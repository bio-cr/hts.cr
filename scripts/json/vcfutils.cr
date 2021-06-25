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

struct BcfHrecT
  type : Int32
  key : 
  value : 
  nkeys : Int32
  keys : 
  vals : 
end

struct BcfIdinfoT
  info : 
  hrec : 
  id : Int32
end

struct BcfIdpairT
  key : 
  val : 
end

struct BcfHdrT
  n : 
  id : 
  dict : 
  samples : 
  hrec : 
  nhrec : Int32
  dirty : Int32
  ntransl : Int32
  transl : 
  nsamples_ori : Int32
  keep_samples : 
  mem : 
  m : 
end

struct BcfVariantT
  type : Int32
  n : Int32
end

struct BcfFmtT
  id : Int32
  n : Int32
  size : Int32
  type : Int32
  p : 
  p_len : UInt32
  p_off : 
  p_free : 
end

struct BcfInfoT
  key : Int32
  type : Int32
  v1 : 
  vptr : 
  vptr_len : UInt32
  vptr_off : 
  vptr_free : 
  len : Int32
end

struct BcfDecT
  m_fmt : Int32
  m_info : Int32
  m_id : Int32
  m_als : Int32
  m_allele : Int32
  m_flt : Int32
  n_flt : Int32
  flt : 
  id : 
  als : 
  allele : 
  info : 
  fmt : 
  var : 
  n_var : Int32
  var_type : Int32
  shared_dirty : Int32
  indiv_dirty : Int32
end

struct Bcf1T
  pos : 
  rlen : 
  rid : Int32
  qual : Float32
  n_info : 
  n_allele : 
  n_fmt : 
  n_sample : 
  shared : 
  indiv : 
  d : 
  max_unpack : Int32
  unpacked : Int32
  unpack_size : 
  errcode : Int32
end

struct KbitsetT
end
# fun __errno_location() : Int32*
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
fun __bswap_16(UInt16) : UInt16
fun __bswap_32(UInt32) : UInt32
fun __bswap_64(UInt64) : UInt64
fun __uint16_identity(UInt16) : UInt16
fun __uint32_identity(UInt32) : UInt32
fun __uint64_identity(UInt64) : UInt64
# fun select(Int32, *, *, *, *) : Int32
# fun pselect(Int32, *, *, *, *, *) : Int32
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
fun __assert_fail(UInt8*, UInt8*, UInt32, UInt8*) : Void
fun __assert_perror_fail(Int32, UInt8*, UInt32, UInt8*) : Void
fun __assert(UInt8*, UInt8*, Int32) : Void
# fun bcf_hdr_init(UInt8*) : *
# fun bcf_hdr_destroy(*) : Void
# fun bcf_init() : *
# fun bcf_destroy(*) : Void
# fun bcf_empty(*) : Void
# fun bcf_clear(*) : Void
# fun bcf_hdr_read(*) : *
# fun bcf_hdr_set_samples(*, UInt8*, Int32) : Int32
# fun bcf_subset_format(*, *) : Int32
# fun bcf_hdr_write(*, *) : Int32
# fun vcf_parse(*, *, *) : Int32
fun vcf_open_mode(UInt8*, UInt8*, UInt8*) : Int32
# fun vcf_format(*, *, *) : Int32
# fun bcf_read(*, *, *) : Int32
# fun bcf_unpack(*, Int32) : Int32
# fun bcf_dup(*) : *
# fun bcf_copy(*, *) : *
# fun bcf_write(*, *, *) : Int32
# fun vcf_hdr_read(*) : *
# fun vcf_hdr_write(*, *) : Int32
# fun vcf_read(*, *, *) : Int32
# fun vcf_write(*, *, *) : Int32
# fun bcf_readrec(*, Void*, Void*, Int32*, *, *) : Int32
# fun vcf_write_line(*, *) : Int32
# fun bcf_hdr_dup(*) : *
# fun bcf_hdr_combine(*, *) : Int32
# fun bcf_hdr_merge(*, *) : *
# fun bcf_hdr_add_sample(*, UInt8*) : Int32
# fun bcf_hdr_set(*, UInt8*) : Int32
# fun bcf_hdr_format(*, Int32, *) : Int32
# fun bcf_hdr_fmt_text(*, Int32, Int32*) : UInt8*
# fun bcf_hdr_append(*, UInt8*) : Int32
# fun bcf_hdr_printf(*, UInt8*) : Int32
# fun bcf_hdr_get_version(*) : UInt8*
# fun bcf_hdr_set_version(*, UInt8*) : Int32
# fun bcf_hdr_remove(*, Int32, UInt8*) : Void
# fun bcf_hdr_subset(*, Int32, UInt8**, Int32*) : *
# fun bcf_hdr_seqnames(*, Int32*) : *
# fun bcf_hdr_parse(*, UInt8*) : Int32
# fun bcf_hdr_sync(*) : Int32
# fun bcf_hdr_parse_line(*, UInt8*, Int32*) : *
# fun bcf_hrec_format(*, *) : Int32
# fun bcf_hdr_add_hrec(*, *) : Int32
# fun bcf_hdr_get_hrec(*, Int32, UInt8*, UInt8*, UInt8*) : *
# fun bcf_hrec_dup(*) : *
# fun bcf_hrec_add_key(*, UInt8*, SizeT) : Int32
# fun bcf_hrec_set_val(*, Int32, UInt8*, SizeT, Int32) : Int32
# fun bcf_hrec_find_key(*, UInt8*) : Int32
# fun hrec_add_idx(*, Int32) : Int32
# fun bcf_hrec_destroy(*) : Void
# fun bcf_subset(*, *, Int32, Int32*) : Int32
# fun bcf_translate(*, *, *) : Int32
# fun bcf_get_variant_types(*) : Int32
# fun bcf_get_variant_type(*, Int32) : Int32
# fun bcf_is_snp(*) : Int32
# fun bcf_update_filter(*, *, Int32*, Int32) : Int32
# fun bcf_add_filter(*, *, Int32) : Int32
# fun bcf_remove_filter(*, *, Int32, Int32) : Int32
# fun bcf_has_filter(*, *, UInt8*) : Int32
# fun bcf_update_alleles(*, *, UInt8**, Int32) : Int32
# fun bcf_update_alleles_str(*, *, UInt8*) : Int32
# fun bcf_update_id(*, *, UInt8*) : Int32
# fun bcf_add_id(*, *, UInt8*) : Int32
# fun bcf_update_info(*, *, UInt8*, Void*, Int32, Int32) : Int32
# fun bcf_update_info_int64(*, *, UInt8*, Int64*, Int32) : Int32
# fun bcf_update_format_string(*, *, UInt8*, UInt8**, Int32) : Int32
# fun bcf_update_format(*, *, UInt8*, Void*, Int32, Int32) : Int32
fun bcf_gt2alleles(Int32, Int32*, Int32*) : Void
# fun bcf_get_fmt(*, *, UInt8*) : *
# fun bcf_get_info(*, *, UInt8*) : *
# fun bcf_get_fmt_id(*, Int32) : *
# fun bcf_get_info_id(*, Int32) : *
# fun bcf_get_info_values(*, *, UInt8*, Void**, Int32*, Int32) : Int32
# fun bcf_get_info_int64(*, *, UInt8*, Int64**, Int32*) : Int32
# fun bcf_get_format_string(*, *, UInt8*, **, Int32*) : Int32
# fun bcf_get_format_values(*, *, UInt8*, Void**, Int32*, Int32) : Int32
# fun bcf_hdr_id2int(*, Int32, UInt8*) : Int32
# fun bcf_hdr_name2id(*, UInt8*) : Int32
# fun bcf_hdr_id2name(*, Int32) : UInt8*
# fun bcf_seqname(*, *) : UInt8*
# fun bcf_seqname_safe(*, *) : UInt8*
# fun bcf_fmt_array(*, Int32, Int32, Void*) : Int32
# fun bcf_fmt_sized_array(*, UInt8*) : UInt8*
# fun bcf_enc_vchar(*, Int32, UInt8*) : Int32
# fun bcf_enc_vint(*, Int32, Int32*, Int32) : Int32
# fun bcf_enc_vfloat(*, Int32, Float32*) : Int32
# fun bcf_itr_next(*, *, Void*) : Int32
# fun bcf_index_load2(UInt8*, UInt8*) : *
# fun bcf_index_load3(UInt8*, UInt8*, Int32) : *
fun bcf_index_build(UInt8*, Int32) : Int32
fun bcf_index_build2(UInt8*, UInt8*, Int32) : Int32
fun bcf_index_build3(UInt8*, UInt8*, Int32, Int32) : Int32
# fun bcf_idx_init(*, *, Int32, UInt8*) : Int32
# fun bcf_idx_save(*) : Int32
fun bcf_float_set(Float32*, UInt32) : Void
fun bcf_float_is_missing(Float32) : Int32
fun bcf_float_is_vector_end(Float32) : Int32
# fun bcf_format_gt(*, Int32, *) : Int32
# fun bcf_enc_size(*, Int32, Int32) : Int32
fun bcf_enc_inttype(Long) : Int32
# fun bcf_enc_int1(*, Int32) : Int32
fun bcf_dec_int1(UInt8*, Int32, UInt8**) : Int64
fun bcf_dec_typed_int1(UInt8*, UInt8**) : Int64
fun bcf_dec_size(UInt8*, UInt8**, Int32*) : Int32
# fun bcf_trim_alleles(*, *) : Int32
# fun bcf_remove_alleles(*, *, Int32) : Int32
# fun bcf_remove_allele_set(*, *, *) : Int32
# fun bcf_calc_ac(*, *, Int32*, Int32) : Int32
# fun bcf_gt_type(*, Int32, Int32*, Int32*) : Int32
fun bcf_acgt2int(UInt8) : Int32

# Unknown types
# ["__time_t", "__suseconds_t", "__syscall_slong_t", ":pointer", ":array", ":enum", "struct", ":bitfield", "kstring_t", "union", "htsFormat", "hts_pos_t", ":function-pointer", "bcf_dec_t", "intmax_t", "imaxdiv_t", "uintmax_t", "__gwchar_t", ":long-double", "fd_set", ":struct", "__sigset_t", "__compar_fn_t", "div_t", "ldiv_t", "lldiv_t", "wchar_t", "locale_t", "FILE", "__gnuc_va_list", "__off_t", "fpos_t", "va_list", "ks_tokaux_t", "hts_opt", "htsFile", "htsThreadPool", "hts_idx_t", "hts_name2id_f", "hts_itr_t", "BGZF", "hts_id2name_f", "hts_reglist_t", "errmod_t", "probaln_par_t", "hts_md5_context", ":unsigned-char", "bcf_hdr_t", "bcf1_t", "bcf_hrec_t", "bcf_fmt_t", "bcf_info_t"]
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
# bcf_hrec_t, :pointer
# bcf_hrec_t, :pointer
# bcf_hrec_t, :pointer
# bcf_hrec_t, :pointer
# bcf_idinfo_t, :array
# bcf_idinfo_t, :array
# bcf_idpair_t, :pointer
# bcf_idpair_t, :pointer
# bcf_hdr_t, :array
# bcf_hdr_t, :array
# bcf_hdr_t, :array
# bcf_hdr_t, :pointer
# bcf_hdr_t, :pointer
# bcf_hdr_t, :array
# bcf_hdr_t, :pointer
# bcf_hdr_t, kstring_t
# bcf_hdr_t, :array
# bcf_fmt_t, :pointer
# bcf_fmt_t, :bitfield
# bcf_fmt_t, :bitfield
# bcf_info_t, union
# bcf_info_t, :pointer
# bcf_info_t, :bitfield
# bcf_info_t, :bitfield
# bcf_dec_t, :pointer
# bcf_dec_t, :pointer
# bcf_dec_t, :pointer
# bcf_dec_t, :pointer
# bcf_dec_t, :pointer
# bcf_dec_t, :pointer
# bcf_dec_t, :pointer
# bcf1_t, hts_pos_t
# bcf1_t, hts_pos_t
# bcf1_t, :bitfield
# bcf1_t, :bitfield
# bcf1_t, :bitfield
# bcf1_t, :bitfield
# bcf1_t, kstring_t
# bcf1_t, kstring_t
# bcf1_t, bcf_dec_t
# bcf1_t, :array
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
# select, fd_set
# select, fd_set
# select, fd_set
# select, :struct
# pselect, fd_set
# pselect, fd_set
# pselect, fd_set
# pselect, :struct
# pselect, __sigset_t
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
# bcf_hdr_init, bcf_hdr_t
# bcf_hdr_destroy, bcf_hdr_t
# bcf_init, bcf1_t
# bcf_destroy, bcf1_t
# bcf_empty, bcf1_t
# bcf_clear, bcf1_t
# bcf_hdr_read, htsFile
# bcf_hdr_read, bcf_hdr_t
# bcf_hdr_set_samples, bcf_hdr_t
# bcf_subset_format, bcf_hdr_t
# bcf_subset_format, bcf1_t
# bcf_hdr_write, htsFile
# bcf_hdr_write, bcf_hdr_t
# vcf_parse, kstring_t
# vcf_parse, bcf_hdr_t
# vcf_parse, bcf1_t
# vcf_format, bcf_hdr_t
# vcf_format, bcf1_t
# vcf_format, kstring_t
# bcf_read, htsFile
# bcf_read, bcf_hdr_t
# bcf_read, bcf1_t
# bcf_unpack, bcf1_t
# bcf_dup, bcf1_t
# bcf_dup, bcf1_t
# bcf_copy, bcf1_t
# bcf_copy, bcf1_t
# bcf_copy, bcf1_t
# bcf_write, htsFile
# bcf_write, bcf_hdr_t
# bcf_write, bcf1_t
# vcf_hdr_read, htsFile
# vcf_hdr_read, bcf_hdr_t
# vcf_hdr_write, htsFile
# vcf_hdr_write, bcf_hdr_t
# vcf_read, htsFile
# vcf_read, bcf_hdr_t
# vcf_read, bcf1_t
# vcf_write, htsFile
# vcf_write, bcf_hdr_t
# vcf_write, bcf1_t
# bcf_readrec, BGZF
# bcf_readrec, hts_pos_t
# bcf_readrec, hts_pos_t
# vcf_write_line, htsFile
# vcf_write_line, kstring_t
# bcf_hdr_dup, bcf_hdr_t
# bcf_hdr_dup, bcf_hdr_t
# bcf_hdr_combine, bcf_hdr_t
# bcf_hdr_combine, bcf_hdr_t
# bcf_hdr_merge, bcf_hdr_t
# bcf_hdr_merge, bcf_hdr_t
# bcf_hdr_merge, bcf_hdr_t
# bcf_hdr_add_sample, bcf_hdr_t
# bcf_hdr_set, bcf_hdr_t
# bcf_hdr_format, bcf_hdr_t
# bcf_hdr_format, kstring_t
# bcf_hdr_fmt_text, bcf_hdr_t
# bcf_hdr_append, bcf_hdr_t
# bcf_hdr_printf, bcf_hdr_t
# bcf_hdr_get_version, bcf_hdr_t
# bcf_hdr_set_version, bcf_hdr_t
# bcf_hdr_remove, bcf_hdr_t
# bcf_hdr_subset, bcf_hdr_t
# bcf_hdr_subset, bcf_hdr_t
# bcf_hdr_seqnames, bcf_hdr_t
# bcf_hdr_seqnames, :pointer
# bcf_hdr_parse, bcf_hdr_t
# bcf_hdr_sync, bcf_hdr_t
# bcf_hdr_parse_line, bcf_hdr_t
# bcf_hdr_parse_line, bcf_hrec_t
# bcf_hrec_format, bcf_hrec_t
# bcf_hrec_format, kstring_t
# bcf_hdr_add_hrec, bcf_hdr_t
# bcf_hdr_add_hrec, bcf_hrec_t
# bcf_hdr_get_hrec, bcf_hdr_t
# bcf_hdr_get_hrec, bcf_hrec_t
# bcf_hrec_dup, bcf_hrec_t
# bcf_hrec_dup, bcf_hrec_t
# bcf_hrec_add_key, bcf_hrec_t
# bcf_hrec_set_val, bcf_hrec_t
# bcf_hrec_find_key, bcf_hrec_t
# hrec_add_idx, bcf_hrec_t
# bcf_hrec_destroy, bcf_hrec_t
# bcf_subset, bcf_hdr_t
# bcf_subset, bcf1_t
# bcf_translate, bcf_hdr_t
# bcf_translate, bcf_hdr_t
# bcf_translate, bcf1_t
# bcf_get_variant_types, bcf1_t
# bcf_get_variant_type, bcf1_t
# bcf_is_snp, bcf1_t
# bcf_update_filter, bcf_hdr_t
# bcf_update_filter, bcf1_t
# bcf_add_filter, bcf_hdr_t
# bcf_add_filter, bcf1_t
# bcf_remove_filter, bcf_hdr_t
# bcf_remove_filter, bcf1_t
# bcf_has_filter, bcf_hdr_t
# bcf_has_filter, bcf1_t
# bcf_update_alleles, bcf_hdr_t
# bcf_update_alleles, bcf1_t
# bcf_update_alleles_str, bcf_hdr_t
# bcf_update_alleles_str, bcf1_t
# bcf_update_id, bcf_hdr_t
# bcf_update_id, bcf1_t
# bcf_add_id, bcf_hdr_t
# bcf_add_id, bcf1_t
# bcf_update_info, bcf_hdr_t
# bcf_update_info, bcf1_t
# bcf_update_info_int64, bcf_hdr_t
# bcf_update_info_int64, bcf1_t
# bcf_update_format_string, bcf_hdr_t
# bcf_update_format_string, bcf1_t
# bcf_update_format, bcf_hdr_t
# bcf_update_format, bcf1_t
# bcf_get_fmt, bcf_hdr_t
# bcf_get_fmt, bcf1_t
# bcf_get_fmt, bcf_fmt_t
# bcf_get_info, bcf_hdr_t
# bcf_get_info, bcf1_t
# bcf_get_info, bcf_info_t
# bcf_get_fmt_id, bcf1_t
# bcf_get_fmt_id, bcf_fmt_t
# bcf_get_info_id, bcf1_t
# bcf_get_info_id, bcf_info_t
# bcf_get_info_values, bcf_hdr_t
# bcf_get_info_values, bcf1_t
# bcf_get_info_int64, bcf_hdr_t
# bcf_get_info_int64, bcf1_t
# bcf_get_format_string, bcf_hdr_t
# bcf_get_format_string, bcf1_t
# bcf_get_format_string, :pointer
# bcf_get_format_values, bcf_hdr_t
# bcf_get_format_values, bcf1_t
# bcf_hdr_id2int, bcf_hdr_t
# bcf_hdr_name2id, bcf_hdr_t
# bcf_hdr_id2name, bcf_hdr_t
# bcf_seqname, bcf_hdr_t
# bcf_seqname, bcf1_t
# bcf_seqname_safe, bcf_hdr_t
# bcf_seqname_safe, bcf1_t
# bcf_fmt_array, kstring_t
# bcf_fmt_sized_array, kstring_t
# bcf_enc_vchar, kstring_t
# bcf_enc_vint, kstring_t
# bcf_enc_vfloat, kstring_t
# bcf_itr_next, htsFile
# bcf_itr_next, hts_itr_t
# bcf_index_load2, hts_idx_t
# bcf_index_load3, hts_idx_t
# bcf_idx_init, htsFile
# bcf_idx_init, bcf_hdr_t
# bcf_idx_save, htsFile
# bcf_format_gt, bcf_fmt_t
# bcf_format_gt, kstring_t
# bcf_enc_size, kstring_t
# bcf_enc_int1, kstring_t
# bcf_trim_alleles, bcf_hdr_t
# bcf_trim_alleles, bcf1_t
# bcf_remove_alleles, bcf_hdr_t
# bcf_remove_alleles, bcf1_t
# bcf_remove_allele_set, bcf_hdr_t
# bcf_remove_allele_set, bcf1_t
# bcf_remove_allele_set, struct
# bcf_calc_ac, bcf_hdr_t
# bcf_calc_ac, bcf1_t
# bcf_gt_type, bcf_fmt_t
