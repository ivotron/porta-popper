#!/bin/bash
set -e -x

NUM_REPETITIONS=5

# run baseliner to get IO baseline of the device
docker run --rm -ti \
  -v `pwd`/../results:/results \
  -v `pwd`:/experiment \
  -v "$SSH_AUTH_SOCK:/tmp/ssh_auth_sock" \
  -e "SSH_AUTH_SOCK=/tmp/ssh_auth_sock" \
  --workdir=/experiment \
  --net=host \
  --entrypoint=/bin/bash \
  williamyeh/ansible:debian8 -c \
    "ssh-add -l &&
     ansible-playbook
       -e results_path=/results/baseline
       -e @baseline-vars.yml
       playbook.yml"

# obtain CSV for baseline results
docker run --rm \
  -v `pwd`/results/baseline:/data \
  -v `pwd`/results/csv_spec.yml:/csv_spec.yml \
  ivotron/json-to-table --spec /csv_spec.yml > results/baseline.csv

# extract a "read,write,randread,randwrite" max bandwidth comma-sep list
maxbw=`foo`

# iterate
for i in $(seq 1 $NUM_REPETITIONS); do
  docker run --rm -ti \
    -v `pwd`/../results:/results \
    -v `pwd`:/experiment \
    -v "$SSH_AUTH_SOCK:/tmp/ssh_auth_sock" \
    -e "SSH_AUTH_SOCK=/tmp/ssh_auth_sock" \
    --workdir=/experiment \
    --net=host \
    --entrypoint=/bin/bash \
    williamyeh/ansible:debian8 -c \
      "ssh-add -l &&
       ansible-playbook
         -e results_path=/results/with_limits/repetition/$i
         -e maxbw=${maxbw}
         -e @vars.yml playbook.yml"
done
