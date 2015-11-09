FROM ivotron/phoronix

# a subset of pts/linux-system (removed all tests involving disk) and added some from pts/cpu

ADD user-config.xml /root/.phoronix-test-suite/
ADD pts_result_file_output /usr/share/phoronix-test-suite/pts-core/objects/pts_result_file_output.php
RUN apt-get update && \
    sed -i -e "s/'NUM_CPU_CORES'.*/'NUM_CPU_CORES' => 1,/" /usr/share/phoronix-test-suite/pts-core/objects/client/pts_client.php && \
    CFLAGS="-O0 -mtune=generic" phoronix-test-suite batch-install \
       pts/compress-lzma \
       pts/compress-pbzip2 \
       pts/compress-7zip \
       pts/encode-mp3 \
       pts/encode-flac \
       pts/ffmpeg \
       pts/gcrypt \
       pts/gnupg \
       pts/gmpbench \
       pts/himeno \
       pts/john-the-ripper \
       pts/tachyon \
       pts/mafft \
       pts/npb \
       pts/hmmer \
       pts/graphics-magick \
       pts/openssl \
       pts/smallpt \
       pts/sunflow \
       pts/sudokut \
       pts/tscp \
       pts/nero2d \
       pts/dcraw \
       pts/minion \
       pts/pybench && \
    apt-get autoremove -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt-get update && \
    apt-get install -y jq && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ADD entrypoint.sh /root/
ENTRYPOINT ["/root/entrypoint.sh"]
