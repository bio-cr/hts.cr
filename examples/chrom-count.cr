require "../src/hts"
require "option_parser"

nthreads = 0

OptionParser.parse do |parser|
  parser.banner = "Usage: chrom-count [options] <bam_file>"
  parser.on("-t", "--threads NUM") { |v| nthreads = v.to_i }
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end
  parser.invalid_option do
    puts parser
    exit 1
  end
  if ARGV.empty?
    puts parser
    exit 1
  end
end

fname = ARGV[0]

HTS::Bam.open(fname, threads: nthreads) do |bam|
  counts = Hash(Int32, Int32).new(0)
  bam.each { |record| counts[record.tid] += 1 }

  rows = counts.map do |tid, num|
    chrom = tid == -1 ? "*" : bam.header.target_name(tid)
    "#{chrom}\t#{num}"
  end
  puts rows.join("\n")
end
