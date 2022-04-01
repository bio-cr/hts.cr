require "minitest/autorun"
require "../../src/hts/bam"

class BamTest < Minitest::Test
  def teardown
    @bam.try &.close
  end

  def sam_path_string
    File.expand_path("../fixtures/moo.sam", __DIR__)
  end

  def bam_path_string
    File.expand_path("../fixtures/poo.sort.bam", __DIR__)
  end

  def sam_path_path
    Path[sam_path_string]
  end

  def bam_path_path
    Path[bam_path_string]
  end

  def sam_path_uri
    "https://raw.githubusercontent.com/kojix2/ruby-htslib/develop/test/fixtures/moo.sam"
  end

  def bam_path_uri
    "https://raw.githubusercontent.com/kojix2/ruby-htslib/develop/test/fixtures/poo.sort.bam"
  end

  def bam
    @bam ||= HTS::Bam.new(bam_path_string)
  end



  {% for format, index in ["bam", "sam"] %}
    {% for type, index in ["string", "path", "uri"] %}
      def test_new_{{format.id}}_path_{{type.id}}
        b = HTS::Bam.new({{format.id}}_path_{{type.id}})
        assert_instance_of HTS::Bam, b
        b.close
        assert_equal true, b.closed?
      end

      def test_open_{{format.id}}_path_{{type.id}}
        b = HTS::Bam.open({{format.id}}_path_{{type.id}})
        assert_instance_of HTS::Bam, b
        b.close
        assert_equal true, b.closed?
      end

      def test_open_{{format.id}}_path_{{type.id}}_with_block
        f = HTS::Bam.open({{format.id}}_path_{{type.id}}) do |b|
          assert_instance_of HTS::Bam, b
        end
        assert_equal true, f.closed?
      end
    {% end %}
  {% end %}

  def test_file_name
    assert_equal bam_path_string, bam.file_name
  end

  def test_mode
    assert_equal "r", bam.mode
  end

  def test_header
    assert_instance_of HTS::Bam::Header, bam.header
  end

  def test_format
    assert_equal "Bam", bam.format
  end

  def test_format_version
    assert_equal "1", bam.format_version
  end

  def test_each
    bam.each do |aln|
      assert_instance_of HTS::Bam::Record, aln
    end
  end

  def test_query
    arr = [] of Int64
    bam.query("poo:3200-3300") do |aln|
      arr << aln.start
    end
    assert_equal [3289, 3292, 3293, 3298], arr
  end
end
