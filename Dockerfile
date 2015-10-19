FROM debian:jessie

# - download and install opentuner
# - download and prepare memguard source code
RUN apt-get update && \
    apt-get install -y wget && \
    cd / && \
    wget --no-check-certificate https://github.com/jansel/opentuner/tarball/master -O - | tar xz && \
    mv jansel* opentuner && \
    cd /opentuner && \
    apt-get install -y \
      `cat debian-packages-deps | tr '\n' ' '` \
      module-init-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    python ./venv-bootstrap.py && \
    cd / && \
    wget --no-check-certificate https://github.com/heechul/memguard/tarball/d5b823589857f20b72cafe336bb814da83d88427 -O - | tar xz && \
    mv heechul* memguard

ENV OPENTUNER_DIR /opentuner
ENV PATH /opentuner/venv/bin/:$PATH

ADD docker-run-wrapper /usr/bin/
ADD porta.py /usr/bin/

ENTRYPOINT ["/usr/bin/porta.py"]
CMD ["--help"]
