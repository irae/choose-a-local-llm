# Research run 1, task list

Ready to start when the owner says benchmark run 28 is closed,
2026-09-20. The runbook is `AGENT.md`. Items are one file each in `../`, named by mnemonic and never
numbered. **This list is the order.** The executor checks the items
off here as it goes and writes results in `results.md`.

This run does one thing: it measures a typed decision engine, a model
category the project has not run before, with tests that are all new.
One job on the GPU at a time; the run never shares the machine with a
benchmark run.

- [x] `laya-decision-engine` — cost on CUDA and CPU, the authors'
  benchmarks against their published numbers, then the loop gate and
  the pass gate on the project's own labels
  (`../laya-decision-engine.md`). The tests and their order are in the
  item.

Closed 2026-09-21. Four tests measured and wrote numbers: `harness`,
`laya-cost` on CUDA and on the CPU, `laya-portuguese` and
`laya-pass-gate`. `laya-loop-gate` wrote its table and no measurement,
because no session log survives for any of the thirteen loop
occurrences. `laya-claims` did not run: a permission refusal that only
the owner can lift, and `retry-sweep` carries it. `state.md` holds the
handing-over section.
