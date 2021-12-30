Automatic binding generator

https://github.com/crystal-lang/crystal_lib

(1) Install crystal_lib

```sh
git clone https://github.com/crystal-lang/crystal_lib
cd crystal_lib
shards install
crystal build src/main.cr -o crystal_lib
```

(2) generate bindings

```
crystal_lib crystal_lib/htslib.cr > src/hts/libhts/libhts.cr
crystal tool format src/hts/libhts/libhts.cr
```
