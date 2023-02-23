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

    @idx : LibHTS::HtsIdxT

    getter :file_name
    getter :mode
    getter :header
    getter :nthreads

    def self.open(file_name : Path | String, mode = "r", index = "", fai = "",
                  threads = 0, build_index = false)
      new(file_name, mode, index, fai, threads, build_index)
    end

    def self.open(file_name : Path | String, mode = "r", index = "", fai = "",
                  threads = 0, build_index = false)
      file = new(file_name, mode, index, fai, threads, build_index)
      begin
        yield file
      ensure
        file.close
      end
      file
    end

    def initialize(file_name : Path | String, @mode = "r", index = "", fai = "",
                   threads = 0, build_index = false)
      @file_name = file_name.to_s || ""
      @nthreads = threads

      # NOTE: Do not check for the existence of local files, since file_names may be remote URIs.

      @hts_file = LibHTS.hts_open(@file_name, @mode)

      raise "Failed to open file #{@file_name}" if @hts_file.null?

      if fai != ""
        r = LibHTS.hts_set_fai_filename(@hts_file, fai)
        r < 0 && raise "Failed to load fasta index: #{fai}"
      end

      set_threads(threads) if threads > 0

      return if mode[0] == 'w'

      @header = Bam::Header.new(@hts_file)

      build_index(index) if build_index

      @idx = load_index(index)

      @start_position = tell
    end

    def build_index(index_name, min_shift = 0)
      check_closed

      if index_name == ""
        STDERR.puts "Create index for #{@file_name}"
      else
        STDERR.puts "Create index for #{@file_name} to #{index_name}"
      end
      LibHTS.sam_index_build3(@file_name, index_name, min_shift, @nthreads)
    end

    def load_index(index_name = "")
      check_closed

      if index_name == ""
        LibHTS.sam_index_load3(@hts_file, @file_name, nil, 2) # should be 3 ? (copy remote file to local?)
      else
        LibHTS.sam_index_load2(@hts_file, @file_name, index_name)
      end
    end

    def index_loaded?
      check_closed

      !@idx.null?
    end

    def close
      LibHTS.hts_idx_destroy(@idx) unless @idx.null?
      @idx = @idx.class.null
      super
    end

    def finalize
      close
    end

    def fai=(fai)
      check_closed
      r = LibHTS.hts_set_fai_filename(@hts_file, fai)
      r < 0 && raise "Failed to load fasta: #{fai}"
    end

    def write_header(header)
      check_closed

      @header = header.clone
      LibHTS.sam_hdr_write(@hts_file, header.struct)
    end

    def header=(header)
      write_header(header)
    end

    def write(record)
      check_closed

      r = LibHTS.sam_write1(@hts_file, header.struct, new_record.struct)
      raise "Failed to write record: #{record}" if r < 0
    end

    def <<(record)
      write(record)
    end

    define_getter :qname
    define_getter :flag
    define_getter :chrom
    define_getter :pos
    define_getter :mapq
    define_getter :cigar
    define_getter :mate_chrom
    define_getter :mate_pos
    define_getter :insert_size
    define_getter :seq
    define_getter :qual

    def isize
      insert_size
    end

    def mpos
      mate_pos
    end

    # def aux(tag)

    define_iterator :qname
    define_iterator :flag
    define_iterator :chrom
    define_iterator :pos
    define_iterator :mapq
    define_iterator :cigar
    define_iterator :mate_chrom
    define_iterator :mate_pos
    define_iterator :insert_size
    define_iterator :seq
    define_iterator :qual

    # each_isize
    # each_mpos

    # each_aux(tag)

    def each(copy = false)
      if copy
        each_record_copy do |record|
          yield record
        end
      else
        each_record_reuse do |record|
          yield record
        end
      end
    end

    private def each_record_copy
      check_closed

      while LibHTS.sam_read1(@hts_file, header.struct, bam1 = LibHTS.bam_init1) != -1
        yield Record.new(bam1, header)
      end
    end

    private def each_record_reuse
      check_closed
      
      bam1 = LibHTS.bam_init1
      record = Record.new(bam1, header)
      while LibHTS.sam_read1(@hts_file, header.struct, bam1) != -1
        yield record
      end
    end

    def query(region)
      check_closed
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
