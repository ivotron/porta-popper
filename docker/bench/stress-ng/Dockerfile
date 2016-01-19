FROM debian:stretch

RUN apt-get update && apt-get install -y stress-ng python python-yaml && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ADD postprocess.py /
ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
