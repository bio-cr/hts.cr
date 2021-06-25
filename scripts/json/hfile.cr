struct LocaleStruct
  __locales : 
  __ctype_b : 
  __ctype_tolower : 
  __ctype_toupper : 
  __names : 
end

struct LocaleData
end

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

struct HFILEBackend
end

struct KstringT
end

struct HFILE
  buffer : 
  begin : 
  end : 
  limit : 
  backend : 
  offset : 
  at_eof : 
  mobile : 
  readonly : 
  has_errno : Int32
end

# fun memcpy(Void*, Void*, SizeT) : Void*
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
fun __bswap_16(UInt16) : UInt16
fun __bswap_32(UInt32) : UInt32
fun __bswap_64(UInt64) : UInt64
fun __uint16_identity(UInt16) : UInt16
fun __uint32_identity(UInt32) : UInt32
fun __uint64_identity(UInt64) : UInt64
# fun select(Int32, *, *, *, *) : Int32
# fun pselect(Int32, *, *, *, *, *) : Int32
# fun hopen(UInt8*, UInt8*) : *
# fun hdopen(Int32, UInt8*) : *
fun hisremote(UInt8*) : Int32
# fun haddextension(*, UInt8*, Int32, UInt8*) : UInt8*
# fun hclose(*) : Int32
# fun hclose_abruptly(*) : Void
# fun herrno(*) : Int32
# fun hclearerr(*) : Void
# fun hseek(*, , Int32) : 
# fun htell(*) : 
# fun hgetc(*) : Int32
# fun hgetdelim(UInt8*, SizeT, Int32, *) : SSizeT
# fun hgetln(UInt8*, SizeT, *) : SSizeT
# fun hgets(UInt8*, Int32, *) : UInt8*
# fun hpeek(*, Void*, SizeT) : SSizeT
# fun hread(*, Void*, SizeT) : SSizeT
# fun hputc(Int32, *) : Int32
# fun hputs(UInt8*, *) : Int32
# fun hwrite(*, Void*, SizeT) : SSizeT
# fun hflush(*) : Int32
# fun hfile_mem_get_buffer(*, SizeT*) : UInt8*
# fun hfile_mem_steal_buffer(*, SizeT*) : UInt8*
fun hfile_list_schemes(UInt8*, UInt8**, Int32*) : Int32
fun hfile_list_plugins(UInt8**, Int32*) : Int32
fun hfile_has_plugin(UInt8*) : Int32

# Unknow types
# [":array", ":pointer", "__time_t", "__suseconds_t", "__syscall_slong_t", "__pthread_list_t", "union", "off_t", ":bitfield", "locale_t", "fd_set", ":struct", "__sigset_t", "hFILE", "struct"]
# caller
# __locale_struct, :array, convert.rb:79:in `block (2 levels) in <main>'
# __locale_struct, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# __locale_struct, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# __locale_struct, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# __locale_struct, :array, convert.rb:79:in `block (2 levels) in <main>'
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
# hFILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# hFILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# hFILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# hFILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# hFILE, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# hFILE, off_t, convert.rb:79:in `block (2 levels) in <main>'
# hFILE, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# hFILE, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# hFILE, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# strcoll_l, locale_t, convert.rb:104:in `block (2 levels) in <main>'
# strxfrm_l, locale_t, convert.rb:104:in `block (2 levels) in <main>'
# strerror_l, locale_t, convert.rb:104:in `block (2 levels) in <main>'
# strcasecmp_l, locale_t, convert.rb:104:in `block (2 levels) in <main>'
# strncasecmp_l, locale_t, convert.rb:104:in `block (2 levels) in <main>'
# select, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# select, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# select, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# select, :struct, convert.rb:100:in `block (2 levels) in <main>'
# pselect, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# pselect, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# pselect, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# pselect, :struct, convert.rb:100:in `block (2 levels) in <main>'
# pselect, __sigset_t, convert.rb:100:in `block (2 levels) in <main>'
# , hFILE, convert.rb:109:in `block in <main>'
# , hFILE, convert.rb:109:in `block in <main>'
# haddextension, struct, convert.rb:100:in `block (2 levels) in <main>'
# hclose, hFILE, convert.rb:100:in `block (2 levels) in <main>'
# hclose_abruptly, hFILE, convert.rb:100:in `block (2 levels) in <main>'
# herrno, hFILE, convert.rb:100:in `block (2 levels) in <main>'
# hclearerr, hFILE, convert.rb:100:in `block (2 levels) in <main>'
# hseek, hFILE, convert.rb:100:in `block (2 levels) in <main>'
# hseek, off_t, convert.rb:104:in `block (2 levels) in <main>'
# hseek, off_t, convert.rb:112:in `block in <main>'
# htell, hFILE, convert.rb:100:in `block (2 levels) in <main>'
# htell, off_t, convert.rb:112:in `block in <main>'
# hgetc, hFILE, convert.rb:100:in `block (2 levels) in <main>'
# hgetdelim, hFILE, convert.rb:100:in `block (2 levels) in <main>'
# hgetln, hFILE, convert.rb:100:in `block (2 levels) in <main>'
# hgets, hFILE, convert.rb:100:in `block (2 levels) in <main>'
# hpeek, hFILE, convert.rb:100:in `block (2 levels) in <main>'
# hread, hFILE, convert.rb:100:in `block (2 levels) in <main>'
# hputc, hFILE, convert.rb:100:in `block (2 levels) in <main>'
# hputs, hFILE, convert.rb:100:in `block (2 levels) in <main>'
# hwrite, hFILE, convert.rb:100:in `block (2 levels) in <main>'
# hflush, hFILE, convert.rb:100:in `block (2 levels) in <main>'
# hfile_mem_get_buffer, hFILE, convert.rb:100:in `block (2 levels) in <main>'
# hfile_mem_steal_buffer, hFILE, convert.rb:100:in `block (2 levels) in <main>'
