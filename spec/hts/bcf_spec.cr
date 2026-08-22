require "../spec_helper"
require "../../src/hts/bcf"
require "../../src/hts/bgzf"

class BcfTest
  include TestBcfMultisampleHelper

  @bcf : HTS::Bcf?
  @indexed_bcf : HTS::Bcf?

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

  def test_vcf_path
    File.expand_path("../fixtures/test.vcf", __DIR__)
  end

  def test_bcf_index_path
    File.expand_path("../fixtures/test.bcf.csi.tmp", __DIR__)
  end

  private def with_temp_indexed_vcf_gz(&)
    file = File.tempfile("bcf_tabix_query", ".vcf.gz")
    path = file.path || raise "tempfile path is nil"
    file.close
    begin
      HTS::Bgzf.open(path, "wz") do |bgzf|
        bgzf.puts "##fileformat=VCFv4.3"
        bgzf.puts "##contig=<ID=chr1,length=100>"
        bgzf.puts "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO"
        bgzf.puts "chr1\t10\t.\tA\tC\t.\tPASS\t."
        bgzf.puts "chr1\t20\t.\tG\tT\t.\tPASS\t."
      end
      HTS::Bcf.build_index(path, min_shift: 0, verbose: false)
      yield path
    ensure
      File.delete(path) if File.exists?(path)
      File.delete("#{path}.tbi") if File.exists?("#{path}.tbi")
    end
  end

  def test_query_bgzip_vcf_through_tabix_backend
    with_temp_indexed_vcf_gz do |path|
      HTS::Bcf.open(path) do |vcf|
        positions = [] of Int64
        vcf.query("chr1", 9_i64, 20_i64) { |record| positions << record.pos }
        (positions).should eq([9, 19])

        copies = [] of HTS::Bcf::Record
        vcf.query_copy("chr1:10-20") { |record| copies << record }
        (copies.map(&.pos)).should eq([9, 19])
      end
    end
  end

  private def with_temp_three_sample_bcf(&)
    file = File.tempfile("three_sample_subset_test", ".bcf")
    path = file.path || raise "tempfile path is nil"
    begin
      file.close

      header = HTS::Bcf::Header.new
      header.version = "VCFv4.3"
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

  private def with_temp_indexed_three_sample_bcf(&)
    with_temp_three_sample_bcf do |path|
      index_path = "#{path}.csi"
      begin
        HTS::Bcf.build_index(path, index_path, 14, 0, false)
        yield path, index_path
      ensure
        File.delete(index_path) if File.exists?(index_path)
      end
    end
  end

  private def selected_sample_fields(record : HTS::Bcf::Record) : {Array(String), Array(Int32)}
    format = record.format
    genotypes = format.get_string("GT") || raise "GT should be present"
    qualities = (format.get_int("GQ") || raise "GQ should be present").map(&.not_nil!)
    {genotypes, qualities}
  end

  def bcf
    @bcf ||= with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogError) { HTS::Bcf.new(test_bcf_path) }
  end

  def indexed_bcf : HTS::Bcf
    if indexed_bcf = @indexed_bcf
      indexed_bcf
    else
      HTS::Bcf.build_index(test_bcf_path, test_bcf_index_path, 14, 0, false)
      @indexed_bcf = with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogError) do
        HTS::Bcf.new(test_bcf_path, "r", test_bcf_index_path)
      end
      if indexed_bcf = @indexed_bcf
        indexed_bcf
      else
        raise "indexed_bcf was not initialized"
      end
    end
  end

  def test_new
    # test.bcf is an older fixture whose MQ header triggers an htslib warning.
    # Keep errors visible while avoiding a warning-only line in normal spec output.
    b = with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogError) { HTS::Bcf.new(test_bcf_path) }
    (b).should be_a(HTS::Bcf)
    b.close
    (b.closed?).should be_true
  end

  # def test_new_with_block
  #   expect_raises do
  #     HTS::Bcf.new(test_bcf_path) {}
  #   end
  # end

  def test_open
    b = with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogError) { HTS::Bcf.open(test_bcf_path) }
    (b).should be_a(HTS::Bcf)
    b.close
    (b.closed?).should be_true
  end

  def test_open_with_block
    f = with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogError) do
      HTS::Bcf.open(test_bcf_path) do |bcf|
        (bcf).should be_a(HTS::Bcf)
      end
    end
    (f.closed?).should be_true
  end

  def test_unpack_levels_are_applied_to_records
    levels = {
      site_only: HTS::LibHTS2::BCF_UN_SHR,
      info:      HTS::LibHTS2::BCF_UN_INFO,
      format:    HTS::LibHTS2::BCF_UN_FMT,
      all:       HTS::LibHTS2::BCF_UN_ALL,
    }

    levels.each do |level, expected|
      HTS::Bcf.open(test_bcf_path, unpack: level) do |file|
        (file.first.to_unsafe.value.max_unpack).should eq(expected)
      end
    end
  end

  def test_unpack_level_is_applied_to_copy_and_indexed_reads
    HTS::Bcf.open(test_bcf_path, unpack: :info) do |file|
      (file.to_a.first.to_unsafe.value.max_unpack).should eq(HTS::LibHTS2::BCF_UN_INFO)
    end

    HTS::Bcf.build_index(test_bcf_path, test_bcf_index_path, 14, 0, false)
    HTS::Bcf.open(test_bcf_path, "r", test_bcf_index_path, unpack: :site_only) do |file|
      file.query("poo:4000-4100") do |record|
        (record.to_unsafe.value.max_unpack).should eq(HTS::LibHTS2::BCF_UN_SHR)
      end
      file.query_copy("poo:4000-4100") do |record|
        (record.to_unsafe.value.max_unpack).should eq(HTS::LibHTS2::BCF_UN_SHR)
      end
    end
  end

  def test_site_only_vcf_read_skips_format_columns
    HTS::Bcf.open(test_vcf_path, unpack: :site_only) do |file|
      record = file.first
      (record.chrom).should eq("poo")
      (record.ref).should eq("T")
      (record.info.get_int("DP")).should eq([31])
      (record.to_unsafe.value.indiv.l).should eq(0)
      (record.format.get_string("GT")).should be_nil
    end

    HTS::Bcf.open(test_vcf_path, unpack: :format) do |file|
      (file.first.format.get_string("GT")).should eq(["1/1"])
    end
  end

  def test_unknown_unpack_level_is_rejected
    expect_raises(ArgumentError, "Unknown BCF unpack level: :unknown") do
      HTS::Bcf.new(test_bcf_path, unpack: :unknown)
    end
  end

  def test_selective_unpacking_is_rejected_for_writing
    file = File.tempfile("selective_unpack_write", ".bcf")
    path = file.path || raise "tempfile path is nil"
    file.close

    expect_raises(ArgumentError, "Selective unpacking is only available when reading BCF/VCF files") do
      HTS::Bcf.new(path, "wb", unpack: :site_only)
    end
  ensure
    File.delete(path) if path && File.exists?(path)
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
    (bcf.file_format).should eq("bcf")
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
    with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogOff) do
      expect_raises(HTS::Bcf::OpenError) { HTS::Bcf.new("/tmp/no_such_file") }
    end
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

  def test_indexed_queries_apply_the_same_sample_subset
    with_temp_indexed_three_sample_bcf do |path, index_path|
      subset_bcf = HTS::Bcf.new(path, "r", index_path, subset: ["C", "A"])
      reused = [] of {Array(String), Array(Int32)}
      copied = [] of {Array(String), Array(Int32)}

      subset_bcf.query("1:1-100") do |record|
        reused << selected_sample_fields(record)
      end
      subset_bcf.query_copy("1:1-100") do |record|
        copied << selected_sample_fields(record)
      end

      expected = [{["1/1", "0/0"], [30, 10]}]
      (subset_bcf.samples).should eq(["C", "A"])
      (reused).should eq(expected)
      (copied).should eq(expected)
    ensure
      subset_bcf.try &.close
    end
  end

  def test_index_is_loaded_lazily
    with_temp_indexed_three_sample_bcf do |path, index_path|
      file = HTS::Bcf.new(path, "r", index_path)
      file.index_loaded?.should be_false
      file.query("1:1-100") { |_| }
      file.index_loaded?.should be_true
    ensure
      file.try &.close
    end
  end

  def test_load_index_retains_reloads_and_clears_the_index
    with_temp_indexed_three_sample_bcf do |path, index_path|
      file = HTS::Bcf.new(path)
      begin
        file.load_index(index_path).should be(file)
        file.index_loaded?.should be_true
        file.load_index(index_path).should be(file)
        file.index_loaded?.should be_true

        with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogOff) do
          file.try_load_index("#{index_path}.missing").should be_false
          expect_raises(HTS::Bcf::MissingIndexError) { file.load_index("#{index_path}.missing") }
        end
        file.index_loaded?.should be_false
      ensure
        file.close
      end
      file.closed?.should be_true
    end
  end

  def test_class_build_index_uses_default_index_name
    with_temp_three_sample_bcf do |path|
      index_path = "#{path}.csi"
      begin
        HTS::Bcf.build_index(path, verbose: false)
        File.exists?(index_path).should be_true
      ensure
        File.delete(index_path) if File.exists?(index_path)
      end
    end
  end

  def test_instance_build_index_uses_default_index_name
    with_temp_three_sample_bcf do |path|
      index_path = "#{path}.csi"
      begin
        HTS::Bcf.open(path) do |file|
          file.build_index(verbose: false).should be(file)
        end
        File.exists?(index_path).should be_true
      ensure
        File.delete(index_path) if File.exists?(index_path)
      end
    end
  end

  def test_write_build_index_uses_default_index_name_on_close
    file = File.tempfile("bcf_auto_index", ".bcf")
    path = file.path || raise "tempfile path is nil"
    file.close
    index_path = "#{path}.csi"

    header = HTS::Bcf::Header.new
    header.version = "VCFv4.3"
    header.append("##contig=<ID=1,length=100>")
    header.add_sample("sample", sync: true)

    stderr = capture_stderr do
      HTS::Bcf.open(path, "wb", build_index: true) do |bcf|
        bcf.write_header(header)
      end
    end
    stderr.should contain("Create index")
    File.exists?(index_path).should be_true
  ensure
    File.delete(path) if path && File.exists?(path)
    File.delete(index_path) if index_path && File.exists?(index_path)
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
    indexed_bcf.query_copy("poo:4000-4500") do |record|
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

  def test_query_tid_rejects_header_upper_bound
    tid = indexed_bcf.header.target_count
    expect_raises(ArgumentError, "tid (#{tid}) must be within 0...#{tid}") do
      indexed_bcf.query(tid, 0_i64, 1_i64) { |_| }
    end
    expect_raises(ArgumentError, "tid (#{tid}) must be within 0...#{tid}") do
      indexed_bcf.query_copy(tid, 0_i64, 1_i64) { |_| }
    end
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
    indexed_bcf.query_copy(["poo:4000-4100", "poo:4300-4400"]) do |record|
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
    bcf.each_copy do |record|
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
