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

# Unknow types
# ["__time_t", "__suseconds_t", "__syscall_slong_t", ":pointer", "__pthread_list_t", ":array", "union", ":long-double", "fd_set", ":struct", "__sigset_t", ":function-pointer", "__compar_fn_t", "div_t", "ldiv_t", "lldiv_t", "wchar_t", "locale_t", "kbitset_t", "kbitset_iter_t"]
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
# kbitset_t, :array, convert.rb:79:in `block (2 levels) in <main>'
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
# , kbitset_t, convert.rb:109:in `block in <main>'
# , kbitset_t, convert.rb:109:in `block in <main>'
# kbs_resize2, kbitset_t, convert.rb:97:in `block (2 levels) in <main>'
# kbs_resize, kbitset_t, convert.rb:97:in `block (2 levels) in <main>'
# kbs_destroy, kbitset_t, convert.rb:100:in `block (2 levels) in <main>'
# kbs_clear, kbitset_t, convert.rb:100:in `block (2 levels) in <main>'
# kbs_insert_all, kbitset_t, convert.rb:100:in `block (2 levels) in <main>'
# kbs_insert, kbitset_t, convert.rb:100:in `block (2 levels) in <main>'
# kbs_delete, kbitset_t, convert.rb:100:in `block (2 levels) in <main>'
# kbs_exists, kbitset_t, convert.rb:100:in `block (2 levels) in <main>'
# kbs_start, kbitset_iter_t, convert.rb:100:in `block (2 levels) in <main>'
# kbs_next, kbitset_t, convert.rb:100:in `block (2 levels) in <main>'
# kbs_next, kbitset_iter_t, convert.rb:100:in `block (2 levels) in <main>'
