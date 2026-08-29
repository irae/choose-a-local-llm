# Local coding models on M1 Max 32 GB

Cross-model picks · llama-server (build 10621) + mlx-lm 0.31.3 · 2026-08-25

## Highlights

- **Best quality:** Qwen3.8-27B on MLX — 0.982 / 0.939 EvalPlus. Send hard
  problems here.
- **Best depth:** Gemma-12B on the LM Studio engine — 29.9 tok/s at 168K used
  tokens, in 8.8 GB. LM Studio's own MLX loader caps it at 170K (a known
  LM Studio bug, not a memory or speed limit of the model).
- **Best speed with depth:** Gemma-26B on MLX — 51 tok/s at 4K, still 22 at
  74K, in 13.5 GB.
- **Best big window, and the best all-round config:** Qwen3.6-35B on llama —
  never crosses the 8 tok/s floor inside its whole 96K window, and now scores
  0.939 / 0.921.
- **Best all-day agent:** Ternary Bonsai-27B — 27B-class quality from 8 GB of
  weights, and the flattest curve of any model.
- **Best multi-agent:** Bonsai on the prism fork — 2×48K slots at 9.8 tok/s
  each, in 10.0 GB flat. The only setup that leaves the machine free.
- **The law that decides everything:** MLX runtimes barely slow down but hit
  hard memory ceilings. llama runtimes slow down faster but never OOM inside
  their window.

## Models evaluated

| Suggested for | Config | Gated at | Gated by | tok/s (shallow → deep) | Memory | EvalPlus |
|---|---|--:|:--:|--:|--:|--:|
| **Hard problems** | Qwen3.8 MLX, compact | 28K | mem | 17 → 14 | 14.3 GB | 0.982/0.939 |
| **Deep sessions** | Qwen3.6 llama+MTP q8 | 90K | speed | 44 → 8.1 | 22.8 GB | 0.939/0.921 |
| **Fast + deep (contender)** | Gemma-26B MLX | 74K | mem | 51 → 22 | 13.5 GB | pending |
| **Flattest (contender)** | Gemma-12B via LM Studio (lms CLI) | 170K | engine | 37 → 31 | 8.8 GB | pending |
| **All-day background** | Bonsai MLX, bounded cache | 49K | mem | 24.5 → 18.8 | grows to ~15 GB | 0.915/0.884 |
| **Desktop + multi-agent** | Bonsai prism fork q4, 2×48K slots | 48K per slot | speed | 14.6 solo; 9.8 each concurrent | 10.0 GB flat | pending |

"Gated at / by" is the used-context point where a config first breaks, and
why: memory (MLX runtimes OOM), speed (llama runtimes cross the 8 tok/s
usability floor), or engine (LM Studio's MLX loader auto-fits the context
to its own RAM estimate and cannot be told to allocate more — a known,
unfixed LM Studio bug, not a measurement of this model or this machine).
"tok/s (shallow → deep)" is decode speed near an empty context, then at
the gated depth. "Memory" is the wired GPU memory the config holds at
that depth.

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

Measured 2026-08-28 at wired limit 25000.

| model / runtime | tok/s @ 4K | @ 16K | @ 32-33K | @ 49K | @ 74-90K | capped by | EvalPlus (base/plus) |
|---|--:|--:|--:|--:|--:|---|--:|
| **Gemma-26B MLX** | 51.1 | 43.5 | 35.6 | 28.8 | 22.2 (74K) | mem — OOM at 82-98K, 20.6 tok/s at 82K | pending |
| **Qwen3.6-35B MLX** | 53.3 | 49.6 | 42.2 | | | mem — OOM at 37-41K, 42.0 tok/s at 37K | pending |
| **Qwen3.6-35B llama (q8, MTP)** | 44.5 | 30.1 | 18.8 | 13.5 | 8.1 (90K) | speed — its 96K window ends at 8.1 tok/s | 0.939/0.921 |
| Bonsai MLX (f16 KV) | 24.5 | 22.9 | 20.5 | 18.8 | 18.2 (57K) | mem — OOM at 57-61K, 18.2 tok/s at 57K | 0.915/0.884 |
| Qwen3.8 MLX | 17.1* | 16.4 | | | | mem — OOM at 29-33K, still 14.2 tok/s at 28K | 0.982/0.939 |
| Gemma-26B llama (q8, MTP) | 23.5 | 11.2 | | | | speed — under 8 tok/s at ~24K | pending |
| Bonsai prism fork (q4 KV) | 14.6 | 10.6 | | | | speed — under 8 tok/s at ~30K | pending |
| Qwen3.8 llama (q8, MTP) | 14.1 | 8.6 | | | | speed — under 8 tok/s at ~19K | pending |
| Gemma-12B llama (q8, MTP) | 14.0 | | | | | speed — under 8 tok/s at ~11K | pending |
| **Gemma-12B MLX (LM Studio engine, CLI)** | 36.7 | 36.9 | 34.8 | 33.1 | 29.9 (168K) | engine — LM Studio auto-fits MLX context to 170K regardless of the requested value (unfixed LM Studio bug); still 29.9 tok/s at 168K, the deepest point reached, no OOM and no speed floor hit; served via lms CLI, 8.8 GB RSS at 74K | pending |

Cells are blank past a config's cap. *8K value.

## Code quality — EvalPlus HumanEval+

| model | config scored | pass@1 base | pass@1 plus | status |
|---|---|--:|--:|---|
| **Qwen3.8-27B** | mlx 4-bit, reasoning_effort=medium, budget 8192 | **0.982** | **0.939** | 0 empty |
| **Ternary Bonsai-27B** | mlx 2-bit, thinking on, budget 10240 | **0.915** | **0.884** | 5/164 empty is a real model ceiling |
| **Qwen3.6-35B-A3B (MoE)** | llama+MTP, thinking on, budget 26624 | **0.939** | **0.921** | 5/164 empty is a real model ceiling |
| Gemma-4-26B-A4B | calibrated only (budget 30000) | – | – | pending — 2/10 sample problems never finished reasoning at the 30K cap |
| Gemma-4-12B | calibrated only (budget 30000) | – | – | pending — 4/10 sample problems hit the cap, worse than the 26B |

## Open questions

- EvalPlus for the Gemma configs (MLX and LM Studio), the Bonsai prism-fork
  q4 pick, and a Bonsai thinking-off pass.
- Memory ceilings for the MLX configs that never hit the speed floor.
- Aider polyglot (tier 2) for gate survivors — driven from another computer;
  docker does not fit beside a loaded model here.
- Watch list: brew llama.cpp reading ternary Q2; mlx-lm gaining
  `gemma4_unified` and server-side KV quantization.

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
HumanEval+ pass@1, measured on the same weights as the row's runtime.

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
