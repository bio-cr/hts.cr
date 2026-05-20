require "../../spec_helper"
require "../../../src/hts/bam"

class BamHeaderTest
  def teardown
    @bam.try &.close
  end

  private def normalize_header(text : String) : String
    text.gsub(/\r\n/, "\n")
  end

  private def minimal_header_text : String
    <<-TEXT
    @HD\tVN:1.6\tSO:coordinate
    @SQ\tSN:chr1\tLN:1000

    TEXT
  end

  private def rg_header_text : String
    <<-TEXT
    @HD\tVN:1.6\tSO:coordinate
    @SQ\tSN:chr1\tLN:1000
    @RG\tID:rg1\tSM:sample1

    TEXT
  end

  def test_bam_path
    File.expand_path("../../fixtures/poo.sort.bam", __DIR__)
  end

  def bam
    @bam ||= HTS::Bam.new(test_bam_path)
  end

  def test_parse
    s = bam.header.to_s
    b = HTS::Bam::Header.parse(s)
    (b).should be_a(HTS::Bam::Header)
    (b.to_s).should eq(s)
  end

  def test_parse_rejects_invalid_header_text
    ex = expect_raises(ArgumentError) { HTS::Bam::Header.parse("not-a-sam-header") }
    (ex.message.to_s).should contain("Failed to parse SAM header text")
  end

  def test_initialize
    (HTS::Bam::Header.new).should be_a(HTS::Bam::Header)
  end

  def test_target_count
    (bam.header.target_count).should eq(1)
  end

  def test_target_name
    (bam.header.target_name(0)).should eq("poo")
  end

  def test_target_name_rejects_invalid_tid
    ex = expect_raises(ArgumentError) { bam.header.target_name(99) }
    (ex.message.to_s).should contain("Unknown target id 99")
  end

  def test_target_names
    (bam.header.target_names).should eq(["poo"])
  end

  def test_target_len
    (bam.header.target_len).should eq([5000])
  end

  def test_get_tid
    (bam.header.get_tid("poo")).should eq(0)
  end

  def test_add_pg
    header = HTS::Bam::Header.parse(minimal_header_text)
    header.add_pg("meowtools", "CL", "meow -n 3")

    (normalize_header(header.to_s).includes?("@PG\tID:meowtools\tPN:meowtools\tCL:meow -n 3\n")).should be_true
  end

  def test_add_pg_generates_unique_id
    header_text = <<-TEXT
    @HD\tVN:1.6\tSO:coordinate
    @SQ\tSN:chr1\tLN:1000
    @PG\tID:samtools\tPN:samtools

    TEXT
    header = HTS::Bam::Header.parse(header_text)

    header.add_pg("samtools", "CL", "samtools view -H")

    (normalize_header(header.to_s).includes?("@PG\tID:samtools.1\tPN:samtools\tCL:samtools view -H\n")).should be_true
  end

  def test_add_pg_with_parent
    header_text = <<-TEXT
    @HD\tVN:1.6\tSO:coordinate
    @SQ\tSN:chr1\tLN:1000
    @PG\tID:align\tPN:align

    TEXT
    header = HTS::Bam::Header.parse(header_text)

    header.add_pg("sort", "PP", "align", "CL", "samtools sort")

    (normalize_header(header.to_s).includes?("@PG\tID:sort\tPN:sort\tPP:align\tCL:samtools sort\n")).should be_true
  end

  def test_add_pg_rejects_odd_tag_count
    header = HTS::Bam::Header.parse(minimal_header_text)

    ex = expect_raises(ArgumentError) { header.add_pg("meowtools", "CL") }
    (ex.message.try &.includes?("key/value pairs")).should be_true
  end

  def test_add_pg_rejects_unknown_parent
    header = HTS::Bam::Header.parse(minimal_header_text)

    ex = expect_raises(ArgumentError) { header.add_pg("meowtools", "PP", "missing") }
    (ex.message.try &.includes?("Unknown PG parent")).should be_true
  end

  def test_update_hd
    header = HTS::Bam::Header.parse(minimal_header_text)

    header.update_hd(version: "1.7", group_order: "query")

    (normalize_header(header.to_s).includes?("@HD\tVN:1.7\tSO:coordinate\tGO:query\n")).should be_true
  end

  def test_add_update_remove_sq
    header = HTS::Bam::Header.parse(minimal_header_text)

    header.add_sq("chr2", 2000, assembly: "GRCh38")
    (header.count_lines("SQ")).should eq(2)
    (header.line_name("SQ", 1)).should eq("chr2")
    (header.find_tag("SQ", "SN", "chr2", "LN")).should eq("2000")

    header.update_sq("chr2", md5: "abc123")
    (header.find_tag("SQ", "SN", "chr2", "M5")).should eq("abc123")

    (header.remove_sq("chr2")).should eq(true)
    (header.find_line("SQ", "SN", "chr2")).should be_nil
  end

  def test_add_update_remove_rg
    header = HTS::Bam::Header.parse(rg_header_text)

    header.add_rg("rg2", sample: "sample2", platform: "ILLUMINA")
    (header.count_lines("RG")).should eq(2)
    (header.find_tag("RG", "ID", "rg2", "SM")).should eq("sample2")

    header.update_rg("rg2", description: "tumor")
    (header.find_tag("RG", "ID", "rg2", "DS")).should eq("tumor")

    (header.delete_tag("RG", "ID", "rg2", "DS")).should eq(true)
    (header.find_tag("RG", "ID", "rg2", "DS")).should be_nil

    (header.remove_rg("rg2")).should eq(true)
    (header.find_line("RG", "ID", "rg2")).should be_nil
  end

  def test_to_s
    header_text = <<-TEXT
    @HD	VN:1.3	SO:coordinate
    @SQ	SN:poo	LN:5000
    @PG	ID:bwa	PN:bwa	VN:0.7.17-r1188	CL:bwa mem poo.fa poos_1.fq poos_2.fq
    @PG	ID:samtools	PN:samtools	PP:bwa	VN:1.10-96-gcc4e1a6	CL:samtools sort -o poo.sort.bam b.bam

    TEXT
    header_text = header_text.gsub(/\r\n/, "\n") # for Windows
    (bam.header.to_s).should eq(header_text)
  end

  def test_clone
    hdr2 = bam.header.clone
    (hdr2).should be_a(HTS::Bam::Header)
  end
end

describe BamHeaderTest do
  {% for method in BamHeaderTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BamHeaderTest.new
      begin
        spec_case.{{ method.name.id }}
      ensure
        spec_case.teardown
      end
    end
  {% end %}
end
