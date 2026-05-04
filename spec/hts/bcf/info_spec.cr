require "../../spec_helper"
require "../../../src/hts/bcf"

class BcfInfoTest < HTSSpecCase
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
    expect_equal([31], info.get_int("DP"))
    expect_equal([0.673439_f32], info.get_float("VDB"))
    expect_equal([0, 0, 14, 17], info.get_int("DP4"))
  end

  def test_int64_and_character_info
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record_info = bcf.first.info

        expect_equal([42, Int32::MIN], record_info.get_int("MIX"))
        expect_equal([42, nil], record_info.get_int_opt("MIX"))
        expect_equal([42_i64, Int64::MIN], record_info.get_int64("MIX"))
        expect_equal([42_i64, nil], record_info.get_int64_opt("MIX"))
        raw_float = record_info.get_float("FOPT") || raise "FOPT should be present"
        expect_equal(2, raw_float.size)
        expect_equal(1.5_f32, raw_float[0])
        expect_equal(1, HTS::LibHTS2.bcf_float_is_missing(raw_float[1]))
        expect_equal([1.5_f32, nil], record_info.get_float_opt("FOPT"))
        expect_equal("Q", record_info.get_string("CH"))
        expect_equal(:string, bcf.header.info_type("CH"))
        expect_equal("Q", record_info["CH"])
      end
    end
  end

  def test_bracket_access
    expect_equal([31], info["DP"])
    expect_equal([0.673439_f32], info["VDB"])
    expect_equal(false, info["INDEL"])

    tag = "DP"
    expect_equal([31], info[tag])
  end

  def test_low_level_contract
    expect_nil info.get_int("NO_SUCH_TAG")
    expect_nil info.get_int64("NO_SUCH_TAG")
    expect_nil info.get_string("NO_SUCH_TAG")
    expect_nil info.get_flag("NO_SUCH_TAG")

    ex = expect_raises(HTS::Bcf::InfoTypeError) { info.get_float("DP") }
    expect_equal "Tag DP is not float INFO field", ex.message
  end

  def test_defined_but_absent_tags
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record_info = bcf.first.info

        expect_nil record_info.get_int("ABSI")
        expect_nil record_info.get_float("ABSF")
        expect_nil record_info.get_string("ABSS")
        expect_equal(false, record_info.get_flag("FLAG"))
      end
    end
  end

  def test_numeric_sentinel_helpers
    expect_equal(1, HTS::LibHTS2.bcf_int32_is_missing(HTS::LibHTS2.bcf_int32_missing))
    expect_equal(1, HTS::LibHTS2.bcf_int32_is_vector_end(HTS::LibHTS2.bcf_int32_vector_end))
    expect_equal(0, HTS::LibHTS2.bcf_int32_is_missing(42))
    expect_equal(0, HTS::LibHTS2.bcf_int32_is_vector_end(42))

    expect_equal(1, HTS::LibHTS2.bcf_int64_is_missing(HTS::LibHTS2.bcf_int64_missing))
    expect_equal(1, HTS::LibHTS2.bcf_int64_is_vector_end(HTS::LibHTS2.bcf_int64_vector_end))
    expect_equal(0, HTS::LibHTS2.bcf_int64_is_missing(42_i64))
    expect_equal(0, HTS::LibHTS2.bcf_int64_is_vector_end(42_i64))

    expect_equal(1, HTS::LibHTS2.bcf_float_is_missing(HTS::LibHTS2.bcf_float_missing))
    expect_equal(1, HTS::LibHTS2.bcf_float_is_vector_end(HTS::LibHTS2.bcf_float_vector_end))
    expect_equal(0, HTS::LibHTS2.bcf_float_is_missing(1.5_f32))
    expect_equal(0, HTS::LibHTS2.bcf_float_is_vector_end(1.5_f32))
  end

  def test_update_info_methods
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record = bcf.first
        info = record.info

        info.update_int("WINT", [10, 20])
        expect_equal([10, 20], info.get_int("WINT"))

        ex = expect_raises(HTS::Bcf::UnsupportedInfoOperationError) { info.update_int64("W64", [(1_i64 << 40)]) }
        expect_includes ex.message.to_s, "BCF_HT_LONG"

        info.update_float("WFLOAT", [0.25_f32, 0.5_f32])
        expect_equal([0.25_f32, 0.5_f32], info.get_float("WFLOAT"))

        info.update_string("WSTR", "hello")
        expect_equal("hello", info.get_string("WSTR"))

        info.update_flag("WFLAG", true)
        expect_equal(true, info.get_flag("WFLAG"))

        info.update_flag("WFLAG", false)
        expect_includes([true, false], info.get_flag("WFLAG"))
      end
    end
  end

  def test_update_info_scalar_overloads_and_delete
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record = bcf.first
        info = record.info

        info.update_int("WINT", 7)
        expect_equal([7], info.get_int("WINT"))

        ex = expect_raises(HTS::Bcf::UnsupportedInfoOperationError) { info.update_int64("W64", (1_i64 << 39)) }
        expect_includes ex.message.to_s, "BCF_HT_LONG"

        info.update_float("WFLOAT", 1.25)
        expect_equal([1.25_f32], info.get_float("WFLOAT"))

        info.update_string("WSTR", "bye")
        expect_equal("bye", info.get_string("WSTR"))

        expect_equal(true, info.delete("WSTR"))
        expect_nil(info.get_string("WSTR"))
        expect_equal(false, info.delete("NO_SUCH_TAG"))
      end
    end
  end
end

describe BcfInfoTest do
  {% for method in BcfInfoTest.methods.select { |method| method.name.stringify.starts_with?("test_") } %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BcfInfoTest.new
      run_spec_case(spec_case) do
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
