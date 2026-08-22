require "./libhts"
require "./version"
require "./error"

require "./hts"
require "./bcf/errors"
require "./bcf/header"
require "./bcf/scratch"
require "./bcf/info"
require "./bcf/format"
require "./bcf/record"

module HTS
  class Bcf < Hts
    include Enumerable(Bcf::Record)

    @idx : LibHTS::HtsIdxT
    @tbx : LibHTS::TbxT*
    # Kept separately so opening a sequential reader does not load the index.
    @index_name : String
    @header : Bcf::Header?
    @read_header : Bcf::Header?
    @read_subset_imap : Slice(Int32)?
    @max_unpack : Int32
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
                  threads = 0, build_index = false, *, subset : Enumerable(String)? = nil,
                  unpack : Symbol = :all)
      new(file_name, mode, index, threads, build_index, subset: subset, unpack: unpack)
    end

    def self.open(file_name : Path | String, mode = "r", index = "",
                  threads = 0, build_index = false, *, subset : Enumerable(String)? = nil,
                  unpack : Symbol = :all, &)
      file = new(file_name, mode, index, threads, build_index, subset: subset, unpack: unpack)
      close_after_yield(file) { |handle| yield handle }
    end

    def initialize(file_name : Path | String, @mode = "r", index = "",
                   threads = 0, build_index = false, *, subset : Enumerable(String)? = nil,
                   unpack : Symbol = :all)
      @file_name = file_name.to_s
      @nthreads = threads
      @max_unpack = unpack_level(unpack)
      @idx = LibHTS::HtsIdxT.null
      @tbx = Pointer(LibHTS::TbxT).null
      @index_name = index
      @header = nil
      @read_header = nil
      @read_subset_imap = nil
      @hts_file = Pointer(LibHTS::HtsFile).null

      validate_reader_options!(subset, unpack)

      begin
        # NOTE: Do not check for the existence of local files, since file_names may be remote URIs.

        @hts_file = LibHTS.hts_open(@file_name, @mode)

        raise OpenError.new("Failed to open file #{@file_name}") if @hts_file.null?

        set_threads(threads) if threads > 0

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
          if subset
            subset_names = subset.map(&.to_s).to_a
            source_samples = source_header.samples
            @header = source_header.subset(subset_names)
            configure_sample_selection!(source_header, subset_names)
            @read_subset_imap = sample_reorder_imap(source_samples, subset_names)
          else
            @header = source_header
          end
        end
        @header_written = true

        build_index(index) if build_index

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
      path = file_name.to_s
      index_path = index_name.empty? ? Pointer(LibC::Char).null : index_name.to_unsafe
      r = if vcf_text_file?(path)
            conf = LibHTS.tbx_conf_vcf
            LibHTS.tbx_index_build3(path, index_path, min_shift, threads, pointerof(conf))
          else
            LibHTS.bcf_index_build3(path, index_path, min_shift, threads)
          end
      raise IndexError.new("Indexing failed for #{file_name} (rc=#{r})") if r < 0
    end

    private def self.vcf_text_file?(path : String) : Bool
      file = LibHTS.hts_open(path, "r")
      raise OpenError.new("Failed to inspect file #{path} before indexing") if file.null?
      begin
        format = LibHTS.hts_get_format(file)
        !format.null? && format.value.format == LibHTS::HtsExactFormat::Vcf
      ensure
        LibHTS.hts_close(file)
      end
    end

    # Instance helper delegating to the class method.
    def build_index(index_name = "", min_shift = 14, verbose = true)
      self.class.build_index(@file_name, index_name, min_shift, @nthreads, verbose)
      self
    end

    def load_index(index_name = @index_name) : self
      return self if try_load_index(index_name)

      raise MissingIndexError.new("Failed to load index #{index_name.empty? ? "for #{@file_name}" : index_name}")
    end

    def try_load_index(index_name = @index_name) : Bool
      check_closed

      LibHTS.hts_idx_destroy(@idx) unless @idx.null?
      LibHTS.tbx_destroy(@tbx) unless @tbx.null?
      @idx = LibHTS::HtsIdxT.null
      @tbx = Pointer(LibHTS::TbxT).null
      if vcf_text_backend?
        @tbx = if index_name != ""
                 LibHTS.tbx_index_load2(@file_name, index_name)
               else
                 LibHTS.tbx_index_load3(@file_name, nil, 2)
               end
      else
        @idx = if index_name != ""
                 LibHTS.bcf_index_load2(@file_name, index_name)
               else
                 LibHTS.bcf_index_load3(@file_name, nil, 2)
               end
      end
      index_loaded?
    end

    def index_loaded?
      check_closed

      !@idx.null? || !@tbx.null?
    end

    def close
      LibHTS.hts_idx_destroy(@idx) unless @idx.null?
      LibHTS.tbx_destroy(@tbx) unless @tbx.null?
      @idx = @idx.class.null
      @tbx = @tbx.class.null
      super
      # Auto-build index after file is closed when requested in write mode
      if @auto_index_on_close
        self.class.build_index(@file_name, @index_name_on_close, 14, @nthreads, true)
        @auto_index_on_close = false
      end
    end

    def finalize
      LibHTS.hts_idx_destroy(@idx) unless @idx.null?
      LibHTS.tbx_destroy(@tbx) unless @tbx.null?
      @idx = @idx.class.null
      @tbx = @tbx.class.null
      close_hts_file
    rescue Exception
      nil
    end

    protected def close_error : Exception
      WriteError.new("Failed to close BCF file #{@file_name}")
    end

    def write_header(header)
      check_closed

      cloned_header = header.clone # Necessary. If not, it will cause segfault.
      r = LibHTS.bcf_hdr_write(@hts_file, cloned_header)
      raise WriteError.new("Failed to write BCF/VCF header") if r < 0

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
        raise WriteError.new("Header not written. Call write_header(header) first.")
      end
      r = LibHTS.bcf_write(@hts_file, header, var)
      raise WriteError.new("Failed to write record") if r < 0
    end

    def <<(var)
      write(var)
      self
    end

    def nsamples
      check_closed

      header.nsamples
    end

    def samples
      check_closed

      header.samples
    end

    def each(&)
      each_record_reuse do |record|
        yield record
      end
    end

    def each_copy(&)
      each_record_copy do |record|
        yield record
      end
    end

    # Ensure collected records are independent and safe after iteration ends.
    def to_a : Array(Bcf::Record)
      ary = [] of Bcf::Record
      each_copy { |record| ary << record }
      ary
    end

    private def each_record_copy(&)
      check_closed

      bcf1 = new_bcf1!
      begin
        ret = LibHTS.bcf_read(@hts_file, header_for_reading, bcf1)
        while ret >= 0
          record = Bcf::Record.new(header, take_bcf1!(pointerof(bcf1)))
          apply_read_subset_order!(record)
          yield record
          bcf1 = new_bcf1!
          ret = LibHTS.bcf_read(@hts_file, header_for_reading, bcf1)
        end
        raise ReadError.new("Failed to read BCF/VCF record from #{@file_name} (rc=#{ret})") if ret < -1
      ensure
        LibHTS.bcf_destroy(bcf1) unless bcf1.null?
      end
    end

    private def each_record_reuse(&)
      check_closed
      bcf1 = new_bcf1!
      record = Bcf::Record.new(header, bcf1)
      ret = LibHTS.bcf_read(@hts_file, header_for_reading, bcf1)
      while ret >= 0
        apply_read_subset_order!(record)
        yield record
        ret = LibHTS.bcf_read(@hts_file, header_for_reading, bcf1)
      end
      raise ReadError.new("Failed to read BCF/VCF record from #{@file_name} (rc=#{ret})") if ret < -1
    end

    def query(region : String, &)
      check_closed
      raise ArgumentError.new("region must not be empty") if region.empty?
      ensure_query_index!

      qiter = query_region_iterator(region)
      raise_region_query_error(region) if qiter.null?
      begin
        iterate_query_iterator(qiter) { |record| yield record }
      ensure
        LibHTS.hts_itr_destroy(qiter)
      end
    end

    def query_copy(region : String, &)
      check_closed
      raise ArgumentError.new("region must not be empty") if region.empty?
      ensure_query_index!

      qiter = query_region_iterator(region)
      raise_region_query_error(region) if qiter.null?
      begin
        iterate_query_iterator_copy(qiter) { |record| yield record }
      ensure
        LibHTS.hts_itr_destroy(qiter)
      end
    end

    # Multi-region query. This currently uses sequential single-region iterators.
    # Records overlapping multiple regions may be yielded more than once;
    # regions are not merged or deduplicated.
    def query(regions : Array(String), &)
      check_closed
      raise ArgumentError.new("regions must not be empty") if regions.empty?
      ensure_query_index!

      regions.each_with_index do |region, index|
        raise ArgumentError.new("regions[#{index}] must not be empty") if region.empty?
        query(region) { |record| yield record }
      end
    end

    def query_copy(regions : Array(String), &)
      check_closed
      raise ArgumentError.new("regions must not be empty") if regions.empty?
      ensure_query_index!

      regions.each_with_index do |region, index|
        raise ArgumentError.new("regions[#{index}] must not be empty") if region.empty?
        query_copy(region) { |record| yield record }
      end
    end

    # Numeric (tid) query: coordinates are 0-based half-open [beg, end)
    def query(tid : Int32, beg : Int64, end_pos : Int64, &)
      check_closed
      ensure_query_index!
      validate_tid!(tid)
      raise ArgumentError.new("beg (#{beg}) must be >= 0 for 0-based half-open coordinates") if beg < 0
      raise ArgumentError.new("beg (#{beg}) must be <= end_pos (#{end_pos})") if beg > end_pos

      qiter = query_coordinate_iterator(tid, beg, end_pos)
      raise_coordinate_query_error(tid, beg, end_pos) if qiter.null?
      begin
        iterate_query_iterator(qiter) { |record| yield record }
      ensure
        LibHTS.hts_itr_destroy(qiter)
      end
    end

    def query_copy(tid : Int32, beg : Int64, end_pos : Int64, &)
      check_closed
      ensure_query_index!
      validate_tid!(tid)
      raise ArgumentError.new("beg (#{beg}) must be >= 0 for 0-based half-open coordinates") if beg < 0
      raise ArgumentError.new("beg (#{beg}) must be <= end_pos (#{end_pos})") if beg > end_pos

      qiter = query_coordinate_iterator(tid, beg, end_pos)
      raise_coordinate_query_error(tid, beg, end_pos) if qiter.null?
      begin
        iterate_query_iterator_copy(qiter) { |record| yield record }
      ensure
        LibHTS.hts_itr_destroy(qiter)
      end
    end

    # Chromosome name + range using 0-based half-open coordinates [beg, end_pos).
    def query(chrom : String, beg : Int64, end_pos : Int64, &)
      raise ArgumentError.new("chrom must not be empty") if chrom.empty?
      raise ArgumentError.new("beg (#{beg}) must be >= 0 for 0-based half-open coordinates") if beg < 0
      raise ArgumentError.new("beg (#{beg}) must be <= end_pos (#{end_pos})") if beg > end_pos

      tid = header.name2id(chrom)
      raise ArgumentError.new("Unknown reference name #{chrom.inspect} in #{@file_name}") if tid < 0

      query(tid, beg, end_pos) { |record| yield record }
    end

    def query_copy(chrom : String, beg : Int64, end_pos : Int64, &)
      raise ArgumentError.new("chrom must not be empty") if chrom.empty?
      raise ArgumentError.new("beg (#{beg}) must be >= 0 for 0-based half-open coordinates") if beg < 0
      raise ArgumentError.new("beg (#{beg}) must be <= end_pos (#{end_pos})") if beg > end_pos

      tid = header.name2id(chrom)
      raise ArgumentError.new("Unknown reference name #{chrom.inspect} in #{@file_name}") if tid < 0

      query_copy(tid, beg, end_pos) { |record| yield record }
    end

    private def ensure_query_index! : Nil
      return if index_loaded?

      return if try_load_index

      raise MissingIndexError.new("Query requires an index for #{@file_name}. Open the BCF/VCF with a matching index or build one first.")
    end

    private def vcf_text_backend? : Bool
      format = LibHTS.hts_get_format(@hts_file)
      !format.null? && format.value.format == LibHTS::HtsExactFormat::Vcf
    end

    private def query_region_iterator(region : String)
      if @tbx.null?
        LibHTS2.bcf_itr_querys(@idx, header_for_reading, region)
      else
        LibHTS2.tbx_itr_querys(@tbx, region)
      end
    end

    private def query_coordinate_iterator(tid : Int32, beg : Int64, end_pos : Int64)
      if @tbx.null?
        LibHTS2.bcf_itr_queryi(@idx, tid, beg, end_pos)
      else
        LibHTS2.tbx_itr_queryi(@tbx, tid, beg, end_pos)
      end
    end

    private def validate_tid!(tid : Int32) : Nil
      target_count = header.target_count
      unless 0 <= tid < target_count
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

    private def iterate_query_iterator(qiter, & : HTS::Bcf::Record ->)
      return iterate_vcf_query_iterator(qiter) { |record| yield record } unless @tbx.null?

      bcf1 = new_bcf1!
      record = Bcf::Record.new(header, bcf1)
      slen = LibHTS2.bcf_itr_next(@hts_file, qiter, bcf1)
      while slen >= 0
        apply_iterator_subset!(record)
        yield record
        slen = LibHTS2.bcf_itr_next(@hts_file, qiter, bcf1)
      end
      raise ReadError.new("Failed to read BCF/VCF query record from #{@file_name} (rc=#{slen})") if slen < -1
    end

    private def iterate_query_iterator_copy(qiter, & : HTS::Bcf::Record ->)
      return iterate_vcf_query_iterator_copy(qiter) { |record| yield record } unless @tbx.null?

      bcf1 = new_bcf1!
      begin
        slen = LibHTS2.bcf_itr_next(@hts_file, qiter, bcf1)
        while slen >= 0
          record = Bcf::Record.new(header, take_bcf1!(pointerof(bcf1)))
          apply_iterator_subset!(record)
          yield record
          bcf1 = new_bcf1!
          slen = LibHTS2.bcf_itr_next(@hts_file, qiter, bcf1)
        end
        raise ReadError.new("Failed to read BCF/VCF query record from #{@file_name} (rc=#{slen})") if slen < -1
      ensure
        LibHTS.bcf_destroy(bcf1) unless bcf1.null?
      end
    end

    private def iterate_vcf_query_iterator(qiter, & : HTS::Bcf::Record ->) : Nil
      line = LibHTS::KstringT.new
      bcf1 = new_bcf1!
      record = Bcf::Record.new(header, bcf1)
      begin
        while (rc = LibHTS2.tbx_itr_next(@hts_file, @tbx, qiter, pointerof(line).as(Void*))) >= 0
          parse_vcf_query_line!(pointerof(line), bcf1)
          apply_iterator_subset!(record)
          yield record
          LibHTS.bcf_clear(bcf1)
        end
        raise ReadError.new("Failed to read VCF query record from #{@file_name} (rc=#{rc})") if rc < -1
      ensure
        LibC.free(line.s) unless line.s.null?
      end
    end

    private def iterate_vcf_query_iterator_copy(qiter, & : HTS::Bcf::Record ->) : Nil
      line = LibHTS::KstringT.new
      bcf1 = new_bcf1!
      begin
        while (rc = LibHTS2.tbx_itr_next(@hts_file, @tbx, qiter, pointerof(line).as(Void*))) >= 0
          parse_vcf_query_line!(pointerof(line), bcf1)
          record = Bcf::Record.new(header, take_bcf1!(pointerof(bcf1)))
          apply_iterator_subset!(record)
          yield record
          bcf1 = new_bcf1!
        end
        raise ReadError.new("Failed to read VCF query record from #{@file_name} (rc=#{rc})") if rc < -1
      ensure
        LibHTS.bcf_destroy(bcf1) unless bcf1.null?
        LibC.free(line.s) unless line.s.null?
      end
    end

    private def parse_vcf_query_line!(line : LibHTS::KstringT*, bcf1 : LibHTS::Bcf1T*) : Nil
      rc = LibHTS.vcf_parse(line, header_for_reading, bcf1)
      raise ReadError.new("Failed to parse indexed VCF record from #{@file_name} (rc=#{rc})") if rc < 0
    end

    private def new_bcf1! : LibHTS::Bcf1T*
      bcf1 = LibHTS.bcf_init
      raise RecordError.new("bcf_init failed") if bcf1.null?
      bcf1.value.max_unpack = @max_unpack
      bcf1
    end

    private def unpack_level(unpack : Symbol) : Int32
      case unpack
      when :site_only then LibHTS2::BCF_UN_SHR
      when :info      then LibHTS2::BCF_UN_INFO
      when :format    then LibHTS2::BCF_UN_FMT
      when :all       then LibHTS2::BCF_UN_ALL
      else
        raise ArgumentError.new("Unknown BCF unpack level: #{unpack.inspect}")
      end
    end

    private def take_bcf1!(slot : Pointer(LibHTS::Bcf1T*)) : LibHTS::Bcf1T*
      bcf1 = slot.value
      slot.value = Pointer(LibHTS::Bcf1T).null
      bcf1
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

    private def configure_sample_selection!(source_header : Bcf::Header, samples : Array(String)) : Nil
      sample_list = samples.join(',')
      encoded_samples = samples.empty? ? Pointer(LibC::Char).null : sample_list.to_unsafe
      rc = LibHTS.bcf_hdr_set_samples(source_header, encoded_samples, 0)
      return if rc == 0

      raise SubsetError.new("Failed to configure sample selection #{samples.inspect} for #{@file_name}")
    end

    private def sample_reorder_imap(source_samples : Array(String), requested_samples : Array(String)) : Slice(Int32)?
      requested = requested_samples.to_set
      read_order = source_samples.select { |sample| requested.includes?(sample) }
      imap = Slice(Int32).new(requested_samples.size) do |index|
        read_order.index!(requested_samples[index]).to_i32
      end
      imap.each_with_index.all? { |source_index, output_index| source_index == output_index } ? nil : imap
    end

    private def apply_read_subset_order!(record : Bcf::Record) : Nil
      return unless imap = @read_subset_imap

      source_header = @read_header || header
      rc = LibHTS.bcf_subset(source_header, record, imap.size, imap.to_unsafe)
      return if rc >= 0

      raise SubsetError.new("Failed to reorder selected samples while reading #{@file_name}")
    end

    private def apply_iterator_subset!(record : Bcf::Record) : Nil
      output_header = @header
      return unless output_header
      return unless output_header.subset?

      source_header = @read_header || output_header
      rc = LibHTS.bcf_subset_format(source_header, record)
      unless rc >= 0
        raise SubsetError.new("Failed to subset samples #{output_header.subset_samples.inspect} while querying #{@file_name}")
      end

      apply_read_subset_order!(record)
    end

    private def validate_reader_options!(subset : Enumerable(String)?, unpack : Symbol) : Nil
      return unless @mode[0] == 'w'

      if subset
        raise SubsetError.new("Sample subsetting is only available when reading BCF/VCF files")
      end
      if unpack != :all
        raise ArgumentError.new("Selective unpacking is only available when reading BCF/VCF files")
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
