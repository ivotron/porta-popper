FROM debian:jessie

RUN apt-get update && \
    apt-get install -y wget && \
    cd / && \
    wget --no-check-certificate https://github.com/jansel/opentuner/tarball/master -O - | tar xz && \
    mv jansel* opentuner && \
    cd /opentuner && \
    apt-get install -y `cat debian-packages-deps | tr '\n' ' '` && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* debian/

# install opentuner
RUN cd /opentuner && \
    python ./venv-bootstrap.py

# download memguard
RUN cd / && \
    wget --no-check-certificate https://github.com/heechul/memguard/tarball/f671ad2f8a5aeec07d3db9e1930fc5c3abadecc3 -O - | tar xz && \
    mv heechul* memguard

RUN apt-get update && \
    apt-get install -y module-init-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* debian/

# add our scripts
ENV OPENTUNER_DIR /opentuner
ENV PATH /opentuner/venv/bin/:$PATH
ADD docker-run-wrapper /usr/bin/
ADD porta.py /usr/bin/
ENTRYPOINT ["/usr/bin/porta.py"]
CMD ["--help"]
