# Gemma-4-12B UD-Q4_K_XL (unsloth)

File: [`unsloth/gemma-4-12b-it-GGUF`](https://huggingface.co/unsloth/gemma-4-12b-it-GGUF),
`gemma-4-12b-it-UD-Q4_K_XL.gguf`, revision `fc034cf`, about 7.5 GB. The
Mac's tables call this quant "Q4_K_XL" and the card calls it
"UD-Q4_K_XL"; it is the same file. Server: llama-server, f16 KV on the
M1 Max 32 GB (setup kamaji); llama-server on CUDA, f16 KV on the RTX
5060 Ti 16 GB (setup arrietty). Every run of this file on every
machine is on this page, retired and superseded rows included; a run a
harness or serving defect voided is not.

- **Why it is here.** On the M1 Max, the dense 12B candidate for the
  machine's 32 GB budget, and the only Gemma-4-12B entry that stays in
  scope after the MLX and LM Studio entries were ruled out for agent
  work (research 2026-09-04). On the RTX 5060 Ti, the k-quant the Mac
  serves, read on this card at the same depths as the card's NVFP4
  build, so the NVFP4 row has a control.
- **What it settled.** On the M1 Max, f16 KV wins on this model: it
  costs no context, because 262,144 fits inside the wired limit, and
  it reads 22.66 tok/s at 16K against q8_0's 7.12, already under the
  8 tok/s floor (2026-09-04, wired limit 24000, no drafter); the MTP drafter loses at every
  depth tried. On the RTX 5060 Ti, the model reads the trained 262,144
  window at f16 KV, 2 to 5 percent slower than NVFP4 on that card, and
  fails the agent task at both thinking levels with zero commits.
  Thinking is off on every current M1 Max row; thinking-on Gemma-4-12B
  failed on both other backends in a research run, so it was never
  scored on that file. At thinking off, EvalPlus reads 0.976/0.939 on
  the M1 Max against 0.951/0.909 on the RTX 5060 Ti.
- **Where it stands.** On the M1 Max, EvalPlus 0.976/0.939 at thinking
  off, no empty answer; the guided agent task ends at 37.5, 3 of 8
  libraries, on `model_budget_exhausted` — a Gemma-12B-family failure
  signature, not a harness fault. On the RTX 5060 Ti, this is a
  single-turn model at thinking off, not an agent model: the agent
  task ran at thinking on only (owner, 2026-09-14), thinking off has
  no agent row, and thinking off delivers every EvalPlus answer in 26
  minutes while thinking on loses a fifth of them to thinking that
  never ends.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" top /> | **245k** | mem | <TokCell shallow="25.0" deep="9.2" /> | **13.9 GB** | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 0h43 · Mendel 1h38">2h21</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" top /> | 2x82k | mem | <TokCell shallow="25.0" deep="15.7" stale /> | **13.8 GB** | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" top /> | 4x49k | mem | <TokCell shallow="42.9" deep="27.7" stale top-shallow top-deep /> | 25.1 GB | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" top /> | 16k | speed | <TokCell shallow="13.8" deep="6.5" stale /> | **10.5 GB** | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-unsloth-ud-q4kxl" top /> | **261k** | mem | <TokCell shallow="47.39" deep="32.18" top-shallow top-deep /> | **12.7 GB** | <ScoreCell value="0.951/0.909" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 0h26 · Mendel —">0h26†</span> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-unsloth-ud-q4kxl" /> | **261k** | mem | <TokCell shallow="47.39" deep="32.18" top-shallow top-deep /> | **12.7 GB** | <ScoreCell value="0.793/0.780" sub="79% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 4h19 · Mendel 0h05">4h24</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | none | <TokCell shallow="25.0" deep="9.2" /> | 0h43 |
| [<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-unsloth-ud-q4kxl" />](../setups/arrietty/benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.951/0.909" sub="100% completion" top /> | none | <TokCell shallow="47.39" deep="32.18" /> | 0h26 |
| [<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-unsloth-ud-q4kxl" />](../setups/arrietty/benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.793/0.780" sub="79% completion" /> | † unproven | <TokCell shallow="47.39" deep="32.18" /> | 4h19 |
<!-- gen:binary-evalplus:end -->

The M1 Max thinking-off run had no empty answer at budget 8192
(0/164). Both RTX 5060 Ti runs served `-c 32768` at budget 8192. The
thinking-on run left 34 empty answers of 164; their cause is unproven
because the run saved no finish log. The runner first reported no
empties; the coordinator re-derived the count from the samples file on
2026-09-16.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" /> | blind-v1.1 | 256k | **0** | 0/8/model-failed | 80.3 | 9,994k | 179k | 0 | 92 | 0 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" /> | guided-v3.0 | 256k | **37.5** (raw 58) | 3/8/partial | 97.6 | 6,453k | 125k | 0 | 132 | 3 | text |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-unsloth-ud-q4kxl" /> | guided-v3.0 | 256k | **0** (raw 34) | 0/8/model-failed | 5.3 | 213k | 25k | 0 | 17 | 0 | thinking |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The M1 Max guided row ends on `model_budget_exhausted` after three
model nudges, 3 of 8 libraries, the same signature the retired LM
Studio entry showed at its own high-effort guided row — read as a
Gemma-12B-family characteristic, not a harness misconfiguration.

The RTX 5060 Ti guided row ended with zero commits. Right after the
model read `package.json` to find the `uuid` dependency, its thinking
channel cycled "Wait, I'll run the removal command. / Actually, I'll
do it." 818 times, filled the 8192-token output budget in 181 seconds,
and closed on a repetition loop about 5 minutes 19 seconds after the
start. This is the second of three Gemma-12B guided rows on this card to
end without a single commit.

## Speed and context

<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" hide="drafter,effort" />

| machine | measurement | date | config | result |
|---|---|---|---|---|
| M1 Max 32 GB | MTP sweep, thinking on, f16 KV, 32K | 2026-08-27/28 | n-max 3, 4, 6 | n-max 3 peaks at 35.0 (py) / 35.6 (js) tok/s; n-max 4 peaks thinking off |
| M1 Max 32 GB | depth sweep, no drafter, f16 vs q8_0 | 2026-09-04 | `-c` above each step, wired limit 24000 | f16 22.66 tok/s at 16,411 used tokens against q8_0's 7.12, already under the 8 tok/s floor; wired memory flat at 14,186 MB, 59% of the limit |
| M1 Max 32 GB | slow creep, f16 KV, no drafter | 2026-09-04 | `-c 262144`, wired limit 24000 | 24.64 tok/s at 4,115, 8.86 at 245,810, the deepest step inside the trained window; the window is model-limited, memory stays flat |
| M1 Max 32 GB | one slot vs two slots, f16 KV | 2026-09-08 | `--parallel 1 -c 131072`; `--parallel 2 -c 196608` | one slot clean to 114,718 at 13.59 tok/s; two slots clean to 81,958 tokens each, about 71% of the one-slot depth per agent |
| M1 Max 32 GB | four slots, f16 KV | 2026-09-05 | `--parallel 4 -c 655360`, one slot swept with the others idle | clean per-slot depth 49,152 at 27.7 tok/s, gated by memory; machine ran with free memory near zero and swap already in use |
| RTX 5060 Ti 16 GB | real text, llama-benchy | 2026-09-13 | no drafter, `-c 262144`, first load passed | 47.39 tok/s at 4K, 40.26 at 98K, 32.18 at 261120; 12.7 GB of VRAM (13052 MiB) |

The RTX 5060 Ti's NVFP4 build of the same model read 49.55, 41.57 and
33.11 tok/s at the same depths on that card.

The full curves for the M1 Max are on
[the benchmarks page](../setups/kamaji/benchmarks/gemma-4-12b-it.md).

## Log

- 2026-08-27 — M1 Max: The planned block on this file (MTP n=3, q8_0
  KV, thinking on) never started; the owner paused the run after the
  third block. `hardware/kamaji/benchmarks/bench1/`.
- 2026-08-27/28 — M1 Max: MTP sweep at thinking on, chat endpoint,
  32K, f16 KV: n-max 3 is the peak (35.0 / 35.6 tok/s), thinking text
  drafts worse so the shallower depth wins; n-max 4 is the
  thinking-off peak. Also measured: the q8_0 MTP sweep (n-max 4 peak,
  39.49 / 31.06 tok/s), a no-drafter baseline (22.27 / 22.16 tok/s),
  and a q8_0-vs-f16 comparison at n-max 4 where f16 wins both prompts.
  `docs/setups/kamaji/benchmarks/gemma-4-12b-it.md`.
- 2026-08-28 — M1 Max: Calibration only at thinking on, budget 30000:
  4 of 10 sample problems hit the token cap with empty content, worse
  than the 26B sibling's 2 of 10; a genuine model-behaviour finding,
  not a bug. `hardware/kamaji/benchmarks/bench2/`.
- 2026-09-04 — M1 Max: A research run closes Gemma-4-12B on MLX and LM
  Studio for thinking-on agent work: the good 0.909/0.872 EvalPlus
  score and the three model-failed Mendel rows come from two different
  LM Studio entries that share weights but not thinking behaviour; the
  fixed chat template does not stop the thought loop on replay against
  llama-server either (post-fix template looped 1 of 2). GGUF stays in
  scope, thinking off, no MTP, to the trained window.
  `hardware/kamaji/research/run2/`.
- 2026-09-04 — M1 Max: KV depth sweep, both backends, wired limit
  24000: f16 KV, no drafter reads 24.64 tok/s at 4,115 down to 8.86 at
  245,810, the deepest step inside the trained window, wired memory
  flat at 14,186 MB; q8_0 floors under 8 tok/s by 16,411. f16 KV, no
  drafter is the picked configuration.
  `hardware/kamaji/research/run2/`.
- 2026-09-04/05 — M1 Max: EvalPlus at thinking off: 0.976/0.939, 0 of
  164 empty, budget 8192. This is the first scoring of the GGUF quant;
  it does not share a score with the MLX 4-bit build (Δbase and Δplus
  both 0.067, over the 0.012 threshold). Guided agent task at thinking
  off, f16 KV, no drafter: 3 of 8 libraries, `model_budget_exhausted`
  after three model nudges, 37.5 capped from 58 raw — the same failure
  signature as the retired LM Studio entry's high-effort guided row.
  `hardware/kamaji/benchmarks/bench9/`.
- 2026-09-05 — M1 Max: Four slots at f16 KV, `-c 655360`: one slot
  swept with the other three loaded and idle, clean per-slot depth
  49,152 at 27.7 tok/s, 25.1 GB wired; the sweep ran with free memory
  near zero and swap already in use at session start. Supersedes the
  earlier q8_0 allocation-only reading of this row (33.7 tok/s
  shallow, no measured depth). `hardware/kamaji/benchmarks/bench10/`.
- 2026-09-07/08 — M1 Max: A research run's compaction ladder finds a
  usable `contextWindow` floor on this model only, 23552, the first
  rung with two clean passes; every other model's task either never
  reached a rung or found no floor. `hardware/kamaji/research/run3/`.
- 2026-09-08 — M1 Max: Two slots, f16 KV: the ladder's `-c 770048`
  load result stands, but its own creep mem-stops at depth 16,386, so
  it is not a window measurement. Redone judged by the creep: four
  `-c` values all stop at depth 81,958 once large enough to reach it,
  so `gemma12_2x_clean` = 81,958 tokens per slot, superseding the
  earlier 8,222 reading. One slot at `-c 131072` runs clean to 114,718
  tokens at 13.59 tok/s. `hardware/kamaji/benchmarks/bench12/`.
- 2026-09-13 — RTX 5060 Ti: Named in the card's first runbook as the
  k-quant control for the NVFP4 build; the Mac's row of the same file
  is the `old` reference row. `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-13 to 2026-09-14 — RTX 5060 Ti: Speed at three depths on
  real text; `-c 262144` loads at once and serves the deep cell. Agent
  smoke at thinking off passed, 8 calls, 1 commit, 15 seconds. Guided
  agent task, run at thinking on (owner, 2026-09-14): model-failed,
  zero commits, the thinking channel repeated one line 818 times over
  the `uuid` removal and filled the output budget, 34 raw points
  capped to 0. No row is retried on its own after a zero-commit run.
  `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-15 — RTX 5060 Ti: The file moved from the llama.cpp cache to
  the default Hugging Face cache; every serve command reads it with
  `hf download`. `hardware/arrietty/benchmarks/bench19/`.
- 2026-09-16 — RTX 5060 Ti: EvalPlus at thinking off: 0.951 / 0.909,
  no empty answer, budget 8192 (the longest calibration answer ran
  1011 tokens), 26.1 minutes. The Mac's row of the same file reads
  0.976 / 0.939. EvalPlus at thinking on: 0.793 / 0.780, 34 empty
  answers of 164 at budget 8192, 259.0 minutes; every answered problem
  passed the base tests, so the whole loss is thinking that did not
  end inside the budget, as the calibration predicted with four of ten
  answers at the 30000 cap. The NVFP4 build at the same level lost 53
  answers, so this k-quant converges more often on this card. The
  runner first reported no empties on both rows; the coordinator
  re-derived the counts from the samples file on 2026-09-16.
  `hardware/arrietty/benchmarks/bench19/`.
