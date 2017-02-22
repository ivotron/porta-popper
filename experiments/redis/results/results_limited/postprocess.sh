#!/bin/bash
set -e -x
docker run --rm \
  -v `pwd`/benchoutput:/data \
  ivotron/json-to-tabular:v0.0.3 \
    --header 'op,result' \
    --shexp "grep 'memory rate:' |
             awk '{print \$7\$8}' |
             sed 's/KB.*/*1024/' |
             sed 's/MB.*/*1024*1024/' |
             sed 's/GB.*/1024*1024*1024/' |
             bc |
             sed 's/\(.*\)/raw,\1/'" \
    --txtregex '.*stdoutout' ./ > all.csv
