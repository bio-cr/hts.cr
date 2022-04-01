require "minitest/autorun"
require "../../src/hts/bam"

class BamTest < Minitest::Test
  def teardown
    # close files
    {% for format in ["bam", "sam"] %}
      {% for type in ["string", "path", "uri"] %}
        @{{format.id}}_{{type.id}}.try &.close
      {% end %}
    {% end %}
  end

  {% for format in ["bam", "sam"] %}
    def path_{{format.id}}_string
      File.expand_path("../fixtures/moo.{{format.id}}", __DIR__)
    end

    def path_{{format.id}}_path
      Path[path_{{format.id}}_string]
    end

    def path_{{format.id}}_uri
      "https://raw.githubusercontent.com/bio-crystal/htslib.cr/develop/test/fixtures/moo.{{format.id}}"
    end

    {% for type in ["string", "path", "uri"] %}
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
        @{{format.id}}_{{type.id}} ||= HTS::Bam.open(path_{{format.id}}_{{type.id}})
      end

      def test_file_name_{{format.id}}_{{type.id}}
        assert_equal path_{{format.id}}_{{type.id}}.to_s, {{format.id}}_{{type.id}}.file_name
      end

      def test_mode_{{format.id}}_{{type.id}}
        assert_equal "r", {{format.id}}_{{type.id}}.mode
      end

      def test_header_{{format.id}}_{{type.id}}
        assert_instance_of HTS::Bam::Header, {{format.id}}_{{type.id}}.header
      end

      def test_format_{{format.id}}_{{type.id}}
        assert_equal {{format}}.capitalize, {{format.id}}_{{type.id}}.format
      end

      def test_each_{{format.id}}_{{type.id}}
        c = 0
        {{format.id}}_{{type.id}}.each do |aln|
          c += 1
          assert_instance_of HTS::Bam::Record, aln
        end
        assert_equal 10, c
      end

      def test_format_version_{{format.id}}_{{type.id}}
        assert_includes ["1", "1.6"], {{format.id}}_{{type.id}}.format_version
      end

      {% if format != "sam" %}
        def test_query_{{format.id}}_{{type.id}}
          arr = [] of Int64
          {{format.id}}_{{type.id}}.query("chr2:350-700") do |aln|
            arr << aln.start
          end
          assert_equal [341, 658], arr
        end
      {% end %}

    {% end %}
  {% end %}
end
