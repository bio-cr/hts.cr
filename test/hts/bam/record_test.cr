require "minitest/autorun"
require "../../../src/hts/bam"

class BamRecordTest < Minitest::Test
  def test_bam_path
    File.expand_path("../../fixtures/poo.sort.bam", __DIR__)
  end

  def aln1 : HTS::Bam::Record
    bam = HTS::Bam.new(test_bam_path)
    r = bam.first
    bam.close
    r
  end

  def test_tid
    assert_equal 0, aln1.tid
  end

  def test_mate_tid
    assert_equal 0, aln1.mate_tid
  end

  def test_start
    assert_equal 3289, aln1.start
  end

  def test_stop
    assert_equal 3290, aln1.stop
  end

  def test_qname
    assert_equal "poo_3290_3833_2:0:0_2:0:0_119", aln1.qname
  end

  def test_mate_start
    assert_equal 3289, aln1.mate_start
  end

  def test_mate_pos
    assert_equal 3289, aln1.mate_pos
  end

  def test_chrom
    assert_equal "poo", aln1.chrom
  end

  def test_mate_chrom
    assert_equal "poo", aln1.mate_chrom
  end

  def test_strand
    assert_equal "+", aln1.strand
  end

  def test_isize
    assert_equal 0, aln1.isize
  end

  def test_mapping_quality
    assert_equal 0, aln1.mapping_quality
  end

  def test_chrom
    assert_equal "poo", aln1.chrom
  end

  def test_cigar
    assert_instance_of HTS::Bam::Cigar, aln1.cigar
  end

  def test_qlen
    assert_equal 0, aln1.qlen
  end

  def test_rlen
    assert_equal 0, aln1.rlen
  end

  def test_sequence
    assert_equal "GGGGCAGCTTGTTCGAAGCGTGACCCCCAAGACGTCGTCCTGACGAGCACAAACTCCCATTGAGAGTGGC", aln1.sequence
  end

  def test_base_at
    assert_equal 'G', aln1.base_at(0)
    assert_equal 'C', aln1.base_at(4)
    assert_equal 'A', aln1.base_at(5)
    assert_equal '.', aln1.base_at(70)
    assert_equal 'C', aln1.base_at(-1)
    assert_equal 'G', aln1.base_at(-2)
    assert_equal 'G', aln1.base_at(-70)
    assert_equal '.', aln1.base_at(-71)
  end
end
