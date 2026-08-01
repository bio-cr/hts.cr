require "./libhts"
require "./version"
require "./error"

require "./bgzf"
require "./tabix/errors"

module HTS
  class Tabix < Bgzf
    @idx : LibHTS::TbxT*

    getter :file_name
    getter :mode

    def self.open(file_name : Path | String, mode = "r", index = "", threads = 0, build_index = false, preset = :vcf)
      new(file_name, mode, index, threads, build_index, preset)
    end

    def self.open(file_name : Path | String, mode = "r", index = "", threads = 0, build_index = false, preset = :vcf, &)
      file = new(file_name, mode, index, threads, build_index, preset)
      close_after_yield(file) { |handle| yield handle }
      file
    end

    def initialize(file_name : Path | String, @mode = "r", index = "", threads = 0, build_index = false, preset = :vcf)
      @file_name = file_name.to_s
      @idx = Pointer(LibHTS::TbxT).null
      @hts_file = Pointer(LibHTS::HtsFile).null

      begin
        # NOTE: Do not check for the existence of local files, since file_names may be remote URIs.

        @hts_file = LibHTS.hts_open(@file_name.to_s.to_unsafe, @mode.to_unsafe)
        raise OpenError.new("Failed to open file #{@file_name}") if @hts_file.null?

        set_threads(threads) if threads > 0

        build_index(index, preset: preset) if build_index
        @idx = load_index(index)
        @start_position = tell
      rescue ex
        close rescue nil
        raise ex
      end
    end

    # Build a tabix index for *file_name* on disk. Uses the VCF preset by default.
    #
    # Supported presets are `:vcf`, `:bed`, `:gff`, `:sam`, and `:psltbl`.
    def self.build_index(file_name : Path | String, index_name = "", min_shift = 0, threads = 0, verbose = true, preset = :vcf)
      fn = file_name.to_s
      if verbose
        if index_name == ""
          STDERR.puts "Create index for #{fn}"
        else
          STDERR.puts "Create index for #{fn} to #{index_name}"
        end
      end

      conf = tabix_conf_for(preset)
      rc =
        if threads > 0
          LibHTS.tbx_index_build3(fn, index_name == "" ? Pointer(LibC::Char).null : index_name.to_unsafe, min_shift, threads, pointerof(conf))
        elsif index_name != ""
          LibHTS.tbx_index_build2(fn, index_name, min_shift, pointerof(conf))
        else
          LibHTS.tbx_index_build(fn, min_shift, pointerof(conf))
        end

      case rc
      when 0 # success
      when -1 then raise IndexError.new("General failure indexing #{fn}")
      when -2 then raise IndexError.new("Compression is not BGZF: #{fn}")
      else         raise IndexError.new("Unknown error indexing #{fn} (rc=#{rc})")
      end
    end

    # Build a tabix index for this file. Delegates to the class method.
    def build_index(index_name = "", min_shift = 0, verbose = true, preset = :vcf)
      self.class.build_index(@file_name.to_s, index_name, min_shift, (@nthreads || 0), verbose, preset)
      self
    end

    def load_index(index_name = "")
      check_closed
      if index_name != ""
        LibHTS.tbx_index_load2(@file_name.to_s, index_name)
      else
        LibHTS.tbx_index_load3(@file_name.to_s, Pointer(LibC::Char).null, 2)
      end
    end

    def index_loaded?
      check_closed
      !@idx.null?
    end

    # Return the sequence (chromosome) ID for *name*, or -1 if not found.
    def name2id(name : String) : Int32
      check_closed
      raise ArgumentError.new("name must not be empty") if name.empty?
      ensure_index!("name2id")
      LibHTS.tbx_name2id(@idx, name)
    end

    # Return the list of sequence names stored in the index.
    def seqnames : Array(String)
      check_closed
      ensure_index!("seqnames")
      n = 0
      names = LibHTS.tbx_seqnames(@idx, pointerof(n))
      begin
        raise ReadError.new("Failed to load seqnames for #{@file_name}") if names.null? && n > 0

        Array(String).new(n) do |i|
          name = names[i]
          raise ReadError.new("Failed to load seqname #{i} for #{@file_name}") if name.null?
          String.new(name)
        end
      ensure
        LibC.free(names.as(Void*)) unless names.null?
      end
    end

    # Query by region string using htslib's native parser.
    # Yields each matching record as an Array(String) of tab-split fields.
    def query(region : String, &)
      check_closed
      raise ArgumentError.new("region must not be empty") if region.empty?
      ensure_index!("query")
      each_fields(region) { |fields| yield fields }
    end

    def each_fields(region : String, & : Array(String) ->) : self
      each_line_view(region) { |line| yield owning_fields(line) }
      self
    end

    def each_line(region : String, & : String ->) : self
      each_line_view(region) { |line| yield String.new(line) }
      self
    end

    # The borrowed line is valid only during the block.
    @[Experimental]
    def each_line_view(region : String, & : Bytes ->) : self
      check_closed
      raise ArgumentError.new("region must not be empty") if region.empty?
      ensure_index!("each_line_view")
      qiter = LibHTS2.tbx_itr_querys(@idx, region)
      raise_region_query_error(region) if qiter.null?
      begin
        each_line_view_from_iterator(qiter) { |line| yield line }
      ensure
        LibHTS.hts_itr_destroy(qiter)
      end
      self
    end

    # The values and their backing array are reused after each block call.
    @[Experimental]
    def each_selected_fields(region : String, *field_indices, & : Array(Bytes) ->) : self
      indices = field_indices.map(&.to_i32)
      if index = indices.find { |field_index| field_index < 0 }
        raise ArgumentError.new("field index must not be negative: #{index}")
      end

      values = Array(Bytes).new(indices.size, Bytes.empty)
      found = Array(Bool).new(indices.size, false)
      each_line_view(region) do |line|
        select_fields!(line, indices, values, found)
        yield values
      end
      self
    end

    # Query by chromosome name and 0-based half-open coordinates [start, end_).
    # Yields each matching record as an Array(String) of tab-split fields.
    def query(chrom : String, start : Int, end_ : Int, &)
      check_closed
      raise ArgumentError.new("chrom must not be empty") if chrom.empty?
      ensure_index!("query")
      tid = name2id(chrom)
      raise ArgumentError.new("Unknown reference name #{chrom.inspect} in #{@file_name}") if tid < 0
      raise ArgumentError.new("start (#{start}) must be >= 0 for 0-based half-open coordinates") if start < 0
      raise ArgumentError.new("start (#{start}) must be <= end_ (#{end_})") if start > end_
      query_by_coord(tid, start.to_i64, end_.to_i64) { |line| yield owning_fields(line) }
      self
    end

    def close
      unless @idx.null?
        LibHTS.tbx_destroy(@idx)
        @idx = Pointer(LibHTS::TbxT).null
      end
      super
    end

    def finalize
      close unless closed?
    rescue Exception
      nil
    end

    private def query_by_coord(tid : Int32, beg : Int64, end_pos : Int64, &)
      qiter = LibHTS2.tbx_itr_queryi(@idx, tid, beg, end_pos)
      raise_coordinate_query_error(tid, beg, end_pos) if qiter.null?
      begin
        each_line_view_from_iterator(qiter) { |line| yield line }
      ensure
        LibHTS.hts_itr_destroy(qiter)
      end
    end

    private def ensure_index!(operation : String) : Nil
      return if index_loaded?

      raise MissingIndexError.new("#{operation} requires an index for #{@file_name}. Open the file with a matching .tbi/.csi index or build one first.")
    end

    private def raise_region_query_error(region : String) : NoReturn
      raise QueryError.new("Failed to create an iterator for region #{region.inspect} in #{@file_name}. Check the region syntax, that the reference exists in the index, and that the index matches the file.")
    end

    private def raise_coordinate_query_error(tid : Int32, beg : Int64, end_pos : Int64) : NoReturn
      ref_name = seqnames[tid]? || tid.to_s
      raise QueryError.new("Failed to create an iterator for #{ref_name}:#{beg}-#{end_pos} (tid=#{tid}, 0-based half-open) in #{@file_name}. The index may be stale or incompatible with the file.")
    end

    private def each_line_view_from_iterator(qiter, & : Bytes ->) : Nil
      r = LibHTS::KstringT.new
      r.l = 0
      r.m = 0
      r.s = Pointer(LibC::Char).null
      begin
        while (rc = LibHTS2.tbx_itr_next(@hts_file, @idx, qiter, pointerof(r).as(Void*))) > 0
          yield Bytes.new(r.s.as(UInt8*), r.l.to_i)
        end
        raise ReadError.new("Failed to read tabix query record from #{@file_name} (rc=#{rc})") if rc < -1
      ensure
        LibC.free(r.s) unless r.s.null?
      end
    end

    private def owning_fields(line : Bytes) : Array(String)
      fields = [] of String
      each_field_view(line) { |field| fields << String.new(field) }
      fields
    end

    private def select_fields!(line : Bytes, indices, values : Array(Bytes), found : Array(Bool)) : Nil
      found.fill(false)
      field_count = 0
      each_field_view(line) do |field|
        indices.each_with_index do |requested_index, output_index|
          if requested_index == field_count
            values[output_index] = field
            found[output_index] = true
          end
        end
        field_count += 1
      end

      if output_index = found.index(false)
        raise ::IndexError.new("field index #{indices[output_index]} out of range 0...#{field_count}")
      end
    end

    private def each_field_view(line : Bytes, & : Bytes ->) : Nil
      field_start = 0
      line.each_with_index do |byte, index|
        next unless byte == '\t'.ord

        yield line[field_start, index - field_start]
        field_start = index + 1
      end
      yield line[field_start, line.size - field_start]
    end

    private def self.tabix_conf_for(preset)
      case preset.to_s.downcase
      when "vcf"    then LibHTS.tbx_conf_vcf
      when "bed"    then LibHTS.tbx_conf_bed
      when "gff"    then LibHTS.tbx_conf_gff
      when "sam"    then LibHTS.tbx_conf_sam
      when "psltbl" then LibHTS.tbx_conf_psltbl
      else
        raise ArgumentError.new("Unsupported tabix preset: #{preset.inspect}")
      end
    end
  end
end
