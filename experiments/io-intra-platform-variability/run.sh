#!/bin/bash
set -e -x

# delete previous results
sudo rm -fr results/output
mkdir -p results/output

# get variables
NUM_REPETITIONS=`cat ansible/vars.yml | grep num_repetitions | sed 's/num_repetitions://'`
DEVICE=`cat ansible/vars.yml | grep device: | sed 's/device://'`
echo "" > ansible/extra-vars.yml

function run_baseliner() {
  ID=$1
  for i in $(seq 1 $NUM_REPETITIONS); do
   mkdir -p results/output/$ID/repetition/${i}
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
        ansible all -m shell -a 'docker stop \$(docker ps -q); \
                                 docker rm \$(docker ps -aq); \
                                 true' && \
        ansible-playbook \
          -e results_path=/results/output/$ID/repetition/${i} \
          -e @vars.yml \
          -e @extra-vars.yml \
          playbook.yml"
  done

  # obtain benchmark-specific CSV
  docker run --rm \
    -v `pwd`/results/output/$ID:/data \
    -v `pwd`/results/csv_spec.yml:/csv_spec.yml \
    ivotron/json-to-table --csv-spec /csv_spec.yml > results/$ID.csv
}

# run baseliner to get IO baseline of device
run_baseliner "baseline"

# get lowest common denominator
READ_LCD=`results/get_lcd results/baseline.csv read_iops 0.90`
WRITE_LCD=`results/get_lcd results/baseline.csv write_iops 0.90`
echo "READ_LCD: $READ_LCD"
echo "WRITE_LCD: $WRITE_LCD"

# run with limits
echo "defaults:" >> ansible/extra-vars.yml
echo "  limits:" >> ansible/extra-vars.yml
echo "    device-read-iops: '{{ device }}:${READ_LCD}'" >> ansible/extra-vars.yml
echo "    device-write-iops: '{{ device }}:${WRITE_LCD}'" >> ansible/extra-vars.yml

run_baseliner "with_limits"
