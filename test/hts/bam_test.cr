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
    assert_equal true, b.closed?
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
    assert_equal true, b.closed?
  end

  def test_open_with_block
    f = HTS::Bam.open(test_bam_path) do |b|
      assert_instance_of HTS::Bam, b
    end
    assert_equal true, f.closed?
  end

  def test_file_path
    assert_equal test_bam_path, bam.file_path
  end

  def test_mode
    assert_equal "r", bam.mode
  end

  def test_header
    assert_instance_of HTS::Bam::Header, bam.header
  end

  def test_each
    bam.each do |aln|
      assert_instance_of HTS::Bam::Record, aln
    end
  end

  def test_query
    arr = [] of Int64
    bam.query("poo:3200-3300") do |aln|
      arr << aln.start
    end
    assert_equal [3289, 3292, 3293, 3298], arr
  end
end
