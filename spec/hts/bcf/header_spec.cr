require "../../spec_helper"
require "../../../src/hts/bcf"

# require "digest/md5"

class BcfHeaderTest
  include TestBcfMultisampleHelper

  @bcf : HTS::Bcf?

  def teardown
    @bcf.try &.close
  end

  def test_bcf_path
    File.expand_path("../../fixtures/test.bcf", __DIR__)
  end

  def bcf
    @bcf ||= with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogError) { HTS::Bcf.new(test_bcf_path) }
  end

  def hdr
    bcf.header
  end

  def test_initialize
    (HTS::Bcf::Header.new).should be_a(HTS::Bcf::Header)
  end

  def test_version
    (hdr.version).should eq("VCFv4.2")
  end

  def test_version_setter
    hdr2 = hdr.clone
    hdr2.version = "VCFv9.9"
    (hdr2.version).should eq("VCFv9.9")
  end

  def test_nsamples
    (hdr.nsamples).should eq(1)
  end

  def test_target_count
    (hdr.target_count).should eq(1)
  end

  def test_target_name
    (hdr.target_name(0)).should eq("poo")
  end

  def test_target_names
    (hdr.target_names).should eq(["poo"])
  end

  def test_get_tid
    (hdr.get_tid("poo")).should eq(0)
  end

  def test_samples
    (hdr.samples).should eq(["poo.sort.bam"])
  end

  def test_subset_returns_new_header
    with_temp_multisample_bcf do |path|
      source = HTS::Bcf.new(path)
      subset = source.header.subset(["B"])

      (source.header.samples).should eq(["A", "B"])
      (subset.samples).should eq(["B"])
      (subset.nsamples).should eq(1)
    ensure
      source.try &.close
    end
  end

  def test_subset_rejects_unknown_samples
    with_temp_multisample_bcf do |path|
      source = HTS::Bcf.new(path)

      error = expect_raises(HTS::Bcf::UnknownSampleError) do
        source.header.subset(["missing"])
      end

      (error.message.to_s).should contain("missing")
    ensure
      source.try &.close
    end
  end

  def test_subset_rejects_duplicates
    with_temp_multisample_bcf do |path|
      source = HTS::Bcf.new(path)

      error = expect_raises(HTS::Bcf::SubsetError) do
        source.header.subset(["A", "A"])
      end

      (error.message.to_s).should contain("Duplicate sample names")
    ensure
      source.try &.close
    end
  end

  def test_sync
    hdr2 = hdr.clone
    hdr2.add_sample("kojix1", sync: false)
    hdr2.add_sample("kojix2", sync: false)
    hdr2.add_sample("kojix3", sync: false)
    (hdr2.nsamples).should eq(1)
    (hdr2.samples).should eq(["poo.sort.bam"])
    hdr2.sync
    (hdr2.nsamples).should eq(4)
    (hdr2.samples).should eq(["poo.sort.bam", "kojix1", "kojix2", "kojix3"])
  end

  def test_append_delete
    h = HTS::Bcf::Header.new
    h.append("##FILTER=<ID=Nessie,Description=\"Nessie is a creature in Scottish folklore that is said to inhabit Loch Ness in the Scottish Highlands.\">")
    h.delete("FILTER", "Nessie")
  end

  def test_to_s
    # md5 = Digest::MD5.hexdigest(bcf.header.to_s)
    # exp = "ca7d2c7ac2a51e4f2b2b88004615e98b"
    # (md5).should eq(exp)
  end

  def test_clone
    (hdr.clone).should be_a(HTS::Bcf::Header)
  end

  def test_edit_batches_sync
    hdr2 = hdr.clone

    hdr2.edit do |header|
      header.add_sample("kojix4")
      header.add_sample("kojix5")
      header.add_filter("BatchFilter", description: "batch-added")
    end

    (hdr2.samples).should eq(["poo.sort.bam", "kojix4", "kojix5"])
    (hdr2.to_s.includes?("##FILTER=<ID=BatchFilter,Description=\"batch-added\">")).should be_true
  end

  def test_add_and_remove_contig
    h = HTS::Bcf::Header.new
    h.add_contig("chr1", length: 1000, assembly: "GRCh38")

    (h.target_names).should eq(["chr1"])
    (h.to_s.includes?("##contig=<ID=chr1,length=1000,assembly=GRCh38>")).should be_true

    (h.remove_contig("chr1")).should be_true
    (h.target_names).should eq([] of String)
  end

  def test_add_update_remove_info_and_format
    h = HTS::Bcf::Header.new
    h.add_info("DP", number: 1, type: :int, description: "Total depth")
    h.add_format("GT", number: 1, type: :string, description: "Genotype")

    (h.to_s.includes?("##INFO=<ID=DP,Number=1,Type=Integer,Description=\"Total depth\">")).should be_true
    (h.to_s.includes?("##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">")).should be_true

    h.update_info("DP", number: 1, type: :int, description: "Read depth")
    h.update_format("GT", number: 1, type: :string, description: "GT field")
    (h.to_s.includes?("##INFO=<ID=DP,Number=1,Type=Integer,Description=\"Read depth\">")).should be_true
    (h.to_s.includes?("##FORMAT=<ID=GT,Number=1,Type=String,Description=\"GT field\">")).should be_true

    (h.remove_info("DP")).should be_true
    (h.remove_format("GT")).should be_true
    (h.to_s.includes?("##INFO=<ID=DP")).should be_false
    (h.to_s.includes?("##FORMAT=<ID=GT")).should be_false
  end

  def test_schema_cache_is_scoped_and_invalidated
    h = HTS::Bcf::Header.new
    (h.info_type("FIELD")).should be_nil
    (h.format_type("FIELD")).should be_nil

    h.add_info("FIELD", number: 1, type: :int, description: "Info field")
    h.add_format("FIELD", number: :variable, type: :float, description: "Format field")
    h.add_filter("FILTERED", description: "Filter field")
    2.times do
      (h.info_type("FIELD")).should eq(:int)
      (h.format_type("FIELD")).should eq(:float)
      (h.info_id("FIELD")).should_not be_nil
      (h.format_id("FIELD")).should eq(h.info_id("FIELD"))
      (h.filter_id("FILTERED")).should_not be_nil
    end
    (h.info_id("FILTERED")).should be_nil
    (h.format_id("FILTERED")).should be_nil
    (h.filter_id("FIELD")).should be_nil

    h.update_info("FIELD", number: :a, type: :string, description: "Updated info field")
    (h.info_type("FIELD")).should eq(:string)
    (h.format_type("FIELD")).should eq(:float)

    h.remove_info("FIELD")
    (h.info_type("FIELD")).should be_nil
    (h.info_id("FIELD")).should be_nil
    (h.format_type("FIELD")).should eq(:float)

    h.remove_filter("FILTERED")
    (h.filter_id("FILTERED")).should be_nil
  end

  def test_add_meta_and_filter
    h = HTS::Bcf::Header.new
    h.add_meta("source", "myCaller")
    h.add_filter("LowQual", description: "Low quality")

    (h.to_s.includes?("##source=myCaller")).should be_true
    (h.to_s.includes?("##FILTER=<ID=LowQual,Description=\"Low quality\">")).should be_true

    (h.remove_filter("LowQual")).should be_true
    (h.to_s.includes?("LowQual")).should be_false
  end
end

describe BcfHeaderTest do
  {% for method in BcfHeaderTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BcfHeaderTest.new
      begin
        spec_case.{{ method.name.id }}
      ensure
        spec_case.teardown
      end
    end
  {% end %}
end
