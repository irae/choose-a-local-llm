# Local coding models on M1 Max 32 GB

Cross-model picks · llama-server (build 10621) + mlx-lm 0.31.3 · 2026-08-25

## Per-model reports

- [Gemma-4-26B-A4B](/setups/m1-max-32gb/reports/gemma-4-26b-a4b) —
  MoE+MTP: fastest Python, full 256K window (q8 KV), 2×184K slots
- [Qwen3.6-35B-A3B](/setups/m1-max-32gb/reports/qwen3.6-35b-a3b) —
  MoE+MTP: fastest JS, strongest base benchmarks; 96K context at the current
  wired limit
- [Gemma-4-12B-it](/setups/m1-max-32gb/reports/gemma-4-12b-it.html) —
  biggest context, best concurrency
- [Ternary Bonsai-27B](/setups/m1-max-32gb/reports/bonsai-27b) —
  27B-class from 8 GB; two serving profiles (MLX speed / prism-fork
  desktop), 2 concurrent slots on the fork
- [Qwen3.8-27B](/setups/m1-max-32gb/reports/qwen3.8-27b.html) — strongest
  base model, slowest on this hardware

Everything on this page was measured at the current wired limit
(`iogpu.wired_limit_mb=25000`, resets on reboot). Superseded measurements
live in [historical.html](/setups/m1-max-32gb/historical.html); the flow is
in the [methodology](../../methodology.md).

## Code quality — EvalPlus HumanEval+ (night 2, 2026-08-27)

| model | config scored | pass@1 base | pass@1 plus | status |
|---|---|--:|--:|---|
| **Qwen3.8-27B** | mlx 4-bit, reasoning_effort=medium, budget 8192 | **0.982** | **0.939** | fair — 0 empty |
| **Ternary Bonsai-27B** | mlx 2-bit, thinking on, budget 10240 | **0.915** | **0.884** | fair — 5/164 empty is a real model ceiling |
| Qwen3.6-35B-A3B (MoE) | llama+MTP, thinking on | 0.610 | 0.610 | still night-1 lower bound — correction parked at 5/62 regenerated |
| Gemma-4-26B-A4B | calibrated only (budget 30000) | – | – | 2/10 sample problems never finished reasoning at the 30K cap |
| Gemma-4-12B | calibrated only (budget 30000) | – | – | 4/10 sample problems hit the cap — worse than the 26B, counterintuitively |

The night-1 token-budget flaw is fixed: budgets are now calibrated per model
from measured reasoning length (`night2/calibration.md`). Bonsai's correction
was the largest (0.640 → 0.915) — the flawed cap was hiding most of its
ability. Qwen3.6's score is still the deflated night-1 number; do not rank on
it until its correction finishes. The Gemma thinking mode sometimes fails to
converge at all (30K tokens of reasoning without an answer) — that is model
behavior, not a harness limit, and the 12B does it more than the 26B. Full
history: `night2/results.md`, `night2/state.md`.

## Decode speed vs used context — the 8 tok/s usability floor (2026-08-28, limit 25000)

Why this axis exists: decode speed falls as the KV cache *fills* — a real
coding session measured 1.7 tok/s at 135K used tokens on a config whose
near-empty benchmark said 62. Context maxima alone are storage, not speed.
Each model is swept with an append-only growing prompt (perfect cache reuse)
until decode drops under the user's 8 tok/s floor or the server runs out of
memory. The floor, not the window, is where pi's compaction threshold
belongs — and capping the window also returns wired memory to the system.

| model / runtime | tok/s @ 4K | @ 16K | @ 32-33K | @ 49K | @ 74-90K | capped by | EvalPlus (base/plus) |
|---|--:|--:|--:|--:|--:|---|--:|
| **Gemma-26B MLX** | 51.1 | 43.5 | 35.6 | 28.8 | 22.2 (74K) | OOM at 82-98K — 20.6 tok/s at 82K | not scored (night 3) |
| **Qwen3.6-35B MLX** | 53.3 | 49.6 | 42.2 | | | OOM at 37-41K — 42.0 tok/s at 37K | not scored |
| **Qwen3.6-35B llama (q8, MTP)** | 44.5 | 30.1 | 18.8 | 13.5 | 8.1 (90K) | its own 96K window — still 8.1 tok/s at 90K | 0.610/0.610 — deflated, correction parked |
| Bonsai MLX (f16 KV) | 24.5 | 22.9 | 20.5 | 18.8 | 18.2 (57K) | OOM at 57-61K — 18.2 tok/s at 57K | 0.915/0.884 |
| Qwen3.8 MLX | 17.1* | 16.4 | | | | OOM at 29-33K — still 14.2 tok/s at 28K | 0.982/0.939 |
| Gemma-26B llama (q8, MTP) | 23.5 | 11.2 | | | | speed — under 8 tok/s at ~24K | not scored (night 3) |
| Bonsai prism fork (q4 KV) | 14.6 | 10.6 | | | | speed — under 8 tok/s at ~30K | pending (night 3) |
| Qwen3.8 llama (q8, MTP) | 14.1 | 8.6 | | | | speed — under 8 tok/s at ~19K | not scored |
| Gemma-12B llama (q8, MTP) | 14.0 | | | | | speed — under 8 tok/s at ~11K | not scored (night 3) |
| **Gemma-12B MLX (LM Studio engine, CLI)** | 36.7 | 36.9 | 34.8 | 33.1 | 30.8 (74K) | not found — **25.1 tok/s at 147K**, the deepest usable curve measured; served via lms CLI on port 1234, 8.8 GB RSS at 74K | not scored (night 3) |

Cells are blank past a config's cap. Scores are HumanEval+ pass@1 from
night 2, measured on the same weights as the row's runtime where noted; see
the quality section above. *8K value. Sweep prompts are synthetic code
continuations, so MTP-model numbers read below the standard py/js bench
(draft acceptance differs); curves are comparable across rows.

The pattern is universal: **MLX runtimes barely creep but hit hard memory
ceilings; llama runtimes creep faster but never OOM inside their windows.**
MoE models on MLX dominate: Gemma-26B MLX (13.5 GB RSS) and Qwen3.6 MLX are
the two fastest curves ever measured here. Bonsai on the prism fork also
serves **2×48K slots at 9.8 tok/s each concurrently in 10.0 GB** (3×48K: 7.6
each in 11.2 GB) — the only multi-agent setup that leaves the machine free.
Raw sweeps in the [benchmarks](./benchmarks/bonsai-27b.md) markdowns.

## Current picks by seat (quality gate pending where noted)

| seat | config | tok/s (shallow → deep) | memory | EvalPlus |
|---|---|--:|--:|--:|
| **Hard problems** | Qwen3.8 MLX, compact ~26K | 17 → 14 at 28K | 14.3 GB | 0.982/0.939 |
| **Deep sessions** | Qwen3.6 llama+MTP q8, 96K | 44 → 8.1 at 90K | 22.8 GB | correction parked |
| **Fast + deep (contender)** | Gemma-26B MLX | 51 → 22 at 74K | 13.5 GB | night 3 |
| **Flattest (contender)** | Gemma-12B via LM Studio (lms CLI) | 37 → 31 at 74K | 8.8 GB | night 3 |
| **All-day background** | Bonsai MLX, 48K, bounded cache | 24.5 → 18.8 at 49K | grows to ~15 GB | 0.915/0.884 |
| **Desktop + multi-agent** | Bonsai prism fork q4, 2×48K slots | 14.6 solo; 9.8 each concurrent | 10.0 GB flat | night 3 (q4) |

Server commands live in each model's report; aliases equal the pi model ids.
Compaction thresholds come from the floor table above, not from the window.

## Open questions

- Night 3 (draft): finish the Qwen3.6 score correction; EvalPlus for the
  Gemma configs — now including Gemma-26B MLX and Gemma-12B via LM Studio,
  the two best unscored depth curves — and the Bonsai prism-fork q4 A/B.
- Memory ceilings for the MLX configs that never hit the speed floor
  (measurement in flight).
- Aider polyglot (tier 2) for gate survivors — driven from another computer;
  docker does not fit beside a loaded model here.
- Watch list: brew llama.cpp reading ternary Q2; mlx-lm gaining
  `gemma4_unified` and server-side KV quantization.

---

Method: warmup before measurements; identical prompts across models;
temperature 0. Per-model raw numbers in the benchmarks markdowns.
