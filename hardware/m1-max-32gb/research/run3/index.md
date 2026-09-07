# Research run 3 — memory: the wired limit and the no-OOM rule

Not started. The runbook (`AGENT.md`) and the rest of the kit appear
when the run starts. Items are one file each in `../`, in the order
the run takes them; the executor checks them off here as it goes and
writes results beside the item (`../<mnemonic>/results.md`).

This run holds the two items that share one apparatus: a served model,
a slow creep, and the memory watcher. Both change every published
ceiling, so they run together and before any work that computes a
context from a limit. Everything else moved to
[run 4](../run4/index.md).

Why they belong together (2026-09-07). The wired limit item asks what
`iogpu.wired_limit_mb` should be. The no-OOM item asks what margin a
config needs so an agent run never dies of memory. Run 11 showed the
two questions are one: at limit 24000 the machine already held 25.0 to
25.5 GB wired during creeps, and at 25000 it held 25.3 to 26.0 GB, so
the sysctl was not the binding constraint in either regime. What
changed the result was the machine's state at the start.

- [x] **Control: is the gain the limit or a clean machine?** Answered
  2026-09-07 by run 12's pre-block prep
  (`../../benchmarks/bench12/results.md`): at wired 24000 the same
  model serves `-c 40960` at q8_0 and `-c 33792` at f16, against
  `-c 98304` and `-c 40960` at 25000. The gain was the limit, not the
  machine state. 24000 stands, because six creeps there showed zero
  swap growth while 25000 swapped under back-to-back sweeps. Only
  Qwen3.6 changed rows; no other model needs a re-sweep.
- [ ] **A config that reaches Mendel never runs out of memory**: the
  in-turn margin, the mlx and llama findings, four tests in order
  (../no-oom-at-mendel.md; attachments in ../no-oom-at-mendel/). It
  writes the window and budget rule that
  `backlog/qwen38-mlx-window.md` waits on. Runs unattended, at
  whatever limit the ladder settles on.

One item is left. The ladder above 24000 moved to the backlog as a
later item (`backlog/wired-limit-ladder.md`, owner 2026-09-07): 24000
stands and the higher rungs are not wanted for now. The no-OOM item
runs unattended at 24000 and needs nothing from the owner.

Waits on the owner: `backlog/bonsai-kv-bias-corpus.md`,
`backlog/qwen38-mlx-window.md`.
