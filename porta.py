#!/usr/bin/env python
#
# Autotune docker execution engine parameters to resemble the performance of
#

import os
t = os.path.join(os.path.dirname(__file__), os.path.expandvars(
                 '$OPENTUNER_DIR/opentuner/utils/adddeps.py'))
execfile(t, dict(__file__=t))

import argparse
import json
import subprocess

import opentuner
from opentuner import ConfigurationManipulator
from opentuner import IntegerParameter
from opentuner import MeasurementInterface
from opentuner import Result

parser = argparse.ArgumentParser(parents=opentuner.argparsers())
parser.add_argument('--action', default='base',
                    choices=('base', 'tune'),
                    help='Whether to tune or generate target results')
parser.add_argument('--categories', default='cpu mem', nargs='+',
                    help=('Type of benchmarks to consider (cpu, mem, io, net)'))
parser.add_argument('--target-file', default='target.json',
                    help=('JSON file containing target performance results'))
parser.add_argument('--benchmarks', default='stream-copy crafty', nargs='+',
                    help='benchmarks to execute')
# internal arguments
parser.add_argument('--category', help=argparse.SUPPRESS)
parser.add_argument('--target', type=json.loads, help=argparse.SUPPRESS)


class PortaTuner(MeasurementInterface):
    def manipulator(self):
        """
        Define the search space by creating a
        ConfigurationManipulator
        """
        manipulator = ConfigurationManipulator()

        if args.category == 'cpu':
            manipulator.add_parameter(
                IntegerParameter('cpu-quota', 5000, 100000))
        elif args.category == 'mem':
            manipulator.add_parameter(
                IntegerParameter('mem-bw-limit', 100, 2000))
        else:
            raise Exception('Unknown benchmark class ' + args.category)

        return manipulator

    def run(self, desired_result, input, limit):
        """
        Run a given configuration and return accuracy
        """
        cfg = desired_result.configuration.data

        docker_cmd = ('docker-run-wrapper {}'
                      ' --cpuset-cpus=0'
                      ' --cpu-quota={}'
                      ' -e BENCHMARKS="{}"'
                      ' --rm'
                      ' ivotron/microbench ').format(
                          cfg['mem-bw-limit'],
                          ' '.join(self.args.benchmarks),
                          cfg['cpu-quota'])

        result = self.call_program(docker_cmd)
        assert result['returncode'] == 0

        current = json.load(result.stdout)
        target = args.target

        diff_count = 0
        for bench in self.args.benchmarks:
            if args.category != current[bench]['class']:
                continue
            diff_sum = abs(current[bench]['result'] - target[bench]['result'])
            diff_count += 1
        diff_mean = float(diff_sum) / diff_count

        return Result(accuracy=(1/diff_mean))

if __name__ == '__main__':
    args = parser.parse_args()

    if args.action == 'base':
        print(subprocess.check_output(
                ('docker run --rm --cpuset-cpus=0 -e BENCHMARKS="{}"'
                 '  ivotron/microbench').format(' '.join(args.benchmarks)),
                stderr=subprocess.PIPE, shell=True))
        exit()

    # read json
    if not args.target_file:
        raise Exception('Expecting name of file with target results')
    with open(args.target_file) as f:
        args.target = json.load(f.readlines())

    # invoke opentuner for each category
    for category in args.categories:
        args.category = category
        PortaTuner.main(args)
