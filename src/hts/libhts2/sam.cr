module HTS
  module LibHTS2
    extend self

    # constants
    BAM_CMATCH     = 0
    BAM_CINS       = 1
    BAM_CDEL       = 2
    BAM_CREF_SKIP  = 3
    BAM_CSOFT_CLIP = 4
    BAM_CHARD_CLIP = 5
    BAM_CPAD       = 6
    BAM_CEQUAL     = 7
    BAM_CDIFF      = 8
    BAM_CBACK      = 9

    BAM_CIGAR_STR   = "MIDNSHP=XB"
    BAM_CIGAR_SHIFT =       4
    BAM_CIGAR_MASK  =     0xf
    BAM_CIGAR_TYPE  = 0x3C1A7

    # macros
    def bam_cigar_op(c)
      c & BAM_CIGAR_MASK
    end

    def bam_cigar_oplen(c)
      c >> BAM_CIGAR_SHIFT
    end

    def bam_cigar_opchr(c)
      ("#{BAM_CIGAR_STR}??????")[bam_cigar_op(c)]
    end

    def bam_cigar_gen(l, o)
      l << BAM_CIGAR_SHIFT | o
    end

    def bam_cigar_type(o)
      BAM_CIGAR_TYPE >> (o << 1) & 3
    end

    BAM_FPAIRED        =    1
    BAM_FPROPER_PAIR   =    2
    BAM_FUNMAP         =    4
    BAM_FMUNMAP        =    8
    BAM_FREVERSE       =   16
    BAM_FMREVERSE      =   32
    BAM_FREAD1         =   64
    BAM_FREAD2         =  128
    BAM_FSECONDARY     =  256
    BAM_FQCFAIL        =  512
    BAM_FDUP           = 1024
    BAM_FSUPPLEMENTARY = 2048

    def bam_is_rev(b : Pointer(HTS::LibHTS::Bam1T))
      b.value.core.flag & BAM_FREVERSE != 0
    end

    def bam_is_mrev(b : Pointer(HTS::LibHTS::Bam1T))
      b.value.core.flag & BAM_FMREVERSE != 0
    end

    def bam_get_qname(b : Pointer(HTS::LibHTS::Bam1T))
      b.value.data
    end

    def bam_get_cigar(b : Pointer(HTS::LibHTS::Bam1T))
      (b.value.data + b.value.core.l_qname).as(Pointer(UInt32))
    end

    def bam_get_seq(b : Pointer(HTS::LibHTS::Bam1T))
      b.value.data + (b.value.core.n_cigar << 2) + b.value.core.l_qname
    end

    def bam_get_qual(b : Pointer(HTS::LibHTS::Bam1T))
      b.value.data + (b.value.core.n_cigar << 2) + b.value.core.l_qname + ((b.value.core.l_qseq + 1) >> 1)
    end

    def bam_get_aux(b : Pointer(HTS::LibHTS::Bam1T))
      b.value.data + (b.value.core.n_cigar << 2) + b.value.core.l_qname + ((b.value.core.l_qseq + 1) >> 1) + b.value.core.l_qseq
    end

    def bam_get_l_aux(b : Pointer(HTS::LibHTS::Bam1T))
      b.value.l_data - (b.value.core.n_cigar << 2) - b.value.core.l_qname - b.value.core.l_qseq - ((b.value.core.l_qseq + 1) >> 1)
    end

    def bam_seqi(s, i)
      s[(i) >> 1] >> ((~i & 1) << 2) & 0xf
    end

    def sam_itr_next(htsfp, itr, r)
      # FIXME: check if htsfp is compressed BGZF
      raise "Null iterator" if itr.null?
      # FIXME: check multi
      LibHTS.hts_itr_next(htsfp.value.fp.bgzf, itr, r, htsfp)
    end
  end
end
