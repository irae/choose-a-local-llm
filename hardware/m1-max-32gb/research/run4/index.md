# Research run 4, task list

Ready to start, 2026-09-10. Items are one file each in `../`, named
by mnemonic and never numbered. **This list is the order.** The
executor checks the items off here as it goes and writes results in
`results.md`.

Everything here runs at wired 25000, the standing limit. Items that
wait on a decision, on a download, or on the MLX margin rule live in
`../unscheduled/`, which has no index and no order.

This run does one thing: it validates `llama-benchy` as the project's
reader of decode speed at depth, on the one build whose creeps are
already on disk. The measurements that follow from a pass are
benchmark run 14's, not this run's, so the owner can switch models
once and keep two agents on the machine.

- [ ] `benchy-ab` — `llama-benchy` against the two ISTA creeps on
  disk: no drafter at 4K, 49K and 98K; n-max 3 at 98K; server-default
  sampling; acceptance recorded per cell (`../benchy-ab.md`). Pass
  criteria and the values it sets for run 14 are in the item.
