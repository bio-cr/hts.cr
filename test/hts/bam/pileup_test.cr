require "minitest/autorun"
require "../../../src/hts/bam"

class BamPileupSmokeTest < Minitest::Test
  def test_pileup_yields_columns
    path = File.expand_path("../../fixtures/moo.bam", __DIR__)
    HTS::Bam.open(path) do |bam|
      seen = 0
      first_col = nil
      plp = HTS::Bam::Pileup.new(bam, maxcnt: 1000)
      # Capture a first column and, if present, duplicate one record while the
      # underlying plp iterator is still alive. The pileup entry pointers are
      # only valid until the next plp step or destruction, so record() must be
      # called before close.
      rec1 = nil
      rec2 = nil
      begin
        plp.each do |col|
          first_col ||= col
          if rec1.nil? && col.depth > 0
            aln = col.alignments.first
            rec1 = aln.record
            rec2 = aln.record
          end
          seen += 1
          break if seen >= 3
        end
      ensure
        plp.close
      end

      refute_nil first_col
      assert_instance_of HTS::Bam::Pileup::Column, first_col
      assert first_col.not_nil!.tid.is_a?(Int32) || first_col.not_nil!.tid.is_a?(Int64)
      assert first_col.not_nil!.pos.is_a?(Int64) || first_col.not_nil!.pos.is_a?(Int32)
      assert first_col.not_nil!.depth >= 0

      # Alignment wrapper basic behaviors (verified before close)
      if first_col.not_nil!.depth > 0
        assert_same rec1, rec2
        assert_instance_of HTS::Bam::Record, rec1
      end
    end
  end
end
