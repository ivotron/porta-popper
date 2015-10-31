#!/bin/bash
cd /comd/bin

./CoMD-serial > output

if [ $? -ne 0 ] ; then
   cat output
   exit 1
fi

result=`sed -n 's/total *1 *\([0-9]*\.[0-9]*\) *.*/\1/p' output`
echo "{ \"comd-serial\": { \"class\": \"processor\", \"result\": \"$result\" } }"
