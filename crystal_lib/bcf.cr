@[Include(
  "htslib/vcf.h",
  prefix: %w(vcf_ bcf_),
  import_docstrings: "brief",
  remove_prefix: false,
)]
@[Link("htslib")]
lib Bcf
end
