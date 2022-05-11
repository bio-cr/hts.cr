require "../src/hts"

if ARGV.empty?
  bcf_path = File.expand_path("../../test/fixtures/test.bcf", __FILE__)
else
  bcf_path = ARGV[0]
end

HTS::Bcf.open(bcf_path) do |bcf|
  bcf.each do |r|
    p chrom: r.chrom,
      pos: r.pos,
      id: r.id,
      qual: r.qual.round(2),
      ref: r.ref,
      alt: r.alt,
      filter: r.alleles,
      info: r.info,
      format: r.format
  end
end
