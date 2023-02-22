FROM crystallang/crystal:latest

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    automake \
    libcurl4-openssl-dev \
    liblzma-dev \
    libbz2-dev \
    libdeflate-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --recursive https://github.com/samtools/htslib && \
    cd htslib && \
    autoreconf -i && \
    ./configure && \
    make -j2 && \
    make install && \
    cd .. && rm -rf htslib

ENV LD_LIBRARY_PATH="/usr/local/lib"

RUN git clone https://github.com/bio-cr/hts.cr && \
    cd hts.cr && \
    shards install && \
    crystal run test/run_all.cr && \
    cd .. && rm -rf hts.cr

# Set the default command to start the Crystal REPL
CMD ["crystal", "play"]