FROM debian:jessie

RUN apt-get update && \
    apt-get install -y wget build-essential && \
    cd / && \
    wget --no-check-certificate https://github.com/heechul/memguard/tarball/f671ad2f8a5aeec07d3db9e1930fc5c3abadecc3 -O - | tar xz && \
    mv heechul* memguard

RUN sed -i 's/local codebase.*//' /memguard/functions

ADD docker-run-wrapper /usr/bin/
