require "../../spec_helper"
require "../../../src/hts/bam"

class BamMpileupSmokeTest
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
      (first).should_not be_nil
      (first.not_nil!.size).should eq(2)
      first.not_nil!.each do |col|
        (col).should be_a(HTS::Bam::Pileup::Column)
        (col.tid.is_a?(Int32) || col.tid.is_a?(Int64)).should be_true
        (col.pos.is_a?(Int64) || col.pos.is_a?(Int32)).should be_true
        (col.depth >= 0).should be_true
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
      begin
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
