struct Flock
  l_type : Short
  l_whence : Short
  l_start : 
  l_len : 
  l_pid : 
end

struct Timespec
  tv_sec : 
  tv_nsec : 
end

struct Stat
  st_dev : 
  st_ino : 
  st_nlink : 
  st_mode : 
  st_uid : 
  st_gid : 
  __pad0 : Int32
  st_rdev : 
  st_size : 
  st_blksize : 
  st_blocks : 
  st_atim : 
  st_mtim : 
  st_ctim : 
  __glibc_reserved : 
end

struct Timeval
  tv_sec : 
  tv_usec : 
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

struct KnetFileS
  type : Int32
  fd : Int32
  offset : Int64
  host : 
  port : 
  ctrl_fd : Int32
  pasv_ip : 
  pasv_port : Int32
  max_response : Int32
  no_reconnect : Int32
  is_ready : Int32
  response : 
  retr : 
  size_cmd : 
  seek_offset : Int64
  file_size : Int64
  path : 
  http_host : 
end

# fun fcntl(Int32, Int32) : Int32
fun open(UInt8*, Int32) : Int32
fun openat(Int32, UInt8*, Int32) : Int32
# fun creat(UInt8*, ) : Int32
# fun lockf(Int32, Int32, ) : Int32
# fun posix_fadvise(Int32, , , Int32) : Int32
# fun posix_fallocate(Int32, , ) : Int32
fun __bswap_16(UInt16) : UInt16
fun __bswap_32(UInt32) : UInt32
fun __bswap_64(UInt64) : UInt64
fun __uint16_identity(UInt16) : UInt16
fun __uint32_identity(UInt32) : UInt32
fun __uint64_identity(UInt64) : UInt64
# fun select(Int32, *, *, *, *) : Int32
# fun pselect(Int32, *, *, *, *, *) : Int32
# fun knet_open(UInt8*, UInt8*) : *
# fun knet_dopen(Int32, UInt8*) : *
# fun knet_read(*, Void*, SizeT) : SSizeT
# fun knet_seek(*, , Int32) : 
# fun knet_close(*) : Int32

# Unknow types
# ["__off_t", "__pid_t", "__time_t", "__syscall_slong_t", "__dev_t", "__ino_t", "__nlink_t", "__mode_t", "__uid_t", "__gid_t", "__blksize_t", "__blkcnt_t", ":struct", ":array", "__suseconds_t", ":pointer", "__pthread_list_t", "union", "mode_t", "off_t", "fd_set", "__sigset_t", "knetFile"]
# caller
# flock, __off_t, convert.rb:79:in `block (2 levels) in <main>'
# flock, __off_t, convert.rb:79:in `block (2 levels) in <main>'
# flock, __pid_t, convert.rb:79:in `block (2 levels) in <main>'
# timespec, __time_t, convert.rb:79:in `block (2 levels) in <main>'
# timespec, __syscall_slong_t, convert.rb:79:in `block (2 levels) in <main>'
# stat, __dev_t, convert.rb:79:in `block (2 levels) in <main>'
# stat, __ino_t, convert.rb:79:in `block (2 levels) in <main>'
# stat, __nlink_t, convert.rb:79:in `block (2 levels) in <main>'
# stat, __mode_t, convert.rb:79:in `block (2 levels) in <main>'
# stat, __uid_t, convert.rb:79:in `block (2 levels) in <main>'
# stat, __gid_t, convert.rb:79:in `block (2 levels) in <main>'
# stat, __dev_t, convert.rb:79:in `block (2 levels) in <main>'
# stat, __off_t, convert.rb:79:in `block (2 levels) in <main>'
# stat, __blksize_t, convert.rb:79:in `block (2 levels) in <main>'
# stat, __blkcnt_t, convert.rb:79:in `block (2 levels) in <main>'
# stat, :struct, convert.rb:79:in `block (2 levels) in <main>'
# stat, :struct, convert.rb:79:in `block (2 levels) in <main>'
# stat, :struct, convert.rb:79:in `block (2 levels) in <main>'
# stat, :array, convert.rb:79:in `block (2 levels) in <main>'
# timeval, __time_t, convert.rb:79:in `block (2 levels) in <main>'
# timeval, __suseconds_t, convert.rb:79:in `block (2 levels) in <main>'
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
# knetFile_s, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# knetFile_s, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# knetFile_s, :array, convert.rb:79:in `block (2 levels) in <main>'
# knetFile_s, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# knetFile_s, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# knetFile_s, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# knetFile_s, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# knetFile_s, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# creat, mode_t, convert.rb:104:in `block (2 levels) in <main>'
# lockf, off_t, convert.rb:104:in `block (2 levels) in <main>'
# posix_fadvise, off_t, convert.rb:104:in `block (2 levels) in <main>'
# posix_fadvise, off_t, convert.rb:104:in `block (2 levels) in <main>'
# posix_fallocate, off_t, convert.rb:104:in `block (2 levels) in <main>'
# posix_fallocate, off_t, convert.rb:104:in `block (2 levels) in <main>'
# select, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# select, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# select, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# select, :struct, convert.rb:100:in `block (2 levels) in <main>'
# pselect, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# pselect, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# pselect, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# pselect, :struct, convert.rb:100:in `block (2 levels) in <main>'
# pselect, __sigset_t, convert.rb:100:in `block (2 levels) in <main>'
# , knetFile, convert.rb:109:in `block in <main>'
# , knetFile, convert.rb:109:in `block in <main>'
# knet_read, knetFile, convert.rb:100:in `block (2 levels) in <main>'
# knet_seek, knetFile, convert.rb:100:in `block (2 levels) in <main>'
# knet_seek, off_t, convert.rb:104:in `block (2 levels) in <main>'
# knet_seek, off_t, convert.rb:112:in `block in <main>'
# knet_close, knetFile, convert.rb:100:in `block (2 levels) in <main>'
