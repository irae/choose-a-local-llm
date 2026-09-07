# Research run 3, task list

Not started. The runbook (`AGENT.md`) and the rest of the kit appear
when the run starts. Items are one file each in `../`, in the order
the run takes them; the executor checks them off here as it goes and
writes results beside the item (`../<mnemonic>/results.md`).

Order set by the owner on 2026-09-07: the no-OOM item first, the
Qwen3.8 work second. Qwen3.8 is the best model that runs here, and its
two weak points are maximum context and decode speed; the no-OOM item
produces the window and budget rule that its MLX row needs
(`backlog/qwen38-mlx-window.md` waits on it).

- [ ] A config that reaches Mendel never runs out of memory: the
  in-turn margin, the mlx and llama findings, four tests in order
  (../no-oom-at-mendel.md; attachments in ../no-oom-at-mendel/). Runs
  unattended.
- [ ] Wired limit retest (../wired-limit-retest.md; the procedure is
  `docs/methodology/wired-limit.md`). Needs the owner for sudo and a
  reboot, so it runs when the owner is available. It comes before the
  Qwen3.8 quant work, because every context ceiling that work
  computes depends on the standing limit, and run 11 left the limit
  open at 24000 or 25000.
- [ ] Qwen3.8-27B: alternative GGUF quants, the context each buys, and
  the effort-level question (../qwen38-configs.md; finding attached:
  ../kv-quant-on-m1.md). Its "vision off" step is answered by
  ../strip-modules.md: every GGUF row already drops the tower, so only
  the memory measurement remains.
- [ ] pi compaction at a lowered window, two to four models, the
  summary scored (../compaction-experiment.md)
- [ ] Container trials: the survey, then at most three candidates
  through the three quick checks (../container-trials.md)

Not on this list, ready when the owner picks them up:
../strip-modules.md (one load pair per GGUF model, unattended),
../small-agent-models.md (needs a download decision first),
../specialized-models.md (needs downloads, two runtimes and five real
inputs from the owner).

Waits on the owner: `backlog/bonsai-kv-bias-corpus.md`,
`backlog/qwen38-mlx-window.md`.
