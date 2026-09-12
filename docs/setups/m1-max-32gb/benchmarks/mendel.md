# Mendel — M1 Max 32 GB

The agentic tier of the quality flow, after EvalPlus: one real repo
task with known traps, scored on a 100-point
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

Each row names the serving path and the harness window. The KV cache type
of a run is in its config note in the Mendel report.

One Qwen3.6-35B-A3B score below, the guided 83 at thinking high, is
pending a re-run at low priority: it ran on a 120K harness window, and
at wired limit 25000 the model serves `-c 98304`. The score stays as a
record of what the model did; the other Qwen3.6 rows ran on windows
the machine serves today.

## Local models — blind test

<!-- gen:mendel-local:start -->
| config | score | worst defect |
|---|--:|---|
| [<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" />](../reports/qwen3.8-27b.md) | **93/100** | medium |
| [<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" />](../reports/qwen3.8-27b.md) | **87/100** | minor |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" />](../reports/qwen3.8-27b.md) | **80.5/100** | critical |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" />](../reports/qwen3.8-27b.md) | **76.5/100** | critical |
| [<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" />](../reports/qwen3.8-27b.md) | **76/100** | critical |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" />](../reports/qwen3.8-27b.md) | **66/100** (partial) | critical |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" />](../reports/qwen3.6-35b-a3b.md) | **63/100** | critical |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" />](../reports/qwen3.6-35b-a3b.md) | **50.5/100** | critical |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" />](../reports/qwen3.6-35b-a3b.md) | **50/100** | critical |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" />](../reports/gemma-4-26b-a4b.md) | **47.5/100** | critical |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" />](../reports/bonsai-27b.md) | **37.5/100** (partial) | medium |
| [<ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" />](../reports/qwen3.8-27b.md) | **37.5/100** (partial) | medium |
| [<ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" />](../reports/qwen3.8-27b.md) | **12.5/100** (partial) | minor |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" />](../reports/bonsai-27b.md) | **12.5/100** | critical |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" />](../reports/gemma-4-26b-a4b.md) | **12.5/100** (partial) | critical |
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
stop reasons. A third attempt is scheduled, with the runner's live
loop stop in place.

Three scored rows above are scheduled for a re-run: Qwen3.8-27B GGUF
blind (87), Gemma-4-26B-A4B GGUF blind (47.5) and Qwen3.6-35B-A3B
guided (83). They compacted under the harness's old reserve of 16384
tokens; since 2026-09-06 the harness reserves 8192, the answer budget.
Each keeps its row until the fresh one lands. The 87 ran at effort
medium, which Qwen3.8 is no longer run at; its fresh row is the 4-bit
build at effort xhigh, 93 above, complete on a 65536 window at the
8192 reserve. The rows at xhigh (80.5) and low (66) above are the
ISTA 3-bit build at the 8192 reserve, on a 147456 window. Every row
from 2026-09-09 on records its sampling: temperature 1.0, top_p 0.95,
the server's default.

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
| config | harness | score |
|---|---|--:|
| glm-5p3-flash | pi | **98/100** |
| deepseek-v4-flash-0731 | pi | **97/100** |
| gpt-5.6-luna | pi | **88.5/100** |
| claude-sonnet-4.5 | pi | **88/100** |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" />](../reports/qwen3.6-35b-a3b.md) | pi | **83/100** |
| Claude Haiku 4.5 | pi | **76/100** |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" />](../reports/qwen3.6-35b-a3b.md) | pi | **62.5/100** |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" />](../reports/gemma-4-26b-a4b.md) | pi | **57/100** (partial) |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" />](../reports/qwen3.6-35b-a3b.md) | pi | **46.5/100** |
| [<ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" />](../reports/gemma-4-12b-it.md) | pi | **37.5/100** (partial) |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" />](../reports/bonsai-27b.md) | pi | **31.5/100** (partial) |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" />](../reports/gemma-4-26b-a4b.md) | pi | **25/100** (partial) |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" />](../reports/bonsai-27b.md) | pi | **12.5/100** (partial) |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" />](../reports/bonsai-27b.md) | pi | **12.5/100** (partial) |
<!-- gen:mendel-guided:end -->
