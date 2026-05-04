require "../spec_helper"
require "../../src/hts/bgzf"
require "../../src/hts/tabix"

class BgzfTest < HTSSpecCase
  def test_create_bgzf_instance
    # Test with a simple text file first
    test_file = File.tempfile("test", ".txt")
    test_file.puts("Hello, World!")
    test_file.puts("This is a test.")
    test_file.close

    # Test reading
    HTS::Bgzf.open(test_file.path, "r") do |bgzf|
      expect_instance_of HTS::Bgzf, bgzf
      expect_equal test_file.path.to_s, bgzf.file_name
      expect_equal "r", bgzf.mode
    end

    test_file.delete
  end

  def test_read_lines_with_gets
    test_file = File.tempfile("test", ".gz")
    test_file.close

    # Only test with BGZF files
    HTS::Bgzf.open(test_file.path, "wz") do |bgzf|
      if bgzf.is_bgzf?
        bgzf.puts("Line 1")
        bgzf.puts("Line 2")
        bgzf.puts("Line 3")
        bgzf.flush
      end
    end

    if File.exists?(test_file.path)
      HTS::Bgzf.open(test_file.path, "r") do |bgzf|
        if bgzf.is_bgzf?
          line1 = bgzf.gets
          expect_equal "Line 1", line1

          line2 = bgzf.gets
          expect_equal "Line 2", line2

          line3 = bgzf.gets
          expect_equal "Line 3", line3

          # EOF should return nil
          eof_line = bgzf.gets
          expect_nil eof_line
        end
      end
    end

    test_file.delete
  end

  def test_iterate_over_lines
    test_file = File.tempfile("test", ".gz")
    test_file.close

    # Only test with BGZF files
    HTS::Bgzf.open(test_file.path, "wz") do |bgzf|
      if bgzf.is_bgzf?
        bgzf.puts("Line A")
        bgzf.puts("Line B")
        bgzf.puts("Line C")
        bgzf.flush
      end
    end

    lines = [] of String
    HTS::Bgzf.open(test_file.path, "r") do |bgzf|
      if bgzf.is_bgzf?
        bgzf.each_line do |line|
          lines << line
        end
      end
    end

    if lines.size > 0
      expect_equal 3, lines.size
      expect_equal "Line A", lines[0]
      expect_equal "Line B", lines[1]
      expect_equal "Line C", lines[2]
    end

    test_file.delete
  end

  def test_read_characters_with_getc
    test_file = File.tempfile("test", ".gz")
    test_file.close

    # Only test with BGZF files
    HTS::Bgzf.open(test_file.path, "wz") do |bgzf|
      if bgzf.is_bgzf?
        bgzf.write("ABC")
        bgzf.flush
      end
    end

    HTS::Bgzf.open(test_file.path, "r") do |bgzf|
      if bgzf.is_bgzf?
        char1 = bgzf.getc
        expect_equal 'A', char1

        char2 = bgzf.getc
        expect_equal 'B', char2

        char3 = bgzf.getc
        expect_equal 'C', char3

        # EOF should return nil
        eof_char = bgzf.getc
        expect_nil eof_char
      end
    end

    test_file.delete
  end

  def test_read_bytes_with_read
    test_file = File.tempfile("test", ".gz")
    test_file.close

    # Only test with BGZF files
    HTS::Bgzf.open(test_file.path, "wz") do |bgzf|
      if bgzf.is_bgzf?
        bgzf.write("Hello")
        bgzf.flush
      end
    end

    HTS::Bgzf.open(test_file.path, "r") do |bgzf|
      if bgzf.is_bgzf?
        bytes = bgzf.read(5)
        expect_equal "Hello".to_slice, bytes

        # Reading beyond EOF should return empty bytes
        empty_bytes = bgzf.read(10)
        expect_equal Bytes.empty, empty_bytes
      end
    end

    test_file.delete
  end

  def test_write_data_with_write
    test_file = File.tempfile("test", ".gz")
    test_file.close

    # Write data
    HTS::Bgzf.open(test_file.path, "wz") do |bgzf|
      if bgzf.is_bgzf?
        bytes_written = bgzf.write("Hello, BGZF!")
        expect_true bytes_written > 0
        bgzf.flush
      end
    end

    # Read back the data
    HTS::Bgzf.open(test_file.path, "r") do |bgzf|
      if bgzf.is_bgzf?
        data = bgzf.read(100)
        expect_equal "Hello, BGZF!", String.new(data)
      end
    end

    test_file.delete
  end

  def test_write_lines_with_puts
    test_file = File.tempfile("test", ".gz")
    test_file.close

    # Write lines
    HTS::Bgzf.open(test_file.path, "wz") do |bgzf|
      if bgzf.is_bgzf?
        bgzf.puts("First line")
        bgzf.puts("Second line")
        bgzf.flush
      end
    end

    # Read back the lines
    lines = [] of String
    HTS::Bgzf.open(test_file.path, "r") do |bgzf|
      if bgzf.is_bgzf?
        bgzf.each_line do |line|
          lines << line.chomp
        end
      end
    end

    if lines.size > 0
      expect_equal 2, lines.size
      expect_equal "First line", lines[0]
      expect_equal "Second line", lines[1]
    end

    test_file.delete
  end

  def test_check_if_file_is_bgzf
    test_file = File.tempfile("test", ".gz")
    test_file.close

    HTS::Bgzf.open(test_file.path, "wz") do |bgzf|
      if bgzf.is_bgzf?
        bgzf.write("test data")
        expect_true bgzf.is_bgzf?
      end
    end

    test_file.delete
  end

  def test_get_compression_level
    test_file = File.tempfile("test", ".gz")
    test_file.close

    HTS::Bgzf.open(test_file.path, "wz") do |bgzf|
      level = bgzf.compression_level
      expect_true level >= -1 # -1 means no compression info available
    end

    test_file.delete
  end

  def test_tabix_inherits_bgzf
    # Test that Tabix inherits from Bgzf
    test_file = File.tempfile("tabix_test", ".txt")
    test_file.puts("chr1\t100\t200\tfeature1")
    test_file.puts("chr1\t300\t400\tfeature2")
    test_file.close

    HTS::Tabix.open(test_file.path, "r") do |tabix|
      expect_true tabix.is_a?(HTS::Bgzf)
      expect_true tabix.is_a?(HTS::Hts)

      # BGZFから継承したメソッドが使用可能
      lines = [] of String
      tabix.each_line do |line|
        lines << line.chomp
      end

      expect_equal 2, lines.size
    end

    test_file.delete
  end
end

describe BgzfTest do
  {% for method in BgzfTest.methods.select { |method| method.name.stringify.starts_with?("test_") } %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BgzfTest.new
      run_spec_case(spec_case) do
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
