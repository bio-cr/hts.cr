require "../../spec_helper"
require "../../../src/hts/bam"

class BamPileupSmokeTest
  def test_pileup_yields_columns
    path = File.expand_path("../../fixtures/moo.bam", __DIR__)
    HTS::Bam.open(path) do |bam|
      seen = 0
      first_col = nil
      first_query_pos = nil
      first_base = nil
      first_base_qual = nil
      first_qname = nil
      plp = HTS::Bam::Pileup.new(bam, maxcnt: 1000)
      # Alignment metadata and per-position base calls are copied into Crystal
      # values, but record() still duplicates the htslib record and must be
      # called before close.
      rec1 = nil
      rec2 = nil
      begin
        plp.each do |col|
          first_col ||= col
          if rec1.nil? && col.depth > 0
            aln = col.alignments.first
            first_query_pos = aln.query_pos
            rec1 = aln.record
            rec2 = aln.record
            first_base = aln.base
            first_base_qual = aln.base_qual
            first_qname = aln.qname

            unless aln.del? || aln.refskip?
              record = rec1 || raise "missing copied record"
              (first_base).should eq(record.base(aln.query_pos))
              (first_base_qual).should eq(record.base_qual(aln.query_pos))
              (first_qname).should eq(record.qname)
            end
          end
          seen += 1
          break if seen >= 3
        end
      ensure
        plp.close
      end

      column = first_col || raise "no pileup column yielded"
      (column).should be_a(HTS::Bam::Pileup::Column)
      (column.tid.is_a?(Int32) || column.tid.is_a?(Int64)).should be_true
      (column.pos.is_a?(Int64) || column.pos.is_a?(Int32)).should be_true
      (column.depth >= 0).should be_true

      # Copied alignment metadata remains available after close.
      if column.depth > 0
        (column.alignments.first.query_pos).should eq(first_query_pos)
        (column.alignments.first.base).should eq(first_base)
        (column.alignments.first.base_qual).should eq(first_base_qual)
        (rec2).same?(rec1).should be_true
        (rec1).should be_a(HTS::Bam::Record)
      end
    end
  end

  def test_pileup_open_with_keyword_region
    path = File.expand_path("../../fixtures/moo.bam", __DIR__)
    HTS::Bam.open(path) do |bam|
      HTS::Bam::Pileup.open(bam, region: "chr2:350-700", maxcnt: 1000) do |plp|
        first_col = nil
        plp.each do |col|
          first_col ||= col
          break
        end

        column = first_col || raise "no pileup column yielded"
        (column.depth >= 0).should be_true
      end
    end
  end
end

describe BamPileupSmokeTest do
  {% for method in BamPileupSmokeTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BamPileupSmokeTest.new
      begin
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
