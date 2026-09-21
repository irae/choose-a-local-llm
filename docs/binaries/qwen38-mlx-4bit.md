# Qwen3.8-27B MLX 4-bit (mlx-community)

File: [`mlx-community/Qwen3.8-27B-4bit`](https://huggingface.co/mlx-community/Qwen3.8-27B-4bit),
revision `3e6447f`, about 16.1 GB, mlx-lm's 4-bit repack. Server:
`mlx_lm.server`, unquantized (f16) KV; MLX has no `-c` preallocation, so
the KV grows per request up to the trained window, memory permitting.
Every run of this file on every machine is on this page, retired and
superseded rows included; a run a harness or serving defect voided is
not.

- **Why it is here.** The first Qwen3.8-27B file measured on the M1
  Max 32 GB, picked on 2026-08-26 as the MLX arm of the
  MLX-versus-GGUF comparison, beside the bartowski GGUF build.
- **What it settled.** MLX's Metal ceiling on this model sits at 28K
  to 30K context under the slow-creep rule, far short of the roughly
  46K an agent run needs, so no Mendel attempt on this build has ever
  finished clean; every one is partial or invalid. `mlx_lm.server` has
  no drafter API, so the MTP head measured on the CLI (`mlx_vlm.generate`)
  can never serve here. The owner ruled the model "not run" on Mendel
  on 2026-09-10.
- **Where it stands.** Complete on EvalPlus at both effort levels
  (0.982/0.939 at medium, budget 8192, 2026-08-27; 0.976/0.927 at low,
  2026-08-31), with no scored agent-task row. Qwen3.8-27B is never run
  at effort medium since 2026-09-09 (owner rule,
  `benchmarks/PLANNING.md`), so the medium rows keep their numbers as a
  record, with no re-run.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" hardware="m1-max-32gb" page="/binaries/qwen38-mlx-4bit" top /> | **25k** | <TokCell shallow="17.3" deep="14.8" cap="mem" top-shallow top-deep /> | **22.0 GB** | <ScoreCell value="0.976/0.927" sub="100% completion" top /> | <ScoreCell value="12.5†" note="13%" pill="mendel-blind" top /> | <span title="EvalPlus 2h09 · Mendel 1h25"><b>3h34</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-mlx-4bit" top /> | **25k** | <TokCell shallow="17.3" deep="14.8" cap="mem" top-shallow top-deep /> | **22.0 GB** | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 3h32 · Mendel —">3h32†</span> |
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-mlx-4bit" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | —† | 8192 | <ScoreCell value="0.982/0.939" sub="100% completion" /> | none | — | <TokCell shallow="17.3" deep="14.8" /> | 3h32 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.
<!-- gen:binary-evalplus:end -->

The medium-effort pass ran clean at 0 empty completions after a
mid-run fix (a `mlx_lm.server` Metal resource-limit crash on one
request hung forever under the client's retry loop; the tool now
retries with a 7200 s timeout). The low-effort pass also ran clean.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-mlx-4bit" /> | blind-v1.0 | 26k | **37.5** (raw 80) | 3/8/partial | 253.5 | 1,777k | 24k | 0 | 135 | 6 |  |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" hardware="m1-max-32gb" page="/binaries/qwen38-mlx-4bit" /> | blind-v1.1 | 26k | **12.5** (raw 67.5) | 1/8/partial | 85.2 | 610k | 24k | 0 | 29 | 1 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" hardware="m1-max-32gb" page="/binaries/qwen38-mlx-4bit" /> | guided-v2.1 | 26k | **75** (raw 84) | 6/8/partial | 153.8 | 1,123k | 23k | 0 | 95 | 6 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

No row scores here. Every Mendel attempt on this file, blind and
guided, at medium and at low effort, ended partial or invalid: closed
early on a time or tooling budget, stalled on one-token `length` stops
once context passed about 88 percent of the declared window, or ended
in a Metal out-of-memory crash of the generation thread while
`/health` kept answering 200. `mlx-community/Qwen3.8-27B-4bit`'s
context grew past its declared window in every crash case, and
compaction fired in only one of six recorded sessions.

## Speed and context

Measured on the M1 Max 32 GB, the only machine that served this file.

<ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| fast sweep, no pause | 2026-08-26 | `mlx_lm` API, 32-token probes | clean to 48K, 96 tok/s there; Metal OOM at 64K; superseded by the slow-creep rule |
| slow-creep re-test | 2026-08-29 | wired limit 24000, 25 s pause per step | last stable 28K at 15.29 tok/s; ceiling 28-30K |
| MTP-on-MLX probe | before 2026-08-30 | `mlx_vlm.generate`, draft `Qwen3.8-27B-MTP-4bit` rev `b643c01`, depth fixed at 2 | 20.24 tok/s (py), 22.49 tok/s (js), 82.8% and 97.1% acceptance, 17.1 GB peak; CLI only, no server API (`hardware/kamaji/research/run2/`) |

The full curves are on [the benchmarks page](../setups/kamaji/benchmarks/qwen3.8-27b.md).

## Log

- 2026-08-26 — Night one: first EvalPlus pass at effort medium under a
  flawed 3072-token output cap, 0.970/0.939, 3 of 164 empty; kept only
  as the apples-to-apples comparison of that night, superseded the
  next night. `hardware/kamaji/benchmarks/bench1/`.
- 2026-08-26 to 2026-08-29 — Fast-sweep context probe (no pause between
  depth steps) found a Metal OOM near 64K after 48K clean at 96 tok/s;
  the slow-creep rule replaced it on 2026-08-29 with a last stable
  depth of 28K at 15.29 tok/s and a ceiling of 28K to 30K at wired
  limit 24000. `hardware/kamaji/benchmarks/bench2/`.
- 2026-08-27 — Corrected EvalPlus pass at effort medium under an 8192
  budget: 0.982/0.939, 0 empty, after fixing a `mlx_lm.server` Metal
  resource-limit crash that had hung one request forever.
  `hardware/kamaji/benchmarks/bench2/`.
- 2026-08-30 to 2026-09-01 — First Mendel attempts. Blind v1.0 at
  effort medium closed at 3 of 8 libraries after 253.5 minutes: raw
  80, re-scored 37.5/100 once partial scoring was capped at 12.5
  points per completed library. Guided v2.1 at effort low scored
  75/100, partial, 6 of 8 (raw 84). Prompt v1.0 is superseded by the
  prompt-version reset of 2026-09-02; the row stays as a record on
  [the historical page](../setups/kamaji/historical.md).
  `hardware/kamaji/benchmarks/bench5/`.
- 2026-08-31 — EvalPlus at effort low: 0.976/0.927, 100% completion.
  `hardware/kamaji/benchmarks/bench6/`.
- 2026-09-01 — Mendel blind v1.1 at effort low: 12.5/100, partial, 1 of
  8, a harness stall from one-token `length` stops once context passed
  about 88 percent of the declared 26624-token window (a
  `contextWindow`/`maxTokens` mismatch, not a model defect). A guided
  v3.0 retry at effort low scored 0/100, partial, 0 of 8, tooling
  budget exhausted; worse than the run it retried.
  `hardware/kamaji/benchmarks/bench7/`.
- 2026-09-04 to 2026-09-05 — Guided v3.0 at effort low retried three
  times after a `maxTokens` fix removed the one-token stops; the model
  still grew context past the declared 26624-token window in real
  agentic use and crashed the `mlx_lm.server` generation thread on a
  Metal out-of-memory twice, at prompts of 22892 and 27969 tokens,
  with zero commits on both real attempts. Ruled invalid, root cause
  open. `hardware/kamaji/benchmarks/bench9/`.
- 2026-09-05 — The window question filed as its own item: a smaller
  `contextWindow` with headroom for in-turn growth, an earlier
  compaction trigger, or a measured margin, against the research item
  on MLX Metal-OOM margins.
  `hardware/kamaji/benchmarks/unscheduled/qwen38-mlx-window.md`.
- 2026-09-10 — The owner ruled the model "not run" on Mendel at effort
  medium: no Mendel attempt on this file has ever finished, the GGUF
  build already holds the model's scored agent-task row, and nothing
  else waits on the margin research. The effort-low row's `mendel` cell stays `pending`, marked
  stale, since it shares the model's speed curve with the medium row
  but was never itself retried.
