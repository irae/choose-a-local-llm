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
traps disclosed, and measures instruction-following. Strong API models
run blind only; local and weak models run both, so each pair shows the
lift. Scores never compare across the two tests.

The full reports are hosted here, generated from the Mendel data:

- <a href="../../../mendel/report.html" target="_blank" rel="noreferrer">Blind report</a> — scoreboard, criteria
  matrix, cost tables, defect ledger.
- <a href="../../../mendel/report-guided.html" target="_blank" rel="noreferrer">Guided report</a> — same format,
  guided runs only.

The tables below are drawn from the mirrored result files in
`benchmarks/mendel/` (`npm run docs:tables`). They show only the
current prompt version of each test (blind v1.1, guided v3.0); rows
from older prompt versions live in
[historical](../historical.md) and in the hosted reports, one
scoreboard per version.

## Local models — blind test

<!-- gen:mendel-local:start -->
| model | serving | score | worst defect |
|---|---|--:|---|
| qwen3.8-27b | llama-server | **87/100** | minor |
| [qwen3.6-35b-a3b](../reports/qwen3.6-35b-a3b.md) | llama-server | **63/100** | critical |
| [gemma-4-26b-a4b](../reports/gemma-4-26b-a4b.md) | llama-server | **47.5/100** | critical |
| [Ternary-Bonsai-27B-mlx-2bit](../reports/bonsai-27b.md) | mlx_lm.server | **37.5/100** (partial) | medium |
| [Qwen3.8-27B (mlx, low)](../reports/qwen3.8-27b.md) | mlx_lm.server | **12.5/100** (partial) | minor |
| bonsai-prism | llama-server | **12.5/100** | critical |
<!-- gen:mendel-local:end -->

Run notes for the two partials are in the
[comparison page's Mendel section](../comparison#mendel-agentic-quality-issue-13-bake-off):
both closed early on `mlx_lm.server` failures or the time budget, not
on the rubric.

Three Gemma-4-12B runs are marked invalid and are not listed above.
They ran the retired LM Studio entry `google/gemma-4-12b` with thinking
on and its pre-fix chat template, fell into a repetition loop, and
committed nothing. They measure that serving combination, not the
model — the evidence is on
[the Gemma-12B data page](./gemma-4-12b-it.md#the-retired-entry).

Two Ternary-Bonsai-27B guided runs with thinking off (2026-09-06) are
invalid and are not listed above. The first hit a dead
`gh` token and looped on login. The second ran 85 identical shell calls
in a row against a missing file and committed nothing in three hours,
and the operator stopped it. Both rows are in the guided CSV with their
stop reasons. No third attempt is scheduled.

## Cloud reference — blind test

<!-- gen:mendel-cloud:start -->
| model | harness | score |
|---|---|--:|
| kimi-k3 | pi | **93.5/100** |
| grok-4.6 | pi | **92.5/100** |
| gpt-5.6-sol | pi | **92/100** |
| claude-opus-5 | pi | **90.5/100** |
| deepseek-v4-flash-0731 | pi | **84.5/100** |
| gpt-5.6-luna | pi | **83.5/100** |
| deepseek-v4-pro-0813 | pi | **79/100** |
| glm-5p3-flash | pi | **75/100** |
| Claude Sonnet 4.5 | pi | **43.5/100** |
| claude-haiku-4.5 | pi | **34/100** |
<!-- gen:mendel-cloud:end -->

## Guided test

Two local models have guided rows on the current prompt so far,
alongside the cloud anchors. More local guided runs are queued on the
same frozen prompt; a blind-guided pair can land at different times.

<!-- gen:mendel-guided:start -->
| model | harness | score |
|---|---|--:|
| glm-5p3-flash | pi | **98/100** |
| deepseek-v4-flash-0731 | pi | **97/100** |
| gpt-5.6-luna | pi | **88.5/100** |
| claude-sonnet-4.5 | pi | **88/100** |
| [qwen3.6-35b-a3b](../reports/qwen3.6-35b-a3b.md) | pi | **83/100** |
| Claude Haiku 4.5 | pi | **76/100** |
| Gemma-4-12B (llama.cpp, off) | pi | **37.5/100** (partial) |
| [Ternary-Bonsai-27B-mlx-2bit](../reports/bonsai-27b.md) | pi | **12.5/100** (partial) |
<!-- gen:mendel-guided:end -->
