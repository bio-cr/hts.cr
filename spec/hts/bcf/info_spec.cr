require "../../spec_helper"
require "../../../src/hts/bcf"

class BcfInfoTest
  def with_temp_bcf(&)
    file = File.tempfile("info_test", ".bcf")
    path = file.path || raise "tempfile path is nil"
    begin
      file.close

      header = HTS::Bcf::Header.new
      header.version = "VCFv4.3"
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
    bcf = with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogError) { HTS::Bcf.new(test_bcf_path) }
    info = bcf.first.info
    bcf.close
    info
  end

  def test_get_int
    (info.get_int("DP")).should eq([31])
    (info.get_float("VDB")).should eq([0.673439_f32])
    (info.get_int("DP4")).should eq([0, 0, 14, 17])
  end

  def test_getters_reuse_typed_scratch_buffers
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record = bcf.first
        info = record.info
        scratch = record.scratch

        (scratch.info_i32.null?).should be_true
        (info.get_int("MIX")).should eq([42, Int32::MIN])
        int_pointer = scratch.info_i32
        int_capacity = scratch.info_i32_capacity
        (int_pointer.null?).should be_false

        (info.get_int("MIX")).should eq([42, Int32::MIN])
        (scratch.info_i32).should eq(int_pointer)
        (scratch.info_i32_capacity).should eq(int_capacity)

        (info.get_int64("MIX")).should eq([42_i64, Int64::MIN])
        (scratch.info_i64.null?).should be_false
        (info.get_float("FOPT")).should_not be_nil
        (scratch.info_f32.null?).should be_false
        (info.get_string("CH")).should eq("Q")
        (scratch.info_char.null?).should be_false

        # Other INFO element types do not invalidate the Int32 storage.
        (scratch.info_i32).should eq(int_pointer)
      end
    end
  end

  def test_borrowed_numeric_buffers
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record = bcf.first
        info = record.info

        info.with_i32_buffer("MIX") do |values|
          (values).should eq(Slice[42, Int32::MIN])
          (values.to_unsafe).should eq(record.scratch.info_i32)
          (values.size).should eq(2)
        end.should be_true

        info.with_i64_buffer("MIX") do |values|
          (values).should eq(Slice[42_i64, Int64::MIN])
          (values.to_unsafe).should eq(record.scratch.info_i64)
          (values.size).should eq(2)
        end.should be_true

        info.with_f32_buffer("FOPT") do |values|
          (values.to_unsafe).should eq(record.scratch.info_f32)
          (values.size).should eq(2)
          (values[0]).should eq(1.5_f32)
          (HTS::LibHTS2.bcf_float_is_missing(values[1])).should eq(1)
        end.should be_true

        absent_yielded = false
        info.with_i32_buffer("ABSI") { absent_yielded = true }.should be_false
        (absent_yielded).should be_false
      end
    end
  end

  def test_borrowed_string_view
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record = bcf.first
        info = record.info

        yielded = false
        info.with_string_view("CH") do |bytes|
          yielded = true
          (bytes).should eq(Bytes['Q'.ord])
          (bytes.to_unsafe).should eq(record.scratch.info_char)
          (bytes.size).should eq(1)
        end.should be_true
        (yielded).should be_true

        yielded = false
        info.with_string_view("ABSS") { yielded = true }.should be_false
        (yielded).should be_false
        (info.get_string("CH")).should eq("Q")
      end
    end
  end

  def test_int64_and_character_info
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record_info = bcf.first.info

        (record_info.get_int("MIX")).should eq([42, Int32::MIN])
        (record_info.get_int_opt("MIX")).should eq([42, nil])
        (record_info.get_int64("MIX")).should eq([42_i64, Int64::MIN])
        (record_info.get_int64_opt("MIX")).should eq([42_i64, nil])
        raw_float = record_info.get_float("FOPT") || raise "FOPT should be present"
        (raw_float.size).should eq(2)
        (raw_float[0]).should eq(1.5_f32)
        (HTS::LibHTS2.bcf_float_is_missing(raw_float[1])).should eq(1)
        (record_info.get_float_opt("FOPT")).should eq([1.5_f32, nil])
        (record_info.get_string("CH")).should eq("Q")
        (bcf.header.info_type("CH")).should eq(:string)
      end
    end
  end

  def test_low_level_contract
    expect_raises(HTS::Bcf::InfoDefinitionError) { info.get_int("NO_SUCH_TAG") }
    expect_raises(HTS::Bcf::InfoDefinitionError) { info.get_int64("NO_SUCH_TAG") }
    expect_raises(HTS::Bcf::InfoDefinitionError) { info.get_string("NO_SUCH_TAG") }
    expect_raises(HTS::Bcf::InfoDefinitionError) { info.get_flag("NO_SUCH_TAG") }
    expect_raises(HTS::Bcf::InfoDefinitionError) { info.with_i32_buffer("NO_SUCH_TAG") { } }
    expect_raises(HTS::Bcf::InfoDefinitionError) { info.with_string_view("NO_SUCH_TAG") { } }

    ex = expect_raises(HTS::Bcf::InfoTypeError) { info.get_float("DP") }
    (ex.message).should eq("Tag DP is not float INFO field")
    expect_raises(HTS::Bcf::InfoTypeError) { info.with_f32_buffer("DP") { } }
    expect_raises(HTS::Bcf::InfoTypeError) { info.with_string_view("DP") { } }
  end

  def test_defined_but_absent_tags
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record_info = bcf.first.info

        (record_info.get_int("ABSI")).should be_nil
        (record_info.get_float("ABSF")).should be_nil
        (record_info.get_string("ABSS")).should be_nil
        (record_info.get_flag("FLAG")).should be_false
      end
    end
  end

  def test_numeric_sentinel_helpers
    (HTS::LibHTS2.bcf_int32_is_missing(HTS::LibHTS2.bcf_int32_missing)).should eq(1)
    (HTS::LibHTS2.bcf_int32_is_vector_end(HTS::LibHTS2.bcf_int32_vector_end)).should eq(1)
    (HTS::LibHTS2.bcf_int32_is_missing(42)).should eq(0)
    (HTS::LibHTS2.bcf_int32_is_vector_end(42)).should eq(0)

    (HTS::LibHTS2.bcf_int64_is_missing(HTS::LibHTS2.bcf_int64_missing)).should eq(1)
    (HTS::LibHTS2.bcf_int64_is_vector_end(HTS::LibHTS2.bcf_int64_vector_end)).should eq(1)
    (HTS::LibHTS2.bcf_int64_is_missing(42_i64)).should eq(0)
    (HTS::LibHTS2.bcf_int64_is_vector_end(42_i64)).should eq(0)

    (HTS::LibHTS2.bcf_float_is_missing(HTS::LibHTS2.bcf_float_missing)).should eq(1)
    (HTS::LibHTS2.bcf_float_is_vector_end(HTS::LibHTS2.bcf_float_vector_end)).should eq(1)
    (HTS::LibHTS2.bcf_float_is_missing(1.5_f32)).should eq(0)
    (HTS::LibHTS2.bcf_float_is_vector_end(1.5_f32)).should eq(0)
  end

  def test_update_info_methods
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record = bcf.first
        info = record.info

        info.update_int("WINT", [10, 20])
        (info.get_int("WINT")).should eq([10, 20])

        ex = expect_raises(HTS::Bcf::UnsupportedInfoOperationError) { info.update_int64("W64", [(1_i64 << 40)]) }
        (ex.message.to_s).should contain("BCF_HT_LONG")

        info.update_float("WFLOAT", [0.25_f32, 0.5_f32])
        (info.get_float("WFLOAT")).should eq([0.25_f32, 0.5_f32])

        info.update_string("WSTR", "hello")
        (info.get_string("WSTR")).should eq("hello")

        info.update_flag("WFLAG", true)
        (info.get_flag("WFLAG")).should be_true

        info.update_flag("WFLAG", false)
        ([true, false]).should contain(info.get_flag("WFLAG"))
      end
    end
  end

  def test_update_info_scalar_overloads_and_delete
    with_temp_bcf do |path|
      HTS::Bcf.open(path) do |bcf|
        record = bcf.first
        info = record.info

        info.update_int("WINT", 7)
        (info.get_int("WINT")).should eq([7])

        ex = expect_raises(HTS::Bcf::UnsupportedInfoOperationError) { info.update_int64("W64", (1_i64 << 39)) }
        (ex.message.to_s).should contain("BCF_HT_LONG")

        info.update_float("WFLOAT", 1.25)
        (info.get_float("WFLOAT")).should eq([1.25_f32])

        info.update_string("WSTR", "bye")
        (info.get_string("WSTR")).should eq("bye")

        (info.delete("WSTR")).should be_true
        (info.get_string("WSTR")).should be_nil
        (info.delete("NO_SUCH_TAG")).should be_false
      end
    end
  end
end

describe BcfInfoTest do
  {% for method in BcfInfoTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BcfInfoTest.new
      begin
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
