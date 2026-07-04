require "option_parser"
require "../src/hts"

# Usage:
#   crystal run examples/pileup_counts.cr -- [options] input.bam
#
# Output columns:
#   chrom, pos(1-based), depth, A, C, G, T, N, n_del, n_refskip

output_path = nil.as(String?)
maxcnt = nil.as(Int32?)
region = nil.as(String?)
threads = 0

parser = OptionParser.parse do |parser_config|
  parser_config.banner = "Usage: pileup_counts [options] <in.bam|in.cram>"
  parser_config.on("--maxcnt=N", "Max reads per column") { |value| maxcnt = value.to_i }
  parser_config.on("-r REGION", "--region=REGION", "Region (e.g., chr1:1000-2000)") { |value| region = value }
  parser_config.on("-o FILE", "--output=FILE", "Output TSV (default: stdout)") { |value| output_path = value }
  parser_config.on("-@ THREADS", "--threads=THREADS", "Number of threads for decompression (default: 0)") { |value| threads = value.to_i }
  parser_config.on("-h", "--help", "Show help") { puts parser_config; exit 0 }
end

if ARGV.size != 1
  STDERR.puts parser
  abort "ERROR: Specify one input BAM/CRAM file."
end

in_path = ARGV.shift

def run_pileup(io : IO, in_path : String, region : String?, maxcnt : Int32?, threads : Int32)
  HTS::Bam.open(in_path, threads: threads) do |bam|
    io.puts ["chrom", "pos", "depth", "A", "C", "G", "T", "N", "n_del", "n_refskip"].join('\t')

    HTS::Bam::Pileup.open(bam, region, maxcnt) do |pileup|
      pileup.each do |col|
        chrom = col.chrom.empty? ? "*" : col.chrom
        pos1 = col.pos + 1

        a = c = g = t = n = 0
        n_del = 0
        n_refskip = 0

        col.each do |aln|
          next n_refskip += 1 if aln.refskip?
          next n_del += 1 if aln.del?

          case aln.base.try(&.upcase)
          when 'A' then a += 1
          when 'C' then c += 1
          when 'G' then g += 1
          when 'T' then t += 1
          else          n += 1
          end
        end

        io.puts "#{chrom}\t#{pos1}\t#{col.depth}\t#{a}\t#{c}\t#{g}\t#{t}\t#{n}\t#{n_del}\t#{n_refskip}"
      end
    end
  end
rescue IO::Error
  # Ignore broken pipe errors (e.g., when piped to head)
end

if path = output_path
  File.open(path, "w") do |io|
    run_pileup(io, in_path, region, maxcnt, threads)
  end
else
  run_pileup(STDOUT, in_path, region, maxcnt, threads)
end
