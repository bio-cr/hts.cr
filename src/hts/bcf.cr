require "./libhts"
require "./version"

require "./hts"
require "./bcf/header"
require "./bcf/info"
require "./bcf/format"
require "./bcf/record"

module HTS
  class Bcf < Hts
    class QueryError < Exception; end
    class MissingIndexError < QueryError; end

    @@bcf_name2id = ->(hdr : Void*, name : LibC::Char*) : LibC::Int {
      LibHTS.bcf_hdr_id2int(hdr.as(LibHTS::BcfHdrT*), LibHTS2::BCF_DT_CTG, name)
    }

    include Enumerable(Bcf::Record)

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

    def self.open(file_name : Path | String, mode = "r", index = "",
                  threads = 0, build_index = false)
      new(file_name, mode, index, threads, build_index)
    end

    def self.open(file_name : Path | String, mode = "r", index = "",
                  threads = 0, build_index = false, &)
      file = new(file_name, mode, index, threads, build_index)
      begin
        yield file
      ensure
        file.close
      end
      file
    end

    def initialize(file_name : Path | String, @mode = "r", index = "",
                   threads = 0, build_index = false)
      @file_name = file_name.to_s
      @nthreads = threads
      @idx = LibHTS::HtsIdxT.null

      # NOTE: Do not check for the existence of local files, since file_names may be remote URIs.

      @hts_file = LibHTS.hts_open(@file_name, @mode)

      raise "Failed to open file #{@file_name}" if @hts_file.null?

      set_threads(threads) if threads > 0

      if @mode[0] == 'w'
        # Defer index building until after close
        if build_index
          @auto_index_on_close = true
          @index_name_on_close = index
        end
        return
      end

      @header = Bcf::Header.new(@hts_file)
      @header_written = true

      build_index(index) if build_index

      @idx = load_index(index)

      @start_position = tell
    end

    # Build index for an on-disk file (callable even after close)
    def self.build_index(file_name : Path | String, index_name = "", min_shift = 14, threads = 0, verbose = true)
      if verbose
        if index_name == ""
          STDERR.puts "Create index for #{file_name}"
        else
          STDERR.puts "Create index for #{file_name} to #{index_name}"
        end
      end
      r = LibHTS.bcf_index_build3(file_name.to_s, index_name, min_shift, threads)
      raise "Indexing failed for #{file_name} (rc=#{r})" if r < 0
    end

    # Instance helper delegating to the class method.
    def build_index(index_name = "", min_shift = 14, verbose = true)
      self.class.build_index(@file_name, index_name, min_shift, @nthreads, verbose)
      self
    end

    def load_index(index_name = "")
      check_closed

      if index_name != ""
        LibHTS.bcf_index_load2(@file_name, index_name)
      else
        LibHTS.bcf_index_load3(@file_name, nil, 2)
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
        self.class.build_index(@file_name, @index_name_on_close, 14, @nthreads, true)
        @auto_index_on_close = false
      end
    end

    def finalize
      close unless closed?
    end

    def write_header(header)
      check_closed

      @header = header.clone # Necessary. If not, it will cause segfault.
      LibHTS.bcf_hdr_write(@hts_file, header)
      @header_written = true
    end

    def header=(header)
      write_header(header)
    end

    def write(var)
      check_closed
      # Guard to ensure header was written before any record
      unless @header_written
        raise "Header not written. Call write_header(header) first."
      end
      r = LibHTS.bcf_write(@hts_file, header, var)
      raise "Failed to write record" if r < 0
    end

    def <<(var)
      write(var)
    end

    def nsamples
      check_closed

      header.nsamples
    end

    def samples
      check_closed

      header.samples
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
    def to_a : Array(Bcf::Record)
      ary = [] of Bcf::Record
      each(copy: true) { |r| ary << r }
      ary
    end

    private def each_record_copy(&)
      check_closed
      while LibHTS.bcf_read(@hts_file, header, bcf1 = LibHTS.bcf_init) != -1
        yield Bcf::Record.new(header, bcf1)
      end
    end

    private def each_record_reuse(&)
      check_closed
      bcf1 = LibHTS.bcf_init
      record = Bcf::Record.new(header, bcf1)
      while LibHTS.bcf_read(@hts_file, header, bcf1) != -1
        yield record
      end
    end

    def query(region : String, copy = false, &)
      check_closed
      raise ArgumentError.new("region must not be empty") if region.empty?
      ensure_query_index!

      readrec = ->LibHTS.bcf_readrec(LibHTS::Bgzf*, Void*, Void*, LibC::Int*, LibHTS::HtsPosT*, LibHTS::HtsPosT*)
      itr_query = ->LibHTS.hts_itr_query(LibHTS::HtsIdxT, LibC::Int, LibHTS::HtsPosT, LibHTS::HtsPosT, (LibHTS::Bgzf*, Void*, Void*, LibC::Int*, LibHTS::HtsPosT*, LibHTS::HtsPosT* -> LibC::Int))

      qiter = LibHTS.hts_itr_querys(@idx, region, @@bcf_name2id, header.to_unsafe.as(Void*), itr_query, readrec)
      raise_region_query_error(region) if qiter.null?
      begin
        iterate_query_iterator(qiter, copy) { |record| yield record }
      ensure
        LibHTS.hts_itr_destroy(qiter)
      end
    end

    def query(regions : Array(String), copy = false, &)
      check_closed
      raise ArgumentError.new("regions must not be empty") if regions.empty?
      ensure_query_index!

      regions.each_with_index do |region, index|
        raise ArgumentError.new("regions[#{index}] must not be empty") if region.empty?
        query(region, copy) { |record| yield record }
      end
    end

    # Numeric (tid) query: coordinates are 0-based half-open [beg, end)
    def query(tid : Int32, beg : Int64, end_pos : Int64, copy = false, &)
      check_closed
      ensure_query_index!
      raise ArgumentError.new("tid (#{tid}) must be >= 0") if tid < 0
      raise ArgumentError.new("beg (#{beg}) must be >= 0 for 0-based half-open coordinates") if beg < 0
      raise ArgumentError.new("beg (#{beg}) must be <= end_pos (#{end_pos})") if beg > end_pos

      readrec = ->LibHTS.bcf_readrec(LibHTS::Bgzf*, Void*, Void*, LibC::Int*, LibHTS::HtsPosT*, LibHTS::HtsPosT*)

      qiter = LibHTS.hts_itr_query(@idx, tid, beg, end_pos, readrec)
      raise_coordinate_query_error(tid, beg, end_pos) if qiter.null?
      begin
        iterate_query_iterator(qiter, copy) { |record| yield record }
      ensure
        LibHTS.hts_itr_destroy(qiter)
      end
    end

    # Chromosome name + range using SAM-style 1-based inclusive coordinates.
    def query(chrom : String, beg : Int64, end_pos : Int64, copy = false, &)
      raise ArgumentError.new("chrom must not be empty") if chrom.empty?
      raise ArgumentError.new("beg (#{beg}) must be >= 1 for 1-based inclusive coordinates") if beg < 1
      raise ArgumentError.new("beg (#{beg}) must be <= end_pos (#{end_pos})") if beg > end_pos

      tid = header.name2id(chrom)
      raise ArgumentError.new("Unknown reference name #{chrom.inspect} in #{@file_name}") if tid < 0

      query(tid, beg - 1, end_pos, copy) { |record| yield record }
    end

    private def ensure_query_index! : Nil
      return if index_loaded?

      raise MissingIndexError.new("Query requires an index for #{@file_name}. Open the BCF/VCF with a matching index or build one first.")
    end

    private def raise_region_query_error(region : String) : NoReturn
      raise QueryError.new("Failed to create an iterator for region #{region.inspect} in #{@file_name}. Check the region syntax, that the reference exists in the header, and that the index matches the file.")
    end

    private def raise_coordinate_query_error(tid : Int32, beg : Int64, end_pos : Int64) : NoReturn
      ref_name = header.target_name(tid)
      raise QueryError.new("Failed to create an iterator for #{ref_name}:#{beg}-#{end_pos} (tid=#{tid}, 0-based half-open) in #{@file_name}. The index may be stale or incompatible with the file.")
    end

    private def iterate_query_iterator(qiter, copy, & : HTS::Bcf::Record ->)
      if copy
        bcf1 = LibHTS.bcf_init
        slen = LibHTS2.sam_itr_next(@hts_file, qiter, bcf1)
        while slen >= 0
          yield Bcf::Record.new(header, bcf1)
          bcf1 = LibHTS.bcf_init
          slen = LibHTS2.sam_itr_next(@hts_file, qiter, bcf1)
        end
      else
        bcf1 = LibHTS.bcf_init
        record = Bcf::Record.new(header, bcf1)
        slen = LibHTS2.sam_itr_next(@hts_file, qiter, bcf1)
        while slen >= 0
          yield record
          slen = LibHTS2.sam_itr_next(@hts_file, qiter, bcf1)
        end
      end
    end

    define_getter :chrom
    define_getter :pos
    define_getter :endpos
    define_getter :id
    define_getter :ref
    define_getter :alt
    define_getter :qual
    define_getter :filter

    def info
      raise NotImplementedError.new
    end

    def format
      raise NotImplementedError.new
    end

    define_iterator :chrom
    define_iterator :pos
    define_iterator :endpos
    define_iterator :id
    define_iterator :ref
    define_iterator :alt
    define_iterator :qual
    define_iterator :filter
  end
end
