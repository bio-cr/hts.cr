require "minitest/autorun"
require "../../src/hts/bam"

class BamTest < Minitest::Test
  def setup
    @bam = HTS::Bam.new(File.expand_path("../fixtures/poo.sort.bam", __DIR__))
  end

  def teardown
    @bam.try &.close
  end

  def test_initialize
    assert_instance_of HTS::Bam, @bam
  end
end
