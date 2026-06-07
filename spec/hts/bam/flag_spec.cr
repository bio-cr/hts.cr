require "../../spec_helper"
require "../../../src/hts/bam"

class BamFlagTest
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
    (flag.value).should eq(4095)
    (flag_zero.value).should eq(0)
  end

  {% for name in BAM_FLAG_METHODS %}
    def test_{{ name.id }}
      (flag.{{ name.id }}).should eq(true)
      (flag_zero.{{ name.id }}).should eq(false)
    end
  {% end %}

  def test_bitwise_and
    ((flag & 1024).value).should eq(1024)
    ((flag_zero & 1024).value).should eq(0)
  end

  def test_bitwise_or
    ((flag | 1024).value).should eq(4095)
    ((flag_zero | 1024).value).should eq(1024)
  end

  def test_bitwise_xor
    ((flag ^ 1024).value).should eq(3071)
    ((flag_zero ^ 1024).value).should eq(1024)
  end

  def test_bitwise_not
    ((~flag).value).should eq(61440)
    ((~flag_zero).value).should eq(65535)
  end

  def test_bitwise_shift_left
    ((flag << 1).value).should eq(8190)
    ((flag_zero << 1).value).should eq(0)
  end

  def test_bitwise_shift_right
    ((flag >> 1).value).should eq(2047)
    ((flag_zero >> 1).value).should eq(0)
  end

  def test_to_i
    (flag.to_i).should eq(4095)
    (flag_zero.to_i).should eq(0)
  end

  def test_to_s
    (flag.to_s).should eq("PAIRED,PROPER_PAIR,UNMAP,MUNMAP,REVERSE,MREVERSE,READ1,READ2,SECONDARY,QCFAIL,DUP,SUPPLEMENTARY")
    (flag_zero.to_s).should eq("")
  end
end

describe BamFlagTest do
  {% for method in BamFlagTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BamFlagTest.new
        spec_case.setup
      begin
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
