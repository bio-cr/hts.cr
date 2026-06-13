require "./libhts"
require "./version"
require "./error"

require "./hts"
require "./bam/header"
require "./bam/cigar"
require "./bam/flag"
require "./bam/record"
require "./bam/base_mod"
require "./bam/pileup"
require "./bam/mpileup"

module HTS
  class Bam < Hts
    class QueryError < Exception; end

    class MissingIndexError < QueryError; end

    alias AuxValue = (Int64 | Float64 | String | Char | Array(Int64) | Array(Float64))?

    include Enumerable(Record)

    @idx : LibHTS::HtsIdxT
    # Auto index after close when opened for writing with build_index: true
    @auto_index_on_close : Bool = false
    @index_name_on_close : String = ""
    # Track whether a header has been written/initialized in this handle
    @header_written : Bool = false

    getter :file_name
    getter :mode
    getter :header
    getter :nthreads

    def self.open(file_name : Path | String, mode = "r", index = "", fai = "",
                  threads = 0, build_index = false)
      new(file_name, mode, index, fai, threads, build_index)
    end

    def self.open(file_name : Path | String, mode = "r", index = "", fai = "",
                  threads = 0, build_index = false, &)
      file = new(file_name, mode, index, fai, threads, build_index)
      begin
        yield file
      ensure
        file.close
      end
      file
    end

    def initialize(file_name : Path | String, @mode = "r", index = "", fai = "",
                   threads = 0, build_index = false)
      @file_name = file_name.to_s
      @nthreads = threads
      @idx = LibHTS::HtsIdxT.null
      @hts_file = Pointer(LibHTS::HtsFile).null
      @header = uninitialized Bam::Header

      begin
        # NOTE: Do not check for the existence of local files, since file_names may be remote URIs.

        @mode = self.class.normalize_mode(@mode)
        index_name = self.class.default_index_name(@file_name, index)

        self.class.build_index(file_name, index_name, 0, threads, false) if build_index && @mode[0] != 'w'

        @hts_file = LibHTS.hts_open(@file_name, @mode)

        raise "Failed to open file #{@file_name}" if @hts_file.null?

        fai = self.class.infer_cram_reference(@file_name, fai)

        if fai != ""
          r = LibHTS.hts_set_fai_filename(@hts_file, fai)
          r < 0 && raise "Failed to load fasta index: #{fai}"
        end

        set_threads(threads) if threads > 0

        if @mode[0] == 'w'
          # Defer index building until after close
          if build_index
            @auto_index_on_close = true
            @index_name_on_close = index_name
          end
          @idx = LibHTS::HtsIdxT.null
          return
        end

        @header = Bam::Header.new(@hts_file)
        @header_written = true

        # Set start position to 0 for CRAM files
        flags = @hts_file.value.flags
        if flags & "1000".to_i(2) != 0 # cram
          @start_position = 0_i64
        else
          @start_position = tell
        end

        @idx = load_index(index)
      rescue ex
        close rescue nil
        raise ex
      end
    end

    protected def self.normalize_mode(mode : String) : String
      # PySAM-compatible mode handling. Do not force 'b' for write:
      # "w" should be SAM text like PySAM.
      case mode
      when "wbu" then "wb0"
      when "rU"  then "rb"
      else            mode
      end
    end

    protected def self.default_index_name(file_name : String, index : String) : String
      return index unless index.empty?
      return "#{file_name}.crai" if file_name.ends_with?(".cram")

      "#{file_name}.bai"
    end

    protected def self.infer_cram_reference(file_name : String, fai : String) : String
      return fai unless fai.empty? && file_name.ends_with?(".cram")

      if remote_file?(file_name)
        file_name.gsub(/\.cram\z/, ".fa")
      else
        potential_ref = File.join(File.dirname(file_name), "#{File.basename(file_name, ".cram")}.fa")
        File.exists?(potential_ref) ? potential_ref : fai
      end
    end

    protected def self.remote_file?(file_name : String) : Bool
      file_name.starts_with?("http://") || file_name.starts_with?("https://")
    end

    # Class method: build index for any file on disk (even after close)
    def self.build_index(file_name : Path | String, index_name = "", min_shift = 0, threads = 0, verbose = true)
      index_name = default_index_name(file_name.to_s, index_name)
      if verbose
        STDERR.puts "Create index for #{file_name} to #{index_name}"
      end

      case LibHTS.sam_index_build3(file_name.to_s, index_name, min_shift, threads)
      when 0 # successful
      when -1 then raise "indexing failed"
      when -2 then raise "opening #{file_name} failed"
      when -3 then raise "format not indexable"
      when -4 then raise "failed to create and/or save the index"
      else         raise "unknown error"
      end
    end

    def build_index(index_name, min_shift = 0, verbose = true)
      check_closed

      if verbose
        if index_name == ""
          STDERR.puts "Create index for #{@file_name}"
        else
          STDERR.puts "Create index for #{@file_name} to #{index_name}"
        end
      end

      case LibHTS.sam_index_build3(@file_name, index_name, min_shift, @nthreads)
      when 0 # successful
      when -1 then raise "indexing failed"
      when -2 then raise "opening #{@file_name} failed"
      when -3 then raise "format not indexable"
      when -4 then raise "failed to create and/or save the index"
      else         raise "unknown error"
      end
      self # for method chaining
    end

    def load_index(index_name = "")
      check_closed

      if index_name != ""
        LibHTS.sam_index_load2(@hts_file, @file_name, index_name)
      else
        LibHTS.sam_index_load3(@hts_file, @file_name, nil, 3) # Changed from 2 to 3 for remote file support
      end
    end

    def index_loaded?
      check_closed

      !@idx.null?
    end

    def close
      LibHTS.hts_idx_destroy(@idx) unless @idx.null?
      @idx = @idx.class.null
      super
      # Auto-build index after file is closed when requested in write mode
      if @auto_index_on_close
        self.class.build_index(@file_name, @index_name_on_close, 0, @nthreads, true)
        @auto_index_on_close = false
      end
    end

    def finalize
      close unless closed?
    end

    def fai=(fai)
      check_closed
      r = LibHTS.hts_set_fai_filename(@hts_file, fai)
      r < 0 && raise "Failed to load fasta: #{fai}"
    end

    def write_header(header)
      check_closed

      cloned_header = header.clone # Necessary. If not, it will cause segfault.
      r = LibHTS.sam_hdr_write(@hts_file, cloned_header)
      raise "Failed to write SAM/BAM header" if r < 0

      @header = cloned_header
      @header_written = true
    end

    def header=(header)
      write_header(header)
    end

    def write(record)
      check_closed
      unless @header_written
        raise "Header not written. Call write_header(header) first."
      end
      r = LibHTS.sam_write1(@hts_file, header, record)
      raise "Failed to write record: #{record}" if r < 0
    end

    def <<(record)
      write(record)
    end

    define_getter :qname
    define_getter :flag
    define_getter :chrom
    define_getter :pos
    define_getter :mapq
    define_getter :cigar
    define_getter :mate_chrom
    define_getter :mate_pos
    define_getter :insert_size
    define_getter :seq
    define_getter :qual

    def isize
      insert_size
    end

    def mpos
      mate_pos
    end

    def aux_int(tag : String) : Array(Int64?)
      collect_aux_values do |record|
        record.aux.get_int(tag)
      end
    end

    def aux_float(tag : String) : Array(Float64?)
      collect_aux_values do |record|
        record.aux.get_float(tag)
      end
    end

    def aux_string(tag : String) : Array(String?)
      collect_aux_values do |record|
        record.aux.get_string(tag)
      end
    end

    def aux_char(tag : String) : Array(Char?)
      collect_aux_values do |record|
        record.aux.get_char(tag)
      end
    end

    def aux(tag : String) : Array(AuxValue)
      collect_aux_values do |record|
        record.aux[tag]
      end
    end

    define_iterator :qname
    define_iterator :flag
    define_iterator :chrom
    define_iterator :pos
    define_iterator :mapq
    define_iterator :cigar
    define_iterator :mate_chrom
    define_iterator :mate_pos
    define_iterator :insert_size
    define_iterator :seq
    define_iterator :qual

    # each_isize
    # each_mpos

    def each_aux_int(tag : String, &)
      each_aux_value do |record|
        yield record.aux.get_int(tag)
      end
    end

    def each_aux_float(tag : String, &)
      each_aux_value do |record|
        yield record.aux.get_float(tag)
      end
    end

    def each_aux_string(tag : String, &)
      each_aux_value do |record|
        yield record.aux.get_string(tag)
      end
    end

    def each_aux_char(tag : String, &)
      each_aux_value do |record|
        yield record.aux.get_char(tag)
      end
    end

    def each_aux(tag : String, &)
      each_aux_value do |record|
        yield record.aux[tag]
      end
    end

    def each(copy = false, &)
      if copy
        each_record_copy do |record|
          yield record
        end
      else
        each_record_reuse do |record|
          yield record
        end
      end
    end

    # Ensure collected records are independent and safe after iteration ends.
    def to_a : Array(Record)
      ary = [] of Record
      each(copy: true) { |record| ary << record }
      ary
    end

    private def each_record_copy(&)
      check_closed

      bam1 = new_bam1!
      begin
        ret = LibHTS.sam_read1(@hts_file, header, bam1)
        while ret >= 0
          record = Record.new(header, take_bam1!(pointerof(bam1)))
          yield record
          bam1 = new_bam1!
          ret = LibHTS.sam_read1(@hts_file, header, bam1)
        end
        raise HTS::Error.new("Failed to read SAM/BAM record from #{@file_name} (rc=#{ret})") if ret < -1
      ensure
        LibHTS.bam_destroy1(bam1) unless bam1.null?
      end
    end

    private def each_record_reuse(&)
      check_closed

      bam1 = new_bam1!
      record = Record.new(header, bam1)
      ret = LibHTS.sam_read1(@hts_file, header, bam1)
      while ret >= 0
        yield record
        ret = LibHTS.sam_read1(@hts_file, header, bam1)
      end
      raise HTS::Error.new("Failed to read SAM/BAM record from #{@file_name} (rc=#{ret})") if ret < -1
    end

    private def collect_aux_values(& : Record -> T) : Array(T) forall T
      check_closed

      position = tell
      ary = [] of T
      begin
        each do |record|
          ary << yield record
        end
      ensure
        restore_aux_position(position)
      end
      ary
    end

    private def each_aux_value(& : Record ->) : self
      check_closed

      position = tell
      begin
        each do |record|
          yield record
        end
      ensure
        restore_aux_position(position)
      end
      self
    end

    private def restore_aux_position(position : Int64?) : Nil
      if position.nil?
        STDERR.puts "Warning: #{@file_name} is not seekable"
      else
        seek(position)
      end
    end

    def query(region : String, copy = false, &)
      check_closed
      raise ArgumentError.new("region must not be empty") if region.empty?
      ensure_query_index!

      qiter = LibHTS.sam_itr_querys(@idx, header, region)
      raise_region_query_error(region) if qiter.null?
      begin
        iterate_iterator(qiter, copy) { |record| yield record }
      ensure
        LibHTS.hts_itr_destroy(qiter)
      end
    end

    # Multi-region query. This currently uses sequential single-region iterators.
    # It preserves the same copy semantics as the single-region query.
    # Records overlapping multiple regions may be yielded more than once;
    # regions are not merged or deduplicated.
    def query(regions : Array(String), copy = false, &)
      check_closed
      raise ArgumentError.new("regions must not be empty") if regions.empty?
      ensure_query_index!

      regions.each_with_index do |region, index|
        raise ArgumentError.new("regions[#{index}] must not be empty") if region.empty?
        query(region, copy) { |record| yield record }
      end
    end

    # IMPORTANT (coordinate systems):
    # - query(region : String, ...) above uses sam_itr_querys(). Region strings follow the SAM spec:
    #   1-based, inclusive coordinates (e.g. "chr1:100-200" covers both ends 100 and 200).
    # - The numeric query methods below use sam_itr_queryi() which takes 0-based, half-open intervals [beg, end).
    #   To convert a region string "chr1:100-200" (1-based inclusive) to numeric form:
    #     beg = 100 - 1 = 99
    #     end = 200      (DO NOT subtract 1)  => numeric interval [99, 200)
    #   Be careful not to decrement the end coordinate during conversion.

    # Numeric (tid) query: coordinates are 0-based half-open [beg, end)
    def query(tid : Int32, beg : Int64, end_pos : Int64, copy = false, &)
      check_closed
      ensure_query_index!
      validate_tid!(tid)
      raise ArgumentError.new("beg (#{beg}) must be >= 0 for 0-based half-open coordinates") if beg < 0
      raise ArgumentError.new("beg (#{beg}) must be <= end_pos (#{end_pos})") if beg > end_pos

      qiter = LibHTS.sam_itr_queryi(@idx, tid, beg, end_pos)
      raise_coordinate_query_error(tid, beg, end_pos) if qiter.null?
      begin
        iterate_iterator(qiter, copy) { |record| yield record }
      ensure
        LibHTS.hts_itr_destroy(qiter)
      end
    end

    # Chromosome name + range using SAM-style 1-based inclusive coordinates.
    def query(chrom : String, beg : Int64, end_pos : Int64, copy = false, &)
      raise ArgumentError.new("chrom must not be empty") if chrom.empty?
      raise ArgumentError.new("beg (#{beg}) must be >= 1 for 1-based inclusive coordinates") if beg < 1
      raise ArgumentError.new("beg (#{beg}) must be <= end_pos (#{end_pos})") if beg > end_pos

      tid = @header.get_tid(chrom)
      raise ArgumentError.new("Unknown reference name #{chrom.inspect} in #{@file_name}") if tid < 0

      # Convert 1-based inclusive [beg, end] to 0-based half-open [beg - 1, end).
      query(tid, beg - 1, end_pos, copy) { |record| yield record }
    end

    private def ensure_query_index! : Nil
      return if index_loaded?

      raise MissingIndexError.new("Query requires an index for #{@file_name}. Open the BAM/CRAM with a matching index or build one first.")
    end

    private def validate_tid!(tid : Int32) : Nil
      target_count = header.target_count
      if tid < 0 || tid >= target_count
        raise ArgumentError.new("tid (#{tid}) must be within 0...#{target_count}")
      end
    end

    private def raise_region_query_error(region : String) : NoReturn
      raise QueryError.new("Failed to create an iterator for region #{region.inspect} in #{@file_name}. Check the region syntax, that the reference exists in the header, and that the index matches the file.")
    end

    private def raise_coordinate_query_error(tid : Int32, beg : Int64, end_pos : Int64) : NoReturn
      ref_name = header.target_name(tid)
      raise QueryError.new("Failed to create an iterator for #{ref_name}:#{beg}-#{end_pos} (tid=#{tid}, 0-based half-open) in #{@file_name}. The index may be stale or incompatible with the file.")
    end

    private def iterate_iterator(qiter, copy, & : HTS::Bam::Record ->)
      if copy
        bam1 = new_bam1!
        begin
          slen = LibHTS2.sam_itr_next(@hts_file, qiter, bam1)
          while slen >= 0
            record = Record.new(header, take_bam1!(pointerof(bam1)))
            yield record
            bam1 = new_bam1!
            slen = LibHTS2.sam_itr_next(@hts_file, qiter, bam1)
          end
          raise HTS::Error.new("Failed to read SAM/BAM query record from #{@file_name} (rc=#{slen})") if slen < -1
        ensure
          LibHTS.bam_destroy1(bam1) unless bam1.null?
        end
      else
        bam1 = new_bam1!
        record = Record.new(header, bam1)
        slen = LibHTS2.sam_itr_next(@hts_file, qiter, bam1)
        while slen >= 0
          yield record
          slen = LibHTS2.sam_itr_next(@hts_file, qiter, bam1)
        end
        raise HTS::Error.new("Failed to read SAM/BAM query record from #{@file_name} (rc=#{slen})") if slen < -1
      end
    end

    private def new_bam1! : LibHTS::Bam1T*
      bam1 = LibHTS.bam_init1
      raise "bam_init1 failed" if bam1.null?
      bam1
    end

    private def take_bam1!(slot : Pointer(LibHTS::Bam1T*)) : LibHTS::Bam1T*
      bam1 = slot.value
      slot.value = Pointer(LibHTS::Bam1T).null
      bam1
    end
  end
end
