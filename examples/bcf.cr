require "../src/hts"

bcf_path = ARGV[0]? || File.expand_path("../spec/fixtures/test.bcf", __DIR__)

HTS::Bcf.open(bcf_path) do |bcf|
  bcf.each do |record|
    info = record.info
    format = record.format

    puts({
      chrom:     record.chrom,
      pos:       record.pos + 1,
      id:        record.id,
      qual:      record.qual.round(2),
      ref:       record.ref,
      alt:       record.alt,
      filters:   record.filter,
      info_dp:   info.get_int("DP"),
      info_vdb:  info.get_float("VDB"),
      genotypes: format.get_string("GT"),
    }.inspect)
  end
end
