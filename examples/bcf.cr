require "../src/hts"

bcf_path = ARGV[0]? || File.expand_path("../spec/fixtures/test.bcf", __DIR__)

HTS::Bcf.open(bcf_path) do |bcf|
  bcf.each do |r|
    info = r.info
    format = r.format

    puts({
      chrom:     r.chrom,
      pos:       r.pos + 1,
      id:        r.id,
      qual:      r.qual.round(2),
      ref:       r.ref,
      alt:       r.alt,
      filter:    r.filter,
      info_dp:   info["DP"],
      info_mq:   info["MQ"],
      genotypes: format.get_string("GT"),
    }.inspect)
  end
end
