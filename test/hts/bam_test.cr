require "minitest/autorun"
require "../../src/hts/bam"

class BamTest < Minitest::Test
  def bam
    HTS::Bam.new(File.expand_path("../fixtures/poo.sort.bam", __DIR__))
  end

  def test_close
    assert_equal 0, bam.close
  end
end
