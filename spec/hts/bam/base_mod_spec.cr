require "../../spec_helper"
require "../../../src/hts/bam"

# Test BaseMod API with a generated BAM file containing MM/ML tags
class BamBaseModGenerateTest
  @tmpdir : String?
  @bam : HTS::Bam?

  def setup
    tmp = File.join(Dir.tempdir, "base_mod_test_#{Time.utc.to_unix_ns}_#{Process.pid}")
    Dir.mkdir_p(tmp)
    @tmpdir = tmp
  end

  def teardown
    @bam.try &.close
    if tmp = @tmpdir
      begin
        Dir.glob(File.join(tmp, "*")).each { |file| File.delete(file) rescue nil }
        Dir.delete(tmp)
      rescue
      end
    end
  end

  def test_base_mod_api_with_generated_bam
    skip_unless_samtools_available

    base_mod = create_and_parse_base_mod

    verify_modification_positions(base_mod)
    verify_modification_types(base_mod)
    verify_modification_qualities(base_mod)
  end

  private def skip_unless_samtools_available
    pending! "samtools not found" unless have_samtools?
  end

  private def create_and_parse_base_mod : HTS::Bam::BaseMod
    bam_path = create_test_bam_with_modifications
    verify_tags_preserved_in_bam(bam_path)

    bam = HTS::Bam.open(bam_path)
    @bam = bam
    record = bam.first? || raise "No record in BAM"

    base_mod = HTS::Bam::BaseMod.new(record)
    base_mod.parse
    base_mod
  end

  private def create_test_bam_with_modifications : String
    tmp = @tmpdir || raise "tmpdir not set"
    sam_path = File.join(tmp, "mods.sam")
    bam_path = File.join(tmp, "mods.bam")

    # Sequence: ACGTACGTACGTACGTACGT (20bp)
    # C positions (0-based): 1,5,9,13,17  -> C+m at positions 1,9 (skip deltas: 0,2)
    # A positions (0-based): 0,4,8,12,16  -> A+a at position 8 (skip delta: 2)
    # ML has 3 values for the 3 modifications total
    sam_content = <<-SAM
      @HD\tVN:1.6\tSO:unknown
      @SQ\tSN:ref\tLN:1000
      r1\t0\tref\t1\t60\t20M\t*\t0\t0\tACGTACGTACGTACGTACGT\t*\tMM:Z:C+m,0,2;A+a,2;\tML:B:C,200,150,180
      SAM

    File.write(sam_path, sam_content)

    result = Process.run("samtools", ["view", "-b", "-o", bam_path, sam_path],
      output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)
    raise "samtools conversion failed" unless result.success?

    bam_path
  end

  private def verify_tags_preserved_in_bam(bam_path : String)
    output = IO::Memory.new
    result = Process.run("samtools", ["view", "-h", bam_path],
      output: output, error: Process::Redirect::Inherit)
    raise "samtools view failed" unless result.success?

    text = output.to_s
    (text).should contain("MM:Z:C+m,0,2;A+a,2;")
    (text).should contain("ML:B:C,200,150,180")
  end

  private def verify_modification_positions(base_mod : HTS::Bam::BaseMod)
    positions = base_mod.to_a.map(&.position).sort!
    (positions).should eq([1, 8, 13])
  end

  private def verify_modification_types(base_mod : HTS::Bam::BaseMod)
    types = base_mod.recorded_types
    (types.includes?('m'.ord)).should be_true
    (types.includes?('a'.ord)).should be_true

    qt_m = base_mod.query_type('m'.ord) || raise "Missing 'm' metadata"
    qt_a = base_mod.query_type('a'.ord) || raise "Missing 'a' metadata"
    qt_m_char = base_mod.query_type('m') || raise "Missing 'm' metadata"

    (qt_m[:canonical]).should eq("C")
    (qt_a[:canonical]).should eq("A")
    (qt_m_char[:canonical]).should eq("C")
  end

  private def verify_modification_qualities(base_mod : HTS::Bam::BaseMod)
    qualities = base_mod.to_a.flat_map { |position| position.modifications.map(&.qual) }.sort!
    (qualities).should eq([150, 180, 200])
  end

  private def have_samtools? : Bool
    Process.run("bash", ["-lc", "command -v samtools >/dev/null 2>&1"]).success?
  end
end

# Test BaseMod API with remote SAM file containing ChEBI modification codes
class BamBaseModChebiIntegrationTest
  MM_CHEBI_URL = "https://raw.githubusercontent.com/samtools/htslib/refs/heads/develop/test/base_mods/MM-chebi.sam"

  def test_chebi_modification_types
    bam = HTS::Bam.new(MM_CHEBI_URL)
    record = bam.first? || raise "No record found"
    base_mod = HTS::Bam::BaseMod.new(record)
    base_mod.parse

    verify_chebi_modification_types(base_mod)
  ensure
    bam.try &.close
  end

  def test_chebi_modification_positions
    bam = HTS::Bam.new(MM_CHEBI_URL)
    record = bam.first? || raise "No record found"
    base_mod = HTS::Bam::BaseMod.new(record)
    base_mod.parse

    verify_chebi_modification_positions(base_mod)
  ensure
    bam.try &.close
  end

  def test_chebi_position_specific_modifications
    bam = HTS::Bam.new(MM_CHEBI_URL)
    record = bam.first? || raise "No record found"
    base_mod = HTS::Bam::BaseMod.new(record)
    base_mod.parse

    verify_chebi_position_specific_modifications(base_mod)
  ensure
    bam.try &.close
  end

  def test_chebi_type_metadata
    bam = HTS::Bam.new(MM_CHEBI_URL)
    record = bam.first? || raise "No record found"
    base_mod = HTS::Bam::BaseMod.new(record)
    base_mod.parse

    verify_chebi_type_metadata(base_mod)
  ensure
    bam.try &.close
  end

  private def verify_chebi_modification_types(base_mod : HTS::Bam::BaseMod)
    types = base_mod.recorded_types

    (types.includes?('m'.ord)).should be_true
    types.includes?(-76_792).should be_true # ChEBI ID
    (types.includes?('n'.ord)).should be_true
  end

  private def verify_chebi_modification_positions(base_mod : HTS::Bam::BaseMod)
    modifications = base_mod.to_a

    total_count = modifications.sum(&.modifications.size)
    (total_count).should eq(8)

    positions = modifications.map(&.position).uniq!.sort!
    (positions).should eq([6, 15, 17, 19, 20, 31, 34])
  end

  private def verify_chebi_position_specific_modifications(base_mod : HTS::Bam::BaseMod)
    position_codes = build_position_to_codes_map(base_mod)

    # Positions with 'm' modification
    [6, 17, 20, 31, 34].each do |pos|
      (position_codes[pos].includes?('m'.ord)).should be_true
    end

    # Positions with ChEBI modification
    [19, 34].each do |pos|
      (position_codes[pos].includes?(-76_792)).should be_true
    end

    # Position with 'n' modification
    (position_codes[15].includes?('n'.ord)).should be_true
  end

  private def verify_chebi_type_metadata(base_mod : HTS::Bam::BaseMod)
    metadata_m = base_mod.query_type('m'.ord) || raise "Missing 'm' metadata"
    metadata_n = base_mod.query_type('n'.ord) || raise "Missing 'n' metadata"
    metadata_chebi = base_mod.query_type(-76_792) || raise "Missing ChEBI metadata"

    (metadata_m[:canonical]).should eq("C")
    (metadata_n[:canonical]).should eq("N")
    (metadata_chebi[:canonical]).should eq("C")

    [metadata_m, metadata_n, metadata_chebi].each do |metadata|
      (metadata[:strand]).should_not be_nil
      (metadata[:implicit]).should_not be_nil
    end
  end

  private def build_position_to_codes_map(base_mod : HTS::Bam::BaseMod)
    position_codes = Hash(Int32, Array(Int32)).new { |hash, key| hash[key] = [] of Int32 }

    base_mod.each do |position|
      position.modifications.each do |mod|
        position_codes[position.position] << mod.modified_base
      end
    end

    position_codes
  end
end

describe BamBaseModGenerateTest do
  {% for method in BamBaseModGenerateTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BamBaseModGenerateTest.new
        spec_case.setup
      begin
        spec_case.{{ method.name.id }}
      ensure
        spec_case.teardown
      end
    end
  {% end %}
end

describe BamBaseModChebiIntegrationTest do
  {% for method in BamBaseModChebiIntegrationTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BamBaseModChebiIntegrationTest.new
      begin
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end

describe HTS::Bam::BaseMod do
  it "rejects non-positive at_pos buffer sizes before parsing" do
    bam = HTS::Bam.open(File.expand_path("../../fixtures/moo.bam", __DIR__))
    record = bam.first? || raise "No record in BAM"
    base_mod = HTS::Bam::BaseMod.new(record, auto_parse: false)

    expect_raises(ArgumentError, "max_mods must be positive") { base_mod.at_pos(0, max_mods: 0) }
    expect_raises(ArgumentError, "max_mods must be positive") { base_mod.at_pos(0, max_mods: -1) }
  ensure
    base_mod.try &.close
    bam.try &.close
  end

  it "returns all modifications when a position has more modifications than the buffer" do
    file = File.tempfile("base_mod_many_mods", ".sam")
    path = file.path || raise "tempfile path is nil"
    qualities = (11..21).to_a
    codes = "abcdefghijk"

    begin
      file << "@HD\tVN:1.6\tSO:unknown\n"
      file << "@SQ\tSN:ref\tLN:1000\n"
      file << "r1\t0\tref\t1\t60\t1M\t*\t0\t0\tC\t*\tMM:Z:C+#{codes},0;\tML:B:C,#{qualities.join(",")}\n"
      file.close

      HTS::Bam.open(path) do |bam|
        record = bam.first? || raise "No record in SAM"
        base_mod = HTS::Bam::BaseMod.new(record)

        at_pos = base_mod.at_pos(0, max_mods: 10) || raise "Missing base modifications at position 0"
        (at_pos.position).should eq(0)
        (at_pos.modifications.map(&.code)).should eq(codes.chars.map(&.to_s))
        (at_pos.modifications.map(&.qual)).should eq(qualities)

        positions = base_mod.to_a
        (positions.size).should eq(1)
        (positions[0].position).should eq(0)
        (positions[0].modifications.map(&.code)).should eq(codes.chars.map(&.to_s))
        (positions[0].modifications.map(&.qual)).should eq(qualities)

        raw = [] of Tuple(Int32, Int32, Int32, Int32, Int32)
        returned = base_mod.each_raw(max_mods: 10) do |position, canonical_base, modified_base, strand, qual|
          raw << {position, canonical_base, modified_base, strand, qual}
        end
        returned.should be(base_mod)
        raw.map(&.[0]).should eq([0] * codes.size)
        raw.map(&.[1]).should eq(['C'.ord] * codes.size)
        raw.map(&.[2]).should eq(codes.chars.map(&.ord))
        raw.map(&.[3]).should eq([0] * codes.size)
        raw.map(&.[4]).should eq(qualities)

        record_raw = [] of Tuple(Int32, Int32, Int32, Int32, Int32)
        record.each_base_mod_raw(max_mods: 10) do |position, canonical_base, modified_base, strand, qual|
          record_raw << {position, canonical_base, modified_base, strand, qual}
        end.should be(record)
        record_raw.should eq(raw)
      end
    ensure
      file.close unless file.closed?
      File.delete(path) if File.exists?(path)
    end
  end

  it "raises when queried after close" do
    bam = HTS::Bam.open(File.expand_path("../../fixtures/moo.bam", __DIR__))
    record = bam.first? || raise "No record in BAM"
    base_mod = HTS::Bam::BaseMod.new(record)
    base_mod.close

    expect_raises(HTS::Bam::BaseMod::Error, "BaseMod is closed") { base_mod.parse }
    expect_raises(HTS::Bam::BaseMod::Error, "BaseMod is closed") { base_mod.each { } }
    expect_raises(HTS::Bam::BaseMod::Error, "BaseMod is closed") { base_mod.at_pos(0) }
    expect_raises(HTS::Bam::BaseMod::Error, "BaseMod is closed") { base_mod.modification_types }
    expect_raises(HTS::Bam::BaseMod::Error, "BaseMod is closed") { base_mod.query_type("m") }
  ensure
    base_mod.try &.close
    bam.try &.close
  end

  it "rejects multi-character query type strings" do
    bam = HTS::Bam.open(File.expand_path("../../fixtures/moo.bam", __DIR__))
    record = bam.first? || raise "No record in BAM"
    base_mod = HTS::Bam::BaseMod.new(record)

    error = expect_raises(ArgumentError) { base_mod.query_type("mm") }
    (error.message).should eq("modification code string must contain exactly one character")
  ensure
    base_mod.try &.close
    bam.try &.close
  end
end
