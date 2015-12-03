#!/bin/bash

phoronix-test-suite batch-benchmark \
       pts/bullet \
       pts/byte \
       pts/cachebench \
       pts/compress-lzma \
       pts/compress-gzip \
       pts/compress-pbzip2 \
       pts/compress-7zip \
       pts/dcraw \
       pts/encode-mp3 \
       pts/encode-flac \
       pts/encode-ogg \
       pts/encode-ape \
       pts/encode-wavpack \
       pts/etqw-demo \
       pts/ffmpeg \
       pts/fhourstones \
       pts/gcrypt \
       pts/gnupg \
       pts/gmpbench \
       pts/graphics-magick \
       pts/himeno \
       pts/hmmer \
       pts/john-the-ripper \
       pts/jxrendermark \
       pts/lightsmark \
       pts/mafft \
       pts/mencoder \
       pts/minion \
       pts/mrbayes \
       pts/n-queens \
       pts/nero2d \
       pts/npb \
       pts/openssl \
       pts/padman \
       pts/povray \
       pts/pybench \
       pts/scimark2 \
       pts/smallpt \
       pts/sunflow \
       pts/sudokut \
       pts/tachyon \
       pts/tscp \
       pts/ttsiod-renderer \
       pts/vdrift \
       pts/x264 &> /tmp/out
if [ $? -ne 0 ] ; then
  echo "ERROR while executing benchmark"
  cat /tmp/out
  exit 1
fi

result=`basename /root/.phoronix-test-suite/test-results/*-*-*-*`

phoronix-test-suite result-file-to-csv $result > /tmp/out
if [ $? -ne 0 ] ; then
  echo "ERROR while getting benchmark results"
  cat /tmp/out
  exit 1
fi

sed -i -e '/^\s*$/d' /tmp/out
jq --slurp --raw-input --raw-output \
  'split("\n") | map(split(",")) |
      map({"name": .[0],
           "class": "system",
           "result": .[1]})' \
  /tmp/out
