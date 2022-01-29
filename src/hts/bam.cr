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
      file
    end

     @idx : Nil | Pointer(Void)

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
      idx = LibHTS.sam_index_load(@hts_file, file_path)

      # create index
      if index || idx.null?
        create_index
      else
        @idx = idx
      end
    end

    def create_index
      STDERR.puts "Create index for #{file_path}"
      LibHTS.sam_index_build(file_path, -1)
      idx = LibHTS.sam_index_load(@hts_file, file_path)
      raise "Failed to create index" if idx.null?
      @idx = idx
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
      while LibHTS.sam_read1(@hts_file, header.struct, bam1 = LibHTS.bam_init1) > 0
        yield Record.new(bam1, header)
      end
    end
  end
end
