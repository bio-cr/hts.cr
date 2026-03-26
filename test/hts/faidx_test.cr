require "minitest/autorun"
require "../../src/hts/faidx"

class FaidxTest < Minitest::Test
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
    assert_instance_of HTS::Faidx, f
    f.close
  end

  def test_open
    f = HTS::Faidx.open(fasta_path)
    assert_instance_of HTS::Faidx, f
    f.close
  end

  def test_open_with_block
    HTS::Faidx.open(fasta_path) do |f|
      assert_instance_of HTS::Faidx, f
    end
  end

  def test_file_name
    assert_equal fasta_path, fasta.file_name
  end

  def test_format
    assert_equal :fasta, fasta.format
    assert_equal :fastq, fastq.format
  end

  def test_closed
    refute fasta.closed?
    fasta.close
    assert fasta.closed?
  end

  def test_size
    assert_equal 5, fasta.size
  end

  def test_length
    assert_equal 5, fasta.length
  end

  def test_names
    assert_equal ["chr1", "chr2", "chr3", "chr4", "chr5"], fasta.names
  end

  def test_has_seq
    assert fasta.has_seq?("chr1")
    refute fasta.has_seq?("chrX")
  end

  def test_seq_len
    assert_equal 500, fasta.seq_len("chr1")
    assert_raises(ArgumentError) { fasta.seq_len("chrX") }
  end

  def test_fetch_seq
    assert_equal "TTGTGGAGAC", fasta.fetch_seq("chr1", 0, 9)
    assert_equal "ACTTAGTTGA", fasta.fetch_seq("chr2", 10, 19)
  end

  def test_fetch_full_sequence
    assert_equal 500, fasta.fetch_seq("chr1").size
  end

  def test_fetch_qual
    assert_equal "2222222222222222222222222222222222222222", fastq.fetch_qual("chr1_read1")
    assert_equal "22222", fastq.fetch_qual("chr1_read1", 0, 4)
  end

  def test_fetch_qual_on_fasta_raises
    assert_raises(Exception) { fasta.fetch_qual("chr1") }
  end

  def test_invalid_range
    assert_raises(ArgumentError) { fasta.fetch_seq("chr1", -1, 10) }
    assert_raises(ArgumentError) { fasta.fetch_seq("chr1", 10, 5) }
    assert_raises(ArgumentError) { fasta.fetch_seq("chr1", 0, 500) }
  end

  def test_closed_object_raises
    fasta.close
    assert_raises(IO::Error) { fasta.size }
    assert_raises(IO::Error) { fasta.names }
    assert_raises(IO::Error) { fasta.has_seq?("chr1") }
    assert_raises(IO::Error) { fasta.seq_len("chr1") }
    assert_raises(IO::Error) { fasta.fetch_seq("chr1") }
  end

  def test_build_index
    file = File.tempfile("faidx_build", ".fa")
    file << ">chr1\nACGT\n"
    file.close
    begin
      HTS::Faidx.build_index(file.path)
      assert File.exists?("#{file.path}.fai")
    ensure
      File.delete(file.path) if File.exists?(file.path)
      File.delete("#{file.path}.fai") if File.exists?("#{file.path}.fai")
      File.delete("#{file.path}.gzi") if File.exists?("#{file.path}.gzi")
    end
  end
end
