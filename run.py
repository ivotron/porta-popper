#!/usr/bin/env python

import subprocess
import json
import sys

with open('parameters.json') as f:
    params = json.load(f)
    # get the parameters to 'docker run'
    run_args = ' '.join(sys.argv[1:])
    cmd = ('docker-run-wrapper {} --cpu-quota={} ' + run_args).format(
        params['mem-bw-limit'],
        params['cpu-quota'])
    print(cmd)
    p = subprocess.Popen(cmd,
                         shell=True,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT)
    for line in iter(p.stdout.readline, b''):
        print(line.rstrip())
