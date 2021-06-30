@[Link("htslib")]
lib SAM
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

  alias X__Int32T = LibC::Int
  alias Int32T = X__Int32T
  alias X__Uint32T = LibC::UInt
  alias Uint32T = X__Uint32T
  alias X__Int8T = LibC::Char
  alias Int8T = X__Int8T
  type SamHrecsT = Void*
  alias SamHrecsT = Void
  fun sam_hdr_init : SamHdrT*
  fun bam_hdr_read(fp : Bgzf) : SamHdrT*
  type Bgzf = Void*
  fun bam_hdr_write(fp : Bgzf, h : SamHdrT*) : LibC::Int
  fun sam_hdr_destroy(h : SamHdrT*)
  fun sam_hdr_dup(h0 : SamHdrT*) : SamHdrT*
  fun bam_hdr_init : SamHdrT*
  fun bam_hdr_destroy(h : SamHdrT*)
  fun bam_hdr_dup(h0 : SamHdrT*) : SamHdrT*
  fun sam_hdr_parse(l_text : LibC::SizeT, text : LibC::Char*) : SamHdrT*
  fun sam_hdr_read(fp : SamFile*) : SamHdrT*

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

  alias SamFile = HtsFile
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
  alias HtsPosT = Int64T
  fun bam_name2id(h : SamHdrT*, ref : LibC::Char*) : LibC::Int
  fun sam_hdr_pg_id(h : SamHdrT*, name : LibC::Char*) : LibC::Char*
  fun sam_hdr_add_pg(h : SamHdrT*, name : LibC::Char*, ...) : LibC::Int
  fun sam_hdr_incr_ref(h : SamHdrT*)
  fun bam_init1 : Bam1T*

  struct Bam1T
    core : Bam1CoreT
    id : Uint64T
    data : Uint8T*
    l_data : LibC::Int
    m_data : Uint32T
    mempolicy : Uint32T
    # : Uint32T
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

  alias X__Uint16T = LibC::UShort
  alias Uint16T = X__Uint16T
  alias X__Uint8T = UInt8
  alias Uint8T = X__Uint8T
  alias X__Uint64T = LibC::ULong
  alias Uint64T = X__Uint64T
  fun bam_destroy1(b : Bam1T*)
  fun bam_set_mempolicy(b : Bam1T*, policy : Uint32T)
  fun bam_get_mempolicy(b : Bam1T*) : Uint32T
  fun bam_read1(fp : Bgzf, b : Bam1T*) : LibC::Int
  fun bam_write1(fp : Bgzf, b : Bam1T*) : LibC::Int
  fun bam_copy1(bdst : Bam1T*, bsrc : Bam1T*) : Bam1T*
  fun bam_dup1(bsrc : Bam1T*) : Bam1T*
  fun bam_cigar2qlen(n_cigar : LibC::Int, cigar : Uint32T*) : HtsPosT
  fun bam_cigar2rlen(n_cigar : LibC::Int, cigar : Uint32T*) : HtsPosT
  fun bam_endpos(b : Bam1T*) : HtsPosT
  fun bam_str2flag(str : LibC::Char*) : LibC::Int
  fun bam_flag2str(flag : LibC::Int) : LibC::Char*
  fun bam_set_qname(b : Bam1T*, qname : LibC::Char*) : LibC::Int
  fun sam_idx_init(fp : HtsFile*, h : SamHdrT*, min_shift : LibC::Int, fnidx : LibC::Char*) : LibC::Int
  fun sam_idx_save(fp : HtsFile*) : LibC::Int
  fun sam_index_load(fp : HtsFile*, fn : LibC::Char*) : HtsIdxT
  fun sam_index_load2(fp : HtsFile*, fn : LibC::Char*, fnidx : LibC::Char*) : HtsIdxT
  fun sam_index_load3(fp : HtsFile*, fn : LibC::Char*, fnidx : LibC::Char*, flags : LibC::Int) : HtsIdxT
  fun sam_index_build(fn : LibC::Char*, min_shift : LibC::Int) : LibC::Int
  fun sam_index_build2(fn : LibC::Char*, fnidx : LibC::Char*, min_shift : LibC::Int) : LibC::Int
  fun sam_index_build3(fn : LibC::Char*, fnidx : LibC::Char*, min_shift : LibC::Int, nthreads : LibC::Int) : LibC::Int
  fun sam_itr_queryi(idx : HtsIdxT, tid : LibC::Int, beg : HtsPosT, _end : HtsPosT) : HtsItrT*

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

  fun sam_itr_querys(idx : HtsIdxT, hdr : SamHdrT*, region : LibC::Char*) : HtsItrT*
  fun sam_itr_regions(idx : HtsIdxT, hdr : SamHdrT*, reglist : HtsReglistT*, regcount : LibC::UInt) : HtsItrT*
  fun sam_itr_regarray(idx : HtsIdxT, hdr : SamHdrT*, regarray : LibC::Char**, regcount : LibC::UInt) : HtsItrT*
  fun sam_itr_next(htsfp : HtsFile*, itr : HtsItrT*, r : Bam1T*) : LibC::Int
  fun sam_parse_region(h : SamHdrT*, s : LibC::Char*, tid : LibC::Int*, beg : HtsPosT*, _end : HtsPosT*, flags : LibC::Int) : LibC::Char*
  fun sam_open_mode(mode : LibC::Char*, fn : LibC::Char*, format : LibC::Char*) : LibC::Int
  fun sam_open_mode_opts(fn : LibC::Char*, mode : LibC::Char*, format : LibC::Char*) : LibC::Char*
  fun sam_hdr_change_hd = sam_hdr_change_HD(h : SamHdrT*, key : LibC::Char*, val : LibC::Char*) : LibC::Int
  fun sam_parse1(s : KstringT*, h : SamHdrT*, b : Bam1T*) : LibC::Int
  fun sam_format1(h : SamHdrT*, b : Bam1T*, str : KstringT*) : LibC::Int
  fun sam_read1(fp : SamFile*, h : SamHdrT*, b : Bam1T*) : LibC::Int
  fun sam_write1(fp : SamFile*, h : SamHdrT*, b : Bam1T*) : LibC::Int
  fun sam_format_aux1(key : Uint8T*, type : Uint8T, tag : Uint8T*, _end : Uint8T*, ks : KstringT*) : Uint8T*
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
  fun bam_aux_update_str(b : Bam1T*, tag : LibC::Char[2], len : LibC::Int, data : LibC::Char*) : LibC::Int
  fun bam_aux_update_int(b : Bam1T*, tag : LibC::Char[2], val : Int64T) : LibC::Int
  fun bam_aux_update_float(b : Bam1T*, tag : LibC::Char[2], val : LibC::Float) : LibC::Int
  fun bam_aux_update_array(b : Bam1T*, tag : LibC::Char[2], type : Uint8T, items : Uint32T, data : Void*) : LibC::Int

  struct BamPileup1T
    b : Bam1T*
    qpos : Int32T
    indel : LibC::Int
    level : LibC::Int
    is_del : Uint32T
    is_head : Uint32T
    is_tail : Uint32T
    is_refskip : Uint32T
    # : Uint32T
    aux : Uint32T
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
  $bam_cigar_table : Int8T[256]
end
