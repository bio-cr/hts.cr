require "minitest/autorun"
require "../../src/hts/version"

class VersionTest < Minitest::Test
  def test_version
    assert_instance_of String, HTS::VERSION
  end
end
