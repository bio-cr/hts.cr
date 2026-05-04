require "../../spec_helper"
require "../../../src/hts/bam"

class BamHeaderTest < HTSSpecCase
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
    expect_instance_of HTS::Bam::Header, b
    expect_equal s, b.to_s
  end

  def test_parse_rejects_invalid_header_text
    ex = expect_raises(ArgumentError) { HTS::Bam::Header.parse("not-a-sam-header") }
    expect_includes ex.message.to_s, "Failed to parse SAM header text"
  end

  def test_initialize
    expect_instance_of HTS::Bam::Header, HTS::Bam::Header.new
  end

  def test_target_count
    expect_equal(1, bam.header.target_count)
  end

  def test_target_name
    expect_equal("poo", bam.header.target_name(0))
  end

  def test_target_name_rejects_invalid_tid
    ex = expect_raises(ArgumentError) { bam.header.target_name(99) }
    expect_includes ex.message.to_s, "Unknown target id 99"
  end

  def test_target_names
    expect_equal(["poo"], bam.header.target_names)
  end

  def test_target_len
    expect_equal([5000], bam.header.target_len)
  end

  def test_get_tid
    expect_equal 0, bam.header.get_tid("poo")
  end

  def test_add_pg
    header = HTS::Bam::Header.parse(minimal_header_text)
    header.add_pg("meowtools", "CL", "meow -n 3")

    expect_true normalize_header(header.to_s).includes?("@PG\tID:meowtools\tPN:meowtools\tCL:meow -n 3\n")
  end

  def test_add_pg_generates_unique_id
    header_text = <<-TEXT
    @HD\tVN:1.6\tSO:coordinate
    @SQ\tSN:chr1\tLN:1000
    @PG\tID:samtools\tPN:samtools

    TEXT
    header = HTS::Bam::Header.parse(header_text)

    header.add_pg("samtools", "CL", "samtools view -H")

    expect_true normalize_header(header.to_s).includes?("@PG\tID:samtools.1\tPN:samtools\tCL:samtools view -H\n")
  end

  def test_add_pg_with_parent
    header_text = <<-TEXT
    @HD\tVN:1.6\tSO:coordinate
    @SQ\tSN:chr1\tLN:1000
    @PG\tID:align\tPN:align

    TEXT
    header = HTS::Bam::Header.parse(header_text)

    header.add_pg("sort", "PP", "align", "CL", "samtools sort")

    expect_true normalize_header(header.to_s).includes?("@PG\tID:sort\tPN:sort\tPP:align\tCL:samtools sort\n")
  end

  def test_add_pg_rejects_odd_tag_count
    header = HTS::Bam::Header.parse(minimal_header_text)

    ex = expect_raises(ArgumentError) { header.add_pg("meowtools", "CL") }
    expect_true ex.message.try &.includes?("key/value pairs")
  end

  def test_add_pg_rejects_unknown_parent
    header = HTS::Bam::Header.parse(minimal_header_text)

    ex = expect_raises(ArgumentError) { header.add_pg("meowtools", "PP", "missing") }
    expect_true ex.message.try &.includes?("Unknown PG parent")
  end

  def test_update_hd
    header = HTS::Bam::Header.parse(minimal_header_text)

    header.update_hd(version: "1.7", group_order: "query")

    expect_true normalize_header(header.to_s).includes?("@HD\tVN:1.7\tSO:coordinate\tGO:query\n")
  end

  def test_add_update_remove_sq
    header = HTS::Bam::Header.parse(minimal_header_text)

    header.add_sq("chr2", 2000, assembly: "GRCh38")
    expect_equal 2, header.count_lines("SQ")
    expect_equal "chr2", header.line_name("SQ", 1)
    expect_equal "2000", header.find_tag("SQ", "SN", "chr2", "LN")

    header.update_sq("chr2", md5: "abc123")
    expect_equal "abc123", header.find_tag("SQ", "SN", "chr2", "M5")

    expect_equal true, header.remove_sq("chr2")
    expect_nil header.find_line("SQ", "SN", "chr2")
  end

  def test_add_update_remove_rg
    header = HTS::Bam::Header.parse(rg_header_text)

    header.add_rg("rg2", sample: "sample2", platform: "ILLUMINA")
    expect_equal 2, header.count_lines("RG")
    expect_equal "sample2", header.find_tag("RG", "ID", "rg2", "SM")

    header.update_rg("rg2", description: "tumor")
    expect_equal "tumor", header.find_tag("RG", "ID", "rg2", "DS")

    expect_equal true, header.delete_tag("RG", "ID", "rg2", "DS")
    expect_nil header.find_tag("RG", "ID", "rg2", "DS")

    expect_equal true, header.remove_rg("rg2")
    expect_nil header.find_line("RG", "ID", "rg2")
  end

  def test_to_s
    header_text = <<-TEXT
    @HD	VN:1.3	SO:coordinate
    @SQ	SN:poo	LN:5000
    @PG	ID:bwa	PN:bwa	VN:0.7.17-r1188	CL:bwa mem poo.fa poos_1.fq poos_2.fq
    @PG	ID:samtools	PN:samtools	PP:bwa	VN:1.10-96-gcc4e1a6	CL:samtools sort -o poo.sort.bam b.bam

    TEXT
    header_text = header_text.gsub(/\r\n/, "\n") # for Windows
    expect_equal header_text, bam.header.to_s
  end

  def test_clone
    hdr2 = bam.header.clone
    expect_instance_of HTS::Bam::Header, hdr2
  end
end

describe BamHeaderTest do
  {% for method in BamHeaderTest.methods.select { |method| method.name.stringify.starts_with?("test_") } %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BamHeaderTest.new
      run_spec_case(spec_case) do
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
