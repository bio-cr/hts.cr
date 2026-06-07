require "./libhts"
require "./version"
require "./error"

require "./hts"
require "./bcf/errors"
require "./bcf/header"
require "./bcf/info"
require "./bcf/format"
require "./bcf/record"

module HTS
  class Bcf < Hts
    @@bcf_name2id = ->(hdr : Void*, name : LibC::Char*) : LibC::Int {
      LibHTS.bcf_hdr_id2int(hdr.as(LibHTS::BcfHdrT*), LibHTS2::BCF_DT_CTG, name)
    }

    include Enumerable(Bcf::Record)

    @idx : LibHTS::HtsIdxT
    @header : Bcf::Header?
    @read_header : Bcf::Header?
    # Auto index after close when opened for writing with build_index: true
    @auto_index_on_close : Bool = false
    @index_name_on_close : String = ""
    # Track whether a header has been written/initialized in this handle
    @header_written : Bool = false

    getter :file_name
    getter :mode
    getter :nthreads

    def header : Bcf::Header
      if header = @header
        header
      else
        raise Error.new("Header is not available for #{@file_name}")
      end
    end

    def self.open(file_name : Path | String, mode = "r", index = "",
                  threads = 0, build_index = false, *, subset : Enumerable(String)? = nil)
      new(file_name, mode, index, threads, build_index, subset: subset)
    end

    def self.open(file_name : Path | String, mode = "r", index = "",
                  threads = 0, build_index = false, *, subset : Enumerable(String)? = nil, &)
      file = new(file_name, mode, index, threads, build_index, subset: subset)
      begin
        yield file
      ensure
        file.close
      end
      file
    end

    def initialize(file_name : Path | String, @mode = "r", index = "",
                   threads = 0, build_index = false, *, subset : Enumerable(String)? = nil)
      @file_name = file_name.to_s
      @nthreads = threads
      @idx = LibHTS::HtsIdxT.null
      @header = nil
      @read_header = nil
      @hts_file = Pointer(LibHTS::HtsFile).null

      begin
        # NOTE: Do not check for the existence of local files, since file_names may be remote URIs.

        @hts_file = LibHTS.hts_open(@file_name, @mode)

        raise OpenError.new("Failed to open file #{@file_name}") if @hts_file.null?

        set_threads(threads) if threads > 0

        if subset && @mode[0] == 'w'
          raise SubsetError.new("Sample subsetting is only available when reading BCF/VCF files")
        end

        if @mode[0] == 'w'
          # Defer index building until after close
          if build_index
            @auto_index_on_close = true
            @index_name_on_close = index
          end
          return
        end

        @read_header = Bcf::Header.new(@hts_file)
        if source_header = @read_header
          @header = subset ? source_header.subset(subset) : source_header
        end
        @header_written = true

        build_index(index) if build_index

        @idx = load_index(index)

        @start_position = tell
      rescue ex
        close rescue nil
        raise ex
      end
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
      raise IndexError.new("Indexing failed for #{file_name} (rc=#{r})") if r < 0
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

      cloned_header = header.clone # Necessary. If not, it will cause segfault.
      r = LibHTS.bcf_hdr_write(@hts_file, cloned_header)
      raise Error.new("Failed to write BCF/VCF header") if r < 0

      @header = cloned_header
      @header_written = true
    end

    def header=(header)
      write_header(header)
    end

    def write(var)
      check_closed
      # Guard to ensure header was written before any record
      unless @header_written
        raise Error.new("Header not written. Call write_header(header) first.")
      end
      r = LibHTS.bcf_write(@hts_file, header, var)
      raise Error.new("Failed to write record") if r < 0
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
      each(copy: true) { |record| ary << record }
      ary
    end

    private def each_record_copy(&)
      check_closed

      bcf1 = LibHTS.bcf_init
      begin
        ret = LibHTS.bcf_read(@hts_file, header_for_reading, bcf1)
        while ret >= 0
          record = Bcf::Record.new(header, bcf1)
          # Ownership moved to Record; keep ensure from destroying it.
          bcf1 = Pointer(LibHTS::Bcf1T).null
          apply_subset!(record)
          yield record
          bcf1 = LibHTS.bcf_init
          ret = LibHTS.bcf_read(@hts_file, header_for_reading, bcf1)
        end
        raise Error.new("Failed to read BCF/VCF record from #{@file_name} (rc=#{ret})") if ret < -1
      ensure
        LibHTS.bcf_destroy(bcf1) unless bcf1.null?
      end
    end

    private def each_record_reuse(&)
      check_closed
      bcf1 = LibHTS.bcf_init
      record = Bcf::Record.new(header, bcf1)
      ret = LibHTS.bcf_read(@hts_file, header_for_reading, bcf1)
      while ret >= 0
        apply_subset!(record)
        yield record
        ret = LibHTS.bcf_read(@hts_file, header_for_reading, bcf1)
      end
      raise Error.new("Failed to read BCF/VCF record from #{@file_name} (rc=#{ret})") if ret < -1
    end

    def query(region : String, copy = false, &)
      check_closed
      raise ArgumentError.new("region must not be empty") if region.empty?
      ensure_query_index!

      readrec = ->LibHTS.bcf_readrec(LibHTS::Bgzf*, Void*, Void*, LibC::Int*, LibHTS::HtsPosT*, LibHTS::HtsPosT*)
      itr_query = ->LibHTS.hts_itr_query(LibHTS::HtsIdxT, LibC::Int, LibHTS::HtsPosT, LibHTS::HtsPosT, (LibHTS::Bgzf*, Void*, Void*, LibC::Int*, LibHTS::HtsPosT*, LibHTS::HtsPosT* -> LibC::Int))

      qiter = LibHTS.hts_itr_querys(@idx, region, @@bcf_name2id, header_for_reading.to_unsafe.as(Void*), itr_query, readrec)
      raise_region_query_error(region) if qiter.null?
      begin
        iterate_query_iterator(qiter, copy) { |record| yield record }
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
        begin
          slen = LibHTS2.sam_itr_next(@hts_file, qiter, bcf1)
          while slen >= 0
            record = Bcf::Record.new(header, bcf1)
            # Ownership moved to Record; keep ensure from destroying it.
            bcf1 = Pointer(LibHTS::Bcf1T).null
            apply_subset!(record)
            yield record
            bcf1 = LibHTS.bcf_init
            slen = LibHTS2.sam_itr_next(@hts_file, qiter, bcf1)
          end
          raise Error.new("Failed to read BCF/VCF query record from #{@file_name} (rc=#{slen})") if slen < -1
        ensure
          LibHTS.bcf_destroy(bcf1) unless bcf1.null?
        end
      else
        bcf1 = LibHTS.bcf_init
        record = Bcf::Record.new(header, bcf1)
        slen = LibHTS2.sam_itr_next(@hts_file, qiter, bcf1)
        while slen >= 0
          apply_subset!(record)
          yield record
          slen = LibHTS2.sam_itr_next(@hts_file, qiter, bcf1)
        end
        raise Error.new("Failed to read BCF/VCF query record from #{@file_name} (rc=#{slen})") if slen < -1
      end
    end

    private def header_for_reading : Bcf::Header
      if read_header = @read_header
        read_header
      elsif header = @header
        header
      else
        raise Error.new("Header is not available for #{@file_name}")
      end
    end

    private def apply_subset!(record : Bcf::Record) : Nil
      output_header = @header
      return unless output_header
      return unless output_header.subset?

      source_header = @read_header || output_header
      rc = LibHTS.bcf_subset(source_header, record, output_header.subset_sample_count, output_header.subset_imap_buffer)
      return if rc >= 0

      raise SubsetError.new("Failed to subset samples #{output_header.subset_samples.inspect} while reading #{@file_name}")
    end

    define_getter :chrom
    define_getter :pos
    define_getter :endpos
    define_getter :id
    define_getter :ref
    define_getter :alt
    define_getter :qual
    define_getter :filter

    # Do not add file-level INFO/FORMAT helpers here because these fields
    # depend on each record and its samples. Use Bcf::Record instead.
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
