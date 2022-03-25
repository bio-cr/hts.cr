require "minitest/autorun"
require "../../../src/hts/bam"

class BamCigarTest < Minitest::Test
  def test_bam_path
    File.expand_path("../../fixtures/moo.bam", __DIR__)
  end

  def cigar9 : HTS::Bam::Cigar
    bam = HTS::Bam.open(test_bam_path)
    r = bam.first(8).last
    bam.close
    r.cigar
  end

  def test_initalize
    assert_instance_of HTS::Bam::Cigar, cigar9
  end

  def test_each
    assert_equal [{'M', 28}, {'I', 1}, {'M', 11}], cigar9.to_a
  end

  def test_to_s
    assert_equal "28M1I11M", cigar9.to_s
  end
end
