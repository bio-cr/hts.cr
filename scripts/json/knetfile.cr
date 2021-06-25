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

# Unknown types
# ["__off_t", "__pid_t", "__time_t", "__syscall_slong_t", "__dev_t", "__ino_t", "__nlink_t", "__mode_t", "__uid_t", "__gid_t", "__blksize_t", "__blkcnt_t", ":struct", ":array", "__suseconds_t", ":pointer", "mode_t", "off_t", "fd_set", "__sigset_t", "knetFile"]
# flock, __off_t
# flock, __off_t
# flock, __pid_t
# timespec, __time_t
# timespec, __syscall_slong_t
# stat, __dev_t
# stat, __ino_t
# stat, __nlink_t
# stat, __mode_t
# stat, __uid_t
# stat, __gid_t
# stat, __dev_t
# stat, __off_t
# stat, __blksize_t
# stat, __blkcnt_t
# stat, :struct
# stat, :struct
# stat, :struct
# stat, :array
# timeval, __time_t
# timeval, __suseconds_t
# knetFile_s, :pointer
# knetFile_s, :pointer
# knetFile_s, :array
# knetFile_s, :pointer
# knetFile_s, :pointer
# knetFile_s, :pointer
# knetFile_s, :pointer
# knetFile_s, :pointer
# creat, mode_t
# lockf, off_t
# posix_fadvise, off_t
# posix_fadvise, off_t
# posix_fallocate, off_t
# posix_fallocate, off_t
# select, fd_set
# select, fd_set
# select, fd_set
# select, :struct
# pselect, fd_set
# pselect, fd_set
# pselect, fd_set
# pselect, :struct
# pselect, __sigset_t
# knet_open, knetFile
# knet_dopen, knetFile
# knet_read, knetFile
# knet_seek, knetFile
# knet_seek, off_t
# knet_seek, off_t
# knet_close, knetFile
