#!/bin/bash

phoronix-test-suite batch-benchmark pts/linux-system &> /tmp/out
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
