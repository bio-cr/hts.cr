@[Link("htslib")]
lib HTS
  fun hts_set_log_level(level : HtsLogLevel)
  enum HtsLogLevel
    HtsLogOff = 0
    HtsLogError = 1
    HtsLogWarning = 3
    HtsLogInfo = 4
    HtsLogDebug = 5
    HtsLogTrace = 6
  end
  fun hts_get_log_level : HtsLogLevel
  fun hts_log(severity : HtsLogLevel, context : LibC::Char*, format : LibC::Char*, ...)
  alias HtsTpool = Void
  fun hts_resize_array_(x0 : LibC::SizeT, x1 : LibC::SizeT, x2 : LibC::SizeT, x3 : Void*, x4 : Void**, x5 : LibC::Int, x6 : LibC::Char*) : LibC::Int
  fun hts_lib_shutdown
  fun hts_free(ptr : Void*)
  type HtsIdxT = Void*
  struct HtsOpt
    arg : LibC::Char*
    opt : HtsFmtOption
    val : HtsOptVal
    next : HtsOpt*
  end
  enum HtsFmtOption
    CramOptDecodeMd = 0
    CramOptPrefix = 1
    CramOptVerbosity = 2
    CramOptSeqsPerSlice = 3
    CramOptSlicesPerContainer = 4
    CramOptRange = 5
    CramOptVersion = 6
    CramOptEmbedRef = 7
    CramOptIgnoreMd5 = 8
    CramOptReference = 9
    CramOptMultiSeqPerSlice = 10
    CramOptNoRef = 11
    CramOptUseBzip2 = 12
    CramOptSharedRef = 13
    CramOptNthreads = 14
    CramOptThreadPool = 15
    CramOptUseLzma = 16
    CramOptUseRans = 17
    CramOptRequiredFields = 18
    CramOptLossyNames = 19
    CramOptBasesPerSlice = 20
    CramOptStoreMd = 21
    CramOptStoreNm = 22
    CramOptRangeNoseek = 23
    HtsOptCompressionLevel = 100
    HtsOptNthreads = 101
    HtsOptThreadPool = 102
    HtsOptCacheSize = 103
    HtsOptBlockSize = 104
  end
  union HtsOptVal
    i : LibC::Int
    s : LibC::Char*
  end
  fun hts_opt_add(opts : HtsOpt**, c_arg : LibC::Char*) : LibC::Int
  fun hts_opt_apply(fp : HtsFile*, opts : HtsOpt*) : LibC::Int
  struct HtsFile
    is_bin : Uint32T
    is_write : Uint32T
    is_be : Uint32T
    is_cram : Uint32T
    is_bgzf : Uint32T
    dummy : Uint32T
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
  end
  alias X__Uint32T = LibC::UInt
  alias Uint32T = X__Uint32T
  alias X__Int64T = LibC::Long
  alias Int64T = X__Int64T
  struct KstringT
    l : LibC::SizeT
    m : LibC::SizeT
    s : LibC::Char*
  end
  union HtsFileFp
    bgzf : Bgzf
    cram : CramFd*
    hfile : HFile*
  end
  type Bgzf = Void*
  alias CramFd = Void
  alias HFile = Void
  struct HtsFormat
    category : HtsFormatCategory
    format : HtsExactFormat
    version : HtsFormatVersion
    compression : HtsCompression
    compression_level : LibC::Short
    specific : Void*
  end
  enum HtsFormatCategory
    UnknownCategory = 0
    SequenceData = 1
    VariantData = 2
    IndexFile = 3
    RegionList = 4
    CategoryMaximum = 32767
  end
  enum HtsExactFormat
    UnknownFormat = 0
    BinaryFormat = 1
    TextFormat = 2
    Sam = 3
    Bam = 4
    Bai = 5
    Cram = 6
    Crai = 7
    Vcf = 8
    Bcf = 9
    Csi = 10
    Gzi = 11
    Tbi = 12
    Bed = 13
    Htsget = 14
    Json = 14
    EmptyFormat = 15
    FastaFormat = 16
    FastqFormat = 17
    FaiFormat = 18
    FqiFormat = 19
    HtsCrypt4ghFormat = 20
    FormatMaximum = 32767
  end
  struct HtsFormatVersion
    major : LibC::Short
    minor : LibC::Short
  end
  enum HtsCompression
    NoCompression = 0
    Gzip = 1
    Bgzf = 2
    Custom = 3
    Bzip2Compression = 4
    CompressionMaximum = 32767
  end
  alias SamHdrT = Void
  fun hts_opt_free(opts : HtsOpt*)
  fun hts_parse_format(opt : HtsFormat*, str : LibC::Char*) : LibC::Int
  fun hts_parse_opt_list(opt : HtsFormat*, str : LibC::Char*) : LibC::Int
  fun hts_version : LibC::Char*
  fun hts_detect_format(fp : HFile*, fmt : HtsFormat*) : LibC::Int
  fun hts_format_description(format : HtsFormat*) : LibC::Char*
  fun hts_open(fn : LibC::Char*, mode : LibC::Char*) : HtsFile*
  fun hts_open_format(fn : LibC::Char*, mode : LibC::Char*, fmt : HtsFormat*) : HtsFile*
  fun hts_hopen(fp : HFile*, fn : LibC::Char*, mode : LibC::Char*) : HtsFile*
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
  alias X__Uint64T = LibC::ULong
  alias Uint64T = X__Uint64T
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
    read_rest : Uint32T
    finished : Uint32T
    is_cram : Uint32T
    nocoor : Uint32T
    multi : Uint32T
    dummy : Uint32T
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
    readrec : (Bgzf, Void*, Void*, LibC::Int*, HtsPosT*, HtsPosT* -> LibC::Int)
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
  alias X__Uint8T = UInt8
  alias Uint8T = X__Uint8T
  fun hts_idx_set_meta(idx : HtsIdxT, l_meta : Uint32T, meta : Uint8T*, is_copy : LibC::Int) : LibC::Int
  fun hts_idx_get_stat(idx : HtsIdxT, tid : LibC::Int, mapped : Uint64T*, unmapped : Uint64T*) : LibC::Int
  fun hts_idx_get_n_no_coor(idx : HtsIdxT) : Uint64T
  fun hts_parse_decimal(str : LibC::Char*, strend : LibC::Char**, flags : LibC::Int) : LibC::LongLong
  fun hts_parse_reg64(str : LibC::Char*, beg : HtsPosT*, _end : HtsPosT*) : LibC::Char*
  fun hts_parse_reg(str : LibC::Char*, beg : LibC::Int*, _end : LibC::Int*) : LibC::Char*
  fun hts_parse_region(s : LibC::Char*, tid : LibC::Int*, beg : HtsPosT*, _end : HtsPosT*, getid : HtsName2idF, hdr : Void*, flags : LibC::Int) : LibC::Char*
  alias HtsName2idF = (Void*, LibC::Char* -> LibC::Int)
  fun hts_itr_query(idx : HtsIdxT, tid : LibC::Int, beg : HtsPosT, _end : HtsPosT, readrec : (Bgzf, Void*, Void*, LibC::Int*, HtsPosT*, HtsPosT* -> LibC::Int)) : HtsItrT*
  fun hts_itr_destroy(iter : HtsItrT*)
  fun hts_itr_querys(idx : HtsIdxT, reg : LibC::Char*, getid : HtsName2idF, hdr : Void*, itr_query : (HtsIdxT, LibC::Int, HtsPosT, HtsPosT, (Bgzf, Void*, Void*, LibC::Int*, HtsPosT*, HtsPosT* -> LibC::Int) -> HtsItrT*), readrec : (Bgzf, Void*, Void*, LibC::Int*, HtsPosT*, HtsPosT* -> LibC::Int)) : HtsItrT*
  fun hts_itr_next(fp : Bgzf, iter : HtsItrT*, r : Void*, data : Void*) : LibC::Int
  fun hts_idx_seqnames(idx : HtsIdxT, n : LibC::Int*, getid : HtsId2nameF, hdr : Void*) : LibC::Char**
  alias HtsId2nameF = (Void*, LibC::Int -> LibC::Char*)
  fun hts_itr_multi_bam(idx : HtsIdxT, iter : HtsItrT*) : LibC::Int
  fun hts_itr_multi_cram(idx : HtsIdxT, iter : HtsItrT*) : LibC::Int
  fun hts_itr_regions(idx : HtsIdxT, reglist : HtsReglistT*, count : LibC::Int, getid : HtsName2idF, hdr : Void*, itr_specific : (HtsIdxT, HtsItrT* -> LibC::Int), readrec : (Bgzf, Void*, Void*, LibC::Int*, HtsPosT*, HtsPosT* -> LibC::Int), seek : (Void*, Int64T, LibC::Int -> LibC::Int), tell : (Void* -> Int64T)) : HtsItrT*
  fun hts_itr_multi_next(fd : HtsFile*, iter : HtsItrT*, r : Void*) : LibC::Int
  fun hts_reglist_create(argv : LibC::Char**, argc : LibC::Int, r_count : LibC::Int*, hdr : Void*, getid : HtsName2idF) : HtsReglistT*
  fun hts_reglist_free(reglist : HtsReglistT*, count : LibC::Int)
  fun hts_file_type(fname : LibC::Char*) : LibC::Int
  type HtsMd5Context = Void*
  fun hts_md5_init : HtsMd5Context
  fun hts_md5_update(ctx : HtsMd5Context, data : Void*, size : LibC::ULong)
  fun hts_md5_final(digest : UInt8*, ctx : HtsMd5Context)
  fun hts_md5_reset(ctx : HtsMd5Context)
  fun hts_md5_hex(hex : LibC::Char*, digest : UInt8*)
  fun hts_md5_destroy(ctx : HtsMd5Context)
  fun hts_reg2bin(beg : HtsPosT, _end : HtsPosT, min_shift : LibC::Int, n_lvls : LibC::Int) : LibC::Int
  fun hts_bin_bot(bin : LibC::Int, n_lvls : LibC::Int) : LibC::Int
  $hts_verbose : LibC::Int
end
