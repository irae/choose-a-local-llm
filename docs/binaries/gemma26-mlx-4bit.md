# Gemma-4-26B-A4B MLX 4-bit (mlx-community)

File: [`mlx-community/gemma-4-26b-a4b-it-4bit`](https://huggingface.co/mlx-community/gemma-4-26b-a4b-it-4bit),
4-bit MLX repack. Server: mlx_lm.server. Every run of this file on every
machine is on this page, retired and superseded rows included; a run a
harness or serving defect voided is not.

- **Why it is here.** The MLX build of the 26B-A4B model, run beside the
  GGUF UD-Q4_K_XL build as the runtime comparison on this machine.
- **What it settled.** The agent smoke failed on a truncated tool call,
  so the build never ran an agent task. The GGUF build of the same
  model finishes the agent task; the runtime is the difference. Owner
  ruling: "the MLX build `mlx-community/gemma-4-26b-a4b-it-4bit` is no
  longer a candidate here" (owner, 2026-09-12).
- **Where it stands.** Retired 2026-09-12. Its speed and quality
  numbers stay on record because they are real and explain the
  decision. The score on record is the re-run one of 2026-09-16,
  0.793/0.768 with 31 empty answers of 164 at budget 30000.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/gemma-4-26b-a4b-it-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-mlx-4bit" /> 💀 | ***66k*** | ****49.3*** → ***23.4***, mem* | ***20.0 GB*** | <ScoreCell value="0.793/0.768" sub="81% completion" top /> | <ScoreCell value="0" note="0%" pill="failed-smoke" /> | <span title="EvalPlus 9h06 · Mendel —">9h06†</span> |

💀 This MLX build is retired here: it failed the agent smoke on a truncated tool call, while the GGUF build of the same model completes the task. [Why it is not a candidate](../setups/kamaji/gemma-4-26b-a4b-mlx-retired.md).
<!-- gen:binary-rows:end -->

<!-- gen:binary-best-preset:start -->
No server preset: this file is not served by a llama.cpp build.
<!-- gen:binary-best-preset:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="Gemma-4-26B-A4B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/gemma-4-26b-a4b-it-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-mlx-4bit" />](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md) | —† | 30000 | <ScoreCell value="0.793/0.768" sub="81% completion" /> | 31 budget | — | <TokCell shallow="49.3" deep="23.4" /> | 9h06 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.
<!-- gen:binary-evalplus:end -->

The first run (2026-08-29) scored 0.713/0.701 with 46 of 164 problems
empty at the 30000-token budget, 72 percent completion. A re-run of the
46 empty problems (2026-09-16) raised the score to 0.793/0.768, with 31
still empty. Every empty answer hit the 30000-token cap with the answer
still coming: a real model convergence limit, not a harness artifact.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
No Mendel run yet.
<!-- gen:binary-mendel:end -->

No Mendel row exists for this build. The agent smoke at thinking high,
on a 65536 window at wired limit 25000, ended after six tool calls with
zero commits and a dirty tree: the server truncated a tool call in the
middle of generation and the harness could not parse it. The log shows
no OOM and no server death. A failed smoke means no full agent run.

## Speed and context

Measured on the M1 Max 32 GB, the only machine that served this file.

<ModelSpec base="Gemma-4-26B-A4B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/gemma-4-26b-a4b-it-4bit" kv="f16" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| depth sweep | 2026-08-28 to 2026-08-29 | f16 KV, wired limit 24000, slow creep | 51.1 tok/s at 4K, 43.5 at 16K, 39.6 at 24.5K, 35.6 at 33K, 28.8 at 49K, swings between 13.44 and 24.96 from 62K to 70K, last stable at 70K (12.83 tok/s) |
| Metal OOM ceiling | 2026-08-29 | same run, wired limit 24000 | OOM near 72K; gfx-resident 20.0 GB at the last stable depth |
| real-text speed, llama-benchy | 2026-09-12 | wired limit 25000 | 49.3 tok/s at 4K, 23.4 at 64K |

The full curve is on [the benchmarks page](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md).

## Server presets

<!-- gen:binary-presets:start -->
No server preset: this file is not served by a llama.cpp build.
<!-- gen:binary-presets:end -->

## Log

- 2026-08-27 — Calibrated for a 164-problem EvalPlus run at thinking on,
  budget 30000: 2 of 10 sample problems never finished reasoning under
  the cap. `hardware/kamaji/benchmarks/bench2/`.
- 2026-08-28 to 2026-08-29 — Depth sweep at f16 KV, wired limit 24000:
  fast through about 68K, then swings between roughly 13 and 24 tok/s
  from 62K to 70K, Metal OOM near 72K. `hardware/kamaji/benchmarks/bench3/`.
- 2026-08-29 — Fresh 164-problem EvalPlus run at thinking on, budget
  30000: pass@1 0.713/0.701, 46 of 164 problems empty (72 percent
  completion), every empty at the budget cap. Ran across two sessions,
  paused at 130 of 164 and resumed from the same file with no gap or
  duplicate. `hardware/kamaji/benchmarks/bench3/`.
- 2026-09-12 — Agent smoke at thinking high, 65536 window, wired limit
  25000: failed after six tool calls, zero commits, a truncated tool
  call the harness could not parse. No Mendel row exists for this
  build. Real-text speed read with llama-benchy: 49.3 tok/s at 4K, 23.4
  at 64K. The owner retired the build the same day: "the MLX build
  `mlx-community/gemma-4-26b-a4b-it-4bit` is no longer a candidate
  here." `hardware/kamaji/benchmarks/bench16/`,
  `docs/setups/kamaji/gemma-4-26b-a4b-mlx-retired.md`.
- 2026-09-16 — Re-run of the 46 empty EvalPlus problems: pass@1 rises
  to 0.793/0.768, 31 still empty, every one confirmed as the output
  budget by the re-run. `hardware/kamaji/benchmarks/bench20/`.
