require "../src/hts"

bam_path = ARGV[0]? || File.expand_path("../spec/fixtures/poo.sort.bam", __DIR__)

HTS::Bam.open(bam_path) do |bam|
  bam.each do |record|
    puts({
      name:        record.qname,
      flag:        record.flag.value,
      chrom:       record.chrom,
      start:       record.pos + 1,
      mapq:        record.mapq,
      cigar:       record.cigar.to_s,
      mate_chrom:  record.mate_chrom,
      mate_start:  record.mate_pos >= 0 ? record.mate_pos + 1 : nil,
      insert_size: record.insert_size,
      seq:         record.seq,
      qual:        record.qual_string,
      nm:          record.aux_int("NM"),
      mc:          record.aux_string("MC"),
    }.inspect)
  end
end
