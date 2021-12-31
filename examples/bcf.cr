require "../src/hts/bcf"

bcf_path = File.expand_path("../../test/fixtures/test.bcf", __FILE__)

bcf = HTS::Bcf.new(bcf_path)

bcf.each do |r|
  p pos: r.pos,
    start: r.start,
    stop: r.stop,
    id: r.id,
    qual: r.qual,
    filter: r.filter,
    ref: r.ref,
    alt: r.alt,
    alleles: r.alleles
end

bcf.close
