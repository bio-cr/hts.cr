# Generate a small SAM file using HTS::Bam API (no external tools)
#
# Usage:
#   crystal run examples/write_sam.cr -- [output.sam]
#
# If no path is given, writes to ./examples/out.sam

require "../src/hts"

out_path = ARGV[0]? || File.expand_path("./out.sam", __DIR__)

# Build a minimal SAM header
header_text = <<-SAM
  @HD\tVN:1.6\tSO:unknown
  @SQ\tSN:ref\tLN:1000
  SAM

header = HTS::Bam::Header.parse(header_text)

# Open output SAM in write mode and write the header
HTS::Bam.open(out_path, "wh") do |bam|
  bam.write_header(header)

  # Build first record using the new high-level initializer
  seq1 = "ACGTACGTACGTACGTACGT"
  # Build a uniform Phred quality buffer explicitly (0..93)
  qual1 = Array(UInt8).new(seq1.bytesize, 30_u8)
  rec1 = HTS::Bam::Record.new(header, "r1", 0_u16, "ref", 0_i64, 60_u8, "20M", seq1, qual1)
  bam << rec1

  # Second record
  seq2 = "ACGTACGTAC"
  qual2 = Array(UInt8).new(seq2.bytesize, 25_u8)
  rec2 = HTS::Bam::Record.new(header, "r2", 0_u16, "ref", 100_i64, 50_u8, "10M", seq2, qual2)
  bam << rec2

  puts "Wrote SAM to #{out_path}"
end
