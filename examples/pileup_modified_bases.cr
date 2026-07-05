require "option_parser"
require "../src/hts"

# Usage:
#   crystal run examples/pileup_modified_bases.cr -- [options] input.bam
#
# Output columns:
#   chrom, pos(1-based), base, strand, modification, quality

region = nil.as(String?)

parser = OptionParser.parse do |parser_config|
  parser_config.banner = "Usage: pileup_modified_bases [options] <in.bam|in.cram>"
  parser_config.on("-r", "--region REGION", "Region (e.g., chr1:100-200)") { |value| region = value }
  parser_config.on("-h", "--help", "Show help") { puts parser_config; exit 0 }
end

if ARGV.size != 1
  STDERR.puts parser
  abort "ERROR: Specify one input BAM/CRAM file."
end

in_path = ARGV.shift

HTS::Bam.open(in_path) do |bam|
  HTS::Bam::Pileup.open(bam, region) do |pileup|
    pileup.each do |column|
      column.each do |pileup_read|
        next if pileup_read.del? || pileup_read.refskip?

        # Get base modification information for this read
        base_mod = pileup_read.record.base_mod
        qpos = pileup_read.query_pos
        next if qpos < 0

        # Check for modifications at the current query position
        if mod_pos = base_mod[qpos]
          mod_pos.modifications.each do |mod|
            prob = mod.probability
            prob_str = prob ? prob.round(3).to_s : "N/A"
            chrom = column.chrom.empty? ? "*" : column.chrom
            puts "#{chrom}\t#{column.pos + 1}\t#{mod.canonical}\t#{pileup_read.record.strand}\t#{mod.code}\t#{prob_str}"
          end
        end
      end
    end
  end
rescue IO::Error
  # Ignore broken pipe errors (e.g., when piped to head)
end
