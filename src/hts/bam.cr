require "./libhts"
require "./version"

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

      # NOTE: Do not check for the existence of local files, since file_names may be remote URIs.

      # PySAM-compatible mode handling
      # Do NOT force 'b' for write: "w" should be SAM text like PySAM.
      # Apply small compatibility mappings observed in PySAM:
      # - "wbu" => "wb0" (htslib handles wb0; wbu may not work)
      # - "rU"  => "rb"  (uppercase U is not recognized by htslib)
      case @mode
      when "wbu"
        @mode = "wb0"
      when "rU"
        @mode = "rb"
      end

      @hts_file = LibHTS.hts_open(@file_name, @mode)

      raise "Failed to open file #{@file_name}" if @hts_file.null?

      # Auto-detect and set reference for CRAM files
      if fai == "" && @file_name.ends_with?(".cram")
        # Remote URL case: avoid File.join which introduces backslashes on Windows
        if @file_name.starts_with?("http://") || @file_name.starts_with?("https://")
          # Replace only the trailing .cram with .fa to keep URL separators intact
          potential_ref = @file_name.gsub(/\.cram\z/, ".fa")
          fai = potential_ref
        else
          # Local file case: construct a sibling .fa path and use it only if it exists
          base_name = File.basename(@file_name, ".cram")
          dir_name = File.dirname(@file_name)
          potential_ref = File.join(dir_name, "#{base_name}.fa")
          fai = potential_ref if File.exists?(potential_ref)
        end
      end

      if fai != ""
        r = LibHTS.hts_set_fai_filename(@hts_file, fai)
        r < 0 && raise "Failed to load fasta index: #{fai}"
      end

      set_threads(threads) if threads > 0

      if @mode[0] == 'w'
        # Defer index building until after close
        if build_index
          @auto_index_on_close = true
          @index_name_on_close = index
        end
        @idx = LibHTS::HtsIdxT.null
        return
      end

      @header = Bam::Header.new(@hts_file)
      @header_written = true

      @idx = load_index(index)

      # Set start position to 0 for CRAM files
      flags = @hts_file.value.flags
      if (flags & "1000".to_i(2) != 0) # cram
        @start_position = 0_i64
      else
        @start_position = tell
      end

      build_index(index) if build_index
    end

    # Class method: build index for any file on disk (even after close)
    def self.build_index(file_name : Path | String, index_name = "", min_shift = 0, threads = 0, verbose = true)
      if verbose
        if index_name == ""
          STDERR.puts "Create index for #{file_name}"
        else
          STDERR.puts "Create index for #{file_name} to #{index_name}"
        end
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

      @header = header.clone # Necessary. If not, it will cause segfault.
      LibHTS.sam_hdr_write(@hts_file, header)
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

    # def aux(tag)

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

    # each_aux(tag)

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
      each(copy: true) { |r| ary << r }
      ary
    end

    private def each_record_copy(&)
      check_closed

      while LibHTS.sam_read1(@hts_file, header, bam1 = LibHTS.bam_init1) != -1
        yield Record.new(header, bam1)
      end
    end

    private def each_record_reuse(&)
      check_closed

      bam1 = LibHTS.bam_init1
      record = Record.new(header, bam1)
      while LibHTS.sam_read1(@hts_file, header, bam1) != -1
        yield record
      end
    end

    def query(region : String, copy = false, &)
      check_closed
      raise "Index file is required to call the query method." unless index_loaded?

      qiter = LibHTS.sam_itr_querys(@idx, header, region)
      raise "sam_itr_querys failed for region: #{region}" if qiter.null?
      begin
        iterate_iterator(qiter, copy) { |r| yield r }
      ensure
        LibHTS.hts_itr_destroy(qiter)
      end
    end

    # Multi-region query. This currently uses sequential single-region iterators.
    # It preserves the same copy semantics as the single-region query.
    def query(regions : Array(String), copy = false, &)
      check_closed
      raise "Index file is required to call the query method." unless index_loaded?

      regions.each do |region|
        query(region, copy) { |r| yield r }
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
      raise "Index file is required to call the query method." unless index_loaded?
      raise "tid (#{tid}) must be >= 0" if tid < 0
      raise "beg (#{beg}) must be <= end (#{end_pos})" if beg > end_pos

      qiter = LibHTS.sam_itr_queryi(@idx, tid, beg, end_pos)
      raise "sam_itr_queryi failed (tid=#{tid}, beg=#{beg}, end=#{end_pos})" if qiter.null?
      begin
        iterate_iterator(qiter, copy) { |r| yield r }
      ensure
        LibHTS.hts_itr_destroy(qiter)
      end
    end

    # Chromosome name + range using SAM-style 1-based inclusive coordinates.
    def query(chrom : String, beg : Int64, end_pos : Int64, copy = false, &)
      raise "beg (#{beg}) must be >= 1" if beg < 1
      raise "beg (#{beg}) must be <= end (#{end_pos})" if beg > end_pos

      tid = @header.get_tid(chrom)
      raise "Unknown reference name: #{chrom}" if tid < 0

      # Convert 1-based inclusive [beg, end] to 0-based half-open [beg - 1, end).
      query(tid, beg - 1, end_pos, copy) { |r| yield r }
    end

    private def iterate_iterator(qiter, copy, & : HTS::Bam::Record ->)
      if copy
        bam1 = LibHTS.bam_init1
        slen = LibHTS2.sam_itr_next(@hts_file, qiter, bam1)
        while slen > 0
          yield Record.new(header, bam1)
          bam1 = LibHTS.bam_init1
          slen = LibHTS2.sam_itr_next(@hts_file, qiter, bam1)
        end
      else
        bam1 = LibHTS.bam_init1
        record = Record.new(header, bam1)
        slen = LibHTS2.sam_itr_next(@hts_file, qiter, bam1)
        while slen > 0
          yield record
          slen = LibHTS2.sam_itr_next(@hts_file, qiter, bam1)
        end
      end
    end
  end
end
