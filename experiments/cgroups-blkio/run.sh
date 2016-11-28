#!/bin/bash
set -e -x

# this should be run from the experiments/cgroups-blkio folder

# delete any possible file in all hosts
docker run --rm -ti \
  -v `pwd`/ansible:/experiment \
  -v "$SSH_AUTH_SOCK:/tmp/ssh_auth_sock" \
  -e "SSH_AUTH_SOCK=/tmp/ssh_auth_sock" \
  --workdir=/experiment \
  --net=host \
  --entrypoint=/bin/bash \
  ivotron/ansible:2.2.0.0 -c \
    'ssh-add -l && \
     ansible all \
      -m shell \
      -a "sudo rm -fr /tmp/results/ && mkdir /tmp/results"'
sudo rm -fr results/baseline

# run baseliner to get IO baseline of the device
docker run --rm -ti \
  -v `pwd`/ansible:/experiment \
  -v `pwd`/../../.vendor:/experiment/vendor \
  -v `pwd`/results:/results \
  -v "$SSH_AUTH_SOCK:/tmp/ssh_auth_sock" \
  -e "SSH_AUTH_SOCK=/tmp/ssh_auth_sock" \
  --workdir=/experiment \
  --net=host \
  --entrypoint=/bin/bash \
  ivotron/ansible:2.2.0.0 -c \
    'ssh-add -l && \
     ansible-playbook \
       -e results_path=/results/baseline \
       -e "@baseline-vars.yml" \
       playbook.yml'

# obtain CSV for baseline results
docker run --rm \
  -v `pwd`/results/baseline:/data \
  -v `pwd`/results/csv_spec.yml:/csv_spec.yml \
  ivotron/json-to-table --csv-spec /csv_spec.yml > results/baseline.csv

# extract a "read,write,randread,randwrite" max bandwidth comma-sep list
maxbw="`cat results/baseline.csv | grep ',"read' | awk -F',' '{print $4}'`"
maxbw+=",`cat results/baseline.csv | grep ',"write' | awk -F',' '{print $5}'`"
maxbw+=",`cat results/baseline.csv | grep ',"randread' | awk -F',' '{print $4}'`"
maxbw+=",`cat results/baseline.csv | grep ',"randwrite' | awk -F',' '{print $5}'`"

NUM_REPETITIONS=3

cat ansible/vars.yml > ansible/vars_with_maxbw.yml
echo "maxbw: \"${maxbw}\"" >> ansible/vars_with_maxbw.yml

sudo rm -fr results/with_limits/
mkdir -p results/with_limits/repetition

# iterate
for i in $(seq 1 $NUM_REPETITIONS); do
  docker run --rm -ti \
    -v `pwd`/ansible:/experiment \
    -v `pwd`/../../.vendor:/experiment/vendor \
    -v `pwd`/results:/results \
    -v "$SSH_AUTH_SOCK:/tmp/ssh_auth_sock" \
    -e "SSH_AUTH_SOCK=/tmp/ssh_auth_sock" \
    --workdir=/experiment \
    --net=host \
    --entrypoint=/bin/bash \
    ivotron/ansible:2.2.0.0 -c \
      "ssh-add -l && \
       ansible-playbook \
         -e results_path=/results/with_limits/repetition/${i}/ \
         -e @vars_with_maxbw.yml \
         playbook.yml"
done

# obtain CSV for results
docker run --rm \
  -v `pwd`/results/with_limits:/data \
  -v `pwd`/results/csv_spec.yml:/csv_spec.yml \
  ivotron/json-to-table --csv-spec /csv_spec.yml > results/all.csv
