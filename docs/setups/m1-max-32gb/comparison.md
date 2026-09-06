# Local coding models on M1 Max 32 GB

Cross-model picks · llama-server (build 10621) + mlx-lm 0.31.3 · 2026-08-25

## Highlights

- **Best quality, and the first local model to finish the agent task:**
  Qwen3.8-27B — 0.982 / 0.939 EvalPlus on MLX, and on llama-server at
  f16 KV the highest valid Mendel blind score of any local model, 87 of
  100 with all eight libraries (run 10). Send hard problems to the llama
  row.
- **Best depth:** Gemma-12B on llama-server with f16 KV and no drafter —
  24.64 tok/s at 4K and still 8.86 at 245K, so it reaches the model's own
  262,144 window above the floor, in 13.9 GB. The LM Studio engine is
  faster at every depth it survives (34.19 at 4K, 23.23 at 131K) but stops
  on memory, and it loops in multi-turn tool work.
- **Best speed with depth:** Gemma-26B on MLX — 51 tok/s at 4K, still 12.8 at
  70K (ceiling), in 20.0 GB.
- **Best big window, and the secondary-model pick:** Gemma-26B on
  llama-server with f16 KV — 60.3 tok/s at 4K and 17.3 at 197K, the
  largest context this machine loads for it (run 9), and 0.884 / 0.860
  on EvalPlus with thinking on (run 10), far above its MLX build.
- **Best all-round config, with a caveat:** Qwen3.6-35B on llama — the
  fastest shallow decode and 0.939 / 0.921, but the slow creep of run 9
  shows memory compaction from 16K at the only `-c` that loads; the
  clean depth is 8K.
- **Best all-day agent:** Ternary Bonsai-27B — 27B-class quality from 8 GB of
  weights, and the flattest curve of any model.
- **Best multi-agent:** Bonsai on the prism fork — 2×48K slots at 9.8 tok/s
  each, in 10.0 GB. The only setup that leaves the machine free.
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
MLX 4-bit (run 9), and Gemma-4-26B-A4B's GGUF UD-Q4_K_XL at f16 KV
scored 0.171 above its MLX 4-bit (run 10), so those pairs carry their
own. Aggressive quants (for
example the prism fork's calibrated q4 KV) never share; they pass the
gate separately.

³ LM Studio's MLX engine — the only runtime that loads this model's
`gemma4_unified` architecture. Its context auto-fit cannot be overridden;
see the floor table below.

⁴ PrismML's llama.cpp fork, an approved exception to the no-forks rule.

All ceilings below are slow-creep re-tests at wired limit 24000 (2026-08-29).
See [the measurement rules](../../methodology/context-creep) for why the
slow creep is more realistic than a fast sweep.

"Memory (at max ctx)" is the wired GPU memory the config holds at max ctx.

Server commands live in each model's report; aliases equal the pi model ids.
Compaction thresholds come from the floor table below, not from the window.

## Per-model reports

- [Gemma-4-26B-A4B](./reports/gemma-4-26b-a4b.md) —
  MoE+MTP: fastest Python, 197K at f16 KV on one slot
- [Qwen3.6-35B-A3B](./reports/qwen3.6-35b-a3b.md) —
  MoE+MTP: fastest JS, strongest base benchmarks; 49K is the context
  that loads at the current wired limit
- [Gemma-4-12B-it](./reports/gemma-4-12b-it.md) —
  biggest context, best concurrency
- [Ternary Bonsai-27B](./reports/bonsai-27b.md) —
  27B-class from 8 GB; two serving profiles (MLX speed / prism-fork
  desktop), 2 concurrent slots on the fork
- [Qwen3.8-27B](./reports/qwen3.8-27b.md) — strongest
  base model, slowest on this hardware; on llama f16 it finishes the
  agent task (87 blind, run 10)

## Decode speed vs used context — the 8 tok/s usability floor

Measured at wired limit 24000. All MLX ceiling rows (Gemma-26B, Qwen3.6-35B,
Bonsai, Qwen3.8) are slow-creep re-tests (2026-08-29); the three Gemma-12B rows
are slow-creep sweeps of 2026-09-03 and 2026-09-04; the remaining llama rows
are speed-floored, not memory-gated, so the fast 2026-08-28 sweep still
applies.

| model / runtime | tok/s @ 4K | @ 16K | @ 32-33K | @ 49K | @ 74-90K | capped by | EvalPlus (base/plus) |
|---|--:|--:|--:|--:|--:|---|--:|
| **Gemma-26B MLX** | 51.1 | 43.5 | 35.6 | 28.8 | 12.8 (70K) | mem — stable to 70K, 12.8 tok/s there | 0.713/0.701 |
| **Qwen3.6-35B MLX** | 53.3 | 49.6 | 42.2 | | | mem — stable to 37K, 42.0 tok/s there | pending |
| Qwen3.6-35B llama (q8, MTP, `-c 49152`) | 36.4 | 31.0 | 19.6 | | | mem — compaction from 16K at 25 GB wired; last clean row 8K, 43.8 tok/s (run 9) | 0.939/0.921 |
| Bonsai MLX (f16 KV) | 24.5 | 22.9 | 20.5 | 18.8 | 17.3 (58K) | mem — stable to 58K, 17.3 tok/s there | 0.915/0.884 |
| Qwen3.8 MLX | 17.1* | 16.4 | | | 15.3 (28K) | mem — stable to 28K, 15.3 tok/s there | 0.982/0.939 |
| **Gemma-26B llama (f16, MTP, `-c 212992`)** | 60.3 | 56.5 | 45.9 | 45.9 | 26.4 (115K), 17.3 (197K) | mem — 212992 is the largest `-c` that loads; 17.3 tok/s at 197K (run 9) | 0.884/0.860 |
| Bonsai prism fork (q4 KV) | 14.9 | 10.8 | 7.9 | | 7.9 (32K) | speed — under 8 tok/s at 32K, single slot deep, other slot idle-loaded | 0.927/0.890 |
| **Qwen3.8 llama (f16, MTP, `-c 49152`)** | 20.0 | 16.0 | 16.4 | 15.0 | | mem — 49152 is the largest `-c` that loads; 15.0 tok/s at 49K (run 9) | 0.982/0.939 (MLX score) |
| Gemma-12B llama (q8, MTP) | 13.8 | 6.5 | | | | speed — under 8 tok/s at 16K | 0.976/0.939 |
| **Gemma-12B llama (f16, no drafter)** | 24.6 | 22.7 | 20.6 | 18.8 | 8.86 (245K) | mem — 8.86 tok/s at 245K, where the trained window ends² | 0.976/0.939 |
| **Gemma-12B MLX (LM Studio engine, CLI)** | 34.2 | 32.1 | 30.6 | | 23.2 (131K) | mem — last stable 131K, 23.23 tok/s there² | 0.909/0.872 |

Cells are blank past a config's cap, or where no step was measured at that depth.

\*8K value.

² Both Gemma-12B curves were measured 2026-09-04, thinking off. The
llama f16 curve ends where the model's trained window ends, with wired
memory flat at 13.9 GB. The LM Studio curve ends on memory: past its
last stable step the engine grows into the wired cap and swap starts.
Context length cannot be pinned on the LM Studio path; the loader
auto-fits it.

## Code quality — EvalPlus HumanEval+

| model | config scored | pass@1 base | pass@1 plus | status |
|---|---|--:|--:|---|
| **Qwen3.8-27B** | mlx 4-bit, reasoning_effort=medium, budget 8192 | **0.982** | **0.939** | 0 empty |
| **Ternary Bonsai-27B** | mlx 2-bit, thinking on, budget 10240 | **0.915** | **0.884** | 5/164 empty is a real model ceiling |
| **Qwen3.6-35B-A3B (MoE)** | llama+MTP, thinking on, budget 26624 | **0.939** | **0.921** | 5/164 empty is a real model ceiling; thinking off reads 0.951 / 0.915 with 0 empty (run 10) |
| **Gemma-4-26B-A4B** | GGUF UD-Q4_K_XL llama f16, thinking off, budget 8192 | **0.976** | **0.945** | 0 empty, 19 minutes (run 10); thinking on reads 0.884 / 0.860 with 18 empty |
| Gemma-4-26B-A4B | mlx 4-bit, thinking on, budget 30000 | 0.713 | 0.701 | 46/164 (~28%) empty, the thinking-convergence problem at its worst |
| **Gemma-4-12B** | GGUF Q4_K_XL llama f16, thinking off, budget 8192 | **0.976** | **0.939** | 0 empty (run 9) |
| Gemma-4-12B | LM Studio MLX 4-bit, thinking off, budget 30000 | 0.909 | 0.872 | 0 empty; 0.067 under the GGUF quant, so the two do not share a score |

## Mendel — agentic quality (issue-13 bake-off)

Two independent tests of the same task (rubric unchanged, everything
else different — never compare a score across them): **blind** (terse
prompt, model must find the traps itself) and **guided** (numbered
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
points for each earlier valid attempt — the Bonsai-27B PrismML blind
row below will score that way after its retry. When our own harness
caused the stop, as the 16384-token output budget inside a 26624-token
window did to the Qwen3.8-27B blind row, the corrected re-run carries
no penalty. Runs where a
serving failure prevented any real work are invalid and not listed
here; the hosted reports show them dimmed, with reasons.

| model | test | config scored | score | status |
|---|---|---|--:|---|
| Qwen3.6-35B-A3B | guided | llama-server, thinking high, `pi` harness | **83/100** | complete — all 8 libraries |
| Qwen3.6-35B-A3B | blind | llama-server, thinking high, `pi` harness | **63/100** | complete — all 8 libraries; one critical runtime defect (trap A) |
| Ternary Bonsai-27B | blind | mlx 2-bit, thinking high, `pi` harness | **37.5/100** (raw 55) | partial — 300-min wall clock at 3/8 libraries, `rimraf` partial |
| Qwen3.8-27B | blind | mlx 4-bit, effort low, `pi` harness | **12.5/100** (raw 67.5) | partial — tooling-nudge budget hit at 1/8 libraries; the harness entry's 26624-token window plus a 16384-token output budget forced repeated premature stops (our config arithmetic, not the model) |
| Ternary Bonsai-27B | guided | mlx 2-bit, thinking high, `pi` harness | **12.5/100** (raw 59) | partial — 300-min wall clock at 1/8 libraries |
| Ternary Bonsai-27B | blind | PrismML GGUF fork, thinking high, `pi` harness | **12.5/100** (raw 60.5) | 1/8 libraries — typoed the repo path, self-scoped to chalk; a penalized retry is pending |

Invalid, not scored as model quality: three Gemma-4-12B runs (the
retired LM Studio entry `google/gemma-4-12b`, thinking on, pre-fix chat
template, repetition loop, zero commits) and the Qwen3.8-27B guided run
(three Metal OOM server crashes, zero commits).

Full tables for both Mendel tests are on the
[Mendel page](./benchmarks/mendel.md), and the complete reports are
hosted here: <a href="../../mendel/report.html" target="_blank" rel="noreferrer">blind</a> ·
<a href="../../mendel/report-guided.html" target="_blank" rel="noreferrer">guided</a>. The rubric and raw data live
in the open-source
[Mendel benchmark](https://github.com/irae/mendel/tree/benchmark).

**The `mlx_lm.server` `qwen3_coder` tool-parser crash no longer blocks
scoring.** The crash still fired on Bonsai (per-request
JSONDecodeError on malformed tool-call arguments), but the server
stayed up, the runner's unscored tooling nudges resumed the session,
and the run reached the wall clock with a scored row. Earlier attempts
died on it; those rows are in [historical](./historical.md).

**The recurring limit for Qwen3.8-27B on `mlx_lm.server` is the serving
window, not the model.** The blind low run kept stopping at 1 output
token once the prompt neared the mlx entry's fixed 26624-token window
(unverifiable on `mlx_lm.server`), and burned the tooling-nudge budget.
The guided low run grew past the same window and the server hit the
Metal OOM dead-thread trap three times. Verify or raise the window
before the next mlx run; the scores above carry that caveat.

**Finding, unrelated to scoring: Qwen3.6-35B-A3B's MTP drafter is
currently broken on this brew build.** `--spec-type draft-mtp
--spec-draft-n-max 3` fails to allocate and leaves the whole
llama-server backend in a broken state (every completion after that
returns HTTP 500, even though `/health` still reports ready) —
reproduced at both `-c 98304` and `-c 65536` with the GPU idle
beforehand. The Qwen3.6 Mendel runs use the same command without the
drafter flags, which loads and generates normally. The site's own
`14.1/8.6 tok/s` decode figures for this config need a re-check against
the current brew build before the next depth sweep.

**The three Gemma-12B rows measure a serving failure, not the model's
coding.** All three ran the retired LM Studio entry, which always
thinks: the model fell into a repetition loop after its first failed
edit in every run and landed zero commits. Read the ~30 scores as "this
serving combination cannot run the task", not as Gemma's agentic
quality. On llama-server with thinking off the same short task produced
42 tool calls and a working commit; a scored GGUF run is pending. The
evidence is on
[the Gemma-12B data page](./benchmarks/gemma-4-12b-it.md#the-retired-entry).

**Both Bonsai mlx rows ran at thinking high, not the requested low.**
The runner asked for low, but the session logs record high — the flag
was not honored on `mlx_lm.server`. The rows are scored and labeled at
the observed level.

**Bonsai's blind run lost most of its clock to self-inflicted
breakage.** It finished 3 of 8 libraries (uuid, xtend, urlsafe-base64)
and part of `rimraf`, but one JSON syntax break it made in
`mendel-transform-less/package.json` cost four commit attempts (~40
minutes) before it fixed the file itself, and it missed the
`legacy-packages/mendel-requirify` `rimraf` reference. The run ended
on the 300-minute wall clock, not on the rubric.

## Open questions

- EvalPlus for the Gemma-12B GGUF quant, a thinking-on score for it,
  and a Mendel run on llama-server. The Bonsai prism-fork q4 pick and a
  Bonsai thinking-off pass.
- Memory ceilings for the MLX configs that never hit the speed floor.
- Aider polyglot (tier 2) for gate survivors — driven from another computer;
  docker does not fit beside a loaded model here.
- **Qwen3-Coder-30B-A3B is the only promising untested contender.** Not on
  this machine yet. Community-reported EvalPlus HumanEval+ 0.902 (unverified
  by our gate); MoE, 3.3B active, GGUF Q4_K_M ~18.6 GB. Math projects its
  GGUF single-slot ceiling above 45K, but its 2-slot ceiling lands close to
  our 45K bar either way — not a clear win, and likely below our best
  score. Worth a real test before ruling it out, low priority otherwise.
- Watch list: brew llama.cpp reading ternary Q2; mlx-lm gaining
  `gemma4_unified` and server-side KV quantization; LM Studio's MLX
  continuous batching (mlx-engine, general since 0.4.2 — confirmed here at
  0.4.21) as the only path to real multi-slot MLX serving. Plain
  `mlx_lm.server` has no shared-weight multi-slot mode — concurrent MLX
  decode needs a second full weight copy, so MLX 2-slot math does not
  apply to it the way GGUF's does.

## History and reasoning

**Why the depth axis exists at all.** Decode speed falls as the KV cache
*fills*. A real coding session measured 1.7 tok/s at 135K used tokens, on a
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
failures — a harness flaw, not a model flaw. Budgets here are calibrated per
model from measured reasoning length. Superseded scores from an
uncalibrated budget live on [the historical page](./historical.md), never
here.

**The Gemma models have a real convergence problem.** Their thinking mode
sometimes fails to converge at all — 30K tokens of reasoning with no answer.
That is model behavior, not a harness limit, and the 12B does it more often
than the 26B.

Superseded measurements live in
[the historical page](./historical.md). Nothing on this page
was measured under a retired wired limit. The flow is in the
[methodology](../../methodology.md).

---

Method: warmup before measurements; identical prompts across models;
temperature 0. Per-model raw numbers in the benchmarks pages.
