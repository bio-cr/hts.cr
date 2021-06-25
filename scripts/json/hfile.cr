

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

# Unknown types
# ["__time_t", "__suseconds_t", "__syscall_slong_t", ":pointer", "off_t", ":bitfield", "locale_t", "fd_set", ":struct", "__sigset_t", "hFILE", "struct"]
# timeval, __time_t
# timeval, __suseconds_t
# timespec, __time_t
# timespec, __syscall_slong_t
# hFILE, :pointer
# hFILE, :pointer
# hFILE, :pointer
# hFILE, :pointer
# hFILE, :pointer
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
