# Mendel — M1 Max 32 GB

The agentic tier of the quality flow, after EvalPlus and before
polyglot: one real repo task with known traps, scored on a 100-point
rubric — from the open-source
[Mendel](https://github.com/irae/mendel/tree/benchmark) project, where
the task, the rubric, and the raw results live. Method and house rules:
[Mendel in the methodology](../../../methodology/mendel).

Mendel is two tests on the same task. The **blind** test gives a terse
prompt and asks whether the model finds the traps by itself. The
**guided** test hands every model the same structured plan with the
traps disclosed, and measures instruction-following — all new runs use
it. Scores never compare across the two tests.

The full reports are hosted here, generated from the Mendel data:

- [Blind report](../../../mendel/report.html) — scoreboard, criteria
  matrix, cost tables, defect ledger.
- [Guided report](../../../mendel/report-guided.html) — same format,
  guided runs only.

The tables below are drawn from the mirrored result files in
`benchmarks/mendel/` (`npm run docs:tables`).

## Local models — blind test

<!-- gen:mendel-local:start -->
| model | serving | score | worst defect |
|---|---|--:|---|
| [Qwen3.8-27B-4bit](../reports/qwen3.8-27b.md) | mlx_lm.server | **80.0/100** (partial) | medium |
| [Ternary-Bonsai-27B-mlx-2bit](../reports/bonsai-27b.md) | mlx_lm.server | **58.0/100** (partial) | critical |
| [qwen3.6-35b-a3b](../reports/qwen3.6-35b-a3b.md) | llama-server | **41.5/100** | critical |
| [gemma-4-26b-a4b](../reports/gemma-4-26b-a4b.md) | llama-server | **38/100** (partial) | critical |
<!-- gen:mendel-local:end -->

Run notes for the two partials are in the
[comparison page's Mendel section](../comparison#mendel-agentic-quality-issue-13-bake-off):
both closed early on `mlx_lm.server` failures or the time budget, not
on the rubric.

## Cloud reference — blind test

<!-- gen:mendel-cloud:start -->
| model | harness | score |
|---|---|--:|
| grok-4.6 | pi | **89.5/100** |
| claude-opus-5 | claude-code | **87/100** |
| gpt-5.6-luna | pi | **84.5/100** |
| claude-sonnet-5 | claude-code | **81.5/100** |
| kimi-k3 | pi | **80.5/100** |
| deepseek-v4-pro-0813 | pi | **70.5/100** |
| gpt-5.6-sol | pi | **65.5/100** |
| claude-haiku-4.5 | claude-code | **49.5/100** |
<!-- gen:mendel-cloud:end -->

## Guided test

Three local models have run the guided prompt so far, alongside two
cloud anchors. Two more local runs (Gemma-12B, Qwen3.8-27B at effort
medium) are still queued on the same frozen prompt.

<!-- gen:mendel-guided:start -->
| model | harness | score |
|---|---|--:|
| claude-sonnet-5 | claude-code | **98.5/100** |
| [Qwen3.8-27B-4bit](../reports/qwen3.8-27b.md) | pi | **84/100** (partial) |
| [Ternary-Bonsai-27B-mlx-2bit](../reports/bonsai-27b.md) | pi | **69.0/100** (partial) |
| claude-haiku-4.5 | claude-code | **68/100** |
| [qwen3.6-35b-a3b](../reports/qwen3.6-35b-a3b.md) | pi | **65.5/100** |
<!-- gen:mendel-guided:end -->
