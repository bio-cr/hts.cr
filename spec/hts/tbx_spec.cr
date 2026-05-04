require "../spec_helper"
require "../../src/hts/tabix"

class TabixTest < HTSSpecCase
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
      expect_false tbx.closed?
    end
  end

  def test_index_loaded
    HTS::Tabix.open(@vcf_gz) do |tbx|
      expect_true tbx.index_loaded?
    end
  end

  def test_seqnames
    HTS::Tabix.open(@vcf_gz) do |tbx|
      expect_equal ["poo"], tbx.seqnames
    end
  end

  def test_name2id_known
    HTS::Tabix.open(@vcf_gz) do |tbx|
      expect_equal 0, tbx.name2id("poo")
    end
  end

  def test_name2id_unknown
    HTS::Tabix.open(@vcf_gz) do |tbx|
      expect_equal -1, tbx.name2id("nonexistent")
    end
  end

  def test_seqnames_requires_index
    without_index do |tbx|
      ex = expect_raises(HTS::Tabix::MissingIndexError) { tbx.seqnames }
      expect_includes ex.message, @vcf_gz
      expect_includes ex.message, "seqnames requires an index"
    end
  end

  def test_name2id_requires_index
    without_index do |tbx|
      ex = expect_raises(HTS::Tabix::MissingIndexError) { tbx.name2id("poo") }
      expect_includes ex.message, @vcf_gz
      expect_includes ex.message, "name2id requires an index"
    end
  end

  # "poo:150-250" (1-based inclusive) → POS=200 only
  def test_query_string_single_record
    HTS::Tabix.open(@vcf_gz) do |tbx|
      results = [] of Array(String)
      tbx.query("poo:150-250") { |f| results << f }
      expect_equal 1, results.size
      expect_equal "200", results[0][1]
    end
  end

  # "poo:100-300" → POS=100, 200, 300
  def test_query_string_multiple_records
    HTS::Tabix.open(@vcf_gz) do |tbx|
      results = [] of Array(String)
      tbx.query("poo:100-300") { |f| results << f }
      expect_equal 3, results.size
    end
  end

  # htslib parser accepts commas in region coordinates.
  def test_query_string_with_commas
    HTS::Tabix.open(@vcf_gz) do |tbx|
      results = [] of Array(String)
      tbx.query("poo:1-3,00") { |f| results << f }
      expect_equal 3, results.size
    end
  end

  # whole-chromosome query "poo" → all 5 data records
  def test_query_string_whole_chromosome
    HTS::Tabix.open(@vcf_gz) do |tbx|
      results = [] of Array(String)
      tbx.query("poo") { |f| results << f }
      expect_equal 5, results.size
    end
  end

  # query("poo", 149, 201) → 0-based [149,201) covers 1-based POS=200 only
  def test_query_numeric_single_record
    HTS::Tabix.open(@vcf_gz) do |tbx|
      results = [] of Array(String)
      tbx.query("poo", 149, 201) { |f| results << f }
      expect_equal 1, results.size
      expect_equal "200", results[0][1]
    end
  end

  # query("poo", 99, 299) → 0-based [99,299) covers 1-based POS=100, 200 (POS=300 at 0-based 299 is excluded)
  def test_query_numeric_two_records
    HTS::Tabix.open(@vcf_gz) do |tbx|
      results = [] of Array(String)
      tbx.query("poo", 99, 299) { |f| results << f }
      expect_equal 2, results.size
    end
  end

  def test_query_fields
    HTS::Tabix.open(@vcf_gz) do |tbx|
      tbx.query("poo:100-100") do |fields|
        expect_equal "poo", fields[0]
        expect_equal "100", fields[1]
        expect_equal "A", fields[3]
        expect_equal "T", fields[4]
      end
    end
  end

  def test_query_requires_index
    without_index do |tbx|
      ex = expect_raises(HTS::Tabix::MissingIndexError) do
        tbx.query("poo:100-100") { |_| }
      end
      expect_includes ex.message, @vcf_gz
      expect_includes ex.message, "query requires an index"
    end
  end

  def test_query_invalid_region_message
    HTS::Tabix.open(@vcf_gz) do |tbx|
      ex = expect_raises(HTS::Tabix::QueryError) do
        tbx.query("unknown:1-10") { |_| }
      end
      expect_includes ex.message, "unknown:1-10"
      expect_includes ex.message, @vcf_gz
    end
  end

  def test_query_invalid_chrom_message
    HTS::Tabix.open(@vcf_gz) do |tbx|
      ex = expect_raises(ArgumentError) do
        tbx.query("unknown", 0, 10) { |_| }
      end
      expect_includes ex.message, "Unknown reference name"
      expect_includes ex.message, @vcf_gz
    end
  end

  def test_query_negative_start
    HTS::Tabix.open(@vcf_gz) do |tbx|
      ex = expect_raises(ArgumentError) do
        tbx.query("poo", -1, 10) { |_| }
      end
      expect_includes ex.message, "must be >= 0"
    end
  end

  # ── build_index ───────────────────────────────────────────────────────────

  def test_build_index_class_method
    # build_index creates a .tbi file next to the input
    tbi = "#{@vcf_gz}.tbi"
    expect_true File.exists?(tbi)
  end
end

describe TabixTest do
  {% for method in TabixTest.methods.select { |method| method.name.stringify.starts_with?("test_") } %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = TabixTest.new
      run_spec_case(spec_case) do
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
