require "../../spec_helper"
require "../../../src/hts/bam"

class BamRecordTest < HTSSpecCase
  def test_bam_path
    File.expand_path("../../fixtures/poo.sort.bam", __DIR__)
  end

  def aln1 : HTS::Bam::Record
    bam = HTS::Bam.new(test_bam_path)
    r = bam.first
    bam.close
    r
  end

  def minimal_header : HTS::Bam::Header
    HTS::Bam::Header.parse("@HD\tVN:1.6\tSO:unknown\n@SQ\tSN:chr1\tLN:1000\n")
  end

  def test_initialize_rejects_short_qual
    error = expect_raises(ArgumentError) do
      HTS::Bam::Record.new(
        minimal_header,
        "read1",
        0,
        0,
        0_i64,
        60,
        HTS::Bam::Cigar.encode("4M"),
        "ACGT",
        [30_u8, 30_u8, 30_u8]
      )
    end

    expect_equal "qual length must equal sequence length", error.message
  end

  def test_qname
    expect_equal "poo_3290_3833_2:0:0_2:0:0_119", aln1.qname
  end

  def test_qname_set
    aln = aln1
    expect_equal "poo_3290_3833_2:0:0_2:0:0_119", aln.qname
    aln.qname = "test_qname_01"
    expect_equal "test_qname_01", aln.qname
    aln.qname = "poo_3290_3833_2:0:0_2:0:0_119"
    expect_equal "poo_3290_3833_2:0:0_2:0:0_119", aln.qname
  end

  def test_tid
    expect_equal 0, aln1.tid
  end

  def test_tid_set
    aln = aln1
    expect_equal 0, aln.tid
    aln.tid = 1
    expect_equal 1, aln.tid
    aln.tid = 0
    expect_equal 0, aln.tid
  end

  def test_mtid
    expect_equal 0, aln1.mtid
  end

  def test_mtid_set
    aln = aln1
    expect_equal 0, aln.mtid
    aln.mtid = 1
    expect_equal 1, aln.mtid
    aln.mtid = 0
    expect_equal 0, aln.mtid
  end

  def test_pos
    expect_equal 3289, aln1.pos
  end

  def test_pos_set
    aln = aln1
    expect_equal 3289, aln.pos
    aln.pos = 3290
    expect_equal 3290, aln.pos
    aln.pos = 3289
    expect_equal 3289, aln.pos
  end

  def test_mpos
    expect_equal 3289, aln1.mpos
  end

  def test_mpos_set
    aln = aln1
    expect_equal 3289, aln.mpos
    aln.mpos = 3290
    expect_equal 3290, aln.mpos
    aln.mpos = 3289
    expect_equal 3289, aln.mpos
  end

  def test_bin
    expect_equal 4681, aln1.bin
  end

  def test_bin_set
    aln = aln1
    expect_equal 4681, aln.bin
    aln.bin = 4682
    expect_equal 4682, aln.bin
    aln.bin = 4681
    expect_equal 4681, aln.bin
  end

  def test_chrom
    expect_equal "poo", aln1.chrom
  end

  def test_contig
    expect_equal "poo", aln1.contig
  end

  def test_mate_chrom
    expect_equal "poo", aln1.mate_chrom
  end

  def test_mate_contig
    expect_equal "poo", aln1.mate_contig
  end

  def test_endpos
    expect_equal 3290, aln1.endpos
  end

  def test_strand
    expect_equal "+", aln1.strand
  end

  def test_mates_strand
    expect_equal "+", aln1.strand
  end

  def test_insert_size
    expect_equal 0, aln1.insert_size
  end

  def test_isize
    expect_equal 0, aln1.isize
  end

  def test_insert_size_set
    aln = aln1
    expect_equal 0, aln.insert_size
    aln.insert_size = 1
    expect_equal 1, aln.insert_size
    aln.insert_size = 0
    expect_equal 0, aln.insert_size
  end

  def test_isize_set
    aln = aln1
    expect_equal 0, aln.isize
    aln.isize = 1
    expect_equal 1, aln.isize
    aln.isize = 0
    expect_equal 0, aln.isize
  end

  def test_mapq
    expect_equal 0, aln1.mapq
  end

  def test_mapq_set
    aln = aln1
    expect_equal 0, aln.mapq
    aln.mapq = 1
    expect_equal 1, aln.mapq
    aln.mapq = 0
    expect_equal 0, aln.mapq
  end

  def test_cigar
    expect_instance_of HTS::Bam::Cigar, aln1.cigar
  end

  def test_qlen
    expect_equal 0, aln1.qlen
  end

  def test_rlen
    expect_equal 0, aln1.rlen
  end

  def test_seq
    expect_equal "GGGGCAGCTTGTTCGAAGCGTGACCCCCAAGACGTCGTCCTGACGAGCACAAACTCCCATTGAGAGTGGC", aln1.seq
  end

  def test_sequence
    expect_equal "GGGGCAGCTTGTTCGAAGCGTGACCCCCAAGACGTCGTCCTGACGAGCACAAACTCCCATTGAGAGTGGC", aln1.sequence
  end

  def test_len
    expect_equal 70, aln1.len
  end

  def test_base
    aln = aln1
    expect_equal 'G', aln.base(0)
    expect_equal 'C', aln.base(4)
    expect_equal 'A', aln.base(5)
    expect_equal '.', aln.base(70)
    expect_equal 'C', aln.base(-1)
    expect_equal 'G', aln.base(-2)
    expect_equal 'G', aln.base(-70)
    expect_equal '.', aln.base(-71)
  end

  def test_qual
    expect_equal ([17] * 70), aln1.qual
  end

  def test_qual_string
    expect_equal "2" * 70, aln1.qual_string
  end

  def test_base_qual
    expect_equal 17, aln1.base_qual(0)
    expect_equal 17, aln1.base_qual(-1)
    expect_equal 17, aln1.base_qual(69)
    expect_equal 17, aln1.base_qual(-70)
  end

  def test_flag
    aln = aln1
    expect_instance_of HTS::Bam::Flag, aln.flag
    expect_equal 133, aln.flag.value
  end

  def test_flag_set
    aln = aln1
    expect_equal 133, aln.flag.value
    aln.flag = 0
    expect_equal 0, aln.flag.value
    f = HTS::Bam::Flag.new(133)
    aln.flag = f
    expect_equal 133, aln.flag.value
  end

  def test_aux
    aln = aln1
    expect_equal "70M", aln.aux("MC")
    expect_equal 0, aln.aux("AS")
    expect_equal 0, aln.aux("XS")
    expect_nil aln.aux("Tanuki")
  end

  def test_aux_each
    aln = aln1
    aln.aux.each do |tag, value|
      case tag
      when "MC"
        expect_equal "70M", value
      when "AS"
        expect_equal 0, value
      when "XS"
        expect_equal 0, value
      end
    end
  end

  def test_aux_bracket_access
    aln = aln1
    expect_equal "70M", aln.aux["MC"]
    expect_equal 0, aln.aux["AS"]
    expect_equal 0, aln.aux["XS"]
    expect_nil aln.aux["Tanuki"]
  end

  def test_aux_type_specific_methods
    aln = aln1
    expect_equal 0, aln.aux.get_int("AS")
    expect_equal 0, aln.aux.get_int("XS")
    expect_equal "70M", aln.aux.get_string("MC")
    expect_nil aln.aux.get_int("Tanuki")
    expect_nil aln.aux.get_string("Tanuki")
  end

  def test_aux_iteration_consistency
    aln = aln1
    tags1 = [] of String
    tags2 = [] of String

    2.times do
      aln.aux.each { |tag, _| tags1 << tag }
      aln.aux.each { |tag, _| tags2 << tag }
    end

    expect_equal tags1, tags2
  end

  def test_aux_int
    aln = aln1
    expect_equal 0, aln.aux_int("AS")
    expect_equal 0, aln.aux_int("XS")
    a = [] of (Int64 | Nil)
    expect_equal [0], (a << aln.aux_int("AS"))
  end

  def test_aux_string
    aln = aln1
    expect_equal "70M", aln.aux_string("MC")
  end

  def test_aux_type_specific_methods_return_nil_for_missing_tag
    aln = aln1

    expect_nil aln.aux_int("Tanuki")
    expect_nil aln.aux_float("Tanuki")
    expect_nil aln.aux_string("Tanuki")
    expect_nil aln.aux_char("Tanuki")
  end

  def test_aux_to_s
    aln = aln1
    expected = "MC:Z:70M\tAS:i:0\tXS:i:0"
    expect_equal expected, aln.aux.to_s
  end

  def test_aux_update_int_float_string
    aln = aln1
    aln.aux.update_int("AS", 42)
    aln.aux.update_float("XF", 1.5)
    aln.aux.update_string("MC", "71M")

    expect_equal 42, aln.aux.get_int("AS")
    xf = aln.aux.get_float("XF") || raise "XF should be present"
    expect_in_delta 1.5, xf, 1e-6
    expect_equal "71M", aln.aux.get_string("MC")
  end

  def test_aux_update_typed_ints
    aln = aln1
    aln.aux.update_int8("X1", -3)
    aln.aux.update_uint8("X2", 250)
    aln.aux.update_int16("X3", -1234)
    aln.aux.update_uint16("X4", 50000)
    aln.aux.update_int32("X5", -123456)
    aln.aux.update_uint32("X6", 3_000_000_000)

    expect_equal(-3, aln.aux.get_int("X1"))
    expect_equal 250, aln.aux.get_int("X2")
    expect_equal(-1234, aln.aux.get_int("X3"))
    expect_equal 50000, aln.aux.get_int("X4")
    expect_equal(-123456, aln.aux.get_int("X5"))
    expect_equal 3_000_000_000, aln.aux.get_int("X6")
  end

  def test_aux_update_char_hex_double
    aln = aln1
    aln.aux.update_char("XA", 'Q')
    aln.aux.update_hex("XH", "0A0B")
    aln.aux.update_double("XD", 3.25)

    expect_equal 'Q', aln.aux.get_char("XA")
    expect_equal "0A0B", aln.aux.get_string("XH")
    xd = aln.aux.get_float("XD") || raise "XD should be present"
    expect_in_delta 3.25, xd, 1e-12
  end

  def test_aux_update_array
    aln = aln1
    aln.aux.update_array("XB", [1, 2, 3], subtype: 'C')
    expect_equal [1_i64, 2_i64, 3_i64], aln.aux["XB"]

    aln.aux.update_array("XF", [1.25, 2.5], subtype: 'f')
    expect_equal [1.25, 2.5], aln.aux["XF"]
  end

  def test_aux_update_validation
    aln = aln1

    expect_raises(ArgumentError) { aln.aux.update_int("TOO", 1) }
    expect_raises(ArgumentError) { aln.aux.update_hex("XH", "XYZ") }
    expect_raises(ArgumentError) { aln.aux.update_hex("XH", "ABC") }
    expect_raises(ArgumentError) { aln.aux.update_int8("X1", 128) }
    expect_raises(ArgumentError) { aln.aux.update_array("XB", [1, 2], subtype: 'd') }
  end

  # TODO: def test_aux_float

  # TODO: def test_aux_flag

  # TODO: def test_aux_char

  {% for name in BAM_FLAG_METHODS %}
    def test_{{ name.id }}
      expect_equal aln1.flag.{{ name.id }}, aln1.{{ name.id }}
    end
  {% end %}

  def test_to_s
    expect_equal "poo_3290_3833_2:0:0_2:0:0_119\t133\tpoo\t3290\t0\t*\t=\t3290\t0\tGGGGCAGCTTGTTCGAAGCGTGACCCCCAAGACGTCGTCCTGACGAGCACAAACTCCCATTGAGAGTGGC\t2222222222222222222222222222222222222222222222222222222222222222222222\tMC:Z:70M\tAS:i:0\tXS:i:0",
      aln1.to_s
  end

  def test_clone
    aln = aln1
    aln2 = aln.clone
    expect_equal aln.to_s, aln2.to_s
  end
end

describe BamRecordTest do
  {% for method in BamRecordTest.methods.select { |method| method.name.stringify.starts_with?("test_") } %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BamRecordTest.new
      run_spec_case(spec_case) do
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
