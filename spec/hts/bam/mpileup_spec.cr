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
      first_columns = first || raise "no mpileup columns yielded"
      (first_columns.size).should eq(2)
      first_columns.each do |col|
        (col).should be_a(HTS::Bam::Pileup::Column)
        (col.tid.is_a?(Int32) || col.tid.is_a?(Int64)).should be_true
        (col.pos.is_a?(Int64) || col.pos.is_a?(Int32)).should be_true
        (col.depth >= 0).should be_true
      end
    ensure
      # Close Mpileup and input files (not owned by Mpileup)
      mp.close
      b1.close
      b2.close
    end
  end

  def test_multipileup_with_region
    path = File.expand_path("../../fixtures/moo.bam", __DIR__)
    b1 = HTS::Bam.new(path)
    b2 = HTS::Bam.new(path)
    mp = HTS::Bam::Mpileup.new([b1, b2], maxcnt: 1000, overlaps: true, region: "chr2:350-700")
    begin
      first = nil
      mp.each do |cols|
        first ||= cols
        break
      end

      first_columns = first || raise "no mpileup columns yielded"
      (first_columns.size).should eq(2)
      first_columns.each do |col|
        (col).should be_a(HTS::Bam::Pileup::Column)
        (col.depth >= 0).should be_true
      end
    ensure
      mp.close
      b1.close
      b2.close
    end
  end

  def test_open_with_region
    path = File.expand_path("../../fixtures/moo.bam", __DIR__)
    b1 = HTS::Bam.new(path)
    b2 = HTS::Bam.new(path)
    begin
      HTS::Bam::Mpileup.open([b1, b2], maxcnt: 1000, overlaps: true, region: "chr2:350-700") do |mpileup|
        first = nil
        mpileup.each do |cols|
          first ||= cols
          break
        end

        first_columns = first || raise "no mpileup columns yielded"
        (first_columns.size).should eq(2)
      end
    ensure
      b1.close
      b2.close
    end
  end

  def test_multipileup_with_regions
    path = File.expand_path("../../fixtures/moo.bam", __DIR__)
    b1 = HTS::Bam.new(path)
    b2 = HTS::Bam.new(path)
    mp = HTS::Bam::Mpileup.new([b1, b2], maxcnt: 1000, overlaps: true, regions: ["chr2:350-700"])
    begin
      first = nil
      mp.each do |cols|
        first ||= cols
        break
      end

      first_columns = first || raise "no mpileup columns yielded"
      (first_columns.size).should eq(2)
    ensure
      mp.close
      b1.close
      b2.close
    end
  end

  def test_rejects_empty_inputs
    expect_raises(ArgumentError, "inputs must not be empty") do
      HTS::Bam::Mpileup.new([] of HTS::Bam)
    end
  end

  def test_rejects_empty_region
    path = File.expand_path("../../fixtures/moo.bam", __DIR__)
    bam = HTS::Bam.new(path)
    begin
      expect_raises(ArgumentError, "region must not be empty") do
        HTS::Bam::Mpileup.new([bam], region: "")
      end
    ensure
      bam.close
    end
  end

  def test_rejects_empty_regions
    path = File.expand_path("../../fixtures/moo.bam", __DIR__)
    bam = HTS::Bam.new(path)
    begin
      expect_raises(ArgumentError, "regions must not be empty") do
        HTS::Bam::Mpileup.new([bam], regions: [] of String)
      end
    ensure
      bam.close
    end
  end

  def test_rejects_empty_region_entry
    path = File.expand_path("../../fixtures/moo.bam", __DIR__)
    bam = HTS::Bam.new(path)
    begin
      expect_raises(ArgumentError, "regions[1] must not be empty") do
        HTS::Bam::Mpileup.new([bam], regions: ["chr1:100-200", ""])
      end
    ensure
      bam.close
    end
  end

  def test_rejects_region_and_regions_together
    path = File.expand_path("../../fixtures/moo.bam", __DIR__)
    bam = HTS::Bam.new(path)
    begin
      expect_raises(ArgumentError, "region and regions cannot both be specified") do
        HTS::Bam::Mpileup.new([bam], region: "chr1:100-200", regions: ["chr2:350-700"])
      end
    ensure
      bam.close
    end
  end

  def test_region_requires_index
    source_path = File.expand_path("../../fixtures/moo.bam", __DIR__)
    temp_file = File.tempfile("mpileup_no_index", ".bam")
    temp_path = temp_file.path
    temp_file.close
    File.copy(source_path, temp_path)

    bam = HTS::Bam.new(temp_path)
    begin
      expect_raises(HTS::Bam::MissingIndexError) do
        HTS::Bam::Mpileup.new([bam], region: "chr2:350-700")
      end
    ensure
      bam.close
      File.delete(temp_path) if File.exists?(temp_path)
    end
  end
end

describe BamMpileupSmokeTest do
  {% for method in BamMpileupSmokeTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BamMpileupSmokeTest.new
      begin
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
