# Local coding models on M1 Max 32 GB

Cross-model picks · llama-server (build 10621) + mlx-lm 0.31.3 · 2026-08-25

## Highlights

- **Best quality:** Qwen3.8-27B on MLX — 0.982 / 0.939 EvalPlus. Send hard
  problems here.
- **Best depth:** Gemma-12B on the LM Studio engine — 29.7 tok/s at 169.6K used
  tokens, in 8.8 GB. LM Studio's own MLX loader caps it at 170K (a known
  LM Studio bug, not a memory or speed limit of the model).
- **Best speed with depth:** Gemma-26B on MLX — 51 tok/s at 4K, still 12.8 at
  70K (ceiling), in 20.0 GB.
- **Best big window, and the best all-round config:** Qwen3.6-35B on llama —
  never crosses the 8 tok/s floor inside its whole 96K window, and now scores
  0.939 / 0.921.
- **Best all-day agent:** Ternary Bonsai-27B — 27B-class quality from 8 GB of
  weights, and the flattest curve of any model.
- **Best multi-agent:** Bonsai on the prism fork — 2×48K slots at 9.8 tok/s
  each, in 10.0 GB. The only setup that leaves the machine free.
- **The law that decides everything:** MLX runtimes barely slow down but hit
  hard memory ceilings. llama runtimes slow down faster but never OOM inside
  their window.

## Models evaluated

<!-- gen:models-evaluated:start -->
| Config | Max ctx | Gated by¹ | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus² |
|---|--:|:--:|--:|--:|--:|
| Qwen3.8-27B, MLX, compaction ~26k, effort medium | 28k | mem | 17 → 15.3 | 22.0 GB | 0.982/0.939 |
| Qwen3.8-27B, GGUF, MTP q8, effort medium | 19k | speed | 14.1 → 8 | 18.9 GB | 0.982/0.939 |
| Qwen3.6-35B-A3B, GGUF, MTP q8, thinking on | 90k | speed | 44 → 8.1 | 22.8 GB | 0.939/0.921 |
| Qwen3.6-35B-A3B, MLX, thinking on | 34.9k | mem | 53.3 → 41.5 | 22.1 GB | 0.939/0.921 |
| Ternary-Bonsai-27B, MLX, bounded cache, thinking on | 58k | mem | 24.5 → 17.3 | 22.5 GB | 0.915/0.884 |
| Gemma-4-12B, MLX³, thinking off | 170k | engine | 37 → 31 | 8.8 GB | 0.909/0.872 |
| Gemma-4-12B, GGUF, MTP q8, thinking off | 11k | speed | 14.0 → 8 | 8.2 GB | 0.909/0.872 |
| Gemma-4-26B-A4B, MLX | 70k | mem | 51 → 12.8 | 20.0 GB | 0.713/0.701 |
| Gemma-4-26B-A4B, GGUF, MTP q8 | 24k | speed | 23.5 → 8 | 15.4 GB | 0.713/0.701 |
| Gemma-4-12B, MLX³ | 170k | engine | 37 → 31 | 8.8 GB | pending |
| Ternary-Bonsai-27B, GGUF⁴, q4, thinking on | 2x48k | speed | 14.9 → 7.9 | 10.0 GB | pending |
<!-- gen:models-evaluated:end -->

¹ Whichever limit hits first: the max memory a config fits in, or the max
context that stays usable — usable meaning at or above the 8 tok/s floor.
"tok/s (shallow → deep)" is that same decode speed, near an empty context
then at max ctx.

² Scored once per model and thinking mode; runtimes serving the same
model at a standard quant share the score. Aggressive quants (for
example the prism fork's calibrated q4 KV) do not share — they pass the
gate separately.

³ LM Studio's MLX engine — the only runtime that loads this model's
`gemma4_unified` architecture. Its context auto-fit cannot be overridden;
see the floor table below.

⁴ PrismML's llama.cpp fork, an approved exception to the no-forks rule.

All ceilings below are slow-creep re-tests at wired limit 24000 (2026-08-29).
See [the measurement rules](../../methodology#measurement-rules) for why the
slow creep is more realistic than a fast sweep.

"Memory (at max ctx)" is the wired GPU memory the config holds at max ctx.

Server commands live in each model's report; aliases equal the pi model ids.
Compaction thresholds come from the floor table below, not from the window.

## Per-model reports

- [Gemma-4-26B-A4B](./reports/gemma-4-26b-a4b.md) —
  MoE+MTP: fastest Python, full 256K window (q8 KV), 2×184K slots
- [Qwen3.6-35B-A3B](./reports/qwen3.6-35b-a3b.md) —
  MoE+MTP: fastest JS, strongest base benchmarks; 96K context at the current
  wired limit
- [Gemma-4-12B-it](./reports/gemma-4-12b-it.md) —
  biggest context, best concurrency
- [Ternary Bonsai-27B](./reports/bonsai-27b.md) —
  27B-class from 8 GB; two serving profiles (MLX speed / prism-fork
  desktop), 2 concurrent slots on the fork
- [Qwen3.8-27B](./reports/qwen3.8-27b.md) — strongest
  base model, slowest on this hardware

## Decode speed vs used context — the 8 tok/s usability floor

Measured at wired limit 24000. All MLX ceiling rows (Gemma-26B, Qwen3.6-35B,
Bonsai, Qwen3.8) are slow-creep re-tests (2026-08-29); llama rows are
speed-floored, not memory-gated, so the fast 2026-08-28 sweep still applies.

| model / runtime | tok/s @ 4K | @ 16K | @ 32-33K | @ 49K | @ 74-90K | capped by | EvalPlus (base/plus) |
|---|--:|--:|--:|--:|--:|---|--:|
| **Gemma-26B MLX** | 51.1 | 43.5 | 35.6 | 28.8 | 12.8 (70K) | mem — stable to 70K, 12.8 tok/s there | 0.713/0.701 |
| **Qwen3.6-35B MLX** | 53.3 | 49.6 | 42.2 | | | mem — stable to 34.9K, 41.5 tok/s there | pending |
| **Qwen3.6-35B llama (q8, MTP)** | 44.5 | 30.1 | 18.8 | 13.5 | 8.1 (90K) | speed — its 96K window ends at 8.1 tok/s | 0.939/0.921 |
| Bonsai MLX (f16 KV) | 24.5 | 22.9 | 20.5 | 18.8 | 17.3 (58K) | mem — stable to 58K, 17.3 tok/s there | 0.915/0.884 |
| Qwen3.8 MLX | 17.1* | 16.4 | | | 15.3 (28K) | mem — stable to 28K, 15.3 tok/s there | 0.982/0.939 |
| Gemma-26B llama (q8, MTP) | 23.5 | 11.2 | | | | speed — under 8 tok/s at ~24K | 0.713/0.701 |
| Bonsai prism fork (q4 KV) | 14.9 | 10.8 | 9.2 | | 7.9 (32K) | speed — under 8 tok/s at 32K, single slot deep, other slot idle-loaded | pending |
| Qwen3.8 llama (q8, MTP) | 14.1 | 8.6 | | | | speed — under 8 tok/s at ~19K | pending |
| Gemma-12B llama (q8, MTP) | 14.0 | | | | | speed — under 8 tok/s at ~11K | pending |
| **Gemma-12B MLX (LM Studio engine, CLI)** | 36.7 | 36.9 | 34.8 | 33.1 | 29.7 (169.6K) | engine — LM Studio auto-fits MLX context to 170K regardless of the requested value (unfixed LM Studio bug); still 29.7 tok/s at 169.6K, the deepest healthy point, 171K fails clean; served via lms CLI, 8.8 GB RSS at 74K | pending |

Cells are blank past a config's cap. *8K value.

## Code quality — EvalPlus HumanEval+

| model | config scored | pass@1 base | pass@1 plus | status |
|---|---|--:|--:|---|
| **Qwen3.8-27B** | mlx 4-bit, reasoning_effort=medium, budget 8192 | **0.982** | **0.939** | 0 empty |
| **Ternary Bonsai-27B** | mlx 2-bit, thinking on, budget 10240 | **0.915** | **0.884** | 5/164 empty is a real model ceiling |
| **Qwen3.6-35B-A3B (MoE)** | llama+MTP, thinking on, budget 26624 | **0.939** | **0.921** | 5/164 empty is a real model ceiling |
| **Gemma-4-26B-A4B** | mlx 4-bit, thinking on, budget 30000 | **0.713** | **0.701** | 46/164 (~28%) empty is a real model ceiling — the thinking-convergence problem |
| Gemma-4-12B | calibrated only (budget 30000) | – | – | pending — 4/10 sample problems hit the cap, worse than the 26B |

## Open questions

- EvalPlus for Gemma-12B (MLX and LM Studio), the Bonsai prism-fork
  q4 pick, and a Bonsai thinking-off pass.
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
