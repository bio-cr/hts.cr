require "minitest/autorun"
require "../../src/hts/bam"

class BamTest < Minitest::Test
  def teardown
    # close files
    {% for format in ["bam", "sam", "cram"] %}
      {% for type in ["string", "path", "uri"] %}
        @{{format.id}}_{{type.id}}.try &.close
      {% end %}
    {% end %}
  end

  {% for format in ["bam", "sam", "cram"] %}
    def path_{{format.id}}_string
      File.expand_path("../fixtures/moo.{{format.id}}", __DIR__)
    end

    def path_{{format.id}}_path
      Path[path_{{format.id}}_string]
    end

    def path_{{format.id}}_uri
      "https://raw.githubusercontent.com/bio-crystal/hts/develop/test/fixtures/moo.{{format.id}}"
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
        assert_instance_of HTS::Bam, b
        b.close
        assert_equal true, b.closed?
      end

      def test_open_{{ft}}
        b = HTS::Bam.open(path_{{ft}})
        assert_instance_of HTS::Bam, b
        assert_equal false, b.closed?
        b.close
        assert_equal true, b.closed?
        assert_nil b.close
      end

      def test_open_{{ft}}_with_block
        f = HTS::Bam.open(path_{{ft}}) do |b|
          assert_instance_of HTS::Bam, b
        end
        assert_equal true, f.closed?
      end

      {% if format == "bam" %}
      # FIXME: Cram dose not have cram_tell
      def test_tell_{{ft}}
        assert_equal 21889024, {{ft}}.tell
      end
      {% end %}

      {% if format == "sam" %}
      # FIXME: Cram dose not have cram_tell
      def test_tell_{{ft}}
        assert_equal 134, {{ft}}.tell
      end
      {% end %}

      def test_file_name_{{ft}}
        assert_equal path_{{ft}}.to_s, {{ft}}.file_name
      end

      def test_mode_{{ft}}
        assert_equal "r", {{ft}}.mode
      end

      def test_header_{{ft}}
        assert_instance_of HTS::Bam::Header, {{ft}}.header
      end

      def test_file_format_{{ft}}
        assert_equal {{format}}.capitalize, {{ft}}.file_format
      end

      def test_each_{{ft}}
        c = 0
        {{ft}}.each do |aln|
          c += 1
          assert_instance_of HTS::Bam::Record, aln
        end
        assert_equal 10, c
      end

      def test_file_format_version_{{ft}}
        assert_includes ["1", "1.6", "3.0"], {{ft}}.file_format_version
      end

      {% if format != "sam" %}
        def test_query_{{ft}}
          arr = [] of Int64
          {{ft}}.query("chr2:350-700") do |aln|
            arr << aln.pos
          end
          assert_equal [341, 658], arr
        end
      {% end %}

    {% end %}
  {% end %}

  def test_initialize_no_file_bam
    assert_raises { HTS::Bam.new("/tmp/no_such_file") }
  end
end
