require "../src/hts"

bam_path = ARGV[0]? || File.expand_path("../spec/fixtures/poo.sort.bam", __DIR__)

HTS::Bam.open(bam_path) do |b|
  b.each do |r|
    puts({
      name:        r.qname,
      flag:        r.flag.value,
      chrom:       r.chrom,
      start:       r.pos + 1,
      mapq:        r.mapq,
      cigar:       r.cigar.to_s,
      mate_chrom:  r.mate_chrom,
      mate_start:  r.mate_pos >= 0 ? r.mate_pos + 1 : nil,
      insert_size: r.insert_size,
      seq:         r.seq,
      qual:        r.qual_string,
      nm:          r.aux_int("NM"),
      mc:          r.aux_string("MC"),
    }.inspect)
  end
end
