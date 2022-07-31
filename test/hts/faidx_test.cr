require "minitest/autorun"
require "../../src/hts/faidx"

class FaidxTest < Minitest::Test
  def teardown
    @faidx.try &.close
  end

  def test_faidx_path
    File.expand_path("../fixtures/random.fa", __DIR__)
  end

  def faidx
    @faidx ||= HTS::Faidx.new(test_faidx_path)
  end

  def test_new
    f = HTS::Faidx.new(test_faidx_path)
    assert_instance_of HTS::Faidx, f
    f.close
  end

  def test_open
    f = HTS::Faidx.open(test_faidx_path)
    assert_instance_of HTS::Faidx, f
    f.close
  end

  def test_open_with_block
    f = HTS::Faidx.open(test_faidx_path) do |f|
      assert_instance_of HTS::Faidx, f
    end
  end

  def test_faidx_file_name
    assert_equal test_faidx_path, faidx.file_name
  end

  def test_struct
    assert_instance_of HTS::LibHTS::FaidxT, faidx.struct
  end

  def test_size
    assert_equal 5, faidx.size
  end

  def test_length
    assert_equal 5, faidx.length
  end

  def test_chrom_names
    assert_equal ["chr1", "chr2", "chr3", "chr4", "chr5"], faidx.chrom_names
  end

  def test_seq
    assert_equal "TTGTGGAGAC", faidx.seq("chr1:1-10")
    assert_equal "TTGTGGAGAC", faidx.seq(:chr1, 0, 9)
    assert_equal "ACTTAGTTGA", faidx.seq("chr2:11-20")
    assert_equal "ACTTAGTTGA", faidx.seq(:chr2, 10, 19)
  end
end
