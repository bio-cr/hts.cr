require "../src/htslib.cr"

p String.new(HTS::LibHTS.hts_version())
