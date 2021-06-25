struct Timeval
  tv_sec : 
  tv_usec : 
end

struct Timespec
  tv_sec : 
  tv_nsec : 
end

struct PthreadInternalList
  __prev : 
  __next : 
end

struct PthreadInternalSlist
  __next : 
end

struct PthreadMutexS
  __lock : Int32
  __count : UInt32
  __owner : Int32
  __nusers : UInt32
  __kind : Int32
  __spins : Short
  __elision : Short
  __list : 
end

struct PthreadRwlockArchT
  __readers : UInt32
  __writers : UInt32
  __wrphase_futex : UInt32
  __writers_futex : UInt32
  __pad3 : UInt32
  __pad4 : UInt32
  __cur_writer : Int32
  __shared : Int32
  __rwelision : Int8
  __pad1 : 
  __pad2 : ULong
  __flags : UInt32
end

struct PthreadCondS
   : 
   : 
  __g_refs : 
  __g_size : 
  __g1_orig_size : UInt32
  __wrefs : UInt32
  __g_signals : 
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

struct LocaleStruct
  __locales : 
  __ctype_b : 
  __ctype_tolower : 
  __ctype_toupper : 
  __names : 
end

struct LocaleData
end

struct GFposT
  __pos : 
  __state : 
end

struct GFpos64T
  __pos : 
  __state : 
end

struct IOFILE
end

struct IOFILE
end

struct IOFILE
end

struct IOMarker
end

struct IOCodecvt
end

struct IOWideData
end

struct IOFILE
  _flags : Int32
  _IO_read_ptr : 
  _IO_read_end : 
  _IO_read_base : 
  _IO_write_base : 
  _IO_write_ptr : 
  _IO_write_end : 
  _IO_buf_base : 
  _IO_buf_end : 
  _IO_save_base : 
  _IO_backup_base : 
  _IO_save_end : 
  _markers : 
  _chain : 
  _fileno : Int32
  _flags2 : Int32
  _old_offset : 
  _cur_column : UShort
  _vtable_offset : Int8
  _shortbuf : 
  _lock : 
  _offset : 
  _codecvt : 
  _wide_data : 
  _freeres_list : 
  _freeres_buf : 
  __pad5 : SizeT
  _mode : Int32
  _unused2 : 
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

struct TbxConfT
  preset : Int32
  sc : Int32
  bc : Int32
  ec : Int32
  meta_char : Int32
  line_skip : Int32
end

struct TbxT
  conf : 
  idx : 
  dict : 
end

struct BcfSrRegionT
end

struct BcfSrRegionsT
  tbx : 
  itr : 
  line : 
  file : 
  fname : 
  is_bin : Int32
  als : 
  als_str : 
  nals : Int32
  mals : Int32
  als_type : Int32
  missed_reg_handler : 
  missed_reg_data : 
  regs : 
  seq_hash : 
  seq_names : 
  nseqs : Int32
  iseq : Int32
  start : 
  end : 
  prev_seq : Int32
  prev_start : 
  prev_end : 
end

struct BcfSrT
  file : 
  tbx_idx : 
  bcf_idx : 
  header : 
  itr : 
  fname : 
  buffer : 
  nbuffer : Int32
  mbuffer : Int32
  nfilter_ids : Int32
  filter_ids : 
  samples : 
  n_smpl : Int32
end

struct BcfSrsT
  collapse : Int32
  apply_filters : 
  require_index : Int32
  max_unpack : Int32
  has_line : 
  errnum : 
  readers : 
  nreaders : Int32
  streaming : Int32
  explicit_regs : Int32
  samples : 
  regions : 
  targets : 
  targets_als : Int32
  targets_exclude : Int32
  tmps : 
  n_smpl : Int32
  n_threads : Int32
  p : 
  aux : 
end

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
# fun tbx_name2id(*, UInt8*) : Int32
# fun hts_get_bgzfp(*) : *
# fun tbx_readrec(*, Void*, Void*, Int32*, *, *) : Int32
# fun tbx_index(*, Int32, *) : *
# fun tbx_index_build(UInt8*, Int32, *) : Int32
# fun tbx_index_build2(UInt8*, UInt8*, Int32, *) : Int32
# fun tbx_index_build3(UInt8*, UInt8*, Int32, Int32, *) : Int32
# fun tbx_index_load(UInt8*) : *
# fun tbx_index_load2(UInt8*, UInt8*) : *
# fun tbx_index_load3(UInt8*, UInt8*, Int32) : *
# fun tbx_seqnames(*, Int32*) : *
# fun tbx_destroy(*) : Void
# fun bcf_sr_init() : *
# fun bcf_sr_destroy(*) : Void
fun bcf_sr_strerror(Int32) : UInt8*
# fun bcf_sr_set_opt(*, ) : Int32
# fun bcf_sr_set_threads(*, Int32) : Int32
# fun bcf_sr_destroy_threads(*) : Void
# fun bcf_sr_add_reader(*, UInt8*) : Int32
# fun bcf_sr_remove_reader(*, Int32) : Void
# fun bcf_sr_next_line(*) : Int32
# fun bcf_sr_seek(*, UInt8*, ) : Int32
# fun bcf_sr_set_samples(*, UInt8*, Int32) : Int32
# fun bcf_sr_set_targets(*, UInt8*, Int32, Int32) : Int32
# fun bcf_sr_set_regions(*, UInt8*, Int32) : Int32
# fun bcf_sr_regions_init(UInt8*, Int32, Int32, Int32, Int32) : *
# fun bcf_sr_regions_destroy(*) : Void
# fun bcf_sr_regions_seek(*, UInt8*) : Int32
# fun bcf_sr_regions_next(*) : Int32
# fun bcf_sr_regions_overlap(*, UInt8*, , ) : Int32
# fun bcf_sr_regions_flush(*) : Int32

# Unknow types
# ["__time_t", "__suseconds_t", "__syscall_slong_t", ":pointer", "__pthread_list_t", ":array", "union", "__off_t", "__mbstate_t", "__off64_t", ":enum", "struct", ":bitfield", "kstring_t", "htsFormat", "hts_pos_t", ":function-pointer", "bcf_dec_t", "tbx_conf_t", "bcf_sr_error", "intmax_t", "imaxdiv_t", "uintmax_t", "__gwchar_t", ":long-double", "fd_set", ":struct", "__sigset_t", "__compar_fn_t", "div_t", "ldiv_t", "lldiv_t", "wchar_t", "locale_t", "FILE", "__gnuc_va_list", "fpos_t", "va_list", "ks_tokaux_t", "hts_opt", "htsFile", "htsThreadPool", "hts_idx_t", "hts_name2id_f", "hts_itr_t", "BGZF", "hts_id2name_f", "hts_reglist_t", "errmod_t", "probaln_par_t", "hts_md5_context", ":unsigned-char", "bcf_hdr_t", "bcf1_t", "bcf_hrec_t", "bcf_fmt_t", "bcf_info_t", "tbx_t", "bcf_srs_t", "bcf_sr_opt_t", "bcf_sr_regions_t"]
# caller
# timeval, __time_t, convert.rb:79:in `block (2 levels) in <main>'
# timeval, __suseconds_t, convert.rb:79:in `block (2 levels) in <main>'
# timespec, __time_t, convert.rb:79:in `block (2 levels) in <main>'
# timespec, __syscall_slong_t, convert.rb:79:in `block (2 levels) in <main>'
# __pthread_internal_list, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# __pthread_internal_list, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# __pthread_internal_slist, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# __pthread_mutex_s, __pthread_list_t, convert.rb:79:in `block (2 levels) in <main>'
# __pthread_rwlock_arch_t, :array, convert.rb:79:in `block (2 levels) in <main>'
# __pthread_cond_s, union, convert.rb:79:in `block (2 levels) in <main>'
# __pthread_cond_s, union, convert.rb:79:in `block (2 levels) in <main>'
# __pthread_cond_s, :array, convert.rb:79:in `block (2 levels) in <main>'
# __pthread_cond_s, :array, convert.rb:79:in `block (2 levels) in <main>'
# __pthread_cond_s, :array, convert.rb:79:in `block (2 levels) in <main>'
# random_data, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# random_data, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# random_data, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# random_data, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# drand48_data, :array, convert.rb:79:in `block (2 levels) in <main>'
# drand48_data, :array, convert.rb:79:in `block (2 levels) in <main>'
# __locale_struct, :array, convert.rb:79:in `block (2 levels) in <main>'
# __locale_struct, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# __locale_struct, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# __locale_struct, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# __locale_struct, :array, convert.rb:79:in `block (2 levels) in <main>'
# _G_fpos_t, __off_t, convert.rb:79:in `block (2 levels) in <main>'
# _G_fpos_t, __mbstate_t, convert.rb:79:in `block (2 levels) in <main>'
# _G_fpos64_t, __off64_t, convert.rb:79:in `block (2 levels) in <main>'
# _G_fpos64_t, __mbstate_t, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, __off_t, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :array, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, __off64_t, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# _IO_FILE, :array, convert.rb:79:in `block (2 levels) in <main>'
# kstring_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# ks_tokaux_t, :array, convert.rb:79:in `block (2 levels) in <main>'
# ks_tokaux_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# htsFormat, :enum, convert.rb:79:in `block (2 levels) in <main>'
# htsFormat, :enum, convert.rb:79:in `block (2 levels) in <main>'
# htsFormat, struct, convert.rb:79:in `block (2 levels) in <main>'
# htsFormat, :enum, convert.rb:79:in `block (2 levels) in <main>'
# htsFormat, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# htsFile, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# htsFile, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# htsFile, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# htsFile, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# htsFile, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# htsFile, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# htsFile, kstring_t, convert.rb:79:in `block (2 levels) in <main>'
# htsFile, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# htsFile, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# htsFile, union, convert.rb:79:in `block (2 levels) in <main>'
# htsFile, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# htsFile, htsFormat, convert.rb:79:in `block (2 levels) in <main>'
# htsFile, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# htsFile, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# htsFile, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# htsFile, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# htsThreadPool, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# hts_opt, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# hts_opt, :enum, convert.rb:79:in `block (2 levels) in <main>'
# hts_opt, union, convert.rb:79:in `block (2 levels) in <main>'
# hts_opt, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# hts_pair_pos_t, hts_pos_t, convert.rb:79:in `block (2 levels) in <main>'
# hts_pair_pos_t, hts_pos_t, convert.rb:79:in `block (2 levels) in <main>'
# hts_reglist_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# hts_reglist_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# hts_reglist_t, hts_pos_t, convert.rb:79:in `block (2 levels) in <main>'
# hts_reglist_t, hts_pos_t, convert.rb:79:in `block (2 levels) in <main>'
# hts_itr_t, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# hts_itr_t, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# hts_itr_t, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# hts_itr_t, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# hts_itr_t, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# hts_itr_t, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# hts_itr_t, hts_pos_t, convert.rb:79:in `block (2 levels) in <main>'
# hts_itr_t, hts_pos_t, convert.rb:79:in `block (2 levels) in <main>'
# hts_itr_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# hts_itr_t, hts_pos_t, convert.rb:79:in `block (2 levels) in <main>'
# hts_itr_t, hts_pos_t, convert.rb:79:in `block (2 levels) in <main>'
# hts_itr_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# hts_itr_t, :function-pointer, convert.rb:79:in `block (2 levels) in <main>'
# hts_itr_t, :function-pointer, convert.rb:79:in `block (2 levels) in <main>'
# hts_itr_t, :function-pointer, convert.rb:79:in `block (2 levels) in <main>'
# hts_itr_t, struct, convert.rb:79:in `block (2 levels) in <main>'
# bcf_hrec_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_hrec_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_hrec_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_hrec_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_idinfo_t, :array, convert.rb:79:in `block (2 levels) in <main>'
# bcf_idinfo_t, :array, convert.rb:79:in `block (2 levels) in <main>'
# bcf_idpair_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_idpair_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_hdr_t, :array, convert.rb:79:in `block (2 levels) in <main>'
# bcf_hdr_t, :array, convert.rb:79:in `block (2 levels) in <main>'
# bcf_hdr_t, :array, convert.rb:79:in `block (2 levels) in <main>'
# bcf_hdr_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_hdr_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_hdr_t, :array, convert.rb:79:in `block (2 levels) in <main>'
# bcf_hdr_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_hdr_t, kstring_t, convert.rb:79:in `block (2 levels) in <main>'
# bcf_hdr_t, :array, convert.rb:79:in `block (2 levels) in <main>'
# bcf_fmt_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_fmt_t, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# bcf_fmt_t, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# bcf_info_t, union, convert.rb:79:in `block (2 levels) in <main>'
# bcf_info_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_info_t, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# bcf_info_t, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# bcf_dec_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_dec_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_dec_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_dec_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_dec_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_dec_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_dec_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf1_t, hts_pos_t, convert.rb:79:in `block (2 levels) in <main>'
# bcf1_t, hts_pos_t, convert.rb:79:in `block (2 levels) in <main>'
# bcf1_t, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# bcf1_t, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# bcf1_t, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# bcf1_t, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# bcf1_t, kstring_t, convert.rb:79:in `block (2 levels) in <main>'
# bcf1_t, kstring_t, convert.rb:79:in `block (2 levels) in <main>'
# bcf1_t, bcf_dec_t, convert.rb:79:in `block (2 levels) in <main>'
# bcf1_t, :array, convert.rb:79:in `block (2 levels) in <main>'
# tbx_t, tbx_conf_t, convert.rb:79:in `block (2 levels) in <main>'
# tbx_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# tbx_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_regions_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_regions_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_regions_t, kstring_t, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_regions_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_regions_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_regions_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_regions_t, kstring_t, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_regions_t, :function-pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_regions_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_regions_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_regions_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_regions_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_regions_t, hts_pos_t, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_regions_t, hts_pos_t, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_regions_t, hts_pos_t, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_regions_t, hts_pos_t, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_sr_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_srs_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_srs_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_srs_t, bcf_sr_error, convert.rb:79:in `block (2 levels) in <main>'
# bcf_srs_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_srs_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_srs_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_srs_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_srs_t, kstring_t, convert.rb:79:in `block (2 levels) in <main>'
# bcf_srs_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# bcf_srs_t, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# imaxabs, intmax_t, convert.rb:104:in `block (2 levels) in <main>'
# imaxabs, intmax_t, convert.rb:112:in `block in <main>'
# imaxdiv, intmax_t, convert.rb:104:in `block (2 levels) in <main>'
# imaxdiv, intmax_t, convert.rb:104:in `block (2 levels) in <main>'
# imaxdiv, imaxdiv_t, convert.rb:112:in `block in <main>'
# strtoimax, intmax_t, convert.rb:112:in `block in <main>'
# strtoumax, uintmax_t, convert.rb:112:in `block in <main>'
# wcstoimax, __gwchar_t, convert.rb:100:in `block (2 levels) in <main>'
# wcstoimax, __gwchar_t, convert.rb:97:in `block (2 levels) in <main>'
# wcstoimax, intmax_t, convert.rb:112:in `block in <main>'
# wcstoumax, __gwchar_t, convert.rb:100:in `block (2 levels) in <main>'
# wcstoumax, __gwchar_t, convert.rb:97:in `block (2 levels) in <main>'
# wcstoumax, uintmax_t, convert.rb:112:in `block in <main>'
# hts_set_log_level, :enum, convert.rb:104:in `block (2 levels) in <main>'
# hts_get_log_level, :enum, convert.rb:112:in `block in <main>'
# hts_log, :enum, convert.rb:104:in `block (2 levels) in <main>'
# strtold, :long-double, convert.rb:112:in `block in <main>'
# select, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# select, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# select, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# select, :struct, convert.rb:100:in `block (2 levels) in <main>'
# pselect, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# pselect, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# pselect, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# pselect, :struct, convert.rb:100:in `block (2 levels) in <main>'
# pselect, __sigset_t, convert.rb:100:in `block (2 levels) in <main>'
# random_r, :struct, convert.rb:100:in `block (2 levels) in <main>'
# srandom_r, :struct, convert.rb:100:in `block (2 levels) in <main>'
# initstate_r, :struct, convert.rb:100:in `block (2 levels) in <main>'
# setstate_r, :struct, convert.rb:100:in `block (2 levels) in <main>'
# erand48, :array, convert.rb:104:in `block (2 levels) in <main>'
# nrand48, :array, convert.rb:104:in `block (2 levels) in <main>'
# jrand48, :array, convert.rb:104:in `block (2 levels) in <main>'
# seed48, :array, convert.rb:104:in `block (2 levels) in <main>'
# lcong48, :array, convert.rb:104:in `block (2 levels) in <main>'
# drand48_r, :struct, convert.rb:100:in `block (2 levels) in <main>'
# erand48_r, :array, convert.rb:104:in `block (2 levels) in <main>'
# erand48_r, :struct, convert.rb:100:in `block (2 levels) in <main>'
# lrand48_r, :struct, convert.rb:100:in `block (2 levels) in <main>'
# nrand48_r, :array, convert.rb:104:in `block (2 levels) in <main>'
# nrand48_r, :struct, convert.rb:100:in `block (2 levels) in <main>'
# mrand48_r, :struct, convert.rb:100:in `block (2 levels) in <main>'
# jrand48_r, :array, convert.rb:104:in `block (2 levels) in <main>'
# jrand48_r, :struct, convert.rb:100:in `block (2 levels) in <main>'
# srand48_r, :struct, convert.rb:100:in `block (2 levels) in <main>'
# seed48_r, :array, convert.rb:104:in `block (2 levels) in <main>'
# seed48_r, :struct, convert.rb:100:in `block (2 levels) in <main>'
# lcong48_r, :array, convert.rb:104:in `block (2 levels) in <main>'
# lcong48_r, :struct, convert.rb:100:in `block (2 levels) in <main>'
# atexit, :function-pointer, convert.rb:104:in `block (2 levels) in <main>'
# at_quick_exit, :function-pointer, convert.rb:104:in `block (2 levels) in <main>'
# on_exit, :function-pointer, convert.rb:104:in `block (2 levels) in <main>'
# bsearch, __compar_fn_t, convert.rb:104:in `block (2 levels) in <main>'
# qsort, __compar_fn_t, convert.rb:104:in `block (2 levels) in <main>'
# div, div_t, convert.rb:112:in `block in <main>'
# ldiv, ldiv_t, convert.rb:112:in `block in <main>'
# lldiv, lldiv_t, convert.rb:112:in `block in <main>'
# qecvt, :long-double, convert.rb:104:in `block (2 levels) in <main>'
# qfcvt, :long-double, convert.rb:104:in `block (2 levels) in <main>'
# qgcvt, :long-double, convert.rb:104:in `block (2 levels) in <main>'
# qecvt_r, :long-double, convert.rb:104:in `block (2 levels) in <main>'
# qfcvt_r, :long-double, convert.rb:104:in `block (2 levels) in <main>'
# mbtowc, wchar_t, convert.rb:100:in `block (2 levels) in <main>'
# wctomb, wchar_t, convert.rb:104:in `block (2 levels) in <main>'
# mbstowcs, wchar_t, convert.rb:100:in `block (2 levels) in <main>'
# wcstombs, wchar_t, convert.rb:100:in `block (2 levels) in <main>'
# strcoll_l, locale_t, convert.rb:104:in `block (2 levels) in <main>'
# strxfrm_l, locale_t, convert.rb:104:in `block (2 levels) in <main>'
# strerror_l, locale_t, convert.rb:104:in `block (2 levels) in <main>'
# strcasecmp_l, locale_t, convert.rb:104:in `block (2 levels) in <main>'
# strncasecmp_l, locale_t, convert.rb:104:in `block (2 levels) in <main>'
# , FILE, convert.rb:109:in `block in <main>'
# fclose, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fflush, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fflush_unlocked, FILE, convert.rb:100:in `block (2 levels) in <main>'
# , FILE, convert.rb:109:in `block in <main>'
# freopen, FILE, convert.rb:100:in `block (2 levels) in <main>'
# , FILE, convert.rb:109:in `block in <main>'
# , FILE, convert.rb:109:in `block in <main>'
# , FILE, convert.rb:109:in `block in <main>'
# , FILE, convert.rb:109:in `block in <main>'
# setbuf, FILE, convert.rb:100:in `block (2 levels) in <main>'
# setvbuf, FILE, convert.rb:100:in `block (2 levels) in <main>'
# setbuffer, FILE, convert.rb:100:in `block (2 levels) in <main>'
# setlinebuf, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fprintf, FILE, convert.rb:100:in `block (2 levels) in <main>'
# vfprintf, FILE, convert.rb:100:in `block (2 levels) in <main>'
# vfprintf, __gnuc_va_list, convert.rb:104:in `block (2 levels) in <main>'
# vprintf, __gnuc_va_list, convert.rb:104:in `block (2 levels) in <main>'
# vsprintf, __gnuc_va_list, convert.rb:104:in `block (2 levels) in <main>'
# vsnprintf, __gnuc_va_list, convert.rb:104:in `block (2 levels) in <main>'
# vdprintf, __gnuc_va_list, convert.rb:104:in `block (2 levels) in <main>'
# fscanf, FILE, convert.rb:100:in `block (2 levels) in <main>'
# __isoc99_fscanf, FILE, convert.rb:100:in `block (2 levels) in <main>'
# vfscanf, FILE, convert.rb:100:in `block (2 levels) in <main>'
# vfscanf, __gnuc_va_list, convert.rb:104:in `block (2 levels) in <main>'
# vscanf, __gnuc_va_list, convert.rb:104:in `block (2 levels) in <main>'
# vsscanf, __gnuc_va_list, convert.rb:104:in `block (2 levels) in <main>'
# __isoc99_vfscanf, FILE, convert.rb:100:in `block (2 levels) in <main>'
# __isoc99_vfscanf, __gnuc_va_list, convert.rb:104:in `block (2 levels) in <main>'
# __isoc99_vscanf, __gnuc_va_list, convert.rb:104:in `block (2 levels) in <main>'
# __isoc99_vsscanf, __gnuc_va_list, convert.rb:104:in `block (2 levels) in <main>'
# fgetc, FILE, convert.rb:100:in `block (2 levels) in <main>'
# getc, FILE, convert.rb:100:in `block (2 levels) in <main>'
# getc_unlocked, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fgetc_unlocked, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fputc, FILE, convert.rb:100:in `block (2 levels) in <main>'
# putc, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fputc_unlocked, FILE, convert.rb:100:in `block (2 levels) in <main>'
# putc_unlocked, FILE, convert.rb:100:in `block (2 levels) in <main>'
# getw, FILE, convert.rb:100:in `block (2 levels) in <main>'
# putw, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fgets, FILE, convert.rb:100:in `block (2 levels) in <main>'
# __getdelim, FILE, convert.rb:100:in `block (2 levels) in <main>'
# getdelim, FILE, convert.rb:100:in `block (2 levels) in <main>'
# getline, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fputs, FILE, convert.rb:100:in `block (2 levels) in <main>'
# ungetc, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fread, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fwrite, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fread_unlocked, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fwrite_unlocked, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fseek, FILE, convert.rb:100:in `block (2 levels) in <main>'
# ftell, FILE, convert.rb:100:in `block (2 levels) in <main>'
# rewind, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fseeko, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fseeko, __off_t, convert.rb:104:in `block (2 levels) in <main>'
# ftello, FILE, convert.rb:100:in `block (2 levels) in <main>'
# ftello, __off_t, convert.rb:112:in `block in <main>'
# fgetpos, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fgetpos, fpos_t, convert.rb:100:in `block (2 levels) in <main>'
# fsetpos, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fsetpos, fpos_t, convert.rb:100:in `block (2 levels) in <main>'
# clearerr, FILE, convert.rb:100:in `block (2 levels) in <main>'
# feof, FILE, convert.rb:100:in `block (2 levels) in <main>'
# ferror, FILE, convert.rb:100:in `block (2 levels) in <main>'
# clearerr_unlocked, FILE, convert.rb:100:in `block (2 levels) in <main>'
# feof_unlocked, FILE, convert.rb:100:in `block (2 levels) in <main>'
# ferror_unlocked, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fileno, FILE, convert.rb:100:in `block (2 levels) in <main>'
# fileno_unlocked, FILE, convert.rb:100:in `block (2 levels) in <main>'
# , FILE, convert.rb:109:in `block in <main>'
# pclose, FILE, convert.rb:100:in `block (2 levels) in <main>'
# flockfile, FILE, convert.rb:100:in `block (2 levels) in <main>'
# ftrylockfile, FILE, convert.rb:100:in `block (2 levels) in <main>'
# funlockfile, FILE, convert.rb:100:in `block (2 levels) in <main>'
# __uflow, FILE, convert.rb:100:in `block (2 levels) in <main>'
# __overflow, FILE, convert.rb:100:in `block (2 levels) in <main>'
# kvsprintf, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# kvsprintf, va_list, convert.rb:104:in `block (2 levels) in <main>'
# ksprintf, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# kputd, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# kstrtok, ks_tokaux_t, convert.rb:100:in `block (2 levels) in <main>'
# kgetline, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# kgetline, :function-pointer, convert.rb:104:in `block (2 levels) in <main>'
# kgetline2, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# kgetline2, :function-pointer, convert.rb:104:in `block (2 levels) in <main>'
# ks_initialize, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# ks_resize, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# ks_expand, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# ks_str, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# ks_c_str, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# ks_len, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# ks_clear, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# , kstring_t, convert.rb:109:in `block in <main>'
# ks_release, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# ks_free, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# kputsn, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# kputs, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# kputc, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# kputc_, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# kputsn_, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# kputuw, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# kputw, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# kputll, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# kputl, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# ksplit, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_opt_add, hts_opt, convert.rb:97:in `block (2 levels) in <main>'
# hts_opt_apply, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# hts_opt_apply, hts_opt, convert.rb:100:in `block (2 levels) in <main>'
# hts_opt_free, hts_opt, convert.rb:100:in `block (2 levels) in <main>'
# hts_parse_format, htsFormat, convert.rb:100:in `block (2 levels) in <main>'
# hts_parse_opt_list, htsFormat, convert.rb:100:in `block (2 levels) in <main>'
# hts_detect_format, struct, convert.rb:100:in `block (2 levels) in <main>'
# hts_detect_format, htsFormat, convert.rb:100:in `block (2 levels) in <main>'
# hts_format_description, htsFormat, convert.rb:100:in `block (2 levels) in <main>'
# , htsFile, convert.rb:109:in `block in <main>'
# hts_open_format, htsFormat, convert.rb:100:in `block (2 levels) in <main>'
# , htsFile, convert.rb:109:in `block in <main>'
# hts_hopen, struct, convert.rb:100:in `block (2 levels) in <main>'
# , htsFile, convert.rb:109:in `block in <main>'
# hts_close, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# hts_get_format, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# , htsFormat, convert.rb:109:in `block in <main>'
# hts_format_file_extension, htsFormat, convert.rb:100:in `block (2 levels) in <main>'
# hts_set_opt, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# hts_set_opt, :enum, convert.rb:104:in `block (2 levels) in <main>'
# hts_getline, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# hts_getline, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# , :pointer, convert.rb:109:in `block in <main>'
# , :pointer, convert.rb:109:in `block in <main>'
# hts_set_threads, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# hts_set_thread_pool, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# hts_set_thread_pool, htsThreadPool, convert.rb:100:in `block (2 levels) in <main>'
# hts_set_cache_size, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# hts_set_fai_filename, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# hts_set_filter_expression, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# hts_check_EOF, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# , hts_idx_t, convert.rb:109:in `block in <main>'
# hts_idx_destroy, hts_idx_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_idx_push, hts_idx_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_idx_push, hts_pos_t, convert.rb:104:in `block (2 levels) in <main>'
# hts_idx_push, hts_pos_t, convert.rb:104:in `block (2 levels) in <main>'
# hts_idx_finish, hts_idx_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_idx_fmt, hts_idx_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_idx_tbi_name, hts_idx_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_idx_save, hts_idx_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_idx_save_as, hts_idx_t, convert.rb:100:in `block (2 levels) in <main>'
# , hts_idx_t, convert.rb:109:in `block in <main>'
# , hts_idx_t, convert.rb:109:in `block in <main>'
# , hts_idx_t, convert.rb:109:in `block in <main>'
# hts_idx_get_meta, hts_idx_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_idx_set_meta, hts_idx_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_idx_get_stat, hts_idx_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_idx_get_n_no_coor, hts_idx_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_parse_reg64, hts_pos_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_parse_reg64, hts_pos_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_parse_region, hts_pos_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_parse_region, hts_pos_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_parse_region, hts_name2id_f, convert.rb:104:in `block (2 levels) in <main>'
# hts_itr_query, hts_idx_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_itr_query, hts_pos_t, convert.rb:104:in `block (2 levels) in <main>'
# hts_itr_query, hts_pos_t, convert.rb:104:in `block (2 levels) in <main>'
# hts_itr_query, :function-pointer, convert.rb:104:in `block (2 levels) in <main>'
# , hts_itr_t, convert.rb:109:in `block in <main>'
# hts_itr_destroy, hts_itr_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_itr_querys, hts_idx_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_itr_querys, hts_name2id_f, convert.rb:104:in `block (2 levels) in <main>'
# hts_itr_querys, :function-pointer, convert.rb:104:in `block (2 levels) in <main>'
# hts_itr_querys, :function-pointer, convert.rb:104:in `block (2 levels) in <main>'
# , hts_itr_t, convert.rb:109:in `block in <main>'
# hts_itr_next, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# hts_itr_next, hts_itr_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_idx_seqnames, hts_idx_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_idx_seqnames, hts_id2name_f, convert.rb:104:in `block (2 levels) in <main>'
# , :pointer, convert.rb:109:in `block in <main>'
# hts_itr_multi_bam, hts_idx_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_itr_multi_bam, hts_itr_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_itr_multi_cram, hts_idx_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_itr_multi_cram, hts_itr_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_itr_regions, hts_idx_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_itr_regions, hts_reglist_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_itr_regions, hts_name2id_f, convert.rb:104:in `block (2 levels) in <main>'
# hts_itr_regions, :function-pointer, convert.rb:104:in `block (2 levels) in <main>'
# hts_itr_regions, :function-pointer, convert.rb:104:in `block (2 levels) in <main>'
# hts_itr_regions, :function-pointer, convert.rb:104:in `block (2 levels) in <main>'
# hts_itr_regions, :function-pointer, convert.rb:104:in `block (2 levels) in <main>'
# , hts_itr_t, convert.rb:109:in `block in <main>'
# hts_itr_multi_next, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# hts_itr_multi_next, hts_itr_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_reglist_create, hts_name2id_f, convert.rb:104:in `block (2 levels) in <main>'
# , hts_reglist_t, convert.rb:109:in `block in <main>'
# hts_reglist_free, hts_reglist_t, convert.rb:100:in `block (2 levels) in <main>'
# , errmod_t, convert.rb:109:in `block in <main>'
# errmod_destroy, errmod_t, convert.rb:100:in `block (2 levels) in <main>'
# errmod_cal, errmod_t, convert.rb:100:in `block (2 levels) in <main>'
# probaln_glocal, probaln_par_t, convert.rb:100:in `block (2 levels) in <main>'
# , hts_md5_context, convert.rb:109:in `block in <main>'
# hts_md5_update, hts_md5_context, convert.rb:100:in `block (2 levels) in <main>'
# hts_md5_final, :unsigned-char, convert.rb:100:in `block (2 levels) in <main>'
# hts_md5_final, hts_md5_context, convert.rb:100:in `block (2 levels) in <main>'
# hts_md5_reset, hts_md5_context, convert.rb:100:in `block (2 levels) in <main>'
# hts_md5_hex, :unsigned-char, convert.rb:100:in `block (2 levels) in <main>'
# hts_md5_destroy, hts_md5_context, convert.rb:100:in `block (2 levels) in <main>'
# hts_reg2bin, hts_pos_t, convert.rb:104:in `block (2 levels) in <main>'
# hts_reg2bin, hts_pos_t, convert.rb:104:in `block (2 levels) in <main>'
# , bcf_hdr_t, convert.rb:109:in `block in <main>'
# bcf_hdr_destroy, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# , bcf1_t, convert.rb:109:in `block in <main>'
# bcf_destroy, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_empty, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_clear, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_read, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# , bcf_hdr_t, convert.rb:109:in `block in <main>'
# bcf_hdr_set_samples, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_subset_format, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_subset_format, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_write, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_write, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# vcf_parse, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# vcf_parse, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# vcf_parse, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# vcf_format, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# vcf_format, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# vcf_format, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_read, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# bcf_read, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_read, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_unpack, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_dup, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# , bcf1_t, convert.rb:109:in `block in <main>'
# bcf_copy, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_copy, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# , bcf1_t, convert.rb:109:in `block in <main>'
# bcf_write, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# bcf_write, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_write, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# vcf_hdr_read, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# , bcf_hdr_t, convert.rb:109:in `block in <main>'
# vcf_hdr_write, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# vcf_hdr_write, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# vcf_read, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# vcf_read, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# vcf_read, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# vcf_write, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# vcf_write, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# vcf_write, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_readrec, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bcf_readrec, hts_pos_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_readrec, hts_pos_t, convert.rb:100:in `block (2 levels) in <main>'
# vcf_write_line, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# vcf_write_line, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_dup, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# , bcf_hdr_t, convert.rb:109:in `block in <main>'
# bcf_hdr_combine, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_combine, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_merge, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_merge, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# , bcf_hdr_t, convert.rb:109:in `block in <main>'
# bcf_hdr_add_sample, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_set, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_format, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_format, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_fmt_text, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_append, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_printf, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_get_version, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_set_version, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_remove, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_subset, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# , bcf_hdr_t, convert.rb:109:in `block in <main>'
# bcf_hdr_seqnames, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# , :pointer, convert.rb:109:in `block in <main>'
# bcf_hdr_parse, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_sync, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_parse_line, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# , bcf_hrec_t, convert.rb:109:in `block in <main>'
# bcf_hrec_format, bcf_hrec_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hrec_format, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_add_hrec, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_add_hrec, bcf_hrec_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_get_hrec, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# , bcf_hrec_t, convert.rb:109:in `block in <main>'
# bcf_hrec_dup, bcf_hrec_t, convert.rb:100:in `block (2 levels) in <main>'
# , bcf_hrec_t, convert.rb:109:in `block in <main>'
# bcf_hrec_add_key, bcf_hrec_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hrec_set_val, bcf_hrec_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hrec_find_key, bcf_hrec_t, convert.rb:100:in `block (2 levels) in <main>'
# hrec_add_idx, bcf_hrec_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hrec_destroy, bcf_hrec_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_subset, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_subset, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_translate, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_translate, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_translate, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_get_variant_types, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_get_variant_type, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_is_snp, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_update_filter, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_update_filter, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_add_filter, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_add_filter, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_remove_filter, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_remove_filter, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_has_filter, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_has_filter, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_update_alleles, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_update_alleles, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_update_alleles_str, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_update_alleles_str, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_update_id, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_update_id, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_add_id, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_add_id, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_update_info, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_update_info, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_update_info_int64, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_update_info_int64, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_update_format_string, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_update_format_string, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_update_format, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_update_format, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_get_fmt, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_get_fmt, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# , bcf_fmt_t, convert.rb:109:in `block in <main>'
# bcf_get_info, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_get_info, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# , bcf_info_t, convert.rb:109:in `block in <main>'
# bcf_get_fmt_id, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# , bcf_fmt_t, convert.rb:109:in `block in <main>'
# bcf_get_info_id, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# , bcf_info_t, convert.rb:109:in `block in <main>'
# bcf_get_info_values, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_get_info_values, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_get_info_int64, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_get_info_int64, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_get_format_string, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_get_format_string, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_get_format_string, :pointer, convert.rb:97:in `block (2 levels) in <main>'
# bcf_get_format_values, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_get_format_values, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_id2int, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_name2id, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_hdr_id2name, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_seqname, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_seqname, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_seqname_safe, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_seqname_safe, bcf1_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_fmt_array, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_fmt_sized_array, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_enc_vchar, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_enc_vint, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_enc_vfloat, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_itr_next, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# bcf_itr_next, hts_itr_t, convert.rb:100:in `block (2 levels) in <main>'
# , hts_idx_t, convert.rb:109:in `block in <main>'
# , hts_idx_t, convert.rb:109:in `block in <main>'
# bcf_idx_init, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# bcf_idx_init, bcf_hdr_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_idx_save, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# bcf_format_gt, bcf_fmt_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_format_gt, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_enc_size, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_enc_int1, kstring_t, convert.rb:100:in `block (2 levels) in <main>'
# tbx_name2id, tbx_t, convert.rb:100:in `block (2 levels) in <main>'
# hts_get_bgzfp, htsFile, convert.rb:100:in `block (2 levels) in <main>'
# , BGZF, convert.rb:109:in `block in <main>'
# tbx_readrec, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# tbx_readrec, hts_pos_t, convert.rb:100:in `block (2 levels) in <main>'
# tbx_readrec, hts_pos_t, convert.rb:100:in `block (2 levels) in <main>'
# tbx_index, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# tbx_index, tbx_conf_t, convert.rb:100:in `block (2 levels) in <main>'
# , tbx_t, convert.rb:109:in `block in <main>'
# tbx_index_build, tbx_conf_t, convert.rb:100:in `block (2 levels) in <main>'
# tbx_index_build2, tbx_conf_t, convert.rb:100:in `block (2 levels) in <main>'
# tbx_index_build3, tbx_conf_t, convert.rb:100:in `block (2 levels) in <main>'
# , tbx_t, convert.rb:109:in `block in <main>'
# , tbx_t, convert.rb:109:in `block in <main>'
# , tbx_t, convert.rb:109:in `block in <main>'
# tbx_seqnames, tbx_t, convert.rb:100:in `block (2 levels) in <main>'
# , :pointer, convert.rb:109:in `block in <main>'
# tbx_destroy, tbx_t, convert.rb:100:in `block (2 levels) in <main>'
# , bcf_srs_t, convert.rb:109:in `block in <main>'
# bcf_sr_destroy, bcf_srs_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_sr_set_opt, bcf_srs_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_sr_set_opt, bcf_sr_opt_t, convert.rb:104:in `block (2 levels) in <main>'
# bcf_sr_set_threads, bcf_srs_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_sr_destroy_threads, bcf_srs_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_sr_add_reader, bcf_srs_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_sr_remove_reader, bcf_srs_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_sr_next_line, bcf_srs_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_sr_seek, bcf_srs_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_sr_seek, hts_pos_t, convert.rb:104:in `block (2 levels) in <main>'
# bcf_sr_set_samples, bcf_srs_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_sr_set_targets, bcf_srs_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_sr_set_regions, bcf_srs_t, convert.rb:100:in `block (2 levels) in <main>'
# , bcf_sr_regions_t, convert.rb:109:in `block in <main>'
# bcf_sr_regions_destroy, bcf_sr_regions_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_sr_regions_seek, bcf_sr_regions_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_sr_regions_next, bcf_sr_regions_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_sr_regions_overlap, bcf_sr_regions_t, convert.rb:100:in `block (2 levels) in <main>'
# bcf_sr_regions_overlap, hts_pos_t, convert.rb:104:in `block (2 levels) in <main>'
# bcf_sr_regions_overlap, hts_pos_t, convert.rb:104:in `block (2 levels) in <main>'
# bcf_sr_regions_flush, bcf_sr_regions_t, convert.rb:100:in `block (2 levels) in <main>'
