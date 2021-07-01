<p align="center">
  <img src="https://user-images.githubusercontent.com/5798442/114347767-72eadf80-9ba0-11eb-9784-3e3518841412.png" width="25%" height="25%" />
</p>

🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬🐈🧬🔬

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

## Related Work

* [ruby-htslib](https://github.com/kojix2/ruby-htslib)

## Contributing

1. Fork it (<https://github.com/kojix2/htslib.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

If you are interested in becoming a project owner, please contact me.
