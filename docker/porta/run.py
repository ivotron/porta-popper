#!/usr/bin/env python

import subprocess
import json
import sys

with open('parameters.json') as f:
    params = json.load(f)
    # get the parameters to 'docker run'
    run_args = ' '.join(sys.argv[1:])
    cmd = ('docker-run-wrapper {} {} --cpu-quota={} ' + run_args).format(
              "1000",
              params['mem-bw-limit'],
              params['cpu-quota'])
    p = subprocess.Popen(cmd,
                         shell=True,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT)
    for line in iter(p.stdout.readline, b''):
        print(line.rstrip())
