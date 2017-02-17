#!/bin/bash
set -e -x

# delete previous results
sudo rm -f results/runtime_*

docker run --rm -ti \
  -v `pwd`/ansible:/experiment \
  -v `pwd`/../../.vendor:/experiment/vendor \
  -v `pwd`/results:/results \
  -v $SSH_AUTH_SOCK:/ssh-agent \
  -e SSH_AUTH_SOCK=/ssh-agent \
  --workdir=/experiment \
  --net=host \
  --entrypoint=/bin/bash \
  ivotron/ansible:2.2.0.0 -c \
    "ansible-playbook -e @vars.yml playbook.yml"

sudo rm -fr results/benchoutput/*
sudo mv results/benchmark results/benchoutput/
