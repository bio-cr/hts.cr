module HTS
  @[Link("hts", pkg_config: "htslib")]
  lib LibHTS
    BCF_GT_MISSING     = 0
    BCF_STR_VECTOR_END = 0
    BCF_STR_MISSING    = 7
    alias HtsTpool = Void
    alias HFileBackend = Void

    struct HFile
      buffer : LibC::Char*
      _begin : LibC::Char*
      _end : LibC::Char*
      limit : LibC::Char*
      backend : HFileBackend*
      offset : OffT
      at_eof : LibC::UInt
      mobile : LibC::UInt
      readonly : LibC::UInt
      has_errno : LibC::Int
    end

    fun hopen(filename : LibC::Char*, mode : LibC::Char*, ...) : HFile*
    fun hdopen(fd : LibC::Int, mode : LibC::Char*) : HFile*
    fun hisremote(filename : LibC::Char*) : LibC::Int
    fun haddextension(buffer : KstringT*, filename : LibC::Char*, replace : LibC::Int, extension : LibC::Char*) : LibC::Char*
    fun hclose(fp : HFile*) : LibC::Int
    fun hclose_abruptly(fp : HFile*)
    fun herrno(fp : HFile*) : LibC::Int
    fun hclearerr(fp : HFile*)
    fun hseek(fp : HFile*, offset : OffT, whence : LibC::Int) : OffT
    fun htell(fp : HFile*) : OffT
    fun hgetc(fp : HFile*) : LibC::Int
    fun hgetdelim(buffer : LibC::Char*, size : LibC::SizeT, delim : LibC::Int, fp : HFile*) : SsizeT
    fun hgetln(buffer : LibC::Char*, size : LibC::SizeT, fp : HFile*) : SsizeT
    fun hgets(buffer : LibC::Char*, size : LibC::Int, fp : HFile*) : LibC::Char*
    fun hpeek(fp : HFile*, buffer : Void*, nbytes : LibC::SizeT) : SsizeT
    fun hread(fp : HFile*, buffer : Void*, nbytes : LibC::SizeT) : SsizeT
    fun hputc(c : LibC::Int, fp : HFile*) : LibC::Int
    fun hputs(text : LibC::Char*, fp : HFile*) : LibC::Int
    fun hwrite(fp : HFile*, buffer : Void*, nbytes : LibC::SizeT) : SsizeT
    fun hflush(fp : HFile*) : LibC::Int
    fun hfile_mem_get_buffer(file : HFile*, length : LibC::SizeT*) : LibC::Char*
    fun hfile_mem_steal_buffer(file : HFile*, length : LibC::SizeT*) : LibC::Char*
    fun hfile_list_schemes(plugin : LibC::Char*, sc_list : LibC::Char**, nschemes : LibC::Int*) : LibC::Int
    fun hfile_list_plugins(plist : LibC::Char**, nplugins : LibC::Int*) : LibC::Int
    fun hfile_has_plugin(name : LibC::Char*) : LibC::Int

    alias BgzfMtauxT = Void
    alias BgzfCacheT = Void*
    fun bgzf_dopen(fd : LibC::Int, mode : LibC::Char*) : Bgzf*

    struct Bgzf
      bitfields : Uint32T # FIXME
      # errcode : LibC::UInt
      # reserved : LibC::UInt
      # is_write : LibC::UInt
      # no_eof_block : LibC::UInt
      # is_be : LibC::UInt
      # compress_level : LibC::Int
      # last_block_eof : LibC::UInt
      # is_compressed : LibC::UInt
      # is_gzip : LibC::UInt
      cache_size : LibC::Int
      block_length : LibC::Int
      block_clength : LibC::Int
      block_offset : LibC::Int
      block_address : Int64T
      uncompressed_address : Int64T
      uncompressed_block : Void*
      compressed_block : Void*
      cache : BgzfCacheT
      fp : HFile*
      mt : BgzfMtauxT*
      idx : BgzidxT
      idx_build_otf : LibC::Int
      gz_stream : ZStreamS*
      seeked : Int64T
    end

    # htslib uses fixed-width 64-bit ints (int64_t/uint64_t). On Windows,
    # LibC::Long is 32-bit, so map explicitly to LongLong.
    {% if flag?(:win32) %}
      alias Int64T = LibC::LongLong
    {% else %}
      alias Int64T = LibC::Long
    {% end %}
    type BgzidxT = Void*
    alias ZStreamS = Void
    fun bgzf_open(path : LibC::Char*, mode : LibC::Char*) : Bgzf*
    fun bgzf_hopen(fp : HFile*, mode : LibC::Char*) : Bgzf*
    fun bgzf_close(fp : Bgzf*) : LibC::Int
    fun bgzf_read(fp : Bgzf*, data : Void*, length : LibC::SizeT) : SsizeT
    # ssize_t width differs; prefer 64-bit on Windows builds.
    {% if flag?(:win32) %}
      alias SsizeT = LibC::LongLong
    {% else %}
      alias SsizeT = LibC::Long
    {% end %}
    fun bgzf_write(fp : Bgzf*, data : Void*, length : LibC::SizeT) : SsizeT
    fun bgzf_block_write(fp : Bgzf*, data : Void*, length : LibC::SizeT) : SsizeT
    fun bgzf_peek(fp : Bgzf*) : LibC::Int
    fun bgzf_raw_read(fp : Bgzf*, data : Void*, length : LibC::SizeT) : SsizeT
    fun bgzf_raw_write(fp : Bgzf*, data : Void*, length : LibC::SizeT) : SsizeT
    fun bgzf_flush(fp : Bgzf*) : LibC::Int
    fun bgzf_seek(fp : Bgzf*, pos : Int64T, whence : LibC::Int) : Int64T
    fun bgzf_check_eof = bgzf_check_EOF(fp : Bgzf*) : LibC::Int
    fun bgzf_compression(fp : Bgzf*) : LibC::Int
    fun bgzf_is_bgzf(fn : LibC::Char*) : LibC::Int
    fun bgzf_set_cache_size(fp : Bgzf*, size : LibC::Int)
    fun bgzf_flush_try(fp : Bgzf*, size : SsizeT) : LibC::Int
    fun bgzf_getc(fp : Bgzf*) : LibC::Int
    fun bgzf_getline(fp : Bgzf*, delim : LibC::Int, str : KstringT*) : LibC::Int

    struct KstringT
      l : LibC::SizeT
      m : LibC::SizeT
      s : LibC::Char*
    end

    fun bgzf_read_block(fp : Bgzf*) : LibC::Int
    fun bgzf_thread_pool(fp : Bgzf*, pool : HtsTpool*, qsize : LibC::Int) : LibC::Int
    fun bgzf_mt(fp : Bgzf*, n_threads : LibC::Int, n_sub_blks : LibC::Int) : LibC::Int
    fun bgzf_compress(dst : Void*, dlen : LibC::SizeT*, src : Void*, slen : LibC::SizeT, level : LibC::Int) : LibC::Int
    fun bgzf_useek(fp : Bgzf*, uoffset : OffT, where : LibC::Int) : LibC::Int
    {% if flag?(:win32) %}
      alias OffT = LibC::LongLong
    {% else %}
      alias OffT = LibC::Long
    {% end %}
    fun bgzf_utell(fp : Bgzf*) : OffT
    fun bgzf_index_build_init(fp : Bgzf*) : LibC::Int
    fun bgzf_index_load(fp : Bgzf*, bname : LibC::Char*, suffix : LibC::Char*) : LibC::Int
    fun bgzf_index_load_hfile(fp : Bgzf*, idx : HFile*, name : LibC::Char*) : LibC::Int
    fun bgzf_index_dump(fp : Bgzf*, bname : LibC::Char*, suffix : LibC::Char*) : LibC::Int
    fun bgzf_index_dump_hfile(fp : Bgzf*, idx : HFile*, name : LibC::Char*) : LibC::Int
    fun hts_set_log_level(level : HtsLogLevel)
    enum HtsLogLevel
      HtsLogOff     = 0
      HtsLogError   = 1
      HtsLogWarning = 3
      HtsLogInfo    = 4
      HtsLogDebug   = 5
      HtsLogTrace   = 6
    end
    fun hts_get_log_level : HtsLogLevel
    fun hts_log(severity : HtsLogLevel, context : LibC::Char*, format : LibC::Char*, ...)
    type CramFd = Void

    struct SamHdrT
      n_targets : Int32T
      ignore_sam_err : Int32T
      l_text : LibC::SizeT
      target_len : Uint32T*
      cigar_tab : Int8T*
      target_name : LibC::Char**
      text : LibC::Char*
      sdict : Void*
      hrecs : SamHrecsT
      ref_count : Uint32T
    end

    alias Int32T = Int32
    alias Uint32T = UInt32
    alias Int8T = Int8
    fun hts_resize_array_(x0 : LibC::SizeT, x1 : LibC::SizeT, x2 : LibC::SizeT, x3 : Void*, x4 : Void**, x5 : LibC::Int, x6 : LibC::Char*) : LibC::Int
    fun hts_lib_shutdown
    fun hts_free(ptr : Void*)
    alias HtsIdxT = Void*
    alias HtsFilterT = Void*

    struct HtsOpt
      arg : LibC::Char*
      opt : HtsFmtOption
      val : HtsOptVal
      next : HtsOpt*
    end

    enum HtsFmtOption
      CramOptDecodeMd           =    0
      CramOptPrefix             =    1
      CramOptVerbosity          =    2
      CramOptSeqsPerSlice       =    3
      CramOptSlicesPerContainer =    4
      CramOptRange              =    5
      CramOptVersion            =    6
      CramOptEmbedRef           =    7
      CramOptIgnoreMd5          =    8
      CramOptReference          =    9
      CramOptMultiSeqPerSlice   =   10
      CramOptNoRef              =   11
      CramOptUseBzip2           =   12
      CramOptSharedRef          =   13
      CramOptNthreads           =   14
      CramOptThreadPool         =   15
      CramOptUseLzma            =   16
      CramOptUseRans            =   17
      CramOptRequiredFields     =   18
      CramOptLossyNames         =   19
      CramOptBasesPerSlice      =   20
      CramOptStoreMd            =   21
      CramOptStoreNm            =   22
      CramOptRangeNoseek        =   23
      CramOptUseTok             =   24
      CramOptUseFqz             =   25
      CramOptUseArith           =   26
      CramOptPosDelta           =   27
      HtsOptCompressionLevel    =  100
      HtsOptNthreads            =  101
      HtsOptThreadPool          =  102
      HtsOptCacheSize           =  103
      HtsOptBlockSize           =  104
      HtsOptFilter              =  105
      HtsOptProfile             =  106
      FastqOptCasava            = 1000
      FastqOptAux               = 1001
      FastqOptRnum              = 1002
      FastqOptBarcode           = 1003
      FastqOptName2             = 1004
    end

    union HtsOptVal
      i : LibC::Int
      s : LibC::Char*
    end

    fun hts_opt_add(opts : HtsOpt**, c_arg : LibC::Char*) : LibC::Int
    fun hts_opt_apply(fp : HtsFile*, opts : HtsOpt*) : LibC::Int

    struct HtsFile
      flags : Uint32T # FIXME
      # is_bin : Uint32T
      # is_write : Uint32T
      # is_be : Uint32T
      # is_cram : Uint32T
      # is_bgzf : Uint32T
      # dummy : Uint32T
      lineno : Int64T
      line : KstringT
      fn : LibC::Char*
      fn_aux : LibC::Char*
      fp : HtsFileFp
      state : Void*
      format : HtsFormat
      idx : HtsIdxT
      fnidx : LibC::Char*
      bam_header : SamHdrT*
      filter : HtsFilterT*
    end

    union HtsFileFp
      bgzf : Bgzf*
      cram : CramFd*
      hfile : HFile*
    end

    struct HtsFormat
      category : HtsFormatCategory
      format : HtsExactFormat
      version : HtsFormatVersion
      compression : HtsCompression
      compression_level : LibC::Short
      specific : Void*
    end

    enum HtsFormatCategory
      UnknownCategory =      0
      SequenceData    =      1
      VariantData     =      2
      IndexFile       =      3
      RegionList      =      4
      CategoryMaximum = 32_767
    end
    enum HtsExactFormat
      UnknownFormat     =  0
      BinaryFormat      =  1
      TextFormat        =  2
      Sam               =  3
      Bam               =  4
      Bai               =  5
      Cram              =  6
      Crai              =  7
      Vcf               =  8
      Bcf               =  9
      Csi               = 10
      Gzi               = 11
      Tbi               = 12
      Bed               = 13
      Htsget            = 14
      Json              = Htsget # Deprecated alias of Htsget.
      EmptyFormat       =     15
      FastaFormat       =     16
      FastqFormat       =     17
      FaiFormat         =     18
      FqiFormat         =     19
      HtsCrypt4ghFormat =     20
      D4Format          =     21
      FormatMaximum     = 32_767
    end

    struct HtsFormatVersion
      major : LibC::Short
      minor : LibC::Short
    end

    enum HtsCompression
      NoCompression      =      0
      Gzip               =      1
      Bgzf               =      2
      Custom             =      3
      Bzip2Compression   =      4
      RazfCompression    =      5
      XzCompression      =      6
      ZstdCompression    =      7
      CompressionMaximum = 32_767
    end
    fun hts_opt_free(opts : HtsOpt*)
    fun hts_parse_format(opt : HtsFormat*, str : LibC::Char*) : LibC::Int
    fun hts_parse_opt_list(opt : HtsFormat*, str : LibC::Char*) : LibC::Int
    fun hts_version : LibC::Char*
    fun hts_features : LibC::UInt
    fun hts_test_feature(id : LibC::UInt) : LibC::Char*
    fun hts_feature_string : LibC::Char*
    fun hts_detect_format(fp : HFile*, fmt : HtsFormat*) : LibC::Int
    fun hts_detect_format2(fp : HFile*, fname : LibC::Char*, fmt : HtsFormat*) : LibC::Int
    fun hts_format_description(format : HtsFormat*) : LibC::Char*
    fun hts_open(fn : LibC::Char*, mode : LibC::Char*) : HtsFile*
    fun hts_open_format(fn : LibC::Char*, mode : LibC::Char*, fmt : HtsFormat*) : HtsFile*
    fun hts_hopen(fp : HFile*, fn : LibC::Char*, mode : LibC::Char*) : HtsFile*
    fun hts_flush(fp : HtsFile*) : LibC::Int
    fun hts_close(fp : HtsFile*) : LibC::Int
    fun hts_get_format(fp : HtsFile*) : HtsFormat*
    fun hts_format_file_extension(format : HtsFormat*) : LibC::Char*
    fun hts_set_opt(fp : HtsFile*, opt : HtsFmtOption, ...) : LibC::Int
    fun hts_getline(fp : HtsFile*, delimiter : LibC::Int, str : KstringT*) : LibC::Int
    fun hts_readlines(fn : LibC::Char*, _n : LibC::Int*) : LibC::Char**
    fun hts_readlist(fn : LibC::Char*, is_file : LibC::Int, _n : LibC::Int*) : LibC::Char**
    fun hts_set_threads(fp : HtsFile*, n : LibC::Int) : LibC::Int
    fun hts_set_thread_pool(fp : HtsFile*, p : HtsThreadPool*) : LibC::Int

    struct HtsThreadPool
      pool : HtsTpool*
      qsize : LibC::Int
    end

    fun hts_set_cache_size(fp : HtsFile*, n : LibC::Int)
    fun hts_set_fai_filename(fp : HtsFile*, fn_aux : LibC::Char*) : LibC::Int
    fun hts_set_filter_expression(fp : HtsFile*, expr : LibC::Char*) : LibC::Int
    fun hts_check_eof = hts_check_EOF(fp : HtsFile*) : LibC::Int

    struct HtsPairPosT
      beg : HtsPosT
      _end : HtsPosT
    end

    alias HtsPosT = Int64T

    struct HtsPair64T
      u : Uint64T
      v : Uint64T
    end

    {% if flag?(:win32) %}
      alias Uint64T = LibC::ULongLong
    {% else %}
      alias Uint64T = LibC::ULong
    {% end %}

    struct HtsPair64MaxT
      u : Uint64T
      v : Uint64T
      max : Uint64T
    end

    struct HtsReglistT
      reg : LibC::Char*
      intervals : HtsPairPosT*
      tid : LibC::Int
      count : Uint32T
      min_beg : HtsPosT
      max_end : HtsPosT
    end

    struct HtsItrT
      bitfields : Uint32T # FIXME
      # read_rest : Uint32T
      # finished : Uint32T
      # is_cram : Uint32T
      # nocoor : Uint32T
      # multi : Uint32T
      # dummy : Uint32T
      tid : LibC::Int
      n_off : LibC::Int
      i : LibC::Int
      n_reg : LibC::Int
      beg : HtsPosT
      _end : HtsPosT
      reg_list : HtsReglistT*
      curr_tid : LibC::Int
      curr_reg : LibC::Int
      curr_intv : LibC::Int
      curr_beg : HtsPosT
      curr_end : HtsPosT
      curr_off : Uint64T
      nocoor_off : Uint64T
      off : HtsPair64MaxT*
      readrec : (Bgzf*, Void*, Void*, LibC::Int*, HtsPosT*, HtsPosT* -> LibC::Int)
      seek : (Void*, Int64T, LibC::Int -> LibC::Int)
      tell : (Void* -> Int64T)
      bins : HtsItrTBins
    end

    struct HtsItrTBins
      n : LibC::Int
      m : LibC::Int
      a : LibC::Int*
    end

    fun hts_idx_init(n : LibC::Int, fmt : LibC::Int, offset0 : Uint64T, min_shift : LibC::Int, n_lvls : LibC::Int) : HtsIdxT
    fun hts_idx_destroy(idx : HtsIdxT)
    fun hts_idx_push(idx : HtsIdxT, tid : LibC::Int, beg : HtsPosT, _end : HtsPosT, offset : Uint64T, is_mapped : LibC::Int) : LibC::Int
    fun hts_idx_finish(idx : HtsIdxT, final_offset : Uint64T) : LibC::Int
    fun hts_idx_fmt(idx : HtsIdxT) : LibC::Int
    fun hts_idx_tbi_name(idx : HtsIdxT, tid : LibC::Int, name : LibC::Char*) : LibC::Int
    fun hts_idx_save(idx : HtsIdxT, fn : LibC::Char*, fmt : LibC::Int) : LibC::Int
    fun hts_idx_save_as(idx : HtsIdxT, fn : LibC::Char*, fnidx : LibC::Char*, fmt : LibC::Int) : LibC::Int
    fun hts_idx_load(fn : LibC::Char*, fmt : LibC::Int) : HtsIdxT
    fun hts_idx_load2(fn : LibC::Char*, fnidx : LibC::Char*) : HtsIdxT
    fun hts_idx_load3(fn : LibC::Char*, fnidx : LibC::Char*, fmt : LibC::Int, flags : LibC::Int) : HtsIdxT
    fun hts_idx_get_meta(idx : HtsIdxT, l_meta : Uint32T*) : Uint8T*
    alias Uint8T = UInt8
    fun hts_idx_set_meta(idx : HtsIdxT, l_meta : Uint32T, meta : Uint8T*, is_copy : LibC::Int) : LibC::Int
    fun hts_idx_get_stat(idx : HtsIdxT, tid : LibC::Int, mapped : Uint64T*, unmapped : Uint64T*) : LibC::Int
    fun hts_idx_get_n_no_coor(idx : HtsIdxT) : Uint64T
    fun hts_idx_seqnames(idx : HtsIdxT, n : LibC::Int*, getid : HtsId2nameF, hdr : Void*) : LibC::Char**
    alias HtsId2nameF = (Void*, LibC::Int -> LibC::Char*)
    fun hts_idx_nseq(idx : HtsIdxT) : LibC::Int
    fun hts_parse_decimal(str : LibC::Char*, strend : LibC::Char**, flags : LibC::Int) : LibC::LongLong
    fun hts_parse_reg64(str : LibC::Char*, beg : HtsPosT*, _end : HtsPosT*) : LibC::Char*
    fun hts_parse_reg(str : LibC::Char*, beg : LibC::Int*, _end : LibC::Int*) : LibC::Char*
    fun hts_parse_region(s : LibC::Char*, tid : LibC::Int*, beg : HtsPosT*, _end : HtsPosT*, getid : HtsName2idF, hdr : Void*, flags : LibC::Int) : LibC::Char*
    alias HtsName2idF = (Void*, LibC::Char* -> LibC::Int)
    fun hts_itr_query(idx : HtsIdxT, tid : LibC::Int, beg : HtsPosT, _end : HtsPosT, readrec : (Bgzf*, Void*, Void*, LibC::Int*, HtsPosT*, HtsPosT* -> LibC::Int)) : HtsItrT*
    fun hts_itr_destroy(iter : HtsItrT*)
    fun hts_itr_querys(idx : HtsIdxT, reg : LibC::Char*, getid : HtsName2idF, hdr : Void*, itr_query : (HtsIdxT, LibC::Int, HtsPosT, HtsPosT, (Bgzf*, Void*, Void*, LibC::Int*, HtsPosT*, HtsPosT* -> LibC::Int) -> HtsItrT*), readrec : (Bgzf*, Void*, Void*, LibC::Int*, HtsPosT*, HtsPosT* -> LibC::Int)) : HtsItrT*
    fun hts_itr_next(fp : Bgzf*, iter : HtsItrT*, r : Void*, data : Void*) : LibC::Int
    fun hts_itr_multi_bam(idx : HtsIdxT, iter : HtsItrT*) : LibC::Int
    fun hts_itr_multi_cram(idx : HtsIdxT, iter : HtsItrT*) : LibC::Int
    fun hts_itr_regions(idx : HtsIdxT, reglist : HtsReglistT*, count : LibC::Int, getid : HtsName2idF, hdr : Void*, itr_specific : (HtsIdxT, HtsItrT* -> LibC::Int), readrec : (Bgzf*, Void*, Void*, LibC::Int*, HtsPosT*, HtsPosT* -> LibC::Int), seek : (Void*, Int64T, LibC::Int -> LibC::Int), tell : (Void* -> Int64T)) : HtsItrT*
    fun hts_itr_multi_next(fd : HtsFile*, iter : HtsItrT*, r : Void*) : LibC::Int
    fun hts_reglist_create(argv : LibC::Char**, argc : LibC::Int, r_count : LibC::Int*, hdr : Void*, getid : HtsName2idF) : HtsReglistT*
    fun hts_reglist_free(reglist : HtsReglistT*, count : LibC::Int)
    fun hts_file_type(fname : LibC::Char*) : LibC::Int
    alias HtsMd5Context = Void*
    fun hts_md5_init : HtsMd5Context
    fun hts_md5_update(ctx : HtsMd5Context, data : Void*, size : LibC::ULong)
    fun hts_md5_final(digest : UInt8*, ctx : HtsMd5Context)
    fun hts_md5_reset(ctx : HtsMd5Context)
    fun hts_md5_hex(hex : LibC::Char*, digest : UInt8*)
    fun hts_md5_destroy(ctx : HtsMd5Context)
    fun hts_reg2bin(beg : HtsPosT, _end : HtsPosT, min_shift : LibC::Int, n_lvls : LibC::Int) : LibC::Int
    fun hts_bin_level(bin : LibC::Int) : LibC::Int
    fun hts_bin_bot(bin : LibC::Int, n_lvls : LibC::Int) : LibC::Int
    alias SamHrecsT = Void*
    fun sam_hdr_init : SamHdrT*
    fun bam_hdr_read(fp : Bgzf*) : SamHdrT*
    fun bam_hdr_write(fp : Bgzf*, h : SamHdrT*) : LibC::Int
    fun sam_hdr_destroy(h : SamHdrT*)
    fun sam_hdr_dup(h0 : SamHdrT*) : SamHdrT*
    fun bam_hdr_init : SamHdrT*
    fun bam_hdr_destroy(h : SamHdrT*)
    fun bam_hdr_dup(h0 : SamHdrT*) : SamHdrT*
    fun sam_hdr_parse(l_text : LibC::SizeT, text : LibC::Char*) : SamHdrT*
    fun sam_hdr_read(fp : SamFile*) : SamHdrT*
    alias SamFile = HtsFile
    fun sam_hdr_write(fp : SamFile*, h : SamHdrT*) : LibC::Int
    fun sam_hdr_length(h : SamHdrT*) : LibC::SizeT
    fun sam_hdr_str(h : SamHdrT*) : LibC::Char*
    fun sam_hdr_nref(h : SamHdrT*) : LibC::Int
    fun sam_hdr_add_lines(h : SamHdrT*, lines : LibC::Char*, len : LibC::SizeT) : LibC::Int
    fun sam_hdr_add_line(h : SamHdrT*, type : LibC::Char*, ...) : LibC::Int
    fun sam_hdr_find_line_id(h : SamHdrT*, type : LibC::Char*, id_key : LibC::Char*, id_val : LibC::Char*, ks : KstringT*) : LibC::Int
    fun sam_hdr_find_line_pos(h : SamHdrT*, type : LibC::Char*, pos : LibC::Int, ks : KstringT*) : LibC::Int
    fun sam_hdr_remove_line_id(h : SamHdrT*, type : LibC::Char*, id_key : LibC::Char*, id_value : LibC::Char*) : LibC::Int
    fun sam_hdr_remove_line_pos(h : SamHdrT*, type : LibC::Char*, position : LibC::Int) : LibC::Int
    fun sam_hdr_update_line(h : SamHdrT*, type : LibC::Char*, id_key : LibC::Char*, id_value : LibC::Char*, ...) : LibC::Int
    fun sam_hdr_remove_except(h : SamHdrT*, type : LibC::Char*, id_key : LibC::Char*, id_value : LibC::Char*) : LibC::Int
    fun sam_hdr_remove_lines(h : SamHdrT*, type : LibC::Char*, id : LibC::Char*, rh : Void*) : LibC::Int
    fun sam_hdr_count_lines(h : SamHdrT*, type : LibC::Char*) : LibC::Int
    fun sam_hdr_line_index(bh : SamHdrT*, type : LibC::Char*, key : LibC::Char*) : LibC::Int
    fun sam_hdr_line_name(bh : SamHdrT*, type : LibC::Char*, pos : LibC::Int) : LibC::Char*
    fun sam_hdr_find_tag_id(h : SamHdrT*, type : LibC::Char*, id_key : LibC::Char*, id_value : LibC::Char*, key : LibC::Char*, ks : KstringT*) : LibC::Int
    fun sam_hdr_find_tag_pos(h : SamHdrT*, type : LibC::Char*, pos : LibC::Int, key : LibC::Char*, ks : KstringT*) : LibC::Int
    fun sam_hdr_remove_tag_id(h : SamHdrT*, type : LibC::Char*, id_key : LibC::Char*, id_value : LibC::Char*, key : LibC::Char*) : LibC::Int
    fun sam_hdr_name2tid(h : SamHdrT*, ref : LibC::Char*) : LibC::Int
    fun sam_hdr_tid2name(h : SamHdrT*, tid : LibC::Int) : LibC::Char*
    fun sam_hdr_tid2len(h : SamHdrT*, tid : LibC::Int) : HtsPosT
    fun bam_name2id(h : SamHdrT*, ref : LibC::Char*) : LibC::Int
    fun sam_hdr_pg_id(h : SamHdrT*, name : LibC::Char*) : LibC::Char*
    fun sam_hdr_add_pg(h : SamHdrT*, name : LibC::Char*, ...) : LibC::Int
    fun sam_hdr_incr_ref(h : SamHdrT*)
    fun sam_hdr_set(fp : SamFile*, h : SamHdrT*, dup : LibC::Int) : LibC::Int
    fun sam_hdr_get(fp : SamFile*) : SamHdrT*
    fun bam_init1 : Bam1T*

    struct Bam1T
      core : Bam1CoreT
      id : Uint64T
      data : Uint8T*
      l_data : LibC::Int
      m_data : Uint32T
      mempolicy : Uint32T # FIXME
    end

    struct Bam1CoreT
      pos : HtsPosT
      tid : Int32T
      bin : Uint16T
      qual : Uint8T
      l_extranul : Uint8T
      flag : Uint16T
      l_qname : Uint16T
      n_cigar : Uint32T
      l_qseq : Int32T
      mtid : Int32T
      mpos : HtsPosT
      isize : HtsPosT
    end

    alias Uint16T = UInt16
    fun bam_destroy1(b : Bam1T*)
    fun bam_set_mempolicy(b : Bam1T*, policy : Uint32T)
    fun bam_get_mempolicy(b : Bam1T*) : Uint32T
    fun bam_read1(fp : Bgzf*, b : Bam1T*) : LibC::Int
    fun bam_write1(fp : Bgzf*, b : Bam1T*) : LibC::Int
    fun bam_copy1(bdst : Bam1T*, bsrc : Bam1T*) : Bam1T*
    fun bam_dup1(bsrc : Bam1T*) : Bam1T*
    fun bam_set1(bam : Bam1T*, l_qname : LibC::SizeT, qname : LibC::Char*, flag : Uint16T, tid : Int32T, pos : HtsPosT, mapq : Uint8T, n_cigar : LibC::SizeT, cigar : Uint32T*, mtid : Int32T, mpos : HtsPosT, isize : HtsPosT, l_seq : LibC::SizeT, seq : LibC::Char*, qual : LibC::Char*, l_aux : LibC::SizeT) : LibC::Int
    fun bam_cigar2qlen(n_cigar : LibC::Int, cigar : Uint32T*) : HtsPosT
    fun bam_cigar2rlen(n_cigar : LibC::Int, cigar : Uint32T*) : HtsPosT
    fun bam_endpos(b : Bam1T*) : HtsPosT
    fun bam_str2flag(str : LibC::Char*) : LibC::Int
    fun bam_flag2str(flag : LibC::Int) : LibC::Char*
    fun bam_set_qname(b : Bam1T*, qname : LibC::Char*) : LibC::Int
    fun sam_parse_cigar(in : LibC::Char*, _end : LibC::Char**, a_cigar : Uint32T**, a_mem : LibC::SizeT*) : SsizeT
    fun bam_parse_cigar(in : LibC::Char*, _end : LibC::Char**, b : Bam1T*) : SsizeT
    fun sam_idx_init(fp : HtsFile*, h : SamHdrT*, min_shift : LibC::Int, fnidx : LibC::Char*) : LibC::Int
    fun sam_idx_save(fp : HtsFile*) : LibC::Int
    fun sam_index_load(fp : HtsFile*, fn : LibC::Char*) : HtsIdxT
    fun sam_index_load2(fp : HtsFile*, fn : LibC::Char*, fnidx : LibC::Char*) : HtsIdxT
    fun sam_index_load3(fp : HtsFile*, fn : LibC::Char*, fnidx : LibC::Char*, flags : LibC::Int) : HtsIdxT
    fun sam_index_build(fn : LibC::Char*, min_shift : LibC::Int) : LibC::Int
    fun sam_index_build2(fn : LibC::Char*, fnidx : LibC::Char*, min_shift : LibC::Int) : LibC::Int
    fun sam_index_build3(fn : LibC::Char*, fnidx : LibC::Char*, min_shift : LibC::Int, nthreads : LibC::Int) : LibC::Int
    fun sam_itr_queryi(idx : HtsIdxT, tid : LibC::Int, beg : HtsPosT, _end : HtsPosT) : HtsItrT*
    fun sam_itr_querys(idx : HtsIdxT, hdr : SamHdrT*, region : LibC::Char*) : HtsItrT*
    fun sam_itr_regions(idx : HtsIdxT, hdr : SamHdrT*, reglist : HtsReglistT*, regcount : LibC::UInt) : HtsItrT*
    fun sam_itr_regarray(idx : HtsIdxT, hdr : SamHdrT*, regarray : LibC::Char**, regcount : LibC::UInt) : HtsItrT*
    fun sam_parse_region(h : SamHdrT*, s : LibC::Char*, tid : LibC::Int*, beg : HtsPosT*, _end : HtsPosT*, flags : LibC::Int) : LibC::Char*
    fun sam_open_mode(mode : LibC::Char*, fn : LibC::Char*, format : LibC::Char*) : LibC::Int
    fun sam_open_mode_opts(fn : LibC::Char*, mode : LibC::Char*, format : LibC::Char*) : LibC::Char*
    fun sam_hdr_change_hd = sam_hdr_change_HD(h : SamHdrT*, key : LibC::Char*, val : LibC::Char*) : LibC::Int
    fun sam_parse1(s : KstringT*, h : SamHdrT*, b : Bam1T*) : LibC::Int
    fun sam_format1(h : SamHdrT*, b : Bam1T*, str : KstringT*) : LibC::Int
    fun sam_read1(fp : SamFile*, h : SamHdrT*, b : Bam1T*) : LibC::Int
    fun sam_write1(fp : SamFile*, h : SamHdrT*, b : Bam1T*) : LibC::Int
    fun sam_passes_filter(h : SamHdrT*, b : Bam1T*, filt : HtsFilterT*) : LibC::Int
    fun sam_format_aux1(key : Uint8T*, type : Uint8T, tag : Uint8T*, _end : Uint8T*, ks : KstringT*) : Uint8T*
    fun bam_aux_first(b : Bam1T*) : Uint8T*
    fun bam_aux_next(b : Bam1T*, s : Uint8T*) : Uint8T*
    fun bam_aux_get(b : Bam1T*, tag : LibC::Char[2]) : Uint8T*
    fun bam_aux_get_str(b : Bam1T*, tag : LibC::Char[2], s : KstringT*) : LibC::Int
    fun bam_aux2i(s : Uint8T*) : Int64T
    fun bam_aux2f(s : Uint8T*) : LibC::Double
    fun bam_aux2_a = bam_aux2A(s : Uint8T*) : LibC::Char
    fun bam_aux2_z = bam_aux2Z(s : Uint8T*) : LibC::Char*
    fun bam_aux_b_len = bam_auxB_len(s : Uint8T*) : Uint32T
    fun bam_aux_b2i = bam_auxB2i(s : Uint8T*, idx : Uint32T) : Int64T
    fun bam_aux_b2f = bam_auxB2f(s : Uint8T*, idx : Uint32T) : LibC::Double
    fun bam_aux_append(b : Bam1T*, tag : LibC::Char[2], type : LibC::Char, len : LibC::Int, data : Uint8T*) : LibC::Int
    fun bam_aux_del(b : Bam1T*, s : Uint8T*) : LibC::Int
    fun bam_aux_remove(b : Bam1T*, s : Uint8T*) : Uint8T*
    fun bam_aux_update_str(b : Bam1T*, tag : LibC::Char[2], len : LibC::Int, data : LibC::Char*) : LibC::Int
    fun bam_aux_update_int(b : Bam1T*, tag : LibC::Char[2], val : Int64T) : LibC::Int
    fun bam_aux_update_float(b : Bam1T*, tag : LibC::Char[2], val : LibC::Float) : LibC::Int
    fun bam_aux_update_array(b : Bam1T*, tag : LibC::Char[2], type : Uint8T, items : Uint32T, data : Void*) : LibC::Int

    struct BamPileup1T
      b : Bam1T*
      qpos : Int32T
      indel : LibC::Int
      level : LibC::Int
      bitfields : Uint32T # FIXME
      # is_del : Uint32T
      # is_head : Uint32T
      # is_tail : Uint32T
      # is_refskip : Uint32T
      # reserved
      # aux : Uint32T
      cd : BamPileupCd
      cigar_ind : LibC::Int
    end

    union BamPileupCd
      p : Void*
      i : Int64T
      f : LibC::Double
    end

    alias BamPlpS = Void
    alias BamMplpS = Void
    fun bam_plp_init(func : BamPlpAutoF, data : Void*) : BamPlpT
    alias BamPlpAutoF = (Void*, Bam1T* -> LibC::Int)
    type BamPlpT = Void*
    fun bam_plp_destroy(iter : BamPlpT)
    fun bam_plp_push(iter : BamPlpT, b : Bam1T*) : LibC::Int
    fun bam_plp_next(iter : BamPlpT, _tid : LibC::Int*, _pos : LibC::Int*, _n_plp : LibC::Int*) : BamPileup1T*
    fun bam_plp_auto(iter : BamPlpT, _tid : LibC::Int*, _pos : LibC::Int*, _n_plp : LibC::Int*) : BamPileup1T*
    fun bam_plp64_next(iter : BamPlpT, _tid : LibC::Int*, _pos : HtsPosT*, _n_plp : LibC::Int*) : BamPileup1T*
    fun bam_plp64_auto(iter : BamPlpT, _tid : LibC::Int*, _pos : HtsPosT*, _n_plp : LibC::Int*) : BamPileup1T*
    fun bam_plp_set_maxcnt(iter : BamPlpT, maxcnt : LibC::Int)
    fun bam_plp_reset(iter : BamPlpT)
    fun bam_plp_constructor(plp : BamPlpT, func : (Void*, Bam1T*, BamPileupCd* -> LibC::Int))
    fun bam_plp_destructor(plp : BamPlpT, func : (Void*, Bam1T*, BamPileupCd* -> LibC::Int))
    fun bam_plp_insertion(p : BamPileup1T*, ins : KstringT*, del_len : LibC::Int*) : LibC::Int
    alias HtsBaseModState = Void*
    fun bam_plp_insertion_mod(p : BamPileup1T*, m : HtsBaseModState, ins : KstringT*, del_len : LibC::Int*) : LibC::Int
    fun bam_mplp_init(n : LibC::Int, func : BamPlpAutoF, data : Void**) : BamMplpT
    type BamMplpT = Void*
    fun bam_mplp_init_overlaps(iter : BamMplpT) : LibC::Int
    fun bam_mplp_destroy(iter : BamMplpT)
    fun bam_mplp_set_maxcnt(iter : BamMplpT, maxcnt : LibC::Int)
    fun bam_mplp_auto(iter : BamMplpT, _tid : LibC::Int*, _pos : LibC::Int*, n_plp : LibC::Int*, plp : BamPileup1T**) : LibC::Int
    fun bam_mplp64_auto(iter : BamMplpT, _tid : LibC::Int*, _pos : HtsPosT*, n_plp : LibC::Int*, plp : BamPileup1T**) : LibC::Int
    fun bam_mplp_reset(iter : BamMplpT)
    fun bam_mplp_constructor(iter : BamMplpT, func : (Void*, Bam1T*, BamPileupCd* -> LibC::Int))
    fun bam_mplp_destructor(iter : BamMplpT, func : (Void*, Bam1T*, BamPileupCd* -> LibC::Int))
    fun sam_cap_mapq(b : Bam1T*, ref : LibC::Char*, ref_len : HtsPosT, thres : LibC::Int) : LibC::Int
    fun sam_prob_realn(b : Bam1T*, ref : LibC::Char*, ref_len : HtsPosT, flag : LibC::Int) : LibC::Int

    struct HtsBaseMod
      modified_base : LibC::Int
      canonical_base : LibC::Int
      strand : LibC::Int
      qual : LibC::Int
    end

    fun hts_base_mod_state_alloc : HtsBaseModState
    fun hts_base_mod_state_free(state : HtsBaseModState)
    fun bam_parse_basemod(b : Bam1T*, state : HtsBaseModState) : LibC::Int
    fun bam_parse_basemod2(b : Bam1T*, state : HtsBaseModState, flags : Uint32T) : LibC::Int
    fun bam_mods_at_next_pos(b : Bam1T*, state : HtsBaseModState, mods : HtsBaseMod*, n_mods : LibC::Int) : LibC::Int
    fun bam_next_basemod(b : Bam1T*, state : HtsBaseModState, mods : HtsBaseMod*, n_mods : LibC::Int, pos : LibC::Int*) : LibC::Int
    fun bam_mods_at_qpos(b : Bam1T*, qpos : LibC::Int, state : HtsBaseModState, mods : HtsBaseMod*, n_mods : LibC::Int) : LibC::Int
    fun bam_mods_query_type(state : HtsBaseModState, code : LibC::Int, strand : LibC::Int*, implicit : LibC::Int*, canonical : LibC::Char*) : LibC::Int
    fun bam_mods_queryi(state : HtsBaseModState, i : LibC::Int, strand : LibC::Int*, implicit : LibC::Int*, canonical : LibC::Char*) : LibC::Int
    fun bam_mods_recorded(state : HtsBaseModState, ntype : LibC::Int*) : LibC::Int*
    alias CramFileDef = Void
    alias CramContainer = Void*
    alias CramBlock = Void*
    alias CramSlice = Void*
    alias CramMetrics = Void*
    alias CramBlockSliceHdr = Void
    alias CramBlockCompressionHdr = Void
    alias CramCodec = Void*
    alias CramCid2dsT = Void*
    enum CramBlockMethod
      CramCompUnknown  = -1
      CramCompRaw      =  0
      CramCompGzip     =  1
      CramCompBzip2    =  2
      CramCompLzma     =  3
      CramCompRans4x8  =  4
      CramCompRansNx16 =  5
      CramCompArith    =  6
      CramCompFqz      =  7
      CramCompTok3     =  8
    end
    fun cram_fd_get_header(fd : CramFd*) : SamHdrT*
    fun cram_fd_set_header(fd : CramFd*, hdr : SamHdrT*)
    fun cram_fd_get_version(fd : CramFd*) : LibC::Int
    fun cram_fd_set_version(fd : CramFd*, vers : LibC::Int)
    fun cram_major_vers(fd : CramFd*) : LibC::Int
    fun cram_minor_vers(fd : CramFd*) : LibC::Int
    fun cram_fd_get_fp(fd : CramFd*) : HFile*
    fun cram_fd_set_fp(fd : CramFd*, fp : HFile*)
    fun cram_container_get_length(c : CramContainer) : Int32T
    fun cram_container_set_length(c : CramContainer, length : Int32T)
    fun cram_container_get_num_blocks(c : CramContainer) : Int32T
    fun cram_container_set_num_blocks(c : CramContainer, num_blocks : Int32T)
    fun cram_container_get_landmarks(c : CramContainer, num_landmarks : Int32T*) : Int32T*
    fun cram_container_set_landmarks(c : CramContainer, num_landmarks : Int32T, landmarks : Int32T*)
    fun cram_container_get_num_records(c : CramContainer) : Int32T
    fun cram_container_get_num_bases(c : CramContainer) : Int32T
    fun cram_container_is_empty(fd : CramFd*) : LibC::Int
    fun cram_block_get_content_id(b : CramBlock) : Int32T
    fun cram_block_get_comp_size(b : CramBlock) : Int32T
    fun cram_block_get_uncomp_size(b : CramBlock) : Int32T
    fun cram_block_get_crc32(b : CramBlock) : Int32T
    fun cram_block_get_data(b : CramBlock) : Void*
    fun cram_block_get_content_type(b : CramBlock) : CramContentType
    enum CramContentType
      CtError           = -1
      FileHeader        =  0
      CompressionHeader =  1
      MappedSlice       =  2
      UnmappedSlice     =  3
      External          =  4
      Core              =  5
    end
    fun cram_block_set_content_id(b : CramBlock, id : Int32T)
    fun cram_block_set_comp_size(b : CramBlock, size : Int32T)
    fun cram_block_set_uncomp_size(b : CramBlock, size : Int32T)
    fun cram_block_set_crc32(b : CramBlock, crc : Int32T)
    fun cram_block_set_data(b : CramBlock, data : Void*)
    fun cram_block_append(b : CramBlock, data : Void*, size : LibC::Int) : LibC::Int
    fun cram_block_update_size(b : CramBlock)
    fun cram_block_get_offset(b : CramBlock) : LibC::SizeT
    fun cram_block_set_offset(b : CramBlock, offset : LibC::SizeT)
    fun cram_block_get_method(b : CramBlock) : CramBlockMethod
    fun cram_expand_method(data : Void*, size : LibC::SizeT, comp : CramBlockMethod) : Void*
    fun cram_block_size(b : CramBlock) : Uint32T
    fun cram_transcode_rg(in : CramFd*, out : CramFd*, c : CramContainer, nrg : LibC::Int, in_rg : LibC::Int*, out_rg : LibC::Int*) : LibC::Int
    fun cram_copy_slice(in : CramFd*, out : CramFd*, num_slice : Int32T) : LibC::Int
    fun cram_decode_slice_header(fd : CramFd*, b : CramBlock) : CramBlockSliceHdr*
    fun cram_free_slice_header(hdr : CramBlockSliceHdr*)
    fun cram_slice_hdr_get_coords(h : CramBlockSliceHdr*, refid : LibC::Int*, start : HtsPosT*, span : HtsPosT*)
    fun cram_slice_hdr_get_embed_ref_id(h : CramBlockSliceHdr*) : LibC::Int
    fun cram_slice_hdr_get_num_blocks(hdr : CramBlockSliceHdr*) : Int32T
    fun cram_decode_compression_header(fd : CramFd*, b : CramBlock) : CramBlockCompressionHdr*
    fun cram_free_compression_header(hdr : CramBlockCompressionHdr*)
    fun cram_update_cid2ds_map(hdr : CramBlockCompressionHdr*, cid2ds : CramCid2dsT*) : CramCid2dsT*
    fun cram_cid2ds_query(c2d : CramCid2dsT*, content_id : LibC::Int, n : LibC::Int*) : LibC::Int*
    fun cram_cid2ds_free(cid2ds : CramCid2dsT*)
    fun cram_describe_encodings(hdr : CramBlockCompressionHdr*, ks : KstringT*) : LibC::Int
    fun cram_codec_get_content_ids(c : CramCodec*, ids : LibC::Int[2])
    fun cram_codec_describe(c : CramCodec*, ks : KstringT*) : LibC::Int
    fun cram_new_block(content_type : CramContentType, content_id : LibC::Int) : CramBlock
    fun cram_read_block(fd : CramFd*) : CramBlock
    fun cram_write_block(fd : CramFd*, b : CramBlock) : LibC::Int
    fun cram_free_block(b : CramBlock)
    fun cram_uncompress_block(b : CramBlock) : LibC::Int
    fun cram_compress_block(fd : CramFd*, b : CramBlock, metrics : CramMetrics, method : LibC::Int, level : LibC::Int) : LibC::Int
    fun cram_compress_block2(fd : CramFd*, s : CramSlice, b : CramBlock, metrics : CramMetrics, method : LibC::Int, level : LibC::Int) : LibC::Int
    fun cram_new_container(nrec : LibC::Int, nslice : LibC::Int) : CramContainer
    fun cram_free_container(c : CramContainer)
    fun cram_read_container(fd : CramFd*) : CramContainer
    fun cram_write_container(fd : CramFd*, h : CramContainer) : LibC::Int
    fun cram_store_container(fd : CramFd*, c : CramContainer, dat : LibC::Char*, size : LibC::Int*) : LibC::Int
    fun cram_container_size(c : CramContainer) : LibC::Int
    fun cram_open(filename : LibC::Char*, mode : LibC::Char*) : CramFd*
    fun cram_dopen(fp : HFile*, filename : LibC::Char*, mode : LibC::Char*) : CramFd*
    fun cram_close(fd : CramFd*) : LibC::Int
    fun cram_seek(fd : CramFd*, offset : OffT, whence : LibC::Int) : LibC::Int
    fun cram_flush(fd : CramFd*) : LibC::Int
    fun cram_eof(fd : CramFd*) : LibC::Int
    fun cram_set_option(fd : CramFd*, opt : HtsFmtOption, ...) : LibC::Int
    fun cram_set_voption(fd : CramFd*, opt : HtsFmtOption, args : VaList) : LibC::Int
    alias VaList = LibC::VaList
    fun cram_set_header(fd : CramFd*, hdr : SamHdrT*) : LibC::Int
    fun cram_check_eof = cram_check_EOF(fd : CramFd*) : LibC::Int
    fun sam_hdr_parse_(hdr : LibC::Char*, len : LibC::SizeT) : SamHdr*
    alias SamHdr = SamHdrT
    fun sam_hdr_free(hdr : SamHdr*)
    fun cram_get_refs(fd : HtsFile*) : RefsT
    type RefsT = Void*
    fun fai_build3(fn : LibC::Char*, fnfai : LibC::Char*, fngzi : LibC::Char*) : LibC::Int
    fun fai_build(fn : LibC::Char*) : LibC::Int
    fun fai_destroy(fai : FaidxT)
    type FaidxT = Void*
    fun fai_load3(fn : LibC::Char*, fnfai : LibC::Char*, fngzi : LibC::Char*, flags : LibC::Int) : FaidxT
    fun fai_load(fn : LibC::Char*) : FaidxT
    fun fai_load3_format(fn : LibC::Char*, fnfai : LibC::Char*, fngzi : LibC::Char*, flags : LibC::Int, format : FaiFormatOptions) : FaidxT
    enum FaiFormatOptions
      FaiNone  = 0
      FaiFasta = 1
      FaiFastq = 2
    end
    fun fai_load_format(fn : LibC::Char*, format : FaiFormatOptions) : FaidxT
    fun fai_fetch(fai : FaidxT, reg : LibC::Char*, len : LibC::Int*) : LibC::Char*
    fun fai_fetch64(fai : FaidxT, reg : LibC::Char*, len : HtsPosT*) : LibC::Char*
    fun fai_fetchqual(fai : FaidxT, reg : LibC::Char*, len : LibC::Int*) : LibC::Char*
    fun fai_fetchqual64(fai : FaidxT, reg : LibC::Char*, len : HtsPosT*) : LibC::Char*
    fun faidx_fetch_nseq(fai : FaidxT) : LibC::Int
    fun faidx_fetch_seq(fai : FaidxT, c_name : LibC::Char*, p_beg_i : LibC::Int, p_end_i : LibC::Int, len : LibC::Int*) : LibC::Char*
    fun faidx_fetch_seq64(fai : FaidxT, c_name : LibC::Char*, p_beg_i : HtsPosT, p_end_i : HtsPosT, len : HtsPosT*) : LibC::Char*
    fun faidx_fetch_qual(fai : FaidxT, c_name : LibC::Char*, p_beg_i : LibC::Int, p_end_i : LibC::Int, len : LibC::Int*) : LibC::Char*
    fun faidx_fetch_qual64(fai : FaidxT, c_name : LibC::Char*, p_beg_i : HtsPosT, p_end_i : HtsPosT, len : HtsPosT*) : LibC::Char*
    fun faidx_has_seq(fai : FaidxT, seq : LibC::Char*) : LibC::Int
    fun faidx_nseq(fai : FaidxT) : LibC::Int
    fun faidx_iseq(fai : FaidxT, i : LibC::Int) : LibC::Char*
    fun faidx_seq_len(fai : FaidxT, seq : LibC::Char*) : LibC::Int
    fun faidx_seq_len64(fai : FaidxT, seq : LibC::Char*) : HtsPosT
    fun fai_line_length(fai : FaidxT, reg : LibC::Char*) : LibC::Int
    fun fai_parse_region(fai : FaidxT, s : LibC::Char*, tid : LibC::Int*, beg : HtsPosT*, _end : HtsPosT*, flags : LibC::Int) : LibC::Char*
    fun fai_adjust_region(fai : FaidxT, tid : LibC::Int, beg : HtsPosT*, _end : HtsPosT*) : LibC::Int
    fun fai_set_cache_size(fai : FaidxT, cache_size : LibC::Int)
    fun fai_thread_pool(fai : FaidxT, pool : HtsTpool*, qsize : LibC::Int) : LibC::Int
    fun fai_path(fa : LibC::Char*) : LibC::Char*

    struct TbxConfT
      preset : Int32T
      sc : Int32T
      bc : Int32T
      ec : Int32T
      meta_char : Int32T
      line_skip : Int32T
    end

    struct TbxT
      conf : TbxConfT
      idx : HtsIdxT
      dict : Void*
    end

    fun tbx_name2id(tbx : TbxT*, ss : LibC::Char*) : LibC::Int
    fun hts_get_bgzfp(fp : HtsFile*) : Bgzf*
    fun tbx_readrec(fp : Bgzf*, tbxv : Void*, sv : Void*, tid : LibC::Int*, beg : HtsPosT*, _end : HtsPosT*) : LibC::Int
    fun tbx_index(fp : Bgzf*, min_shift : LibC::Int, conf : TbxConfT*) : TbxT*
    fun tbx_index_build(fn : LibC::Char*, min_shift : LibC::Int, conf : TbxConfT*) : LibC::Int
    fun tbx_index_build2(fn : LibC::Char*, fnidx : LibC::Char*, min_shift : LibC::Int, conf : TbxConfT*) : LibC::Int
    fun tbx_index_build3(fn : LibC::Char*, fnidx : LibC::Char*, min_shift : LibC::Int, n_threads : LibC::Int, conf : TbxConfT*) : LibC::Int
    fun tbx_index_load(fn : LibC::Char*) : TbxT*
    fun tbx_index_load2(fn : LibC::Char*, fnidx : LibC::Char*) : TbxT*
    fun tbx_index_load3(fn : LibC::Char*, fnidx : LibC::Char*, flags : LibC::Int) : TbxT*
    fun tbx_seqnames(tbx : TbxT*, n : LibC::Int*) : LibC::Char**
    fun tbx_destroy(tbx : TbxT*)

    struct BcfHrecT
      type : LibC::Int
      key : LibC::Char*
      value : LibC::Char*
      nkeys : LibC::Int
      keys : LibC::Char**
      vals : LibC::Char**
    end

    struct BcfIdinfoT
      info : Uint64T[3]
      hrec : BcfHrecT*[3]
      id : LibC::Int
    end

    struct BcfIdpairT
      key : LibC::Char*
      val : BcfIdinfoT*
    end

    struct BcfHdrT
      n : Int32T[3]
      id : BcfIdpairT*[3]
      dict : Void*[3]
      samples : LibC::Char**
      hrec : BcfHrecT**
      nhrec : LibC::Int
      dirty : LibC::Int
      ntransl : LibC::Int
      transl : LibC::Int*[2]
      nsamples_ori : LibC::Int
      keep_samples : Uint8T*
      mem : KstringT
      m : Int32T[3]
    end

    struct BcfVariantT
      type : LibC::Int
      n : LibC::Int
    end

    struct BcfFmtT
      id : LibC::Int
      n : LibC::Int
      size : LibC::Int
      type : LibC::Int
      p : Uint8T*
      p_len : Uint32T
      p_off_free : Uint32T # FIXME
      # p_off : Uint32T
      # p_free : Uint32T
    end

    struct BcfInfoT
      key : LibC::Int
      type : LibC::Int
      v1 : BcfInfoTV1
      vptr : Uint8T*
      vptr_len : Uint32T
      vptr_off_free : Uint32T # FIXME
      # vptr_off : Uint32T
      # vptr_free : Uint32T
      len : LibC::Int
    end

    union BcfInfoTV1
      i : Int64T
      f : LibC::Float
    end

    struct BcfDecT
      m_fmt : LibC::Int
      m_info : LibC::Int
      m_id : LibC::Int
      m_als : LibC::Int
      m_allele : LibC::Int
      m_flt : LibC::Int
      n_flt : LibC::Int
      flt : LibC::Int*
      id : LibC::Char*
      als : LibC::Char*
      allele : LibC::Char**
      info : BcfInfoT*
      fmt : BcfFmtT*
      var : BcfVariantT*
      n_var : LibC::Int
      var_type : LibC::Int
      shared_dirty : LibC::Int
      indiv_dirty : LibC::Int
    end

    fun bcf_strerror(errorcode : LibC::Int, buffer : LibC::Char*, maxbuffer : LibC::SizeT) : LibC::Char*
    fun bcf_hdr_init(mode : LibC::Char*) : BcfHdrT*
    fun bcf_hdr_destroy(h : BcfHdrT*)
    fun bcf_init : Bcf1T*

    struct Bcf1T
      pos : HtsPosT
      rlen : HtsPosT
      rid : Int32T
      qual : LibC::Float
      n_info_allele : Uint32T # FIXME
      # n_info : Uint32T
      # n_allele : Uint32T
      n_fmt_sample : Uint32T # FIXME
      # n_fmt : Uint32T
      # n_sample : Uint32T
      shared : KstringT
      indiv : KstringT
      d : BcfDecT
      max_unpack : LibC::Int
      unpacked : LibC::Int
      unpack_size : LibC::Int[3]
      errcode : LibC::Int
    end

    fun bcf_destroy(v : Bcf1T*)
    fun bcf_empty(v : Bcf1T*)
    fun bcf_clear(v : Bcf1T*)
    fun bcf_hdr_read(fp : HtsFile*) : BcfHdrT*
    fun bcf_hdr_set_samples(hdr : BcfHdrT*, samples : LibC::Char*, is_file : LibC::Int) : LibC::Int
    fun bcf_subset_format(hdr : BcfHdrT*, rec : Bcf1T*) : LibC::Int
    fun bcf_hdr_write(fp : HtsFile*, h : BcfHdrT*) : LibC::Int
    fun vcf_parse(s : KstringT*, h : BcfHdrT*, v : Bcf1T*) : LibC::Int
    fun vcf_open_mode(mode : LibC::Char*, fn : LibC::Char*, format : LibC::Char*) : LibC::Int
    fun vcf_format(h : BcfHdrT*, v : Bcf1T*, s : KstringT*) : LibC::Int
    fun bcf_read(fp : HtsFile*, h : BcfHdrT*, v : Bcf1T*) : LibC::Int
    fun bcf_unpack(b : Bcf1T*, which : LibC::Int) : LibC::Int
    fun bcf_dup(src : Bcf1T*) : Bcf1T*
    fun bcf_copy(dst : Bcf1T*, src : Bcf1T*) : Bcf1T*
    fun bcf_write(fp : HtsFile*, h : BcfHdrT*, v : Bcf1T*) : LibC::Int
    fun vcf_hdr_read(fp : HtsFile*) : BcfHdrT*
    fun vcf_hdr_write(fp : HtsFile*, h : BcfHdrT*) : LibC::Int
    fun vcf_read(fp : HtsFile*, h : BcfHdrT*, v : Bcf1T*) : LibC::Int
    fun vcf_write(fp : HtsFile*, h : BcfHdrT*, v : Bcf1T*) : LibC::Int
    fun bcf_readrec(fp : Bgzf*, null : Void*, v : Void*, tid : LibC::Int*, beg : HtsPosT*, _end : HtsPosT*) : LibC::Int
    fun vcf_write_line(fp : HtsFile*, line : KstringT*) : LibC::Int
    fun bcf_hdr_dup(hdr : BcfHdrT*) : BcfHdrT*
    fun bcf_hdr_combine(dst : BcfHdrT*, src : BcfHdrT*) : LibC::Int
    fun bcf_hdr_merge(dst : BcfHdrT*, src : BcfHdrT*) : BcfHdrT*
    fun bcf_hdr_add_sample(hdr : BcfHdrT*, sample : LibC::Char*) : LibC::Int
    fun bcf_hdr_set(hdr : BcfHdrT*, fname : LibC::Char*) : LibC::Int
    fun bcf_hdr_format(hdr : BcfHdrT*, is_bcf : LibC::Int, str : KstringT*) : LibC::Int
    fun bcf_hdr_fmt_text(hdr : BcfHdrT*, is_bcf : LibC::Int, len : LibC::Int*) : LibC::Char*
    fun bcf_hdr_append(h : BcfHdrT*, line : LibC::Char*) : LibC::Int
    fun bcf_hdr_printf(h : BcfHdrT*, format : LibC::Char*, ...) : LibC::Int
    fun bcf_hdr_get_version(hdr : BcfHdrT*) : LibC::Char*
    fun bcf_hdr_set_version(hdr : BcfHdrT*, version : LibC::Char*) : LibC::Int
    fun bcf_hdr_remove(h : BcfHdrT*, type : LibC::Int, key : LibC::Char*)
    fun bcf_hdr_subset(h0 : BcfHdrT*, n : LibC::Int, samples : LibC::Char**, imap : LibC::Int*) : BcfHdrT*
    fun bcf_hdr_seqnames(h : BcfHdrT*, nseqs : LibC::Int*) : LibC::Char**
    fun bcf_hdr_parse(hdr : BcfHdrT*, htxt : LibC::Char*) : LibC::Int
    fun bcf_hdr_sync(h : BcfHdrT*) : LibC::Int
    fun bcf_hdr_parse_line(h : BcfHdrT*, line : LibC::Char*, len : LibC::Int*) : BcfHrecT*
    fun bcf_hrec_format(hrec : BcfHrecT*, str : KstringT*) : LibC::Int
    fun bcf_hdr_add_hrec(hdr : BcfHdrT*, hrec : BcfHrecT*) : LibC::Int
    fun bcf_hdr_get_hrec(hdr : BcfHdrT*, type : LibC::Int, key : LibC::Char*, value : LibC::Char*, str_class : LibC::Char*) : BcfHrecT*
    fun bcf_hrec_dup(hrec : BcfHrecT*) : BcfHrecT*
    fun bcf_hrec_add_key(hrec : BcfHrecT*, str : LibC::Char*, len : LibC::SizeT) : LibC::Int
    fun bcf_hrec_set_val(hrec : BcfHrecT*, i : LibC::Int, str : LibC::Char*, len : LibC::SizeT, is_quoted : LibC::Int) : LibC::Int
    fun bcf_hrec_find_key(hrec : BcfHrecT*, key : LibC::Char*) : LibC::Int
    fun bcf_hrec_destroy(hrec : BcfHrecT*)
    fun bcf_subset(h : BcfHdrT*, v : Bcf1T*, n : LibC::Int, imap : LibC::Int*) : LibC::Int
    fun bcf_translate(dst_hdr : BcfHdrT*, src_hdr : BcfHdrT*, src_line : Bcf1T*) : LibC::Int
    fun bcf_get_variant_types(rec : Bcf1T*) : LibC::Int
    fun bcf_get_variant_type(rec : Bcf1T*, ith_allele : LibC::Int) : LibC::Int
    fun bcf_has_variant_types(rec : Bcf1T*, bitmask : Uint32T, mode : BcfVariantMatch) : LibC::Int
    enum BcfVariantMatch
      BcfMatchExact   = 0
      BcfMatchOverlap = 1
      BcfMatchSubset  = 2
    end
    fun bcf_has_variant_type(rec : Bcf1T*, ith_allele : LibC::Int, bitmask : Uint32T) : LibC::Int
    fun bcf_variant_length(rec : Bcf1T*, ith_allele : LibC::Int) : LibC::Int
    fun bcf_is_snp(v : Bcf1T*) : LibC::Int
    fun bcf_update_filter(hdr : BcfHdrT*, line : Bcf1T*, flt_ids : LibC::Int*, n : LibC::Int) : LibC::Int
    fun bcf_add_filter(hdr : BcfHdrT*, line : Bcf1T*, flt_id : LibC::Int) : LibC::Int
    fun bcf_remove_filter(hdr : BcfHdrT*, line : Bcf1T*, flt_id : LibC::Int, pass : LibC::Int) : LibC::Int
    fun bcf_has_filter(hdr : BcfHdrT*, line : Bcf1T*, filter : LibC::Char*) : LibC::Int
    fun bcf_update_alleles(hdr : BcfHdrT*, line : Bcf1T*, alleles : LibC::Char**, nals : LibC::Int) : LibC::Int
    fun bcf_update_alleles_str(hdr : BcfHdrT*, line : Bcf1T*, alleles_string : LibC::Char*) : LibC::Int
    fun bcf_update_id(hdr : BcfHdrT*, line : Bcf1T*, id : LibC::Char*) : LibC::Int
    fun bcf_add_id(hdr : BcfHdrT*, line : Bcf1T*, id : LibC::Char*) : LibC::Int
    fun bcf_update_info(hdr : BcfHdrT*, line : Bcf1T*, key : LibC::Char*, values : Void*, n : LibC::Int, type : LibC::Int) : LibC::Int
    fun bcf_update_info_int64(hdr : BcfHdrT*, line : Bcf1T*, key : LibC::Char*, values : Int64T*, n : LibC::Int) : LibC::Int
    fun bcf_update_format_string(hdr : BcfHdrT*, line : Bcf1T*, key : LibC::Char*, values : LibC::Char**, n : LibC::Int) : LibC::Int
    fun bcf_update_format(hdr : BcfHdrT*, line : Bcf1T*, key : LibC::Char*, values : Void*, n : LibC::Int, type : LibC::Int) : LibC::Int
    fun bcf_gt2alleles(igt : LibC::Int, a : LibC::Int*, b : LibC::Int*)
    fun bcf_get_fmt(hdr : BcfHdrT*, line : Bcf1T*, key : LibC::Char*) : BcfFmtT*
    fun bcf_get_info(hdr : BcfHdrT*, line : Bcf1T*, key : LibC::Char*) : BcfInfoT*
    fun bcf_get_fmt_id(line : Bcf1T*, id : LibC::Int) : BcfFmtT*
    fun bcf_get_info_id(line : Bcf1T*, id : LibC::Int) : BcfInfoT*
    fun bcf_get_info_values(hdr : BcfHdrT*, line : Bcf1T*, tag : LibC::Char*, dst : Void**, ndst : LibC::Int*, type : LibC::Int) : LibC::Int
    fun bcf_get_info_int64(hdr : BcfHdrT*, line : Bcf1T*, tag : LibC::Char*, dst : Int64T**, ndst : LibC::Int*) : LibC::Int
    fun bcf_get_format_string(hdr : BcfHdrT*, line : Bcf1T*, tag : LibC::Char*, dst : LibC::Char***, ndst : LibC::Int*) : LibC::Int
    fun bcf_get_format_values(hdr : BcfHdrT*, line : Bcf1T*, tag : LibC::Char*, dst : Void**, ndst : LibC::Int*, type : LibC::Int) : LibC::Int
    fun bcf_hdr_id2int(hdr : BcfHdrT*, type : LibC::Int, id : LibC::Char*) : LibC::Int
    fun bcf_hdr_name2id(hdr : BcfHdrT*, id : LibC::Char*) : LibC::Int
    fun bcf_hdr_id2name(hdr : BcfHdrT*, rid : LibC::Int) : LibC::Char*
    fun bcf_seqname(hdr : BcfHdrT*, rec : Bcf1T*) : LibC::Char*
    fun bcf_seqname_safe(hdr : BcfHdrT*, rec : Bcf1T*) : LibC::Char*
    fun bcf_fmt_array(s : KstringT*, n : LibC::Int, type : LibC::Int, data : Void*) : LibC::Int
    fun bcf_fmt_sized_array(s : KstringT*, ptr : Uint8T*) : Uint8T*
    fun bcf_enc_vchar(s : KstringT*, l : LibC::Int, a : LibC::Char*) : LibC::Int
    fun bcf_enc_vint(s : KstringT*, n : LibC::Int, a : Int32T*, wsize : LibC::Int) : LibC::Int
    fun bcf_enc_vfloat(s : KstringT*, n : LibC::Int, a : LibC::Float*) : LibC::Int
    fun bcf_itr_next(htsfp : HtsFile*, itr : HtsItrT*, r : Void*) : LibC::Int
    fun bcf_index_load2(fn : LibC::Char*, fnidx : LibC::Char*) : HtsIdxT
    fun bcf_index_load3(fn : LibC::Char*, fnidx : LibC::Char*, flags : LibC::Int) : HtsIdxT
    fun bcf_index_build(fn : LibC::Char*, min_shift : LibC::Int) : LibC::Int
    fun bcf_index_build2(fn : LibC::Char*, fnidx : LibC::Char*, min_shift : LibC::Int) : LibC::Int
    fun bcf_index_build3(fn : LibC::Char*, fnidx : LibC::Char*, min_shift : LibC::Int, n_threads : LibC::Int) : LibC::Int
    fun bcf_idx_init(fp : HtsFile*, h : BcfHdrT*, min_shift : LibC::Int, fnidx : LibC::Char*) : LibC::Int
    fun bcf_idx_save(fp : HtsFile*) : LibC::Int
    fun bcf_float_set(ptr : LibC::Float*, value : Uint32T)
    fun bcf_float_is_missing(f : LibC::Float) : LibC::Int
    fun bcf_float_is_vector_end(f : LibC::Float) : LibC::Int
    fun bcf_format_gt(fmt : BcfFmtT*, isample : LibC::Int, str : KstringT*) : LibC::Int
    fun bcf_enc_size(s : KstringT*, size : LibC::Int, type : LibC::Int) : LibC::Int
    fun bcf_enc_inttype(x : LibC::Long) : LibC::Int
    fun bcf_enc_int1(s : KstringT*, x : Int32T) : LibC::Int
    fun bcf_dec_int1(p : Uint8T*, type : LibC::Int, q : Uint8T**) : Int64T
    fun bcf_dec_typed_int1(p : Uint8T*, q : Uint8T**) : Int64T
    fun bcf_dec_size(p : Uint8T*, q : Uint8T**, type : LibC::Int*) : Int32T
    alias HtsTpoolProcess = Void
    alias HtsTpoolResult = Void
    fun hts_tpool_init(n : LibC::Int) : HtsTpool*
    fun hts_tpool_size(p : HtsTpool*) : LibC::Int
    fun hts_tpool_dispatch(p : HtsTpool*, q : HtsTpoolProcess*, func : (Void* -> Void*), arg : Void*) : LibC::Int
    fun hts_tpool_dispatch2(p : HtsTpool*, q : HtsTpoolProcess*, func : (Void* -> Void*), arg : Void*, nonblock : LibC::Int) : LibC::Int
    fun hts_tpool_dispatch3(p : HtsTpool*, q : HtsTpoolProcess*, exec_func : (Void* -> Void*), arg : Void*, job_cleanup : (Void* -> Void*), result_cleanup : (Void* -> Void*), nonblock : LibC::Int) : LibC::Int
    fun hts_tpool_wake_dispatch(q : HtsTpoolProcess*)
    fun hts_tpool_process_flush(q : HtsTpoolProcess*) : LibC::Int
    fun hts_tpool_process_reset(q : HtsTpoolProcess*, free_results : LibC::Int) : LibC::Int
    fun hts_tpool_process_qsize(q : HtsTpoolProcess*) : LibC::Int
    fun hts_tpool_destroy(p : HtsTpool*)
    fun hts_tpool_kill(p : HtsTpool*)
    fun hts_tpool_next_result(q : HtsTpoolProcess*) : HtsTpoolResult*
    fun hts_tpool_next_result_wait(q : HtsTpoolProcess*) : HtsTpoolResult*
    fun hts_tpool_delete_result(r : HtsTpoolResult*, free_data : LibC::Int)
    fun hts_tpool_result_data(r : HtsTpoolResult*) : Void*
    fun hts_tpool_process_init(p : HtsTpool*, qsize : LibC::Int, in_only : LibC::Int) : HtsTpoolProcess
    fun hts_tpool_process_destroy(q : HtsTpoolProcess*)
    fun hts_tpool_process_empty(q : HtsTpoolProcess*) : LibC::Int
    fun hts_tpool_process_len(q : HtsTpoolProcess*) : LibC::Int
    fun hts_tpool_process_sz(q : HtsTpoolProcess*) : LibC::Int
    fun hts_tpool_process_shutdown(q : HtsTpoolProcess*)
    fun hts_tpool_process_is_shutdown(q : HtsTpoolProcess*) : LibC::Int
    fun hts_tpool_process_attach(p : HtsTpool*, q : HtsTpoolProcess*)
    fun hts_tpool_process_detach(p : HtsTpool*, q : HtsTpoolProcess*)
    fun hts_tpool_process_ref_incr(q : HtsTpoolProcess*)
    fun hts_tpool_process_ref_decr(q : HtsTpoolProcess*)
    $hts_verbose : LibC::Int
    $bam_cigar_table : Int8T[256]
    $tbx_conf_gff : TbxConfT
    $tbx_conf_bed : TbxConfT
    $tbx_conf_psltbl : TbxConfT
    $tbx_conf_sam : TbxConfT
    $tbx_conf_vcf : TbxConfT
    $bcf_type_shift : Uint8T*
    $bcf_float_vector_end : Uint32T
    $bcf_float_missing : Uint32T

    # Nucleotide encoding/decoding tables exported by htslib (sam/bam API)
    # - seq_nt16_table: ASCII -> BAM 4-bit nibble code (size 256)
    # - seq_nt16_str:   code -> ASCII string mapping ("=ACMGRSVTWYHKDBN")
    # - seq_nt16_int:   legacy integer mapping table
    $seq_nt16_table : UInt8[256]
    $seq_nt16_str : LibC::Char[16]
    $seq_nt16_int : Int32[16]

    # HTS Expression/Filter functions (hts_expr.h)
    struct HtsExprValT
      is_str : UInt8
      is_true : UInt8
      s : LibC::SizeT
      d : LibC::Double
    end

    alias HtsExprSymFunc = (Void*, LibC::Char*, LibC::Char**, Void* -> LibC::Int)

    fun hts_expr_val_exists(v : HtsExprValT*) : LibC::Int
    fun hts_expr_val_exists_t = hts_expr_val_existsT(v : HtsExprValT*) : LibC::Int
    fun hts_expr_val_undef(v : HtsExprValT*)
    fun hts_expr_val_free(f : HtsExprValT*)
    fun hts_filter_init(str : LibC::Char*) : HtsFilterT*
    fun hts_filter_free(filt : HtsFilterT*)
    fun hts_filter_eval2(filt : HtsFilterT*, data : Void*, sym_func : HtsExprSymFunc, res : HtsExprValT*) : LibC::Int
    fun hts_filter_eval(filt : HtsFilterT*, data : Void*, sym_func : HtsExprSymFunc, res : HtsExprValT*) : LibC::Int
  end
end
