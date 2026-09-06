# Local coding models on M1 Max 32 GB

Cross-model picks · llama-server (build 10621) + mlx-lm 0.31.3 · 2026-08-25, updated 2026-09-06

## Highlights

- **Best quality, and the first local model to finish the agent task:**
  Qwen3.8-27B. 0.982 / 0.939 / 100% on EvalPlus, and on llama-server at
  f16 KV the highest valid Mendel blind score of any local model, 87 of
  100 with all eight libraries. Send hard problems to the llama row.
- **Secondary-model pick, and the best big window:** Gemma-26B on
  llama-server at f16 KV. 60.3 tok/s at 4K and 17.3 at 197K, the largest
  context this machine loads for it; 0.976 / 0.945 / 100% on EvalPlus
  with thinking off; 47.5 of 100 on the Mendel blind task, complete.
- **Best depth:** Gemma-12B on llama-server with f16 KV and no drafter.
  24.64 tok/s at 4K and still 8.86 at 245K, so it reaches the model's own
  262,144 window above the floor, in 13.9 GB. The LM Studio engine is
  faster at every depth it survives (34.19 at 4K, 23.23 at 131K) but
  stops on memory, and it loops in multi-turn tool work.
- **Fastest shallow decode, with a caveat:** Qwen3.6-35B on llama. 68 py
  / 74 js tok/s and 0.951 / 0.915 / 100% with thinking off, but the slow
  creep shows memory compaction from 16K at the only `-c` that loads;
  the clean depth is 8K.
- **Best all-day agent:** Ternary Bonsai-27B. 27B-class quality from 8
  GB of weights, and the flattest curve of any model.
- **Best multi-agent:** Bonsai on the prism fork. 2×48K slots at 9.8
  tok/s each, in 10.0 GB. The only setup that leaves the machine free.
- **The rule that decides everything:** MLX runtimes barely slow down but
  hit hard memory ceilings. llama runtimes hold their speed deeper at f16
  KV, and their ceiling is the largest `-c` that loads; a published `-c`
  that OOMs at load is not a window.

## Models evaluated

<!-- gen:models-evaluated:start -->
| # | Config | Max ctx | Gated by¹ | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus² |
|--:|---|--:|:--:|--:|--:|--:|
| 1 | Qwen3.8-27B, GGUF, MTP f16, effort medium | 49k | mem | 20.0 → 15.0 | 23.5 GB | 0.982/0.939/100% |
| 2 | Qwen3.8-27B, MLX, compaction ~26k, effort medium | 28k | mem | 17 → 15.3 | 22.0 GB | 0.982/0.939/100% |
| 3 | Gemma-4-12B, GGUF, f16 KV, no drafter, thinking off | 245k | mem | 24.64 → 8.86 | 13.9 GB | 0.976/0.939/100% |
| 4 | Gemma-4-12B, GGUF, MTP f16, 4 slots, thinking off | 4x49k | mem | 42.9 → 27.7 | 25.1 GB | 0.976/0.939/100% |
| 5 | Qwen3.8-27B, MLX, effort low | 28k | mem | 17 → 15.3 | 22.0 GB | 0.976/0.927/100% |
| 6 | Gemma-4-12B, GGUF, MTP q8, thinking off | 16k | speed | 13.8 → 6.5 | 10.5 GB | 0.976/0.939/100% |
| 7 | Qwen3.6-35B-A3B, MLX, thinking on | 37k | mem | 53.3 → 42.0 | 18.7 GB | 0.939/0.921/97% |
| 8 | Qwen3.6-35B-A3B, GGUF, MTP q8, thinking on | 8k | mem | 36.4 → 43.8 | 25.0 GB | 0.939/0.921/97% |
| 9 | Ternary-Bonsai-27B, MLX, bounded cache, thinking off | 58k | mem | 24.5 → 17.3 | 22.5 GB | 0.927/0.902/100% |
| 10 | Ternary-Bonsai-27B, GGUF⁴, q4, 2 slots, thinking on | 2x48k | speed | 14.9 → 7.8 | 10.9 GB | 0.927/0.890/98% |
| 11 | Ternary-Bonsai-27B, GGUF⁴, q4, thinking on | 33k | speed | 14.8 → 7.9 | 9.6 GB | 0.927/0.890/98% |
| 12 | Ternary-Bonsai-27B, MLX, bounded cache, thinking on | 58k | mem | 24.5 → 17.3 | 22.5 GB | 0.915/0.884/97% |
| 13 | Gemma-4-12B, MLX³, thinking off | 131k | mem | 34.19 → 23.23 | 17.2 GB | 0.909/0.872/100% |
| 14 | Gemma-4-26B-A4B, GGUF, MTP f16 | 197k | mem | 60.3 → 17.3 | 25.6 GB | 0.884/0.860/89% |
| 15 | Gemma-4-26B-A4B, GGUF, MTP f16, 2 slots | 2x82k | mem | 66.6 → 33.6 | 25.3 GB | 0.884/0.860/89% |
| 16 | Gemma-4-26B-A4B, MLX | 70k | mem | 51 → 12.8 | 20.0 GB | 0.713/0.701/72% |
<!-- gen:models-evaluated:end -->

¹ Two values. **mem**: memory ended the curve, whether the server did
not load a larger context, died in flight, compacted or swapped, or the
model's own trained window arrived first; the row note says which.
**speed**: decode fell under the 8 tok/s floor while memory still had
room.
"tok/s (shallow → deep)" is that same decode speed, near an empty context
then at max ctx.

² Scored once per model and thinking mode; runtimes serving the same
model at a standard quant share the score, until a measurement says
otherwise: Gemma-4-12B's GGUF Q4_K_XL scored 0.067 above its LM Studio
MLX 4-bit, and Gemma-4-26B-A4B's GGUF UD-Q4_K_XL at f16 KV scored 0.171
above its MLX 4-bit, so those pairs carry their own. Aggressive quants
(for example the prism fork's calibrated q4 KV) never share; they pass
the gate separately.

³ LM Studio's MLX engine, the only runtime that loads this model's
`gemma4_unified` architecture. Its context auto-fit cannot be overridden;
see the floor table below.

⁴ PrismML's llama.cpp fork, an approved exception to the no-forks rule.

All ceilings below are slow-creep re-tests at wired limit 24000.
See [the measurement rules](../../methodology/context-creep) for why the
slow creep is more realistic than a fast sweep.

"Memory (at max ctx)" is the wired GPU memory the config holds at max ctx.

Server commands live in each model's report; aliases equal the pi model ids.
Compaction thresholds come from the floor table below, not from the window.

## Per-model reports

- [Qwen3.8-27B](./reports/qwen3.8-27b.md): strongest base model,
  slowest on this hardware; on llama f16 it finishes the agent task
  (87 blind)
- [Gemma-4-26B-A4B](./reports/gemma-4-26b-a4b.md): MoE+MTP, fastest
  Python, 197K at f16 KV on one slot, 47.5 blind on the agent task
- [Qwen3.6-35B-A3B](./reports/qwen3.6-35b-a3b.md): MoE+MTP, fastest JS,
  strongest base benchmarks; 8K clean depth at the `-c` that loads
- [Gemma-4-12B-it](./reports/gemma-4-12b-it.md): biggest context, best
  concurrency
- [Ternary Bonsai-27B](./reports/bonsai-27b.md): 27B-class from 8 GB;
  two serving profiles (MLX speed / prism-fork desktop), 2 concurrent
  slots on the fork

## Decode speed vs used context — the 8 tok/s usability floor

Measured at wired limit 24000, slow creeps. MLX rows 2026-08-29; the
llama f16 rows 2026-09-04 and 2026-09-05; the two speed-floored llama
rows keep the fast sweep of 2026-08-28.

| model / runtime | tok/s @ 4K | @ 16K | @ 32-33K | @ 49K | @ 74-90K | capped by | EvalPlus (base/plus/completion) |
|---|--:|--:|--:|--:|--:|---|--:|
| **Gemma-26B llama (f16, MTP, `-c 212992`)** | 60.3 | 56.5 | 45.9 | 45.9 | 26.4 (115K), 17.3 (197K) | mem — 212992 is the largest `-c` that loads; 17.3 tok/s at 197K | 0.976/0.945/100% off, 0.884/0.860/89% on |
| **Gemma-26B MLX** | 51.1 | 43.5 | 35.6 | 28.8 | 12.8 (70K) | mem — stable to 70K, 12.8 tok/s there | 0.713/0.701/72% |
| **Qwen3.6-35B MLX** | 53.3 | 49.6 | 42.2 | | | mem — stable to 37K, 42.0 tok/s there | pending |
| Qwen3.6-35B llama (q8, MTP, `-c 49152`) | 36.4 | 31.0 | 19.6 | | | mem — compaction from 16K at 25 GB wired; last clean row 8K, 43.8 tok/s | 0.951/0.915/100% off, 0.939/0.921/97% on |
| Bonsai MLX (f16 KV) | 24.5 | 22.9 | 20.5 | 18.8 | 17.3 (58K) | mem — stable to 58K, 17.3 tok/s there | 0.915/0.884/97% |
| **Qwen3.8 llama (f16, MTP, `-c 49152`)** | 20.0 | 16.0 | 16.4 | 15.0 | | mem — 49152 is the largest `-c` that loads; 15.0 tok/s at 49K | 0.982/0.939/100% (MLX score) |
| Qwen3.8 MLX | 17.1* | 16.4 | | | 15.3 (28K) | mem — stable to 28K, 15.3 tok/s there | 0.982/0.939/100% |
| Bonsai prism fork (q4 KV) | 14.9 | 10.8 | 7.9 | | 7.9 (32K) | speed — under 8 tok/s at 32K, single slot deep, other slot idle-loaded | 0.927/0.890/98% |
| Gemma-12B llama (q8, MTP) | 13.8 | 6.5 | | | | speed — under 8 tok/s at 16K | 0.976/0.939/100% |
| **Gemma-12B llama (f16, no drafter)** | 24.6 | 22.7 | 20.6 | 18.8 | 8.86 (245K) | mem — 8.86 tok/s at 245K, where the trained window ends² | 0.976/0.939/100% |
| **Gemma-12B MLX (LM Studio engine, CLI)** | 34.2 | 32.1 | 30.6 | | 23.2 (131K) | mem — last stable 131K, 23.23 tok/s there² | 0.909/0.872/100% |

Cells are blank past a config's cap, or where no step was measured at that depth.

\*8K value.

² Both Gemma-12B curves were measured 2026-09-04, thinking off. The
llama f16 curve ends where the model's trained window ends, with wired
memory flat at 13.9 GB. The LM Studio curve ends on memory: past its
last stable step the engine grows into the wired cap and swap starts.
Context length cannot be pinned on the LM Studio path; the loader
auto-fits it.

## Code quality — EvalPlus HumanEval+

| model | config scored | pass@1 base | pass@1 plus | completion | status |
|---|---|--:|--:|--:|---|
| **Qwen3.8-27B** | mlx 4-bit, reasoning_effort=medium, budget 8192 | **0.982** | **0.939** | 100% | 0 empty; the GGUF quant's own score is pending |
| **Gemma-4-26B-A4B** | GGUF UD-Q4_K_XL llama f16, thinking off, budget 8192 | **0.976** | **0.945** | 100% | 0 empty, 19 minutes |
| Gemma-4-26B-A4B | GGUF UD-Q4_K_XL llama f16, thinking on, budget 30000 | 0.884 | 0.860 | 89% | 18/164 empty, thinking non-convergence |
| Gemma-4-26B-A4B | mlx 4-bit, thinking on, budget 30000 | 0.713 | 0.701 | 72% | 46/164 empty, the convergence problem at its worst |
| **Gemma-4-12B** | GGUF Q4_K_XL llama f16, thinking off, budget 8192 | **0.976** | **0.939** | 100% | 0 empty |
| Gemma-4-12B | LM Studio MLX 4-bit, thinking off, budget 30000 | 0.909 | 0.872 | 100% | 0 empty; 0.067 under the GGUF quant, so the two do not share a score |
| **Qwen3.6-35B-A3B (MoE)** | llama+MTP q8_0 KV, thinking off, budget 8192 | **0.951** | 0.915 | 100% | 0 empty, 15 minutes |
| Qwen3.6-35B-A3B (MoE) | llama+MTP, thinking on, budget 26624 | 0.939 | **0.921** | 97% | 5/164 empty is a real model ceiling |
| **Ternary Bonsai-27B** | mlx 2-bit, thinking on, budget 10240 | **0.915** | **0.884** | 97% | 5/164 empty is a real model ceiling |

## Mendel — agentic quality (issue-13 bake-off)

Two independent tests of the same task (rubric unchanged, everything
else different; never compare a score across them): **blind** (terse
prompt, the model must find the traps itself) and **guided** (numbered
workflow, traps disclosed, tests instruction-following instead of trap
discovery). Full rubric, scoring method, and the rest of the field
(proprietary and other local models) live in the open-source
[Mendel benchmark](https://github.com/irae/mendel/tree/benchmark).

Current rows use blind prompt v1.1 and guided v3.0, run from fresh
base tags with the tap crash fix. Rows from older prompt versions
moved to [historical](./historical.md); never compare across prompt
versions.

Scores wear a completion cap: a score cannot exceed the fraction of
the task that got done (`min(raw, 100 × done/8)`). A partial run that
the model itself spoiled can run again, but the new row loses 10
points for each earlier valid attempt. When our own harness caused the
stop, the corrected re-run carries no penalty. Runs where a serving
failure prevented any real work are invalid and not listed here; the
hosted reports show them dimmed, with reasons.

| model | test | config scored | score | status |
|---|---|---|--:|---|
| Qwen3.8-27B | blind | llama-server f16 KV `-c 49152`, effort medium, `pi` harness | **87/100** | complete, all 8 libraries; no bug defect |
| Qwen3.6-35B-A3B | guided | llama-server, thinking high, `pi` harness | **83/100** | complete, all 8 libraries |
| Qwen3.6-35B-A3B | blind | llama-server, thinking high, `pi` harness | **63/100** | complete, all 8 libraries; one critical runtime defect (trap A) |
| Gemma-4-26B-A4B | blind | llama-server f16 KV `-c 212992`, thinking high, `pi` harness | **47.5/100** | complete, all 8 libraries; one critical runtime defect (trap A) |
| Gemma-4-12B | guided | llama-server f16 KV, no drafter, thinking off, `pi` harness | **37.5/100** | partial, 3/8 libraries; model budget exhausted after three nudges |
| Ternary Bonsai-27B | blind | mlx 2-bit, thinking high, `pi` harness | **37.5/100** (raw 55) | partial, 300-min wall clock at 3/8 libraries |
| Qwen3.8-27B | blind | mlx 4-bit, effort low, `pi` harness | **12.5/100** (raw 67.5) | partial, 1/8; the 26624-token window plus a 16384-token output budget forced premature stops (our config arithmetic, not the model) |
| Ternary Bonsai-27B | guided | mlx 2-bit, thinking high, `pi` harness | **12.5/100** (raw 59) | partial, 300-min wall clock at 1/8 libraries |
| Ternary Bonsai-27B | blind | PrismML GGUF fork, thinking high, `pi` harness | **12.5/100** (raw 60.5) | 1/8 libraries; typoed the repo path, self-scoped to chalk; a penalized retry is pending |

Invalid, not scored as model quality: three Gemma-4-12B runs on the
retired LM Studio entry (thinking on, repetition loop, zero commits);
the Qwen3.8-27B MLX guided runs (Metal OOM crashes past the 26624-token
window, zero commits); two Bonsai MLX guided runs at thinking off (a
dead `gh` token, then an 85-call identical-command loop).

Full tables for both Mendel tests are on the
[Mendel page](./benchmarks/mendel.md), and the complete reports are
hosted here: <a href="../../mendel/report.html" target="_blank" rel="noreferrer">blind</a> ·
<a href="../../mendel/report-guided.html" target="_blank" rel="noreferrer">guided</a>.

**The window decides the agent task on dense Qwen3.8.** The task needs
about 46K of context. The GGUF at f16 KV holds 49K and finished it at
87; the MLX build holds 26K, kept stopping at 1 output token as the
prompt neared its window, and its guided runs hit the Metal OOM
dead-thread trap three times. Its scores above carry that caveat.

**Gemma-26B finished the task at thinking high; thinking off is
pending.** It touched all eight libraries and lost most of its points to
one critical trap and leftover calls. Its earlier blind row at q8_0 KV
scored 38, partial, on the previous prompt version.

**Gemma-12B on llama-server ran out of budget, not of ability.** Three
of eight libraries in the guided run, then the model budget after three
nudges, the same signature as its retired LM Studio entry. The three
LM Studio rows measure a serving failure, not the model's coding: the
entry always thinks, fell into a repetition loop after its first failed
edit in every run, and committed nothing. The evidence is on
[the Gemma-12B data page](./benchmarks/gemma-4-12b-it.md#the-retired-entry).

**Both Bonsai mlx rows ran at thinking high, not the requested low.**
The runner asked for low, but the session logs record high; the flag
was not honored on `mlx_lm.server`. The rows are scored and labeled at
the observed level. Bonsai's blind run finished 3 of 8 libraries and
lost about 40 minutes to one JSON syntax break of its own making; it
ended on the 300-minute wall clock, not on the rubric.

## Open questions

- Mendel at thinking off for Gemma-26B (guided and blind) and guided at
  thinking on; the Qwen3.8 GGUF quant's own EvalPlus score; a
  thinking-on score for Gemma-12B.
- A Bonsai guided row at thinking off. Two attempts went invalid on
  the harness; the third waits on a live loop alarm in the runner.
- The Bonsai prism-fork q4 pick, and the corpus behind its KV bias file.
- Aider polyglot (tier 2) for gate survivors, driven from another
  computer; docker does not fit beside a loaded model here.
- **Qwen3-Coder-30B-A3B is the only promising untested contender.** Not on
  this machine yet. Community-reported EvalPlus HumanEval+ 0.902 (unverified
  by our gate); MoE, 3.3B active, GGUF Q4_K_M ~18.6 GB. Math projects its
  GGUF single-slot ceiling above 45K, but its 2-slot ceiling lands close to
  our 45K bar either way; likely below our best score. Worth a real test
  before ruling it out, low priority otherwise.
- Watch list: brew llama.cpp reading ternary Q2; mlx-lm gaining
  `gemma4_unified` and server-side KV quantization; LM Studio's MLX
  continuous batching (mlx-engine, general since 0.4.2, confirmed here at
  0.4.21) as the only path to real multi-slot MLX serving. Plain
  `mlx_lm.server` has no shared-weight multi-slot mode, so MLX 2-slot
  math does not apply to it the way GGUF's does.

## History and reasoning

**Why the depth axis exists at all.** Decode speed falls as the KV cache
fills. A real coding session measured 1.7 tok/s at 135K used tokens, on a
config whose near-empty benchmark said 62. Context maxima alone are storage,
not speed. So each model is swept with an append-only growing prompt, which
gives perfect cache reuse, until decode drops under the 8 tok/s floor or the
server runs out of memory. The floor, not the window, is where the harness
compaction threshold belongs.

**How to read the numbers.** Sweep prompts are synthetic code continuations,
so MTP-model numbers read below the standard py/js bench, because draft
acceptance differs. The curves stay comparable across rows. Scores are
HumanEval+ pass@1, one score per model and thinking mode (footnote ²
above).

**Quality scores need a calibrated output budget.** A fixed budget that is
too small lets reasoning exhaust the cap, and empty completions score as
failures, a harness flaw, not a model flaw. Budgets here are calibrated per
model from measured reasoning length. Superseded scores from an
uncalibrated budget live on [the historical page](./historical.md), never
here.

**The Gemma models have a real convergence problem with thinking on.**
Their thinking mode sometimes fails to converge at all, 30K tokens of
reasoning with no answer. That is model behavior, not a harness limit;
the 26B does it on 11% of the problems on the GGUF and 28% on the MLX
build, and thinking off removes it.

Superseded measurements live in
[the historical page](./historical.md). Nothing on this page
was measured under a retired wired limit. The flow is in the
[methodology](../../methodology.md).

---

Method: warmup before measurements; identical prompts across models;
temperature 0. Per-model raw numbers in the benchmarks pages.
