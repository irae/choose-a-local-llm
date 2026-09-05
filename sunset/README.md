# Scripts on their way out

These scripts are kept here unchanged, for one run only. During bench
10 they run beside `benchmarks/run-watch.sh` on every scoring block, and
the runner compares what each of them saw with what the new watcher saw
at block close. When the new watcher matches them over the run, this
directory is deleted at run close. Do not improve them, and do not start
them on any later run.

- `mem-watch.sh`: the memory sampler that `run-watch.sh` absorbed
  (`MEMWATCH_LOG`, `MEMWATCH_INTERVAL`).
- `liveness-watch.sh`: the one-probe liveness watcher that
  `run-watch.sh` absorbed (`STALL_SECONDS`, `PROBE_TIMEOUT`).
