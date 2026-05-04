require "../spec_helper"
require "../../src/hts/bcf"

class BcfTest < HTSSpecCase
  include TestBcfMultisampleHelper

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
      if indexed_bcf = @indexed_bcf
        indexed_bcf
      else
        raise "indexed_bcf was not initialized"
      end
    end
  end

  def test_new
    b = HTS::Bcf.new(test_bcf_path)
    expect_instance_of HTS::Bcf, b
    b.close
    expect_equal true, b.closed?
  end

  # def test_new_with_block
  #   expect_raises do
  #     HTS::Bcf.new(test_bcf_path) {}
  #   end
  # end

  def test_open
    b = HTS::Bcf.open(test_bcf_path)
    expect_instance_of HTS::Bcf, b
    b.close
    expect_equal true, b.closed?
  end

  def test_open_with_block
    f = HTS::Bcf.open(test_bcf_path) do |b|
      expect_instance_of HTS::Bcf, b
    end
    expect_equal true, f.closed?
  end

  def test_file_name
    expect_equal test_bcf_path, bcf.file_name
  end

  def test_header
    expect_instance_of HTS::Bcf::Header, bcf.header
  end

  def test_mode
    expect_equal "r", bcf.mode
  end

  def test_file_format
    expect_equal "Bcf", bcf.file_format
  end

  def test_file_format_version
    expect_equal "2.2", bcf.file_format_version
  end

  def test_nsamples
    expect_equal 1, bcf.nsamples
  end

  def test_samples
    expect_equal ["poo.sort.bam"], bcf.samples
  end

  def test_initialize_no_file_bcf
    expect_raises(HTS::Bcf::OpenError) { HTS::Bcf.new("/tmp/no_such_file") }
  end

  def test_initialize_with_subset
    with_temp_multisample_bcf do |path|
      subset_bcf = HTS::Bcf.new(path, subset: ["B"])

      expect_equal ["B"], subset_bcf.samples
      expect_equal 1, subset_bcf.nsamples
      expect_equal ["0/1"], subset_bcf.first.format.get_string("GT")
    ensure
      subset_bcf.try &.close
    end
  end

  def test_query_requires_index
    ex = expect_raises(HTS::Bcf::MissingIndexError) do
      bcf.query("poo:4000-4100") { |_| }
    end
    expect_includes ex.message, test_bcf_path
    expect_includes ex.message, "Query requires an index"
  end

  def test_query_region
    positions = [] of Int64
    indexed_bcf.query("poo:4000-4500") do |record|
      positions << record.pos
    end
    expect_equal [4020, 4309, 4336], positions
  end

  def test_query_region_copy
    positions = [] of Int64
    indexed_bcf.query("poo:4000-4500", copy: true) do |record|
      positions << record.pos
    end
    expect_equal [4020, 4309, 4336], positions
  end

  def test_query_tid_numeric
    positions = [] of Int64
    tid = indexed_bcf.header.get_tid("poo")
    indexed_bcf.query(tid, 3999_i64, 4500_i64) do |record|
      positions << record.pos
    end
    expect_equal [4020, 4309, 4336], positions
  end

  def test_query_chrom_numeric
    positions = [] of Int64
    indexed_bcf.query("poo", 4000_i64, 4500_i64) do |record|
      positions << record.pos
    end
    expect_equal [4020, 4309, 4336], positions
  end

  def test_query_multi_regions
    positions = [] of Int64
    indexed_bcf.query(["poo:4000-4100", "poo:4300-4400"]) do |record|
      positions << record.pos
    end
    expect_equal [4020, 4309, 4336], positions
  end

  def test_query_multi_regions_copy
    positions = [] of Int64
    indexed_bcf.query(["poo:4000-4100", "poo:4300-4400"], copy: true) do |record|
      positions << record.pos
    end
    expect_equal [4020, 4309, 4336], positions
  end

  def test_query_invalid_region_message
    ex = expect_raises(HTS::Bcf::QueryError) do
      indexed_bcf.query("unknown:1-10") { |_| }
    end
    expect_includes ex.message, "unknown:1-10"
    expect_includes ex.message, test_bcf_path
  end

  def test_query_invalid_chrom_message
    ex = expect_raises(ArgumentError) do
      indexed_bcf.query("unknown", 1_i64, 10_i64) { |_| }
    end
    expect_includes ex.message, "Unknown reference name"
    expect_includes ex.message, test_bcf_path
  end

  def test_each
    bcf.each do |record|
      expect_instance_of HTS::Bcf::Record, record
    end
  end

  def test_each_copy
    bcf.each(copy: true) do |record|
      expect_instance_of HTS::Bcf::Record, record
    end
  end

  def test_chrom
    act = bcf.chrom
    exp = bcf.map(&.chrom)
    expect_equal exp, act
  end

  def test_pos
    act = bcf.pos
    exp = bcf.map(&.pos)
    expect_equal exp, act
  end

  def test_endpos
    act = bcf.endpos
    exp = bcf.map(&.endpos)
    expect_equal exp, act
  end

  def test_id
    act = bcf.id
    exp = bcf.map(&.id)
    expect_equal exp, act
  end

  def test_ref
    act = bcf.ref
    exp = bcf.map(&.ref)
    expect_equal exp, act
  end

  def test_alt
    act = bcf.alt
    exp = bcf.map(&.alt)
    expect_equal exp, act
  end

  def test_qual
    act = bcf.qual
    exp = bcf.map(&.qual)
    expect_equal exp, act
  end

  def test_filter
    act = bcf.filter
    exp = bcf.map(&.filter)
    expect_equal exp, act
  end
end

describe BcfTest do
  {% for method in BcfTest.methods.select { |method| method.name.stringify.starts_with?("test_") } %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BcfTest.new
      run_spec_case(spec_case) do
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
