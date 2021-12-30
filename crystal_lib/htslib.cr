module HTS
  @[Include(
    "htslib/bgzf.h",
    "htslib/cram.h",
    "htslib/faidx.h",
    "htslib/hts.h",
    "htslib/sam.h",
    "htslib/tbx.h",
    "htslib/vcf.h",
    prefix: %w(hts_ sam_ bam_ vcf_ bcf_ tbx_ cram_ bgzf_ faidx_),
    import_docstrings: "brief",
    remove_prefix: false,
  )]
  @[Link("htslib")]
  lib LibHTS
  end
end
