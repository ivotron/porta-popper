#!/bin/bash
set -e

if [ ! -d /mica_output/ ] ; then
  echo "Folder /mica_output doesn't exist"
  exit 1
fi

cd /pin/source/tools/mica/

make

../../../pin \
  -injection child \
  -t mica.so -- sh -c "cd $ORIGINAL_WORKDIR && $ORIGINAL_ENTRYPOINT"

cp $ORIGINAL_WORKDIR/*.out .
