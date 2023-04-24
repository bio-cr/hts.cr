require "minitest/autorun"
require "../../../src/hts/bam"
require "./flag_test" # Required for automatic generation of test methods related to Flag

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

  def test_qname_set
    aln = aln1
    assert_equal "poo_3290_3833_2:0:0_2:0:0_119", aln.qname
    aln.qname = "test_qname_01"
    assert_equal "test_qname_01", aln.qname
    aln.qname = "poo_3290_3833_2:0:0_2:0:0_119"
    assert_equal "poo_3290_3833_2:0:0_2:0:0_119", aln.qname
  end

  def test_tid
    assert_equal 0, aln1.tid
  end

  def test_tid_set
    aln = aln1
    assert_equal 0, aln.tid
    aln.tid = 1
    assert_equal 1, aln.tid
    aln.tid = 0
    assert_equal 0, aln.tid
  end

  def test_mtid
    assert_equal 0, aln1.mtid
  end

  def test_mtid_set
    aln = aln1
    assert_equal 0, aln.mtid
    aln.mtid = 1
    assert_equal 1, aln.mtid
    aln.mtid = 0
    assert_equal 0, aln.mtid
  end

  def test_pos
    assert_equal 3289, aln1.pos
  end

  def test_pos_set
    aln = aln1
    assert_equal 3289, aln.pos
    aln.pos = 3290
    assert_equal 3290, aln.pos
    aln.pos = 3289
    assert_equal 3289, aln.pos
  end

  def test_mpos
    assert_equal 3289, aln1.mpos
  end

  def test_mpos_set
    aln = aln1
    assert_equal 3289, aln.mpos
    aln.mpos = 3290
    assert_equal 3290, aln.mpos
    aln.mpos = 3289
    assert_equal 3289, aln.mpos
  end

  def test_bin
    assert_equal 4681, aln1.bin
  end

  def test_bin_set
    aln = aln1
    assert_equal 4681, aln.bin
    aln.bin = 4682
    assert_equal 4682, aln.bin
    aln.bin = 4681
    assert_equal 4681, aln.bin
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

  def test_mate_contig
    assert_equal "poo", aln1.mate_contig
  end

  def test_endpos
    assert_equal 3290, aln1.endpos
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
    aln = aln1
    assert_equal 0, aln.insert_size
    aln.insert_size = 1
    assert_equal 1, aln.insert_size
    aln.insert_size = 0
    assert_equal 0, aln.insert_size
  end

  def test_isize_set
    aln = aln1
    assert_equal 0, aln.isize
    aln.isize = 1
    assert_equal 1, aln.isize
    aln.isize = 0
    assert_equal 0, aln.isize
  end

  def test_mapq
    assert_equal 0, aln1.mapq
  end

  def test_mapq_set
    aln = aln1
    assert_equal 0, aln.mapq
    aln.mapq = 1
    assert_equal 1, aln.mapq
    aln.mapq = 0
    assert_equal 0, aln.mapq
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

  def test_flag_set
    aln = aln1
    assert_equal 133, aln.flag.value
    aln.flag = 0
    assert_equal 0, aln.flag.value
    f = HTS::Bam::Flag.new(133)
    aln.flag = f
    assert_equal 133, aln.flag.value
  end

  def test_aux
    aln = aln1
    assert_equal "70M", aln.aux("MC")
    assert_equal 0, aln.aux("AS")
    assert_equal 0, aln.aux("XS")
    assert_nil aln.aux("Tanuki")
  end

  def test_aux_int
    aln = aln1
    assert_equal 0, aln.aux_int("AS")
    assert_equal 0, aln.aux_int("XS")
    a = [] of Int64
    assert_equal [0], (a << aln.aux_int("AS"))
  end

  def test_aux_string
    aln = aln1
    assert_equal "70M", aln.aux_string("MC")
  end

  # TODO: def test_aux_float

  # TODO: def test_aux_flag

  # TODO: def test_aux_char

  {% for name in BamFlagTest::FLAG_METHODS %}
    def test_{{name.id}}
      assert_equal aln1.flag.{{name.id}}, aln1.{{name.id}}
    end
  {% end %}

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
