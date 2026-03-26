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
end
