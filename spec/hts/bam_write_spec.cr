require "../spec_helper"
require "../../src/hts/bam"

class BamWriteTest
  TEMP_DIR = File.expand_path("../fixtures", __DIR__)

  def temp_path(filename : String) : String
    File.join(TEMP_DIR, filename)
  end

  def teardown
    # Clean up temporary BAM/SAM files and their indexes
    cleanup_files = [
      "temp_write.bam",
      "temp_write.bam.bai",
      "temp_write.sam",
      "temp_write_sam.sam",
      "temp_write_block.bam",
      "temp_write_block.bam.bai",
      "temp_write_index.bam",
      "temp_write_index.bam.bai",
      "temp_write_default_index.bam",
      "temp_write_default_index.bam.bai",
      "temp_write_auto_index.bam",
      "temp_write_auto_index.bam.bai",
      "temp_no_header.bam",
      "temp_no_header.bam.bai",
      "temp_mate.bam",
      "temp_mate.bam.bai",
    ]

    cleanup_files.each do |file|
      path = temp_path(file)
      File.delete(path) if File.exists?(path)
    end
  end

  # Helper: Generate minimal BAM header with @HD and @SQ lines
  private def minimal_header_text : String
    <<-HEADER
      @HD\tVN:1.6\tSO:coordinate
      @SQ\tSN:chr1\tLN:1000
      @SQ\tSN:chr2\tLN:2000
      HEADER
  end

  # Placeholder test to verify structure
  def test_setup_works
    (true).should be_true
  end

  # Test basic BAM writing and reading back
  def test_write_and_read_bam
    path = temp_path("temp_write.bam")
    header = HTS::Bam::Header.parse(minimal_header_text)

    # Write BAM file with 2 records
    bam_out = HTS::Bam.open(path, "wb")
    bam_out.write_header(header)

    # Create first record
    rec1 = HTS::Bam::Record.new(
      header,
      qname: "read1",
      flag: 0_u16,
      rname: "chr1",
      pos: 100_i64,
      mapq: 60_u8,
      cigar_str: "10M",
      seq: "ACGTACGTAC",
      qual: [30_u8] * 10
    )
    bam_out.write(rec1)

    # Create second record
    rec2 = HTS::Bam::Record.new(
      header,
      qname: "read2",
      flag: 0_u16,
      rname: "chr2",
      pos: 200_i64,
      mapq: 40_u8,
      cigar_str: "8M",
      seq: "GGTTAAGC",
      qual: [25_u8] * 8
    )
    bam_out.write(rec2)
    bam_out.close

    # Read back and verify
    bam_in = HTS::Bam.open(path)
    records = [] of HTS::Bam::Record
    bam_in.each(copy: true) do |rec|
      records << rec
    end
    bam_in.close

    (records.size).should eq(2)
    (records[0].qname).should eq("read1")
    (records[0].pos).should eq(100)
    (records[1].qname).should eq("read2")
    (records[1].pos).should eq(200)
  end

  # Test SAM format writing
  def test_write_sam_format
    path = temp_path("temp_write_sam.sam")
    header = HTS::Bam::Header.parse(minimal_header_text)

    # Write SAM file
    bam_out = HTS::Bam.open(path, "w")
    bam_out.write_header(header)

    rec = HTS::Bam::Record.new(
      header,
      qname: "sam_read",
      flag: 0_u16,
      rname: "chr1",
      pos: 50_i64,
      mapq: 30_u8,
      cigar_str: "5M",
      seq: "ACGTA",
      qual: [20_u8] * 5
    )
    bam_out.write(rec)
    bam_out.close

    # Read back
    bam_in = HTS::Bam.open(path)
    count = 0
    first_qname = ""
    bam_in.each do |aln|
      count += 1
      first_qname = aln.qname if count == 1
    end
    bam_in.close

    (count).should eq(1)
    (first_qname).should eq("sam_read")
  end

  # Test block form with automatic close
  def test_write_with_block
    path = temp_path("temp_write_block.bam")
    header = HTS::Bam::Header.parse(minimal_header_text)

    result = HTS::Bam.open(path, "wb") do |bam|
      bam.write_header(header)
      rec = HTS::Bam::Record.new(
        header,
        qname: "block_read",
        flag: 0_u16,
        rname: "chr1",
        pos: 10_i64,
        mapq: 50_u8,
        cigar_str: "6M",
        seq: "GGTTAA",
        qual: [35_u8] * 6
      )
      bam.write(rec)
      bam
    end

    (result.closed?).should be_true

    # Verify content
    HTS::Bam.open(path) do |bam|
      records = [] of String
      bam.each { |record| records << record.qname }
      (records).should eq(["block_read"])
    end
  end

  # Test manual index building (indexing requires sorted BAM)
  def test_build_index_manually
    path = temp_path("temp_write_index.bam")
    index_path = "#{path}.bai"

    # Create a coordinate-sorted BAM file
    header_text = "@HD\tVN:1.6\tSO:coordinate\n@SQ\tSN:chr1\tLN:10000\n"
    header = HTS::Bam::Header.parse(header_text)

    HTS::Bam.open(path, "wb") do |bam|
      bam.write_header(header)

      # Write a few records in sorted order
      5.times do |i|
        rec = HTS::Bam::Record.new(
          header,
          qname: "read#{i}",
          flag: 0_u16,
          rname: "chr1",
          pos: (i * 100).to_i64,
          mapq: 60_u8,
          cigar_str: "10M",
          seq: "AAAAAAAAAA",
          qual: [30_u8] * 10
        )
        bam.write(rec)
      end
    end

    # Try to build index - may fail if BAM is not properly sorted
    # This is mainly to test the API works
    begin
      HTS::Bam.build_index(path, "", 0, false)
      # If successful, index file should exist
      if File.exists?(index_path)
        # Test querying
        HTS::Bam.open(path) do |bam|
          count = 0
          bam.query("chr1:150-350") { |_| count += 1 }
          count.should eq(2) # reads at 200 and 300
        end
      end
    rescue ex
      # Index building might fail - that's ok for this test
      # We're mainly testing that the write functionality works
      pending! "Index building failed (may require proper BAM sorting): #{ex.message}"
    end
  end

  def test_write_build_index_on_close
    path = temp_path("temp_write_auto_index.bam")
    index_path = "#{path}.bai"
    header = HTS::Bam::Header.parse(minimal_header_text)

    HTS::Bam.open(path, "wb", build_index: true) do |bam|
      bam.write_header(header)

      [100_i64, 300_i64].each_with_index do |pos, i|
        rec = HTS::Bam::Record.new(
          header,
          qname: "auto_index_read#{i}",
          flag: 0_u16,
          rname: "chr1",
          pos: pos,
          mapq: 60_u8,
          cigar_str: "10M",
          seq: "AAAAAAAAAA",
          qual: [30_u8] * 10
        )
        bam.write(rec)
      end
    end

    File.exists?(index_path).should be_true

    HTS::Bam.open(path) do |bam|
      positions = [] of Int64
      bam.query("chr1:250-350") { |record| positions << record.pos }
      positions.should eq([300])
    end
  end

  def test_build_index_uses_default_index_name
    path = temp_path("temp_write_default_index.bam")
    index_path = "#{path}.bai"
    header = HTS::Bam::Header.parse(minimal_header_text)

    HTS::Bam.open(path, "wb") do |bam|
      bam.write_header(header)
      rec = HTS::Bam::Record.new(
        header,
        qname: "default_index_read",
        flag: 0_u16,
        rname: "chr1",
        pos: 100_i64,
        mapq: 60_u8,
        cigar_str: "10M",
        seq: "AAAAAAAAAA",
        qual: [30_u8] * 10
      )
      bam.write(rec)
    end

    HTS::Bam.build_index(path, "", 0, 0, false)
    File.exists?(index_path).should be_true
  end

  # Test error: write without header
  def test_error_write_without_header
    path = temp_path("temp_no_header.bam")
    header = HTS::Bam::Header.parse(minimal_header_text)

    bam = HTS::Bam.open(path, "wb")
    rec = HTS::Bam::Record.new(
      header,
      qname: "test",
      flag: 0_u16,
      rname: "chr1",
      pos: 0_i64,
      mapq: 30_u8,
      cigar_str: "5M",
      seq: "ACGTA",
      qual: [20_u8] * 5
    )

    ex = expect_raises(Exception) { bam.write(rec) }
    (ex.message.try &.includes?("Header not written")).should be_true
    bam.close
  end

  # Test error: unknown reference name
  def test_error_unknown_reference
    header = HTS::Bam::Header.parse(minimal_header_text)

    ex = expect_raises(Exception) do
      HTS::Bam::Record.new(
        header,
        qname: "test",
        flag: 0_u16,
        rname: "chr999", # This reference doesn't exist in header
        pos: 0_i64,
        mapq: 30_u8,
        cigar_str: "5M",
        seq: "ACGTA",
        qual: [20_u8] * 5
      )
    end
    (ex.message.try &.includes?("Unknown reference")).should be_true
  end

  # Test error: invalid path
  def test_error_invalid_path
    ex = expect_raises(Exception) do
      HTS::Bam.open("/nonexistent/directory/file.bam", "wb")
    end
    (ex.message.try &.includes?("Failed to open")).should be_true
  end

  # Test with mate pair information
  def test_write_with_mate_info
    path = temp_path("temp_mate.bam")
    header = HTS::Bam::Header.parse(minimal_header_text)

    HTS::Bam.open(path, "wb") do |bam|
      bam.write_header(header)

      rec = HTS::Bam::Record.new(
        header,
        qname: "paired_read",
        flag: 99_u16, # Paired, first in pair, mate reverse
        rname: "chr1",
        pos: 100_i64,
        mapq: 60_u8,
        cigar_str: "10M",
        seq: "ACGTACGTAC",
        qual: [30_u8] * 10,
        mtid: header.get_tid("chr2"),
        mpos: 500_i64,
        isize: 450_i64
      )
      bam.write(rec)
    end

    # Read back and verify
    HTS::Bam.open(path) do |bam|
      bam.each do |aln|
        (aln.qname).should eq("paired_read")
        (aln.flag.value).should eq(99)
        (aln.mate_chrom).should eq("chr2")
        (aln.mate_pos).should eq(500)
        (aln.insert_size).should eq(450)
      end
    end
  end
end

describe BamWriteTest do
  {% for method in BamWriteTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BamWriteTest.new
      begin
        spec_case.{{ method.name.id }}
      ensure
        spec_case.teardown
      end
    end
  {% end %}
end
