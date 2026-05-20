# Generate a small BCF file using HTS::Bcf API (no external tools)
#
# Usage:
#   crystal run examples/write_bcf.cr -- [output.bcf]
#
# If no path is given, writes to ./examples/out.bcf

require "../src/hts"

out_path = ARGV[0]? || File.expand_path("./out.bcf", __DIR__)

header = HTS::Bcf::Header.new
header.edit do |edited_header|
  edited_header.set_version("VCFv4.3")
  edited_header.add_contig("ref", length: 1000)
  edited_header.add_info("DP", number: 1, type: :int, description: "Read depth")
  edited_header.add_format("GT", number: 1, type: :string, description: "Genotype")
  edited_header.add_format("GQ", number: 1, type: :int, description: "Genotype quality")
  edited_header.add_sample("sample1")
end

HTS::Bcf.open(out_path, "wb") do |bcf|
  bcf.write_header(header)

  rec = HTS::Bcf::Record.new(header)

  rid = header.name2id("ref")
  raise "Unknown contig 'ref' in header" if rid < 0
  rec.rid = rid
  rec.pos = 0
  rec.qual = 60.0_f32
  rec.id = "v1"

  rc = HTS::LibHTS.bcf_update_alleles_str(header, rec, "A,C")
  raise "bcf_update_alleles_str failed (rc=#{rc})" if rc < 0

  rec.info.update_int("DP", 42)
  rec.format.update_genotypes([
    HTS::LibHTS2.bcf_gt_unphased(0),
    HTS::LibHTS2.bcf_gt_unphased(1),
  ])
  rec.format.update_int("GQ", 99)

  bcf << rec

  puts "Wrote BCF to #{out_path}"
end
