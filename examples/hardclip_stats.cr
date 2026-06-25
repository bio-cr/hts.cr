require "option_parser"
require "../src/hts"

# Usage:
#   crystal run examples/hardclip_stats.cr -- [options] input.bam

class HardclipStats
  property records : UInt64 = 0_u64
  property hardclip_records : UInt64 = 0_u64
  property left_hardclip_records : UInt64 = 0_u64
  property right_hardclip_records : UInt64 = 0_u64
  property both_hardclip_records : UInt64 = 0_u64
  property hardclip_bases : UInt64 = 0_u64

  def add(record : HTS::Bam::Record)
    has_hardclip = false
    left_hardclip = false
    right_hardclip = false
    hardclip_bases_in_record = 0_u64
    cigar_size = record.cigar_size
    cigar_index = 0_u32

    @records += 1

    record.each_cigar do |op, len|
      if op == 'H'
        has_hardclip = true
        hardclip_bases_in_record += len.to_u64
        left_hardclip = true if cigar_index == 0
        right_hardclip = true if cigar_index + 1 == cigar_size
      end
      cigar_index += 1
    end

    return unless has_hardclip

    @hardclip_records += 1
    @hardclip_bases += hardclip_bases_in_record
    @left_hardclip_records += 1 if left_hardclip
    @right_hardclip_records += 1 if right_hardclip
    @both_hardclip_records += 1 if left_hardclip && right_hardclip
  end

  def percent : Float64
    records.zero? ? 0.0 : hardclip_records * 100.0 / records
  end
end

class HardclipOptions
  property threads : Int32 = 0
  property min_mapq : Int32 = 0
  property? primary_only : Bool = false
  property input : String?
end

def parse_options : HardclipOptions
  options = HardclipOptions.new

  parser = OptionParser.parse do |parser_config|
    parser_config.banner = "Usage: hardclip_stats [options] <in.bam|in.cram|in.sam>"
    parser_config.on("-@ N", "--threads N", "Number of threads for BAM/CRAM decoding") { |value| options.threads = value.to_i }
    parser_config.on("-q N", "--min-mapq N", "Minimum MAPQ for mapped records") { |value| options.min_mapq = value.to_i }
    parser_config.on("-p", "--primary-only", "Only inspect primary records (-F 0x900)") { options.primary_only = true }
    parser_config.on("-h", "--help", "Show help") { puts parser_config; exit 0 }
  end

  if ARGV.size != 1
    STDERR.puts parser
    abort "ERROR: Specify one input SAM/BAM/CRAM file."
  end

  options.input = ARGV[0]
  options
end

def validate_options!(options : HardclipOptions)
  abort "ERROR: --threads must be >= 0" if options.threads < 0
  abort "ERROR: --min-mapq must be >= 0" if options.min_mapq < 0
end

def mapped?(flag : UInt16) : Bool
  (flag & HTS::LibHTS2::BAM_FUNMAP) == 0
end

def secondary?(flag : UInt16) : Bool
  (flag & HTS::LibHTS2::BAM_FSECONDARY) != 0
end

def supplementary?(flag : UInt16) : Bool
  (flag & HTS::LibHTS2::BAM_FSUPPLEMENTARY) != 0
end

def pass_filters?(record : HTS::Bam::Record, options : HardclipOptions) : Bool
  flag = record.flag_value
  return false if options.primary_only? && (secondary?(flag) || supplementary?(flag))
  return false if mapped?(flag) && record.mapq < options.min_mapq

  true
end

def collect_hardclip_stats(input : String, options : HardclipOptions)
  total = HardclipStats.new
  primary = HardclipStats.new
  secondary = HardclipStats.new
  supplementary = HardclipStats.new
  unmapped = HardclipStats.new

  HTS::Bam.open(input, threads: options.threads) do |bam|
    bam.each do |record|
      next unless pass_filters?(record, options)

      flag = record.flag_value
      total.add(record)

      if !mapped?(flag)
        unmapped.add(record)
      elsif secondary?(flag)
        secondary.add(record)
      elsif supplementary?(flag)
        supplementary.add(record)
      else
        primary.add(record)
      end
    end
  end

  {
    {"total", total},
    {"primary", primary},
    {"secondary", secondary},
    {"supplementary", supplementary},
    {"unmapped", unmapped},
  }
end

def comma(value) : String
  text = value.to_s
  return text if text.size <= 3

  String.build do |io|
    first_group = text.size % 3
    first_group = 3 if first_group == 0
    io << text[0, first_group]

    index = first_group
    while index < text.size
      io << ','
      io << text[index, 3]
      index += 3
    end
  end
end

def print_summary(input : String, options : HardclipOptions, rows)
  puts "Hard-clip summary"
  puts "Input:   #{input}"
  puts "Filters: primary_only=#{options.primary_only?}, min_mapq=#{options.min_mapq}, threads=#{options.threads}"
  puts

  printf "%-15s %14s %14s %10s %16s %12s %12s %12s\n",
    "category", "records", "H records", "H %", "H bases", "left H", "right H", "both H"
  puts "-" * 112

  rows.each do |name, stats|
    printf "%-15s %14s %14s %9.4f%% %16s %12s %12s %12s\n",
      name,
      comma(stats.records),
      comma(stats.hardclip_records),
      stats.percent,
      comma(stats.hardclip_bases),
      comma(stats.left_hardclip_records),
      comma(stats.right_hardclip_records),
      comma(stats.both_hardclip_records)
  end
end

options = parse_options
validate_options!(options)
input = options.input || abort "ERROR: Specify one input SAM/BAM/CRAM file."
rows = collect_hardclip_stats(input, options)
print_summary(input, options, rows)
