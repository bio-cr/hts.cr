require "minitest/autorun"
require "../src/htslib.cr"

class LibHTSTEST < Minitest::Test
  def test_hts_version
    assert_instance_of String, String.new(LibHTS.hts_version)
  end
end
