#!/usr/bin/env python

import sys

from subprocess import check_output as sh

if len(sys.argv) != 8:
    print("""Usage:
  1 - maxbw list (comma-separated; one per mode: read,write,randread,randwrite)
  2 - modes list (comma-separated; one per container)
  3 - limits list (comma-separated; one per container)
  4 - blksize
  5 - device
  6 - runtime
  7 - output_folder""")

maxbw = sys.argv[1].split(',')
modes = sys.argv[2].split(',')
limits = sys.argv[3].split(',')
bs = sys.argv[4]
device = sys.argv[5]
runtime = sys.argv[6]
output_folder = sys.argv[7]

if len(maxbw) != 4:
    raise Exception("Expecting maxbw list of size 4")

sum = 0
for limit in limits:
    sum += limit
if sum > 100:
    raise Exception("Sum of all limits should be <= 100")

sh(['docker', 'pull', 'ivotron/fio'])

# FIO stuff
#
# It's OK to run multiple fio processes separately since we're
# only interested in measuring the performance of read/write
# requests and not checking their integrity.
# see: http://www.spinics.net/lists/fio/msg03295.html
#
# {
flags = "--entrypoint=genfio-test"
img = "ivotron/fio"
args = "-s -d {} -r {} -b {}k".format(device, runtime, bs)
# }

# create containers first, to minimize startup costs
cnames = []
k = 1
for mode, limit_percentage in zip(modes, limits):

    if limit_percentage < 1 or limit_percentage > 100:
        raise Exception("Limit should be a percentage of max bandwidth")

    # get bandwidth w.r.t. maxbw
    if mode == "read":
        limitkb = (limit_percentage / 100.0) * maxbw[0]
    elif mode == "write":
        limitkb = (limit_percentage / 100.0) * maxbw[1]
    elif mode == "randread":
        limitkb = (limit_percentage / 100.0) * maxbw[2]
    elif mode == "randwrite":
        limitkb = (limit_percentage / 100.0) * maxbw[3]
    else:
        raise Exception("Unknown mode " + mode)

    # round
    limitkb = int(limitkb)

    results_folder = "{}/mode/{}/limit/{}".format(output_folder, mode, limitkb)
    cname = "fio-" + k
    cmd = (
      "docker create"
      " {0} "
      " --name={1} "
      " --device {2}:{2} "
      " --device-write-bps ${2}:${3}kb "
      " --device-read-bps ${2}:${3}kb "
      " --volume {4}:/results "
      " {5} {6} -m {8}"
    ).format(flags, cname, device, limitkb, results_folder, img, args, mode)
    sh(cmd, shell=True)
    cnames += [cname]
    k += 1

# run containers
sh(["docker", "start"] + cnames)

# wait and remove
exit_codes = sh(["docker", "wait"] + cnames)
sh(["docker", "rm"] + cnames)

# check for errors
if sh("echo {} | grep 0 | sed 's/0//g' | sed 's/ //g'", shell=True) != "":
    print("Non-zero exit from one of the containers")
    sys.exit(1)

sys.exit(0)
