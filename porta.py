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
parser.add_argument('--categories', default=['processor', 'memory'], nargs='+',
                    help=('Type of benchmarks to consider. One or more values'
                          ' of processor, memory, io or net.'))
parser.add_argument('--target-file', default='target.json',
                    help=('JSON file containing target performance results'))
parser.add_argument('--output-file', default='parameters.json',
                    help=('output JSON file containing resulting parameters'))
parser.add_argument('--benchmarks', default=['stream-copy', 'crafty'],
                    nargs='+', help='benchmarks to execute')
# internal arguments
parser.add_argument('--category', help=argparse.SUPPRESS)
parser.add_argument('--target', type=json.loads, help=argparse.SUPPRESS)
parser.add_argument('--outjson', help=argparse.SUPPRESS)


class PortaTuner(MeasurementInterface):
    def manipulator(self):
        """
        Define the search space by creating a
        ConfigurationManipulator
        """
        manipulator = ConfigurationManipulator()

        if args.category == 'processor':
            manipulator.add_parameter(
                IntegerParameter('cpu-quota', 5000, 100000))
        elif args.category == 'memory':
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

        target = self.args.target
        benchs = self.get_benchmarks_for_category(self.args.benchmarks, target,
                                                  self.args.category)
        if not benchs:
            raise Exception("Need to execute one benchmark at least")

        docker_cmd = self.get_cmd_for_class(self.args.category, benchs, cfg)

        result = self.call_program(docker_cmd)
        assert result['returncode'] == 0

        current = json.loads(result['stdout'])

        diff_count = 0
        for bench in current:
            current_result = float(current[bench]['result'])
            target_result = float(target[bench]['result'])
            diff_sum = abs(current_result - target_result)
            diff_count += 1
        diff_mean = float(diff_sum) / diff_count
        diff_mean += 1  # avoid division by zero

        # TODO: multiply accuracy by variance (or stddev) to factor in the
        # variability in the differences between distinct results

        return Result(time=(diff_mean * -1))

    def get_benchmarks_for_category(self, benchmarks, target, category):
        benchs = []
        for benchmark in target:
            if benchmark in benchmarks:
                if target[benchmark]['class'] == category:
                    benchs.append(benchmark)
        return benchs

    def get_cmd_for_class(self, category, benchmarks, cfg):
        if category == 'processor':
            return ('docker run '
                    ' --cpuset-cpus=0'
                    ' --cpu-quota={}'
                    ' -e BENCHMARKS="{}"'
                    ' --rm'
                    ' ivotron/microbench ').format(
                        cfg['cpu-quota'],
                        ' '.join(benchmarks))
        elif category == 'memory':
            return ('docker-run-wrapper {}'
                    ' --cpuset-cpus=0'
                    ' -e BENCHMARKS="{}"'
                    ' --rm'
                    ' ivotron/microbench ').format(
                        cfg['mem-bw-limit'],
                        ' '.join(benchmarks))

    def save_final_config(self, configuration):
        '''
        called at the end with best resultsdb.models.Configuration
        '''
        cfg = configuration.data
        for parameter in cfg:
            self.args.outjson += '\n"' + parameter + '":'
            self.args.outjson += str(cfg[parameter]) + ','

if __name__ == '__main__':
    args = parser.parse_args()

    if args.action == 'base':
        print(subprocess.check_output(
              ('docker run --rm --cpuset-cpus=0 -e BENCHMARKS="{}"'
               '  ivotron/microbench').format(' '.join(args.benchmarks)),
              stderr=subprocess.PIPE, shell=True))
        exit()

    # read input
    if not args.target_file:
        raise Exception('Expecting name of file with target results')
    with open(args.target_file) as f:
        args.target = json.load(f)

    # initialize output JSON string
    args.outjson = "{"

    # invoke opentuner for each category
    for category in args.categories:
        args.category = category
        PortaTuner.main(args)

    # delete last comma
    args.outjson = args.outjson[:-1]
    args.outjson += '\n}'

    # write output file
    with open(args.output_file, 'a') as f:
        f.write(args.outjson)
