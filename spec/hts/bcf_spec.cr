require "../spec_helper"
require "../../src/hts/bcf"

class BcfTest
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

  private def with_temp_three_sample_bcf(&)
    file = File.tempfile("three_sample_subset_test", ".bcf")
    path = file.path || raise "tempfile path is nil"
    begin
      file.close

      header = HTS::Bcf::Header.new
      header.set_version("VCFv4.3")
      header.append("##contig=<ID=1,length=100>")
      header.append("##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">")
      header.append("##FORMAT=<ID=GQ,Number=1,Type=Integer,Description=\"Genotype quality\">")
      header.add_sample("A", sync: false)
      header.add_sample("B", sync: false)
      header.add_sample("C", sync: true)

      HTS::Bcf.open(path, "wb") do |bcf|
        bcf.write_header(header)

        record = HTS::Bcf::Record.new(header)
        record.rid = HTS::LibHTS2.bcf_hdr_name2id(header, "1")
        record.pos = 9

        rc = HTS::LibHTS.bcf_update_alleles_str(header, record, "A,C")
        raise "bcf_update_alleles_str failed (rc=#{rc})" if rc < 0

        genotypes = [
          HTS::LibHTS2.bcf_gt_unphased(0), HTS::LibHTS2.bcf_gt_unphased(0),
          HTS::LibHTS2.bcf_gt_unphased(0), HTS::LibHTS2.bcf_gt_unphased(1),
          HTS::LibHTS2.bcf_gt_unphased(1), HTS::LibHTS2.bcf_gt_unphased(1),
        ]
        rc = HTS::LibHTS2.bcf_update_genotypes(header, record, genotypes.to_unsafe, genotypes.size)
        raise "bcf_update_genotypes failed (rc=#{rc})" if rc < 0

        gq = [10, 20, 30]
        rc = HTS::LibHTS2.bcf_update_format_int32(header, record, "GQ", gq.to_unsafe, gq.size)
        raise "bcf_update_format_int32 failed for GQ (rc=#{rc})" if rc < 0

        bcf << record
      end

      yield path
    ensure
      File.delete(path) if File.exists?(path)
    end
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
    (b).should be_a(HTS::Bcf)
    b.close
    (b.closed?).should eq(true)
  end

  # def test_new_with_block
  #   expect_raises do
  #     HTS::Bcf.new(test_bcf_path) {}
  #   end
  # end

  def test_open
    b = HTS::Bcf.open(test_bcf_path)
    (b).should be_a(HTS::Bcf)
    b.close
    (b.closed?).should eq(true)
  end

  def test_open_with_block
    f = HTS::Bcf.open(test_bcf_path) do |bcf|
      (bcf).should be_a(HTS::Bcf)
    end
    (f.closed?).should eq(true)
  end

  def test_file_name
    (bcf.file_name).should eq(test_bcf_path)
  end

  def test_header
    (bcf.header).should be_a(HTS::Bcf::Header)
  end

  def test_mode
    (bcf.mode).should eq("r")
  end

  def test_file_format
    (bcf.file_format).should eq("Bcf")
  end

  def test_file_format_version
    (bcf.file_format_version).should eq("2.2")
  end

  def test_nsamples
    (bcf.nsamples).should eq(1)
  end

  def test_samples
    (bcf.samples).should eq(["poo.sort.bam"])
  end

  def test_initialize_no_file_bcf
    expect_raises(HTS::Bcf::OpenError) { HTS::Bcf.new("/tmp/no_such_file") }
  end

  def test_initialize_with_subset
    with_temp_multisample_bcf do |path|
      subset_bcf = HTS::Bcf.new(path, subset: ["B"])

      (subset_bcf.samples).should eq(["B"])
      (subset_bcf.nsamples).should eq(1)
      (subset_bcf.first.format.get_string("GT")).should eq(["0/1"])
    ensure
      subset_bcf.try &.close
    end
  end

  def test_subset_records_use_source_header_mapping
    with_temp_three_sample_bcf do |path|
      subset_bcf = HTS::Bcf.new(path, subset: ["C", "A"])
      record = subset_bcf.first

      (subset_bcf.samples).should eq(["C", "A"])
      (subset_bcf.nsamples).should eq(2)
      (record.format.get_string("GT")).should eq(["1/1", "0/0"])
      (record.format.get_int("GQ")).should eq([30, 10])
    ensure
      subset_bcf.try &.close
    end
  end

  def test_subset_records_use_source_header_mapping_with_copy
    with_temp_three_sample_bcf do |path|
      subset_bcf = HTS::Bcf.new(path, subset: ["B", "A"])
      record = subset_bcf.to_a.first

      (subset_bcf.samples).should eq(["B", "A"])
      (record.format.get_string("GT")).should eq(["0/1", "0/0"])
      (record.format.get_int("GQ")).should eq([20, 10])
    ensure
      subset_bcf.try &.close
    end
  end

  def test_query_requires_index
    ex = expect_raises(HTS::Bcf::MissingIndexError) do
      bcf.query("poo:4000-4100") { |_| }
    end
    (ex.message.to_s).should contain(test_bcf_path)
    (ex.message.to_s).should contain("Query requires an index")
  end

  def test_query_region
    positions = [] of Int64
    indexed_bcf.query("poo:4000-4500") do |record|
      positions << record.pos
    end
    (positions).should eq([4020, 4309, 4336])
  end

  def test_query_region_copy
    positions = [] of Int64
    indexed_bcf.query("poo:4000-4500", copy: true) do |record|
      positions << record.pos
    end
    (positions).should eq([4020, 4309, 4336])
  end

  def test_query_tid_numeric
    positions = [] of Int64
    tid = indexed_bcf.header.get_tid("poo")
    indexed_bcf.query(tid, 3999_i64, 4500_i64) do |record|
      positions << record.pos
    end
    (positions).should eq([4020, 4309, 4336])
  end

  def test_query_chrom_numeric
    positions = [] of Int64
    indexed_bcf.query("poo", 4000_i64, 4500_i64) do |record|
      positions << record.pos
    end
    (positions).should eq([4020, 4309, 4336])
  end

  def test_query_multi_regions
    positions = [] of Int64
    indexed_bcf.query(["poo:4000-4100", "poo:4300-4400"]) do |record|
      positions << record.pos
    end
    (positions).should eq([4020, 4309, 4336])
  end

  def test_query_multi_regions_copy
    positions = [] of Int64
    indexed_bcf.query(["poo:4000-4100", "poo:4300-4400"], copy: true) do |record|
      positions << record.pos
    end
    (positions).should eq([4020, 4309, 4336])
  end

  def test_query_invalid_region_message
    ex = expect_raises(HTS::Bcf::QueryError) do
      indexed_bcf.query("unknown:1-10") { |_| }
    end
    (ex.message.to_s).should contain("unknown:1-10")
    (ex.message.to_s).should contain(test_bcf_path)
  end

  def test_query_invalid_chrom_message
    ex = expect_raises(ArgumentError) do
      indexed_bcf.query("unknown", 1_i64, 10_i64) { |_| }
    end
    (ex.message.to_s).should contain("Unknown reference name")
    (ex.message.to_s).should contain(test_bcf_path)
  end

  def test_each
    bcf.each do |record|
      (record).should be_a(HTS::Bcf::Record)
    end
  end

  def test_each_copy
    bcf.each(copy: true) do |record|
      (record).should be_a(HTS::Bcf::Record)
    end
  end

  def test_chrom
    act = bcf.chrom
    exp = bcf.map(&.chrom)
    (act).should eq(exp)
  end

  def test_pos
    act = bcf.pos
    exp = bcf.map(&.pos)
    (act).should eq(exp)
  end

  def test_endpos
    act = bcf.endpos
    exp = bcf.map(&.endpos)
    (act).should eq(exp)
  end

  def test_id
    act = bcf.id
    exp = bcf.map(&.id)
    (act).should eq(exp)
  end

  def test_ref
    act = bcf.ref
    exp = bcf.map(&.ref)
    (act).should eq(exp)
  end

  def test_alt
    act = bcf.alt
    exp = bcf.map(&.alt)
    (act).should eq(exp)
  end

  def test_qual
    act = bcf.qual
    exp = bcf.map(&.qual)
    (act).should eq(exp)
  end

  def test_filter
    act = bcf.filter
    exp = bcf.map(&.filter)
    (act).should eq(exp)
  end
end

describe BcfTest do
  {% for method in BcfTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BcfTest.new
      begin
        spec_case.{{ method.name.id }}
      ensure
        spec_case.teardown
      end
    end
  {% end %}
end
