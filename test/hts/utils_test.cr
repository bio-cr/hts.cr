require "minitest/autorun"
require "../../src/hts/utils.cr"

class UtilsTest < Minitest::Test
  include HTS::Utils

  def test_warn
    output, error = capture_io do
      warn("The sky is falling!")
    end
    assert_equal "The sky is falling!\n", error
  end
end
