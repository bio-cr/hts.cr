FROM crystallang/crystal:latest

# System packages and build deps
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    automake \
    autoconf \
    m4 \
    pkg-config \
    libcurl4-openssl-dev \
    liblzma-dev \
    libbz2-dev \
    libdeflate-dev \
    samtools && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Build and install HTSlib from source to /usr/local
RUN git clone --depth 1 --recursive https://github.com/samtools/htslib && \
    cd htslib && \
    autoreconf -i && \
    ./configure && \
    make -j2 && \
    make install && \
    cd .. && rm -rf htslib

ENV LD_LIBRARY_PATH="/usr/local/lib"

# Workspace for mounting project source at runtime
WORKDIR /workspace

# Default command: open Crystal REPL (can be overridden)
CMD ["crystal", "play"]