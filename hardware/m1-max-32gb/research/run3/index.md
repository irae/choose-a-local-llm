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

- [ ] **Control: is the gain the limit or a clean machine?** One
  Qwen3.6-35B-A3B GGUF q8_0 creep at `-c 98304`, wired limit 24000, on
  a machine preflight calls clean, no other model loaded. Run 11 got
  81958 tokens at 9.24 tok/s from the same config at 25000, and 8222
  from the 2026-09-04 measurement at 24000 on a machine whose state is
  not recorded. About ninety minutes, unattended, no sudo.
  - Reaches about 82K: the clean start was the cause. Keep 24000, no
    re-sweeps, and run 11's numbers publish as 24000 numbers.
  - Caps near 33K or fails to load `-c 98304`: the 1000 MB is real.
    Adopt 25000, and every published sweep needs a re-run to stay
    comparable (ten creeps, twelve to fifteen hours).
- [ ] **Wired limit ladder** (../wired-limit-retest.md; the procedure is
  `docs/methodology/wired-limit.md`). Needs the owner for sudo and a
  reboot. Rungs 24000, 25000, 26000, 27000, 28000, two clean passes
  each, stop at the first panic or lockup. The owner suspects 26000
  buys context; the control above says whether any rung buys anything
  the sysctl can claim.
- [ ] **A config that reaches Mendel never runs out of memory**: the
  in-turn margin, the mlx and llama findings, four tests in order
  (../no-oom-at-mendel.md; attachments in ../no-oom-at-mendel/). It
  writes the window and budget rule that
  `backlog/qwen38-mlx-window.md` waits on. Runs unattended, at
  whatever limit the ladder settles on.

Order and why: the control first, because it is cheap and it decides
whether the ladder is a re-measurement of everything or a formality.
The ladder second, when the owner is available. The no-OOM item last,
so its margin is derived at the standing limit and does not need a
second pass.

Waits on the owner: `backlog/bonsai-kv-bias-corpus.md`,
`backlog/qwen38-mlx-window.md`.
