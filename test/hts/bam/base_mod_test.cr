require "minitest/autorun"
require "../../../src/hts/bam"

# Test BaseMod API with a generated BAM file containing MM/ML tags
class BamBaseModGenerateTest < Minitest::Test
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
        Dir.glob(File.join(tmp, "*")).each { |f| File.delete(f) rescue nil }
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
    unless have_samtools?
      puts "[INFO] samtools not found; skipping base_mod generation test"
      return
    end
  end

  private def create_and_parse_base_mod : HTS::Bam::BaseMod
    bam_path = create_test_bam_with_modifications
    verify_tags_preserved_in_bam(bam_path)

    @bam = HTS::Bam.open(bam_path)
    record = @bam.not_nil!.first? || raise "No record in BAM"

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
    assert_includes text, "MM:Z:C+m,0,2;A+a,2;"
    assert_includes text, "ML:B:C,200,150,180"
  end

  private def verify_modification_positions(base_mod : HTS::Bam::BaseMod)
    positions = base_mod.to_a.map(&.position).sort
    assert_equal [1, 8, 13], positions
  end

  private def verify_modification_types(base_mod : HTS::Bam::BaseMod)
    types = base_mod.recorded_types
    assert types.includes?('m'.ord)
    assert types.includes?('a'.ord)

    qt_m = base_mod.query_type('m'.ord)
    qt_a = base_mod.query_type('a'.ord)

    assert_equal "C", qt_m.not_nil![:canonical]
    assert_equal "A", qt_a.not_nil![:canonical]
  end

  private def verify_modification_qualities(base_mod : HTS::Bam::BaseMod)
    qualities = base_mod.to_a.flat_map { |p| p.modifications.map(&.qual) }.sort
    assert_equal [150, 180, 200], qualities
  end

  private def have_samtools? : Bool
    Process.run("bash", ["-lc", "command -v samtools >/dev/null 2>&1"]).success?
  end
end

# Test BaseMod API with remote SAM file containing ChEBI modification codes
class BamBaseModChebiIntegrationTest < Minitest::Test
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

    assert types.includes?('m'.ord)
    assert types.includes?(-76_792) # ChEBI ID
    assert types.includes?('n'.ord)
  end

  private def verify_chebi_modification_positions(base_mod : HTS::Bam::BaseMod)
    modifications = base_mod.to_a

    total_count = modifications.sum { |p| p.modifications.size }
    assert_equal 8, total_count

    positions = modifications.map(&.position).uniq.sort
    assert_equal [6, 15, 17, 19, 20, 31, 34], positions
  end

  private def verify_chebi_position_specific_modifications(base_mod : HTS::Bam::BaseMod)
    position_codes = build_position_to_codes_map(base_mod)

    # Positions with 'm' modification
    [6, 17, 20, 31, 34].each do |pos|
      assert position_codes[pos].includes?('m'.ord)
    end

    # Positions with ChEBI modification
    [19, 34].each do |pos|
      assert position_codes[pos].includes?(-76_792)
    end

    # Position with 'n' modification
    assert position_codes[15].includes?('n'.ord)
  end

  private def verify_chebi_type_metadata(base_mod : HTS::Bam::BaseMod)
    metadata_m = base_mod.query_type('m'.ord) || raise "Missing 'm' metadata"
    metadata_n = base_mod.query_type('n'.ord) || raise "Missing 'n' metadata"
    metadata_chebi = base_mod.query_type(-76_792) || raise "Missing ChEBI metadata"

    assert_equal "C", metadata_m[:canonical]
    assert_equal "N", metadata_n[:canonical]
    assert_equal "C", metadata_chebi[:canonical]

    [metadata_m, metadata_n, metadata_chebi].each do |metadata|
      refute_nil metadata[:strand]
      refute_nil metadata[:implicit]
    end
  end

  private def build_position_to_codes_map(base_mod : HTS::Bam::BaseMod)
    position_codes = Hash(Int32, Array(Int32)).new { |h, k| h[k] = [] of Int32 }

    base_mod.each do |position|
      position.modifications.each do |mod|
        position_codes[position.position] << mod.modified_base
      end
    end

    position_codes
  end
end
