#!/bin/bash
set -e -x
docker run --rm \
  -v `pwd`/benchoutput:/data \
  ivotron/json-to-tabular:v0.0.2 \
    --header 'op,result' \
    --shexp "grep 'memory rate:' | awk '{print \$7\" \"\$8}' | sed 's/,//' | sed 's/\(.*\)/raw,\1/'" \
    --txtregex '.*stdoutout' ./ > all.csv
