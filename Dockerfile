FROM crystallang/crystal:latest

RUN apt update -y && apt upgrade -y && \
    apt install -y libhts-dev

RUN git clone --depth 1 --recursive https://github.com/bio-crystal/hts && \
    cd hts && \
    shards install
