#!/bin/bash
sysbench --test=cpu --cpu-max-prime=20000 run > output

if [ $? -ne 0 ] ; then
   cat output
   exit 1
fi

result=`cat output | grep 'total time:' | awk '{ print $NF }' | sed 's/s//'`
echo "[{"
echo "\"name\": \"sysbench-cpu\", "
echo "\"class\": \"processor\", "
echo "\"result\": \"$result\" "
echo "},"

sysbench --test=memory run > output

if [ $? -ne 0 ] ; then
   cat output
   exit 1
fi

result=`cat output | grep 'total time:' | awk '{ print $NF }' | sed 's/s//'`
echo "{"
echo "\"name\": \"sysbench-memory\", "
echo "\"class\": \"memory\", "
echo "\"result\": \"$result\" "
echo "}]"
