@[Include(
  "htslib/cram.h",
  prefix: %w(cram_),
  import_docstrings: "brief",
  remove_prefix: false,
)]
@[Link("htslib")]
lib CRAM
end
