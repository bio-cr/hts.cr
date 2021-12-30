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
    getter :htf_file

    def initialize(filename : Path | String)
      @file_path = File.expand_path(filename)

      unless File.exists?(file_path)
        raise "File not found: #{file_path}"
      end

      @htf_file = LibHTS.hts_open(file_path, "r")
      @header = Bcf::Header.new(LibHTS.bcf_hdr_read(htf_file))
    end

    # Close the current file.
    def close
      LibHTS.hts_close(htf_file)
    end

    def each
      while LibHTS.bcf_read(htf_file, header.struct, bcf1 = LibHTS.bcf_init) > 0
        yield Bcf::Record.new(bcf1, header)
      end
    end
  end
end
