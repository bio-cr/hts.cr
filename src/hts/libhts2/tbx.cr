module HTS
  module LibHTS2
    extend self

    alias_method :tbx_itr_querys, :tbx_itr_querys1

    def tbx_itr_queryi(tbx, tid, beg, end_)
      LibHTS.hts_itr_query(tbx.value.idx, tid, beg, end_, ->LibHTS.tbx_readrec(LibHTS::Bgzf*, Void*, Void*, LibC::Int*, LibHTS::HtsPosT*, LibHTS::HtsPosT*))
    end

    def tbx_itr_next(htsfp, tbx, iter, r)
      LibHTS.tbx_itr_next1(htsfp, tbx, iter, r)
    end

    def tbx_bgzf_itr_next(bgzfp, tbx, iter, r)
      LibHTS.hts_itr_next(bgzfp, iter, r, tbx)
    end
  end
end
