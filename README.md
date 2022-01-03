# htslib.cr

[![CI](https://github.com/bio-crystal/htslib.cr/actions/workflows/ci.yml/badge.svg)](https://github.com/bio-crystal/htslib.cr/actions/workflows/ci.yml)

htslib.cr is the Crystal bindings to HTSlib, a C library for processing high throughput sequencing (HTS) data. 
It will provide APIs to read and write file formats such as [SAM, BAM, VCF, and BCF](http://samtools.github.io/hts-specs/).

:fire: Feel free to fork it out if you can develop it! 

:hatching_chick: alpha stage.

## Requirements

* [Crystal](https://crystal-lang.org)
* [HTSlib](https://github.com/samtools/htslib)
  * Ubuntu : `apt install libhts-dev`
  * macOS : `brew install htslib`
  * Build from source code

Make sure that `pkg-config` can detect htslib.

```sh
pkg-config --libs htslib
````

### Installation

Add htslib to your `shard.yml`:

   ```yaml
   dependencies:
     htslib:
       github: bio-crystal/htslib
   ```

Run `shards install`

## Usage

SAM/BAM

```crystal
require "htslib/hts/bam"

bam = HTS::Bam.new(bam_path)

bam.each do |r|
  p name:  r.qname,
    flag:  r.flag.value,
    start: r.start + 1,
    mpos:  r.mate_pos + 1,
    mqual: r.mapping_quality,
    seq:   r.sequence,
    cigar: r.cigar,
    qual:  r.base_qualities.map { |i| (i + 33).chr }.join
end

bam.close
```

VCF/BCF

```crystal
require "htslib/hts/bcf"

bcf = HTS::Bcf.new(bcf_path)

bcf.each do |r|
  p start:  r.start,
    stop:   r.stop,
    id:     r.id,
    qual:   r.qual,
    filter: r.filter,
    ref:    r.ref,
    alt:    r.alt
end

bcf.close
```

## API Overview (Plan)

* High level API - Create as needed. But don't overdo it.
* Low level API - Native C bindings to HTSLib

```
    ┌───────────────────────────────────────────────────────────────┐
    │                              HTS                              │
    │                                                               │
    │   ┌─────────────┬─────────────┬─────────────┬─────────────┐   │
    │   │ SAM/BAM     │ VCF/BCF     │ CRAM        │ Tabix       │   │
    │   │             │             │             │             │   │
    │   │             │             │             │             │   │
    │   ├─────────────┴─────────────┴─────────────┴─────────────┤   │
    │   │ LibHTS                                                │   │
    │   │ Native C bindings                                     │   │
    │   │                                                       │   │
    │   └───────────────────────────────────────────────────────┘   │
    │                                                               │
    └───────────────────────────────────────────────────────────────┘
```


## Related Work

* [ruby-htslib](https://github.com/kojix2/ruby-htslib)

## Contributing

htslib.cr is an immature, work-in-progress library, and pull requests such as small typo fixes are welcome.
If you are interested in becoming a committer or project owner, please contact  by creating pull requests.
Or you can simply fork it and start a project with a different name than htslib.cr.
