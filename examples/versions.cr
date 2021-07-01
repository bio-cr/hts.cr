require "../src/htslib.cr"

p String.new(LibHTS.hts_version())
