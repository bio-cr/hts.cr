struct HtsTpoolProcess
end

struct HtsTpool
end

struct HtsTpoolResult
end

# fun hts_tpool_init(Int32) : *
# fun hts_tpool_size(*) : Int32
# fun hts_tpool_dispatch(*, *, , Void*) : Int32
# fun hts_tpool_dispatch2(*, *, , Void*, Int32) : Int32
# fun hts_tpool_dispatch3(*, *, , Void*, , , Int32) : Int32
# fun hts_tpool_wake_dispatch(*) : Void
# fun hts_tpool_process_flush(*) : Int32
# fun hts_tpool_process_reset(*, Int32) : Int32
# fun hts_tpool_process_qsize(*) : Int32
# fun hts_tpool_destroy(*) : Void
# fun hts_tpool_kill(*) : Void
# fun hts_tpool_next_result(*) : *
# fun hts_tpool_next_result_wait(*) : *
# fun hts_tpool_delete_result(*, Int32) : Void
# fun hts_tpool_result_data(*) : Void*
# fun hts_tpool_process_init(*, Int32, Int32) : *
# fun hts_tpool_process_destroy(*) : Void
# fun hts_tpool_process_empty(*) : Int32
# fun hts_tpool_process_len(*) : Int32
# fun hts_tpool_process_sz(*) : Int32
# fun hts_tpool_process_shutdown(*) : Void
# fun hts_tpool_process_is_shutdown(*) : Int32
# fun hts_tpool_process_attach(*, *) : Void
# fun hts_tpool_process_detach(*, *) : Void
# fun hts_tpool_process_ref_incr(*) : Void
# fun hts_tpool_process_ref_decr(*) : Void

# Unknow types
# ["hts_tpool", "hts_tpool_process", ":function-pointer", "hts_tpool_result"]
# caller
# , hts_tpool, convert.rb:109:in `block in <main>'
# hts_tpool_size, hts_tpool, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_dispatch, hts_tpool, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_dispatch, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_dispatch, :function-pointer, convert.rb:104:in `block (2 levels) in <main>'
# hts_tpool_dispatch2, hts_tpool, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_dispatch2, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_dispatch2, :function-pointer, convert.rb:104:in `block (2 levels) in <main>'
# hts_tpool_dispatch3, hts_tpool, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_dispatch3, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_dispatch3, :function-pointer, convert.rb:104:in `block (2 levels) in <main>'
# hts_tpool_dispatch3, :function-pointer, convert.rb:104:in `block (2 levels) in <main>'
# hts_tpool_dispatch3, :function-pointer, convert.rb:104:in `block (2 levels) in <main>'
# hts_tpool_wake_dispatch, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_process_flush, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_process_reset, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_process_qsize, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_destroy, hts_tpool, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_kill, hts_tpool, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_next_result, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# , hts_tpool_result, convert.rb:109:in `block in <main>'
# hts_tpool_next_result_wait, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# , hts_tpool_result, convert.rb:109:in `block in <main>'
# hts_tpool_delete_result, hts_tpool_result, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_result_data, hts_tpool_result, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_process_init, hts_tpool, convert.rb:100:in `block (2 levels) in <main>'
# , hts_tpool_process, convert.rb:109:in `block in <main>'
# hts_tpool_process_destroy, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_process_empty, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_process_len, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_process_sz, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_process_shutdown, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_process_is_shutdown, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_process_attach, hts_tpool, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_process_attach, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_process_detach, hts_tpool, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_process_detach, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_process_ref_incr, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
# hts_tpool_process_ref_decr, hts_tpool_process, convert.rb:100:in `block (2 levels) in <main>'
