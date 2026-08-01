require "../spec_helper"
require "../../src/hts/tabix"

class TabixTest
  # Simple sorted VCF data (CHROM, POS 1-based, …).
  # Header lines (beginning with '#') are skipped by tabix when querying.
  VCF_LINES = [
    "##fileformat=VCFv4.0",
    "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO",
    "poo\t100\t.\tA\tT\t.\t.\t.",
    "poo\t200\t.\tG\tC\t.\t.\t.",
    "poo\t300\t.\tT\tA\t.\t.\t.",
    "poo\t400\t.\tC\tG\t.\t.\t.",
    "poo\t500\t.\tA\tC\t.\t.\t.",
  ]

  BED_LINES = [
    "chr1\t0\t100\twide",
    "chr1\t200\t300\tfar",
    "chr2\t5\t15\tother",
  ]

  @vcf_gz : String = ""

  def setup
    tmp = File.tempfile("tbx_test", ".vcf.gz")
    @vcf_gz = tmp.path
    tmp.close

    # Write BGZF-compressed VCF lines.
    HTS::Bgzf.open(@vcf_gz, "wz") do |bgzf|
      VCF_LINES.each { |line| bgzf.puts(line) }
    end

    # Build tabix index (creates @vcf_gz + ".tbi").
    HTS::Tabix.build_index(@vcf_gz, verbose: false)
  end

  def teardown
    File.delete(@vcf_gz) if File.exists?(@vcf_gz)
    tbi = "#{@vcf_gz}.tbi"
    File.delete(tbi) if File.exists?(tbi)
  end

  def without_index(&)
    tbi = "#{@vcf_gz}.tbi"
    File.delete(tbi) if File.exists?(tbi)
    HTS::Tabix.open(@vcf_gz) do |tbx|
      yield tbx
    end
  end

  def test_open_and_close
    HTS::Tabix.open(@vcf_gz) do |tbx|
      (tbx.closed?).should be_false
    end
  end

  def test_open_missing_file_raises_open_error
    with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogOff) do
      expect_raises(HTS::Tabix::OpenError) { HTS::Tabix.open("/tmp/no_such_tabix_file.vcf.gz") }
    end
  end

  def test_index_loaded
    HTS::Tabix.open(@vcf_gz) do |tbx|
      (tbx.index_loaded?).should be_true
    end
  end

  def test_seqnames
    HTS::Tabix.open(@vcf_gz) do |tbx|
      (tbx.seqnames).should eq(["poo"])
    end
  end

  def test_name2id_known
    HTS::Tabix.open(@vcf_gz) do |tbx|
      (tbx.name2id("poo")).should eq(0)
    end
  end

  def test_name2id_unknown
    HTS::Tabix.open(@vcf_gz) do |tbx|
      (tbx.name2id("nonexistent")).should eq(-1)
    end
  end

  def test_seqnames_requires_index
    without_index do |tbx|
      ex = expect_raises(HTS::Tabix::MissingIndexError) { tbx.seqnames }
      (ex.message.to_s).should contain(@vcf_gz)
      (ex.message.to_s).should contain("seqnames requires an index")
    end
  end

  def test_name2id_requires_index
    without_index do |tbx|
      ex = expect_raises(HTS::Tabix::MissingIndexError) { tbx.name2id("poo") }
      (ex.message.to_s).should contain(@vcf_gz)
      (ex.message.to_s).should contain("name2id requires an index")
    end
  end

  # "poo:150-250" (1-based inclusive) → POS=200 only
  def test_query_string_single_record
    HTS::Tabix.open(@vcf_gz) do |tbx|
      results = [] of Array(String)
      tbx.query("poo:150-250") { |feature| results << feature }
      (results.size).should eq(1)
      (results[0][1]).should eq("200")
    end
  end

  # "poo:100-300" → POS=100, 200, 300
  def test_query_string_multiple_records
    HTS::Tabix.open(@vcf_gz) do |tbx|
      results = [] of Array(String)
      tbx.query("poo:100-300") { |feature| results << feature }
      (results.size).should eq(3)
    end
  end

  # htslib parser accepts commas in region coordinates.
  def test_query_string_with_commas
    HTS::Tabix.open(@vcf_gz) do |tbx|
      results = [] of Array(String)
      tbx.query("poo:1-3,00") { |feature| results << feature }
      (results.size).should eq(3)
    end
  end

  # whole-chromosome query "poo" → all 5 data records
  def test_query_string_whole_chromosome
    HTS::Tabix.open(@vcf_gz) do |tbx|
      results = [] of Array(String)
      tbx.query("poo") { |feature| results << feature }
      (results.size).should eq(5)
    end
  end

  # query("poo", 149, 201) → 0-based [149,201) covers 1-based POS=200 only
  def test_query_numeric_single_record
    HTS::Tabix.open(@vcf_gz) do |tbx|
      results = [] of Array(String)
      tbx.query("poo", 149, 201) { |feature| results << feature }
      (results.size).should eq(1)
      (results[0][1]).should eq("200")
    end
  end

  # query("poo", 99, 299) → 0-based [99,299) covers 1-based POS=100, 200 (POS=300 at 0-based 299 is excluded)
  def test_query_numeric_two_records
    HTS::Tabix.open(@vcf_gz) do |tbx|
      results = [] of Array(String)
      tbx.query("poo", 99, 299) { |feature| results << feature }
      (results.size).should eq(2)
    end
  end

  def test_query_fields
    HTS::Tabix.open(@vcf_gz) do |tbx|
      tbx.query("poo:100-100") do |fields|
        (fields[0]).should eq("poo")
        (fields[1]).should eq("100")
        (fields[3]).should eq("A")
        (fields[4]).should eq("T")
      end
    end
  end

  def test_each_line_and_line_view
    HTS::Tabix.open(@vcf_gz) do |tbx|
      lines = [] of String
      tbx.each_line("poo:100-200") { |line| lines << line }
      (lines).should eq(VCF_LINES[2, 2])

      views = [] of String
      tbx.each_line_view("poo:100-200") do |line|
        (line.to_unsafe.null?).should be_false
        views << String.new(line)
      end
      (views).should eq(lines)
    end
  end

  def test_each_fields_preserves_query_convenience
    HTS::Tabix.open(@vcf_gz) do |tbx|
      fields = [] of Array(String)
      tbx.each_fields("poo:100-100") { |row| fields << row }
      (fields).should eq([["poo", "100", ".", "A", "T", ".", ".", "."]])
    end
  end

  def test_each_selected_fields
    HTS::Tabix.open(@vcf_gz) do |tbx|
      selected = [] of Array(String)
      array_id = nil.as(UInt64?)

      tbx.each_selected_fields("poo:100-200", 0, 3, 4) do |values|
        array_id ||= values.object_id
        (values.object_id).should eq(array_id)
        selected << values.map { |value| String.new(value) }
      end

      (selected).should eq([
        ["poo", "A", "T"],
        ["poo", "G", "C"],
      ])
    end
  end

  def test_each_selected_fields_validates_indices
    HTS::Tabix.open(@vcf_gz) do |tbx|
      expect_raises(ArgumentError, "field index must not be negative: -1") do
        tbx.each_selected_fields("poo:100-100", -1) { }
      end
      expect_raises(IndexError, "field index 8 out of range 0...8") do
        tbx.each_selected_fields("poo:100-100", 8) { }
      end
    end
  end

  def test_query_requires_index
    without_index do |tbx|
      ex = expect_raises(HTS::Tabix::MissingIndexError) do
        tbx.query("poo:100-100") { |_| }
      end
      (ex.message.to_s).should contain(@vcf_gz)
      (ex.message.to_s).should contain("query requires an index")
    end
  end

  def test_query_invalid_region_message
    HTS::Tabix.open(@vcf_gz) do |tbx|
      ex = expect_raises(HTS::Tabix::QueryError) do
        tbx.query("unknown:1-10") { |_| }
      end
      (ex.message.to_s).should contain("unknown:1-10")
      (ex.message.to_s).should contain(@vcf_gz)
    end
  end

  def test_query_invalid_chrom_message
    HTS::Tabix.open(@vcf_gz) do |tbx|
      ex = expect_raises(ArgumentError) do
        tbx.query("unknown", 0, 10) { |_| }
      end
      (ex.message.to_s).should contain("Unknown reference name")
      (ex.message.to_s).should contain(@vcf_gz)
    end
  end

  def test_query_negative_start
    HTS::Tabix.open(@vcf_gz) do |tbx|
      ex = expect_raises(ArgumentError) do
        tbx.query("poo", -1, 10) { |_| }
      end
      (ex.message.to_s).should contain("must be >= 0")
    end
  end

  # ── build_index ───────────────────────────────────────────────────────────

  def test_build_index_class_method
    # build_index creates a .tbi file next to the input
    tbi = "#{@vcf_gz}.tbi"
    (File.exists?(tbi)).should be_true
  end

  def test_build_index_rejects_plain_text
    plain = File.tempfile("tbx_plain", ".vcf")
    path = plain.path || raise "tempfile path is nil"
    begin
      VCF_LINES.each { |line| plain.puts(line) }
      plain.close

      expect_raises(HTS::Tabix::IndexError) do
        HTS::Tabix.build_index(path, verbose: false)
      end
    ensure
      plain.close rescue nil
      File.delete(path) if File.exists?(path)
      File.delete("#{path}.tbi") if File.exists?("#{path}.tbi")
    end
  end

  def test_build_index_with_bed_preset
    bed_gz = File.tempfile("tbx_bed", ".bed.gz")
    path = bed_gz.path
    bed_gz.close

    begin
      HTS::Bgzf.open(path, "wz") do |bgzf|
        BED_LINES.each { |line| bgzf.puts(line) }
      end

      HTS::Tabix.build_index(path, verbose: false, preset: :bed)

      HTS::Tabix.open(path) do |tbx|
        results = [] of Array(String)
        tbx.query("chr1:50-60") { |feature| results << feature }

        (results).should eq([["chr1", "0", "100", "wide"]])
      end
    ensure
      File.delete(path) if File.exists?(path)
      File.delete("#{path}.tbi") if File.exists?("#{path}.tbi")
    end
  end

  def test_build_index_rejects_unknown_preset
    expect_raises(ArgumentError, /Unsupported tabix preset/) do
      HTS::Tabix.build_index(@vcf_gz, verbose: false, preset: :unknown)
    end
  end
end

describe TabixTest do
  {% for method in TabixTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = TabixTest.new
        spec_case.setup
      begin
        spec_case.{{ method.name.id }}
      ensure
        spec_case.teardown
      end
    end
  {% end %}
end
