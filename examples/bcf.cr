require "../src/hts"

bcf_path = File.expand_path("../../test/fixtures/test.bcf", __FILE__)

HTS::Bcf.open(bcf_path) do |bcf|
  bcf.each do |r|
    p chrom: r.chrom,
      pos: r.pos,
      id: r.id,
      qual: r.qual,
      filter: r.filter,
      ref: r.ref,
      alt: r.alt,
      alleles: r.alleles
  end
end
