@[Include(
  "htslib/hts.h"
  prefix: %w(hts_), 
  import_docstrings: "brief",
  remove_prefix: false,
)]
@[Link("htslib")]
lib HTS
end