#!/bin/bash
if [ -z $BENCHMARKS ] ; then
  BENCHMARKS="cpu-methods cpu-class cpu-cache memory matrix-methods string-methods"
fi

if [ -z $NUM_WORKERS ] ; then
  NUM_WORKERS=1
fi

if [ -z $TIMEOUT ] ; then
  TIMEOUT=10
fi

function include_comma {
  if [ "$need_comma" = true ] ; then
    echo ","
  else
    need_comma=true
  fi
}

need_comma=false

echo "["

if [[ $BENCHMARKS == *"cpu-methods"* ]] ; then
  for method in ackermann bitops callfunc crc16 cdouble cfloat clongdouble correlate decimal32 decimal64 decimal128 double djb2a euler explog fibonacci fnv1a fft float gamma gcd gray hamming hanoi hyperbolic idct int128 int64 int32 int16 int8 int128float int128double int128longdouble int128decimal32 int128decimal64 int128decimal128 int64float int64double int64longdouble int32float int32double int32longdouble jenkin jmp ln2 longdouble loop matrixprod nsqrt omega phi pi pjw prime psi rand rgb sdbm sieve sqrt trig zeta ; do
     stress-ng --cpu $NUM_WORKERS --cpu-method $method -t $TIMEOUT --metrics-brief --times -Y /out.yml &> /dev/null
     /postprocess.py cpu $method
     if [ "$method" != "zeta" ] ; then
       echo ","
     fi
  done
  need_comma=true
fi
if [[ $BENCHMARKS == *"matrix-methods"* ]] ; then
  include_comma
  for method in add div frobenius mult prod sub hadamard trans ; do
     stress-ng --matrix $NUM_WORKERS --matrix-method $method -t $TIMEOUT --metrics-brief --times -Y /out.yml &> /dev/null
     /postprocess.py matrix $method
     if [ "$method" != "trans" ] ; then
       echo ","
     fi
  done
fi
if [[ $BENCHMARKS == *"string-methods"* ]] ; then
  include_comma
  for method in index rindex strcasecmp strcat strchr strcoll strcmp strcpy strlen strncasecmp strncat strncmp strrchr strxfrm ; do
     stress-ng --str $NUM_WORKERS --str-method $method -t $TIMEOUT --metrics-brief --times -Y /out.yml &> /dev/null
     /postprocess.py string $method
     if [ "$method" != "strxfrm" ] ; then
       echo ","
     fi
  done
fi
if [[ $BENCHMARKS == *"cpu-class"* ]] ; then
  include_comma
  stress-ng --class cpu --exclude matrix,context --sequential $NUM_WORKERS -t $TIMEOUT --metrics-brief -Y /out.yml &> /dev/null
  /postprocess.py cpu
fi
if [[ $BENCHMARKS == *"memory"* ]] ; then
  include_comma
  stress-ng --class memory --exclude bsearch,hsearch,lsearch,qsort,wcs,tsearch,stream,numa --sequential $NUM_WORKERS -t $TIMEOUT --metrics-brief -Y /out.yml &> /dev/null
  /postprocess.py memory
fi
if [[ $BENCHMARKS == *"cpu-cache"* ]] ; then
  include_comma
  stress-ng --class cpu-cache --exclude bsearch,hsearch,lockbus,lsearch,vecmath,matrix,qsort,malloc,str,stream,memcpy,wcs,tsearch --sequential $NUM_WORKERS -t $TIMEOUT --metrics-brief -Y /out.yml &> /dev/null
  /postprocess.py cpu-cache
fi

echo "]"
