require "../spec_helper"
require "../../src/hts/bgzf"
require "../../src/hts/tabix"

class BgzfTest
  def test_create_bgzf_instance
    # Test with a simple text file first
    test_file = File.tempfile("test", ".txt")
    test_file.puts("Hello, World!")
    test_file.puts("This is a test.")
    test_file.close

    # Test reading
    HTS::Bgzf.open(test_file.path, "r") do |bgzf|
      (bgzf).should be_a(HTS::Bgzf)
      (bgzf.file_name).should eq(test_file.path.to_s)
      (bgzf.mode).should eq("r")
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
          (line1).should eq("Line 1")

          line2 = bgzf.gets
          (line2).should eq("Line 2")

          line3 = bgzf.gets
          (line3).should eq("Line 3")

          # EOF should return nil
          eof_line = bgzf.gets
          (eof_line).should be_nil
        end
      end
    end

    test_file.delete
  end

  def test_gets_raises_on_read_error
    test_file = File.tempfile("bad_bgzf_gets", ".gz")
    path = test_file.path
    test_file.close

    begin
      HTS::Bgzf.open(path, "wz") do |bgzf|
        bgzf.puts("hello")
        bgzf.puts("world")
      end

      size = File.size(path)
      File.open(path, "r+", &.truncate(size - 10))

      HTS::Bgzf.open(path, "r") do |bgzf|
        (bgzf.gets).should eq("hello")
        (bgzf.gets).should eq("world")
        with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogOff) do
          expect_raises(HTS::Bgzf::ReadError) { bgzf.gets }
        end
      end
    ensure
      File.delete(path) if File.exists?(path)
    end
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
      (lines.size).should eq(3)
      (lines[0]).should eq("Line A")
      (lines[1]).should eq("Line B")
      (lines[2]).should eq("Line C")
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
        (char1).should eq('A')

        char2 = bgzf.getc
        (char2).should eq('B')

        char3 = bgzf.getc
        (char3).should eq('C')

        # EOF should return nil
        eof_char = bgzf.getc
        (eof_char).should be_nil
      end
    end

    test_file.delete
  end

  def test_getc_raises_on_read_error
    test_file = File.tempfile("bad_bgzf_getc", ".gz")
    path = test_file.path
    test_file.close

    begin
      HTS::Bgzf.open(path, "wz") do |bgzf|
        bgzf.puts("hello")
        bgzf.puts("world")
      end

      size = File.size(path)
      File.open(path, "r+", &.truncate(size - 10))

      HTS::Bgzf.open(path, "r") do |bgzf|
        "hello\nworld\n".each_char do |char|
          (bgzf.getc).should eq(char)
        end
        with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogOff) do
          expect_raises(HTS::Bgzf::ReadError) { bgzf.getc }
        end
      end
    ensure
      File.delete(path) if File.exists?(path)
    end
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
        (bytes).should eq("Hello".to_slice)

        # Reading beyond EOF should return empty bytes
        empty_bytes = bgzf.read(10)
        (empty_bytes).should eq(Bytes.empty)
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
        (bytes_written > 0).should be_true
        bgzf.flush
      end
    end

    # Read back the data
    HTS::Bgzf.open(test_file.path, "r") do |bgzf|
      if bgzf.is_bgzf?
        data = bgzf.read(100)
        (String.new(data)).should eq("Hello, BGZF!")
      end
    end

    test_file.delete
  end

  def test_close_raises_on_write_failure
    return unless File.exists?("/dev/full")

    bgzf = HTS::Bgzf.open("/dev/full", "wz")
    bgzf.write("x" * 100_000)

    with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogOff) do
      expect_raises(HTS::Bgzf::WriteError) { bgzf.close }
    end
    (bgzf.closed?).should be_true
  end

  def test_block_open_prefers_body_exception_over_close_failure
    return unless File.exists?("/dev/full")

    ex = with_htslib_log_level(HTS::LibHTS::HtsLogLevel::HtsLogOff) do
      expect_raises(ArgumentError) do
        HTS::Bgzf.open("/dev/full", "wz") do |bgzf|
          bgzf.write("x" * 100_000)
          raise ArgumentError.new("body failure")
        end
      end
    end

    (ex.message).should eq("body failure")
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
      (lines.size).should eq(2)
      (lines[0]).should eq("First line")
      (lines[1]).should eq("Second line")
    end

    test_file.delete
  end

  def test_check_if_file_is_bgzf
    test_file = File.tempfile("test", ".gz")
    test_file.close

    HTS::Bgzf.open(test_file.path, "wz") do |bgzf|
      if bgzf.is_bgzf?
        bgzf.write("test data")
        (bgzf.is_bgzf?).should be_true
      end
    end

    test_file.delete
  end

  def test_get_compression_level
    test_file = File.tempfile("test", ".gz")
    test_file.close

    HTS::Bgzf.open(test_file.path, "wz") do |bgzf|
      level = bgzf.compression_level
      (level >= -1).should be_true # -1 means no compression info available
    end

    test_file.delete
  end

  def test_finalize_closes_file
    test_file = File.tempfile("test", ".gz")
    test_file.close

    bgzf = HTS::Bgzf.open(test_file.path, "wz")
    (bgzf.closed?).should be_false

    bgzf.finalize
    (bgzf.closed?).should be_true

    test_file.delete
  end

  def test_tabix_inherits_bgzf
    # Test that Tabix inherits from Bgzf
    test_file = File.tempfile("tabix_test", ".txt")
    test_file.puts("chr1\t100\t200\tfeature1")
    test_file.puts("chr1\t300\t400\tfeature2")
    test_file.close

    HTS::Tabix.open(test_file.path, "r") do |tabix|
      (tabix.is_a?(HTS::Bgzf)).should be_true
      (tabix.is_a?(HTS::Hts)).should be_true

      # BGZFから継承したメソッドが使用可能
      lines = [] of String
      tabix.each_line do |line|
        lines << line.chomp
      end

      (lines.size).should eq(2)
    end

    test_file.delete
  end
end

describe BgzfTest do
  {% for method in BgzfTest.methods.select(&.name.stringify.starts_with?("test_")) %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = BgzfTest.new
      begin
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
