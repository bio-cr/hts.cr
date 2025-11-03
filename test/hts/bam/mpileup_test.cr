require "minitest/autorun"
require "../../../src/hts/bam"

class BamMpileupSmokeTest < Minitest::Test
  def test_multipileup_two_inputs_basic
    path = File.expand_path("../../fixtures/moo.bam", __DIR__)
    b1 = HTS::Bam.new(path)
    b2 = HTS::Bam.new(path)
    mp = HTS::Bam::Mpileup.new([b1, b2], 1000, true)
    begin
      seen = 0
      first = nil
      mp.each do |cols|
        first ||= cols
        seen += 1
        break if seen >= 3
      end
      refute_nil first
      assert_equal 2, first.not_nil!.size
      first.not_nil!.each do |col|
        assert_instance_of HTS::Bam::Pileup::Column, col
        assert col.tid.is_a?(Int32) || col.tid.is_a?(Int64)
        assert col.pos.is_a?(Int64) || col.pos.is_a?(Int32)
        assert col.depth >= 0
      end
    ensure
      # Close Mpileup and input BAMs (not owned by Mpileup)
      mp.close
      b1.close
      b2.close
    end
  end
end
