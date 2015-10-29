# porta

Porta lets you port a container's performance between distinct 
platforms. It achieves this by obtaining base metrics of a system and 
tuning container execution parameters of other systems where the 
original performance is intended to be replicated.

--------

Generate performance metrics for a system:

```bash
porta base
```

The above stores the output in a `base.json` output file.

--------

Tune a target system to replicate the performance of a container:

```bash
porta tune
```

Which expects a `base.json` file in the current directory and 
generates the values of tunable parameters (in a `parameters.json` 
file). Example output:

```javascript
{
  "mem-bw-limit": 450,
  "cpu-quota": 68700
}
```

--------

Finally, to run a container with the intent of replicating 
performance:

```bash
porta run --name foo --rm repo/container
```

Which expects a `parameters.json` file in the current directory. The 
arguments to `run` are similar to the ones for `docker run` but 
`porta` adds the `--cpu-quota` and `--mem-bw-limit` arguments.

# `base.json` file

The results that are intended to be ported to other target platforms 
are contained in one or more files in JSON format. For example, the 
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

The `ivotron/microbench` docker image contains a list of commonly used 
micro-benchmarks. This is what gets executed via the `base` subcommand 
of `porta` to obtain the metrics of a base system A. These performance 
results get passed when porting the performance to another target 
system B (i.e. the `base.json` file passed to the `tune` subcommand 
when `porta` runs on system B).

<!--
## Adding new benchmarks

Porta relies on docker, so adding a new benchmark means creating a 
docker image that executes one or more benchmarks and prints to 
`stdout` results in the JSON format shown above. Once an image that 
follows this convention is defined, one can copy the `microbench.yml` 
file and modify it accordingly. In order to have `porta` use this, use 
the `--file` flag of the `base` command.
-->

# Dependencies

  * Docker 1.7+
  * Linux headers for host kernel
