struct Timeval
  tv_sec : 
  tv_usec : 
end

struct Timespec
  tv_sec : 
  tv_nsec : 
end






struct RandomData
  fptr : Int32*
  rptr : Int32*
  state : Int32*
  rand_type : Int32
  rand_deg : Int32
  rand_sep : Int32
  end_ptr : Int32*
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
  s : LibC::Char*
end

struct KsTokauxT
  tab : 
  sep : Int32
  finished : Int32
  p : LibC::Char*
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
  specific : Void*
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
  fn : LibC::Char*
  fn_aux : LibC::Char*
  fp : 
  state : Void*
  format : 
  idx : *
  fnidx : LibC::Char*
  bam_header : *
  filter : *
end

struct HtsThreadPool
  pool : *
  qsize : Int32
end

struct HtsOpt
  arg : LibC::Char*
  opt : 
  val : 
  next : *
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
  reg : LibC::Char*
  intervals : *
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
  reg_list : *
  curr_tid : Int32
  curr_reg : Int32
  curr_intv : Int32
  curr_beg : 
  curr_end : 
  curr_off : UInt64
  nocoor_off : UInt64
  off : *
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
  idx : *
  dict : Void*
end
# fun imaxabs() : 
# fun imaxdiv(, ) : 
# fun strtoimax(LibC::Char*, LibC::Char**, Int32) : 
# fun strtoumax(LibC::Char*, LibC::Char**, Int32) : 
# fun wcstoimax(*, **, Int32) : 
# fun wcstoumax(*, **, Int32) : 
# fun hts_set_log_level() : Void
# fun hts_get_log_level() : 
# fun hts_log(, LibC::Char*, LibC::Char*) : Void
fun __ctype_get_mb_cur_max() : SizeT
fun atof(LibC::Char*) : Float64
fun atoi(LibC::Char*) : Int32
fun atol(LibC::Char*) : Long
fun atoll(LibC::Char*) : LongLong
fun strtod(LibC::Char*, LibC::Char**) : Float64
fun strtof(LibC::Char*, LibC::Char**) : Float32
# fun strtold(LibC::Char*, LibC::Char**) : 
fun strtol(LibC::Char*, LibC::Char**, Int32) : Long
fun strtoul(LibC::Char*, LibC::Char**, Int32) : ULong
fun strtoq(LibC::Char*, LibC::Char**, Int32) : LongLong
fun strtouq(LibC::Char*, LibC::Char**, Int32) : ULongLong
fun strtoll(LibC::Char*, LibC::Char**, Int32) : LongLong
fun strtoull(LibC::Char*, LibC::Char**, Int32) : ULongLong
fun l64a(Long) : LibC::Char*
fun a64l(LibC::Char*) : Long
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
fun initstate(UInt32, LibC::Char*, SizeT) : LibC::Char*
fun setstate(LibC::Char*) : LibC::Char*
# fun random_r(*, Int32*) : Int32
# fun srandom_r(UInt32, *) : Int32
# fun initstate_r(UInt32, LibC::Char*, SizeT, *) : Int32
# fun setstate_r(LibC::Char*, *) : Int32
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
fun getenv(LibC::Char*) : LibC::Char*
fun putenv(LibC::Char*) : Int32
fun setenv(LibC::Char*, LibC::Char*, Int32) : Int32
fun unsetenv(LibC::Char*) : Int32
fun clearenv() : Int32
fun mktemp(LibC::Char*) : LibC::Char*
fun mkstemp(LibC::Char*) : Int32
fun mkstemps(LibC::Char*, Int32) : Int32
fun mkdtemp(LibC::Char*) : LibC::Char*
fun system(LibC::Char*) : Int32
fun realpath(LibC::Char*, LibC::Char*) : LibC::Char*
# fun bsearch(Void*, Void*, SizeT, SizeT, ) : Void*
# fun qsort(Void*, SizeT, SizeT, ) : Void
fun abs(Int32) : Int32
fun labs(Long) : Long
fun llabs(LongLong) : LongLong
# fun div(Int32, Int32) : 
# fun ldiv(Long, Long) : 
# fun lldiv(LongLong, LongLong) : 
fun ecvt(Float64, Int32, Int32*, Int32*) : LibC::Char*
fun fcvt(Float64, Int32, Int32*, Int32*) : LibC::Char*
fun gcvt(Float64, Int32, LibC::Char*) : LibC::Char*
# fun qecvt(, Int32, Int32*, Int32*) : LibC::Char*
# fun qfcvt(, Int32, Int32*, Int32*) : LibC::Char*
# fun qgcvt(, Int32, LibC::Char*) : LibC::Char*
fun ecvt_r(Float64, Int32, Int32*, Int32*, LibC::Char*, SizeT) : Int32
fun fcvt_r(Float64, Int32, Int32*, Int32*, LibC::Char*, SizeT) : Int32
# fun qecvt_r(, Int32, Int32*, Int32*, LibC::Char*, SizeT) : Int32
# fun qfcvt_r(, Int32, Int32*, Int32*, LibC::Char*, SizeT) : Int32
fun mblen(LibC::Char*, SizeT) : Int32
# fun mbtowc(*, LibC::Char*, SizeT) : Int32
# fun wctomb(LibC::Char*, ) : Int32
# fun mbstowcs(*, LibC::Char*, SizeT) : SizeT
# fun wcstombs(LibC::Char*, *, SizeT) : SizeT
fun rpmatch(LibC::Char*) : Int32
fun getsubopt(LibC::Char**, LibC::Char**, LibC::Char**) : Int32
fun getloadavg(Float64*, Int32) : Int32
fun memcpy(Void*, Void*, SizeT) : Void*
fun memmove(Void*, Void*, SizeT) : Void*
fun memccpy(Void*, Void*, Int32, SizeT) : Void*
fun memset(Void*, Int32, SizeT) : Void*
fun memcmp(Void*, Void*, SizeT) : Int32
fun memchr(Void*, Int32, SizeT) : Void*
fun strcpy(LibC::Char*, LibC::Char*) : LibC::Char*
fun strncpy(LibC::Char*, LibC::Char*, SizeT) : LibC::Char*
fun strcat(LibC::Char*, LibC::Char*) : LibC::Char*
fun strncat(LibC::Char*, LibC::Char*, SizeT) : LibC::Char*
fun strcmp(LibC::Char*, LibC::Char*) : Int32
fun strncmp(LibC::Char*, LibC::Char*, SizeT) : Int32
fun strcoll(LibC::Char*, LibC::Char*) : Int32
fun strxfrm(LibC::Char*, LibC::Char*, SizeT) : ULong
# fun strcoll_l(LibC::Char*, LibC::Char*, ) : Int32
# fun strxfrm_l(LibC::Char*, LibC::Char*, SizeT, ) : SizeT
fun strdup(LibC::Char*) : LibC::Char*
fun strndup(LibC::Char*, SizeT) : LibC::Char*
fun strchr(LibC::Char*, Int32) : LibC::Char*
fun strrchr(LibC::Char*, Int32) : LibC::Char*
fun strcspn(LibC::Char*, LibC::Char*) : ULong
fun strspn(LibC::Char*, LibC::Char*) : ULong
fun strpbrk(LibC::Char*, LibC::Char*) : LibC::Char*
fun strstr(LibC::Char*, LibC::Char*) : LibC::Char*
fun strtok(LibC::Char*, LibC::Char*) : LibC::Char*
fun __strtok_r(LibC::Char*, LibC::Char*, LibC::Char**) : LibC::Char*
fun strtok_r(LibC::Char*, LibC::Char*, LibC::Char**) : LibC::Char*
fun strlen(LibC::Char*) : ULong
fun strnlen(LibC::Char*, SizeT) : SizeT
fun strerror(Int32) : LibC::Char*
fun __xpg_strerror_r(Int32, LibC::Char*, SizeT) : Int32
# fun strerror_l(Int32, ) : LibC::Char*
fun bcmp(Void*, Void*, SizeT) : Int32
fun bcopy(Void*, Void*, SizeT) : Void
fun bzero(Void*, SizeT) : Void
fun index(LibC::Char*, Int32) : LibC::Char*
fun rindex(LibC::Char*, Int32) : LibC::Char*
fun ffs(Int32) : Int32
fun ffsl(Long) : Int32
fun ffsll(LongLong) : Int32
fun strcasecmp(LibC::Char*, LibC::Char*) : Int32
fun strncasecmp(LibC::Char*, LibC::Char*, SizeT) : Int32
# fun strcasecmp_l(LibC::Char*, LibC::Char*, ) : Int32
# fun strncasecmp_l(LibC::Char*, LibC::Char*, SizeT, ) : Int32
fun explicit_bzero(Void*, SizeT) : Void
fun strsep(LibC::Char**, LibC::Char*) : LibC::Char*
fun strsignal(Int32) : LibC::Char*
fun __stpcpy(LibC::Char*, LibC::Char*) : LibC::Char*
fun stpcpy(LibC::Char*, LibC::Char*) : LibC::Char*
fun __stpncpy(LibC::Char*, LibC::Char*, SizeT) : LibC::Char*
fun stpncpy(LibC::Char*, LibC::Char*, SizeT) : LibC::Char*
fun remove(LibC::Char*) : Int32
fun rename(LibC::Char*, LibC::Char*) : Int32
fun renameat(Int32, LibC::Char*, Int32, LibC::Char*) : Int32
# fun tmpfile() : *
fun tmpnam(LibC::Char*) : LibC::Char*
fun tmpnam_r(LibC::Char*) : LibC::Char*
fun tempnam(LibC::Char*, LibC::Char*) : LibC::Char*
# fun fclose(*) : Int32
# fun fflush(*) : Int32
# fun fflush_unlocked(*) : Int32
# fun fopen(LibC::Char*, LibC::Char*) : *
# fun freopen(LibC::Char*, LibC::Char*, *) : *
# fun fdopen(Int32, LibC::Char*) : *
# fun fmemopen(Void*, SizeT, LibC::Char*) : *
# fun open_memstream(LibC::Char**, SizeT*) : *
# fun setbuf(*, LibC::Char*) : Void
# fun setvbuf(*, LibC::Char*, Int32, SizeT) : Int32
# fun setbuffer(*, LibC::Char*, SizeT) : Void
# fun setlinebuf(*) : Void
# fun fprintf(*, LibC::Char*) : Int32
fun printf(LibC::Char*) : Int32
fun sprintf(LibC::Char*, LibC::Char*) : Int32
# fun vfprintf(*, LibC::Char*, ) : Int32
# fun vprintf(LibC::Char*, ) : Int32
# fun vsprintf(LibC::Char*, LibC::Char*, ) : Int32
fun snprintf(LibC::Char*, SizeT, LibC::Char*) : Int32
# fun vsnprintf(LibC::Char*, SizeT, LibC::Char*, ) : Int32
# fun vdprintf(Int32, LibC::Char*, ) : Int32
fun dprintf(Int32, LibC::Char*) : Int32
# fun fscanf(*, LibC::Char*) : Int32
fun scanf(LibC::Char*) : Int32
fun sscanf(LibC::Char*, LibC::Char*) : Int32
# fun __isoc99_fscanf(*, LibC::Char*) : Int32
fun __isoc99_scanf(LibC::Char*) : Int32
fun __isoc99_sscanf(LibC::Char*, LibC::Char*) : Int32
# fun vfscanf(*, LibC::Char*, ) : Int32
# fun vscanf(LibC::Char*, ) : Int32
# fun vsscanf(LibC::Char*, LibC::Char*, ) : Int32
# fun __isoc99_vfscanf(*, LibC::Char*, ) : Int32
# fun __isoc99_vscanf(LibC::Char*, ) : Int32
# fun __isoc99_vsscanf(LibC::Char*, LibC::Char*, ) : Int32
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
# fun fgets(LibC::Char*, Int32, *) : LibC::Char*
# fun __getdelim(LibC::Char**, SizeT*, Int32, *) : SSizeT
# fun getdelim(LibC::Char**, SizeT*, Int32, *) : SSizeT
# fun getline(LibC::Char**, SizeT*, *) : SSizeT
# fun fputs(LibC::Char*, *) : Int32
fun puts(LibC::Char*) : Int32
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
fun perror(LibC::Char*) : Void
# fun fileno(*) : Int32
# fun fileno_unlocked(*) : Int32
# fun popen(LibC::Char*, LibC::Char*) : *
# fun pclose(*) : Int32
fun ctermid(LibC::Char*) : LibC::Char*
# fun flockfile(*) : Void
# fun ftrylockfile(*) : Int32
# fun funlockfile(*) : Void
# fun __uflow(*) : Int32
# fun __overflow(*, Int32) : Int32
fun __errno_location() : Int32*
# fun kvsprintf(*, LibC::Char*, ) : Int32
# fun ksprintf(*, LibC::Char*) : Int32
# fun kputd(Float64, *) : Int32
fun ksplit_core(LibC::Char*, Int32, Int32*, Int32**) : Int32
fun kstrstr(LibC::Char*, LibC::Char*, Int32**) : LibC::Char*
fun kstrnstr(LibC::Char*, LibC::Char*, Int32, Int32**) : LibC::Char*
fun kmemmem(Void*, Int32, Void*, Int32, Int32**) : Void*
# fun kstrtok(LibC::Char*, LibC::Char*, *) : LibC::Char*
# fun kgetline(*, , Void*) : Int32
# fun kgetline2(*, , Void*) : Int32
# fun ks_initialize(*) : Void
# fun ks_resize(*, SizeT) : Int32
# fun ks_expand(*, SizeT) : Int32
# fun ks_str(*) : LibC::Char*
# fun ks_c_str(*) : LibC::Char*
# fun ks_len(*) : SizeT
# fun ks_clear(*) : *
# fun ks_release(*) : LibC::Char*
# fun ks_free(*) : Void
# fun kputsn(LibC::Char*, SizeT, *) : Int32
# fun kputs(LibC::Char*, *) : Int32
# fun kputc(Int32, *) : Int32
# fun kputc_(Int32, *) : Int32
# fun kputsn_(Void*, SizeT, *) : Int32
# fun kputuw(UInt32, *) : Int32
# fun kputw(Int32, *) : Int32
# fun kputll(LongLong, *) : Int32
# fun kputl(Long, *) : Int32
# fun ksplit(*, Int32, Int32*) : Int32*
fun hts_resize_array_(SizeT, SizeT, SizeT, Void*, Void**, Int32, LibC::Char*) : Int32
fun hts_lib_shutdown() : Void
fun hts_free(Void*) : Void
# fun hts_opt_add(**, LibC::Char*) : Int32
# fun hts_opt_apply(*, *) : Int32
# fun hts_opt_free(*) : Void
# fun hts_parse_format(*, LibC::Char*) : Int32
# fun hts_parse_opt_list(*, LibC::Char*) : Int32
fun hts_version() : LibC::Char*
fun hts_features() : UInt32
fun hts_test_feature(UInt32) : LibC::Char*
fun hts_feature_string() : LibC::Char*
# fun hts_detect_format(*, *) : Int32
# fun hts_format_description(*) : LibC::Char*
# fun hts_open(LibC::Char*, LibC::Char*) : *
# fun hts_open_format(LibC::Char*, LibC::Char*, *) : *
# fun hts_hopen(*, LibC::Char*, LibC::Char*) : *
# fun hts_close(*) : Int32
# fun hts_get_format(*) : *
# fun hts_format_file_extension(*) : LibC::Char*
# fun hts_set_opt(*, ) : Int32
# fun hts_getline(*, Int32, *) : Int32
# fun hts_readlines(LibC::Char*, Int32*) : *
# fun hts_readlist(LibC::Char*, Int32, Int32*) : *
# fun hts_set_threads(*, Int32) : Int32
# fun hts_set_thread_pool(*, *) : Int32
# fun hts_set_cache_size(*, Int32) : Void
# fun hts_set_fai_filename(*, LibC::Char*) : Int32
# fun hts_set_filter_expression(*, LibC::Char*) : Int32
# fun hts_check_EOF(*) : Int32
# fun hts_idx_init(Int32, Int32, UInt64, Int32, Int32) : *
# fun hts_idx_destroy(*) : Void
# fun hts_idx_push(*, Int32, , , UInt64, Int32) : Int32
# fun hts_idx_finish(*, UInt64) : Int32
# fun hts_idx_fmt(*) : Int32
# fun hts_idx_tbi_name(*, Int32, LibC::Char*) : Int32
# fun hts_idx_save(*, LibC::Char*, Int32) : Int32
# fun hts_idx_save_as(*, LibC::Char*, LibC::Char*, Int32) : Int32
# fun hts_idx_load(LibC::Char*, Int32) : *
# fun hts_idx_load2(LibC::Char*, LibC::Char*) : *
# fun hts_idx_load3(LibC::Char*, LibC::Char*, Int32, Int32) : *
# fun hts_idx_get_meta(*, UInt32*) : UInt8*
# fun hts_idx_set_meta(*, UInt32, UInt8*, Int32) : Int32
# fun hts_idx_get_stat(*, Int32, UInt64*, UInt64*) : Int32
# fun hts_idx_get_n_no_coor(*) : UInt64
fun hts_parse_decimal(LibC::Char*, LibC::Char**, Int32) : LongLong
# fun hts_parse_reg64(LibC::Char*, *, *) : LibC::Char*
fun hts_parse_reg(LibC::Char*, Int32*, Int32*) : LibC::Char*
# fun hts_parse_region(LibC::Char*, Int32*, *, *, , Void*, Int32) : LibC::Char*
# fun hts_itr_query(*, Int32, , , ) : *
# fun hts_itr_destroy(*) : Void
# fun hts_itr_querys(*, LibC::Char*, , Void*, , ) : *
# fun hts_itr_next(*, *, Void*, Void*) : Int32
# fun hts_idx_seqnames(*, Int32*, , Void*) : *
# fun hts_itr_multi_bam(*, *) : Int32
# fun hts_itr_multi_cram(*, *) : Int32
# fun hts_itr_regions(*, *, Int32, , Void*, , , , ) : *
# fun hts_itr_multi_next(*, *, Void*) : Int32
# fun hts_reglist_create(LibC::Char**, Int32, Int32*, Void*, ) : *
# fun hts_reglist_free(*, Int32) : Void
fun hts_file_type(LibC::Char*) : Int32
# fun errmod_init(Float64) : *
# fun errmod_destroy(*) : Void
# fun errmod_cal(*, Int32, Int32, UInt16*, Float32*) : Int32
# fun probaln_glocal(UInt8*, Int32, UInt8*, Int32, UInt8*, *, Int32*, UInt8*) : Int32
# fun hts_md5_init() : *
# fun hts_md5_update(*, Void*, ULong) : Void
# fun hts_md5_final(*, *) : Void
# fun hts_md5_reset(*) : Void
# fun hts_md5_hex(LibC::Char*, *) : Void
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
# fun tbx_name2id(*, LibC::Char*) : Int32
# fun hts_get_bgzfp(*) : *
# fun tbx_readrec(*, Void*, Void*, Int32*, *, *) : Int32
# fun tbx_index(*, Int32, *) : *
# fun tbx_index_build(LibC::Char*, Int32, *) : Int32
# fun tbx_index_build2(LibC::Char*, LibC::Char*, Int32, *) : Int32
# fun tbx_index_build3(LibC::Char*, LibC::Char*, Int32, Int32, *) : Int32
# fun tbx_index_load(LibC::Char*) : *
# fun tbx_index_load2(LibC::Char*, LibC::Char*) : *
# fun tbx_index_load3(LibC::Char*, LibC::Char*, Int32) : *
# fun tbx_seqnames(*, Int32*) : *
# fun tbx_destroy(*) : Void

# Unknown types
# ["__time_t", "__suseconds_t", "__syscall_slong_t", ":array", ":enum", "struct", ":bitfield", "kstring_t", "union", "htsFormat", "hts_idx_t", ":struct", "hts_pos_t", "hts_pair_pos_t", "hts_reglist_t", "hts_pair64_max_t", ":function-pointer", "tbx_conf_t", "intmax_t", "imaxdiv_t", "uintmax_t", "__gwchar_t", ":long-double", "fd_set", "__sigset_t", "__compar_fn_t", "div_t", "ldiv_t", "lldiv_t", "wchar_t", "locale_t", "FILE", "__gnuc_va_list", "__off_t", "fpos_t", "va_list", "ks_tokaux_t", "hts_opt", "htsFile", ":pointer", "htsThreadPool", "hts_name2id_f", "hts_itr_t", "BGZF", "hts_id2name_f", "errmod_t", "probaln_par_t", "hts_md5_context", ":unsigned-char", "tbx_t"]
# timeval, __time_t
# timeval, __suseconds_t
# timespec, __time_t
# timespec, __syscall_slong_t
# drand48_data, :array
# drand48_data, :array
# ks_tokaux_t, :array
# htsFormat, :enum
# htsFormat, :enum
# htsFormat, struct
# htsFormat, :enum
# htsFile, :bitfield
# htsFile, :bitfield
# htsFile, :bitfield
# htsFile, :bitfield
# htsFile, :bitfield
# htsFile, :bitfield
# htsFile, kstring_t
# htsFile, union
# htsFile, htsFormat
# htsFile, hts_idx_t
# htsFile, struct
# htsFile, struct
# htsThreadPool, struct
# hts_opt, :enum
# hts_opt, union
# hts_opt, :struct
# hts_pair_pos_t, hts_pos_t
# hts_pair_pos_t, hts_pos_t
# hts_reglist_t, hts_pair_pos_t
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
# hts_itr_t, hts_reglist_t
# hts_itr_t, hts_pos_t
# hts_itr_t, hts_pos_t
# hts_itr_t, hts_pair64_max_t
# hts_itr_t, :function-pointer
# hts_itr_t, :function-pointer
# hts_itr_t, :function-pointer
# hts_itr_t, struct
# tbx_t, tbx_conf_t
# tbx_t, hts_idx_t
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
# tbx_name2id, tbx_t
# hts_get_bgzfp, htsFile
# hts_get_bgzfp, BGZF
# tbx_readrec, BGZF
# tbx_readrec, hts_pos_t
# tbx_readrec, hts_pos_t
# tbx_index, BGZF
# tbx_index, tbx_conf_t
# tbx_index, tbx_t
# tbx_index_build, tbx_conf_t
# tbx_index_build2, tbx_conf_t
# tbx_index_build3, tbx_conf_t
# tbx_index_load, tbx_t
# tbx_index_load2, tbx_t
# tbx_index_load3, tbx_t
# tbx_seqnames, tbx_t
# tbx_seqnames, :pointer
# tbx_destroy, tbx_t
