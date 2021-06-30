require "minitest/autorun"
require "../src/htslib.cr"

class HTSlibTEST < Minitest::Test
  def test_hts_version
    assert_instance_of String, String.new(HTSlib.hts_version)
  end
end
