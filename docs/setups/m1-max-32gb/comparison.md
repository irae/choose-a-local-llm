# Local coding models on M1 Max 32 GB

Cross-model picks · llama-server (build 10621) + mlx-lm 0.31.3 · 2026-08-25

## Highlights

- **Best quality:** Qwen3.8-27B on MLX — 0.982 / 0.939 EvalPlus. Send hard
  problems here.
- **Best depth:** Gemma-12B on the LM Studio engine — 25.1 tok/s at 147K used
  tokens, in 8.8 GB. No ceiling found yet.
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

## Current picks by seat

Quality gate pending where noted.

| seat | config | tok/s (shallow → deep) | memory | EvalPlus |
|---|---|--:|--:|--:|
| **Hard problems** | Qwen3.8 MLX, compact ~26K | 17 → 14 at 28K | 14.3 GB | 0.982/0.939 |
| **Deep sessions** | Qwen3.6 llama+MTP q8, 96K | 44 → 8.1 at 90K | 22.8 GB | 0.939/0.921 |
| **Fast + deep (contender)** | Gemma-26B MLX | 51 → 22 at 74K | 13.5 GB | run 3 |
| **Flattest (contender)** | Gemma-12B via LM Studio (lms CLI) | 37 → 31 at 74K | 8.8 GB | run 3 |
| **All-day background** | Bonsai MLX, 48K, bounded cache | 24.5 → 18.8 at 49K | grows to ~15 GB | 0.915/0.884 |
| **Desktop + multi-agent** | Bonsai prism fork q4, 2×48K slots | 14.6 solo; 9.8 each concurrent | 10.0 GB flat | run 3 (q4) |

Server commands live in each model's report; aliases equal the pi model ids.
Compaction thresholds come from the floor table below, not from the window.

## Per-model reports

- [Gemma-4-26B-A4B](/setups/m1-max-32gb/reports/gemma-4-26b-a4b) —
  MoE+MTP: fastest Python, full 256K window (q8 KV), 2×184K slots
- [Qwen3.6-35B-A3B](/setups/m1-max-32gb/reports/qwen3.6-35b-a3b) —
  MoE+MTP: fastest JS, strongest base benchmarks; 96K context at the current
  wired limit
- [Gemma-4-12B-it](/setups/m1-max-32gb/reports/gemma-4-12b-it) —
  biggest context, best concurrency
- [Ternary Bonsai-27B](/setups/m1-max-32gb/reports/bonsai-27b) —
  27B-class from 8 GB; two serving profiles (MLX speed / prism-fork
  desktop), 2 concurrent slots on the fork
- [Qwen3.8-27B](/setups/m1-max-32gb/reports/qwen3.8-27b) — strongest
  base model, slowest on this hardware

## Decode speed vs used context — the 8 tok/s usability floor

Measured 2026-08-28 at wired limit 25000.

| model / runtime | tok/s @ 4K | @ 16K | @ 32-33K | @ 49K | @ 74-90K | capped by | EvalPlus (base/plus) |
|---|--:|--:|--:|--:|--:|---|--:|
| **Gemma-26B MLX** | 51.1 | 43.5 | 35.6 | 28.8 | 22.2 (74K) | OOM at 82-98K — 20.6 tok/s at 82K | not scored (run 3) |
| **Qwen3.6-35B MLX** | 53.3 | 49.6 | 42.2 | | | OOM at 37-41K — 42.0 tok/s at 37K | not scored |
| **Qwen3.6-35B llama (q8, MTP)** | 44.5 | 30.1 | 18.8 | 13.5 | 8.1 (90K) | its own 96K window — still 8.1 tok/s at 90K | 0.939/0.921 |
| Bonsai MLX (f16 KV) | 24.5 | 22.9 | 20.5 | 18.8 | 18.2 (57K) | OOM at 57-61K — 18.2 tok/s at 57K | 0.915/0.884 |
| Qwen3.8 MLX | 17.1* | 16.4 | | | | OOM at 29-33K — still 14.2 tok/s at 28K | 0.982/0.939 |
| Gemma-26B llama (q8, MTP) | 23.5 | 11.2 | | | | speed — under 8 tok/s at ~24K | not scored (run 3) |
| Bonsai prism fork (q4 KV) | 14.6 | 10.6 | | | | speed — under 8 tok/s at ~30K | pending (run 3) |
| Qwen3.8 llama (q8, MTP) | 14.1 | 8.6 | | | | speed — under 8 tok/s at ~19K | not scored |
| Gemma-12B llama (q8, MTP) | 14.0 | | | | | speed — under 8 tok/s at ~11K | not scored (run 3) |
| **Gemma-12B MLX (LM Studio engine, CLI)** | 36.7 | 36.9 | 34.8 | 33.1 | 30.8 (74K) | not found — **25.1 tok/s at 147K**, the deepest usable curve measured; served via lms CLI on port 1234, 8.8 GB RSS at 74K | not scored (run 3) |

Cells are blank past a config's cap. *8K value.

## Code quality — EvalPlus HumanEval+

Qwen3.8 and Bonsai measured on run 2, 2026-08-27. Qwen3.6 corrected on
run 3, 2026-08-28.

| model | config scored | pass@1 base | pass@1 plus | status |
|---|---|--:|--:|---|
| **Qwen3.8-27B** | mlx 4-bit, reasoning_effort=medium, budget 8192 | **0.982** | **0.939** | fair — 0 empty |
| **Ternary Bonsai-27B** | mlx 2-bit, thinking on, budget 10240 | **0.915** | **0.884** | fair — 5/164 empty is a real model ceiling |
| **Qwen3.6-35B-A3B (MoE)** | llama+MTP, thinking on, budget 26624 | **0.939** | **0.921** | fair — corrected in run 3; 5/164 empty is a real model ceiling |
| Gemma-4-26B-A4B | calibrated only (budget 30000) | – | – | 2/10 sample problems never finished reasoning at the 30K cap |
| Gemma-4-12B | calibrated only (budget 30000) | – | – | 4/10 sample problems hit the cap — worse than the 26B, counterintuitively |

## Open questions

- Run 3, remaining blocks: EvalPlus for the Gemma configs, now including
  Gemma-26B MLX and Gemma-12B via LM Studio, the two best unscored depth
  curves; the Bonsai prism-fork q4 A/B; and a Bonsai thinking-off pass.
  Blocks run one at a time, each waiting for a go-ahead.
- Memory ceilings for the MLX configs that never hit the speed floor
  (measurement in flight).
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
compaction threshold belongs — and capping the window also returns wired
memory to the system.

**The pattern held across every model.** MLX runtimes barely slow down but
hit hard memory ceilings; llama runtimes slow down faster but never OOM
inside their windows. MoE models on MLX dominate the speed rankings:
Gemma-26B MLX at 13.5 GB RSS and Qwen3.6 MLX are the two fastest curves ever
measured here.

**How to read the numbers.** Sweep prompts are synthetic code continuations,
so MTP-model numbers there read below the standard py/js bench, because draft
acceptance differs. The curves stay comparable across rows. Scores are
HumanEval+ pass@1, measured on the same weights as the row's runtime where
noted.

**The quality scores moved a lot once the harness was fixed.** Run 1 used a
fixed output budget that was too small, so reasoning exhausted the cap and
empty completions scored as failures. Budgets are now calibrated per model
from measured reasoning length (`night2/calibration.md`). Every corrected
score went up, and two went up enormously: Qwen3.6 from 0.610 to **0.939**,
and Bonsai from 0.640 to **0.915**. The flawed cap had been hiding most of
both models' ability. Nothing about the models changed — only the harness
that measured them. Treat any single-pass score with a fixed output budget
as a lower bound until the budget is calibrated.

**The Gemma models have a real convergence problem.** Their thinking mode
sometimes fails to converge at all — 30K tokens of reasoning with no answer.
That is model behavior, not a harness limit, and the 12B does it more often
than the 26B. Full history: `night2/results.md`, `night2/state.md`.

Superseded measurements live in
[historical.html](/setups/m1-max-32gb/historical.html). Nothing on this page
was measured under a retired wired limit. The flow is in the
[methodology](../../methodology.md).

---

Method: warmup before measurements; identical prompts across models;
temperature 0. Per-model raw numbers in the benchmarks pages.
