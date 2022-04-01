require "minitest/autorun"
require "../../src/hts/bam"

class BamTest < Minitest::Test
  def teardown
    @bam.try &.close
  end

  def path_sam_string
    File.expand_path("../fixtures/moo.sam", __DIR__)
  end

  def path_bam_string
    File.expand_path("../fixtures/moo.bam", __DIR__)
  end

  def path_sam_path
    Path[path_sam_string]
  end

  def path_bam_path
    Path[path_bam_string]
  end

  def path_sam_uri
    "https://raw.githubusercontent.com/bio-crystal/htslib.cr/develop/test/fixtures/moo.sam"
  end

  def path_bam_uri
    "https://raw.githubusercontent.com/bio-crystal/htslib.cr/develop/test/fixtures/moo.bam"
  end

  def bam
    @bam ||= HTS::Bam.new(path_bam_string)
  end

  {% for format, index in ["bam", "sam"] %}
    {% for type, index in ["string", "path", "uri"] %}
      def test_new_{{format.id}}_{{type.id}}
        b = HTS::Bam.new(path_{{format.id}}_{{type.id}})
        assert_instance_of HTS::Bam, b
        b.close
        assert_equal true, b.closed?
      end

      def test_open_{{format.id}}_{{type.id}}
        b = HTS::Bam.open(path_{{format.id}}_{{type.id}})
        assert_instance_of HTS::Bam, b
        b.close
        assert_equal true, b.closed?
      end

      def test_open_{{format.id}}_{{type.id}}_with_block
        f = HTS::Bam.open(path_{{format.id}}_{{type.id}}) do |b|
          assert_instance_of HTS::Bam, b
        end
        assert_equal true, f.closed?
      end

      def {{format.id}}_{{type.id}}
        @{{format.id}}_{{type.id}} ||= HTS::Bam.open({{format.id}}_{{type.id}})
      end

    {% end %}
  {% end %}

  def test_file_name
    assert_equal path_bam_string, bam.file_name
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
    bam.query("chr2:350-700") do |aln|
      arr << aln.start
    end
    assert_equal [341, 658], arr
  end
end
