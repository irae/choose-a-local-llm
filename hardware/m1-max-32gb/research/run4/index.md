# Research run 4 — models, harness and packaging

Not started. The runbook (`AGENT.md`) and the rest of the kit appear
when the run starts. Items are one file each in `../`, in the order
the run takes them; the executor checks them off here as it goes and
writes results beside the item (`../<mnemonic>/results.md`).

Everything that is not the memory apparatus of
[run 3](../run3/index.md). Every context ceiling this run computes
depends on the standing wired limit, so run 3 comes first.

- [ ] **Qwen3.8-27B: alternative GGUF quants and the effort levels**
  (../qwen38-configs.md; finding attached: ../kv-quant-on-m1.md).
  Qwen3.8 is the best model that runs here, and its two weak points
  are maximum context and decode speed. Its "vision off" step is
  answered by ../strip-modules.md: every GGUF row already drops the
  tower, so only the memory measurement remains.
- [ ] **Strip modules on the trusted models** (../strip-modules.md).
  One load pair per GGUF model, about ten minutes each, unattended.
  It measures what `--no-mmproj` already saves and whether the MTP
  drafters pay for themselves.
- [ ] **pi compaction at a lowered window**, two to four models, the
  summary scored (../compaction-experiment.md). The worker now derives
  a 8192-token keep budget under a 65536-token window, so this item
  measures whether that rule is right.
- [ ] **A 10 GB agent model for the assistant harnesses**
  (../small-agent-models.md). Needs the owner's download decision
  first, then a ladder, a creep and one tool-call smoke per candidate.
- [ ] **Container trials**: the survey, then at most three candidates
  through the three quick checks (../container-trials.md).

Not scheduled, ready when the owner picks it up:
../specialized-models.md (OCR, PDF to tables, speech, email,
spreadsheets and database queries). It needs downloads, two extra
runtimes and five real inputs from the owner, so it is not an
unattended item.
