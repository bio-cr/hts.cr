require "minitest/autorun"
require "../../src/hts/libhts.cr"

class HTSTest < Minitest::Test
  def test_version
    assert_instance_of String, HTS::VERSION
  end

  def test_hts_version
    assert_instance_of String, String.new(HTS::LibHTS.hts_version)
  end
end
