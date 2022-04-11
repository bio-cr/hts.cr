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

    getter :file_name
    getter :mode
    getter :header

    def self.open(file_name : Path | String, mode = "r", threads = 0)
      new(file_name, mode, threads)
    end

    def self.open(file_name : Path | String, mode = "r", threads = 0)
      file = new(file_name, mode, threads)
      begin
        yield file
      ensure
        file.close
      end
      file
    end

    def initialize(file_name : Path | String, mode = "r", threads = 0)
      @file_name = file_name.to_s || ""

      # NOTE: Do not check for the existence of local files, since file_names may be remote URIs.

      @mode = mode
      @hts_file = LibHTS.hts_open(file_name, mode)

      raise "Failed to open file #{@file_name}" if @hts_file.null?

      if threads > 0
        r = LibHTS.hts_set_threads(@hts_file, threads)
        r < 0 && raise "Failed to set number threads: #{r}"
      end

      return if mode == "w"

      # FIXME: Loading index needed for query

      @header = Bcf::Header.new(@hts_file)
    end

    # Close the current file.
    def close
      LibHTS.hts_close(@hts_file)
      @hts_file = @hts_file.class.null
    end

    def closed?
      @hts_file.null?
    end

    # Iterate over each record.
    # Generate a new Record object each time.
    # Slower than each.
    def each_copy
      while LibHTS.bcf_read(@hts_file, header.struct, bcf1 = LibHTS.bcf_init) != -1
        yield Bcf::Record.new(bcf1, header)
      end
    end

    # Iterate over each record.
    # Record object is reused.
    # Faster than each_copy.
    def each
      bcf1 = LibHTS.bcf_init
      record = Bcf::Record.new(bcf1, header)
      while LibHTS.bcf_read(@hts_file, header.struct, bcf1) != -1
        yield record
      end
    end

    def nsamples
      header.nsamples
    end

    def samples
      header.samples
    end
  end
end
