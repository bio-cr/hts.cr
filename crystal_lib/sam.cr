@[Include(
  "htslib/sam.h",
  prefix: %w(sam_ bam_),
  import_docstrings: "brief",
  remove_prefix: false,
)]
@[Link("htslib")]
lib SAM
end
