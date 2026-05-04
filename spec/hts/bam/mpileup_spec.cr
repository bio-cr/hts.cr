require "../../spec_helper"
require "../../../src/hts/bam"

class BamMpileupSmokeTest < HTSSpecCase
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
      expect_not_nil first
      expect_equal 2, first.not_nil!.size
      first.not_nil!.each do |col|
        expect_instance_of HTS::Bam::Pileup::Column, col
        expect_true col.tid.is_a?(Int32) || col.tid.is_a?(Int64)
        expect_true col.pos.is_a?(Int64) || col.pos.is_a?(Int32)
        expect_true col.depth >= 0
      end
    ensure
      # Close Mpileup and input BAMs (not owned by Mpileup)
      mp.close
      b1.close
      b2.close
    end
  end
end

describe BamMpileupSmokeTest do
  {% for method in BamMpileupSmokeTest.methods.select { |method| method.name.stringify.starts_with?("test_") } %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BamMpileupSmokeTest.new
      run_spec_case(spec_case) do
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
