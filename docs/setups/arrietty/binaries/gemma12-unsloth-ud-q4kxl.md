# Gemma-4-12B UD-Q4_K_XL (unsloth) on RTX 5060 Ti 16 GB

File: [`unsloth/gemma-4-12b-it-GGUF`](https://huggingface.co/unsloth/gemma-4-12b-it-GGUF),
`gemma-4-12b-it-UD-Q4_K_XL.gguf`, revision `fc034cf`, about 7 GB.
Server: llama-server on CUDA, f16 KV. Every run of this file on this
machine is on this page, retired and superseded rows included; a run a
harness or serving defect voided is not.

- **Why it is here.** The k-quant the Mac serves, read on this card at
  the same depths as the card's NVFP4 build, so the NVFP4 row has a
  control.
- **What it settled.** The model reads the trained 262,144 window at
  f16 KV, 2 to 5 percent slower than NVFP4 on this card. It fails the
  agent task at both thinking levels with zero commits. Thinking off
  delivers every EvalPlus answer in 26 minutes; thinking on loses a
  fifth of them to thinking that never ends.
- **Where it stands.** A single-turn model at thinking off on this
  card, not an agent model. The agent task ran at thinking on only
  (owner, 2026-09-14); thinking off has no agent row.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" top /> | **261k** | mem | <TokCell shallow="47.39" deep="32.18" top-shallow top-deep /> | **12.7 GB** | <ScoreCell value="0.951/0.909" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 0h26 · Mendel —">0h26†</span> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" /> | **261k** | mem | <TokCell shallow="47.39" deep="32.18" top-shallow top-deep /> | **12.7 GB** | <ScoreCell value="0.793/0.780" sub="79% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 4h19 · Mendel 0h05">4h24</span> |
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" />](../benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.951/0.909" sub="100% completion" top /> | none | <TokCell shallow="47.39" deep="32.18" /> | 0h26 |
| [<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" />](../benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.793/0.780" sub="79% completion" top /> | † unproven | <TokCell shallow="47.39" deep="32.18" /> | 4h19 |
<!-- gen:binary-evalplus:end -->

The thinking-on empties are unproven because the run saved no finish
log; the runner also first reported `0/164` from a log line, which the
coordinator corrected against the samples file.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" /> | guided-v3.0 | 256k | **0** (raw 34) | 0/8/model-failed | 5.3 | 213k | 25k | 0 | 17 | 0 | thinking |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The row ended with zero commits. Right after the model read
`package.json` to find the `uuid` dependency, its thinking channel
cycled "Wait, I'll run the removal command. / Actually, I'll do it."
818 times, filled the 8192-token output budget in 181 seconds, and
closed on a repetition loop about 5 minutes 19 seconds after the
start. This is the second of three Gemma-12B guided rows this run to
end without a single commit.

## Speed and context

<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| real text, llama-benchy | 2026-09-13 | no drafter, `-c 262144`, first load passed | 47.39 tok/s at 4K, 40.26 at 98K, 32.18 at 261120; 13.0 to 13.1 GB of VRAM |

The NVFP4 build of the same model read 49.55, 41.57 and 33.11 at the
same depths on the same day.

## Log

- 2026-09-13 — Named in the card's first runbook as the k-quant
  control for the NVFP4 build; the Mac's row of the same file is the
  `old` reference row. `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-13 to 2026-09-14 — Speed at three depths on real text; `-c
  262144` loads at once and serves the deep cell. Agent smoke at
  thinking off passed, 8 calls, 1 commit, 15 seconds. Guided agent
  task, run at thinking on (owner, 2026-09-14): model-failed, zero
  commits, the thinking channel repeated one line 818 times over the
  `uuid` removal and filled the output budget, 34 raw points capped to
  0. No row is retried on its own after a zero-commit run.
  `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-15 — The file moved from the llama.cpp cache to the default
  Hugging Face cache; every serve command reads it with `hf download`.
- 2026-09-16 — EvalPlus at thinking off: 0.951 / 0.909, no empty
  answer, budget 8192 (the longest calibration answer ran 1011
  tokens), 26.1 minutes. The Mac's row of the same file reads 0.976 /
  0.939. EvalPlus at thinking on: 0.793 / 0.780, 34 empty answers of
  164 at budget 8192, 259.0 minutes; every answered problem passed the
  base tests, so the whole loss is thinking that did not end inside
  the budget, as the calibration predicted with four of ten answers at
  the 30000 cap. The NVFP4 build at the same level lost 53 answers, so
  this k-quant converges more often on this card. The runner first
  reported no empties on both rows; the coordinator re-derived the
  counts from the samples file on 2026-09-16.
  `hardware/arrietty/benchmarks/bench19/`.
