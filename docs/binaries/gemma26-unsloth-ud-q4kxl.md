# Gemma-4-26B-A4B UD-Q4_K_XL (unsloth)

File: [`unsloth/gemma-4-26b-a4b-it-GGUF`](https://huggingface.co/unsloth/gemma-4-26b-a4b-it-GGUF),
`UD-Q4_K_XL`, about 14.2 GB, a mixture-of-experts model with 26B total
parameters and about 4B active per token. Server: llama-server, with
an MTP draft head (`mtp-gemma-4-26B-A4B-it.gguf`, about 460 MB), n-max
2. Every run of this file on every machine is on this page, retired
and superseded rows included; a run a harness or serving defect voided
is not.

- **Why it is here.** The only MoE build of the 26B model on this
  machine, and the first file measured on this hardware.
- **What it settled.** f16 KV lifts this model out of the 8 tok/s
  floor, after a parked spell at q8_0 KV: `-c 212992` is the largest
  that loads on the Mac (229376 and 262144 OOM at load), and it holds
  17.30 tok/s at 196,618 used tokens. Memory sets that ceiling, not
  the trained window. Thinking on passes the agent task; thinking off loops on
  the same five edit calls every time. A server thinking budget of
  19491 tokens turns every one of the model's long-thinking empties
  into a scored answer, at a fraction of the wall clock.
- **Where it stands.** Blind 47.5/100, complete, at thinking on. The
  budgeted EvalPlus score, 0.988/0.957 with no empty, is pending the
  owner's word on how a budgeted row is shown beside the natural ones.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" top /> | **197k** | <TokCell shallow="60.1" deep="19.1" cap="mem" top-shallow top-deep /> | **25.6 GB** | <ScoreCell value="0.896/0.872" sub="90% completion" top /> | <ScoreCell value="47.5" pill="mendel-blind" top /> | <span title="EvalPlus 5h47 · Mendel 1h21"><b>7h08</b></span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" top /> | **2x82k** | <TokCell shallow="66.6" deep="33.6" cap="mem" stale top-shallow top-deep /> | **25.3 GB** | <ScoreCell value="0.896/0.872" sub="90% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 5h47 · Mendel —">5h47†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md) | 8192 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | <TokCell shallow="60.1" deep="19.1" /> | 0h20 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md) | 30000 | <ScoreCell value="0.896/0.872" sub="90% completion" top /> | 16 budget | <TokCell shallow="60.1" deep="19.1" /> | 5h47 |
<!-- gen:binary-evalplus:end -->

Every empty at thinking on and 30000 tokens is the output budget, not
a harness fault: the re-run of the 18 empty problems from the first
score recovered 2 and confirmed 16 as a real model limit
(2026-09-16). Under a 19491-token server thinking budget the same
config left no problem empty; 16 of 164 hit the budget and were
forced to answer, and 15 of those 16 passed.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" /> | blind-v1.1 | 208k | **47.5** | 8/8/done | 80.8 | 23,832k | 209k | 1 | 246 | 21 |  |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" /> | blind-v1.0 | 256k | **38** | 8/8/partial | 104.0 | 8,150k | 142k | 0 | 115 | 9 |  |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" /> | blind-v1.1 | 208k | **12.5** | 1/8/partial | 28.0 | 8,053k | 136k | 0 | 120 | 7 | tool call |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" /> | guided-v3.0 | 208k | **57** | 7/8/partial | 115.1 | 24,803k | 209k | 2 | 269 | 13 |  |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" /> | guided-v3.0 | 208k | **25** | 2/8/partial | 20.4 | 2,605k | 73k | 0 | 91 | 3 | tool call |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The thinking-off blind and guided rows both ended on the live loop
stop, five identical edit calls, inside half an hour. The thinking-on
guided row completed 7 of 8 libraries at 57, its third attempt after
two memory kills on earlier tries. The thinking-on blind row scored
47.5, complete, 8 of 8, with one critical trap hit.

## Speed and context

Measured on the M1 Max 32 GB, the only machine that served this file.

<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" kv="f16" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| MTP sweep, thinking on | 2026-08-28 | n-max 2 to 4, 32K, f16 KV | n-max 2 peak, 71.88 tok/s py / 69.25 js at 84%/78% acceptance |
| MTP sweep, thinking off | 2026-08-28 | n-max 2 to 4, 32K, f16 KV | n-max 2 peak, 74.81 tok/s py / 71.59 js at 88%/81% acceptance |
| context ramp | 2026-08-28 | q8_0 KV, `-c 262144`, limit 25000 | 23.5 tok/s at 4K down to 7.97 at 24.5K, under the 8 tok/s floor |
| KV pick, short creep | 2026-09-04 | q8_0 vs f16, `-c 40960` | q8_0 6.3 tok/s, f16 45.9 tok/s at the same memory; f16 picked |
| full creep, f16 KV | 2026-09-04/05 | `-c 212992`, the largest `-c` that loads (229376 and 262144 OOM) | 17.30 tok/s at 196,618 used tokens, up from 7.97 at 24.5K on the old q8_0 pick |
| two-slot creep | 2026-09-05 | `-c 202752`, 2×101376, f16 KV | window-bound at 81958 tokens per slot, 33.56 tok/s there |
| real text, llama-benchy | 2026-09-12 | n-max 2, f16 KV | 60.1 tok/s at 4K, 28.2 at 98K, 19.1 at 197K; fastest arm of four drafter settings at every depth |
| projector loaded | 2026-09-11 | f16 KV, no drafter, `-c 204800`, `--ubatch-size 2048` | loads and serves one image request at 7894 filled prompt tokens; no drafter fits beside the projector at this `-c` |

The full curves are on
[the benchmarks page](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md).

## Log

- 2026-08-27 — EvalPlus harness stood up on this machine; blocks
  planned for this file were not started, the max_tokens flaw found on
  another model first. `hardware/kamaji/benchmarks/bench1/`.
- 2026-08-28 — MTP sweeps at thinking on and off, n-max 2 the peak
  both ways; context ramp at q8_0 KV finds the 8 tok/s floor at 24.5K.
  `hardware/kamaji/benchmarks/bench2/`.
- 2026-08-29 — First EvalPlus score, mlx_lm.server 4-bit at thinking
  on, budget 30000: base 0.713, plus 0.701, 46/164 (28%) empty, judged
  a real model convergence limit. `hardware/kamaji/benchmarks/bench3/`.
- 2026-08-30 — Parked: excluded from the run's queue with a reminder
  to the owner that it is still owed a full run.
  `hardware/kamaji/benchmarks/bench5/`.
- 2026-09-04/05 — Back in the running. The KV pick moves this file
  from q8_0 to f16: short creep reads 6.3 tok/s at q8_0 against 45.9
  at f16, same memory. The full creep at f16 finds 212992 the largest
  `-c` that loads and holds 17.30 tok/s at 196,618 used tokens.
  `hardware/kamaji/benchmarks/bench9/`.
- 2026-09-05 to 2026-09-06 — f16 EvalPlus re-score, both thinking
  modes: thinking on 0.884/0.860/89% with 18/164 empty at the 30000
  cap (down from the MLX build's 46/164), thinking off 0.976/0.945,
  no empty. The two-slot row's own creep hits a window verdict at
  81958 tokens per slot, not memory or speed. A Mendel smoke at
  thinking high passes; a coverage gap is found — no thinking-off
  Mendel row exists yet — and moved to a later run for a clean pass.
  `hardware/kamaji/benchmarks/bench10/`.
- 2026-09-06 to 2026-09-07 — The four-combination Mendel gap closes.
  Both thinking-off rows, blind and guided, end on the live loop stop,
  five identical edit calls, inside half an hour. The thinking-on
  guided row completes 7 of 8 libraries at 57, on its third attempt
  after two earlier tries were killed by memory pressure.
  `hardware/kamaji/benchmarks/bench11/`.
- 2026-09-07 to 2026-09-08 — Research run: without its drafter the
  file runs clean to 196618, the creep list's end, at 18.57 tok/s, and
  the projector costs memory only — it OOMs at the row's own `-c
  212992` and loads one step below it. The compaction ladder finds no
  floor for this model: both attempts end with the model believing the
  task done and no commit, compaction never firing.
  `hardware/kamaji/research/run3/`.
- 2026-09-11 — The projector loaded and served one image request at
  `-c 204800`, f16 KV, no drafter, `--ubatch-size 2048`; the default
  512 batch asserts on the image chunk. `llama-benchy` on the code
  corpus with the projector loaded: 53.11 tok/s at 4K, 19.24 at
  203776. `hardware/kamaji/benchmarks/bench16/`.
- 2026-09-12 — Real-text speed with llama-benchy across four drafter
  settings: n-max 2 wins at every depth, 60.1/28.2/19.1 tok/s at
  4K/98K/197K. `hardware/kamaji/benchmarks/bench16/`.
- 2026-09-15 to 2026-09-16 — Re-run of the 18 empty EvalPlus problems
  from the 2026-09-05 thinking-on score: 2 recover (`HumanEval/41`,
  `HumanEval/94`), 16 confirm the 30000-token cap as a real model
  limit. New score 0.896/0.872, 16/164 empty, about 2h wall.
  `hardware/kamaji/benchmarks/bench20/`.
- 2026-09-16 — Thinking-budget block, in progress. Calibration derives
  a 19491-token think budget, 2048-token answer budget, margin 1.5, 8
  of 10 problems converged. The budgeted EvalPlus run: base 0.988,
  plus 0.957, no empty, 16 of 164 forced to answer at the budget, 165.8
  minutes against the natural run's 347. The forced re-run of the two
  forced answers that still failed a test changes nothing:
  `HumanEval/141` fails naturally too on a short answer, `HumanEval/145`
  hits a 30000-token cap even with no budget; the 19491 budget stands,
  unchanged. Pending: the owner's word on how a budgeted score is shown
  beside the natural rows. `hardware/kamaji/benchmarks/bench22/`.
