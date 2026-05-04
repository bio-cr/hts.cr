require "../spec_helper"
require "../../src/hts/faidx"

class FaidxTest < HTSSpecCase
  FASTQ_TEXT = [
    "@chr1_read1",
    "TTGGATACCATTCCCCACAAAGGTACATAATGATGTCCTC",
    "+",
    "2222222222222222222222222222222222222222",
    "@chr2_read1",
    "CAATAGCGAGTTCGTTCAGTTTCAAGTTTTCTCATTGCGG",
    "+",
    "2222222222222222222222222222222222222222",
  ].join("\n") + "\n"

  @fasta : HTS::Faidx?
  @fastq : HTS::Faidx?
  @fastq_path : String?

  def setup
    file = File.tempfile("faidx_fastq", ".fastq")
    file << FASTQ_TEXT
    file.close
    @fastq_path = file.path
    HTS::Faidx.build_index(fastq_path)
  end

  def teardown
    @fasta.try &.close
    @fastq.try &.close
    if path = @fastq_path
      File.delete(path) if File.exists?(path)
      File.delete("#{path}.fai") if File.exists?("#{path}.fai")
      File.delete("#{path}.gzi") if File.exists?("#{path}.gzi")
    end
  end

  def fasta_path
    File.expand_path("../fixtures/random.fa", __DIR__)
  end

  def fastq_path
    @fastq_path.not_nil!
  end

  def fasta
    @fasta ||= HTS::Faidx.new(fasta_path)
  end

  def fastq
    @fastq ||= HTS::Faidx.new(fastq_path, format: :fastq, auto_build: false)
  end

  def test_new
    f = HTS::Faidx.new(fasta_path)
    expect_instance_of HTS::Faidx, f
    f.close
  end

  def test_open
    f = HTS::Faidx.open(fasta_path)
    expect_instance_of HTS::Faidx, f
    f.close
  end

  def test_open_with_block
    HTS::Faidx.open(fasta_path) do |f|
      expect_instance_of HTS::Faidx, f
    end
  end

  def test_file_name
    expect_equal fasta_path, fasta.file_name
  end

  def test_format
    expect_equal :fasta, fasta.format
    expect_equal :fastq, fastq.format
  end

  def test_closed
    expect_false fasta.closed?
    fasta.close
    expect_true fasta.closed?
  end

  def test_size
    expect_equal 5, fasta.size
  end

  def test_length
    expect_equal 5, fasta.length
  end

  def test_names
    expect_equal ["chr1", "chr2", "chr3", "chr4", "chr5"], fasta.names
  end

  def test_has_seq
    expect_true fasta.has_seq?("chr1")
    expect_false fasta.has_seq?("chrX")
  end

  def test_seq_len
    expect_equal 500, fasta.seq_len("chr1")
    expect_raises(ArgumentError) { fasta.seq_len("chrX") }
  end

  def test_fetch_seq
    expect_equal "TTGTGGAGAC", fasta.fetch_seq("chr1", 0, 9)
    expect_equal "ACTTAGTTGA", fasta.fetch_seq("chr2", 10, 19)
  end

  def test_fetch_full_sequence
    expect_equal 500, fasta.fetch_seq("chr1").size
  end

  def test_fetch_qual
    expect_equal "2222222222222222222222222222222222222222", fastq.fetch_qual("chr1_read1")
    expect_equal "22222", fastq.fetch_qual("chr1_read1", 0, 4)
  end

  def test_fetch_qual_on_fasta_raises
    expect_raises(Exception) { fasta.fetch_qual("chr1") }
  end

  def test_invalid_range
    expect_raises(ArgumentError) { fasta.fetch_seq("chr1", -1, 10) }
    expect_raises(ArgumentError) { fasta.fetch_seq("chr1", 10, 5) }
    expect_raises(ArgumentError) { fasta.fetch_seq("chr1", 0, 500) }
  end

  def test_closed_object_raises
    fasta.close
    expect_raises(IO::Error) { fasta.size }
    expect_raises(IO::Error) { fasta.names }
    expect_raises(IO::Error) { fasta.has_seq?("chr1") }
    expect_raises(IO::Error) { fasta.seq_len("chr1") }
    expect_raises(IO::Error) { fasta.fetch_seq("chr1") }
  end

  def test_build_index
    file = File.tempfile("faidx_build", ".fa")
    file << ">chr1\nACGT\n"
    file.close
    begin
      HTS::Faidx.build_index(file.path)
      expect_true File.exists?("#{file.path}.fai")
    ensure
      File.delete(file.path) if File.exists?(file.path)
      File.delete("#{file.path}.fai") if File.exists?("#{file.path}.fai")
      File.delete("#{file.path}.gzi") if File.exists?("#{file.path}.gzi")
    end
  end
end

describe FaidxTest do
  {% for method in FaidxTest.methods.select { |method| method.name.stringify.starts_with?("test_") } %}
    it {{ method.name.stringify[5..].gsub(/_/, " ") }} do
      spec_case = FaidxTest.new
      run_spec_case(spec_case) do
        spec_case.{{ method.name.id }}
      end
    end
  {% end %}
end
