# Research run 4, task list

Not started. The runbook (`AGENT.md`) and the rest of the kit appear
when the run starts. Items are one file each in `../`, named by
mnemonic and never numbered. **This list is the order.** The executor
checks the items off here as it goes and writes results beside the
item (`../<mnemonic>/results.md`).

Everything here runs at wired 25000, the standing limit. Items that
wait on a decision, on a download, or on the MLX margin rule live in
`../unscheduled/`, which has no index and no order.

The rules of research run 3 hold, less the withdrawn one: the KV cache
is f16; every candidate gets a context creep; a gate is a task, never a
decision taken as one result lands; no full Mendel run and no full
EvalPlus run; GGUF only; the thinking level is chosen, never inherited.

- [ ] `benchy-ab` — `llama-benchy` against the creep on the Qwen3.8 ISTA
  build, no drafter and n-max 3, four depths, at the serving sampling
  and at temperature 0, acceptance recorded per cell
  (`../benchy-ab.md`). **First on purpose**: the creep's drafter speeds
  past 16K are a 100 percent acceptance artifact, and every drafter
  table on the site reads from them until this item says what to trust.
