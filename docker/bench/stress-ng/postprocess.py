#!/usr/bin/env python

import yaml

with open('/out.yaml', 'r') as f:
    y = yaml.load(f)

print("[")
i = 0
for metrics in y['metrics']:
    print("{")
    print("\"name\": " + metrics['stressor'] + ",")
    print("\"result\": " + str(metrics['bogo-ops-per-second-usr-sys-time']))
    if i < len(y['metrics'])-1:
        print("},")
    else:
        print("}")
    i += 1
print("]")
