# Finding the best local coding model for your machine

A repeatable process to answer, for one specific computer: **which local
model, runtime, and configuration should I code with?** Everything runs
against OpenAI-compatible servers that a coding harness (ours: pi) can
actually use.

## Goals

1. **Usable speed at real session depth, not benchmark speed.** Decode
   speed falls as the context fills; a model that benchmarks at 60 tok/s can
   crawl at 2 tok/s mid-session. Every config gets a decode-vs-used-context
   sweep and an honest "capped by" verdict (speed floor, memory OOM, or model
   window). The user's usability floor here is 8 tok/s.
2. **Context that fits the machine while it stays a desktop.** Memory
   footprints are measured so the Mac remains usable during all-day agent
   work; harness compaction thresholds are set from the measured floor.
3. **Quality per quantization and per runtime.** Published scores cover
   full-precision models; what you run is a quant. EvalPlus (HumanEval+)
   gates every config, Aider polyglot ranks the survivors.
4. **Role assignment, not a single winner**: a thinking main agent, fast
   sub-agents, an all-day background agent, and multi-agent slots — each
   seat can go to a different model/runtime.

This repo is the worked example for one machine (Apple Silicon M1 Max,
32 GB), but the process applies to any box: substitute your memory budget
and candidates.

## Where things are

- **`comparison.html`** — the current cross-model picture: the depth/floor
  table, quality scores, current configs. Start here.
- **`report-<model>.html`** — per-model detail with copy-paste server
  commands (aliases match the pi model ids).
- **`historical.html`** — superseded measurements (retired memory limits,
  old configs). Nothing on the current pages was measured under a retired
  limit.
- **`benchmarks-<model>.md`** — full raw data, current and historical.
- **`docs/methodology.md`** — the flow: measurement rules, runtime policy,
  model-selection reasoning, the quality gate, night-run rules. The flow is
  the law; read it before running anything.
- **`docs/machine.md`** — this machine's setup, models under test, current
  state, and night-run history.
- **`night<N>/`** — unattended-run kits: runbook (`NIGHT-AGENT.md`), state,
  results, scripts.
