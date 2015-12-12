#!/bin/bash
set -e

cd /pin/source/tools/mica/

make

# delete any previous output
rm -f *.out

# analyze
LD_LIBRARY_PATH=`pwd` ../../../pin \
  -follow_execv \
  -t mica.so -- sh -c "$CMD"

# copy generated output
find / -name *pin.out | xargs cp -t .
