require "minitest/autorun"
require "../../../src/hts/bam"

class BamFlagTest < Minitest::Test
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
    assert_equal(4095, flag.value)
    assert_equal(0, flag_zero.value)
  end

  macro define_flag_test_methods(names)
    {% for name in names %}
      def test_{{name.id}}
        assert_equal true, flag.{{name.id}}
        assert_equal false, flag_zero.{{name.id}}
      end
    {% end %}
  end

  define_flag_test_methods %w[
    paired?
    proper_pair?
    unmapped?
    mate_unmapped?
    reverse?
    mate_reverse?
    read1?
    read2?
    secondary?
    qcfail?
    dup?
    supplementary?
  ]

  def test_to_s
    assert_equal "PAIRED,PROPER_PAIR,UNMAP,MUNMAP,REVERSE,MREVERSE,READ1,READ2,SECONDARY,QCFAIL,DUP,SUPPLEMENTARY",
      flag.to_s
    assert_equal "", flag_zero.to_s
  end
end
