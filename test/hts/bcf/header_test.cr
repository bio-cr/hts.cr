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

  def test_samples
    assert_equal ["poo.sort.bam"], hdr.samples
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
end
