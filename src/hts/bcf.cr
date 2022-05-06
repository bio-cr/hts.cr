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

    def self.open(file_name : Path | String, mode = "r", index = "",
                  threads = 0, create_index = false)
      new(file_name, mode, index, threads, create_index)
    end

    def self.open(file_name : Path | String, mode = "r", index = "",
                  threads = 0, create_index = false)
      file = new(file_name, mode, index, threads, create_index)
      begin
        yield file
      ensure
        file.close
      end
      file
    end

    def initialize(file_name : Path | String, @mode = "r", index = "",
                   threads = 0, create_index = false)
      @file_name = file_name.to_s || ""

      # NOTE: Do not check for the existence of local files, since file_names may be remote URIs.

      @hts_file = LibHTS.hts_open(@file_name, @mode)

      raise "Failed to open file #{@file_name}" if @hts_file.null?

      if threads > 0
        r = LibHTS.hts_set_threads(@hts_file, threads)
        r < 0 && raise "Failed to set number threads: #{r}"
      end

      return if mode[0] == "w"

      @header = Bcf::Header.new(@hts_file)

      create_index(index) if create_index

      @idx = load_index(index)

      @start_position = tell
    end

    def create_index(index_name = "")
      STDERR.puts "Creating index for #{@file_name} to #{index_name}"
      if index_name != ""
        LibHTS.bcf_index_build2(@file_name, index_name, -1)
      else
        LibHTS.bcf_index_build(@file_name, -1)
      end
    end

    def load_index(index_name = "")
      if index_name != ""
        LibHTS.bcf_index_load2(@file_name, index_name)
      else
        LibHTS.bcf_index_load3(@file_name, nil, 2)
      end
    end

    def index_loaded?
      !@idx.null?
    end

    def write_header
      raise IO::Error.new("Closed stream") if closed?

      @header = header.clone
      LibHTS.hts_set_fai_filename(header.struct, @file_name)
      LibHTS.bcf_hdr_write(@hts_file, header.struct)
    end

    def write(var)
      raise IO::Error.new("Closed stream") if closed?

      var_dup = var.clone
      LibHTS.bcf_write(@hts_file, header.struct, var_dup.struct)
    end

    def nsamples
      raise IO::Error.new("Closed stream") if closed?

      header.nsamples
    end

    def samples
      raise IO::Error.new("Closed stream") if closed?

      header.samples
    end

    # Iterate over each record.
    # Generate a new Record object each time.
    # Slower than each.
    def each_copy
      raise IO::Error.new("Closed stream") if closed?

      while LibHTS.bcf_read(@hts_file, header.struct, bcf1 = LibHTS.bcf_init) != -1
        yield Bcf::Record.new(bcf1, header)
      end
    end

    # Iterate over each record.
    # Record object is reused.
    # Faster than each_copy.
    def each
      raise IO::Error.new("Closed stream") if closed?

      bcf1 = LibHTS.bcf_init
      record = Bcf::Record.new(bcf1, header)
      while LibHTS.bcf_read(@hts_file, header.struct, bcf1) != -1
        yield record
      end
    end
  end
end
