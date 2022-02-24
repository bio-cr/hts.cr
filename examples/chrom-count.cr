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

bam = HTS::Bam.open(fname, threads: nthreads, index: false)

chroms = bam.map do |r|
  chr = r.chrom
  chr == "" ? "*" : chr
end

puts chroms.tally
           .map { |i| i.join("\t") }
           .join("\n")

