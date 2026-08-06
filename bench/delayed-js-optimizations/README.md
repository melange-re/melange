# Delayed JavaScript optimization benchmark

This benchmark compares the eager (previous) and delayed JavaScript optimizer
schedules through real Dune builds. It covers cold and leaf-edit builds of both
the complete `@melange` output and the CMJ critical path, serial and parallel
execution, one and two JavaScript module systems, and four dependency shapes:

- `chain`: a long critical dependency path
- `wide`: independent modules feeding one entry point
- `diamond`: a branching dependency DAG
- `optimizer`: a chain with substantially more JavaScript optimizer work

`--optimizer-width` controls the number of exported helper functions in every
module of the optimizer topology (default: 64). Raise it to stress large JS IR
without increasing the Dune action count.

Run the full matrix from the repository's Nix development shell:

```sh
nix develop
bench/delayed-js-optimizations/run.sh \
  --output /tmp/melange-delay-js-results
```

For a quick smoke measurement:

```sh
bench/delayed-js-optimizations/run.sh \
  --output /tmp/melange-delay-js-smoke \
  --runs 2 --warmup 0 --modules 20 \
  --topologies chain --module-systems single \
  --jobs 1 --scenarios cold
```

The runner produces Hyperfine JSON, Chrome-compatible Dune action traces for
both schedules, `summary.json`, and a compact `summary.md`. The wall-clock
results measure tracing-disabled production behavior. A separate diagnostic
build enables `--mel-action-trace`, allowing the summary to report compiler
phase counts and durations without contaminating the timing samples.

Treat results as meaningful only when repeated runs are stable and compare the
same checkout, machine, power mode, Dune cache setting, and job count. The dual
module-system cases are especially important: delayed optimization shortens
the CMJ action, but repeats JavaScript optimization once per emitted module
system.
