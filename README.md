# htslib.cr

[![CI](https://github.com/bio-crystal/htslib.cr/actions/workflows/ci.yml/badge.svg)](https://github.com/bio-crystal/htslib.cr/actions/workflows/ci.yml)

Crystal bindings to [HTSlib](https://github.com/samtools/htslib). Under development.

## Installation

### Install [htslib](https://github.com/samtools/htslib)

Use the package manager to install the htslib and development files.

```sh
sudo apt install libhts-dev
```


Alternatively, you can install it from the source code and use the latest version of htslib.

```sh
git clone https://github.com/samtools/htslib
git checkout refs/tags/1.1X # Replace x with the latest version number
cd htslib
autoreconf -i  # Build the configure script and install files it uses
./configure    # Optional but recommended, for choosing extra functionality
make -j4
sudo checkinstall
```

It is important that [pkg-config can discover the library](https://crystal-lang.org/reference/syntax_and_semantics/c_bindings/lib.html). If the following command fails, the compilation may not succeed.

```sh
pkg-config --libs htslib
````

### crystal

Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     htslib:
       github: bio-crystal/htslib
   ```

Run `shards install`

## Usage

```crystal
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

## Related Work

* [ruby-htslib](https://github.com/kojix2/ruby-htslib)

## Contributing

htslib.cr is an immature, work-in-progress library, and pull requests such as small typo fixes are welcome.
If you are interested in becoming a project owner, please contact me.
Or you can simply fork it and start a project with a different name than htslib.cr.
