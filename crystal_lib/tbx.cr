@[Include(
  "htslib/tbx.h",
  prefix: %w(tbx_),
  import_docstrings: "brief",
  remove_prefix: false,
)]
@[Link("htslib")]
lib TBX
end