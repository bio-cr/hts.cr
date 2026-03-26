require "minitest/autorun"
require "../../../src/hts/bcf"

class BcfInfoTest < Minitest::Test
  def with_temp_bcf(&)
    file = File.tempfile("info_test", ".bcf")
    path = file.path || raise "tempfile path is nil"
    begin
      file.close

      header = HTS::Bcf::Header.new
      header.set_version("VCFv4.3")
      header.append("##contig=<ID=1,length=5000000000>")
      header.append("##INFO=<ID=MIX,Number=2,Type=Integer,Description=\"integer with missing\">")
      header.append("##INFO=<ID=CH,Number=1,Type=Character,Description=\"character test\">")
      header.sync

      HTS::Bcf.open(path, "wb") do |bcf|
        bcf.write_header(header)

        record = HTS::Bcf::Record.new(header)
        record.rid = HTS::LibHTS2.bcf_hdr_name2id(header, "1")
        record.pos = 9

        rc = HTS::LibHTS.bcf_update_alleles_str(header, record, "N,<DEL>")
        raise "bcf_update_alleles_str failed (rc=#{rc})" if rc < 0

        mix = [42, Int32::MIN]
        rc = HTS::LibHTS2.bcf_update_info_int32(header, record, "MIX", mix.to_unsafe, mix.size)
        raise "bcf_update_info_int32 failed for MIX (rc=#{rc})" if rc < 0

        rc = HTS::LibHTS2.bcf_update_info_string(header, record, "CH", "Q")
        raise "bcf_update_info_string failed for CH (rc=#{rc})" if rc < 0

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

  def info : HTS::Bcf::Info
    bcf = HTS::Bcf.new(test_bcf_path)
    info = bcf.first.info
    bcf.close
    info
  end

  def test_get_int
    assert_equal([31], info.get_int("DP"))
    assert_equal([0.673439_f32], info.get_float("VDB"))
    assert_equal([0, 0, 14, 17], info.get_int("DP4"))
  end

  def test_int64_and_character_info
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record_info = bcf.first.info

        assert_equal([42_i64, Int64::MIN], record_info.get_int64("MIX"))
        assert_equal([42_i64, nil], record_info.get_int64_opt("MIX"))
        assert_equal("Q", record_info.get_string("CH"))
        assert_equal(:string, bcf.header.info_type("CH"))
        assert_equal("Q", record_info["CH"])
      end
    end
  end

  def test_bracket_access
    assert_equal([31], info["DP"])
    assert_equal([0.673439_f32], info["VDB"])
    assert_equal(false, info["INDEL"])

    tag = "DP"
    assert_equal([31], info[tag])
  end

  def test_low_level_contract
    assert_nil info.get_int("NO_SUCH_TAG")
    assert_nil info.get_int64("NO_SUCH_TAG")
    assert_nil info.get_string("NO_SUCH_TAG")
    assert_nil info.get_flag("NO_SUCH_TAG")

    ex = assert_raises(Exception) { info.get_float("DP") }
    assert_equal "Tag DP is not float INFO field", ex.message
  end
end
