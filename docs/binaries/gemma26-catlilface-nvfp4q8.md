# Gemma-4-26B-A4B NVFP4Q8 (catlilface)

File: [`catlilface/Gemma-4-26B-A4B-NVFP4-GGUF`](https://huggingface.co/catlilface/Gemma-4-26B-A4B-NVFP4-GGUF),
`Gemma4-26b-NVFP4Q8.gguf`, about 15 GB, a community NVFP4 repack that
keeps attention at Q8. Server: llama-server on CUDA, f16 KV. Every run
of this file on every machine is on this page, retired and superseded
rows included; a run a harness or serving defect voided is not.

- **Why it is here.** The card runs NVFP4 natively, and this is the
  26B-A4B build that fits the 16 GB budget with part of its experts
  in host RAM.
- **What it settled.** A `--n-cpu-moe` ladder found 7 as the lowest
  layer count that loads at `-c 98304` and serves the deep cell; 6
  runs out of memory at load. The file has no MTP layers, so it
  serves without a drafter. The guided task scored 37.5, 3 of 8
  libraries, and ended on a 475-times text-repetition loop.
- **Where it stands.** EvalPlus 0.909/0.878 at thinking on, 14 of 164
  empty answers, cause unproven. Thinking off is not scored on this
  card yet.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma26-catlilface-nvfp4q8" top /> | **97k** | <TokCell shallow="58.77" deep="45.59" cap="mem" top-shallow top-deep /> | **15.2 GB** | <ScoreCell value="0.988/0.951" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 2h34 · Mendel 0h23"><b>2h57</b></span> |
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma26-catlilface-nvfp4q8" />](../setups/arrietty/benchmarks/gemma-4-26b-a4b.md) | 8192 | 16384 | <ScoreCell value="0.988/0.951" sub="100% completion" top /> | none | 19/164 | <TokCell shallow="58.77" deep="45.59" /> | 2h34 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma26-catlilface-nvfp4q8" />](../setups/arrietty/benchmarks/gemma-4-26b-a4b.md) | —† | 12500 | <ScoreCell value="0.909/0.878" sub="91% completion" /> | † unproven | — | <TokCell shallow="58.77" deep="45.59" /> | 3h35 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.
<!-- gen:binary-evalplus:end -->

The run served `-c 32768` at budget 12500. It left 14 empty answers of
164; their cause is unproven because the run saved no finish log. Two
of ten calibration problems never converged, so the budget sits just
above the longest successful answer.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma26-catlilface-nvfp4q8" /> | guided-v3.0 | 96k | **37.5** | 3/8/partial | 22.5 | 6,687k | 90k | 1 | 137 | 6 | thinking |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The row ended on a 475-times text-repetition loop
("I'll try to `git add` them and then `git status`."), scored as a
valid partial per Mendel's live-loop-stop rule. Two of its three
libraries carry medium defects, and only one of six commits ran the
full test suite first.

## Speed and context

Measured on the RTX 5060 Ti 16 GB, the only machine that served this file.

<ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| real text, llama-benchy | 2026-09-13 to 2026-09-15 | no drafter, `--n-cpu-moe 7`, `-c 98304` | 58.77 tok/s at 4K, 45.59 at 97280; 15.2 GB of VRAM |

The Mac's k-quant of the same model at f16 KV, n-max 2, reads 60.1
tok/s at 4K, 28.2 at 98K and 19.1 at its 197K deep cell (2026-09-12). The full curves are on
[the benchmarks page](../setups/arrietty/benchmarks/gemma-4-26b-a4b.md).

## Log

- 2026-09-13 to 2026-09-15 — First run on this machine. A
  `--n-cpu-moe` ladder found 7 the lowest layer count that loads at
  `-c 98304` and serves the deep cell; 6 runs out of memory at load.
  The ladder read 12 at 13495 MiB, 9 at 14719 MiB and 7 at 15535 MiB,
  and 7 also served a real request the size of the deep cell before
  the run committed to it. No MTP layers, so no drafter arm. Real-text speed: 58.77 tok/s at 4K, 45.59 at 97280, on
  a clean 97280-token depth with flat VRAM and swap. A smoke pass ran
  10 tool calls and 1 commit, clean, no loop, in 30 s. The guided task
  scored 37.5, 3 of 8 libraries (raw 65, capped), ended on a 475-times
  text-repetition loop. No EvalPlus this run (owner, 2026-09-13).
  `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-15 — Calibration for EvalPlus closes: budget 12500 from the
  non-converging rule, two of ten calibration problems never
  converged. `hardware/arrietty/benchmarks/bench19/`.
- 2026-09-16 — EvalPlus at thinking on closes: 0.909/0.878, 14 empty
  answers of 164, cause unproven (no finish log saved), 215.3 minutes
  of active time. `hardware/arrietty/benchmarks/bench19/`.
