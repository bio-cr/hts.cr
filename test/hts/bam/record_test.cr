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

  def test_qname
    assert_equal "poo_3290_3833_2:0:0_2:0:0_119", aln1.qname
  end

  def test_tid
    assert_equal 0, aln1.tid
  end

  def test_tid_set
    a = aln1
    assert_equal 0, a.tid
    a.tid = 1
    assert_equal 1, a.tid
    a.tid = 0
    assert_equal 0, a.tid
  end

  def test_mtid
    assert_equal 0, aln1.mtid
  end

  def test_mtid_set
    a = aln1
    assert_equal 0, a.mtid
    a.mtid = 1
    assert_equal 1, a.mtid
    a.mtid = 0
    assert_equal 0, a.mtid
  end

  def test_pos
    assert_equal 3289, aln1.pos
  end

  def test_pos_set
    a = aln1
    assert_equal 3289, a.pos
    a.pos = 3290
    assert_equal 3290, a.pos
    a.pos = 3289
    assert_equal 3289, a.pos
  end

  def test_mpos
    assert_equal 3289, aln1.mpos
  end

  def test_mpos_set
    a = aln1
    assert_equal 3289, a.mpos
    a.mpos = 3290
    assert_equal 3290, a.mpos
    a.mpos = 3289
    assert_equal 3289, a.mpos
  end

  def test_bin
    assert_equal 4681, aln1.bin
  end

  def test_bin_set
    a = aln1
    assert_equal 4681, a.bin
    a.bin = 4682
    assert_equal 4682, a.bin
    a.bin = 4681
    assert_equal 4681, a.bin
  end

  def test_endpos
    assert_equal 3290, aln1.endpos
  end

  def test_chrom
    assert_equal "poo", aln1.chrom
  end

  def test_contig
    assert_equal "poo", aln1.contig
  end

  def test_mate_chrom
    assert_equal "poo", aln1.mate_chrom
  end

  def test_strand
    assert_equal "+", aln1.strand
  end

  def test_insert_size
    assert_equal 0, aln1.insert_size
  end

  def test_isize
    assert_equal 0, aln1.isize
  end

  def test_insert_size_set
    a = aln1
    assert_equal 0, a.insert_size
    a.insert_size = 1
    assert_equal 1, a.insert_size
    a.insert_size = 0
    assert_equal 0, a.insert_size
  end

  def test_isize_set
    a = aln1
    assert_equal 0, a.isize
    a.isize = 1
    assert_equal 1, a.isize
    a.isize = 0
    assert_equal 0, a.isize
  end

  def test_mapq
    assert_equal 0, aln1.mapq
  end

  def test_mapq_set
    a = aln1
    assert_equal 0, a.mapq
    a.mapq = 1
    assert_equal 1, a.mapq
    a.mapq = 0
    assert_equal 0, a.mapq
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

  def test_seq
    assert_equal "GGGGCAGCTTGTTCGAAGCGTGACCCCCAAGACGTCGTCCTGACGAGCACAAACTCCCATTGAGAGTGGC", aln1.seq
  end

  def test_sequence
    assert_equal "GGGGCAGCTTGTTCGAAGCGTGACCCCCAAGACGTCGTCCTGACGAGCACAAACTCCCATTGAGAGTGGC", aln1.sequence
  end

  def test_len
    assert_equal 70, aln1.len
  end

  def test_base
    aln = aln1
    assert_equal 'G', aln.base(0)
    assert_equal 'C', aln.base(4)
    assert_equal 'A', aln.base(5)
    assert_equal '.', aln.base(70)
    assert_equal 'C', aln.base(-1)
    assert_equal 'G', aln.base(-2)
    assert_equal 'G', aln.base(-70)
    assert_equal '.', aln.base(-71)
  end

  def test_qual
    assert_equal ([17] * 70), aln1.qual
  end

  def test_base_qual
    assert_equal 17, aln1.base_qual(0)
    assert_equal 17, aln1.base_qual(-1)
    assert_equal 17, aln1.base_qual(69)
    assert_equal 17, aln1.base_qual(-70)
  end

  def test_flag
    aln = aln1
    assert_instance_of HTS::Bam::Flag, aln.flag
    assert_equal 133, aln.flag.value
  end

  def test_tag
    aln = aln1
    assert_equal "70M", aln.tag("MC")
    assert_equal 0, aln.tag("AS")
    assert_equal 0, aln.tag("XS")
    assert_nil aln.tag("Tanuki")
  end

  def test_tag_int
    aln = aln1
    assert_equal "70M", aln.tag_string("MC")
    assert_equal 0, aln.tag_int("AS")
    assert_equal 0, aln.tag_int("XS")
    a = [] of Int64
    assert_equal [0], (a << aln.tag_int("AS"))
  end

  def test_to_s
    assert_equal "poo_3290_3833_2:0:0_2:0:0_119\t133\tpoo\t3290\t0\t*\t=\t3290\t0\tGGGGCAGCTTGTTCGAAGCGTGACCCCCAAGACGTCGTCCTGACGAGCACAAACTCCCATTGAGAGTGGC\t2222222222222222222222222222222222222222222222222222222222222222222222\tMC:Z:70M\tAS:i:0\tXS:i:0",
      aln1.to_s
  end

  def test_clone
    aln = aln1
    aln2 = aln.clone
    assert_equal aln.to_s, aln2.to_s
  end
end
