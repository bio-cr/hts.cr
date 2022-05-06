require "../src/hts"

if ARGV.empty?
  bam_path = File.expand_path("../test/fixtures/poo.sort.bam", __DIR__)
else
  bam_path = ARGV[0]
end

HTS::Bam.open(bam_path) do |b|
  b.each do |r|
    p name: r.qname,
      flag: r.flag.value,
      chrm: r.chrom,
      strt: r.pos + 1,
      mapq: r.mapq,
      cigr: r.cigar.to_s,
      mchr: r.mate_chrom,
      mpos: r.mpos + 1,
      isiz: r.isize,
      seqs: r.seq,
      qual: r.qual.map { |i| (i + 33).chr }.join,
      axMC: r.aux("MC")
  end
end
