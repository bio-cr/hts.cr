require "spec"
require "../src/hts"

BAM_FLAG_METHODS = %w[
  paired?
  proper_pair?
  unmapped?
  mate_unmapped?
  reverse?
  mate_reverse?
  read1?
  read2?
  secondary?
  qcfail?
  duplicate?
  supplementary?
]

module TestBcfMultisampleHelper
  def with_temp_multisample_bcf(&)
    file = File.tempfile("multisample_test", ".bcf")
    path = file.path || raise "tempfile path is nil"
    begin
      file.close

      header = HTS::Bcf::Header.new
      header.version = "VCFv4.3"
      header.append("##contig=<ID=1,length=100>")
      header.append("##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">")
      header.add_sample("A", sync: false)
      header.add_sample("B", sync: true)

      HTS::Bcf.open(path, "wb") do |bcf|
        bcf.write_header(header)

        record = HTS::Bcf::Record.new(header)
        record.rid = HTS::LibHTS2.bcf_hdr_name2id(header, "1")
        record.pos = 9

        rc = HTS::LibHTS.bcf_update_alleles_str(header, record, "A,C")
        raise "bcf_update_alleles_str failed (rc=#{rc})" if rc < 0

        genotypes = [
          HTS::LibHTS2.bcf_gt_unphased(1),
          HTS::LibHTS2.bcf_gt_unphased(1),
          HTS::LibHTS2.bcf_gt_unphased(0),
          HTS::LibHTS2.bcf_gt_unphased(1),
        ]
        rc = HTS::LibHTS2.bcf_update_genotypes(header, record, genotypes.to_unsafe, genotypes.size)
        raise "bcf_update_genotypes failed (rc=#{rc})" if rc < 0

        bcf << record
      end

      yield path
    ensure
      File.delete(path) if File.exists?(path)
    end
  end
end
