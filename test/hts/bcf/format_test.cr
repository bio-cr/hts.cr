require "minitest/autorun"
require "../../../src/hts/bcf"

class BcfFormatTest < Minitest::Test
  def with_temp_bcf(&)
    file = File.tempfile("format_test", ".bcf")
    path = file.path || raise "tempfile path is nil"
    begin
      file.close

      header = HTS::Bcf::Header.new
      header.set_version("VCFv4.3")
      header.append("##contig=<ID=1,length=100>")
      header.append("##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">")
      header.append("##FORMAT=<ID=PL,Number=G,Type=Integer,Description=\"Phred likelihoods\">")
      header.add_sample("S1", sync: false)
      header.add_sample("S2", sync: true)

      HTS::Bcf.open(path, "wb") do |bcf|
        bcf.write_header(header)

        record = HTS::Bcf::Record.new(header)
        record.rid = HTS::LibHTS2.bcf_hdr_name2id(header, "1")
        record.pos = 9

        rc = HTS::LibHTS.bcf_update_alleles_str(header, record, "A,C")
        raise "bcf_update_alleles_str failed (rc=#{rc})" if rc < 0

        genotypes = [
          HTS::LibHTS2.bcf_gt_unphased(0),
          HTS::LibHTS2.bcf_gt_unphased(1),
          HTS::LibHTS2.bcf_gt_unphased(1),
          HTS::LibHTS2.bcf_gt_unphased(1),
        ]
        rc = HTS::LibHTS2.bcf_update_genotypes(header, record, genotypes.to_unsafe, genotypes.size)
        raise "bcf_update_genotypes failed (rc=#{rc})" if rc < 0

        likelihoods = [10, 20, 30, 40, 50, 60]
        rc = HTS::LibHTS2.bcf_update_format_int32(header, record, "PL", likelihoods.to_unsafe, likelihoods.size)
        raise "bcf_update_format_int32 failed (rc=#{rc})" if rc < 0

        bcf << record
      end

      yield path
    ensure
      File.delete(path) if File.exists?(path)
    end
  end

  def with_temp_gt_bcf(&)
    file = File.tempfile("format_gt_test", ".bcf")
    path = file.path || raise "tempfile path is nil"
    begin
      file.close

      header = HTS::Bcf::Header.new
      header.set_version("VCFv4.3")
      header.append("##contig=<ID=1,length=100>")
      header.append("##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">")
      header.add_sample("S1", sync: false)
      header.add_sample("S2", sync: false)
      header.add_sample("S3", sync: false)
      header.add_sample("S4", sync: true)

      HTS::Bcf.open(path, "wb") do |bcf|
        bcf.write_header(header)

        record = HTS::Bcf::Record.new(header)
        record.rid = HTS::LibHTS2.bcf_hdr_name2id(header, "1")
        record.pos = 9

        rc = HTS::LibHTS.bcf_update_alleles_str(header, record, "A,C")
        raise "bcf_update_alleles_str failed (rc=#{rc})" if rc < 0

        gt_vector_end = HTS::LibHTS2.bcf_gt_vector_end
        genotypes = [
          HTS::LibHTS2.bcf_gt_unphased(0), HTS::LibHTS2.bcf_gt_phased(1),
          HTS::LibHTS2.bcf_gt_unphased(0), HTS::LibHTS2.bcf_gt_unphased(1),
          HTS::LibHTS2.bcf_gt_missing, HTS::LibHTS2.bcf_gt_missing,
          HTS::LibHTS2.bcf_gt_unphased(1), gt_vector_end,
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

  def test_bcf_path
    File.expand_path("../../fixtures/test.bcf", __DIR__)
  end

  def format : HTS::Bcf::Format
    bcf = HTS::Bcf.new(test_bcf_path)
    rec = bcf.first
    bcf.close
    rec.format
  end

  def test_get_int
    assert_equal([172, 93, 0], format.get_int("PL"))
  end

  def test_get_string
    assert_equal(["1/1"], format.get_string("GT"))
  end

  def test_get_genotypes
    assert_equal([4, 4], format.get_genotypes)
  end

  def test_multisample_gt_and_flat_numeric_buffers
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        format = bcf.first.format

        assert_equal(["0/1", "1/1"], format.get_string("GT"))
        assert_equal([2, 4, 4, 4], format.get_genotypes)
        assert_equal([10, 20, 30, 40, 50, 60], format.get_int("PL"))
      end
    end
  end

  def test_gt_decoding_handles_phased_missing_and_lower_ploidy
    with_temp_gt_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        format = bcf.first.format
        raw = format.get_genotypes || raise "GT should be present"

        assert_equal(8, raw.size)
        assert_equal(0, HTS::LibHTS2.bcf_gt_allele(raw[0]))
        assert_equal(1, HTS::LibHTS2.bcf_gt_allele(raw[1]))
        assert_equal(1, HTS::LibHTS2.bcf_gt_is_phased(raw[1]))
        assert_equal(0, HTS::LibHTS2.bcf_gt_is_missing(raw[2]))
        assert_equal(0, HTS::LibHTS2.bcf_gt_is_missing(raw[3]))
        assert_equal(1, HTS::LibHTS2.bcf_gt_allele(raw[6]))
        assert_equal(1, HTS::LibHTS2.bcf_gt_is_vector_end(raw[7]))
        assert_equal(["0|1", "0/1", "./.", "1"], format.get_string("GT"))
      end
    end
  end

  def test_low_level_contract
    assert_nil format.get_int("NO_SUCH_TAG")
    assert_nil format.get_float("NO_SUCH_TAG")
    assert_nil format.get_string("NO_SUCH_TAG")

    ex = assert_raises(Exception) { format.get_float("PL") }
    assert_equal "Tag PL is not float FORMAT field", ex.message
  end
end
