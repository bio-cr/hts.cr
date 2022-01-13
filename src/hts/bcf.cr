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
    getter :header

    def self.open(filename : Path | String)
      new(filename)
    end

    def self.open(filename : Path | String)
      file = new(filename)
      begin
        yield file
      ensure
        file.close
      end
    end

    def initialize(filename : Path | String)
      @file_path = File.expand_path(filename)

      unless File.exists?(file_path)
        raise "File not found: #{file_path}"
      end

      @hts_file = LibHTS.hts_open(file_path, "r")
      @header = Bcf::Header.new(LibHTS.bcf_hdr_read(@hts_file))
    end

    # Close the current file.
    def close
      LibHTS.hts_close(@hts_file)
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
