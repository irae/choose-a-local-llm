# Gemma-4-12B Q4_K_XL (unsloth) on M1 Max 32 GB

File: [`unsloth/gemma-4-12b-it-GGUF`](https://huggingface.co/unsloth/gemma-4-12b-it-GGUF),
`gemma-4-12b-it-UD-Q4_K_XL.gguf`, revision `fc034cf`, about 7.5 GB.
Server: llama-server, f16 KV. Every run of this file on this machine is
on this page, retired and superseded rows included; a run a harness or
serving defect voided is not.

- **Why it is here.** The dense 12B candidate for the machine's 32 GB
  budget, and the only Gemma-4-12B entry that stays in scope after the
  MLX and LM Studio entries were ruled out for agent work (research
  2026-09-04).
- **What it settled.** f16 KV wins on this model: it costs no context,
  because 262,144 fits inside the wired limit, and it is 3.2x faster
  than q8_0 at 16K. The MTP drafter loses at every depth tried. Thinking
  is off on every current row; thinking-on Gemma-4-12B failed on both
  other backends in a research run, so it was never scored on this
  file.
- **Where it stands.** EvalPlus 0.976/0.939 at thinking off, no empty
  answer. The guided agent task ends at 37.5, 3 of 8 libraries, on
  `model_budget_exhausted` — a Gemma-12B-family failure signature, not
  a harness fault.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/setups/kamaji/binaries/gemma12-unsloth-q4kxl" top /> | **245k** | mem | <TokCell shallow="25.0" deep="9.2" top-shallow /> | **13.9 GB** | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 0h43 · Mendel 1h38">2h21</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/setups/kamaji/binaries/gemma12-unsloth-q4kxl" top /> | **2x82k** | mem | <TokCell shallow="25.0" deep="15.7" stale top-shallow top-deep /> | **13.8 GB** | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="f16" effort="off" page="/setups/kamaji/binaries/gemma12-unsloth-q4kxl" top /> | **4x49k** | mem | <TokCell shallow="42.9" deep="27.7" stale top-shallow top-deep /> | 25.1 GB | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="q8_0" effort="off" page="/setups/kamaji/binaries/gemma12-unsloth-q4kxl" top /> | 16k | speed | <TokCell shallow="13.8" deep="6.5" stale /> | **10.5 GB** | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/setups/kamaji/binaries/gemma12-unsloth-q4kxl" />](../benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | none | <TokCell shallow="25.0" deep="9.2" /> | 0h43 |
<!-- gen:binary-evalplus:end -->

The thinking-off run had no empty answer at budget 8192 (0/164).

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/setups/kamaji/binaries/gemma12-unsloth-q4kxl" /> | blind-v1.1 | 256k | **0** | 0/8/model-failed | 80.3 | 9,994k | 179k | 0 | 92 | 0 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/setups/kamaji/binaries/gemma12-unsloth-q4kxl" /> | guided-v3.0 | 256k | **37.5** (raw 58) | 3/8/partial | 97.6 | 6,453k | 125k | 0 | 132 | 3 | text |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The guided row ends on `model_budget_exhausted` after three model
nudges, 3 of 8 libraries, the same signature the retired LM Studio
entry showed at its own high-effort guided row — read as a
Gemma-12B-family characteristic, not a harness misconfiguration.

## Speed and context

<ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| MTP sweep, thinking on, q8_0 KV, 32K | 2026-08-27/28 | n-max 3, 4, 6 | n-max 3 peaks at 35.0 (py) / 35.6 (js) tok/s; n-max 4 peaks thinking off |
| depth sweep, no drafter, f16 vs q8_0 | 2026-09-04 | `-c` above each step, wired limit 24000 | f16 22.66 tok/s at 16,411 against q8_0's 6.53, both KV types at flat 14,186 MB wired for f16 |
| slow creep, f16 KV, no drafter | 2026-09-04 | `-c 262144`, wired limit 24000 | 24.64 tok/s at 4,115, 8.86 at 245,810, the deepest step inside the trained window; the window is model-limited, memory stays flat |
| one slot vs two slots, f16 KV | 2026-09-08 | `--parallel 1 -c 131072`; `--parallel 2 -c 196608` | one slot clean to 114,718 at 13.59 tok/s; two slots clean to 81,958 tok/s each, about 71% of the one-slot depth per agent |
| four slots, f16 KV | 2026-09-05 | `--parallel 4 -c 655360`, one slot swept with the others idle | clean per-slot depth 49,152 at 27.7 tok/s, gated by memory; machine ran with free memory near zero and swap already in use |

The full curves are on
[the benchmarks page](../benchmarks/gemma-4-12b-it.md).

## Log

- 2026-08-27 — The first bench run's block on this file (MTP n=3, q8_0 KV,
  thinking on) was never started; the owner paused the run after
  block 3. `hardware/kamaji/benchmarks/bench1/`.
- 2026-08-27/28 — MTP sweep at thinking on, chat endpoint, 32K, f16 KV:
  n-max 3 is the peak (35.0 / 35.6 tok/s), thinking text drafts worse
  so the shallower depth wins; n-max 4 is the thinking-off peak. Also
  measured: the q8_0 MTP sweep (n-max 4 peak, 39.49 / 31.06 tok/s), a
  no-drafter baseline (22.27 / 22.16 tok/s), and a q8_0-vs-f16
  comparison at n-max 4 where f16 wins both prompts. `hardware/kamaji/benchmarks/gemma-4-12b-it.md`.
- 2026-08-28 — Calibration only at thinking on, budget 30000: 4 of 10
  sample problems hit the token cap with empty content, worse than the
  26B sibling's 2 of 10; a genuine model-behaviour finding, not a bug.
  `hardware/kamaji/benchmarks/bench2/`.
- 2026-09-04 — A research run closes Gemma-4-12B on MLX and LM Studio
  for thinking-on agent work: the good 0.909/0.872 EvalPlus score and
  the three model-failed Mendel rows come from two different LM Studio
  entries that share weights but not thinking behaviour; the fixed
  chat template does not stop the thought loop on replay against
  llama-server either (post-fix template looped 1 of 2). GGUF stays in
  scope, thinking off, no MTP, to the trained window.
  `hardware/kamaji/research/run2/`.
- 2026-09-04 — KV depth sweep, both backends, wired limit 24000: f16
  KV, no drafter reads 24.64 tok/s at 4,115 down to 8.86 at 245,810,
  the deepest step inside the trained window, wired memory flat at
  14,186 MB; q8_0 floors under 8 tok/s by 16,411. f16 KV, no drafter is
  the picked configuration. `hardware/kamaji/benchmarks/gemma-4-12b-it.md`.
- 2026-09-04/05 — EvalPlus at thinking off: 0.976/0.939, 0 of 164
  empty, budget 8192. This is the first scoring of the GGUF quant; it
  does not share a score with the MLX 4-bit build (Δbase and Δplus
  both 0.067, over the 0.012 threshold). Guided agent task at thinking
  off, f16 KV, no drafter: 3 of 8 libraries, `model_budget_exhausted`
  after three model nudges, 37.5 capped from 58 raw — the same failure
  signature as the retired LM Studio entry's high-effort guided row.
  `hardware/kamaji/benchmarks/bench9/`.
- 2026-09-05 — Four slots at f16 KV, `-c 655360`: one slot swept with
  the other three loaded and idle, clean per-slot depth 49,152 at 27.7
  tok/s, 25.1 GB wired; the sweep ran with free memory near zero and
  swap already in use at session start. Supersedes the earlier q8_0
  allocation-only reading of this row (33.7 tok/s shallow, no measured
  depth). `hardware/kamaji/benchmarks/bench10/`.
- 2026-09-07/08 — A research run's compaction ladder finds a usable
  `contextWindow` floor on this model only, 23552, the first rung with
  two clean passes; every other model's task either never reached a
  rung or found no floor. `hardware/kamaji/research/run3/`.
- 2026-09-08 — Two slots, f16 KV: the ladder's `-c 770048` load result
  stands, but its own creep mem-stops at depth 16,386, so it is not a
  window measurement. Redone judged by the creep: four `-c` values all
  stop at depth 81,958 once large enough to reach it, so
  `gemma12_2x_clean` = 81,958 tokens per slot, superseding the earlier
  8,222 reading. One slot at `-c 131072` runs clean to 114,718 tokens
  at 13.59 tok/s. `hardware/kamaji/benchmarks/bench12/`.
