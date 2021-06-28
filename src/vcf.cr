@[Link("htslib")]
lib VCF
  BCF_GT_MISSING     = 0
  BCF_STR_VECTOR_END = 0
  BCF_STR_MISSING    = 7

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

  alias X__Uint64T = LibC::ULong
  alias Uint64T = X__Uint64T

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
    transl : LibC::Int[2]
    nsamples_ori : LibC::Int
    keep_samples : Uint8T*
    mem : KstringT
    m : Int32T[3]
  end

  alias X__Int32T = LibC::Int
  alias Int32T = X__Int32T
  alias X__Uint8T = UInt8
  alias Uint8T = X__Uint8T

  struct KstringT
    l : LibC::SizeT
    m : LibC::SizeT
    s : LibC::Char*
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
    p_off : Uint32T
    p_free : Uint32T
  end

  alias X__Uint32T = LibC::UInt
  alias Uint32T = X__Uint32T

  struct BcfInfoT
    key : LibC::Int
    type : LibC::Int
    v1 : BcfInfoTV1
    vptr : Uint8T*
    vptr_len : Uint32T
    vptr_off : Uint32T
    vptr_free : Uint32T
    len : LibC::Int
  end

  union BcfInfoTV1
    i : Int64T
    f : LibC::Float
  end

  alias X__Int64T = LibC::Long
  alias Int64T = X__Int64T

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

  fun bcf_hdr_init(mode : LibC::Char*) : BcfHdrT*
  fun bcf_hdr_destroy(h : BcfHdrT*)
  fun bcf_init : Bcf1T*

  struct Bcf1T
    pos : HtsPosT
    rlen : HtsPosT
    rid : Int32T
    qual : LibC::Float
    n_info : Uint32T
    n_allele : Uint32T
    n_fmt : Uint32T
    n_sample : Uint32T
    shared : KstringT
    indiv : KstringT
    d : BcfDecT
    max_unpack : LibC::Int
    unpacked : LibC::Int
    unpack_size : LibC::Int[3]
    errcode : LibC::Int
  end

  alias HtsPosT = Int64T
  fun bcf_destroy(v : Bcf1T*)
  fun bcf_empty(v : Bcf1T*)
  fun bcf_clear(v : Bcf1T*)
  fun bcf_hdr_read(fp : HtsFile*) : BcfHdrT*

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
    UnknownCategory =     0
    SequenceData    =     1
    VariantData     =     2
    IndexFile       =     3
    RegionList      =     4
    CategoryMaximum = 32767
  end
  enum HtsExactFormat
    UnknownFormat     =     0
    BinaryFormat      =     1
    TextFormat        =     2
    Sam               =     3
    Bam               =     4
    Bai               =     5
    Cram              =     6
    Crai              =     7
    Vcf               =     8
    Bcf               =     9
    Csi               =    10
    Gzi               =    11
    Tbi               =    12
    Bed               =    13
    Htsget            =    14
    Json              =    14
    EmptyFormat       =    15
    FastaFormat       =    16
    FastqFormat       =    17
    FaiFormat         =    18
    FqiFormat         =    19
    HtsCrypt4ghFormat =    20
    FormatMaximum     = 32767
  end

  struct HtsFormatVersion
    major : LibC::Short
    minor : LibC::Short
  end

  enum HtsCompression
    NoCompression      =     0
    Gzip               =     1
    Bgzf               =     2
    Custom             =     3
    Bzip2Compression   =     4
    CompressionMaximum = 32767
  end
  type HtsIdxT = Void*
  alias SamHdrT = Void
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
  fun bcf_readrec(fp : Bgzf, null : Void*, v : Void*, tid : LibC::Int*, beg : HtsPosT*, _end : HtsPosT*) : LibC::Int
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

  struct HtsReglistT
    reg : LibC::Char*
    intervals : HtsPairPosT*
    tid : LibC::Int
    count : Uint32T
    min_beg : HtsPosT
    max_end : HtsPosT
  end

  struct HtsPairPosT
    beg : HtsPosT
    _end : HtsPosT
  end

  struct HtsPair64MaxT
    u : Uint64T
    v : Uint64T
    max : Uint64T
  end

  struct HtsItrTBins
    n : LibC::Int
    m : LibC::Int
    a : LibC::Int*
  end

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
  $bcf_type_shift : Uint8T*
  $bcf_float_vector_end : Uint32T
  $bcf_float_missing : Uint32T
end
