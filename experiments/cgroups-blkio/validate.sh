#!/bin/bash
# The point of entry to the validation of results produced by the experiment.
# Any non-zero exit code will be interpreted as a failure by the 'popper check'
# command. Additionally, the command should print "true" or "false" for each
# validation (one per line, each interpreted as a separate validation).
set -e

# obtain CSV from JSON results
docker run --rm -v `pwd`/results:/data ivotron/json-to-table > results/all.csv

# remove JSON files to avoid polluting the repo
rm -r results/repetition

# run validations in python

exit 0
