struct Timeval
  tv_sec : 
  tv_usec : 
end

struct Timespec
  tv_sec : 
  tv_nsec : 
end






struct HFILE
end

struct HtsTpool
end

struct KstringT
end

struct BgzfMtauxT
end

struct BgzidxT
end

struct BgzfCacheT
end

struct ZStreamS
end

struct BGZF
  errcode : 
  reserved : 
  is_write : 
  no_eof_block : 
  is_be : 
  compress_level : 
  last_block_eof : 
  is_compressed : 
  is_gzip : 
  cache_size : Int32
  block_length : Int32
  block_clength : Int32
  block_offset : Int32
  block_address : Int64
  uncompressed_address : Int64
  uncompressed_block : 
  compressed_block : 
  cache : 
  fp : 
  mt : 
  idx : 
  idx_build_otf : Int32
  gz_stream : 
  seeked : Int64
end
# fun __bswap_16(UInt16) : UInt16
fun __bswap_32(UInt32) : UInt32
fun __bswap_64(UInt64) : UInt64
fun __uint16_identity(UInt16) : UInt16
fun __uint32_identity(UInt32) : UInt32
fun __uint64_identity(UInt64) : UInt64
# fun select(Int32, *, *, *, *) : Int32
# fun pselect(Int32, *, *, *, *, *) : Int32
# fun bgzf_dopen(Int32, UInt8*) : *
# fun bgzf_open(UInt8*, UInt8*) : *
# fun bgzf_hopen(*, UInt8*) : *
# fun bgzf_close(*) : Int32
# fun bgzf_read(*, Void*, SizeT) : SSizeT
# fun bgzf_write(*, Void*, SizeT) : SSizeT
# fun bgzf_block_write(*, Void*, SizeT) : SSizeT
# fun bgzf_peek(*) : Int32
# fun bgzf_raw_read(*, Void*, SizeT) : SSizeT
# fun bgzf_raw_write(*, Void*, SizeT) : SSizeT
# fun bgzf_flush(*) : Int32
# fun bgzf_seek(*, Int64, Int32) : Int64
# fun bgzf_check_EOF(*) : Int32
# fun bgzf_compression(*) : Int32
fun bgzf_is_bgzf(UInt8*) : Int32
# fun bgzf_set_cache_size(*, Int32) : Void
# fun bgzf_flush_try(*, SSizeT) : Int32
# fun bgzf_getc(*) : Int32
# fun bgzf_getline(*, Int32, *) : Int32
# fun bgzf_read_block(*) : Int32
# fun bgzf_thread_pool(*, *, Int32) : Int32
# fun bgzf_mt(*, Int32, Int32) : Int32
fun bgzf_compress(Void*, SizeT*, Void*, SizeT, Int32) : Int32
# fun bgzf_useek(*, , Int32) : Int32
# fun bgzf_utell(*) : 
# fun bgzf_index_build_init(*) : Int32
# fun bgzf_index_load(*, UInt8*, UInt8*) : Int32
# fun bgzf_index_load_hfile(*, *, UInt8*) : Int32
# fun bgzf_index_dump(*, UInt8*, UInt8*) : Int32
# fun bgzf_index_dump_hfile(*, *, UInt8*) : Int32

# Unknown types
# ["__time_t", "__suseconds_t", "__syscall_slong_t", ":bitfield", ":pointer", "fd_set", ":struct", "__sigset_t", "BGZF", "struct", "off_t"]
# timeval, __time_t
# timeval, __suseconds_t
# timespec, __time_t
# timespec, __syscall_slong_t
# BGZF, :bitfield
# BGZF, :bitfield
# BGZF, :bitfield
# BGZF, :bitfield
# BGZF, :bitfield
# BGZF, :bitfield
# BGZF, :bitfield
# BGZF, :bitfield
# BGZF, :bitfield
# BGZF, :pointer
# BGZF, :pointer
# BGZF, :pointer
# BGZF, :pointer
# BGZF, :pointer
# BGZF, :pointer
# BGZF, :pointer
# select, fd_set
# select, fd_set
# select, fd_set
# select, :struct
# pselect, fd_set
# pselect, fd_set
# pselect, fd_set
# pselect, :struct
# pselect, __sigset_t
# bgzf_dopen, BGZF
# bgzf_open, BGZF
# bgzf_hopen, struct
# bgzf_hopen, BGZF
# bgzf_close, BGZF
# bgzf_read, BGZF
# bgzf_write, BGZF
# bgzf_block_write, BGZF
# bgzf_peek, BGZF
# bgzf_raw_read, BGZF
# bgzf_raw_write, BGZF
# bgzf_flush, BGZF
# bgzf_seek, BGZF
# bgzf_check_EOF, BGZF
# bgzf_compression, BGZF
# bgzf_set_cache_size, BGZF
# bgzf_flush_try, BGZF
# bgzf_getc, BGZF
# bgzf_getline, BGZF
# bgzf_getline, struct
# bgzf_read_block, BGZF
# bgzf_thread_pool, BGZF
# bgzf_thread_pool, struct
# bgzf_mt, BGZF
# bgzf_useek, BGZF
# bgzf_useek, off_t
# bgzf_utell, BGZF
# bgzf_utell, off_t
# bgzf_index_build_init, BGZF
# bgzf_index_load, BGZF
# bgzf_index_load_hfile, BGZF
# bgzf_index_load_hfile, struct
# bgzf_index_dump, BGZF
# bgzf_index_dump_hfile, BGZF
# bgzf_index_dump_hfile, struct
