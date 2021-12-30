require "./libhts"
require "./version"

require "./bam/header"
require "./bam/cigar"
require "./bam/flag"
require "./bam/record"

module HTS
  class Bam
    include Enumerable(Record)

    getter :file_path
    getter :header
    getter :htf_file

    def initialize(filename : Path | String)
      @file_path = File.expand_path(filename)

      unless File.exists?(file_path)
        raise "File not found: #{file_path}"
      end

      @htf_file = LibHTS.hts_open(file_path, "r")
      @header = Bam::Header.new(LibHTS.sam_hdr_read(htf_file))
    end

    # Close the current file.
    def close
      LibHTS.hts_close(htf_file)
    end

    def each
      while LibHTS.sam_read1(htf_file, header.struct, bam1 = LibHTS.bam_init1) > 0
        yield Record.new(bam1, header)
      end
    end
  end
end
