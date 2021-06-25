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

struct HtsExprValT
  is_str : LibC::Char
  is_true : LibC::Char
  s : 
  d : Float64
end

struct HtsFilterT
end
# fun __ctype_get_mb_cur_max() : SizeT
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
# fun hts_expr_val_free(*) : Void
# fun hts_filter_init(LibC::Char*) : *
# fun hts_filter_free(*) : Void
# fun hts_filter_eval(*, Void*, , *) : Int32

# Unknown types
# ["__time_t", "__suseconds_t", "__syscall_slong_t", ":array", "kstring_t", ":long-double", "fd_set", ":struct", "__sigset_t", ":function-pointer", "__compar_fn_t", "div_t", "ldiv_t", "lldiv_t", "wchar_t", "locale_t", "FILE", "__gnuc_va_list", "__off_t", "fpos_t", "va_list", "ks_tokaux_t", "hts_expr_val_t", "hts_filter_t"]
# timeval, __time_t
# timeval, __suseconds_t
# timespec, __time_t
# timespec, __syscall_slong_t
# drand48_data, :array
# drand48_data, :array
# ks_tokaux_t, :array
# hts_expr_val_t, kstring_t
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
# hts_expr_val_free, hts_expr_val_t
# hts_filter_init, hts_filter_t
# hts_filter_free, hts_filter_t
# hts_filter_eval, hts_filter_t
# hts_filter_eval, :function-pointer
# hts_filter_eval, hts_expr_val_t
