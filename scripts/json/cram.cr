struct Timeval
  tv_sec : 
  tv_usec : 
end

struct Timespec
  tv_sec : 
  tv_nsec : 
end






struct RandomData
  fptr : 
  rptr : 
  state : 
  rand_type : Int32
  rand_deg : Int32
  rand_sep : Int32
  end_ptr : 
end

struct Drand48Data
  __x : 
  __old_x : 
  __c : UShort
  __init : UShort
  __a : ULongLong
end












struct KstringT
  l : SizeT
  m : SizeT
  s : 
end

struct KsTokauxT
  tab : 
  sep : Int32
  finished : Int32
  p : 
end

struct BGZF
end

struct CramFd
end

struct HFILE
end

struct HtsTpool
end

struct SamHdrT
end

struct HtsFormat
  category : 
  format : 
  version : 
  compression : 
  compression_level : Short
  specific : 
end

struct HtsIdxT
end

struct HtsFilterT
end

struct HtsFile
  is_bin : 
  is_write : 
  is_be : 
  is_cram : 
  is_bgzf : 
  dummy : 
  lineno : Int64
  line : 
  fn : 
  fn_aux : 
  fp : 
  state : 
  format : 
  idx : 
  fnidx : 
  bam_header : 
  filter : 
end

struct HtsThreadPool
  pool : 
  qsize : Int32
end

struct HtsOpt
  arg : 
  opt : 
  val : 
  next : 
end

struct HtsPairPosT
  beg : 
  end : 
end

struct HtsPair64T
  u : UInt64
  v : UInt64
end

struct HtsPair64MaxT
  u : UInt64
  v : UInt64
  max : UInt64
end

struct HtsReglistT
  reg : 
  intervals : 
  tid : Int32
  count : UInt32
  min_beg : 
  max_end : 
end

struct HtsItrT
  read_rest : 
  finished : 
  is_cram : 
  nocoor : 
  multi : 
  dummy : 
  tid : Int32
  n_off : Int32
  i : Int32
  n_reg : Int32
  beg : 
  end : 
  reg_list : 
  curr_tid : Int32
  curr_reg : Int32
  curr_intv : Int32
  curr_beg : 
  curr_end : 
  curr_off : UInt64
  nocoor_off : UInt64
  off : 
  readrec : 
  seek : 
  tell : 
  bins : 
end

struct ErrmodT
end

struct ProbalnParT
  d : Float32
  e : Float32
  bw : Int32
end

struct HtsMd5Context
end

struct SamHrecsT
end

struct SamHdrT
  n_targets : Int32
  ignore_sam_err : Int32
  l_text : SizeT
  target_len : 
  cigar_tab : 
  target_name : 
  text : 
  sdict : 
  hrecs : 
  ref_count : UInt32
end

struct Bam1CoreT
  pos : 
  tid : Int32
  bin : UInt16
  qual : UInt8
  l_extranul : UInt8
  flag : UInt16
  l_qname : UInt16
  n_cigar : UInt32
  l_qseq : Int32
  mtid : Int32
  mpos : 
  isize : 
end

struct Bam1T
  core : 
  id : UInt64
  data : 
  l_data : Int32
  m_data : UInt32
  mempolicy : 
   : 
end

struct HtsFilterT
end

struct BamPileup1T
  b : 
  qpos : Int32
  indel : Int32
  level : Int32
  is_del : 
  is_head : 
  is_tail : 
  is_refskip : 
   : 
  aux : 
  cd : 
  cigar_ind : Int32
end

struct BamPlpS
end

struct BamMplpS
end

struct CramFileDef
end

struct CramContainer
end

struct CramBlock
end

struct CramSlice
end

struct CramMetrics
end

struct CramBlockSliceHdr
end

struct CramBlockCompressionHdr
end

struct RefsT
end

struct HFILE
end
# fun __bswap_16(UInt16) : UInt16
fun __bswap_32(UInt32) : UInt32
fun __bswap_64(UInt64) : UInt64
fun __uint16_identity(UInt16) : UInt16
fun __uint32_identity(UInt32) : UInt32
fun __uint64_identity(UInt64) : UInt64
# fun select(Int32, *, *, *, *) : Int32
# fun pselect(Int32, *, *, *, *, *) : Int32
# fun imaxabs() : 
# fun imaxdiv(, ) : 
# fun strtoimax(UInt8*, UInt8**, Int32) : 
# fun strtoumax(UInt8*, UInt8**, Int32) : 
# fun wcstoimax(*, **, Int32) : 
# fun wcstoumax(*, **, Int32) : 
# fun hts_set_log_level() : Void
# fun hts_get_log_level() : 
# fun hts_log(, UInt8*, UInt8*) : Void
fun __ctype_get_mb_cur_max() : SizeT
fun atof(UInt8*) : Float64
fun atoi(UInt8*) : Int32
fun atol(UInt8*) : Long
fun atoll(UInt8*) : LongLong
fun strtod(UInt8*, UInt8**) : Float64
fun strtof(UInt8*, UInt8**) : Float32
# fun strtold(UInt8*, UInt8**) : 
fun strtol(UInt8*, UInt8**, Int32) : Long
fun strtoul(UInt8*, UInt8**, Int32) : ULong
fun strtoq(UInt8*, UInt8**, Int32) : LongLong
fun strtouq(UInt8*, UInt8**, Int32) : ULongLong
fun strtoll(UInt8*, UInt8**, Int32) : LongLong
fun strtoull(UInt8*, UInt8**, Int32) : ULongLong
fun l64a(Long) : UInt8*
fun a64l(UInt8*) : Long
fun random() : Long
fun srandom(UInt32) : Void
fun initstate(UInt32, UInt8*, SizeT) : UInt8*
fun setstate(UInt8*) : UInt8*
# fun random_r(*, Int32*) : Int32
# fun srandom_r(UInt32, *) : Int32
# fun initstate_r(UInt32, UInt8*, SizeT, *) : Int32
# fun setstate_r(UInt8*, *) : Int32
fun rand() : Int32
fun srand(UInt32) : Void
fun rand_r(UInt32*) : Int32
fun drand48() : Float64
# fun erand48() : Float64
fun lrand48() : Long
# fun nrand48() : Long
fun mrand48() : Long
# fun jrand48() : Long
fun srand48(Long) : Void
# fun seed48() : UShort*
# fun lcong48() : Void
# fun drand48_r(*, Float64*) : Int32
# fun erand48_r(, *, Float64*) : Int32
# fun lrand48_r(*, Long*) : Int32
# fun nrand48_r(, *, Long*) : Int32
# fun mrand48_r(*, Long*) : Int32
# fun jrand48_r(, *, Long*) : Int32
# fun srand48_r(Long, *) : Int32
# fun seed48_r(, *) : Int32
# fun lcong48_r(, *) : Int32
fun malloc(SizeT) : Void*
fun calloc(SizeT, SizeT) : Void*
fun realloc(Void*, SizeT) : Void*
fun reallocarray(Void*, SizeT, SizeT) : Void*
fun free(Void*) : Void
fun alloca(SizeT) : Void*
fun valloc(SizeT) : Void*
fun posix_memalign(Void**, SizeT, SizeT) : Int32
fun aligned_alloc(SizeT, SizeT) : Void*
fun abort() : Void
# fun atexit() : Int32
# fun at_quick_exit() : Int32
# fun on_exit(, Void*) : Int32
fun exit(Int32) : Void
fun quick_exit(Int32) : Void
fun _Exit(Int32) : Void
fun getenv(UInt8*) : UInt8*
fun putenv(UInt8*) : Int32
fun setenv(UInt8*, UInt8*, Int32) : Int32
fun unsetenv(UInt8*) : Int32
fun clearenv() : Int32
fun mktemp(UInt8*) : UInt8*
fun mkstemp(UInt8*) : Int32
fun mkstemps(UInt8*, Int32) : Int32
fun mkdtemp(UInt8*) : UInt8*
fun system(UInt8*) : Int32
fun realpath(UInt8*, UInt8*) : UInt8*
# fun bsearch(Void*, Void*, SizeT, SizeT, ) : Void*
# fun qsort(Void*, SizeT, SizeT, ) : Void
fun abs(Int32) : Int32
fun labs(Long) : Long
fun llabs(LongLong) : LongLong
# fun div(Int32, Int32) : 
# fun ldiv(Long, Long) : 
# fun lldiv(LongLong, LongLong) : 
fun ecvt(Float64, Int32, Int32*, Int32*) : UInt8*
fun fcvt(Float64, Int32, Int32*, Int32*) : UInt8*
fun gcvt(Float64, Int32, UInt8*) : UInt8*
# fun qecvt(, Int32, Int32*, Int32*) : UInt8*
# fun qfcvt(, Int32, Int32*, Int32*) : UInt8*
# fun qgcvt(, Int32, UInt8*) : UInt8*
fun ecvt_r(Float64, Int32, Int32*, Int32*, UInt8*, SizeT) : Int32
fun fcvt_r(Float64, Int32, Int32*, Int32*, UInt8*, SizeT) : Int32
# fun qecvt_r(, Int32, Int32*, Int32*, UInt8*, SizeT) : Int32
# fun qfcvt_r(, Int32, Int32*, Int32*, UInt8*, SizeT) : Int32
fun mblen(UInt8*, SizeT) : Int32
# fun mbtowc(*, UInt8*, SizeT) : Int32
# fun wctomb(UInt8*, ) : Int32
# fun mbstowcs(*, UInt8*, SizeT) : SizeT
# fun wcstombs(UInt8*, *, SizeT) : SizeT
fun rpmatch(UInt8*) : Int32
fun getsubopt(UInt8**, UInt8**, UInt8**) : Int32
fun getloadavg(Float64*, Int32) : Int32
fun memcpy(Void*, Void*, SizeT) : Void*
fun memmove(Void*, Void*, SizeT) : Void*
fun memccpy(Void*, Void*, Int32, SizeT) : Void*
fun memset(Void*, Int32, SizeT) : Void*
fun memcmp(Void*, Void*, SizeT) : Int32
fun memchr(Void*, Int32, SizeT) : Void*
fun strcpy(UInt8*, UInt8*) : UInt8*
fun strncpy(UInt8*, UInt8*, SizeT) : UInt8*
fun strcat(UInt8*, UInt8*) : UInt8*
fun strncat(UInt8*, UInt8*, SizeT) : UInt8*
fun strcmp(UInt8*, UInt8*) : Int32
fun strncmp(UInt8*, UInt8*, SizeT) : Int32
fun strcoll(UInt8*, UInt8*) : Int32
fun strxfrm(UInt8*, UInt8*, SizeT) : ULong
# fun strcoll_l(UInt8*, UInt8*, ) : Int32
# fun strxfrm_l(UInt8*, UInt8*, SizeT, ) : SizeT
fun strdup(UInt8*) : UInt8*
fun strndup(UInt8*, SizeT) : UInt8*
fun strchr(UInt8*, Int32) : UInt8*
fun strrchr(UInt8*, Int32) : UInt8*
fun strcspn(UInt8*, UInt8*) : ULong
fun strspn(UInt8*, UInt8*) : ULong
fun strpbrk(UInt8*, UInt8*) : UInt8*
fun strstr(UInt8*, UInt8*) : UInt8*
fun strtok(UInt8*, UInt8*) : UInt8*
fun __strtok_r(UInt8*, UInt8*, UInt8**) : UInt8*
fun strtok_r(UInt8*, UInt8*, UInt8**) : UInt8*
fun strlen(UInt8*) : ULong
fun strnlen(UInt8*, SizeT) : SizeT
fun strerror(Int32) : UInt8*
fun __xpg_strerror_r(Int32, UInt8*, SizeT) : Int32
# fun strerror_l(Int32, ) : UInt8*
fun bcmp(Void*, Void*, SizeT) : Int32
fun bcopy(Void*, Void*, SizeT) : Void
fun bzero(Void*, SizeT) : Void
fun index(UInt8*, Int32) : UInt8*
fun rindex(UInt8*, Int32) : UInt8*
fun ffs(Int32) : Int32
fun ffsl(Long) : Int32
fun ffsll(LongLong) : Int32
fun strcasecmp(UInt8*, UInt8*) : Int32
fun strncasecmp(UInt8*, UInt8*, SizeT) : Int32
# fun strcasecmp_l(UInt8*, UInt8*, ) : Int32
# fun strncasecmp_l(UInt8*, UInt8*, SizeT, ) : Int32
fun explicit_bzero(Void*, SizeT) : Void
fun strsep(UInt8**, UInt8*) : UInt8*
fun strsignal(Int32) : UInt8*
fun __stpcpy(UInt8*, UInt8*) : UInt8*
fun stpcpy(UInt8*, UInt8*) : UInt8*
fun __stpncpy(UInt8*, UInt8*, SizeT) : UInt8*
fun stpncpy(UInt8*, UInt8*, SizeT) : UInt8*
fun remove(UInt8*) : Int32
fun rename(UInt8*, UInt8*) : Int32
fun renameat(Int32, UInt8*, Int32, UInt8*) : Int32
# fun tmpfile() : *
fun tmpnam(UInt8*) : UInt8*
fun tmpnam_r(UInt8*) : UInt8*
fun tempnam(UInt8*, UInt8*) : UInt8*
# fun fclose(*) : Int32
# fun fflush(*) : Int32
# fun fflush_unlocked(*) : Int32
# fun fopen(UInt8*, UInt8*) : *
# fun freopen(UInt8*, UInt8*, *) : *
# fun fdopen(Int32, UInt8*) : *
# fun fmemopen(Void*, SizeT, UInt8*) : *
# fun open_memstream(UInt8**, SizeT*) : *
# fun setbuf(*, UInt8*) : Void
# fun setvbuf(*, UInt8*, Int32, SizeT) : Int32
# fun setbuffer(*, UInt8*, SizeT) : Void
# fun setlinebuf(*) : Void
# fun fprintf(*, UInt8*) : Int32
fun printf(UInt8*) : Int32
fun sprintf(UInt8*, UInt8*) : Int32
# fun vfprintf(*, UInt8*, ) : Int32
# fun vprintf(UInt8*, ) : Int32
# fun vsprintf(UInt8*, UInt8*, ) : Int32
fun snprintf(UInt8*, SizeT, UInt8*) : Int32
# fun vsnprintf(UInt8*, SizeT, UInt8*, ) : Int32
# fun vdprintf(Int32, UInt8*, ) : Int32
fun dprintf(Int32, UInt8*) : Int32
# fun fscanf(*, UInt8*) : Int32
fun scanf(UInt8*) : Int32
fun sscanf(UInt8*, UInt8*) : Int32
# fun __isoc99_fscanf(*, UInt8*) : Int32
fun __isoc99_scanf(UInt8*) : Int32
fun __isoc99_sscanf(UInt8*, UInt8*) : Int32
# fun vfscanf(*, UInt8*, ) : Int32
# fun vscanf(UInt8*, ) : Int32
# fun vsscanf(UInt8*, UInt8*, ) : Int32
# fun __isoc99_vfscanf(*, UInt8*, ) : Int32
# fun __isoc99_vscanf(UInt8*, ) : Int32
# fun __isoc99_vsscanf(UInt8*, UInt8*, ) : Int32
# fun fgetc(*) : Int32
# fun getc(*) : Int32
fun getchar() : Int32
# fun getc_unlocked(*) : Int32
fun getchar_unlocked() : Int32
# fun fgetc_unlocked(*) : Int32
# fun fputc(Int32, *) : Int32
# fun putc(Int32, *) : Int32
fun putchar(Int32) : Int32
# fun fputc_unlocked(Int32, *) : Int32
# fun putc_unlocked(Int32, *) : Int32
fun putchar_unlocked(Int32) : Int32
# fun getw(*) : Int32
# fun putw(Int32, *) : Int32
# fun fgets(UInt8*, Int32, *) : UInt8*
# fun __getdelim(UInt8**, SizeT*, Int32, *) : SSizeT
# fun getdelim(UInt8**, SizeT*, Int32, *) : SSizeT
# fun getline(UInt8**, SizeT*, *) : SSizeT
# fun fputs(UInt8*, *) : Int32
fun puts(UInt8*) : Int32
# fun ungetc(Int32, *) : Int32
# fun fread(Void*, SizeT, SizeT, *) : ULong
# fun fwrite(Void*, SizeT, SizeT, *) : ULong
# fun fread_unlocked(Void*, SizeT, SizeT, *) : SizeT
# fun fwrite_unlocked(Void*, SizeT, SizeT, *) : SizeT
# fun fseek(*, Long, Int32) : Int32
# fun ftell(*) : Long
# fun rewind(*) : Void
# fun fseeko(*, , Int32) : Int32
# fun ftello(*) : 
# fun fgetpos(*, *) : Int32
# fun fsetpos(*, *) : Int32
# fun clearerr(*) : Void
# fun feof(*) : Int32
# fun ferror(*) : Int32
# fun clearerr_unlocked(*) : Void
# fun feof_unlocked(*) : Int32
# fun ferror_unlocked(*) : Int32
fun perror(UInt8*) : Void
# fun fileno(*) : Int32
# fun fileno_unlocked(*) : Int32
# fun popen(UInt8*, UInt8*) : *
# fun pclose(*) : Int32
fun ctermid(UInt8*) : UInt8*
# fun flockfile(*) : Void
# fun ftrylockfile(*) : Int32
# fun funlockfile(*) : Void
# fun __uflow(*) : Int32
# fun __overflow(*, Int32) : Int32
fun __errno_location() : Int32*
# fun kvsprintf(*, UInt8*, ) : Int32
# fun ksprintf(*, UInt8*) : Int32
# fun kputd(Float64, *) : Int32
fun ksplit_core(UInt8*, Int32, Int32*, Int32**) : Int32
fun kstrstr(UInt8*, UInt8*, Int32**) : UInt8*
fun kstrnstr(UInt8*, UInt8*, Int32, Int32**) : UInt8*
fun kmemmem(Void*, Int32, Void*, Int32, Int32**) : Void*
# fun kstrtok(UInt8*, UInt8*, *) : UInt8*
# fun kgetline(*, , Void*) : Int32
# fun kgetline2(*, , Void*) : Int32
# fun ks_initialize(*) : Void
# fun ks_resize(*, SizeT) : Int32
# fun ks_expand(*, SizeT) : Int32
# fun ks_str(*) : UInt8*
# fun ks_c_str(*) : UInt8*
# fun ks_len(*) : SizeT
# fun ks_clear(*) : *
# fun ks_release(*) : UInt8*
# fun ks_free(*) : Void
# fun kputsn(UInt8*, SizeT, *) : Int32
# fun kputs(UInt8*, *) : Int32
# fun kputc(Int32, *) : Int32
# fun kputc_(Int32, *) : Int32
# fun kputsn_(Void*, SizeT, *) : Int32
# fun kputuw(UInt32, *) : Int32
# fun kputw(Int32, *) : Int32
# fun kputll(LongLong, *) : Int32
# fun kputl(Long, *) : Int32
# fun ksplit(*, Int32, Int32*) : Int32*
fun hts_resize_array_(SizeT, SizeT, SizeT, Void*, Void**, Int32, UInt8*) : Int32
fun hts_lib_shutdown() : Void
fun hts_free(Void*) : Void
# fun hts_opt_add(**, UInt8*) : Int32
# fun hts_opt_apply(*, *) : Int32
# fun hts_opt_free(*) : Void
# fun hts_parse_format(*, UInt8*) : Int32
# fun hts_parse_opt_list(*, UInt8*) : Int32
fun hts_version() : UInt8*
fun hts_features() : UInt32
fun hts_test_feature(UInt32) : UInt8*
fun hts_feature_string() : UInt8*
# fun hts_detect_format(*, *) : Int32
# fun hts_format_description(*) : UInt8*
# fun hts_open(UInt8*, UInt8*) : *
# fun hts_open_format(UInt8*, UInt8*, *) : *
# fun hts_hopen(*, UInt8*, UInt8*) : *
# fun hts_close(*) : Int32
# fun hts_get_format(*) : *
# fun hts_format_file_extension(*) : UInt8*
# fun hts_set_opt(*, ) : Int32
# fun hts_getline(*, Int32, *) : Int32
# fun hts_readlines(UInt8*, Int32*) : *
# fun hts_readlist(UInt8*, Int32, Int32*) : *
# fun hts_set_threads(*, Int32) : Int32
# fun hts_set_thread_pool(*, *) : Int32
# fun hts_set_cache_size(*, Int32) : Void
# fun hts_set_fai_filename(*, UInt8*) : Int32
# fun hts_set_filter_expression(*, UInt8*) : Int32
# fun hts_check_EOF(*) : Int32
# fun hts_idx_init(Int32, Int32, UInt64, Int32, Int32) : *
# fun hts_idx_destroy(*) : Void
# fun hts_idx_push(*, Int32, , , UInt64, Int32) : Int32
# fun hts_idx_finish(*, UInt64) : Int32
# fun hts_idx_fmt(*) : Int32
# fun hts_idx_tbi_name(*, Int32, UInt8*) : Int32
# fun hts_idx_save(*, UInt8*, Int32) : Int32
# fun hts_idx_save_as(*, UInt8*, UInt8*, Int32) : Int32
# fun hts_idx_load(UInt8*, Int32) : *
# fun hts_idx_load2(UInt8*, UInt8*) : *
# fun hts_idx_load3(UInt8*, UInt8*, Int32, Int32) : *
# fun hts_idx_get_meta(*, UInt32*) : UInt8*
# fun hts_idx_set_meta(*, UInt32, UInt8*, Int32) : Int32
# fun hts_idx_get_stat(*, Int32, UInt64*, UInt64*) : Int32
# fun hts_idx_get_n_no_coor(*) : UInt64
fun hts_parse_decimal(UInt8*, UInt8**, Int32) : LongLong
# fun hts_parse_reg64(UInt8*, *, *) : UInt8*
fun hts_parse_reg(UInt8*, Int32*, Int32*) : UInt8*
# fun hts_parse_region(UInt8*, Int32*, *, *, , Void*, Int32) : UInt8*
# fun hts_itr_query(*, Int32, , , ) : *
# fun hts_itr_destroy(*) : Void
# fun hts_itr_querys(*, UInt8*, , Void*, , ) : *
# fun hts_itr_next(*, *, Void*, Void*) : Int32
# fun hts_idx_seqnames(*, Int32*, , Void*) : *
# fun hts_itr_multi_bam(*, *) : Int32
# fun hts_itr_multi_cram(*, *) : Int32
# fun hts_itr_regions(*, *, Int32, , Void*, , , , ) : *
# fun hts_itr_multi_next(*, *, Void*) : Int32
# fun hts_reglist_create(UInt8**, Int32, Int32*, Void*, ) : *
# fun hts_reglist_free(*, Int32) : Void
fun hts_file_type(UInt8*) : Int32
# fun errmod_init(Float64) : *
# fun errmod_destroy(*) : Void
# fun errmod_cal(*, Int32, Int32, UInt16*, Float32*) : Int32
# fun probaln_glocal(UInt8*, Int32, UInt8*, Int32, UInt8*, *, Int32*, UInt8*) : Int32
# fun hts_md5_init() : *
# fun hts_md5_update(*, Void*, ULong) : Void
# fun hts_md5_final(*, *) : Void
# fun hts_md5_reset(*) : Void
# fun hts_md5_hex(UInt8*, *) : Void
# fun hts_md5_destroy(*) : Void
# fun hts_reg2bin(, , Int32, Int32) : Int32
fun hts_bin_bot(Int32, Int32) : Int32
fun ed_is_big() : Int32
fun ed_swap_2(UInt16) : UInt16
fun ed_swap_2p(Void*) : Void*
fun ed_swap_4(UInt32) : UInt32
fun ed_swap_4p(Void*) : Void*
fun ed_swap_8(UInt64) : UInt64
fun ed_swap_8p(Void*) : Void*
fun le_to_u16(UInt8*) : UInt16
fun le_to_u32(UInt8*) : UInt32
fun le_to_u64(UInt8*) : UInt64
fun u16_to_le(UInt16, UInt8*) : Void
fun u32_to_le(UInt32, UInt8*) : Void
fun u64_to_le(UInt64, UInt8*) : Void
fun le_to_i8(UInt8*) : Int8
fun le_to_i16(UInt8*) : Int16
fun le_to_i32(UInt8*) : Int32
fun le_to_i64(UInt8*) : Int64
fun i16_to_le(Int16, UInt8*) : Void
fun i32_to_le(Int32, UInt8*) : Void
fun i64_to_le(Int64, UInt8*) : Void
fun le_to_float(UInt8*) : Float32
fun le_to_double(UInt8*) : Float64
fun float_to_le(Float32, UInt8*) : Void
fun double_to_le(Float64, UInt8*) : Void
# fun sam_hdr_init() : *
# fun bam_hdr_read(*) : *
# fun bam_hdr_write(*, *) : Int32
# fun sam_hdr_destroy(*) : Void
# fun sam_hdr_dup(*) : *
# fun bam_hdr_init() : *
# fun bam_hdr_destroy(*) : Void
# fun bam_hdr_dup(*) : *
# fun sam_hdr_parse(SizeT, UInt8*) : *
# fun sam_hdr_read(*) : *
# fun sam_hdr_write(*, *) : Int32
# fun sam_hdr_length(*) : SizeT
# fun sam_hdr_str(*) : UInt8*
# fun sam_hdr_nref(*) : Int32
# fun sam_hdr_add_lines(*, UInt8*, SizeT) : Int32
# fun sam_hdr_add_line(*, UInt8*) : Int32
# fun sam_hdr_find_line_id(*, UInt8*, UInt8*, UInt8*, *) : Int32
# fun sam_hdr_find_line_pos(*, UInt8*, Int32, *) : Int32
# fun sam_hdr_remove_line_id(*, UInt8*, UInt8*, UInt8*) : Int32
# fun sam_hdr_remove_line_pos(*, UInt8*, Int32) : Int32
# fun sam_hdr_update_line(*, UInt8*, UInt8*, UInt8*) : Int32
# fun sam_hdr_remove_except(*, UInt8*, UInt8*, UInt8*) : Int32
# fun sam_hdr_remove_lines(*, UInt8*, UInt8*, Void*) : Int32
# fun sam_hdr_count_lines(*, UInt8*) : Int32
# fun sam_hdr_line_index(*, UInt8*, UInt8*) : Int32
# fun sam_hdr_line_name(*, UInt8*, Int32) : UInt8*
# fun sam_hdr_find_tag_id(*, UInt8*, UInt8*, UInt8*, UInt8*, *) : Int32
# fun sam_hdr_find_tag_pos(*, UInt8*, Int32, UInt8*, *) : Int32
# fun sam_hdr_remove_tag_id(*, UInt8*, UInt8*, UInt8*, UInt8*) : Int32
# fun sam_hdr_name2tid(*, UInt8*) : Int32
# fun sam_hdr_tid2name(*, Int32) : UInt8*
# fun sam_hdr_tid2len(*, Int32) : 
# fun bam_name2id(*, UInt8*) : Int32
# fun sam_hdr_pg_id(*, UInt8*) : UInt8*
# fun sam_hdr_add_pg(*, UInt8*) : Int32
fun stringify_argv(Int32, UInt8**) : UInt8*
# fun sam_hdr_incr_ref(*) : Void
# fun bam_init1() : *
# fun bam_destroy1(*) : Void
# fun bam_set_mempolicy(*, UInt32) : Void
# fun bam_get_mempolicy(*) : UInt32
# fun bam_read1(*, *) : Int32
# fun bam_write1(*, *) : Int32
# fun bam_copy1(*, *) : *
# fun bam_dup1(*) : *
# fun bam_set1(*, SizeT, UInt8*, UInt16, Int32, , UInt8, SizeT, UInt32*, Int32, , , SizeT, UInt8*, UInt8*, SizeT) : Int32
# fun bam_cigar2qlen(Int32, UInt32*) : 
# fun bam_cigar2rlen(Int32, UInt32*) : 
# fun bam_endpos(*) : 
fun bam_str2flag(UInt8*) : Int32
fun bam_flag2str(Int32) : UInt8*
# fun bam_set_qname(*, UInt8*) : Int32
fun sam_parse_cigar(UInt8*, UInt8**, UInt32**, SizeT*) : SSizeT
# fun bam_parse_cigar(UInt8*, UInt8**, *) : SSizeT
# fun sam_idx_init(*, *, Int32, UInt8*) : Int32
# fun sam_idx_save(*) : Int32
# fun sam_index_load(*, UInt8*) : *
# fun sam_index_load2(*, UInt8*, UInt8*) : *
# fun sam_index_load3(*, UInt8*, UInt8*, Int32) : *
fun sam_index_build(UInt8*, Int32) : Int32
fun sam_index_build2(UInt8*, UInt8*, Int32) : Int32
fun sam_index_build3(UInt8*, UInt8*, Int32, Int32) : Int32
# fun sam_itr_queryi(*, Int32, , ) : *
# fun sam_itr_querys(*, *, UInt8*) : *
# fun sam_itr_regions(*, *, *, UInt32) : *
# fun sam_itr_regarray(*, *, UInt8**, UInt32) : *
# fun sam_itr_next(*, *, *) : Int32
# fun sam_parse_region(*, UInt8*, Int32*, *, *, Int32) : UInt8*
fun sam_open_mode(UInt8*, UInt8*, UInt8*) : Int32
fun sam_open_mode_opts(UInt8*, UInt8*, UInt8*) : UInt8*
# fun sam_hdr_change_HD(*, UInt8*, UInt8*) : Int32
# fun sam_parse1(*, *, *) : Int32
# fun sam_format1(*, *, *) : Int32
# fun sam_read1(*, *, *) : Int32
# fun sam_write1(*, *, *) : Int32
# fun sam_passes_filter(*, *, *) : Int32
# fun sam_format_aux1(UInt8*, UInt8, UInt8*, UInt8*, *) : UInt8*
# fun bam_aux_get(*, ) : UInt8*
# fun bam_aux_get_str(*, , *) : Int32
fun bam_aux2i(UInt8*) : Int64
fun bam_aux2f(UInt8*) : Float64
fun bam_aux2A(UInt8*) : UInt8
fun bam_aux2Z(UInt8*) : UInt8*
fun bam_auxB_len(UInt8*) : UInt32
fun bam_auxB2i(UInt8*, UInt32) : Int64
fun bam_auxB2f(UInt8*, UInt32) : Float64
# fun bam_aux_append(*, , UInt8, Int32, UInt8*) : Int32
# fun bam_aux_del(*, UInt8*) : Int32
# fun bam_aux_update_str(*, , Int32, UInt8*) : Int32
# fun bam_aux_update_int(*, , Int64) : Int32
# fun bam_aux_update_float(*, , Float32) : Int32
# fun bam_aux_update_array(*, , UInt8, UInt32, Void*) : Int32
# fun bam_plp_init(, Void*) : 
# fun bam_plp_destroy() : Void
# fun bam_plp_push(, *) : Int32
# fun bam_plp_next(, Int32*, Int32*, Int32*) : *
# fun bam_plp_auto(, Int32*, Int32*, Int32*) : *
# fun bam_plp64_next(, Int32*, *, Int32*) : *
# fun bam_plp64_auto(, Int32*, *, Int32*) : *
# fun bam_plp_set_maxcnt(, Int32) : Void
# fun bam_plp_reset() : Void
# fun bam_plp_constructor(, ) : Void
# fun bam_plp_destructor(, ) : Void
# fun bam_plp_insertion(*, *, Int32*) : Int32
# fun bam_mplp_init(Int32, , Void**) : 
# fun bam_mplp_init_overlaps() : Int32
# fun bam_mplp_destroy() : Void
# fun bam_mplp_set_maxcnt(, Int32) : Void
# fun bam_mplp_auto(, Int32*, Int32*, Int32*, **) : Int32
# fun bam_mplp64_auto(, Int32*, *, Int32*, **) : Int32
# fun bam_mplp_reset() : Void
# fun bam_mplp_constructor(, ) : Void
# fun bam_mplp_destructor(, ) : Void
# fun sam_cap_mapq(*, UInt8*, , Int32) : Int32
# fun sam_prob_realn(*, UInt8*, , Int32) : Int32
# fun cram_fd_get_header(*) : *
# fun cram_fd_set_header(*, *) : Void
# fun cram_fd_get_version(*) : Int32
# fun cram_fd_set_version(*, Int32) : Void
# fun cram_major_vers(*) : Int32
# fun cram_minor_vers(*) : Int32
# fun cram_fd_get_fp(*) : *
# fun cram_fd_set_fp(*, *) : Void
# fun cram_container_get_length(*) : Int32
# fun cram_container_set_length(*, Int32) : Void
# fun cram_container_get_num_blocks(*) : Int32
# fun cram_container_set_num_blocks(*, Int32) : Void
# fun cram_container_get_landmarks(*, Int32*) : Int32*
# fun cram_container_set_landmarks(*, Int32, Int32*) : Void
# fun cram_container_is_empty(*) : Int32
# fun cram_block_get_content_id(*) : Int32
# fun cram_block_get_comp_size(*) : Int32
# fun cram_block_get_uncomp_size(*) : Int32
# fun cram_block_get_crc32(*) : Int32
# fun cram_block_get_data(*) : Void*
# fun cram_block_get_content_type(*) : 
# fun cram_block_set_content_id(*, Int32) : Void
# fun cram_block_set_comp_size(*, Int32) : Void
# fun cram_block_set_uncomp_size(*, Int32) : Void
# fun cram_block_set_crc32(*, Int32) : Void
# fun cram_block_set_data(*, Void*) : Void
# fun cram_block_append(*, Void*, Int32) : Int32
# fun cram_block_update_size(*) : Void
# fun cram_block_get_offset(*) : SizeT
# fun cram_block_set_offset(*, SizeT) : Void
# fun cram_block_size(*) : UInt32
# fun cram_transcode_rg(*, *, *, Int32, Int32*, Int32*) : Int32
# fun cram_copy_slice(*, *, Int32) : Int32
# fun cram_new_block(, Int32) : *
# fun cram_read_block(*) : *
# fun cram_write_block(*, *) : Int32
# fun cram_free_block(*) : Void
# fun cram_uncompress_block(*) : Int32
# fun cram_compress_block(*, *, *, Int32, Int32) : Int32
# fun cram_compress_block2(*, *, *, *, Int32, Int32) : Int32
# fun cram_new_container(Int32, Int32) : *
# fun cram_free_container(*) : Void
# fun cram_read_container(*) : *
# fun cram_write_container(*, *) : Int32
# fun cram_store_container(*, *, UInt8*, Int32*) : Int32
# fun cram_container_size(*) : Int32
# fun cram_open(UInt8*, UInt8*) : *
# fun cram_dopen(*, UInt8*, UInt8*) : *
# fun cram_close(*) : Int32
# fun cram_seek(*, , Int32) : Int32
# fun cram_flush(*) : Int32
# fun cram_eof(*) : Int32
# fun cram_set_option(*, ) : Int32
# fun cram_set_voption(*, , ) : Int32
# fun cram_set_header(*, *) : Int32
# fun cram_check_EOF(*) : Int32
# fun int32_put_blk(*, Int32) : Int32
# fun sam_hdr_parse_(UInt8*, SizeT) : *
# fun sam_hdr_free(*) : Void
# fun cram_get_refs(*) : *

# Unknown types
# ["__time_t", "__suseconds_t", "__syscall_slong_t", ":pointer", ":array", ":enum", "struct", ":bitfield", "kstring_t", "union", "htsFormat", "hts_pos_t", ":function-pointer", "bam1_core_t", "bam_pileup_cd", "fd_set", ":struct", "__sigset_t", "intmax_t", "imaxdiv_t", "uintmax_t", "__gwchar_t", ":long-double", "__compar_fn_t", "div_t", "ldiv_t", "lldiv_t", "wchar_t", "locale_t", "FILE", "__gnuc_va_list", "__off_t", "fpos_t", "va_list", "ks_tokaux_t", "hts_opt", "htsFile", "htsThreadPool", "hts_idx_t", "hts_name2id_f", "hts_itr_t", "BGZF", "hts_id2name_f", "hts_reglist_t", "errmod_t", "probaln_par_t", "hts_md5_context", ":unsigned-char", "sam_hdr_t", "samFile", "bam1_t", "bam_plp_auto_f", "bam_plp_t", "bam_pileup1_t", "bam_mplp_t", "cram_fd", "cram_container", "cram_block", "cram_metrics", "cram_slice", "off_t", "SAM_hdr", "refs_t"]
# timeval, __time_t
# timeval, __suseconds_t
# timespec, __time_t
# timespec, __syscall_slong_t
# random_data, :pointer
# random_data, :pointer
# random_data, :pointer
# random_data, :pointer
# drand48_data, :array
# drand48_data, :array
# kstring_t, :pointer
# ks_tokaux_t, :array
# ks_tokaux_t, :pointer
# htsFormat, :enum
# htsFormat, :enum
# htsFormat, struct
# htsFormat, :enum
# htsFormat, :pointer
# htsFile, :bitfield
# htsFile, :bitfield
# htsFile, :bitfield
# htsFile, :bitfield
# htsFile, :bitfield
# htsFile, :bitfield
# htsFile, kstring_t
# htsFile, :pointer
# htsFile, :pointer
# htsFile, union
# htsFile, :pointer
# htsFile, htsFormat
# htsFile, :pointer
# htsFile, :pointer
# htsFile, :pointer
# htsFile, :pointer
# htsThreadPool, :pointer
# hts_opt, :pointer
# hts_opt, :enum
# hts_opt, union
# hts_opt, :pointer
# hts_pair_pos_t, hts_pos_t
# hts_pair_pos_t, hts_pos_t
# hts_reglist_t, :pointer
# hts_reglist_t, :pointer
# hts_reglist_t, hts_pos_t
# hts_reglist_t, hts_pos_t
# hts_itr_t, :bitfield
# hts_itr_t, :bitfield
# hts_itr_t, :bitfield
# hts_itr_t, :bitfield
# hts_itr_t, :bitfield
# hts_itr_t, :bitfield
# hts_itr_t, hts_pos_t
# hts_itr_t, hts_pos_t
# hts_itr_t, :pointer
# hts_itr_t, hts_pos_t
# hts_itr_t, hts_pos_t
# hts_itr_t, :pointer
# hts_itr_t, :function-pointer
# hts_itr_t, :function-pointer
# hts_itr_t, :function-pointer
# hts_itr_t, struct
# sam_hdr_t, :pointer
# sam_hdr_t, :pointer
# sam_hdr_t, :pointer
# sam_hdr_t, :pointer
# sam_hdr_t, :pointer
# sam_hdr_t, :pointer
# bam1_core_t, hts_pos_t
# bam1_core_t, hts_pos_t
# bam1_core_t, hts_pos_t
# bam1_t, bam1_core_t
# bam1_t, :pointer
# bam1_t, :bitfield
# bam1_t, :bitfield
# bam_pileup1_t, :pointer
# bam_pileup1_t, :bitfield
# bam_pileup1_t, :bitfield
# bam_pileup1_t, :bitfield
# bam_pileup1_t, :bitfield
# bam_pileup1_t, :bitfield
# bam_pileup1_t, :bitfield
# bam_pileup1_t, bam_pileup_cd
# select, fd_set
# select, fd_set
# select, fd_set
# select, :struct
# pselect, fd_set
# pselect, fd_set
# pselect, fd_set
# pselect, :struct
# pselect, __sigset_t
# imaxabs, intmax_t
# imaxabs, intmax_t
# imaxdiv, intmax_t
# imaxdiv, intmax_t
# imaxdiv, imaxdiv_t
# strtoimax, intmax_t
# strtoumax, uintmax_t
# wcstoimax, __gwchar_t
# wcstoimax, __gwchar_t
# wcstoimax, intmax_t
# wcstoumax, __gwchar_t
# wcstoumax, __gwchar_t
# wcstoumax, uintmax_t
# hts_set_log_level, :enum
# hts_get_log_level, :enum
# hts_log, :enum
# strtold, :long-double
# random_r, :struct
# srandom_r, :struct
# initstate_r, :struct
# setstate_r, :struct
# erand48, :array
# nrand48, :array
# jrand48, :array
# seed48, :array
# lcong48, :array
# drand48_r, :struct
# erand48_r, :array
# erand48_r, :struct
# lrand48_r, :struct
# nrand48_r, :array
# nrand48_r, :struct
# mrand48_r, :struct
# jrand48_r, :array
# jrand48_r, :struct
# srand48_r, :struct
# seed48_r, :array
# seed48_r, :struct
# lcong48_r, :array
# lcong48_r, :struct
# atexit, :function-pointer
# at_quick_exit, :function-pointer
# on_exit, :function-pointer
# bsearch, __compar_fn_t
# qsort, __compar_fn_t
# div, div_t
# ldiv, ldiv_t
# lldiv, lldiv_t
# qecvt, :long-double
# qfcvt, :long-double
# qgcvt, :long-double
# qecvt_r, :long-double
# qfcvt_r, :long-double
# mbtowc, wchar_t
# wctomb, wchar_t
# mbstowcs, wchar_t
# wcstombs, wchar_t
# strcoll_l, locale_t
# strxfrm_l, locale_t
# strerror_l, locale_t
# strcasecmp_l, locale_t
# strncasecmp_l, locale_t
# tmpfile, FILE
# fclose, FILE
# fflush, FILE
# fflush_unlocked, FILE
# fopen, FILE
# freopen, FILE
# freopen, FILE
# fdopen, FILE
# fmemopen, FILE
# open_memstream, FILE
# setbuf, FILE
# setvbuf, FILE
# setbuffer, FILE
# setlinebuf, FILE
# fprintf, FILE
# vfprintf, FILE
# vfprintf, __gnuc_va_list
# vprintf, __gnuc_va_list
# vsprintf, __gnuc_va_list
# vsnprintf, __gnuc_va_list
# vdprintf, __gnuc_va_list
# fscanf, FILE
# __isoc99_fscanf, FILE
# vfscanf, FILE
# vfscanf, __gnuc_va_list
# vscanf, __gnuc_va_list
# vsscanf, __gnuc_va_list
# __isoc99_vfscanf, FILE
# __isoc99_vfscanf, __gnuc_va_list
# __isoc99_vscanf, __gnuc_va_list
# __isoc99_vsscanf, __gnuc_va_list
# fgetc, FILE
# getc, FILE
# getc_unlocked, FILE
# fgetc_unlocked, FILE
# fputc, FILE
# putc, FILE
# fputc_unlocked, FILE
# putc_unlocked, FILE
# getw, FILE
# putw, FILE
# fgets, FILE
# __getdelim, FILE
# getdelim, FILE
# getline, FILE
# fputs, FILE
# ungetc, FILE
# fread, FILE
# fwrite, FILE
# fread_unlocked, FILE
# fwrite_unlocked, FILE
# fseek, FILE
# ftell, FILE
# rewind, FILE
# fseeko, FILE
# fseeko, __off_t
# ftello, FILE
# ftello, __off_t
# fgetpos, FILE
# fgetpos, fpos_t
# fsetpos, FILE
# fsetpos, fpos_t
# clearerr, FILE
# feof, FILE
# ferror, FILE
# clearerr_unlocked, FILE
# feof_unlocked, FILE
# ferror_unlocked, FILE
# fileno, FILE
# fileno_unlocked, FILE
# popen, FILE
# pclose, FILE
# flockfile, FILE
# ftrylockfile, FILE
# funlockfile, FILE
# __uflow, FILE
# __overflow, FILE
# kvsprintf, kstring_t
# kvsprintf, va_list
# ksprintf, kstring_t
# kputd, kstring_t
# kstrtok, ks_tokaux_t
# kgetline, kstring_t
# kgetline, :function-pointer
# kgetline2, kstring_t
# kgetline2, :function-pointer
# ks_initialize, kstring_t
# ks_resize, kstring_t
# ks_expand, kstring_t
# ks_str, kstring_t
# ks_c_str, kstring_t
# ks_len, kstring_t
# ks_clear, kstring_t
# ks_clear, kstring_t
# ks_release, kstring_t
# ks_free, kstring_t
# kputsn, kstring_t
# kputs, kstring_t
# kputc, kstring_t
# kputc_, kstring_t
# kputsn_, kstring_t
# kputuw, kstring_t
# kputw, kstring_t
# kputll, kstring_t
# kputl, kstring_t
# ksplit, kstring_t
# hts_opt_add, hts_opt
# hts_opt_apply, htsFile
# hts_opt_apply, hts_opt
# hts_opt_free, hts_opt
# hts_parse_format, htsFormat
# hts_parse_opt_list, htsFormat
# hts_detect_format, struct
# hts_detect_format, htsFormat
# hts_format_description, htsFormat
# hts_open, htsFile
# hts_open_format, htsFormat
# hts_open_format, htsFile
# hts_hopen, struct
# hts_hopen, htsFile
# hts_close, htsFile
# hts_get_format, htsFile
# hts_get_format, htsFormat
# hts_format_file_extension, htsFormat
# hts_set_opt, htsFile
# hts_set_opt, :enum
# hts_getline, htsFile
# hts_getline, kstring_t
# hts_readlines, :pointer
# hts_readlist, :pointer
# hts_set_threads, htsFile
# hts_set_thread_pool, htsFile
# hts_set_thread_pool, htsThreadPool
# hts_set_cache_size, htsFile
# hts_set_fai_filename, htsFile
# hts_set_filter_expression, htsFile
# hts_check_EOF, htsFile
# hts_idx_init, hts_idx_t
# hts_idx_destroy, hts_idx_t
# hts_idx_push, hts_idx_t
# hts_idx_push, hts_pos_t
# hts_idx_push, hts_pos_t
# hts_idx_finish, hts_idx_t
# hts_idx_fmt, hts_idx_t
# hts_idx_tbi_name, hts_idx_t
# hts_idx_save, hts_idx_t
# hts_idx_save_as, hts_idx_t
# hts_idx_load, hts_idx_t
# hts_idx_load2, hts_idx_t
# hts_idx_load3, hts_idx_t
# hts_idx_get_meta, hts_idx_t
# hts_idx_set_meta, hts_idx_t
# hts_idx_get_stat, hts_idx_t
# hts_idx_get_n_no_coor, hts_idx_t
# hts_parse_reg64, hts_pos_t
# hts_parse_reg64, hts_pos_t
# hts_parse_region, hts_pos_t
# hts_parse_region, hts_pos_t
# hts_parse_region, hts_name2id_f
# hts_itr_query, hts_idx_t
# hts_itr_query, hts_pos_t
# hts_itr_query, hts_pos_t
# hts_itr_query, :function-pointer
# hts_itr_query, hts_itr_t
# hts_itr_destroy, hts_itr_t
# hts_itr_querys, hts_idx_t
# hts_itr_querys, hts_name2id_f
# hts_itr_querys, :function-pointer
# hts_itr_querys, :function-pointer
# hts_itr_querys, hts_itr_t
# hts_itr_next, BGZF
# hts_itr_next, hts_itr_t
# hts_idx_seqnames, hts_idx_t
# hts_idx_seqnames, hts_id2name_f
# hts_idx_seqnames, :pointer
# hts_itr_multi_bam, hts_idx_t
# hts_itr_multi_bam, hts_itr_t
# hts_itr_multi_cram, hts_idx_t
# hts_itr_multi_cram, hts_itr_t
# hts_itr_regions, hts_idx_t
# hts_itr_regions, hts_reglist_t
# hts_itr_regions, hts_name2id_f
# hts_itr_regions, :function-pointer
# hts_itr_regions, :function-pointer
# hts_itr_regions, :function-pointer
# hts_itr_regions, :function-pointer
# hts_itr_regions, hts_itr_t
# hts_itr_multi_next, htsFile
# hts_itr_multi_next, hts_itr_t
# hts_reglist_create, hts_name2id_f
# hts_reglist_create, hts_reglist_t
# hts_reglist_free, hts_reglist_t
# errmod_init, errmod_t
# errmod_destroy, errmod_t
# errmod_cal, errmod_t
# probaln_glocal, probaln_par_t
# hts_md5_init, hts_md5_context
# hts_md5_update, hts_md5_context
# hts_md5_final, :unsigned-char
# hts_md5_final, hts_md5_context
# hts_md5_reset, hts_md5_context
# hts_md5_hex, :unsigned-char
# hts_md5_destroy, hts_md5_context
# hts_reg2bin, hts_pos_t
# hts_reg2bin, hts_pos_t
# sam_hdr_init, sam_hdr_t
# bam_hdr_read, BGZF
# bam_hdr_read, sam_hdr_t
# bam_hdr_write, BGZF
# bam_hdr_write, sam_hdr_t
# sam_hdr_destroy, sam_hdr_t
# sam_hdr_dup, sam_hdr_t
# sam_hdr_dup, sam_hdr_t
# bam_hdr_init, sam_hdr_t
# bam_hdr_destroy, sam_hdr_t
# bam_hdr_dup, sam_hdr_t
# bam_hdr_dup, sam_hdr_t
# sam_hdr_parse, sam_hdr_t
# sam_hdr_read, samFile
# sam_hdr_read, sam_hdr_t
# sam_hdr_write, samFile
# sam_hdr_write, sam_hdr_t
# sam_hdr_length, sam_hdr_t
# sam_hdr_str, sam_hdr_t
# sam_hdr_nref, sam_hdr_t
# sam_hdr_add_lines, sam_hdr_t
# sam_hdr_add_line, sam_hdr_t
# sam_hdr_find_line_id, sam_hdr_t
# sam_hdr_find_line_id, kstring_t
# sam_hdr_find_line_pos, sam_hdr_t
# sam_hdr_find_line_pos, kstring_t
# sam_hdr_remove_line_id, sam_hdr_t
# sam_hdr_remove_line_pos, sam_hdr_t
# sam_hdr_update_line, sam_hdr_t
# sam_hdr_remove_except, sam_hdr_t
# sam_hdr_remove_lines, sam_hdr_t
# sam_hdr_count_lines, sam_hdr_t
# sam_hdr_line_index, sam_hdr_t
# sam_hdr_line_name, sam_hdr_t
# sam_hdr_find_tag_id, sam_hdr_t
# sam_hdr_find_tag_id, kstring_t
# sam_hdr_find_tag_pos, sam_hdr_t
# sam_hdr_find_tag_pos, kstring_t
# sam_hdr_remove_tag_id, sam_hdr_t
# sam_hdr_name2tid, sam_hdr_t
# sam_hdr_tid2name, sam_hdr_t
# sam_hdr_tid2len, sam_hdr_t
# sam_hdr_tid2len, hts_pos_t
# bam_name2id, sam_hdr_t
# sam_hdr_pg_id, sam_hdr_t
# sam_hdr_add_pg, sam_hdr_t
# sam_hdr_incr_ref, sam_hdr_t
# bam_init1, bam1_t
# bam_destroy1, bam1_t
# bam_set_mempolicy, bam1_t
# bam_get_mempolicy, bam1_t
# bam_read1, BGZF
# bam_read1, bam1_t
# bam_write1, BGZF
# bam_write1, bam1_t
# bam_copy1, bam1_t
# bam_copy1, bam1_t
# bam_copy1, bam1_t
# bam_dup1, bam1_t
# bam_dup1, bam1_t
# bam_set1, bam1_t
# bam_set1, hts_pos_t
# bam_set1, hts_pos_t
# bam_set1, hts_pos_t
# bam_cigar2qlen, hts_pos_t
# bam_cigar2rlen, hts_pos_t
# bam_endpos, bam1_t
# bam_endpos, hts_pos_t
# bam_set_qname, bam1_t
# bam_parse_cigar, bam1_t
# sam_idx_init, htsFile
# sam_idx_init, sam_hdr_t
# sam_idx_save, htsFile
# sam_index_load, htsFile
# sam_index_load, hts_idx_t
# sam_index_load2, htsFile
# sam_index_load2, hts_idx_t
# sam_index_load3, htsFile
# sam_index_load3, hts_idx_t
# sam_itr_queryi, hts_idx_t
# sam_itr_queryi, hts_pos_t
# sam_itr_queryi, hts_pos_t
# sam_itr_queryi, hts_itr_t
# sam_itr_querys, hts_idx_t
# sam_itr_querys, sam_hdr_t
# sam_itr_querys, hts_itr_t
# sam_itr_regions, hts_idx_t
# sam_itr_regions, sam_hdr_t
# sam_itr_regions, hts_reglist_t
# sam_itr_regions, hts_itr_t
# sam_itr_regarray, hts_idx_t
# sam_itr_regarray, sam_hdr_t
# sam_itr_regarray, hts_itr_t
# sam_itr_next, htsFile
# sam_itr_next, hts_itr_t
# sam_itr_next, bam1_t
# sam_parse_region, sam_hdr_t
# sam_parse_region, hts_pos_t
# sam_parse_region, hts_pos_t
# sam_hdr_change_HD, sam_hdr_t
# sam_parse1, kstring_t
# sam_parse1, sam_hdr_t
# sam_parse1, bam1_t
# sam_format1, sam_hdr_t
# sam_format1, bam1_t
# sam_format1, kstring_t
# sam_read1, samFile
# sam_read1, sam_hdr_t
# sam_read1, bam1_t
# sam_write1, samFile
# sam_write1, sam_hdr_t
# sam_write1, bam1_t
# sam_passes_filter, sam_hdr_t
# sam_passes_filter, bam1_t
# sam_passes_filter, struct
# sam_format_aux1, kstring_t
# bam_aux_get, bam1_t
# bam_aux_get, :array
# bam_aux_get_str, bam1_t
# bam_aux_get_str, :array
# bam_aux_get_str, kstring_t
# bam_aux_append, bam1_t
# bam_aux_append, :array
# bam_aux_del, bam1_t
# bam_aux_update_str, bam1_t
# bam_aux_update_str, :array
# bam_aux_update_int, bam1_t
# bam_aux_update_int, :array
# bam_aux_update_float, bam1_t
# bam_aux_update_float, :array
# bam_aux_update_array, bam1_t
# bam_aux_update_array, :array
# bam_plp_init, bam_plp_auto_f
# bam_plp_init, bam_plp_t
# bam_plp_destroy, bam_plp_t
# bam_plp_push, bam_plp_t
# bam_plp_push, bam1_t
# bam_plp_next, bam_plp_t
# bam_plp_next, bam_pileup1_t
# bam_plp_auto, bam_plp_t
# bam_plp_auto, bam_pileup1_t
# bam_plp64_next, bam_plp_t
# bam_plp64_next, hts_pos_t
# bam_plp64_next, bam_pileup1_t
# bam_plp64_auto, bam_plp_t
# bam_plp64_auto, hts_pos_t
# bam_plp64_auto, bam_pileup1_t
# bam_plp_set_maxcnt, bam_plp_t
# bam_plp_reset, bam_plp_t
# bam_plp_constructor, bam_plp_t
# bam_plp_constructor, :function-pointer
# bam_plp_destructor, bam_plp_t
# bam_plp_destructor, :function-pointer
# bam_plp_insertion, bam_pileup1_t
# bam_plp_insertion, kstring_t
# bam_mplp_init, bam_plp_auto_f
# bam_mplp_init, bam_mplp_t
# bam_mplp_init_overlaps, bam_mplp_t
# bam_mplp_destroy, bam_mplp_t
# bam_mplp_set_maxcnt, bam_mplp_t
# bam_mplp_auto, bam_mplp_t
# bam_mplp_auto, bam_pileup1_t
# bam_mplp64_auto, bam_mplp_t
# bam_mplp64_auto, hts_pos_t
# bam_mplp64_auto, bam_pileup1_t
# bam_mplp_reset, bam_mplp_t
# bam_mplp_constructor, bam_mplp_t
# bam_mplp_constructor, :function-pointer
# bam_mplp_destructor, bam_mplp_t
# bam_mplp_destructor, :function-pointer
# sam_cap_mapq, bam1_t
# sam_cap_mapq, hts_pos_t
# sam_prob_realn, bam1_t
# sam_prob_realn, hts_pos_t
# cram_fd_get_header, cram_fd
# cram_fd_get_header, sam_hdr_t
# cram_fd_set_header, cram_fd
# cram_fd_set_header, sam_hdr_t
# cram_fd_get_version, cram_fd
# cram_fd_set_version, cram_fd
# cram_major_vers, cram_fd
# cram_minor_vers, cram_fd
# cram_fd_get_fp, cram_fd
# cram_fd_get_fp, struct
# cram_fd_set_fp, cram_fd
# cram_fd_set_fp, struct
# cram_container_get_length, cram_container
# cram_container_set_length, cram_container
# cram_container_get_num_blocks, cram_container
# cram_container_set_num_blocks, cram_container
# cram_container_get_landmarks, cram_container
# cram_container_set_landmarks, cram_container
# cram_container_is_empty, cram_fd
# cram_block_get_content_id, cram_block
# cram_block_get_comp_size, cram_block
# cram_block_get_uncomp_size, cram_block
# cram_block_get_crc32, cram_block
# cram_block_get_data, cram_block
# cram_block_get_content_type, cram_block
# cram_block_get_content_type, :enum
# cram_block_set_content_id, cram_block
# cram_block_set_comp_size, cram_block
# cram_block_set_uncomp_size, cram_block
# cram_block_set_crc32, cram_block
# cram_block_set_data, cram_block
# cram_block_append, cram_block
# cram_block_update_size, cram_block
# cram_block_get_offset, cram_block
# cram_block_set_offset, cram_block
# cram_block_size, cram_block
# cram_transcode_rg, cram_fd
# cram_transcode_rg, cram_fd
# cram_transcode_rg, cram_container
# cram_copy_slice, cram_fd
# cram_copy_slice, cram_fd
# cram_new_block, :enum
# cram_new_block, cram_block
# cram_read_block, cram_fd
# cram_read_block, cram_block
# cram_write_block, cram_fd
# cram_write_block, cram_block
# cram_free_block, cram_block
# cram_uncompress_block, cram_block
# cram_compress_block, cram_fd
# cram_compress_block, cram_block
# cram_compress_block, cram_metrics
# cram_compress_block2, cram_fd
# cram_compress_block2, cram_slice
# cram_compress_block2, cram_block
# cram_compress_block2, cram_metrics
# cram_new_container, cram_container
# cram_free_container, cram_container
# cram_read_container, cram_fd
# cram_read_container, cram_container
# cram_write_container, cram_fd
# cram_write_container, cram_container
# cram_store_container, cram_fd
# cram_store_container, cram_container
# cram_container_size, cram_container
# cram_open, cram_fd
# cram_dopen, struct
# cram_dopen, cram_fd
# cram_close, cram_fd
# cram_seek, cram_fd
# cram_seek, off_t
# cram_flush, cram_fd
# cram_eof, cram_fd
# cram_set_option, cram_fd
# cram_set_option, :enum
# cram_set_voption, cram_fd
# cram_set_voption, :enum
# cram_set_voption, va_list
# cram_set_header, cram_fd
# cram_set_header, sam_hdr_t
# cram_check_EOF, cram_fd
# int32_put_blk, cram_block
# sam_hdr_parse_, SAM_hdr
# sam_hdr_free, SAM_hdr
# cram_get_refs, htsFile
# cram_get_refs, refs_t
