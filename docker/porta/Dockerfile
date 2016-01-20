FROM ivotron/memguard

# - download and install opentuner
RUN apt-get update && \
    apt-get install -y wget && \
    cd / && \
    wget --no-check-certificate https://github.com/jansel/opentuner/tarball/master -O - | tar xz && \
    mv jansel* opentuner && \
    cd /opentuner && \
    apt-get install -y --no-install-recommends \
      `cat debian-packages-deps | tr '\n' ' '` \
      module-init-tools lxc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    python ./venv-bootstrap.py

ENV OPENTUNER_DIR /opentuner
ENV PATH /opentuner/venv/bin/:$PATH

ADD porta.py /usr/bin/
ADD run.py /usr/bin/

ENTRYPOINT ["/usr/bin/porta.py"]
CMD ["--help"]
