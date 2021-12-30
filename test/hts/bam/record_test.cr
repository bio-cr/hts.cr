require "minitest/autorun"
require "../../../src/hts/bam"

class BamRecordTest < Minitest::Test
  # def teardown
  #   @bam.try &.close
  # end

  def test_bam_path
    File.expand_path("../fixtures/poo.sort.bam", __DIR__)
  end
  
  def aln1 : HTS::Bam::Record
    @aln1 ||= HTS::Bam.new(test_bam_path).first
  end

  def test_qname
    assert_equal "poo", aln1.try &.qname
  end
end
