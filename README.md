# htslib.cr

[![CI](https://github.com/bio-crystal/htslib.cr/actions/workflows/ci.yml/badge.svg)](https://github.com/bio-crystal/htslib.cr/actions/workflows/ci.yml)

Crystal bindings to [HTSlib](https://github.com/samtools/htslib). Under development.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     htslib:
       github: kojix2/htslib
   ```

2. Run `shards install`

## Usage

```crystal
require "htslib"
puts String.new(HTS::LibHTS.hts_version())
```

## API Overview (Plan)

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

* High level API - Create as needed. But don't overdo it.
* Low level API - Native C bindings to HTSLib

## Development

```
crystal run scripts/generate.cr
```

No plan. What will be will be.
The author is not familiar with Crystal, so it may be written in an inefficient way, and you may be able to fix it.
If you want the right to commit to this project, please contact me.

## Related Work

* [ruby-htslib](https://github.com/kojix2/ruby-htslib)

## Contributing

htslib.cr is an immature, work-in-progress library, and pull requests such as small typo fixes are welcome.

1. Fork it (<https://github.com/kojix2/htslib.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

If you are interested in becoming a project owner, please contact me.
Or you can simply fork it and start a project with a different name than htslib.cr.
This is open source.
