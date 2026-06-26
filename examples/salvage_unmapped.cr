require "option_parser"
require "fastx"
require "../src/hts"

# Extract reads as FASTQ when they are:
#   - unmapped
#   - mapped with a large left or right terminal soft-clipped segment

def valid_quality_char?(char : String) : Bool
  return false unless char.bytesize == 1

  byte = char.to_slice[0]
  byte >= 33 && byte <= 126
end

def terminal_softclip_lengths(record : HTS::Bam::Record) : Tuple(UInt32, UInt32)
  left = 0_u32
  right = 0_u32
  op_count = record.cigar_size
  index = 0_u32

  record.each_cigar do |op, len|
    left = len if index == 0 && op == 'S'
    right = len if index + 1 == op_count && op == 'S'
    index += 1
  end

  {left, right}
end

def fastq_name(record : HTS::Bam::Record, append_read_number : Bool) : String
  name = record.qname
  return name unless append_read_number

  return "#{name}/1" if record.read1?
  return "#{name}/2" if record.read2?

  name
end

# Lookup table mapping each byte to its IUPAC complement.
# Unlisted bytes (e.g. 'N', '=', lowercase) map to themselves.
COMPLEMENT_TABLE = Slice(UInt8).new(256, &.to_u8).tap do |table|
  {
    'A' => 'T', 'C' => 'G', 'G' => 'C', 'T' => 'A',
    'M' => 'K', 'K' => 'M', 'R' => 'Y', 'Y' => 'R',
    'S' => 'S', 'W' => 'W', 'V' => 'B', 'B' => 'V',
    'H' => 'D', 'D' => 'H',
  }.each { |base, comp| table[base.ord] = comp.ord.to_u8 }
end

def reverse_complement(sequence : String) : String
  String.build(sequence.bytesize) do |io|
    sequence.to_slice.reverse_each do |base|
      io.write_byte(COMPLEMENT_TABLE.to_unsafe[base])
    end
  end
end

def fastq_sequence(record : HTS::Bam::Record) : String
  sequence = record.seq
  return sequence if record.unmapped? || !record.reverse?

  # BAM stores mapped reverse-strand SEQ in alignment orientation.
  # FASTQ should be restored to the original read orientation.
  reverse_complement(sequence)
end

def fastq_quality(record : HTS::Bam::Record, missing_quality : String) : String
  quality = record.qual_string
  return missing_quality * record.len if quality == "*"
  return quality if record.unmapped? || !record.reverse?

  quality.reverse
end

min_softclip = 50
min_read_length = 0
min_mapq = 0
missing_quality = "!"
threads = 0
include_qcfail = false
include_duplicates = false
append_read_number = true
output_path : String? = nil

parser = OptionParser.parse do |parser_config|
  parser_config.banner = "Usage: #{File.basename(PROGRAM_NAME)} [options] <in.bam|in.cram|in.sam>"
  parser_config.on("-s N", "--min-softclip N", "Minimum terminal softclip length [50]") { |value| min_softclip = value.to_i }
  parser_config.on("-l N", "--min-read-length N", "Minimum read length to emit [0]") { |value| min_read_length = value.to_i }
  parser_config.on("-q N", "--min-mapq N", "Minimum MAPQ for mapped reads [0]") { |value| min_mapq = value.to_i }
  parser_config.on("--missing-quality CHAR", "FASTQ quality character for records with missing QUAL [!]") { |value| missing_quality = value }
  parser_config.on("-@ N", "--threads N", "Number of threads for BAM/CRAM decoding [0]") { |value| threads = value.to_i }
  parser_config.on("--include-qcfail", "Include reads flagged QC-fail") { include_qcfail = true }
  parser_config.on("--include-duplicates", "Include duplicate reads") { include_duplicates = true }
  parser_config.on("--no-append-read-number", "Do not append /1 or /2 to FASTQ names") { append_read_number = false }
  parser_config.on("-o PATH", "--output PATH", "Write FASTQ to PATH instead of stdout") { |value| output_path = value }
  parser_config.on("-h", "--help", "Show help") { puts parser_config; exit 0 }
end

if ARGV.size != 1
  STDERR.puts parser
  abort "ERROR: Specify one input SAM/BAM/CRAM file."
end

abort "ERROR: --min-softclip must be > 0" if min_softclip <= 0
abort "ERROR: --min-read-length must be >= 0" if min_read_length < 0
abort "ERROR: --min-mapq must be >= 0" if min_mapq < 0
abort "ERROR: --missing-quality must be a single ASCII quality character" unless valid_quality_char?(missing_quality)
abort "ERROR: --threads must be >= 0" if threads < 0

input_path = ARGV[0]
writer = if path = output_path
           Fastx::Fastq::Writer.new(path)
         else
           Fastx::Fastq::Writer.new(STDOUT)
         end

begin
  HTS::Bam.open(input_path, threads: threads) do |bam|
    bam.each do |record|
      next if record.len == 0
      next if record.len < min_read_length
      next if record.secondary? || record.supplementary?
      next if !include_qcfail && record.qcfail?
      next if !include_duplicates && record.duplicate?

      unless record.unmapped?
        next if record.mapq < min_mapq

        left_softclip, right_softclip = terminal_softclip_lengths(record)
        next unless left_softclip >= min_softclip || right_softclip >= min_softclip
      end

      writer.write(
        fastq_name(record, append_read_number),
        fastq_sequence(record),
        fastq_quality(record, missing_quality)
      )
    end
  end
ensure
  writer.close
end
