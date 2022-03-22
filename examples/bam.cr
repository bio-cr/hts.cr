require "../src/hts"

bam_path = File.expand_path("../../test/fixtures/poo.sort.bam", __FILE__)

HTS::Bam.open(bam_path) do |b|
  b.each do |r|
    p name: r.qname,
      flag: r.flag.value,
      pos: r.start + 1,
      mpos: r.mate_start + 1,
      mqual: r.mapping_quality,
      seq: r.sequence,
      cigar: r.cigar,
      qual: r.base_qualities.map { |i| (i + 33).chr }.join
  end
end
