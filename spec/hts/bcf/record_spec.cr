require "../../spec_helper"
require "../../../src/hts/bcf"

class BcfRecordTest < HTSSpecCase
  def test_bcf_path
    File.expand_path("../../fixtures/test.bcf", __DIR__)
  end

  def var1 : HTS::Bcf::Record
    bcf = HTS::Bcf.new(test_bcf_path)
    v = bcf.first
    bcf.close
    v
  end

  def test_rid
    expect_equal 0, var1.rid
  end

  def test_rid_set
    var = var1.clone
    expect_equal 0, var.rid
    var.rid = 1
    expect_equal 1, var.rid
    var.rid = 0
    expect_equal 0, var.rid
  end

  def test_chrom
    expect_equal "poo", var1.chrom
  end

  def test_pos
    expect_equal 2125, var1.pos
  end

  def test_pos_set
    var = var1.clone
    expect_equal 2125, var.pos
    var.pos = 2126
    expect_equal 2126, var.pos
    var.pos = 2125
    expect_equal 2125, var.pos
  end

  def test_endpos
    expect_equal 2126, var1.endpos
  end

  def test_id
    expect_equal ".", var1.id
  end

  def test_id_set
    var = var1.clone
    expect_equal ".", var.id
    var.id = "asterite"
    expect_equal "asterite", var.id
    var.id = "."
    expect_equal ".", var.id
  end

  def test_clear_id
    var = var1.clone
    expect_equal ".", var.id
    var.id = "Ary"
    expect_equal "Ary", var.id
    var.clear_id
    expect_equal ".", var.id
  end

  def test_filter
    expect_equal "PASS", var1.filter
  end

  def test_qual
    expect_equal 142.41574_f32, var1.qual
  end

  def test_qual_set
    var = var1.clone
    expect_equal 142.41574_f32, var.qual
    var.qual = 100
    expect_equal 100, var.qual
    var.qual = 142.41574_f32
    expect_equal 142.41574_f32, var.qual
  end

  def test_ref
    expect_equal "T", var1.ref
  end

  def test_alt
    expect_equal ["C"], var1.alt
  end

  def test_alleles
    expect_equal ["T", "C"], var1.alleles
  end

  def test_info
    expect_instance_of HTS::Bcf::Info, var1.info
  end

  def test_format
    expect_instance_of HTS::Bcf::Format, var1.format
  end

  def test_to_s
    expect_equal "poo\t2126\t.\tT\tC\t142.416\t.\tDP=31;VDB=0.673439;SGB=-0.69311;MQSBZ=0;FS=0;MQ0F=0;AC=2;AN=2;DP4=0,0,14,17;MQ=60\tGT:PL\t1/1:172,93,0\n",
      var1.to_s
  end

  def test_clone
    var = var1
    var2 = var.clone
    expect_equal var.to_s, var2.to_s
  end
end

describe BcfRecordTest do
  {% for method in BcfRecordTest.methods.select { |method| method.name.stringify.starts_with?("test_") } %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BcfRecordTest.new
      run_spec_case(spec_case) do
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
