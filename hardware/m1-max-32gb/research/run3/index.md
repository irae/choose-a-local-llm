# Research run 3, task list

Not started. The runbook (`AGENT.md`) and the rest of the kit appear
when the run starts. Items are one file each in `../`, named by
mnemonic and never numbered. **This list is the order.** The executor
checks the items off here as it goes and writes results beside the
item (`../<mnemonic>/results.md`).

Everything here runs at wired 25000, the limit the next runs drive.
Items that wait on a decision, on a download, or on the MLX margin
rule live in `../unscheduled/`, which has no index and no order.

Four rules hold across every item in this run:

- **The KV cache is f16.** This hardware is slow at a quantized KV
  cache. Use q8_0 only where a build cannot reach a needed depth at
  f16, and say so in the row.
- **Every candidate gets a context creep.** The creep answers speed,
  which no desk survey can.
- **No full Mendel run and no full EvalPlus run.** Research stops at
  the two smokes. A candidate that passes both becomes a bench item.
- **GGUF only.** An MLX build enters only when it is the only build of
  that model that exists.

- [ ] `qwen38-configs` — **Qwen3.8-27B: alternative GGUF quants and
  the effort levels** (../qwen38-configs.md; finding attached: ../kv-quant-on-m1.md).
  Qwen3.8 is the only local model that finished the agent task, and
  its two weak points are maximum context and decode speed. Its
  "vision off" step is answered by ../strip-modules.md: every GGUF row
  already drops the tower, so only the memory measurement remains.
  **The owner approved the three 3-bit builds on 2026-09-07 and the
  machine is fetching them, with their MTP drafters.** The trial is
  written in that file, under "The trial, as the owner approved it".
  This item takes the run first, because its files arrive first.
- [ ] `strip-modules` — **strip modules on the trusted models**
  (../strip-modules.md).
  One load pair per GGUF model, about ten minutes each, unattended. It
  measures what `--no-mmproj` already saves and whether the MTP
  drafters pay for themselves.
- [ ] `compaction-experiment` — **pi compaction at a lowered window**,
  two to four models, the summary scored
  (../compaction-experiment.md). The worker now derives
  a 8192-token keep budget under a 65536-token window, so this item
  measures whether that rule is right.
- [ ] `container-trials` — the survey, then at most three candidates
  through the three quick checks (../container-trials.md).
