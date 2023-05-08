require "./libhts"
require "./version"

require "./hts"
require "./bcf/header"
require "./bcf/info"
require "./bcf/format"
require "./bcf/record"

module HTS
  class Bcf < Hts
    include Enumerable(Bcf::Record)

    @idx : LibHTS::HtsIdxT

    getter :file_name
    getter :mode
    getter :header
    getter :nthreads

    def self.open(file_name : Path | String, mode = "r", index = "",
                  threads = 0, build_index = false)
      new(file_name, mode, index, threads, build_index)
    end

    def self.open(file_name : Path | String, mode = "r", index = "",
                  threads = 0, build_index = false)
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
      @file_name = file_name.to_s || ""
      @nthreads = threads

      # NOTE: Do not check for the existence of local files, since file_names may be remote URIs.

      @hts_file = LibHTS.hts_open(@file_name, @mode)

      raise "Failed to open file #{@file_name}" if @hts_file.null?

      set_threads(threads) if threads > 0

      return if mode[0] == "w"

      @header = Bcf::Header.new(@hts_file)

      build_index(index) if build_index

      @idx = load_index(index)

      @start_position = tell
    end

    def build_index(index_name = "", min_shift = 14)
      check_closed

      if index_name == ""
        STDERR.puts "Create index for #{@file_name}"
      else
        STDERR.puts "Create index for #{@file_name} to #{index_name}"
      end
      LibHTS.bcf_index_build3(@file_name, index_name, min_shift, @nthreads)
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
    end

    def finalize
      close
    end

    def write_header(header)
      check_closed

      @header = header.clone # Necessary. If not, it will cause segfault.
      LibHTS.bcf_hdr_write(@hts_file, header)
    end

    def header=(header)
      write_header(header)
    end

    def write(var)
      check_closed

      # var_dup = var.clone
      r = LibHTS.bcf_write(@hts_file, header, var_dup)
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

    def each(copy = false)
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

    private def each_record_copy
      check_closed
      while LibHTS.bcf_read(@hts_file, header, bcf1 = LibHTS.bcf_init) != -1
        yield Bcf::Record.new(header, bcf1)
      end
    end

    private def each_record_reuse
      check_closed
      bcf1 = LibHTS.bcf_init
      record = Bcf::Record.new(header, bcf1)
      while LibHTS.bcf_read(@hts_file, header, bcf1) != -1
        yield record
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
