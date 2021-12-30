require "minitest/autorun"
require "../../src/hts/bcf"

class BcfTest < Minitest::Test
  def teardown
    @bcf.try &.close
  end

  def test_bcf_path
    File.expand_path("../fixtures/test.bcf", __DIR__)
  end
  
  def bcf
    @bcf ||= HTS::Bcf.new(test_bcf_path)
  end

  def test_initialize
    assert_instance_of HTS::Bcf, bcf
  end

  def test_file_path
    assert_equal test_bcf_path, bcf.file_path
  end

  def test_header
    assert_instance_of HTS::Bcf::Header, bcf.header
  end

  def test_n_samples
    assert_equal 1, bcf.n_samples
  end
end
