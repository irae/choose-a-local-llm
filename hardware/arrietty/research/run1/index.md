# Research run 1, task list

Draft, 2026-09-20. Not ready to start: it waits for benchmark run 28
to close. Items are one file each in `../`, named by mnemonic and never
numbered. **This list is the order.** The executor checks the items
off here as it goes and writes results in `results.md`.

This run does one thing: it measures a typed decision engine, a model
category the project has not run before, with tests that are all new.
One job on the GPU at a time; the run never shares the machine with a
benchmark run.

- [ ] `laya-decision-engine` — cost on CUDA and CPU, the authors'
  benchmarks against their published numbers, then the loop gate and
  the pass gate on the project's own labels
  (`../laya-decision-engine.md`). The tests and their order are in the
  item.
