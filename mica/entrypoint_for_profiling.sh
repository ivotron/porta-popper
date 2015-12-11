#!/bin/bash
set -e

cd /pin/source/tools/mica/

make

# delete any previous output
rm -f *.out

# analyze
../../../pin \
  -t mica.so -- sh -c "cd $ORIGINAL_WORKDIR && $ORIGINAL_ENTRYPOINT"

# copy output
cp $ORIGINAL_WORKDIR/*.out .
