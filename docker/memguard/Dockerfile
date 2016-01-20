FROM debian:jessie

RUN apt-get update && \
    apt-get install -y wget g++ gcc make lxc module-init-tools && \
    cd / && \
    wget --no-check-certificate https://github.com/heechul/memguard/tarball/a97723dade4246b159badee7764b33ea86bb4c29 -O - | tar xz && \
    mv heechul* memguard

RUN sed -i 's/local codebase.*//' /memguard/functions

ADD docker-run-wrapper /usr/bin/
