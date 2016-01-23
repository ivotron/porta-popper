#!/usr/bin/env python

import yaml
import sys

with open('/out.yaml', 'r') as f:
    y = yaml.load(f)

if len(sys.argv) == 2:
    stressor_name = sys.argv[1]
    metric = y['metrics'][0]
    print("{")
    print("\"name\": \"stressng-"+stressor_name+"\",")
    print("\"class\": \"cpu\",")
    print("\"units\": \"bogo-ops-per-second\",")
    print("\"result\": "+str(metric['bogo-ops-per-second-real-time']))
    print("}")
else:
    i = 0
    for metrics in y['metrics']:

        if metrics['stressor'] is None:
            # handle special case of the 'null' stressor, which isn't
            # correctly displayed in the YAML output of stress-ng
            stressor_name = 'null'
        else:
            stressor_name = metrics['stressor']

        print("{")
        print("\"name\": \"stressng-" + stressor_name + "\",")
        print("\"result\": " + str(metrics['bogo-ops-per-second-real-time']))
        if i < len(y['metrics'])-1:
            print("},")
        else:
            print("}")
        i += 1
    print("]")
