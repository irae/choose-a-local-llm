# Gemma-4-12B NVFP4 (FreedomAISVR)

File: [`FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF`](https://huggingface.co/FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF),
`gemma-4-12b-it-nvfp4.gguf`, revision `207974a`, about 7 GB, a
community NVFP4 repack. Server: llama-server on CUDA, f16 KV. Every run
of this file on every machine is on this page, retired and superseded
rows included; a run a harness or serving defect voided is not.

- **Why it is here.** The card runs NVFP4 natively, so at least one
  NVFP4 build was on the first run's list; this one leaves room for the
  model's trained 262,144 window at f16 KV on 16 GB.
- **What it settled.** NVFP4 fits and reads 2 to 5 percent faster than
  the k-quant of the same model on this card. The model fails the
  agent task at both thinking levels with zero commits. Thinking off
  delivers every EvalPlus answer in 51 minutes; thinking on loses a
  third of them to thinking that never ends.
- **Where it stands.** A single-turn model at thinking off on this
  card, not an agent model. Its thinking-on row is the first case of
  the thinking-budget test.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-freedomaisvr-nvfp4" /> | **261k** | <TokCell shallow="49.55" deep="33.11" cap="mem" top-shallow top-deep /> | **12.3 GB** | <ScoreCell value="0.927/0.896" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h51 · Mendel 0h01"><b>0h52</b></span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-freedomaisvr-nvfp4" /> | **261k** | <TokCell shallow="49.55" deep="33.11" cap="mem" top-shallow top-deep /> | **12.3 GB** | <ScoreCell value="0.659/0.640" sub="68% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 3h24 · Mendel 0h06"><b>3h29</b></span> |
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-freedomaisvr-nvfp4" />](../setups/arrietty/benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.927/0.896" sub="100% completion" top /> | none | <TokCell shallow="49.55" deep="33.11" /> | 0h51 |
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-freedomaisvr-nvfp4" />](../setups/arrietty/benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.659/0.640" sub="68% completion" top /> | † unproven | <TokCell shallow="49.55" deep="33.11" /> | 3h24 |
<!-- gen:binary-evalplus:end -->

Both runs served `-c 32768` at budget 8192. The thinking-off run left
no empty answer of 164. The thinking-on run left 53 empty answers of
164; their cause is unproven because the run saved no finish log. The
runner first reported no empties; the coordinator re-derived the count
from the samples file on 2026-09-16. The calibration predicted the
loss, with five of ten answers at the 30000 cap.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-freedomaisvr-nvfp4" /> | guided-v3.0 | 256k | **0** (raw 34) | 0/8/model-failed | 1.0 | 296k | 13k | 0 | 30 | 0 |  |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-freedomaisvr-nvfp4" /> | guided-v3.0 | 256k | **0** (raw 34) | 0/8/model-failed | 5.5 | 496k | 39k | 0 | 24 | 0 | thinking |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

Both rows ended with zero commits. At thinking off the model sent the
same tool call five times in a row and the run ended after 59 seconds.
At thinking on it broke an `xtend` edit, then repeated the planned fix
520 times in its thinking and never made the call. Gemma-12B agent
rows run at thinking on (owner, 2026-09-14): no Mendel run at thinking
off. The thinking-off row above stays as the record of its attempt and
is not retried.

## Speed and context

Measured on the RTX 5060 Ti 16 GB, the only machine that served this file.

<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| real text, llama-benchy | 2026-09-14 | no drafter, `-c 262144`, first load passed | 49.55 tok/s at 4K, 41.57 at 98K, 33.11 at 261120; 12.3 to 12.6 GB of VRAM |

The k-quant of the same model read 47.39, 40.26 and 32.18 tok/s at the
same depths on this card.

## Log

- 2026-09-13 — Named in the card's first runbook as the NVFP4 build of
  the 12B, beside the unsloth k-quant as its control.
  `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-14 — Speed at three depths on real text; `-c 262144` loads
  at once and serves the deep cell. Agent smoke at thinking off passed.
  Guided agent task at thinking off: model-failed, the same tool call
  five times in a row, 59 seconds, zero commits. Guided at thinking on:
  model-failed, zero commits, 34 raw points capped to 0. No row is
  retried on its own after a zero-commit run.
  `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-15 — The file moved from the llama.cpp cache to the default
  Hugging Face cache; every serve command reads it with `hf download`.
  `hardware/arrietty/benchmarks/bench19/`.
- 2026-09-16 — EvalPlus at thinking off: 0.927 / 0.896, no empty
  answer, budget 8192 (the longest calibration answer ran 949 tokens),
  51.1 minutes. EvalPlus at thinking on: 0.659 / 0.640, 53 empty
  answers of 164 at budget 8192, 203.9 minutes in two parts. The
  runner first set a 1700 budget as a waste limiter because five of
  ten calibration answers hit the 30000 cap; the owner restored the
  8192 floor after 32 answers, which stayed. The runner reported no
  empties; the coordinator re-derived 53 from the samples file. `hardware/arrietty/benchmarks/bench19/`.
- 2026-09-16 — Thinking-budget test started on this file: calibration
  with reasoning lengths, 4 of 10 converged, thinking budget 7350,
  `max_tokens` 9398. The budgeted full run: 0.976 / 0.951, no empty
  answer, 45 forced answers of which 42 pass, 194.8 minutes, against
  0.659 / 0.640 with 53 empties in 203.9 minutes without the budget.
  The natural re-run of the six forced failures found all six at the
  30000 cap without the budget too, so the 7350 budget stands. `hardware/arrietty/benchmarks/bench21/`.
