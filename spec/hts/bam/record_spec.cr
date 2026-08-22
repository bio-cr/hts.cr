require "../../spec_helper"
require "../../../src/hts/bam"

class BamRecordTest
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

    (error.message).should eq("qual length must equal sequence length")
  end

  def test_qname
    (aln1.qname).should eq("poo_3290_3833_2:0:0_2:0:0_119")
  end

  def test_qname_set
    aln = aln1
    (aln.qname).should eq("poo_3290_3833_2:0:0_2:0:0_119")
    aln.qname = "test_qname_01"
    (aln.qname).should eq("test_qname_01")
    aln.qname = "poo_3290_3833_2:0:0_2:0:0_119"
    (aln.qname).should eq("poo_3290_3833_2:0:0_2:0:0_119")
  end

  def test_qname_set_accepts_254_bytes_and_rejects_longer_names
    aln = aln1
    max_qname = "q" * 254
    (aln.qname = max_qname).should eq(max_qname)
    aln.qname.should eq(max_qname)

    expect_raises(HTS::Bam::RecordError, "maximum length is 254 bytes") do
      aln.qname = "q" * 255
    end
    aln.qname.should eq(max_qname)
  end

  def test_qname_set_rejects_nul_bytes
    aln = aln1
    original = aln.qname
    expect_raises(HTS::Bam::RecordError, "QNAME must not contain a NUL byte") do
      aln.qname = "invalid\0qname"
    end
    aln.qname.should eq(original)
  end

  def test_tid
    (aln1.tid).should eq(0)
  end

  def test_tid_set
    aln = aln1
    (aln.tid).should eq(0)
    aln.tid = 1
    (aln.tid).should eq(1)
    aln.tid = 0
    (aln.tid).should eq(0)
  end

  def test_mtid
    (aln1.mtid).should eq(0)
  end

  def test_mtid_set
    aln = aln1
    (aln.mtid).should eq(0)
    aln.mtid = 1
    (aln.mtid).should eq(1)
    aln.mtid = 0
    (aln.mtid).should eq(0)
  end

  def test_pos
    (aln1.pos).should eq(3289)
  end

  def test_pos_set
    aln = aln1
    (aln.pos).should eq(3289)
    aln.pos = 3290
    (aln.pos).should eq(3290)
    aln.pos = 3289
    (aln.pos).should eq(3289)
  end

  def test_mpos
    (aln1.mpos).should eq(3289)
  end

  def test_mpos_set
    aln = aln1
    (aln.mpos).should eq(3289)
    aln.mpos = 3290
    (aln.mpos).should eq(3290)
    aln.mpos = 3289
    (aln.mpos).should eq(3289)
  end

  def test_bin
    (aln1.bin).should eq(4681)
  end

  def test_bin_set
    aln = aln1
    (aln.bin).should eq(4681)
    aln.bin = 4682
    (aln.bin).should eq(4682)
    aln.bin = 4681
    (aln.bin).should eq(4681)
  end

  def test_chrom
    (aln1.chrom).should eq("poo")
  end

  def test_chrom_invalid_tid
    aln = aln1
    aln.tid = 999
    (aln.chrom).should eq("")
  end

  def test_contig
    (aln1.contig).should eq("poo")
  end

  def test_mate_chrom
    (aln1.mate_chrom).should eq("poo")
  end

  def test_mate_chrom_invalid_tid
    aln = aln1
    aln.mtid = 999
    (aln.mate_chrom).should eq("")
  end

  def test_mate_contig
    (aln1.mate_contig).should eq("poo")
  end

  def test_endpos
    (aln1.endpos).should eq(3290)
  end

  def test_strand
    (aln1.strand).should eq("+")
  end

  def test_mates_strand
    (aln1.strand).should eq("+")
  end

  def test_insert_size
    (aln1.insert_size).should eq(0)
  end

  def test_isize
    (aln1.isize).should eq(0)
  end

  def test_insert_size_set
    aln = aln1
    (aln.insert_size).should eq(0)
    aln.insert_size = 1
    (aln.insert_size).should eq(1)
    aln.insert_size = 0
    (aln.insert_size).should eq(0)
  end

  def test_isize_set
    aln = aln1
    (aln.isize).should eq(0)
    aln.isize = 1
    (aln.isize).should eq(1)
    aln.isize = 0
    (aln.isize).should eq(0)
  end

  def test_mapq
    (aln1.mapq).should eq(0)
  end

  def test_mapq_set
    aln = aln1
    (aln.mapq).should eq(0)
    aln.mapq = 1
    (aln.mapq).should eq(1)
    aln.mapq = 0
    (aln.mapq).should eq(0)
  end

  def test_flag_value_and_has_flag
    aln = HTS::Bam::Record.new(
      minimal_header,
      "read1",
      2 | 64,
      0,
      0_i64,
      60,
      HTS::Bam::Cigar.encode("4M"),
      "ACGT",
      [30_u8, 30_u8, 30_u8, 30_u8]
    )

    (aln.flag_value).should eq(66)
    (aln.has_flag?(2)).should be_true
    (aln.has_flag?(64)).should be_true
    (aln.has_flag?(128)).should be_false
    (aln.proper_pair?).should be_true
    (aln.read1?).should be_true
    (aln.read2?).should be_false
  end

  def test_cigar
    (aln1.cigar).should be_a(HTS::Bam::Cigar)
  end

  def test_cigar_size
    aln = HTS::Bam::Record.new(
      minimal_header,
      "read1",
      0,
      0,
      0_i64,
      60,
      HTS::Bam::Cigar.encode("4M1I2D"),
      "ACGTT",
      [30_u8, 30_u8, 30_u8, 30_u8, 30_u8]
    )

    (aln.cigar_size).should eq(3)
  end

  def test_cigar_at
    aln = HTS::Bam::Record.new(
      minimal_header,
      "read1",
      0,
      0,
      0_i64,
      60,
      HTS::Bam::Cigar.encode("4M1I2D"),
      "ACGTT",
      [30_u8, 30_u8, 30_u8, 30_u8, 30_u8]
    )

    aln.cigar_at(0).should eq({'M', 4_u32})
    aln.cigar_at(2).should eq({'D', 2_u32})
    aln.cigar_at(-1).should eq({'D', 2_u32})
    aln.cigar_at(3).should be_nil
    aln.cigar_at(-4).should be_nil
  end

  def test_each_cigar
    aln = HTS::Bam::Record.new(
      minimal_header,
      "read1",
      0,
      0,
      0_i64,
      60,
      HTS::Bam::Cigar.encode("4M1I2D"),
      "ACGTT",
      [30_u8, 30_u8, 30_u8, 30_u8, 30_u8]
    )

    ops = [] of Tuple(Char, UInt32)
    returned = aln.each_cigar do |op|
      ops << op
    end

    (returned).should be(aln)
    (ops).should eq([{'M', 4_u32}, {'I', 1_u32}, {'D', 2_u32}])
    (ops).should eq(aln.cigar.to_a)
  end

  def test_each_cigar_supports_tuple_unpacking
    aln = HTS::Bam::Record.new(
      minimal_header,
      "read1",
      0,
      0,
      0_i64,
      60,
      HTS::Bam::Cigar.encode("4M1I2D"),
      "ACGTT",
      [30_u8, 30_u8, 30_u8, 30_u8, 30_u8]
    )

    ops = [] of Tuple(Char, UInt32)
    aln.each_cigar do |op, len|
      ops << {op, len}
    end

    (ops).should eq(aln.cigar.to_a)
  end

  def test_each_cigar_with_no_cigar_operations
    aln = HTS::Bam::Record.new(
      minimal_header,
      "read1",
      4,
      0,
      0_i64,
      0,
      [] of UInt32,
      "",
      [] of UInt8
    )

    yielded = false
    returned = aln.each_cigar { yielded = true }

    (returned).should be(aln)
    (yielded).should be_false
    (aln.cigar_size).should eq(0)
    (aln.cigar.to_a).should eq([] of Tuple(Char, UInt32))
  end

  def test_qlen
    (aln1.qlen).should eq(0)
  end

  def test_rlen
    (aln1.rlen).should eq(0)
  end

  def test_seq
    (aln1.seq).should eq("GGGGCAGCTTGTTCGAAGCGTGACCCCCAAGACGTCGTCCTGACGAGCACAAACTCCCATTGAGAGTGGC")
  end

  def test_sequence
    (aln1.sequence).should eq("GGGGCAGCTTGTTCGAAGCGTGACCCCCAAGACGTCGTCCTGACGAGCACAAACTCCCATTGAGAGTGGC")
  end

  def test_len
    (aln1.len).should eq(70)
  end

  def test_base
    aln = aln1
    (aln.base(0)).should eq('G')
    (aln.base(4)).should eq('C')
    (aln.base(5)).should eq('A')
    (aln.base(70)).should eq('.')
    (aln.base(-1)).should eq('C')
    (aln.base(-2)).should eq('G')
    (aln.base(-70)).should eq('G')
    (aln.base(-71)).should eq('.')
  end

  def test_each_base
    aln = aln1
    bases = [] of Char
    returned = aln.each_base do |base|
      bases << base
    end

    returned.should be(aln)
    bases.should eq(aln.seq.chars)
  end

  def test_packed_sequence_view
    aln = HTS::Bam::Record.new(
      minimal_header,
      "read1",
      0,
      0,
      0_i64,
      60,
      HTS::Bam::Cigar.encode("5M"),
      "ACGTN",
      [30_u8, 30_u8, 30_u8, 30_u8, 30_u8]
    )

    aln.packed_sequence_view.should eq(Bytes[0x12, 0x48, 0xf0])
  end

  def test_qual
    (aln1.qual).should eq([17] * 70)
  end

  def test_each_qual
    aln = aln1
    qualities = [] of UInt8
    returned = aln.each_qual do |quality|
      qualities << quality
    end

    returned.should be(aln)
    qualities.should eq(aln.qual)
  end

  def test_qual_string
    (aln1.qual_string).should eq("2" * 70)
  end

  def test_qual_string_missing_quality
    aln = HTS::Bam::Record.new(
      minimal_header,
      "read1",
      0,
      0,
      0_i64,
      60,
      HTS::Bam::Cigar.encode("4M"),
      "ACGT",
      [0xff_u8, 0xff_u8, 0xff_u8, 0xff_u8]
    )

    (aln.qual_string).should eq("*")
  end

  def test_qual_string_uses_first_quality_byte_for_missing_quality
    aln = HTS::Bam::Record.new(
      minimal_header,
      "read1",
      0,
      0,
      0_i64,
      60,
      HTS::Bam::Cigar.encode("4M"),
      "ACGT",
      [0xff_u8, 30_u8, 30_u8, 30_u8]
    )

    (aln.qual_string).should eq("*")
  end

  def test_qual_string_does_not_validate_later_missing_quality
    aln = HTS::Bam::Record.new(
      minimal_header,
      "read1",
      0,
      0,
      0_i64,
      60,
      HTS::Bam::Cigar.encode("4M"),
      "ACGT",
      [30_u8, 0xff_u8, 30_u8, 30_u8]
    )

    (aln.qual_string).should eq("?" + " " + "??")
  end

  def test_base_qual
    (aln1.base_qual(0)).should eq(17)
    (aln1.base_qual(-1)).should eq(17)
    (aln1.base_qual(69)).should eq(17)
    (aln1.base_qual(-70)).should eq(17)
  end

  def test_flag
    aln = aln1
    (aln.flag).should be_a(HTS::Bam::Flag)
    (aln.flag.value).should eq(133)
  end

  def test_flag_set
    aln = aln1
    (aln.flag.value).should eq(133)
    aln.flag = 0
    (aln.flag.value).should eq(0)
    f = HTS::Bam::Flag.new(133)
    aln.flag = f
    (aln.flag.value).should eq(133)
  end

  def test_aux_each
    aln = aln1
    aln.aux.each do |tag, value|
      case tag
      when "MC"
        (value).should eq("70M")
      when "AS"
        (value).should eq(0)
      when "XS"
        (value).should eq(0)
      end
    end
  end

  def test_aux_wrapper_is_reused
    aln = aln1
    aux = aln.aux

    aux.should be(aln.aux)
    aux.update_int("AS", 42)
    aln.aux.get_int("AS").should eq(42)
  end

  def test_aux_type_specific_methods
    aln = aln1
    (aln.aux.get_int("AS")).should eq(0)
    (aln.aux.get_int("XS")).should eq(0)
    (aln.aux.get_string("MC")).should eq("70M")
  end

  def test_aux_type_specific_methods_raise_for_type_mismatch
    aln = aln1

    expect_raises(HTS::Bam::AuxTypeError) { aln.aux.get_int("MC") }
    expect_raises(HTS::Bam::AuxTypeError) { aln.aux.get_float("MC") }
    expect_raises(HTS::Bam::AuxTypeError) { aln.aux.get_string("AS") }
    expect_raises(HTS::Bam::AuxTypeError) { aln.aux.get_char("AS") }
  end

  def test_aux_iteration_consistency
    aln = aln1
    tags1 = [] of String
    tags2 = [] of String

    2.times do
      aln.aux.each { |tag, _| tags1 << tag }
      aln.aux.each { |tag, _| tags2 << tag }
    end

    (tags2).should eq(tags1)
  end

  def test_aux_each_with_type
    aln = aln1
    seen = {} of String => {String, (Int64 | Float64 | String | Char | Array(Int64) | Array(Float64))?}

    aln.aux.each_with_type do |tag, type, value|
      seen[tag] = {type, value}
    end

    (seen["MC"]).should eq({"Z", "70M"})
    (seen["AS"]).should eq({"C", 0_i64})
    (seen["XS"]).should eq({"C", 0_i64})
  end

  def test_aux_each_with_type_for_updated_tags
    aln = aln1
    aln.aux.update_char("XA", 'Q')
    aln.aux.update_int8("X1", -3)
    aln.aux.update_array("XB", [1, 2, 3], subtype: 'C')
    aln.aux.update_array("XF", [1.25, 2.5], subtype: 'f')

    seen = {} of String => {String, (Int64 | Float64 | String | Char | Array(Int64) | Array(Float64))?}
    aln.aux.each_with_type do |tag, type, value|
      seen[tag] = {type, value}
    end

    (seen["XA"]).should eq({"A", 'Q'})
    (seen["X1"]).should eq({"c", -3_i64})
    (seen["XB"]).should eq({"B:C", [1_i64, 2_i64, 3_i64]})
    (seen["XF"]).should eq({"B:f", [1.25, 2.5]})
  end

  def test_aux_int
    aln = aln1
    (aln.aux_int("AS")).should eq(0)
    (aln.aux_int("XS")).should eq(0)
    a = [] of Int64?
    ((a << aln.aux_int("AS"))).should eq([0])
  end

  def test_aux_string
    aln = aln1
    (aln.aux_string("MC")).should eq("70M")
  end

  def test_aux_type_specific_methods_return_nil_for_missing_valid_tag
    aln = aln1

    (aln.aux_int("ZZ")).should be_nil
    (aln.aux_float("ZZ")).should be_nil
    (aln.aux_string("ZZ")).should be_nil
    (aln.aux_char("ZZ")).should be_nil
  end

  def test_aux_readers_raise_for_invalid_tag
    aln = aln1

    ["N", "LONG", "1A", "A_", "あ"].each do |tag|
      expect_raises(ArgumentError) { aln.aux.get_int(tag) }
      expect_raises(ArgumentError) { aln.aux.get_string(tag) }
    end
  end

  def test_aux_to_s
    aln = aln1
    expected = "MC:Z:70M\tAS:i:0\tXS:i:0"
    (aln.aux.to_s).should eq(expected)
  end

  def test_aux_update_int_float_string
    aln = aln1
    aln.aux.update_int("AS", 42)
    aln.aux.update_float("XF", 1.5)
    aln.aux.update_string("MC", "71M")

    (aln.aux.get_int("AS")).should eq(42)
    xf = aln.aux.get_float("XF") || raise "XF should be present"
    ((xf) - (1.5)).abs.should be <= 1e-6
    (aln.aux.get_string("MC")).should eq("71M")
  end

  def test_aux_update_typed_ints
    aln = aln1
    aln.aux.update_int8("X1", -3)
    aln.aux.update_uint8("X2", 250)
    aln.aux.update_int16("X3", -1234)
    aln.aux.update_uint16("X4", 50000)
    aln.aux.update_int32("X5", -123456)
    aln.aux.update_uint32("X6", 3_000_000_000)

    (aln.aux.get_int("X1")).should eq(-3)
    (aln.aux.get_int("X2")).should eq(250)
    (aln.aux.get_int("X3")).should eq(-1234)
    (aln.aux.get_int("X4")).should eq(50000)
    (aln.aux.get_int("X5")).should eq(-123456)
    (aln.aux.get_int("X6")).should eq(3_000_000_000)
  end

  def test_aux_update_char_hex_double
    aln = aln1
    aln.aux.update_char("XA", 'Q')
    aln.aux.update_hex("XH", "0A0B")
    aln.aux.update_double("XD", 3.25)

    (aln.aux.get_char("XA")).should eq('Q')
    (aln.aux.get_string("XH")).should eq("0A0B")
    xd = aln.aux.get_float("XD") || raise "XD should be present"
    ((xd) - (3.25)).abs.should be <= 1e-12
  end

  def test_aux_update_array
    aln = aln1
    aln.aux.update_array("XB", [1, 2, 3], subtype: 'C')
    (aln.aux.get_int_array("XB")).should eq([1_i64, 2_i64, 3_i64])

    aln.aux.update_array("XF", [1.25, 2.5], subtype: 'f')
    (aln.aux.get_float_array("XF")).should eq([1.25, 2.5])
  end

  def test_aux_array_view_decodes_all_subtypes
    aln = aln1
    aln.aux.update_array("A1", [-128, 127], subtype: 'c')
    aln.aux.update_array("A2", [0, 255], subtype: 'C')
    aln.aux.update_array("A3", [-32_768, 32_767], subtype: 's')
    aln.aux.update_array("A4", [0, 65_535], subtype: 'S')
    aln.aux.update_array("A5", [Int32::MIN, 0x01020304], subtype: 'i')
    aln.aux.update_array("A6", [0_i64, UInt32::MAX.to_i64], subtype: 'I')
    aln.aux.update_array("A7", [-1.25, 2.5], subtype: 'f')
    aln.aux.update_array("A8", [] of Int32, subtype: 'i')

    {
      {"A1", 'c', [-128_i64, 127_i64]},
      {"A2", 'C', [0_i64, 255_i64]},
      {"A3", 's', [-32_768_i64, 32_767_i64]},
      {"A4", 'S', [0_i64, 65_535_i64]},
      {"A5", 'i', [Int32::MIN.to_i64, 0x01020304_i64]},
      {"A6", 'I', [0_i64, UInt32::MAX.to_i64]},
    }.each do |tag, expected_subtype, expected_values|
      yielded = aln.aux.each_array(tag) do |subtype, view|
        subtype.should eq(expected_subtype)
        view.integer?.should be_true
        values = [] of Int64
        view.each_int { |value| values << value }
        values.should eq(expected_values)
      end
      yielded.should be_true
    end

    aln.aux.each_array("A7") do |subtype, view|
      subtype.should eq('f')
      view.float?.should be_true
      values = [] of Float64
      view.each_float { |value| values << value }
      values.zip([-1.25, 2.5]).each do |actual, expected|
        (actual - expected).abs.should be <= 1e-6
      end
    end.should be_true

    aln.aux.each_array("A8") do |_subtype, view|
      view.size.should eq(0)
    end.should be_true
    aln.aux.each_array("ZZ") { |_subtype, _view| fail "missing tag yielded" }.should be_false
  end

  def test_aux_array_view_exposes_only_matching_aligned_slices
    aln = aln1
    aln.aux.update_array("XB", [1, 2, 3], subtype: 'C')

    aln.aux.each_array("XB") do |_subtype, view|
      view.as_slice(UInt8).should eq(Slice[1_u8, 2_u8, 3_u8])
      view.as_slice(Int8).should be_nil
      view.as_slice(UInt16).should be_nil
    end.should be_true
  end

  def test_aux_array_view_handles_aligned_and_unaligned_little_endian_values
    aln = aln1
    4.times do |index|
      aln.aux.update_array("B#{index}", [0x01020304], subtype: 'i')
      aln.aux.update_string("P#{index}", "x") unless index == 3
    end

    aligned = 0
    unaligned = 0
    4.times do |index|
      aln.aux.each_array("B#{index}") do |_subtype, view|
        view.int_at(0).should eq(0x01020304)
        if values = view.as_slice(Int32)
          values[0].should eq(0x01020304)
          aligned += 1
        else
          unaligned += 1
        end
      end.should be_true
    end
    aligned.should eq(1)
    unaligned.should eq(3)
  end

  def test_aux_array_readers_raise_for_type_mismatch
    aln = aln1
    aln.aux.update_array("XB", [1, 2, 3], subtype: 'C')
    aln.aux.update_array("XF", [1.25, 2.5], subtype: 'f')

    expect_raises(HTS::Bam::AuxTypeError) { aln.aux.get_float_array("XB") }
    expect_raises(HTS::Bam::AuxTypeError) { aln.aux.get_int_array("XF") }
    expect_raises(HTS::Bam::AuxTypeError) { aln.aux.get_int_array("AS") }
  end

  def test_aux_update_validation
    aln = aln1

    expect_raises(ArgumentError) { aln.aux.update_int("TOO", 1) }
    expect_raises(ArgumentError) { aln.aux.update_int("1A", 1) }
    expect_raises(ArgumentError) { aln.aux.update_int("A_", 1) }
    expect_raises(ArgumentError) { aln.aux.update_int("あ", 1) }
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
      (aln1.{{ name.id }}).should eq(aln1.flag.{{ name.id }})
    end
  {% end %}

  def test_to_s
    (aln1.to_s).should eq("poo_3290_3833_2:0:0_2:0:0_119\t133\tpoo\t3290\t0\t*\t=\t3290\t0\tGGGGCAGCTTGTTCGAAGCGTGACCCCCAAGACGTCGTCCTGACGAGCACAAACTCCCATTGAGAGTGGC\t2222222222222222222222222222222222222222222222222222222222222222222222\tMC:Z:70M\tAS:i:0\tXS:i:0")
  end

  def test_clone
    aln = aln1
    aln2 = aln.clone
    (aln2.to_s).should eq(aln.to_s)
  end
end

describe BamRecordTest do
  {% for method in BamRecordTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BamRecordTest.new
      begin
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
