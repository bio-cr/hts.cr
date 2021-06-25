

struct Timeval
  tv_sec : 
  tv_usec : 
end

struct Timespec
  tv_sec : 
  tv_nsec : 
end






struct HFILEBackend
end

struct KstringT
end

struct HFILE
  buffer : LibC::Char*
  begin : LibC::Char*
  end : LibC::Char*
  limit : LibC::Char*
  backend : *
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
fun __bswap_16(UInt16) : UInt16
fun __bswap_32(UInt32) : UInt32
fun __bswap_64(UInt64) : UInt64
fun __uint16_identity(UInt16) : UInt16
fun __uint32_identity(UInt32) : UInt32
fun __uint64_identity(UInt64) : UInt64
# fun select(Int32, *, *, *, *) : Int32
# fun pselect(Int32, *, *, *, *, *) : Int32
# fun hopen(LibC::Char*, LibC::Char*) : *
# fun hdopen(Int32, LibC::Char*) : *
fun hisremote(LibC::Char*) : Int32
# fun haddextension(*, LibC::Char*, Int32, LibC::Char*) : LibC::Char*
# fun hclose(*) : Int32
# fun hclose_abruptly(*) : Void
# fun herrno(*) : Int32
# fun hclearerr(*) : Void
# fun hseek(*, , Int32) : 
# fun htell(*) : 
# fun hgetc(*) : Int32
# fun hgetdelim(LibC::Char*, SizeT, Int32, *) : SSizeT
# fun hgetln(LibC::Char*, SizeT, *) : SSizeT
# fun hgets(LibC::Char*, Int32, *) : LibC::Char*
# fun hpeek(*, Void*, SizeT) : SSizeT
# fun hread(*, Void*, SizeT) : SSizeT
# fun hputc(Int32, *) : Int32
# fun hputs(LibC::Char*, *) : Int32
# fun hwrite(*, Void*, SizeT) : SSizeT
# fun hflush(*) : Int32
# fun hfile_mem_get_buffer(*, SizeT*) : LibC::Char*
# fun hfile_mem_steal_buffer(*, SizeT*) : LibC::Char*
fun hfile_list_schemes(LibC::Char*, LibC::Char**, Int32*) : Int32
fun hfile_list_plugins(LibC::Char**, Int32*) : Int32
fun hfile_has_plugin(LibC::Char*) : Int32

# Unknown types
# ["__time_t", "__suseconds_t", "__syscall_slong_t", "struct", "off_t", ":bitfield", "locale_t", "fd_set", ":struct", "__sigset_t", "hFILE"]
# timeval, __time_t
# timeval, __suseconds_t
# timespec, __time_t
# timespec, __syscall_slong_t
# hFILE, struct
# hFILE, off_t
# hFILE, :bitfield
# hFILE, :bitfield
# hFILE, :bitfield
# strcoll_l, locale_t
# strxfrm_l, locale_t
# strerror_l, locale_t
# strcasecmp_l, locale_t
# strncasecmp_l, locale_t
# select, fd_set
# select, fd_set
# select, fd_set
# select, :struct
# pselect, fd_set
# pselect, fd_set
# pselect, fd_set
# pselect, :struct
# pselect, __sigset_t
# hopen, hFILE
# hdopen, hFILE
# haddextension, struct
# hclose, hFILE
# hclose_abruptly, hFILE
# herrno, hFILE
# hclearerr, hFILE
# hseek, hFILE
# hseek, off_t
# hseek, off_t
# htell, hFILE
# htell, off_t
# hgetc, hFILE
# hgetdelim, hFILE
# hgetln, hFILE
# hgets, hFILE
# hpeek, hFILE
# hread, hFILE
# hputc, hFILE
# hputs, hFILE
# hwrite, hFILE
# hflush, hFILE
# hfile_mem_get_buffer, hFILE
# hfile_mem_steal_buffer, hFILE
