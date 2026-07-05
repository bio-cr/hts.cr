require "option_parser"
require "../src/hts"

# Count REF, ALT, other bases, and deletions at biallelic SNV sites from a VCF.
#
# This is a Crystal implementation of the small htstools snp-pileup utility.
# It intentionally fixes a few sharp edges in the original C++ implementation:
# - MAPQ 0 reads are not discarded unless requested by the -q threshold.
# - deletion/refskip pileup entries are handled before reading query base quality.
# - supplementary alignments are excluded by default.

struct Options
  property? count_orphans : Bool = false
  property? gzip : Bool = false
  property? ignore_overlaps : Bool = false
  property? include_supplementary : Bool = false
  property min_base_quality : Int32 = 0
  property min_map_quality : Int32 = 0
  property min_read_counts : Array(Int32) = [] of Int32
  property max_depth : Int32 = 4000
  property? progress : Bool = false
  property pseudo_snps : Int32 = 0
  property threads : Int32 = 0
end

struct SnpSite
  getter tid : Int32
  getter chrom : String
  getter pos : Int64
  getter ref : Char
  getter alt : Char

  def initialize(@tid, @chrom, @pos, @ref, @alt)
  end

  def after?(other : SnpSite) : Bool
    @tid > other.tid || (@tid == other.tid && @pos > other.pos)
  end

  def label : String
    "#{@chrom}:#{@pos + 1}"
  end
end

struct Counts
  property refs : Int32 = 0
  property alts : Int32 = 0
  property errors : Int32 = 0
  property deletions : Int32 = 0

  def any_base? : Bool
    @refs > 0 || @alts > 0 || @errors > 0
  end
end

def chrom_to_tid(chrom : String, header : HTS::Bam::Header) : Int32
  tid = header.get_tid(chrom)
  return tid if tid >= 0

  if chrom.starts_with?("chr")
    tid = header.get_tid(chrom[3..])
    return tid if tid >= 0
  else
    tid = header.get_tid("chr#{chrom}")
    return tid if tid >= 0
  end

  -1
end

def count_valid_snps(vcf_path : String, header : HTS::Bam::Header) : Int64
  count = 0_i64
  HTS::Bcf.open(vcf_path) do |vcf|
    vcf.each do |record|
      alleles = record.alleles
      next unless alleles.size == 2
      next unless alleles[0].bytesize == 1 && alleles[1].bytesize == 1
      next if chrom_to_tid(record.chrom, header) < 0
      count += 1
    end
  end
  count
end

alias SnpMessage = (SnpSite | Exception)?

def start_snp_reader(vcf_path : String, header : HTS::Bam::Header) : Channel(SnpMessage)
  channel = Channel(SnpMessage).new(1)

  spawn do
    begin
      previous_site = nil
      HTS::Bcf.open(vcf_path) do |vcf|
        vcf.each do |record|
          alleles = record.alleles
          next unless alleles.size == 2
          next unless alleles[0].bytesize == 1 && alleles[1].bytesize == 1

          chrom = record.chrom
          tid = chrom_to_tid(chrom, header)
          next if tid < 0

          site = SnpSite.new(tid, chrom, record.pos.to_i64, alleles[0][0], alleles[1][0])
          if previous = previous_site
            unless site.after?(previous)
              raise ArgumentError.new(
                "VCF SNP records must be sorted strictly by BAM header order and position; " \
                "#{site.label} appears after #{previous.label}"
              )
            end
          end

          previous_site = site
          channel.send site
        end
      end
      channel.send nil
    rescue ex
      channel.send ex
    end
  end

  channel
end

def next_snp(channel : Channel(SnpMessage)) : SnpSite?
  message = channel.receive
  case message
  when Exception
    raise message
  when SnpSite
    message
  end
end

def count_site(column : HTS::Bam::Pileup::Column, ref : Char, alt : Char, min_base_quality : Int32) : Counts
  counts = Counts.new
  column.each do |aln|
    next if aln.refskip?

    if aln.del?
      counts.deletions += 1
      next
    end

    base = aln.base
    qual = aln.base_qual
    next unless base && qual
    next if qual.to_i < min_base_quality

    case base.upcase
    when ref.upcase
      counts.refs += 1
    when alt.upcase
      counts.alts += 1
    else
      counts.errors += 1
    end
  end
  counts
end

def count_pseudo_site(column : HTS::Bam::Pileup::Column, min_base_quality : Int32) : Counts
  counts = Counts.new
  column.each do |aln|
    next if aln.refskip? || aln.del?

    qual = aln.base_qual
    next unless qual
    next if qual.to_i < min_base_quality

    counts.refs += 1
  end
  counts
end

alias Output = IO | HTS::Bgzf

def write_header(io : Output, n_inputs : Int32) : Nil
  io << "Chromosome,Position,Ref,Alt"
  n_inputs.times do |i|
    j = i + 1
    io << ",File#{j}R,File#{j}A,File#{j}E,File#{j}D"
  end
  io << '\n'
end

def write_counts(io : Output, chrom : String, pos : Int64, ref : Char | String, alt : Char | String, counts : Array(Counts)) : Nil
  io << chrom << ',' << (pos + 1) << ',' << ref << ',' << alt
  counts.each do |count|
    io << ',' << count.refs << ',' << count.alts << ',' << count.errors << ',' << count.deletions
  end
  io << '\n'
end

def compact_counts(counts : Array(Counts?)) : Array(Counts)?
  valid_counts = [] of Counts
  counts.each do |count|
    return unless count

    valid_counts << count
  end
  valid_counts
end

# ameba:disable Metrics/CyclomaticComplexity
def write_pileup_counts(io : Output, bams : Array(HTS::Bam), options : Options, bam_header : HTS::Bam::Header,
                        snp_reader : Channel(SnpMessage), current_snp : SnpSite?, total_snps : Int64) : Nil
  processed_snps = 0_i64

  write_header(io, bams.size)

  exclude = HTS::Bam::Flag::UNMAP | HTS::Bam::Flag::QCFAIL |
            HTS::Bam::Flag::SECONDARY | HTS::Bam::Flag::DUP
  exclude = exclude | HTS::Bam::Flag::SUPPLEMENTARY unless options.include_supplementary?

  filter = HTS::Bam::Pileup::Filter.new(
    min_mapq: options.min_map_quality,
    exclude_flags: exclude,
    count_orphans: options.count_orphans?
  )

  HTS::Bam::Mpileup.open(
    bams,
    maxcnt: options.max_depth,
    overlaps: !options.ignore_overlaps?,
    filter: filter
  ) do |mpileup|
    n_inputs = bams.size
    mpileup.each do |position|
      tid = position.tid
      pos = position.pos
      matched_snp = false

      while snp = current_snp
        break if snp.tid > tid || (snp.tid == tid && snp.pos >= pos)

        processed_snps += 1
        current_snp = next_snp(snp_reader)
      end

      if snp = current_snp
        if snp.tid == tid && snp.pos == pos
          counts = Array(Counts?).new(n_inputs)
          n_inputs.times do |index|
            column = position[index]
            if column.depth >= options.min_read_counts[index]
              counts << count_site(column, snp.ref, snp.alt, options.min_base_quality)
            else
              counts << nil
            end
          end

          if valid_counts = compact_counts(counts)
            if valid_counts.any?(&.any_base?)
              write_counts(io, bam_header.target_name(tid), pos, snp.ref, snp.alt, valid_counts)
            end
          end

          processed_snps += 1
          if options.progress? && total_snps > 0
            percent = (processed_snps * 100) // total_snps
            STDERR.print "\r#{percent}%"
          end
          current_snp = next_snp(snp_reader)
          matched_snp = true
        end
      end

      if !matched_snp && options.pseudo_snps > 0 && ((pos + 1) % options.pseudo_snps == 0)
        counts = Array(Counts?).new(n_inputs)
        n_inputs.times do |index|
          column = position[index]
          if column.depth >= options.min_read_counts[index]
            counts << count_pseudo_site(column, options.min_base_quality)
          else
            counts << nil
          end
        end

        if valid_counts = compact_counts(counts)
          if valid_counts.any? { |count| count.refs > 0 }
            write_counts(io, bam_header.target_name(tid), pos, ".", ".", valid_counts)
          end
        end
      end
    end
  end
end

# ameba:enable Metrics/CyclomaticComplexity

options = Options.new

parser = OptionParser.new do |parser_config|
  parser_config.banner = "Usage: snp_pileup [options] <variants.vcf|bcf> <output.csv> <in1.bam|cram> [in2.bam|cram ...]"
  parser_config.on("-A", "--count-orphans", "Count anomalous read pairs") { options.count_orphans = true }
  parser_config.on("-d", "--max-depth DEPTH", "Maximum per-file depth (default: 4000)") { |value| options.max_depth = value.to_i }
  parser_config.on("-g", "--gzip", "Compress output with BGZF") { options.gzip = true }
  parser_config.on("-p", "--progress", "Show progress; scans the VCF once before counting") { options.progress = true }
  parser_config.on("-P", "--pseudo-snps MULTIPLE", "Add pseudo records every MULTIPLE covered positions") { |value| options.pseudo_snps = value.to_i }
  parser_config.on("-q", "--min-map-quality QUALITY", "Minimum mapping quality (default: 0)") { |value| options.min_map_quality = value.to_i }
  parser_config.on("-Q", "--min-base-quality QUALITY", "Minimum base quality (default: 0)") { |value| options.min_base_quality = value.to_i }
  parser_config.on("-r", "--min-read-counts READS", "Comma-separated minimum raw pileup depths per input") do |value|
    options.min_read_counts = value.split(',').map(&.to_i)
  end
  parser_config.on("-s", "--include-supplementary", "Include supplementary alignments") { options.include_supplementary = true }
  parser_config.on("-x", "--ignore-overlaps", "Disable paired-read overlap detection") { options.ignore_overlaps = true }
  parser_config.on("-@", "--threads THREADS", "Threads for decompression") { |value| options.threads = value.to_i }
  parser_config.on("-h", "--help", "Show this help") do
    puts parser_config
    exit
  end
end

parser.parse

if ARGV.size < 3
  STDERR.puts parser
  abort "ERROR: specify VCF/BCF, output, and at least one BAM/CRAM input."
end

vcf_path = ARGV.shift
out_path = ARGV.shift
bam_paths = ARGV.dup

if options.min_read_counts.empty?
  options.min_read_counts = Array.new(bam_paths.size, 0)
elsif options.min_read_counts.size != bam_paths.size
  abort "ERROR: --min-read-counts has #{options.min_read_counts.size} values, but #{bam_paths.size} input files were given."
end

if options.max_depth < 1
  abort "ERROR: --max-depth must be positive."
end

if options.pseudo_snps < 0
  abort "ERROR: --pseudo-snps must be non-negative."
end

out_path = "#{out_path}.gz" if options.gzip? && !out_path.ends_with?(".gz")
abort "ERROR: output file already exists: #{out_path}" if File.exists?(out_path)

bams = bam_paths.map { |path| HTS::Bam.new(path, threads: options.threads) }

begin
  bam_header = bams.first.header
  total_snps = options.progress? ? count_valid_snps(vcf_path, bam_header) : 0_i64
  snp_reader = start_snp_reader(vcf_path, bam_header)
  current_snp = next_snp(snp_reader)

  if options.gzip?
    HTS::Bgzf.open(out_path, "wz") do |io|
      write_pileup_counts(io, bams, options, bam_header, snp_reader, current_snp, total_snps)
    end
  else
    File.open(out_path, "w") do |io|
      write_pileup_counts(io, bams, options, bam_header, snp_reader, current_snp, total_snps)
    end
  end

  STDERR.puts if options.progress?
ensure
  bams.each(&.close)
end
