FROM crystallang/crystal:latest

RUN apt update -y && apt upgrade -y && \
    apt install -y libhts-dev

RUN git clone --depth 1 --recursive https://github.com/bio-crystal/htslib.cr && \
    cd htslib.cr && \
    shards install
