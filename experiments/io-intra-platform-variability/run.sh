#!/bin/bash
set -e -x

NUM_REPETITIONS=10
ANSIBLE_VARS=""
DEVICE="/dev/sdb"

# delete previous results
sudo rm -fr results/output
mkdir -p results/output

# write device to vars file
echo "" > ansible/extra-vars.yml
echo "  measure_runtime: yes" >> ansible/vars.yml
echo "  devices:" >> ansible/vars.yml
echo "  - $DEVICE:$DEVICE" >> ansible/vars.yml

function run_baseliner() {
  ID=$1
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
          -e results_path=/results/output/$ID/repetition/${i} \
          -e @vars.yml -e extra-vars.yml \
          playbook.yml"
  done

  # obtain benchmark-specific CSV
  docker run --rm \
    -v `pwd`/results/output/$ID:/data \
    -v `pwd`/results/csv_spec.yml:/csv_spec.yml \
    ivotron/json-to-table --csv-spec /csv_spec.yml > results/$ID.csv

  # obtain CSV of runtimes
  echo "repetition,bench,runtime" > results/${ID}_runtimes.csv
  for i in $(seq 1 $NUM_REPETITIONS); do
    rt=`cat results/output/$ID/runtime`
    echo "$i,$rt" >> results/${ID}_runtimes.csv
  done
}

# run baseliner to get IO baseline of device
run_baseliner "baseline"

# get lowest common denominator
LCD=`results/get_lcd results/baseline.csv`

# run with limits
echo "  limits:" >> ansible/vars.yml
echo "  - $DEVICE:${LCD}kb" >> ansible/vars.yml

run_baseliner "with_limits"
