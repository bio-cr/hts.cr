require "minitest/autorun"
require "../../../src/hts/bcf"

class BcfRecordTest < Minitest::Test
  def test_bcf_path
    File.expand_path("../../fixtures/test.bcf", __DIR__)
  end

  def var1 : HTS::Bcf::Record
    bcf = HTS::Bcf.new(test_bcf_path)
    v = bcf.first
    bcf.close
    v
  end

  def test_pos
    assert_equal 2126, var1.pos
  end

  def test_start
    assert_equal 2125, var1.start
  end

  def test_stop
    assert_equal 2126, var1.stop
  end

  def test_id
    assert_equal ".", var1.id
  end

  def test_filter
    assert_equal "PASS", var1.filter
  end

  def test_qual
    assert_equal 142.41574_f32, var1.qual
  end

  def test_ref
    assert_equal "T", var1.ref
  end

  def test_alt
    assert_equal ["C"], var1.alt
  end

  def test_alleles
    assert_equal ["T", "C"], var1.alleles
  end

  def test_info
    assert_instance_of HTS::Bcf::Info, var1.info
  end

  def test_format
    assert_instance_of HTS::Bcf::Format, var1.format
  end

  def test_to_s
    assert_equal "poo\t2126\t.\tT\tC\t142.416\t.\tDP=31;VDB=0.673439;SGB=-0.69311;MQSBZ=0;FS=0;MQ0F=0;AC=2;AN=2;DP4=0,0,14,17;MQ=60\tGT:PL\t1/1:172,93,0\n",
      var1.to_s
  end
end
