require "../../spec_helper"
require "../../../src/hts/bcf"

class BcfRecordTest
  def test_bcf_path
    File.expand_path("../../fixtures/test.bcf", __DIR__)
  end

  def var1 : HTS::Bcf::Record
    bcf = with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogError) { HTS::Bcf.new(test_bcf_path) }
    v = bcf.first
    bcf.close
    v
  end

  def test_rid
    (var1.rid).should eq(0)
  end

  def test_rid_set
    var = var1.clone
    (var.rid).should eq(0)
    var.rid = 1
    (var.rid).should eq(1)
    var.rid = 0
    (var.rid).should eq(0)
  end

  def test_chrom
    (var1.chrom).should eq("poo")
  end

  def test_pos
    (var1.pos).should eq(2125)
  end

  def test_pos_set
    var = var1.clone
    (var.pos).should eq(2125)
    var.pos = 2126
    (var.pos).should eq(2126)
    var.pos = 2125
    (var.pos).should eq(2125)
  end

  def test_endpos
    (var1.endpos).should eq(2126)
  end

  def test_id
    (var1.id).should eq(".")
  end

  def test_id_set
    var = var1.clone
    (var.id).should eq(".")
    var.id = "asterite"
    (var.id).should eq("asterite")
    var.id = "."
    (var.id).should eq(".")
  end

  def test_clear_id
    var = var1.clone
    (var.id).should eq(".")
    var.id = "Ary"
    (var.id).should eq("Ary")
    var.clear_id
    (var.id).should eq(".")
  end

  def test_filter
    (var1.filter).should eq(["PASS"])
  end

  def test_filters
    record = var1
    (record.filters).should eq(["PASS"])
    (record.filter_count).should eq(0)
    yielded = false
    record.each_filter_id { yielded = true }
    (yielded).should be_false
  end

  def test_numeric_filter_access
    header = HTS::Bcf::Header.new
    header.version = "VCFv4.3"
    header.add_contig("1", length: 100)
    header.add_filter("LowQual", description: "Low quality")
    header.add_filter("StrandBias", description: "Strand bias")

    record = HTS::Bcf::Record.new(header)
    record.rid = header.name2id("1")
    low_qual = header.filter_id("LowQual") || raise "LowQual should be defined"
    strand_bias = header.filter_id("StrandBias") || raise "StrandBias should be defined"
    filter_ids = [low_qual, strand_bias]
    rc = HTS::LibHTS.bcf_update_filter(header, record, filter_ids.to_unsafe, filter_ids.size)
    raise "bcf_update_filter failed (rc=#{rc})" if rc < 0

    (record.filter_count).should eq(2)
    (record.filter_id_at(0)).should eq(low_qual)
    (record.filter_id_at(1)).should eq(strand_bias)
    iterated_ids = [] of Int32
    record.each_filter_id { |id| iterated_ids << id }
    (iterated_ids).should eq(filter_ids)
    (record.filters).should eq(["LowQual", "StrandBias"])
    expect_raises(IndexError, "filter index -1 out of range 0...2") { record.filter_id_at(-1) }
    expect_raises(IndexError, "filter index 2 out of range 0...2") { record.filter_id_at(2) }
  end

  def test_qual
    (var1.qual).should eq(142.41574_f32)
  end

  def test_qual_set
    var = var1.clone
    (var.qual).should eq(142.41574_f32)
    var.qual = 100
    (var.qual).should eq(100)
    var.qual = 142.41574_f32
    (var.qual).should eq(142.41574_f32)
  end

  def test_ref
    (var1.ref).should eq("T")
  end

  def test_alt
    (var1.alt).should eq(["C"])
  end

  def test_alleles
    (var1.alleles).should eq(["T", "C"])
  end

  def test_each_allele_view
    record = var1
    alleles = [] of String
    allele_index = 0

    record.each_allele_view do |allele|
      pointer = record.to_unsafe.value.d.allele[allele_index]
      (allele.to_unsafe).should eq(pointer.as(UInt8*))
      alleles << String.new(allele)
      allele_index += 1
    end

    (alleles).should eq(["T", "C"])
    (allele_index).should eq(record.allele_count)
  end

  def test_allele_count
    (var1.allele_count).should eq(2)
  end

  def test_info
    (var1.info).should be_a(HTS::Bcf::Info)
  end

  def test_format
    (var1.format).should be_a(HTS::Bcf::Format)
  end

  def test_to_s
    (var1.to_s).should eq("poo\t2126\t.\tT\tC\t142.416\t.\tDP=31;VDB=0.673439;SGB=-0.69311;MQSBZ=0;FS=0;MQ0F=0;AC=2;AN=2;DP4=0,0,14,17;MQ=60\tGT:PL\t1/1:172,93,0\n")
  end

  def test_clone
    var = var1
    var2 = var.clone
    (var2.to_s).should eq(var.to_s)
  end
end

describe BcfRecordTest do
  {% for method in BcfRecordTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BcfRecordTest.new
      begin
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
