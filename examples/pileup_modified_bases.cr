require "option_parser"
require "../src/hts"

# Usage:
#   crystal run examples/pileup_modified_bases.cr -- [options] input.bam
#
# Output columns:
#   chrom, pos(1-based), base, strand, modification, quality

region = nil.as(String?)

parser = OptionParser.parse do |p|
  p.banner = "Usage: pileup_modified_bases [options] <in.bam|in.cram>"
  p.on("-r REGION", "--region=REGION", "Region (e.g., chr1:100-200)") { |v| region = v }
  p.on("-h", "--help", "Show help") { puts p; exit 0 }
end

if ARGV.size != 1
  STDERR.puts parser
  abort "ERROR: Specify one input BAM/CRAM file."
end

in_path = ARGV.shift

HTS::Bam.open(in_path) do |bam|
  HTS::Bam::Pileup.open(bam, region) do |pileup|
    pileup.each do |column|
      column.alignments.each do |pileup_read|
        next if pileup_read.del?

        mods = pileup_read.record.modified_bases
        next unless mods

        mods.each do |(base, strand, mod_type), positions|
          positions.each do |pos, qual|
            if pos == pileup_read.query_pos
              puts "Position #{column.pos}: " \
                   "Base #{base.chr}, Strand #{strand}, " \
                   "Modification #{mod_type.chr}, Quality #{qual}"
            end
          end
        end
      end
    end
  end
rescue IO::Error
  # Ignore broken pipe errors (e.g., when piped to head)
end
