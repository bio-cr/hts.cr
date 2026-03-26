require "minitest/autorun"
require "../../src/hts/bcf"

class BcfTest < Minitest::Test
  def teardown
    @bcf.try &.close
    @indexed_bcf.try &.close
    cleanup_index_files
  end

  private def cleanup_index_files
    index_files = [test_bcf_index_path]

    index_files.each do |file|
      File.delete(file) if File.exists?(file)
    end
  end

  def test_bcf_path
    File.expand_path("../fixtures/test.bcf", __DIR__)
  end

  def test_bcf_index_path
    File.expand_path("../fixtures/test.bcf.csi.tmp", __DIR__)
  end

  def bcf
    @bcf ||= HTS::Bcf.new(test_bcf_path)
  end

  def indexed_bcf : HTS::Bcf
    if indexed_bcf = @indexed_bcf
      indexed_bcf
    else
      HTS::Bcf.build_index(test_bcf_path, test_bcf_index_path, 14, 0, false)
      @indexed_bcf = HTS::Bcf.new(test_bcf_path, "r", test_bcf_index_path)
      @indexed_bcf.not_nil!
    end
  end

  def test_new
    b = HTS::Bcf.new(test_bcf_path)
    assert_instance_of HTS::Bcf, b
    b.close
    assert_equal true, b.closed?
  end

  # def test_new_with_block
  #   assert_raises do
  #     HTS::Bcf.new(test_bcf_path) {}
  #   end
  # end

  def test_open
    b = HTS::Bcf.open(test_bcf_path)
    assert_instance_of HTS::Bcf, b
    b.close
    assert_equal true, b.closed?
  end

  def test_open_with_block
    f = HTS::Bcf.open(test_bcf_path) do |b|
      assert_instance_of HTS::Bcf, b
    end
    assert_equal true, f.closed?
  end

  def test_file_name
    assert_equal test_bcf_path, bcf.file_name
  end

  def test_header
    assert_instance_of HTS::Bcf::Header, bcf.header
  end

  def test_mode
    assert_equal "r", bcf.mode
  end

  def test_file_format
    assert_equal "Bcf", bcf.file_format
  end

  def test_file_format_version
    assert_equal "2.2", bcf.file_format_version
  end

  def test_nsamples
    assert_equal 1, bcf.nsamples
  end

  def test_samples
    assert_equal ["poo.sort.bam"], bcf.samples
  end

  def test_initialize_no_file_bcf
    assert_raises { HTS::Bcf.new("/tmp/no_such_file") }
  end

  def test_query_requires_index
    ex = assert_raises(HTS::Bcf::MissingIndexError) do
      bcf.query("poo:4000-4100") { |_| }
    end
    assert_includes ex.message, test_bcf_path
    assert_includes ex.message, "Query requires an index"
  end

  def test_query_region
    positions = [] of Int64
    indexed_bcf.query("poo:4000-4500") do |record|
      positions << record.pos
    end
    assert_equal [4020, 4309, 4336], positions
  end

  def test_query_region_copy
    positions = [] of Int64
    indexed_bcf.query("poo:4000-4500", copy: true) do |record|
      positions << record.pos
    end
    assert_equal [4020, 4309, 4336], positions
  end

  def test_query_tid_numeric
    positions = [] of Int64
    tid = indexed_bcf.header.get_tid("poo")
    indexed_bcf.query(tid, 3999_i64, 4500_i64) do |record|
      positions << record.pos
    end
    assert_equal [4020, 4309, 4336], positions
  end

  def test_query_chrom_numeric
    positions = [] of Int64
    indexed_bcf.query("poo", 4000_i64, 4500_i64) do |record|
      positions << record.pos
    end
    assert_equal [4020, 4309, 4336], positions
  end

  def test_query_multi_regions
    positions = [] of Int64
    indexed_bcf.query(["poo:4000-4100", "poo:4300-4400"]) do |record|
      positions << record.pos
    end
    assert_equal [4020, 4309, 4336], positions
  end

  def test_query_multi_regions_copy
    positions = [] of Int64
    indexed_bcf.query(["poo:4000-4100", "poo:4300-4400"], copy: true) do |record|
      positions << record.pos
    end
    assert_equal [4020, 4309, 4336], positions
  end

  def test_query_invalid_region_message
    ex = assert_raises(HTS::Bcf::QueryError) do
      indexed_bcf.query("unknown:1-10") { |_| }
    end
    assert_includes ex.message, "unknown:1-10"
    assert_includes ex.message, test_bcf_path
  end

  def test_query_invalid_chrom_message
    ex = assert_raises(ArgumentError) do
      indexed_bcf.query("unknown", 1_i64, 10_i64) { |_| }
    end
    assert_includes ex.message, "Unknown reference name"
    assert_includes ex.message, test_bcf_path
  end

  def test_each
    bcf.each do |record|
      assert_instance_of HTS::Bcf::Record, record
    end
  end

  def test_each_copy
    bcf.each(copy: true) do |record|
      assert_instance_of HTS::Bcf::Record, record
    end
  end

  def test_chrom
    act = bcf.chrom
    exp = bcf.map(&.chrom)
    assert_equal exp, act
  end

  def test_pos
    act = bcf.pos
    exp = bcf.map(&.pos)
    assert_equal exp, act
  end

  def test_endpos
    act = bcf.endpos
    exp = bcf.map(&.endpos)
    assert_equal exp, act
  end

  def test_id
    act = bcf.id
    exp = bcf.map(&.id)
    assert_equal exp, act
  end

  def test_ref
    act = bcf.ref
    exp = bcf.map(&.ref)
    assert_equal exp, act
  end

  def test_alt
    act = bcf.alt
    exp = bcf.map(&.alt)
    assert_equal exp, act
  end

  def test_qual
    act = bcf.qual
    exp = bcf.map(&.qual)
    assert_equal exp, act
  end

  def test_filter
    act = bcf.filter
    exp = bcf.map(&.filter)
    assert_equal exp, act
  end
end
