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

  def test_initialize
    assert_instance_of HTS::Bam, bam
  end

  def test_file_path
    assert_equal test_bam_path, bam.file_path
  end

  def test_header
    assert_instance_of HTS::Bam::Header, bam.header
  end
end
