module HTS
  module LibHTS2
    extend self

    htslib_at_least(1, 24, 0) do
      alias_method :tbx_itr_querys, :tbx_itr_querys1

      def tbx_itr_regarray(tbx, regarray, regcount)
        LibHTS.tbx_itr_regarray(tbx, regarray, regcount)
      end
    end

    htslib_before(1, 24, 0) do
      def tbx_itr_querys(tbx, s)
        readrec = ->LibHTS.tbx_readrec(LibHTS::Bgzf*, Void*, Void*, LibC::Int*, LibHTS::HtsPosT*, LibHTS::HtsPosT*)
        itr_query = ->LibHTS.hts_itr_query(LibHTS::HtsIdxT, LibC::Int, LibHTS::HtsPosT, LibHTS::HtsPosT, (LibHTS::Bgzf*, Void*, Void*, LibC::Int*, LibHTS::HtsPosT*, LibHTS::HtsPosT* -> LibC::Int))
        name2id = ->(tbxv : Void*, ss : LibC::Char*) : LibC::Int {
          LibHTS.tbx_name2id(tbxv.as(LibHTS::TbxT*), ss)
        }
        LibHTS.hts_itr_querys(tbx.value.idx, s, name2id, tbx.as(Void*), itr_query, readrec)
      end
    end

    def tbx_itr_queryi(tbx, tid, beg, end_)
      LibHTS.hts_itr_query(tbx.value.idx, tid, beg, end_, ->LibHTS.tbx_readrec(LibHTS::Bgzf*, Void*, Void*, LibC::Int*, LibHTS::HtsPosT*, LibHTS::HtsPosT*))
    end

    htslib_at_least(1, 24, 0) do
      def tbx_itr_next(htsfp, tbx, iter, r)
        LibHTS.tbx_itr_next1(htsfp, tbx, iter, r)
      end
    end

    htslib_before(1, 24, 0) do
      def tbx_itr_next(htsfp, tbx, iter, r)
        LibHTS.hts_itr_next(LibHTS.hts_get_bgzfp(htsfp), iter, r, tbx)
      end
    end

    def tbx_bgzf_itr_next(bgzfp, tbx, iter, r)
      LibHTS.hts_itr_next(bgzfp, iter, r, tbx)
    end
  end
end
