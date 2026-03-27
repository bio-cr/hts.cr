require "minitest/autorun"
require "../../../src/hts/bcf"

# require "digest/md5"

class BcfHeaderTest < Minitest::Test
  def teardown
    @bcf.try &.close
  end

  def test_bcf_path
    File.expand_path("../../fixtures/test.bcf", __DIR__)
  end

  def bcf
    @bcf ||= HTS::Bcf.new(test_bcf_path)
  end

  def hdr
    bcf.header
  end

  def test_initialize
    assert_instance_of HTS::Bcf::Header, HTS::Bcf::Header.new
  end

  def test_get_version
    assert_equal "VCFv4.2", hdr.get_version
  end

  def test_set_version
    hdr2 = hdr.clone
    hdr2.set_version("VCFv9.9")
    assert_equal "VCFv9.9", hdr2.get_version
  end

  def test_nsamples
    assert_equal 1, hdr.nsamples
  end

  def test_target_count
    assert_equal 1, hdr.target_count
  end

  def test_target_name
    assert_equal "poo", hdr.target_name(0)
  end

  def test_target_names
    assert_equal ["poo"], hdr.target_names
  end

  def test_get_tid
    assert_equal 0, hdr.get_tid("poo")
  end

  def test_samples
    assert_equal ["poo.sort.bam"], hdr.samples
  end

  def test_subset_returns_new_header
    source = HTS::Bcf.new(File.expand_path("../../../../htslib/test/tabix/vcf_file.bcf", __DIR__))
    subset = source.header.subset(["B"])

    assert_equal ["A", "B"], source.header.samples
    assert_equal ["B"], subset.samples
    assert_equal 1, subset.nsamples
  ensure
    source.try &.close
  end

  def test_subset_rejects_unknown_samples
    source = HTS::Bcf.new(File.expand_path("../../../../htslib/test/tabix/vcf_file.bcf", __DIR__))

    error = assert_raises(HTS::Bcf::UnknownSampleError) do
      source.header.subset(["missing"])
    end

    assert_includes error.message, "missing"
  ensure
    source.try &.close
  end

  def test_subset_rejects_duplicates
    source = HTS::Bcf.new(File.expand_path("../../../../htslib/test/tabix/vcf_file.bcf", __DIR__))

    error = assert_raises(HTS::Bcf::SubsetError) do
      source.header.subset(["A", "A"])
    end

    assert_includes error.message, "Duplicate sample names"
  ensure
    source.try &.close
  end

  def test_sync
    hdr2 = hdr.clone
    hdr2.add_sample("kojix1", sync: false)
    hdr2.add_sample("kojix2", sync: false)
    hdr2.add_sample("kojix3", sync: false)
    assert_equal 1, hdr2.nsamples
    assert_equal ["poo.sort.bam"], hdr2.samples
    hdr2.sync
    assert_equal 4, hdr2.nsamples
    assert_equal ["poo.sort.bam", "kojix1", "kojix2", "kojix3"], hdr2.samples
  end

  def test_append_delete
    h = HTS::Bcf::Header.new
    h.append("##FILTER=<ID=Nessie,Description=\"Nessie is a creature in Scottish folklore that is said to inhabit Loch Ness in the Scottish Highlands.\">")
    h.delete("FILTER", "Nessie")
  end

  def test_to_s
    # md5 = Digest::MD5.hexdigest(bcf.header.to_s)
    # exp = "ca7d2c7ac2a51e4f2b2b88004615e98b"
    # assert_equal exp, md5
  end

  def test_clone
    assert_instance_of HTS::Bcf::Header, hdr.clone
  end

  def test_edit_batches_sync
    hdr2 = hdr.clone

    hdr2.edit do |header|
      header.add_sample("kojix4")
      header.add_sample("kojix5")
      header.add_filter("BatchFilter", description: "batch-added")
    end

    assert_equal ["poo.sort.bam", "kojix4", "kojix5"], hdr2.samples
    assert hdr2.to_s.includes?("##FILTER=<ID=BatchFilter,Description=\"batch-added\">")
  end

  def test_add_and_remove_contig
    h = HTS::Bcf::Header.new
    h.add_contig("chr1", length: 1000, assembly: "GRCh38")

    assert_equal ["chr1"], h.target_names
    assert h.to_s.includes?("##contig=<ID=chr1,length=1000,assembly=GRCh38>")

    assert_equal true, h.remove_contig("chr1")
    assert_equal [] of String, h.target_names
  end

  def test_add_update_remove_info_and_format
    h = HTS::Bcf::Header.new
    h.add_info("DP", number: 1, type: :int, description: "Total depth")
    h.add_format("GT", number: 1, type: :string, description: "Genotype")

    assert h.to_s.includes?("##INFO=<ID=DP,Number=1,Type=Integer,Description=\"Total depth\">")
    assert h.to_s.includes?("##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">")

    h.update_info("DP", number: 1, type: :int, description: "Read depth")
    h.update_format("GT", number: 1, type: :string, description: "GT field")
    assert h.to_s.includes?("##INFO=<ID=DP,Number=1,Type=Integer,Description=\"Read depth\">")
    assert h.to_s.includes?("##FORMAT=<ID=GT,Number=1,Type=String,Description=\"GT field\">")

    assert_equal true, h.remove_info("DP")
    assert_equal true, h.remove_format("GT")
    refute h.to_s.includes?("##INFO=<ID=DP")
    refute h.to_s.includes?("##FORMAT=<ID=GT")
  end

  def test_add_meta_and_filter
    h = HTS::Bcf::Header.new
    h.add_meta("source", "myCaller")
    h.add_filter("LowQual", description: "Low quality")

    assert h.to_s.includes?("##source=myCaller")
    assert h.to_s.includes?("##FILTER=<ID=LowQual,Description=\"Low quality\">")

    assert_equal true, h.remove_filter("LowQual")
    refute h.to_s.includes?("LowQual")
  end
end
