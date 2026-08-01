# hts.cr benchmarks

Benchmarks must be compiled with `--release`. The BCF scan benchmark creates a
deterministic BCF fixture when its input path does not exist, verifies that the
high-level and low-level paths produce identical checksums, and then reports
throughput and Crystal bytes allocated per complete file scan.

```sh
crystal run --release benchmark/bcf_scan.cr
```

The default fixture contains 10,000 records and 64 samples. Its default path is
`/tmp/hts-cr-bcf-benchmark.bcf`. Pass another path as the first argument when
needed:

```sh
crystal run --release benchmark/bcf_scan.cr -- data/benchmark.bcf
```

Configuration is controlled through environment variables:

- `HTS_BENCH_RECORDS`: generated record count; default `10000`.
- `HTS_BENCH_SAMPLES`: generated sample count; default `64`.
- `HTS_BENCH_REGENERATE=1`: replace an existing fixture using the configured
  dimensions.
- `HTS_BENCH_SECONDS`: measurement duration per case; default `2` seconds.
- `HTS_BENCH_WARMUP`: warmup duration per case; default `1` second.
- `HTS_BENCH_VERIFY_ONLY=1`: generate if necessary and compare checksums without
  running timed measurements.

For a quick correctness check:

```sh
HTS_BENCH_RECORDS=100 HTS_BENCH_SAMPLES=8 \
  HTS_BENCH_REGENERATE=1 HTS_BENCH_VERIFY_ONLY=1 \
  crystal run --release benchmark/bcf_scan.cr
```

Crystal's benchmark report includes bytes allocated per operation (`B/op`). One
operation is one complete scan of the fixture. It does not expose a portable
heap-allocation count. Use the same Crystal, HTSlib, compiler flags, fixture,
and environment when comparing results.

Peak resident memory can be collected where `/usr/bin/time` supports verbose
resource reporting:

```sh
/usr/bin/time -v crystal run --release benchmark/bcf_scan.cr
```

The low-level cases reuse the destination buffer supplied to HTSlib across
records. The current high-level cases exercise the public owning APIs. Borrowed
API cases will be added alongside them when those APIs are implemented.
