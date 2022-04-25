require "./libhts"
require "./version"

require "./hts"
require "./bam/header"
require "./bam/cigar"
require "./bam/flag"
require "./bam/record"

module HTS
  class Bam < Hts
    include Enumerable(Record)

    getter :file_name
    getter :mode
    getter :header

    def self.open(file_name : Path | String, mode = "r", index = "", fai = "",
                  threads = 0, create_index = false)
      new(file_name, mode, index, fai, threads, create_index)
    end

    def self.open(file_name : Path | String, mode = "r", index = "", fai = "",
                  threads = 0, create_index = false)
      file = new(file_name, mode, index, fai, threads, create_index)
      begin
        yield file
      ensure
        file.close
      end
      file
    end

    def initialize(file_name : Path | String, @mode = "r", index = "", fai = "",
                   threads = 0, create_index = false)
      @file_name = file_name.to_s || ""

      # NOTE: Do not check for the existence of local files, since file_names may be remote URIs.

      @hts_file = LibHTS.hts_open(@file_name, @mode)

      raise "Failed to open file #{@file_name}" if @hts_file.null?

      if fai != ""
        r = LibHTS.hts_set_fai_filename(@hts_file, fai)
        r < 0 && raise "Failed to load fasta index: #{fai}"
      end

      if threads > 0
        r = LibHTS.hts_set_threads(@hts_file, threads)
        r < 0 && raise "Failed to set number of threads: #{r}"
      end

      return if mode[0] == 'w'

      @header = Bam::Header.new(@hts_file)

      create_index(index) if create_index

      @idx = load_index(index)
    
      @start_position = tell
    end

    def create_index(index_name)
      if index_name == ""
        STDERR.puts "Create index for #{@file_name}"
        LibHTS.sam_index_build(@file_name, -1)
      else
        STDERR.puts "Create index for #{@file_name} to #{index_name}"
        LibHTS.sam_index_build2(@file_name, index_name, -1)
      end
    end

    def load_index(index_name)
      if index_name == ""
        @idx = LibHTS.sam_index_load3(@hts_file, @file_name, nil, 2) # should be 3 ? (copy remote file to local?)
      else
        @idx = LibHTS.sam_index_load2(@hts_file, @file_name, index_name)
      end
    end

    def index_loaded?
      !@idx.null?
    end

    # Close the current file.
    def close
      LibHTS.hts_idx_destroy(@idx) unless @idx.null?
      @idx = @idx.class.null
      super
    end

    def write_header(header)
      @header = header.clone
      LibHTS.hts_set_fai_filename(@hts_file, @file_name)
      LibHTS.sam_hdr_write(@hts_file, header.struct)
    end

    def write(record)
      new_record = record.clone
      r = LibHTS.sam_write1(@hts_file, header.struct, new_record.struct)
      r < 0 && raise "Failed to write record: #{record}"
    end

    # Iterate over each record.
    # Generate a new Record object each time.
    # Slower than each.
    def each_copy
      while LibHTS.sam_read1(@hts_file, header.struct, bam1 = LibHTS.bam_init1) != -1
        yield Record.new(bam1, header)
      end
    end

    # Iterate over each record.
    # Record object is reused.
    # Faster than each_copy.
    def each
      bam1 = LibHTS.bam_init1
      record = Record.new(bam1, header)
      while LibHTS.sam_read1(@hts_file, header.struct, bam1) != -1
        yield record
      end
    end

    def query(region)
      raise "Index file is required to call the query method." unless index_loaded?

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
