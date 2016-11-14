#!/bin/bash
set -e -x

# EXPERIMENT VARIABLES
# {
# as many limits as concurrently running containers
LIMITS_KB=("100" "100" "100")

# length of MODES should match lenght of IOPS array
MODES=("write" "read" "randread")

# how long to run the benchmark for
RUNTIME=60

# where to read/write
DEVICE="/dev/sdb"

# block size
BLKSIZES_KB=("4" "256" "4096")

# repetitions
REPS=5
# }

# FIO stuff
#
# It's OK to run multiple fio processes separately since we're
# only interested in measuring the performance of read/write
# requests and not checking their integrity.
# see: http://www.spinics.net/lists/fio/msg03295.html
#
# {
docker pull ivotron/fio &> /dev/null

FLAGS="--entrypoint=genfio-test"
IMAGE="ivotron/fio"
ARGS="-s -d ${DEVICE} -r ${RUNTIME}"
# }

# docker-compose does not support blkio options yet, so we
# launch multiple containers on the same host "manually"
for ((rep=0;rep<${REPS};++rep)); do
  for bsize in ${BLKSIZES_KB[@]}; do

    # create containers first, to minimize startup costs
    cnames=""

    k=0
    for mode in ${MODES[@]}; do
      limit=${LIMITS_KB[k]}
      results_folder="`pwd`/results/repetition/${rep}/blksize_kb/${bsize}/mode/${mode}/limit_kb/${limit}"
      docker create \
        ${FLAGS} \
        --name=c${k} \
        --device ${DEVICE}:${DEVICE} \
        --device-write-bps ${DEVICE}:${limit}kb \
        --device-read-bps ${DEVICE}:${limit}kb \
        --volume ${results_folder}:/results \
        ${IMAGE} ${ARGS} -b ${bsize}k -m ${mode}
      cnames+="c${k} "
      let k=k+1
    done

    # run containers
    docker start $cnames

    # wait and remove
    exit_codes=`docker wait $cnames`
    docker rm $cnames

    # check for errors
    if [ "`echo ${exit_codes} | grep 0 | sed 's/0//g' | sed 's/ //g'`" != "" ] ; then
      echo "Non-zero exit from one of the containers"
      exit 1
    fi
  done
done

exit 0
