FROM crystallang/crystal:latest

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install apt-utils automake -y

RUN apt-get install -y libcurl4-openssl-dev liblzma-dev libbz2-dev libdeflate-dev

RUN git clone --depth 1 --recursive https://github.com/samtools/htslib && \
    cd htslib && \
    autoreconf -i && \
    ./configure && \
    make -j2 && \
    make install 

ENV LD_LIBRARY_PATH="/usr/local/lib"

RUN git clone https://github.com/bio-cr/hts.cr && \
    cd hts && \
    shards install && \
    crystal run test/run_all.cr
