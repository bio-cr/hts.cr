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

  def test_initialize
    assert_instance_of HTS::Bam::Cigar, cigar9
  end

  def test_each
    assert_equal [{'M', 28}, {'I', 1}, {'M', 11}], cigar9.to_a
  end

  def test_to_s
    assert_equal "28M1I11M", cigar9.to_s
  end

  # --- Integrated encode/decode tests ---
  def test_encode_from_ops
    ops = [{'M', 28_u32}, {'I', 1_u32}, {'M', 11_u32}]
    words = HTS::Bam::Cigar.encode(ops)
    expected = [
      (28_u32 << 4) | 0_u32, # M
      (1_u32 << 4) | 1_u32,  # I
      (11_u32 << 4) | 0_u32, # M
    ]
    assert_equal expected, words
  end

  def test_encode_from_string
    words = HTS::Bam::Cigar.encode("28M1I11M")
    expected = [
      (28_u32 << 4) | 0_u32, # M
      (1_u32 << 4) | 1_u32,  # I
      (11_u32 << 4) | 0_u32, # M
    ]
    assert_equal expected, words
  end

  def test_decode_each_and_to_s_roundtrip
    words = [
      (1_u32 << 4) | 0_u32,  # 1M
      (2_u32 << 4) | 1_u32,  # 2I
      (3_u32 << 4) | 2_u32,  # 3D
      (4_u32 << 4) | 3_u32,  # 4N
      (5_u32 << 4) | 4_u32,  # 5S
      (6_u32 << 4) | 5_u32,  # 6H
      (7_u32 << 4) | 6_u32,  # 7P
      (8_u32 << 4) | 7_u32,  # 8=
      (9_u32 << 4) | 8_u32,  # 9X
      (10_u32 << 4) | 9_u32, # 10B
    ]
    ptr = words.to_unsafe
    cig = HTS::Bam::Cigar.new(ptr, words.size.to_u32)

    assert_equal [
      {'M', 1_u32}, {'I', 2_u32}, {'D', 3_u32}, {'N', 4_u32}, {'S', 5_u32},
      {'H', 6_u32}, {'P', 7_u32}, {'=', 8_u32}, {'X', 9_u32}, {'B', 10_u32},
    ], cig.to_a

    assert_equal "1M2I3D4N5S6H7P8=9X10B", cig.to_s
  end

  def test_initialize_from_string
    cig = HTS::Bam::Cigar.new("28M1I11M")
    assert_equal [{'M', 28_u32}, {'I', 1_u32}, {'M', 11_u32}], cig.to_a
    assert_equal "28M1I11M", cig.to_s
  end

  def test_initialize_from_ops
    cig = HTS::Bam::Cigar.new([{'M', 2_u32}, {'D', 3_u32}, {'S', 4_u32}])
    assert_equal [{'M', 2_u32}, {'D', 3_u32}, {'S', 4_u32}], cig.to_a
    assert_equal "2M3D4S", cig.to_s
  end

  def test_encode_raises_on_missing_length_before_op
    assert_raises(ArgumentError) do
      HTS::Bam::Cigar.encode("M")
    end
  end

  def test_encode_raises_on_trailing_length
    assert_raises(ArgumentError) do
      HTS::Bam::Cigar.encode("10")
    end
  end
end
