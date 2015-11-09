#!/bin/bash
/app/UnixBench/Run -c 1 dhry2reg syscall pipe context1 spawn execl shell1 &> /tmp/out

if [ $? -ne 0 ] ; then
  cat /tmp/out
  exit 1
fi

rm results/*.log results/*.html

echo "["
result=`cat results/* | sed -n 's/Dhrystone 2 using register variables *\(.*\) .* samples)/\1/p' | awk '{ print $1 }'`
echo "{\"name\": \"unixbench-dhrystone\",\"class\": \"processor\",\"result\": $result},"

result=`cat results/* | sed -n 's/System Call Overhead *\(.*\) .* samples)/\1/p' | awk '{ print $1 }'`
echo "{\"name\": \"unixbench-syscall\",\"class\": \"processor\",\"result\": $result},"

result=`cat results/* | sed -n 's/Pipe-based Context Switching *\(.*\) .* samples)/\1/p' | awk '{ print $1 }'`
echo "{\"name\": \"unixbench-context\",\"class\": \"processor\",\"result\": $result},"

result=`cat results/* | sed -n 's/Process Creation *\(.*\) .* samples)/\1/p' | awk '{ print $1 }'`
echo "{\"name\": \"unixbench-spawn\",\"class\": \"processor\",\"result\": $result},"

result=`cat results/* | sed -n 's/Execl Throughput *\(.*\) .* samples)/\1/p' | awk '{ print $1 }'`
echo "{\"name\": \"unixbench-execl\",\"class\": \"processor\",\"result\": $result},"

result=`cat results/* | sed -n 's/Shell Scripts (1 concurrent) *\(.*\) .* samples)/\1/p' | awk '{ print $1 }'`
echo "{\"name\": \"unixbench-shell\",\"class\": \"processor\",\"result\": $result},"

result=`cat results/* | sed -n 's/Pipe Throughput *\(.*\) .* samples)/\1/p' | awk '{ print $1 }'`
echo "{\"name\": \"unixbench-pipe\",\"class\": \"processor\",\"result\": $result}"

echo "]"

result=`cat results/* | grep "Pipe Throughput" | awk '{ print $3 }'`
