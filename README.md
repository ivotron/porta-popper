# porta

Generate performance files for a system:

```bash
porta base
```

Tune a system:

```bash
porta tune <perf-results-file>
```

Which generates the values of tunable parameters. For example:

# Results file

The results that are intended to be ported to another platform are 
contained in one or more files in JSON format. For example, the 
results of the STREAM micro-benchmark might be specified as:

```javascript
{
  "stream-copy": {
    "class": "memory",
    "result": "4058"
  }
}
```

In general, the schema for results has the form:

```javascript
{
  "bench-name": {
    "class": "one of memory|processor|network|io",
    "result": "number"
  },
  "otherbench": { ... }
}
```

If class is `processor`, units should be in seconds. If `memory`, 
`network` or `io`, units are rate-based (e.g. mb/s).

# Predefined micro-benchmarks

The `ivotron/microbench` docker image contains a list of used 
micro-benchmarks. This is what gets executed via the `base` subcommand 
of `porta` to obtain the results of a base system A whose performance 
is to be ported to another system B (i.e. the results file passed to 
the `tune` subcommand when `porta` runs on system B).

## Adding new benchmarks

Porta relies on docker, so adding a new benchmark means creating a 
docker image that executes one or more benchmarks and prints to 
`stdout` results in the JSON format shown above. Once an image that 
follows this convention is defined, one can copy the `microbench.yml` 
file and modify it accordingly. In order to have `porta` use this, use 
the `--file` flag of the `base` command.
