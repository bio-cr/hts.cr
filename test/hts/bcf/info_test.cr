require "minitest/autorun"
require "../../../src/hts/bcf"

class BcfInfoTest < Minitest::Test
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

  def test_bracket_access
    assert_equal([31], info["DP"])
    assert_equal([0.673439_f32], info["VDB"])
    assert_equal(false, info["INDEL"])

    tag = "DP"
    assert_equal([31], info[tag])
  end

  def test_low_level_contract
    assert_nil info.get_int("NO_SUCH_TAG")
    assert_nil info.get_string("NO_SUCH_TAG")
    assert_nil info.get_flag("NO_SUCH_TAG")

    ex = assert_raises(Exception) { info.get_float("DP") }
    assert_equal "Tag DP is not float INFO field", ex.message
  end
end
