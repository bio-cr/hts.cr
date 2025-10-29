require "minitest/autorun"
require "../../../src/hts/bam"

# Generate a tiny BAM with MM/ML (base modification) tags and read it back.
# If samtools isn't available, the test returns early.
class BamBaseModGenerateTest < Minitest::Test
  @tmpdir : String?

  def setup
    # Create a unique temporary directory without relying on Dir.mktmpdir (not available in this Crystal version)
    tmp = File.join(Dir.tempdir, "base_mod_test_#{Time.utc.to_unix_ns}_#{Process.pid}")
    Dir.mkdir_p(tmp)
    @tmpdir = tmp
    @bam = nil
  end

  def teardown
    @bam.try &.close
    if tmp = @tmpdir
      begin
        Dir.glob(File.join(tmp, "*")).each do |f|
          begin
            File.delete(f)
          rescue
          end
        end
        Dir.delete(tmp)
      rescue
      end
    end
  end

  def test_generate_and_read_bam_with_base_mod_tags
    unless have_samtools?
      puts "[INFO] samtools not found; skipping base_mod generation test"
      return
    end

    tmp = @tmpdir || raise "tmpdir not set"
    sam_path = File.join(tmp, "mods.sam")
    bam_path = File.join(tmp, "mods.bam")

    # Minimal SAM with MM/ML; ML length matches total modified bases (3).
    # Sequence: ACGT ACGT ACGT ACGT ACGT (20bp)
    # C positions (0-based): 1,5,9,13,17  -> C+m at 1 and 9 (deltas: 0,2)
    # A positions (0-based): 0,4,8,12,16  -> A+a at 8        (delta: 2)
    sam = <<-SAM
  @HD\tVN:1.6\tSO:unknown
  @SQ\tSN:ref\tLN:1000
  r1\t0\tref\t1\t60\t20M\t*\t0\t0\tACGTACGTACGTACGTACGT\t*\tMM:Z:C+m,0,2;A+a,2;\tML:B:C,200,150,180
  SAM
    File.write(sam_path, sam)

    st = Process.run("samtools", ["view", "-b", "-o", bam_path, sam_path], output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)
    assert st.success?, "samtools view failed"

    @bam = HTS::Bam.open(bam_path)
    bam = @bam || raise "bam not opened"
    alns = bam.to_a
    assert_equal 1, alns.size

    # Confirm tags are preserved in BAM using samtools (temporary check until direct API is used)
    out_io = IO::Memory.new
    st2 = Process.run("samtools", ["view", "-h", bam_path], output: out_io, error: Process::Redirect::Inherit)
    assert st2.success?, "samtools view -h failed"
    text = out_io.to_s
    assert_includes text, "MM:Z:C+m,0,2;A+a,2;"
    assert_includes text, "ML:B:C,200,150,180"

    # Exercise BaseMod API: parse and validate positions/types/probabilities
    rec = alns.first?
    raise "no record" unless rec

    bm = HTS::Bam::BaseMod.new(rec.not_nil!)
    bm.parse

    # Collect once to avoid re-iterating internal state
    mods = bm.to_a
    # positions with modifications should be {1, 8, 13}
    positions = mods.map(&.position).sort
    assert_equal [1, 8, 13], positions

    # recorded types should include 'm' (C modifications) and 'a' (A modifications)
    types = bm.recorded_types
    assert types.includes?('m'.ord), "expected 'm' in recorded types"
    assert types.includes?('a'.ord), "expected 'a' in recorded types"

    # query type metadata
    qt_m = bm.query_type('m'.ord)
    qt_a = bm.query_type('a'.ord)
    assert qt_m && qt_m[:canonical] == "C"
    assert qt_a && qt_a[:canonical] == "A"

    # collect quals and compare multiset (order by qpos may vary across types)
    quals = mods.flat_map { |p| p.modifications.map(&.qual) }.sort
    assert_equal [150, 180, 200].sort, quals
  end

  private def have_samtools? : Bool
    Process.run("bash", ["-lc", "command -v samtools >/dev/null 2>&1"]).success?
  end
end

# Integration test: open MM-chebi.sam directly via HTTPS URL using htslib's remote I/O
# and verify BaseMod parsing behavior without local downloads or samtools.
class BamBaseModChebiIntegrationTest < Minitest::Test
  MM_CHEBI_URL = "https://raw.githubusercontent.com/samtools/htslib/refs/heads/develop/test/base_mods/MM-chebi.sam"

  def test_mm_chebi_remote_sam_integration
    bam = HTS::Bam.new(MM_CHEBI_URL)
    begin
      rec = bam.first?
      assert rec, "No record found in MM-chebi.sam"

      bm = HTS::Bam::BaseMod.new(rec.not_nil!)
      bm.parse

      types = bm.recorded_types
      assert types.includes?('m'.ord), "expected 'm' in recorded types"
      assert types.includes?(-76_792), "expected ChEBI:-76792 in recorded types"
      assert types.includes?('n'.ord), "expected 'n' in recorded types"

      mods = bm.to_a
      total = mods.sum { |p| p.modifications.size }
      assert_equal 8, total

      expected_positions = [6, 15, 17, 19, 20, 31, 34].sort
      got_positions = mods.map(&.position).uniq.sort
      assert_equal expected_positions, got_positions

      pos_to_codes = Hash(Int32, Array(Int32)).new { |h, k| h[k] = [] of Int32 }
      mods.each do |p|
        pos_to_codes[p.position].concat p.modifications.map(&.modified_base)
      end

      [6, 17, 20, 31, 34].each do |q|
        assert pos_to_codes[q].any? { |c| c == 'm'.ord }, "pos #{q} should have 'm'"
      end

      [19, 34].each do |q|
        assert pos_to_codes[q].any? { |c| c == -76_792 }, "pos #{q} should have -76792"
      end

      assert pos_to_codes[15].any? { |c| c == 'n'.ord }, "pos 15 should have 'n'"

      qt_m = bm.query_type('m'.ord)
      qt_n = bm.query_type('n'.ord)
      qt_chebi = bm.query_type(-76_792)

      assert qt_m, "query_type('m') returned nil"
      assert qt_n, "query_type('n') returned nil"
      assert qt_chebi, "query_type(ChEBI) returned nil"

      assert_equal "C", qt_m.not_nil![:canonical]
      assert_equal "N", qt_n.not_nil![:canonical]
      assert_equal "C", qt_chebi.not_nil![:canonical]

      [:strand, :implicit].each do |k|
        refute_nil qt_m.not_nil![k]
        refute_nil qt_n.not_nil![k]
        refute_nil qt_chebi.not_nil![k]
      end
    ensure
      bam.close
    end
  end
end
