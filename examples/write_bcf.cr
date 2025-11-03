# Generate a small BCF file using HTS::Bcf API (no external tools)
#
# Usage:
#   crystal run examples/write_bcf.cr -- [output.bcf]
#
# If no path is given, writes to ./examples/out.bcf

require "../src/hts"

out_path = ARGV[0]? || File.expand_path("./out.bcf", __DIR__)

# Build a minimal VCF/BCF header for writing (no samples)
header = HTS::Bcf::Header.new
# Set VCF version (optional but nice to have)
header.set_version("VCFv4.3")
# Define one contig
header.append("##contig=<ID=ref,length=1000>")
# Finalize header dictionaries
header.sync

# Open output BCF in write mode and write the header
HTS::Bcf.open(out_path, "wb") do |bcf|
  bcf.write_header(header)

  # Create a record and fill minimal fields (shared columns only)
  rec = HTS::Bcf::Record.new(header)

  # Map contig name to rid and set coordinates (BCF uses 0-based POS internally)
  rid = HTS::LibHTS2.bcf_hdr_name2id(header, "ref")
  raise "Unknown contig 'ref' in header" if rid < 0
  rec.rid = rid
  rec.pos = 0         # 0-based => corresponds to POS=1 in VCF
  rec.qual = 60.0_f32 # Phred QUAL
  rec.id = "v1"

  # Set REF/ALT alleles (comma-separated)
  # This updates the record's allele block and derived lengths
  rc = HTS::LibHTS.bcf_update_alleles_str(header, rec, "A,C")
  raise "bcf_update_alleles_str failed (rc=#{rc})" if rc < 0

  # (Optional) update INFO/FORMAT here using LibHTS2.bcf_update_info_* / bcf_update_format_*

  # Write the record
  bcf << rec

  puts "Wrote BCF to #{out_path}"
end
