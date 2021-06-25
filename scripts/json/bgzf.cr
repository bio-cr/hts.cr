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

# Unknow types
# ["__time_t", "__suseconds_t", "__syscall_slong_t", ":pointer", "__pthread_list_t", ":array", "union", ":bitfield", "fd_set", ":struct", "__sigset_t", "BGZF", "struct", "off_t"]
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
# BGZF, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# BGZF, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# BGZF, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# BGZF, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# BGZF, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# BGZF, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# BGZF, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# BGZF, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# BGZF, :bitfield, convert.rb:79:in `block (2 levels) in <main>'
# BGZF, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# BGZF, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# BGZF, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# BGZF, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# BGZF, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# BGZF, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# BGZF, :pointer, convert.rb:79:in `block (2 levels) in <main>'
# select, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# select, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# select, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# select, :struct, convert.rb:100:in `block (2 levels) in <main>'
# pselect, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# pselect, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# pselect, fd_set, convert.rb:100:in `block (2 levels) in <main>'
# pselect, :struct, convert.rb:100:in `block (2 levels) in <main>'
# pselect, __sigset_t, convert.rb:100:in `block (2 levels) in <main>'
# , BGZF, convert.rb:109:in `block in <main>'
# , BGZF, convert.rb:109:in `block in <main>'
# bgzf_hopen, struct, convert.rb:100:in `block (2 levels) in <main>'
# , BGZF, convert.rb:109:in `block in <main>'
# bgzf_close, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_read, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_write, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_block_write, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_peek, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_raw_read, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_raw_write, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_flush, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_seek, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_check_EOF, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_compression, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_set_cache_size, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_flush_try, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_getc, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_getline, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_getline, struct, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_read_block, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_thread_pool, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_thread_pool, struct, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_mt, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_useek, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_useek, off_t, convert.rb:104:in `block (2 levels) in <main>'
# bgzf_utell, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_utell, off_t, convert.rb:112:in `block in <main>'
# bgzf_index_build_init, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_index_load, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_index_load_hfile, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_index_load_hfile, struct, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_index_dump, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_index_dump_hfile, BGZF, convert.rb:100:in `block (2 levels) in <main>'
# bgzf_index_dump_hfile, struct, convert.rb:100:in `block (2 levels) in <main>'
