require "minitest/autorun"
require "../../../src/hts/bcf"

class BcfFormatTest < Minitest::Test
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

  def test_low_level_contract
    assert_nil format.get_int("NO_SUCH_TAG")
    assert_nil format.get_float("NO_SUCH_TAG")
    assert_nil format.get_string("NO_SUCH_TAG")

    ex = assert_raises(Exception) { format.get_float("PL") }
    assert_equal "Tag PL is not float FORMAT field", ex.message
  end
end
