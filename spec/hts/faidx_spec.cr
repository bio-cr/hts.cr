require "../spec_helper"
require "../../src/hts/faidx"

class FaidxTest
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
    (f).should be_a(HTS::Faidx)
    f.close
  end

  def test_open
    f = HTS::Faidx.open(fasta_path)
    (f).should be_a(HTS::Faidx)
    f.close
  end

  def test_open_with_block
    HTS::Faidx.open(fasta_path) do |f|
      (f).should be_a(HTS::Faidx)
    end
  end

  def test_file_name
    (fasta.file_name).should eq(fasta_path)
  end

  def test_format
    (fasta.format).should eq(:fasta)
    (fastq.format).should eq(:fastq)
  end

  def test_closed
    (fasta.closed?).should be_false
    fasta.close
    (fasta.closed?).should be_true
  end

  def test_size
    (fasta.size).should eq(5)
  end

  def test_length
    (fasta.length).should eq(5)
  end

  def test_names
    (fasta.names).should eq(["chr1", "chr2", "chr3", "chr4", "chr5"])
  end

  def test_has_seq
    (fasta.has_seq?("chr1")).should be_true
    (fasta.has_seq?("chrX")).should be_false
  end

  def test_seq_len
    (fasta.seq_len("chr1")).should eq(500)
    expect_raises(ArgumentError) { fasta.seq_len("chrX") }
  end

  def test_fetch_seq
    (fasta.fetch_seq("chr1", 0, 9)).should eq("TTGTGGAGAC")
    (fasta.fetch_seq("chr2", 10, 19)).should eq("ACTTAGTTGA")
  end

  def test_fetch_full_sequence
    (fasta.fetch_seq("chr1").size).should eq(500)
  end

  def test_fetch_qual
    (fastq.fetch_qual("chr1_read1")).should eq("2222222222222222222222222222222222222222")
    (fastq.fetch_qual("chr1_read1", 0, 4)).should eq("22222")
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
      (File.exists?("#{file.path}.fai")).should be_true
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
        spec_case.setup
      begin
        spec_case.{{ method.name.id }}
      ensure
        spec_case.teardown
      end
    end
  {% end %}
end
