# This machine — M1 Max, 32 GB

## Setup

- `sudo sysctl iogpu.wired_limit_mb=25000` — **resets on reboot; re-run before
  any model work.** History: 27000 made the machine too slow for normal use;
  24000 gave too little context (Qwen3.6-35B capped at 40K); 25000 is the
  compromise. Every published number states its limit; only 25000 numbers may
  appear on the HTML pages.
- Servers always on port 8081 (8080 is the DB admin UI); LM Studio serves on
  1234. Harness: pi (`~/.pi/agent/models.json`); the user picks servers by
  copy-pasting the HTML command boxes; aliases equal pi model ids.
- Swap arithmetic: the server's RSS is wired; kernel wires ~2-3 GB more; all
  apps share the rest of 32 GB. Whole-machine slowness = swap; slow model on
  a healthy machine = depth physics. Distinguish before acting
  (`vm_stat`, `sysctl vm.swapusage`, the mem-watch probe).

## Models under test

| model | files | reports |
|---|---|---|
| Qwen3.6-35B-A3B (MoE) | `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`; `mlx-community/Qwen3.6-35B-A3B-4bit` | [report](/setups/m1-max-32gb/reports/qwen3.6-35b-a3b), [benchmarks](./benchmarks/qwen3.6-35b-a3b.md) |
| Gemma-4-26B-A4B (MoE) | `unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL` + MTP draft; `mlx-community/gemma-4-26b-a4b-it-4bit` | [report](/setups/m1-max-32gb/reports/gemma-4-26b-a4b), [benchmarks](./benchmarks/gemma-4-26b-a4b.md) |
| Qwen3.8-27B | `bartowski/Qwen3.8-27B-GGUF:Q4_K_M`; `mlx-community/Qwen3.8-27B-4bit` | [report](/setups/m1-max-32gb/reports/qwen3.8-27b.html), [benchmarks](./benchmarks/qwen3.8-27b.md) |
| Ternary Bonsai-27B | `prism-ml/Ternary-Bonsai-27B-mlx-2bit`; GGUF `Q2_g64` + `PQ2_0` + converted dflash drafter (prism fork only) | [report](/setups/m1-max-32gb/reports/bonsai-27b), [benchmarks](./benchmarks/bonsai-27b.md) |
| Gemma-4-12B-it | `unsloth/gemma-4-12b-it-GGUF:Q4_K_XL`; `lmstudio-community/gemma-4-12B-it-MLX-4bit` (LM Studio engine only) | [report](/setups/m1-max-32gb/reports/gemma-4-12b-it.html), [benchmarks](./benchmarks/gemma-4-12b-it.md) |

Thinking controls: Gemma 4 = binary `enable_thinking`, default OFF. Qwen3.6
family (incl. Bonsai) = binary, default ON. Qwen3.8 = graded effort
(`low`/`medium`/`xhigh`). 1-bit Bonsai is out of scope.

## Current state (2026-08-28, end of day)

- **Depth sweeps complete for every model and runtime** — the decode-vs-used-
  context table on the [comparison page](./comparison.md) is
  the project's main artifact. Law:
  MLX barely creeps but OOMs hard; llama creeps but never OOMs in-window.
- Best curves, all quality-unscored: Gemma-12B on LM Studio (flattest,
  30.8 tok/s at 74K, 8.8 GB), Gemma-26B MLX (51→22 at 74K, 13.5 GB),
  Qwen3.6 llama (never floors inside 96K), Qwen3.6 MLX (42 tok/s at 33K).
- Fair EvalPlus scores: Qwen3.8-mlx-medium **0.982/0.939**, Bonsai-mlx-f16
  **0.915/0.884**. Qwen3.6 still carries a deflated 0.610 (correction parked
  at 5/62). Gemmas unscored; their thinking mode sometimes never converges
  (12B worse than 26B).
- Bonsai extras: PrismML fork installed (`~/prism-llama/`), desktop profile
  q4-KV 9.8 GB flat with ~30K floor, 2×48K slots at 9.8 tok/s each
  concurrently (3×48K: 7.6 each), DSpark drafter converted and measured
  (shallow-only gain; not used for scoring).
- pi wiring today: qwen3.8-mlx at 26K window; bonsai-mlx at 48K; qwen3.6
  llama at 96K; gemma-26b llama 256K (q8). Pending decisions: bonsai-prism
  entry, gemma windows after quality scores.
- Seat sketch (pending night-3 quality): main/deep = Gemma-26B MLX or
  Qwen3.6; hard problems = Qwen3.8-MLX at 26K; all-day + swarm = Bonsai.
  Gemma-12B re-entered play via LM Studio.

## Open work

- Night 3 (draft in `night3/NIGHT-AGENT.md`, uncommitted — decide with the
  user): qwen36 correction, Gemma scores (now including the MLX/LM Studio
  variants), bonsai-prism q4 A/B.
- Ceiling brackets for the MLX configs that never floored (runs in flight).
- Aider tier 2, driven from another computer (docker does not fit here).
- Watch list and user context: `HANDOFF.md` (not committed).

## Night-run history

- **Night 1** (`night1/`): first EvalPlus pass; found and patched four
  EvalPlus 0.3.1 defects; discovered the max_tokens flaw — all scores were
  deflated lower bounds. Full incident log: `night1/state.md`.
- **Night 2** (`night2/`): calibrated per-model budgets (Phase A), corrected
  qwen3.8 and bonsai cheaply by regenerating only empty completions
  (temperature-0 identity), found EvalPlus's infinite-retry timeout bug,
  established the heartbeat rule. Log: `night2/state.md`.
- **Night 3**: draft, pending joint sign-off.
