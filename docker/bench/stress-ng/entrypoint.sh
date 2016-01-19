#!/bin/bash
if [ -z $BENCHMARKS ] ; then
  BENCHMARKS="cpu"
fi

if [ -z $TIMEOUT ] ; then
  TIMEOUT=60
fi

if [[ $BENCHMARKS == *"cpu-methods"* ]] ; then
  for method in "ackermann bitops callfunc crc16 cdouble cfloat clongdouble correlate decimal32 decimal64 decimal128 double djb2a euler explog fibonacci fnv1a fft float gamma gcd gray hamming hanoi hyperbolic idct int128 int64 int32 int16 int8 int128float int128double int128longdouble int128decimal32 int128decimal64 int128decimal128 int64float int64double int64longdouble int32float int32double int32longdouble jenkin jmp ln2 longdouble loop matrixprod nsqrt omega phi pi pjw prime psi rand rgb sdbm sieve sqrt trig zeta"; do
     stress-ng --cpu 1 --cpu-method $method -t $TIMEOUT --metrics-brief --times -Y /out.yaml &> /dev/null
  done
elif [[ $BENCHMARKS == *"cpu"* ]] ; then
  stress-ng --class cpu --sequential 1 -t $TIMEOUT --metrics-brief -Y /out.yaml &> /dev/null
elif [[ $BENCHMARKS == *"mem"* ]] ; then
  stress-ng --class memory --sequential 1 -t $TIMEOUT --metrics-brief -Y /out.yaml &> /dev/null
elif [[ $BENCHMARKS == *"cache"* ]] ; then
  stress-ng --class cpu-cache --sequential 1 -t $TIMEOUT --metrics-brief -Y /out.yaml &> /dev/null
else
  echo "Unknown value for BENCHMARKS: $BENCHMARKS"
  exit 1
fi

/postprocess.py
