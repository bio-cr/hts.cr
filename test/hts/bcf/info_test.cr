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
    assert_equal 3, info.get_string("STR")
  end
end
