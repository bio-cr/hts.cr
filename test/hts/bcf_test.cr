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

  def test_new
    b = HTS::Bcf.new(test_bcf_path)
    assert_instance_of HTS::Bcf, b
    b.close
    assert_equal true, b.closed?
  end

  # def test_new_with_block
  #   assert_raises do
  #     HTS::Bcf.new(test_bcf_path) {}
  #   end
  # end

  def test_open
    b = HTS::Bcf.open(test_bcf_path)
    assert_instance_of HTS::Bcf, b
    b.close
    assert_equal true, b.closed?
  end

  def test_open_with_block
    f = HTS::Bcf.open(test_bcf_path) do |b|
      assert_instance_of HTS::Bcf, b
    end
    assert_equal true, f.closed?
  end

  def test_file_name
    assert_equal test_bcf_path, bcf.file_name
  end

  def test_header
    assert_instance_of HTS::Bcf::Header, bcf.header
  end

  def test_nsamples
    assert_equal 1, bcf.nsamples
  end

  def test_samples
    assert_equal ["poo.sort.bam"], bcf.samples
  end
end
