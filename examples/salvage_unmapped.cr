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

def terminal_softclip_at_least?(record : HTS::Bam::Record, min_softclip : UInt32) : Bool
  op_count = record.cigar_size
  index = 0_u32

  record.each_cigar do |op, len|
    return true if op == 'S' && len >= min_softclip && (index == 0 || index + 1 == op_count)

    index += 1
  end

  false
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

def fastq_sequence(record : HTS::Bam::Record, reverse_read : Bool) : String
  sequence = record.seq
  return sequence unless reverse_read

  # BAM stores mapped reverse-strand SEQ in alignment orientation.
  # FASTQ should be restored to the original read orientation.
  reverse_complement(sequence)
end

def fastq_quality(record : HTS::Bam::Record, missing_quality : String, reverse_read : Bool) : String
  quality = record.qual_string
  return missing_quality * record.len if quality == "*"
  return quality unless reverse_read

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
min_softclip_u32 = min_softclip.to_u32
writer = if path = output_path
           Fastx::Fastq::Writer.new(path)
         else
           Fastx::Fastq::Writer.new(STDOUT)
         end

total_records = 0_u64
emitted_records = 0_u64
emitted_unmapped = 0_u64
emitted_softclip = 0_u64
skipped_empty = 0_u64
skipped_short = 0_u64
skipped_secondary_or_supplementary = 0_u64
skipped_qcfail = 0_u64
skipped_duplicate = 0_u64
skipped_low_mapq = 0_u64
skipped_no_terminal_softclip = 0_u64

begin
  HTS::Bam.open(input_path, threads: threads) do |bam|
    bam.each do |record|
      total_records += 1

      if record.len == 0
        skipped_empty += 1
        next
      end

      if record.len < min_read_length
        skipped_short += 1
        next
      end

      if record.secondary? || record.supplementary?
        skipped_secondary_or_supplementary += 1
        next
      end

      if !include_qcfail && record.qcfail?
        skipped_qcfail += 1
        next
      end

      if !include_duplicates && record.duplicate?
        skipped_duplicate += 1
        next
      end

      unmapped = record.unmapped?

      unless unmapped
        if record.mapq < min_mapq
          skipped_low_mapq += 1
          next
        end

        unless terminal_softclip_at_least?(record, min_softclip_u32)
          skipped_no_terminal_softclip += 1
          next
        end
      end

      emitted_records += 1
      if unmapped
        emitted_unmapped += 1
      else
        emitted_softclip += 1
      end

      reverse_read = !unmapped && record.reverse?

      writer.write(
        fastq_name(record, append_read_number),
        fastq_sequence(record, reverse_read),
        fastq_quality(record, missing_quality, reverse_read)
      )
    end
  end
ensure
  writer.close
end

STDERR.puts "salvage_unmapped summary"
STDERR.puts "  input: #{input_path}"
STDERR.puts "  records: #{total_records}"
STDERR.puts "  emitted: #{emitted_records}"
STDERR.puts "    unmapped: #{emitted_unmapped}"
STDERR.puts "    softclip: #{emitted_softclip}"
STDERR.puts "  skipped:"
STDERR.puts "    empty sequence: #{skipped_empty}"
STDERR.puts "    shorter than --min-read-length: #{skipped_short}"
STDERR.puts "    secondary/supplementary: #{skipped_secondary_or_supplementary}"
STDERR.puts "    QC-fail: #{skipped_qcfail}" unless include_qcfail
STDERR.puts "    duplicate: #{skipped_duplicate}" unless include_duplicates
STDERR.puts "    low MAPQ: #{skipped_low_mapq}" if min_mapq > 0
STDERR.puts "    no terminal softclip >= #{min_softclip}: #{skipped_no_terminal_softclip}"
