FROM ivotron/perf

# install membwcg
# RUN wget --no-check-certificate https://github.com/ivotron/membwcg/releases/download/v0.1.0/membwcg-linux-amd64.tar.bz2 -O - | tar xj && \
#     mv membwcg /usr/bin && \
#     mv docker-run /usr/bin
#
# adding it manually for now since the membwcg repo is not public yet
ADD membwcg/membwcg /usr/bin
ADD membwcg/docker-run /usr/bin/

# - download and install opentuner
RUN apt-get update && \
    apt-get install -y wget tar build-essential python-pip python-dev libsqlite3-dev sqlite3 && \
    cd / && \
    wget --no-check-certificate https://github.com/jansel/opentuner/tarball/master -O - | tar xz && \
    mv jansel* opentuner && \
    cd /opentuner && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    pip install -e .

ENV OPENTUNER_DIR /opentuner

# add our tuner
ADD porta.py /usr/bin/

ENTRYPOINT ["/usr/bin/porta.py"]
CMD ["--help"]
