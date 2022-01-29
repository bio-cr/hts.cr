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
    getter :mode
    getter :header

    def self.open(filename : Path | String, mode = "r", fai = "", threads = 0, index = false)
      new(filename, mode, fai, threads, index)
    end

    def self.open(filename : Path | String, mode = "r", fai = "", threads = 0, index = false)
      file = new(filename, mode, fai, threads, index)
      begin
        yield file
      ensure
        file.close
      end
      file
    end

    def initialize(filename : Path | String, mode = "r", fai = "", threads = 0, index = false)
      @file_path = File.expand_path(filename)

      unless File.exists?(file_path)
        raise "File not found: #{file_path}"
      end

      @mode = mode
      @hts_file = LibHTS.hts_open(file_path, "r")

      if fai != ""
        fai_path = File.expand_path(fai)
        r = LibHTS.hts_set_fai_filename(@hts_file, fai_path)
        raise "Failed to load fasta index: #{fai_path}" if r < 0
      end

      if threads > 0
        r = LibHTS.hts_set_threads(@hts_file, threads)
        raise "Failed to set number of threads: #{threads}" if r < 0
      end

      return if mode[0] == "w"

      @header = Bam::Header.new(@hts_file)

      # load index
      @idx = LibHTS.sam_index_load(@hts_file, file_path)

      # create index
      if index || @idx.null?
        create_index
        @idx = LibHTS.sam_index_load(@hts_file, file_path)
      end
    end

    def create_index
      STDERR.puts "Create index for #{file_path}"
      LibHTS.sam_index_build(file_path, -1)
    end

    def struct
      @hts_file
    end

    # Close the current file.
    def close
      LibHTS.hts_close(@hts_file)
      @hts_file = @hts_file.class.null
    end

    def closed?
      @hts_file.null?
    end

    def write_header(header)
      @header = header.clone
      LibHTS.hts_set_fai_filename(@hts_file, @file_path)
      LibHTS.sam_hdr_write(@hts_file, header.struct)
    end

    def write(record)
      new_record = record.clone
      LibHTS.sam_write1(@hts_file, header.struct, new_record.struct) > 0 || raise
    end

    def each
      while LibHTS.sam_read1(@hts_file, header.struct, bam1 = LibHTS.bam_init1) > 0
        yield Record.new(bam1, header)
      end
    end

    def query(region)
      qiter = LibHTS.sam_itr_querys(@idx, header.struct, region)
      begin
        bam1 = LibHTS.bam_init1
        slen = LibHTS2.sam_itr_next(@hts_file, qiter, bam1)
        while slen > 0
          yield Record.new(bam1, header)
          bam1 = LibHTS.bam_init1
          slen = LibHTS2.sam_itr_next(@hts_file, qiter, bam1)
        end
      ensure
        LibHTS.hts_itr_destroy(qiter)
      end
    end
  end
end
