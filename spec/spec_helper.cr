require "spec"
require "../src/hts"

# Temporarily change htslib's internal log level (hts_log, e.g. "[E::...]" / "[W::...]").
def with_htslib_log_level(level : HTS::LibHTS::HtsLogLevel, &)
  previous = HTS::LibHTS.hts_get_log_level
  HTS::LibHTS.hts_set_log_level(level)
  begin
    yield
  ensure
    HTS::LibHTS.hts_set_log_level(previous)
  end
end

# Redirect stderr to a temporary file and return everything written to it.
# A tempfile is used
# rather than /dev/null because the latter caused htslib reads to fail
# (rc=-2) on macOS during testing.
def capture_stderr(&) : String
  original_stderr = STDERR.dup
  temp = File.tempfile("hts_spec_stderr")
  temp_path = temp.path

  begin
    STDERR.reopen(temp)
    yield
    STDERR.flush
    temp.flush
    temp.rewind
    temp.gets_to_end
  ensure
    STDERR.flush rescue nil
    STDERR.reopen(original_stderr)
    original_stderr.close
    begin
      temp.close
    rescue IO::Error
      # The descriptor may already have been closed while STDERR was reopened.
    end
    File.delete(temp_path) if temp_path && File.exists?(temp_path)
  end
end

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
