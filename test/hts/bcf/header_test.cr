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

  def test_to_s
    # md5 = Digest::MD5.hexdigest(bcf.header.to_s)
    # exp = "ca7d2c7ac2a51e4f2b2b88004615e98b"
    # assert_equal exp, md5
  end
end
