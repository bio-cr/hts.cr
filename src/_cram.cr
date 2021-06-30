@[Link("htslib")]
lib CRAM
  alias CramFd = Void
  alias CramFileDef = Void
  alias CramContainer = Void
  alias CramBlock = Void
  alias CramSlice = Void
  alias CramMetrics = Void
  alias CramBlockSliceHdr = Void
  alias CramBlockCompressionHdr = Void
  fun cram_fd_get_header(fd : CramFd) : SamHdrT*
  type CramFd = Void*

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
  fun cram_fd_set_header(fd : CramFd, hdr : SamHdrT*)
  fun cram_fd_get_version(fd : CramFd) : LibC::Int
  fun cram_fd_set_version(fd : CramFd, vers : LibC::Int)
  fun cram_major_vers(fd : CramFd) : LibC::Int
  fun cram_minor_vers(fd : CramFd) : LibC::Int
  fun cram_fd_get_fp(fd : CramFd) : HFile*
  alias HFile = Void
  fun cram_fd_set_fp(fd : CramFd, fp : HFile*)
  fun cram_container_get_length(c : CramContainer) : Int32T
  type CramContainer = Void*
  fun cram_container_set_length(c : CramContainer, length : Int32T)
  fun cram_container_get_num_blocks(c : CramContainer) : Int32T
  fun cram_container_set_num_blocks(c : CramContainer, num_blocks : Int32T)
  fun cram_container_get_landmarks(c : CramContainer, num_landmarks : Int32T*) : Int32T*
  fun cram_container_set_landmarks(c : CramContainer, num_landmarks : Int32T, landmarks : Int32T*)
  fun cram_container_is_empty(fd : CramFd) : LibC::Int
  fun cram_block_get_content_id(b : CramBlock) : Int32T
  type CramBlock = Void*
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
  fun cram_block_size(b : CramBlock) : Uint32T
  fun cram_transcode_rg(in : CramFd, out : CramFd, c : CramContainer, nrg : LibC::Int, in_rg : LibC::Int*, out_rg : LibC::Int*) : LibC::Int
  fun cram_copy_slice(in : CramFd, out : CramFd, num_slice : Int32T) : LibC::Int
  fun cram_new_block(content_type : CramContentType, content_id : LibC::Int) : CramBlock
  fun cram_read_block(fd : CramFd) : CramBlock
  fun cram_write_block(fd : CramFd, b : CramBlock) : LibC::Int
  fun cram_free_block(b : CramBlock)
  fun cram_uncompress_block(b : CramBlock) : LibC::Int
  fun cram_compress_block(fd : CramFd, b : CramBlock, metrics : CramMetrics, method : LibC::Int, level : LibC::Int) : LibC::Int
  type CramMetrics = Void*
  fun cram_new_container(nrec : LibC::Int, nslice : LibC::Int) : CramContainer
  fun cram_free_container(c : CramContainer)
  fun cram_read_container(fd : CramFd) : CramContainer
  fun cram_write_container(fd : CramFd, h : CramContainer) : LibC::Int
  fun cram_store_container(fd : CramFd, c : CramContainer, dat : LibC::Char*, size : LibC::Int*) : LibC::Int
  fun cram_container_size(c : CramContainer) : LibC::Int
  fun cram_open(filename : LibC::Char*, mode : LibC::Char*) : CramFd
  fun cram_dopen(fp : HFile*, filename : LibC::Char*, mode : LibC::Char*) : CramFd
  fun cram_close(fd : CramFd) : LibC::Int
  fun cram_seek(fd : CramFd, offset : OffT, whence : LibC::Int) : LibC::Int
  alias X__OffT = LibC::Long
  alias OffT = X__OffT
  fun cram_flush(fd : CramFd) : LibC::Int
  fun cram_eof(fd : CramFd) : LibC::Int
  fun cram_set_option(fd : CramFd, opt : HtsFmtOption, ...) : LibC::Int
  enum HtsFmtOption
    CramOptDecodeMd           =   0
    CramOptPrefix             =   1
    CramOptVerbosity          =   2
    CramOptSeqsPerSlice       =   3
    CramOptSlicesPerContainer =   4
    CramOptRange              =   5
    CramOptVersion            =   6
    CramOptEmbedRef           =   7
    CramOptIgnoreMd5          =   8
    CramOptReference          =   9
    CramOptMultiSeqPerSlice   =  10
    CramOptNoRef              =  11
    CramOptUseBzip2           =  12
    CramOptSharedRef          =  13
    CramOptNthreads           =  14
    CramOptThreadPool         =  15
    CramOptUseLzma            =  16
    CramOptUseRans            =  17
    CramOptRequiredFields     =  18
    CramOptLossyNames         =  19
    CramOptBasesPerSlice      =  20
    CramOptStoreMd            =  21
    CramOptStoreNm            =  22
    CramOptRangeNoseek        =  23
    HtsOptCompressionLevel    = 100
    HtsOptNthreads            = 101
    HtsOptThreadPool          = 102
    HtsOptCacheSize           = 103
    HtsOptBlockSize           = 104
  end
  fun cram_set_voption(fd : CramFd, opt : HtsFmtOption, args : VaList) : LibC::Int
  alias X__GnucVaList = LibC::VaList
  alias VaList = X__GnucVaList
  fun cram_set_header(fd : CramFd, hdr : SamHdrT*) : LibC::Int
  fun cram_check_eof = cram_check_EOF(fd : CramFd) : LibC::Int
  fun cram_get_refs(fd : HtsFile*) : RefsT

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
  type RefsT = Void*
end
