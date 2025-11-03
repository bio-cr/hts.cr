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

parser = OptionParser.parse do |p|
  p.banner = "Usage: pileup_counts [options] <in.bam|in.cram>"
  p.on("--maxcnt=N", "Max reads per column") { |v| maxcnt = v.to_i }
  p.on("-r REGION", "--region=REGION", "Region (e.g., chr1:1000-2000)") { |v| region = v }
  p.on("-o FILE", "--output=FILE", "Output TSV (default: stdout)") { |v| output_path = v }
  p.on("-h", "--help", "Show help") { puts p; exit 0 }
end

if ARGV.size != 1
  STDERR.puts parser
  abort "ERROR: Specify one input BAM/CRAM file."
end

in_path = ARGV.shift

def run_pileup(io : IO, in_path : String, region : String?, maxcnt : Int32?)
  HTS::Bam.open(in_path) do |bam|
    io.puts ["chrom", "pos", "depth", "A", "C", "G", "T", "N", "n_del", "n_refskip"].join('\t')
    hdr_ptr = bam.header.to_unsafe

    HTS::Bam::Pileup.open(bam, region, maxcnt) do |pileup|
      pileup.each do |col|
        name_ptr = HTS::LibHTS.sam_hdr_tid2name(hdr_ptr, col.tid)
        chrom = name_ptr.null? ? col.tid.to_s : String.new(name_ptr)
        pos1 = col.pos + 1

        a = c = g = t = n = 0
        n_del = 0
        n_refskip = 0

        col.alignments.each do |aln|
          next n_refskip += 1 if aln.refskip?
          next n_del += 1 if aln.del?

          qpos = aln.query_pos
          seq = aln.record.seq

          if qpos >= 0 && qpos < seq.size
            case seq[qpos].upcase
            when 'A' then a += 1
            when 'C' then c += 1
            when 'G' then g += 1
            when 'T' then t += 1
            else          n += 1
            end
          else
            n += 1
          end
        end

        io.puts "#{chrom}\t#{pos1}\t#{col.depth}\t#{a}\t#{c}\t#{g}\t#{t}\t#{n}\t#{n_del}\t#{n_refskip}"
      end
    end
  end
rescue IO::Error
  # Ignore broken pipe errors (e.g., when piped to head)
end

if output_path
  File.open(output_path.not_nil!, "w") do |io|
    run_pileup(io, in_path, region, maxcnt)
  end
else
  run_pileup(STDOUT, in_path, region, maxcnt)
end
