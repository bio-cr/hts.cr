require "../src/hts/bam"
require "option_parser"

nthreads = 0

OptionParser.parse do |parser|
  parser.banner = "Usage: chrom-count [options] <bam_file>"
  parser.on("-t NUM", "--threads NUM") { |v| nthreads = v.to_i }
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

bam = HTS::Bam.open(fname, threads: nthreads)

# Simple way

# puts bam.map { |r|
#        chr = r.chrom
#        chr == "" ? "*" : chr
#      }.tally
#       .map { |i| i.join("\t") }
#       .join("\n")\

# Want to make it even faster?
# Use tid instead of chrom to make it even faster.

puts bam.map { |r| r.tid }
  .tally
  .map { |tid, num|
    ptr = HTS::LibHTS.sam_hdr_tid2name(bam.header.struct, tid)
    chrom = ptr.null? ? "*" : String.new(ptr)
    "#{chrom}\t#{num}"
  }.join("\n")
