require "../spec_helper"
require "../../src/hts/bam"

class BamTest
  def teardown
    # close files
    {% for format in ["bam", "sam", "cram"] %}
      {% for type in ["string", "path", "uri"] %}
        @{{format.id}}_{{type.id}}.try &.close
      {% end %}
    {% end %}

    # Clean up index files created during tests
    cleanup_index_files
  end

  private def cleanup_index_files
    index_files = [
      "moo.bam.bai",
      "moo.cram.crai",
      "poo.sort.bam.bai",
    ]

    index_files.each do |file|
      File.delete(file) if File.exists?(file)
    end
  end

  {% for format in ["bam", "sam", "cram"] %}
    def path_{{format.id}}_string
      File.expand_path("../fixtures/moo.{{format.id}}", __DIR__)
    end

    def path_{{format.id}}_path
      Path[path_{{format.id}}_string]
    end

    def path_{{format.id}}_uri
      "https://raw.githubusercontent.com/bio-cr/hts.cr/develop/spec/fixtures/moo.{{format.id}}"
    end
  {% end %}

  {% for format in ["bam", "sam", "cram"] %}
    {% for type in ["string", "path", "uri"] %}
      {% ft = ("#{format.id}_#{type.id}").id %}
      def {{ft}}
        @{{ft}} ||= HTS::Bam.open(path_{{ft}})
      end

      def test_new_{{ft}}
        b = HTS::Bam.new(path_{{ft}})
        (b).should be_a(HTS::Bam)
        b.close
        (b.closed?).should eq(true)
      end

      def test_open_{{ft}}
        b = HTS::Bam.open(path_{{ft}})
        (b).should be_a(HTS::Bam)
        (b.closed?).should eq(false)
        b.close
        (b.closed?).should eq(true)
        (b.close).should be_nil
      end

      def test_open_{{ft}}_with_block
        f = HTS::Bam.open(path_{{ft}}) do |b|
          (b).should be_a(HTS::Bam)
        end
        (f.closed?).should eq(true)
      end

      {% if format == "bam" %}
      # FIXME: Cram dose not have cram_tell
      def test_tell_{{ft}}
        ({{ft}}.tell).should eq(21889024)
      end
      {% end %}

      {% if format == "sam" %}
      # FIXME: Cram dose not have cram_tell
      def test_tell_{{ft}}
        ({{ft}}.tell).should eq(134)
      end
      {% end %}

      def test_file_name_{{ft}}
        ({{ft}}.file_name).should eq(path_{{ft}}.to_s)
      end

      def test_mode_{{ft}}
        ({{ft}}.mode).should eq("r")
      end

      def test_header_{{ft}}
        ({{ft}}.header).should be_a(HTS::Bam::Header)
      end

      def test_file_format_{{ft}}
        ({{ft}}.file_format).should eq({{format}}.capitalize)
      end

      def test_file_format_version_{{ft}}
        (["1", "1.6", "3.0"]).should contain({{ft}}.file_format_version)
      end

      {% if format != "sam" %}
        def test_query_{{ft}}
          arr = [] of Int64
          {{ft}}.query("chr2:350-700") do |aln|
            arr << aln.pos
          end
          (arr).should eq([341, 658])
        end

        def test_query_copy_{{ft}}
          arr = [] of Int64
          {{ft}}.query("chr2:350-700", copy: true) do |aln|
            arr << aln.pos
          end
          (arr).should eq([341, 658])
        end

        # New: numeric tid query should produce identical positions.
        def test_query_tid_numeric_{{ft}}
          arr = [] of Int64
          # Resolve tid from header (reference name to integer id)
          tid = {{ft}}.header.get_tid("chr2")
          (tid >= 0).should be_true
          # Convert 1-based inclusive 350-700 to 0-based half-open => [349, 700)
          {{ft}}.query(tid, 349_i64, 700_i64) do |aln|
            arr << aln.pos
          end
          (arr).should eq([341, 658])
        end

        # New: chromosome name + numeric coordinates variant
        def test_query_chrom_numeric_{{ft}}
          arr = [] of Int64
          # chr2, 350-700 uses 1-based inclusive coordinates like region strings.
          {{ft}}.query("chr2", 350_i64, 700_i64) do |aln|
            arr << aln.pos
          end
          (arr).should eq([341, 658])
        end

        def test_query_multi_regions_{{ft}}
          arr = [] of Int64
          {{ft}}.query(["chr1:100-200", "chr2:350-700"]) do |aln|
            arr << aln.pos
          end
          (arr).should contain(341)
          (arr).should contain(658)
        end

        def test_query_multi_regions_copy_{{ft}}
          arr = [] of Int64
          {{ft}}.query(["chr1:100-200", "chr2:350-700"], copy: true) do |aln|
            arr << aln.pos
          end
          (arr).should contain(341)
          (arr).should contain(658)
        end

        def test_query_single_region_array_{{ft}}
          arr = [] of Int64
          {{ft}}.query(["chr2:350-700"]) do |aln|
            arr << aln.pos
          end
          (arr).should eq([341, 658])
        end
      {% end %}

      def test_each_{{ft}}
        c = 0
        {{ft}}.each do |aln|
          c += 1
          (aln).should be_a(HTS::Bam::Record)
        end
        (c).should eq(10)
      end

      def test_each_copy_{{ft}}
        c = 0
        {{ft}}.each(copy: true) do |aln|
          c += 1
          (aln).should be_a(HTS::Bam::Record)
        end
        (c).should eq(10)
      end

      def test_qname_{{ft}}
        b = HTS::Bam.new(path_{{ft}})
        (b.qname.size).should eq(10)
        b.close
      end

    {% end %}
  {% end %}

  def test_initialize_no_file_bam
    expect_raises(Exception) { HTS::Bam.new("/tmp/no_such_file") }
  end

  def test_file_level_aux_int
    values : Array(Int64 | Nil) = bam_string.aux_int("NM")
    expected = [] of (Int64 | Nil)
    bam_string.each do |aln|
      expected << aln.aux.get_int("NM")
    end
    (values).should eq(expected)
  end

  def test_file_level_aux_string
    values : Array(String | Nil) = bam_string.aux_string("MC")
    expected = [] of (String | Nil)
    bam_string.each do |aln|
      expected << aln.aux.get_string("MC")
    end
    (values).should eq(expected)
  end

  def test_file_level_aux_runtime_fallback
    values : Array(HTS::Bam::AuxValue) = bam_string.aux("NM")
    expected = [] of HTS::Bam::AuxValue
    bam_string.each do |aln|
      expected << aln.aux["NM"]
    end
    (values).should eq(expected)
  end

  def test_each_aux_int
    values = [] of (Int64 | Nil)
    bam_string.each_aux_int("NM") do |value|
      values << value
    end
    (values).should eq(bam_string.aux_int("NM"))
  end

  def test_each_aux_runtime_fallback
    values = [] of HTS::Bam::AuxValue
    bam_string.each_aux("MC") do |value|
      values << value
    end
    (values).should eq(bam_string.aux("MC"))
  end

  def test_query_requires_index_for_sam
    ex = expect_raises(HTS::Bam::MissingIndexError) do
      sam_string.query("chr1:1-10") { |_| }
    end
    (ex.message.to_s).should contain(path_sam_string)
    (ex.message.to_s).should contain("Query requires an index")
  end

  def test_query_invalid_region_message_bam
    ex = expect_raises(HTS::Bam::QueryError) do
      bam_string.query("chrX:1-10") { |_| }
    end
    (ex.message.to_s).should contain("chrX:1-10")
    (ex.message.to_s).should contain(path_bam_string)
  end

  def test_query_invalid_tid_message_bam
    ex = expect_raises(ArgumentError) do
      bam_string.query(-1, 0_i64, 10_i64) { |_| }
    end
    (ex.message.to_s).should contain("tid (-1)")
  end

  def test_query_invalid_chrom_message_bam
    ex = expect_raises(ArgumentError) do
      bam_string.query("chrX", 1_i64, 10_i64) { |_| }
    end
    (ex.message.to_s).should contain(path_bam_string)
    (ex.message.to_s).should contain("Unknown reference name")
  end
end

describe BamTest do
  {% for method in BamTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BamTest.new
      begin
        spec_case.{{ method.name.id }}
      ensure
        spec_case.teardown
      end
    end
  {% end %}
end
