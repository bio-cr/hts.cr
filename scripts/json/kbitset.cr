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



struct KbitsetT
  n : SizeT
  n_max : SizeT
  b : 
end

struct KbitsetIterT
  mask : ULong
  elt : SizeT
  i : Int32
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
fun kbs_last_mask(SizeT) : ULong
# fun kbs_init2(SizeT, Int32) : *
# fun kbs_init(SizeT) : *
# fun kbs_resize2(**, SizeT, Int32) : Int32
# fun kbs_resize(**, SizeT) : Int32
# fun kbs_destroy(*) : Void
# fun kbs_clear(*) : Void
# fun kbs_insert_all(*) : Void
# fun kbs_insert(*, Int32) : Void
# fun kbs_delete(*, Int32) : Void
# fun kbs_exists(*, Int32) : Int32
# fun kbs_start(*) : Void
# fun kbs_next(*, *) : Int32

# Unknown types
# ["__time_t", "__suseconds_t", "__syscall_slong_t", ":array", ":long-double", "fd_set", ":struct", "__sigset_t", ":function-pointer", "__compar_fn_t", "div_t", "ldiv_t", "lldiv_t", "wchar_t", "locale_t", "kbitset_t", "kbitset_iter_t"]
# timeval, __time_t
# timeval, __suseconds_t
# timespec, __time_t
# timespec, __syscall_slong_t
# drand48_data, :array
# drand48_data, :array
# kbitset_t, :array
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
# kbs_init2, kbitset_t
# kbs_init, kbitset_t
# kbs_resize2, kbitset_t
# kbs_resize, kbitset_t
# kbs_destroy, kbitset_t
# kbs_clear, kbitset_t
# kbs_insert_all, kbitset_t
# kbs_insert, kbitset_t
# kbs_delete, kbitset_t
# kbs_exists, kbitset_t
# kbs_start, kbitset_iter_t
# kbs_next, kbitset_t
# kbs_next, kbitset_iter_t
