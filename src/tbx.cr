@[Link("htslib")]
lib TBX
  struct TbxConfT
    preset : Int32T
    sc : Int32T
    bc : Int32T
    ec : Int32T
    meta_char : Int32T
    line_skip : Int32T
  end

  alias X__Int32T = LibC::Int
  alias Int32T = X__Int32T

  struct TbxT
    conf : TbxConfT
    idx : HtsIdxT
    dict : Void*
  end

  type HtsIdxT = Void*
  fun tbx_name2id(tbx : TbxT*, ss : LibC::Char*) : LibC::Int
  fun tbx_readrec(fp : Bgzf, tbxv : Void*, sv : Void*, tid : LibC::Int*, beg : HtsPosT*, _end : HtsPosT*) : LibC::Int
  type Bgzf = Void*
  alias X__Int64T = LibC::Long
  alias Int64T = X__Int64T
  alias HtsPosT = Int64T
  fun tbx_index(fp : Bgzf, min_shift : LibC::Int, conf : TbxConfT*) : TbxT*
  fun tbx_index_build(fn : LibC::Char*, min_shift : LibC::Int, conf : TbxConfT*) : LibC::Int
  fun tbx_index_build2(fn : LibC::Char*, fnidx : LibC::Char*, min_shift : LibC::Int, conf : TbxConfT*) : LibC::Int
  fun tbx_index_build3(fn : LibC::Char*, fnidx : LibC::Char*, min_shift : LibC::Int, n_threads : LibC::Int, conf : TbxConfT*) : LibC::Int
  fun tbx_index_load(fn : LibC::Char*) : TbxT*
  fun tbx_index_load2(fn : LibC::Char*, fnidx : LibC::Char*) : TbxT*
  fun tbx_index_load3(fn : LibC::Char*, fnidx : LibC::Char*, flags : LibC::Int) : TbxT*
  fun tbx_seqnames(tbx : TbxT*, n : LibC::Int*) : LibC::Char**
  fun tbx_destroy(tbx : TbxT*)
  $tbx_conf_gff : TbxConfT
  $tbx_conf_bed : TbxConfT
  $tbx_conf_psltbl : TbxConfT
  $tbx_conf_sam : TbxConfT
  $tbx_conf_vcf : TbxConfT
end
