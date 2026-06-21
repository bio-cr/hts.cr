# HTS.cr

[![CI](https://github.com/bio-cr/hts.cr/actions/workflows/ci.yml/badge.svg)](https://github.com/bio-cr/hts.cr/actions/workflows/ci.yml)
[![Slack](http://img.shields.io/badge/slack-bio--crystal-purple?labelColor=000000&logo=slack)](https://bio-crystal.slack.com/)
[![Docs Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://bio-cr.github.io/hts.cr/)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/bio-cr/hts.cr)
[![Lines of Code](https://img.shields.io/endpoint?url=https%3A%2F%2Ftokei.kojix2.net%2Fbadge%2Fgithub%2Fbio-cr%2Fhts.cr%2Flines)](https://tokei.kojix2.net/github/bio-cr/hts.cr)
[![DOI](https://zenodo.org/badge/351622305.svg)](https://doi.org/10.5281/zenodo.6462533)

HTS.cr provides [Crystal](https://github.com/crystal-lang/crystal) bindings for [HTSlib](https://github.com/samtools/htslib) that allow you to read and write file formats commonly used in genomics, such as [SAM, BAM, VCF, and BCF](http://samtools.github.io/hts-specs/).

## Requirements

- [Crystal](https://crystal-lang.org)
- [HTSlib](https://github.com/samtools/htslib)
  - Ubuntu : `apt install libhts-dev`
  - macOS : `brew install htslib`
  - Any OS : Build from [source code](https://github.com/samtools/htslib)
  - Make sure that `pkg-config` can detect htslib: `pkg-config --libs htslib`

## Installation

Add hts to your `shard.yml`:

```yaml
dependencies:
  hts:
    github: bio-cr/hts.cr
    branch: develop
```

Run `shards install`

## Usage

Read SAM / BAM / CRAM

```crystal
require "hts/bam"

HTS::Bam.open(bam_path) do |bam|
  bam.each do |r|
    tags = r.aux

    p name: r.qname,
      chrom: r.chrom,
      start: r.pos + 1,
      cigar: r.cigar.to_s,
      seq: r.seq,
      qual: r.qual_string,
      nm: tags.get_int("NM"),
      mc: tags.get_string("MC")
  end
end
```

Read VCF / BCF

```crystal
require "hts/bcf"

HTS::Bcf.open(bcf_path) do |bcf|
  bcf.each do |r|
    p chrom: r.chrom,
      pos: r.pos + 1,
      id: r.id,
      qual: r.qual,
      filter: r.filter,
      ref: r.ref,
      alt: r.alt,
      info_dp: r.info.get_int("DP"),
      genotypes: r.format.get_string("GT")
  end
end
```

## API Overview

- High level API - Classes include Bam, Bcf, Tabix, Faidx, etc.
- LibHTS - Native C bindings to HTSLib
- For more information, please see [API documentation](https://bio-cr.github.io/hts.cr/).

```
 ┌──────────────────── HTS ────────────────────┐
 │                                             │
 │ ┌─ Bam ────────┬─ Bcf ───────┬─ Tabix ────┐ │
 │ │ SAM BAM CRAM │ VCF BCF     │ TABIX      │ │
 │ └──────────────┴─────────────┴────────────┘ │
 │                     ┌─LibHTS2───────────┐   │
 │ ┌─LibHTS────────────┤ Macro functions   ├─┐ │
 │ │ Native C bindings └───────────────────┘ │ │
 │ └─────────────────────────────────────────┘ │
 └─────────────────────────────────────────────┘
```

LibHTS2: Since methods cannot be added to `Lib` in the Crystal language, macro functions are implemented in the LibHTS2 module. This is different from Ruby-htslib.

## Looking for flexibility?

The Crystal language is suited for creating efficient command-line tools. The Ruby language, on the other hand, is suited for exploratory analysis.

- [ruby-htslib](https://github.com/kojix2/ruby-htslib)

## Contributing

:rocket: Feel free to fork it!

    git clone https://github.com/bio-cr/hts.cr
    cd hts.cr
    crystal spec

Bug reports and pull requests are welcome.

## Benchmark

https://github.com/brentp/vcf-bench

code: https://github.com/kojix2/vcf-bench/blob/kojix2/crystal-htslib/read.cr
