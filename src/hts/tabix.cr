require "./libhts"
require "./version"

require "./bgzf"

module HTS
  class Tabix < Bgzf
    class QueryError < Exception; end

    class MissingIndexError < QueryError; end

    @idx : LibHTS::TbxT*
    @@tbx_name2id = ->(tbx : Void*, ss : LibC::Char*) : LibC::Int {
      LibHTS.tbx_name2id(tbx.as(LibHTS::TbxT*), ss)
    }

    getter :file_name
    getter :mode

    def self.open(file_name : Path | String, mode = "r", index = "", threads = 0, build_index = false)
      new(file_name, mode, index, threads, build_index)
    end

    def self.open(file_name : Path | String, mode = "r", index = "", threads = 0, build_index = false, &)
      file = new(file_name, mode, index, threads, build_index)
      begin
        yield file
      ensure
        file.close
      end
      file
    end

    def initialize(file_name : Path | String, @mode = "r", index = "", threads = 0, build_index = false)
      @file_name = file_name.to_s
      @idx = Pointer(LibHTS::TbxT).null

      # NOTE: Do not check for the existence of local files, since file_names may be remote URIs.

      @hts_file = LibHTS.hts_open(@file_name.to_s.to_unsafe, @mode.to_unsafe)
      raise "Failed to open file #{@file_name}" if @hts_file.null?

      set_threads(threads) if threads > 0

      build_index(index) if build_index
      @idx = load_index(index)
      @start_position = tell
    end

    # Build a tabix index for *file_name* on disk. Uses the VCF preset by default.
    def self.build_index(file_name : Path | String, index_name = "", min_shift = 0, threads = 0, verbose = true)
      fn = file_name.to_s
      if verbose
        if index_name == ""
          STDERR.puts "Create index for #{fn}"
        else
          STDERR.puts "Create index for #{fn} to #{index_name}"
        end
      end

      conf = LibHTS.tbx_conf_vcf
      rc =
        if threads > 0
          LibHTS.tbx_index_build3(fn, index_name == "" ? Pointer(LibC::Char).null : index_name.to_unsafe, min_shift, threads, pointerof(conf))
        elsif index_name != ""
          LibHTS.tbx_index_build2(fn, index_name, min_shift, pointerof(conf))
        else
          LibHTS.tbx_index_build(fn, min_shift, pointerof(conf))
        end

      case rc
      when 0 # success
      when -1 then raise "general failure indexing #{fn}"
      when -2 then raise "compression not BGZF: #{fn}"
      else         raise "unknown error indexing #{fn} (rc=#{rc})"
      end
    end

    # Build a tabix index for this file. Delegates to the class method.
    def build_index(index_name = "", min_shift = 0, verbose = true)
      self.class.build_index(@file_name.to_s, index_name, min_shift, (@nthreads || 0), verbose)
      self
    end

    def load_index(index_name = "")
      check_closed
      if index_name != ""
        LibHTS.tbx_index_load2(@file_name.to_s, index_name)
      else
        LibHTS.tbx_index_load3(@file_name.to_s, Pointer(LibC::Char).null, 2)
      end
    end

    def index_loaded?
      check_closed
      !@idx.null?
    end

    # Return the sequence (chromosome) ID for *name*, or -1 if not found.
    def name2id(name : String) : Int32
      check_closed
      raise ArgumentError.new("name must not be empty") if name.empty?
      ensure_index!("name2id")
      LibHTS.tbx_name2id(@idx, name)
    end

    # Return the list of sequence names stored in the index.
    def seqnames : Array(String)
      check_closed
      ensure_index!("seqnames")
      n = 0
      names = LibHTS.tbx_seqnames(@idx, pointerof(n))
      begin
        Array(String).new(n) { |i| String.new(names[i]) }
      ensure
        LibC.free(names.as(Void*)) unless names.null?
      end
    end

    # Query by region string using htslib's native parser.
    # Yields each matching record as an Array(String) of tab-split fields.
    def query(region : String, &)
      check_closed
      raise ArgumentError.new("region must not be empty") if region.empty?
      ensure_index!("query")
      readrec = ->LibHTS.tbx_readrec(LibHTS::Bgzf*, Void*, Void*, LibC::Int*, LibHTS::HtsPosT*, LibHTS::HtsPosT*)
      itr_query = ->LibHTS.hts_itr_query(LibHTS::HtsIdxT, LibC::Int, LibHTS::HtsPosT, LibHTS::HtsPosT, (LibHTS::Bgzf*, Void*, Void*, LibC::Int*, LibHTS::HtsPosT*, LibHTS::HtsPosT* -> LibC::Int))
      qiter = LibHTS.hts_itr_querys(@idx.value.idx, region, @@tbx_name2id, @idx.as(Void*), itr_query, readrec)
      raise_region_query_error(region) if qiter.null?
      begin
        query_yield(qiter) { |fields| yield fields }
      ensure
        LibHTS.hts_itr_destroy(qiter)
      end
      self
    end

    # Query by chromosome name and 0-based half-open coordinates [start, end_).
    # Yields each matching record as an Array(String) of tab-split fields.
    def query(chrom : String, start : Int, end_ : Int, &)
      check_closed
      raise ArgumentError.new("chrom must not be empty") if chrom.empty?
      ensure_index!("query")
      tid = name2id(chrom)
      raise ArgumentError.new("Unknown reference name #{chrom.inspect} in #{@file_name}") if tid < 0
      raise ArgumentError.new("start (#{start}) must be >= 0 for 0-based half-open coordinates") if start < 0
      raise ArgumentError.new("start (#{start}) must be <= end_ (#{end_})") if start > end_
      query_by_coord(tid, start.to_i64, end_.to_i64) { |fields| yield fields }
      self
    end

    def close
      unless @idx.null?
        LibHTS.tbx_destroy(@idx)
        @idx = Pointer(LibHTS::TbxT).null
      end
      super
    end

    def finalize
      close unless closed?
    end

    private def query_by_coord(tid : Int32, beg : Int64, end_pos : Int64, &)
      readrec = ->LibHTS.tbx_readrec(LibHTS::Bgzf*, Void*, Void*, LibC::Int*, LibHTS::HtsPosT*, LibHTS::HtsPosT*)
      qiter = LibHTS.hts_itr_query(@idx.value.idx, tid, beg, end_pos, readrec)
      raise_coordinate_query_error(tid, beg, end_pos) if qiter.null?
      begin
        query_yield(qiter) { |fields| yield fields }
      ensure
        LibHTS.hts_itr_destroy(qiter)
      end
    end

    private def ensure_index!(operation : String) : Nil
      return if index_loaded?

      raise MissingIndexError.new("#{operation} requires an index for #{@file_name}. Open the file with a matching .tbi/.csi index or build one first.")
    end

    private def raise_region_query_error(region : String) : NoReturn
      raise QueryError.new("Failed to create an iterator for region #{region.inspect} in #{@file_name}. Check the region syntax, that the reference exists in the index, and that the index matches the file.")
    end

    private def raise_coordinate_query_error(tid : Int32, beg : Int64, end_pos : Int64) : NoReturn
      ref_name = seqnames[tid]? || tid.to_s
      raise QueryError.new("Failed to create an iterator for #{ref_name}:#{beg}-#{end_pos} (tid=#{tid}, 0-based half-open) in #{@file_name}. The index may be stale or incompatible with the file.")
    end

    private def query_yield(qiter, &)
      r = LibHTS::KstringT.new
      r.l = 0
      r.m = 0
      r.s = Pointer(LibC::Char).null
      bgzf_fp = LibHTS.hts_get_bgzfp(@hts_file)
      begin
        while LibHTS.hts_itr_next(bgzf_fp, qiter, pointerof(r).as(Void*), @idx.as(Void*)) > 0
          yield String.new(r.s, r.l).split('\t')
        end
      ensure
        LibC.free(r.s) unless r.s.null?
      end
    end
  end
end
