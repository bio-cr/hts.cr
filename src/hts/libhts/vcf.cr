module HTS
  module LibHTS2 # FIXME
    extend self
    # constants
    BCF_HL_FLT  = 0 # header line
    BCF_HL_INFO = 1
    BCF_HL_FMT  = 2
    BCF_HL_CTG  = 3
    BCF_HL_STR  = 4 # structured header line TAG=<A=..,B=..>
    BCF_HL_GEN  = 5 # generic header line

    BCF_HT_FLAG = 0 # header type
    BCF_HT_INT  = 1
    BCF_HT_REAL = 2
    BCF_HT_STR  = 3
    BCF_HT_LONG = (BCF_HT_INT | 0x100) # BCF_HT_INT, but for int64_t values; VCF only!

    BCF_VL_FIXED = 0 # variable length
    BCF_VL_VAR   = 1
    BCF_VL_A     = 2
    BCF_VL_G     = 3
    BCF_VL_R     = 4

    BCF_DT_ID     = 0 # dictionary type
    BCF_DT_CTG    = 1
    BCF_DT_SAMPLE = 2

    BCF_BT_NULL  = 0
    BCF_BT_INT8  = 1
    BCF_BT_INT16 = 2
    BCF_BT_INT32 = 3
    BCF_BT_INT64 = 4 # Unofficial, for internal use only.
    BCF_BT_FLOAT = 5
    BCF_BT_CHAR  = 7

    VCF_REF     =  0
    VCF_SNP     =  1
    VCF_MNP     =  2
    VCF_INDEL   =  4
    VCF_OTHER   =  8
    VCF_BND     = 16 # breakend
    VCF_OVERLAP = 32 # overlapping deletion, ALT=*

    BCF1_DIRTY_ID  = 1
    BCF1_DIRTY_ALS = 2
    BCF1_DIRTY_FLT = 4
    BCF1_DIRTY_INF = 8

    BCF_ERR_CTG_UNDEF   =  1
    BCF_ERR_TAG_UNDEF   =  2
    BCF_ERR_NCOLS       =  4
    BCF_ERR_LIMITS      =  8
    BCF_ERR_CHAR        = 16
    BCF_ERR_CTG_INVALID = 32
    BCF_ERR_TAG_INVALID = 64

    alias_method :bcf_init1, :bcf_init
    alias_method :bcf_read1, :bcf_read
    alias_method :vcf_read1, :vcf_read
    alias_method :bcf_write1, :bcf_write
    alias_method :vcf_write1, :vcf_write
    alias_method :bcf_destroy1, :bcf_destroy
    alias_method :bcf_empty1, :bcf_empty
    alias_method :vcf_parse1, :vcf_parse
    alias_method :bcf_clear1, :bcf_clear
    alias_method :vcf_format1, :vcf_format

    alias_method :bcf_open, :hts_open
    alias_method :vcf_open, :hts_open
    # alias_method bcf_flush hts_flush
    alias_method :bcf_close, hts_close
    alias_method :vcf_close, hts_close

    BCF_UN_STR  = 1                                       # up to ALT inclusive
    BCF_UN_FLT  = 2                                       # up to FILTER
    BCF_UN_INFO = 4                                       # up to INFO
    BCF_UN_SHR  = (BCF_UN_STR | BCF_UN_FLT | BCF_UN_INFO) # all shared information
    BCF_UN_FMT  = 8                                       # unpack format and each sample
    BCF_UN_IND  = BCF_UN_FMT                              # a synonym of BCF_UN_FMT
    BCF_UN_ALL  = (BCF_UN_SHR | BCF_UN_FMT)               # everything

    def bcf_hdr_nsamples(hdr : Pointer(HTS::LibHTS::BcfHdrT))
      hdr.value.n[BCF_DT_SAMPLE]
    end

    def bcf_update_info_int32(hdr, line, key, values, n)
      bcf_update_info(hdr, line, key, values, n, BCF_HT_INT)
    end

    def bcf_update_info_float(hdr, line, key, values, n)
      bcf_update_info(hdr, line, key, values, n, BCF_HT_REAL)
    end

    def bcf_update_info_flag(hdr, line, key, string, n)
      bcf_update_info(hdr, line, key, string, n, BCF_HT_FLAG)
    end

    def bcf_update_info_string(hdr, line, key, string)
      bcf_update_info(hdr, line, key, string, 1, BCF_HT_STR)
    end

    def bcf_update_format_int32(hdr, line, key, values, n)
      bcf_update_format(hdr, line, key, values, n,
        BCF_HT_INT)
    end

    def bcf_update_format_float(hdr, line, key, values, n)
      bcf_update_format(hdr, line, key, values, n,
        BCF_HT_REAL)
    end

    def bcf_update_format_char(hdr, line, key, values, n)
      bcf_update_format(hdr, line, key, values, n,
        BCF_HT_STR)
    end

    def bcf_update_genotypes(hdr, line, gts, n)
      bcf_update_format(hdr, line, "GT", gts, n, BCF_HT_INT)
    end

    def bcf_gt_phased(idx)
      ((idx + 1) << 1 | 1)
    end

    def bcf_gt_unphased(idx)
      ((idx + 1) << 1)
    end

    def bcf_gt_missing
      0
    end

    def bcf_gt_is_missing(val)
      ((val) >> 1 ? 0 : 1)
    end

    def bcf_gt_is_phased(idx)
      ((idx) & 1)
    end

    def bcf_gt_allele(val)
      (((val) >> 1) - 1)
    end

    def bcf_alleles2gt(a, b)
      ((a) > (b) ? (a * (a + 1) / 2 + b) : (b * (b + 1) / 2 + a))
    end

    def bcf_get_info_int32(hdr, line, tag, dst, ndst)
      bcf_get_info_values(hdr, line, tag, dst, ndst, BCF_HT_INT)
    end

    def bcf_get_info_float(hdr, line, tag, dst, ndst)
      bcf_get_info_values(hdr, line, tag, dst, ndst, BCF_HT_REAL)
    end

    def bcf_get_info_string(hdr, line, tag, dst, ndst)
      bcf_get_info_values(hdr, line, tag, dst, ndst, BCF_HT_STR)
    end

    def bcf_get_info_flag(hdr, line, tag, dst, ndst)
      bcf_get_info_values(hdr, line, tag, dst, ndst, BCF_HT_FLAG)
    end

    def bcf_get_format_int32(hdr, line, tag, dst, ndst)
      bcf_get_format_values(hdr, line, tag, dst, ndst, BCF_HT_INT)
    end

    def bcf_get_format_float(hdr, line, tag, dst, ndst)
      bcf_get_format_values(hdr, line, tag, dst, ndst, BCF_HT_REAL)
    end

    def bcf_get_format_char(hdr, line, tag, dst, ndst)
      bcf_get_format_values(hdr, line, tag, dst, ndst, BCF_HT_STR)
    end

    def bcf_get_genotypes(hdr, line, dst, ndst)
      bcf_get_format_values(hdr, line, "GT", dst, ndst, BCF_HT_INT)
    end

    def bcf_hdr_int2id(hdr, type, int_id)
      Pointer(LibHTS::BcfIdpairT).new(
        (hdr.value.id[type]).address +
        sizeof(LibHTS::BcfIdpairT) * int_id
      ).value.key
    end

    def bcf_hdr_name2id(hdr, id)
      bcf_hdr_id2int(hdr, BCF_DT_CTG, id)
    end

    # def bcf_hdr_id2name(hdr, rid)
    #   return nil if hdr.null? || rid < 0 || rid >= hdr[:n][LibHTS::BCF_DT_CTG]

    #   LibHTS::BcfIdpair.new(
    #     hdr[:id][LibHTS::BCF_DT_CTG].to_ptr +
    #     LibHTS::BcfIdpair.size * rid # offset
    #   )[:key]
    # end

    # def bcf_hdr_id2length(hdr, type, int_id)
    #   LibHTS::BcfIdpair.new(
    #     hdr[:id][LibHTS::BCF_DT_ID].to_ptr +
    #     LibHTS::BcfIdpair.size * int_id # offset
    #   )[:val][:info][type] >> 8 & 0xf
    # end

    # def bcf_hdr_id2number(hdr, type, int_id)
    #   LibHTS::BcfIdpair.new(
    #     hdr[:id][LibHTS::BCF_DT_ID].to_ptr +
    #     LibHTS::BcfIdpair.size * int_id # offset
    #   )[:val][:info][type] >> 12
    # end
  end
end
