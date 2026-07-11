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
      # Column and Alignment are zero-copy views valid only during iteration.
      # Per-position scalars (query_pos/base/base_qual) are copied out, and
      # record() duplicates the htslib record; both must be captured before close.
      rec1 = nil
      rec2 = nil
      begin
        plp.each do |col|
          first_col ||= col
          if rec1.nil? && col.depth > 0
            aln = col[0]
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
            (col.count).should eq(col.depth)
            (col.count(&.del?)).should be_a(Int32)
          end
          seen += 1
          break if seen >= 3
        end
      ensure
        plp.close
      end

      column = first_col || raise "no pileup column yielded"
      (column).should be_a(HTS::Bam::Pileup::Column)
      # tid/pos/depth are copied-out scalars and stay readable after close.
      (column.tid.is_a?(Int32) || column.tid.is_a?(Int64)).should be_true
      (column.pos.is_a?(Int64) || column.pos.is_a?(Int32)).should be_true
      (column.depth >= 0).should be_true

      # Data retained via the borrowing contract (scalars + duplicated record)
      # survives after close; the views themselves do not.
      if rec1
        (first_query_pos).should_not be_nil
        (first_base_qual).should_not be_nil
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

  def test_pileup_count_consumes_iterator
    path = File.expand_path("../../fixtures/moo.bam", __DIR__)
    HTS::Bam.open(path) do |bam|
      plp = HTS::Bam::Pileup.new(bam, maxcnt: 1000)
      begin
        (plp.count).should be > 0
      ensure
        plp.close
      end
    end
  end

  def test_pileup_count_with_block
    path = File.expand_path("../../fixtures/moo.bam", __DIR__)
    HTS::Bam.open(path) do |bam|
      plp = HTS::Bam::Pileup.new(bam, maxcnt: 1000)
      begin
        (plp.count { |col| col.depth > 0 }).should be > 0
      ensure
        plp.close
      end
    end
  end

  def test_pileup_count_empty_filter
    path = File.expand_path("../../fixtures/moo.bam", __DIR__)
    HTS::Bam.open(path) do |bam|
      plp = HTS::Bam::Pileup.new(bam, maxcnt: 1000, filter: HTS::Bam::Pileup::Filter.new(min_mapq: 61))
      begin
        (plp.count).should eq(0)
      ensure
        plp.close
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
