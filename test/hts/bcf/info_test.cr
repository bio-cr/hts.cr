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
      header.append("##INFO=<ID=ABSI,Number=1,Type=Integer,Description=\"defined but absent integer\">")
      header.append("##INFO=<ID=ABSF,Number=1,Type=Float,Description=\"defined but absent float\">")
      header.append("##INFO=<ID=ABSS,Number=1,Type=String,Description=\"defined but absent string\">")
      header.append("##INFO=<ID=FLAG,Number=0,Type=Flag,Description=\"defined but absent flag\">")
      header.append("##INFO=<ID=MIX,Number=2,Type=Integer,Description=\"integer with missing\">")
      header.append("##INFO=<ID=FOPT,Number=2,Type=Float,Description=\"float with missing\">")
      header.append("##INFO=<ID=CH,Number=1,Type=Character,Description=\"character test\">")
      header.append("##INFO=<ID=WINT,Number=.,Type=Integer,Description=\"writable int\">")
      header.append("##INFO=<ID=W64,Number=.,Type=Integer,Description=\"writable int64\">")
      header.append("##INFO=<ID=WFLOAT,Number=.,Type=Float,Description=\"writable float\">")
      header.append("##INFO=<ID=WSTR,Number=1,Type=String,Description=\"writable string\">")
      header.append("##INFO=<ID=WFLAG,Number=0,Type=Flag,Description=\"writable flag\">")
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

        floats = [1.5_f32, HTS::LibHTS2.bcf_float_missing]
        rc = HTS::LibHTS2.bcf_update_info_float(header, record, "FOPT", floats.to_unsafe, floats.size)
        raise "bcf_update_info_float failed for FOPT (rc=#{rc})" if rc < 0

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

        assert_equal([42, Int32::MIN], record_info.get_int("MIX"))
        assert_equal([42, nil], record_info.get_int_opt("MIX"))
        assert_equal([42_i64, Int64::MIN], record_info.get_int64("MIX"))
        assert_equal([42_i64, nil], record_info.get_int64_opt("MIX"))
        raw_float = record_info.get_float("FOPT") || raise "FOPT should be present"
        assert_equal(2, raw_float.size)
        assert_equal(1.5_f32, raw_float[0])
        assert_equal(1, HTS::LibHTS2.bcf_float_is_missing(raw_float[1]))
        assert_equal([1.5_f32, nil], record_info.get_float_opt("FOPT"))
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

  def test_defined_but_absent_tags
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record_info = bcf.first.info

        assert_nil record_info.get_int("ABSI")
        assert_nil record_info.get_float("ABSF")
        assert_nil record_info.get_string("ABSS")
        assert_equal(false, record_info.get_flag("FLAG"))
      end
    end
  end

  def test_numeric_sentinel_helpers
    assert_equal(1, HTS::LibHTS2.bcf_int32_is_missing(HTS::LibHTS2.bcf_int32_missing))
    assert_equal(1, HTS::LibHTS2.bcf_int32_is_vector_end(HTS::LibHTS2.bcf_int32_vector_end))
    assert_equal(0, HTS::LibHTS2.bcf_int32_is_missing(42))
    assert_equal(0, HTS::LibHTS2.bcf_int32_is_vector_end(42))

    assert_equal(1, HTS::LibHTS2.bcf_int64_is_missing(HTS::LibHTS2.bcf_int64_missing))
    assert_equal(1, HTS::LibHTS2.bcf_int64_is_vector_end(HTS::LibHTS2.bcf_int64_vector_end))
    assert_equal(0, HTS::LibHTS2.bcf_int64_is_missing(42_i64))
    assert_equal(0, HTS::LibHTS2.bcf_int64_is_vector_end(42_i64))

    assert_equal(1, HTS::LibHTS2.bcf_float_is_missing(HTS::LibHTS2.bcf_float_missing))
    assert_equal(1, HTS::LibHTS2.bcf_float_is_vector_end(HTS::LibHTS2.bcf_float_vector_end))
    assert_equal(0, HTS::LibHTS2.bcf_float_is_missing(1.5_f32))
    assert_equal(0, HTS::LibHTS2.bcf_float_is_vector_end(1.5_f32))
  end

  def test_update_info_methods
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record = bcf.first
        info = record.info

        info.update_int("WINT", [10, 20])
        assert_equal([10, 20], info.get_int("WINT"))

        ex = assert_raises(Exception) { info.update_int64("W64", [(1_i64 << 40)]) }
        assert_includes ex.message.to_s, "BCF_HT_LONG"

        info.update_float("WFLOAT", [0.25_f32, 0.5_f32])
        assert_equal([0.25_f32, 0.5_f32], info.get_float("WFLOAT"))

        info.update_string("WSTR", "hello")
        assert_equal("hello", info.get_string("WSTR"))

        info.update_flag("WFLAG", true)
        assert_equal(true, info.get_flag("WFLAG"))

        info.update_flag("WFLAG", false)
        assert_includes([true, false], info.get_flag("WFLAG"))
      end
    end
  end

  def test_update_info_scalar_overloads_and_delete
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record = bcf.first
        info = record.info

        info.update_int("WINT", 7)
        assert_equal([7], info.get_int("WINT"))

        ex = assert_raises(Exception) { info.update_int64("W64", (1_i64 << 39)) }
        assert_includes ex.message.to_s, "BCF_HT_LONG"

        info.update_float("WFLOAT", 1.25)
        assert_equal([1.25_f32], info.get_float("WFLOAT"))

        info.update_string("WSTR", "bye")
        assert_equal("bye", info.get_string("WSTR"))

        assert_equal(true, info.delete("WSTR"))
        assert_nil(info.get_string("WSTR"))
        assert_equal(false, info.delete("NO_SUCH_TAG"))
      end
    end
  end
end
