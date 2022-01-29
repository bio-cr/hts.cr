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

    def self.open(*args)
      new(*args)
    end

    def self.open(*args)
      file = new(*args)
      begin
        yield file
      ensure
        file.close
      end
      file
    end

    def initialize(filename : Path | String, mode = "r", threads = 0)
      @file_path = File.expand_path(filename)

      unless File.exists?(file_path)
        raise "File not found: #{file_path}"
      end

      @mode = mode
      @hts_file = LibHTS.hts_open(file_path, "r")

      if threads > 0
        r = LibHTS.hts_set_threads(@hts_file, threads)
        raise "Failed to set number threads: #{r}" if r < 0
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

    def each
      while LibHTS.bcf_read(@hts_file, header.struct, bcf1 = LibHTS.bcf_init) != -1
        yield Bcf::Record.new(bcf1, header)
      end
    end

    def sample_count
      LibHTS2.bcf_hdr_nsamples(header.struct)
    end
  end
end
