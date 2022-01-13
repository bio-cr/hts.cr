require "minitest/autorun"
require "../../src/hts/bam"

class BamTest < Minitest::Test
  def teardown
    @bam.try &.close
  end

  def test_bam_path
    File.expand_path("../fixtures/poo.sort.bam", __DIR__)
  end

  def bam
    @bam ||= HTS::Bam.new(test_bam_path)
  end

  def test_new
    b = HTS::Bam.new(test_bam_path)
    assert_instance_of HTS::Bam, b
    b.close
  end

  def test_open_with_block
    assert_raise do
      HTS::Bam.open(test_bam_path)
    end
  end

  def test_open
    b = HTS::Bam.open(test_bam_path)
    assert_instance_of HTS::Bam, b
    b.close
  end

  def test_open_with_block
    HTS::Bam.open(test_bam_path) do |b|
      assert_instance_of HTS::Bam, b
    end
  end

  def test_file_path
    assert_equal test_bam_path, bam.file_path
  end

  def test_header
    assert_instance_of HTS::Bam::Header, bam.header
  end
end
