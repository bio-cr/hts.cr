require "./libhts"
require "./version"

require "./bcf/header"
require "./bcf/info"
require "./bcf/format"
require "./bcf/record"

module HTS
  class Bcf
    include Enumerable(Bcf::Record)

    getter :file_path
    getter :mode
    getter :header

    def self.open(filename : Path | String, mode = "r", threads = 0)
      new(filename, mode, threads)
    end

    def self.open(filename : Path | String, mode = "r", threads = 0)
      file = new(filename, mode, threads)
      begin
        yield file
      ensure
        file.close
      end
      file
    end

    def initialize(filename : Path | String, mode = "r", threads = 0)
      @file_path = filename == "-" ? "-" : File.expand_path(filename)

      if mode[0] == 'r' && !File.exists?(file_path)
        raise "File not found: #{file_path}"
      end

      @mode = mode
      @hts_file = LibHTS.hts_open(file_path, mode)

      if threads > 0
        r = LibHTS.hts_set_threads(@hts_file, threads)
        r < 0 && raise "Failed to set number threads: #{r}"
      end

      return if mode == "w"

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

    def each_copy
      while LibHTS.bcf_read(@hts_file, header.struct, bcf1 = LibHTS.bcf_init) != -1
        yield Bcf::Record.new(bcf1, header)
      end
    end

    def each
      bcf1 = LibHTS.bcf_init
      record = Bcf::Record.new(bcf1, header)
      while LibHTS.bcf_read(@hts_file, header.struct, bcf1) != -1
        yield record
      end
    end

    def sample_count
      header.sample_count
    end
  end
end
