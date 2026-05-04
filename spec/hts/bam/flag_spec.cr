require "../../spec_helper"
require "../../../src/hts/bam"

class BamFlagTest < HTSSpecCase
  def setup
    @flag = HTS::Bam::Flag.new(4095)
    @flag_zero = HTS::Bam::Flag.new(0)
  end

  def flag
    @flag ||= HTS::Bam::Flag.new(4095)
  end

  def flag_zero
    @flag_zero ||= HTS::Bam::Flag.new(0)
  end

  # BAM_FPAIRED        =    1
  # BAM_FPROPER_PAIR   =    2
  # BAM_FUNMAP         =    4
  # BAM_FMUNMAP        =    8
  # BAM_FREVERSE       =   16
  # BAM_FMREVERSE      =   32
  # BAM_FREAD1         =   64
  # BAM_FREAD2         =  128
  # BAM_FSECONDARY     =  256
  # BAM_FQCFAIL        =  512
  # BAM_FDUP           = 1024
  # BAM_FSUPPLEMENTARY = 2048

  def test_value
    expect_equal(4095, flag.value)
    expect_equal(0, flag_zero.value)
  end

  {% for name in BAM_FLAG_METHODS %}
    def test_{{name.id}}
      expect_equal true, flag.{{name.id}}
      expect_equal false, flag_zero.{{name.id}}
    end
  {% end %}

  def test_bitwise_and
    expect_equal 1024, (flag & 1024).value
    expect_equal 0, (flag_zero & 1024).value
  end

  def test_bitwise_or
    expect_equal 4095, (flag | 1024).value
    expect_equal 1024, (flag_zero | 1024).value
  end

  def test_bitwise_xor
    expect_equal 3071, (flag ^ 1024).value
    expect_equal 1024, (flag_zero ^ 1024).value
  end

  def test_bitwise_not
    expect_equal 61440, (~flag).value
    expect_equal 65535, (~flag_zero).value
  end

  def test_bitwise_shift_left
    expect_equal 8190, (flag << 1).value
    expect_equal 0, (flag_zero << 1).value
  end

  def test_bitwise_shift_right
    expect_equal 2047, (flag >> 1).value
    expect_equal 0, (flag_zero >> 1).value
  end

  def test_to_i
    expect_equal 4095, flag.to_i
    expect_equal 0, flag_zero.to_i
  end

  def test_to_s
    expect_equal "PAIRED,PROPER_PAIR,UNMAP,MUNMAP,REVERSE,MREVERSE,READ1,READ2,SECONDARY,QCFAIL,DUP,SUPPLEMENTARY",
      flag.to_s
    expect_equal "", flag_zero.to_s
  end
end

describe BamFlagTest do
  {% for method in BamFlagTest.methods.select { |method| method.name.stringify.starts_with?("test_") } %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BamFlagTest.new
      run_spec_case(spec_case) do
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
