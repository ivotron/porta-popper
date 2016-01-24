#!/bin/bash
if [ -z "$BENCHMARKS" ] ; then
  BENCHMARKS="dhry2reg syscall pipe context1 spawn execl shell1"
fi

/app/UnixBench/Run -c 1 $BENCHMARKS &> /tmp/out

if [ $? -ne 0 ] ; then
  cat /tmp/out
  exit 1
fi

rm results/*.log results/*.html

echo "["

if [[ $BENCHMARKS == *"dhry2reg"* ]] ; then
  result=`cat results/* | sed -n 's/Dhrystone 2 using register variables *\(.*\) .* samples)/\1/p' | awk '{ print $1 }'`
  echo "{\"name\": \"unixbench-dhrystone\",\"class\": \"cpu\",\"result\": $result},"
fi

if [[ $BENCHMARKS == *"syscall"* ]] ; then
  result=`cat results/* | sed -n 's/System Call Overhead *\(.*\) .* samples)/\1/p' | awk '{ print $1 }'`
  echo "{\"name\": \"unixbench-syscall\",\"class\": \"os\",\"result\": $result},"
fi

if [[ $BENCHMARKS == *"context1"* ]] ; then
  result=`cat results/* | sed -n 's/Pipe-based Context Switching *\(.*\) .* samples)/\1/p' | awk '{ print $1 }'`
  echo "{\"name\": \"unixbench-context\",\"class\": \"os\",\"result\": $result},"
fi

if [[ $BENCHMARKS == *"spawn"* ]] ; then
  result=`cat results/* | sed -n 's/Process Creation *\(.*\) .* samples)/\1/p' | awk '{ print $1 }'`
  echo "{\"name\": \"unixbench-spawn\",\"class\": \"os\",\"result\": $result},"
fi

if [[ $BENCHMARKS == *"execl"* ]] ; then
  result=`cat results/* | sed -n 's/Execl Throughput *\(.*\) .* samples)/\1/p' | awk '{ print $1 }'`
  echo "{\"name\": \"unixbench-execl\",\"class\": \"os\",\"result\": $result},"
fi

if [[ $BENCHMARKS == *"shell1"* ]] ; then
  result=`cat results/* | sed -n 's/Shell Scripts (1 concurrent) *\(.*\) .* samples)/\1/p' | awk '{ print $1 }'`
  echo "{\"name\": \"unixbench-shell\",\"class\": \"os\",\"result\": $result},"
fi

if [[ $BENCHMARKS == *"pipe"* ]] ; then
  result=`cat results/* | sed -n 's/Pipe Throughput *\(.*\) .* samples)/\1/p' | awk '{ print $1 }'`
  echo "{\"name\": \"unixbench-pipe\",\"class\": \"os\",\"result\": $result}"
fi

echo "]"
