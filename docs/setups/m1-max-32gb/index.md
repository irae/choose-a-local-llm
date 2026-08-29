# This machine — M1 Max, 32 GB

## Highlights

- **Wired limit 25000 MB.** It resets on reboot. Re-run the sysctl before any
  model work.
- **Depth sweeps are complete** for every model and every runtime. The
  decode-vs-used-context table on the [comparison page](./comparison.md) is
  this project's main artifact.
- **Three models have fair quality scores.** Qwen3.8 at 0.982/0.939,
  Qwen3.6 at 0.939/0.921, and Bonsai at 0.915/0.884. Only the Gemmas are
  unscored.
- **Four runtimes are in play**, not one: llama-server, mlx_lm.server, LM
  Studio's engine, and the PrismML llama.cpp fork.
- **The law:** MLX barely slows down but OOMs hard; llama slows down faster
  but never OOMs inside its window.

## Setup

```bash
sudo sysctl iogpu.wired_limit_mb=25000
```

**This resets on reboot.** Re-run it before any model work.

- Servers always listen on port 8081. Port 8080 is the DB admin UI. LM Studio
  serves on 1234.
- Harness: pi (`~/.pi/agent/models.json`). Pick a server by copy-pasting the
  command block from its report page. Aliases equal the pi model ids.
- Swap arithmetic: the server's RSS is wired, the kernel wires ~2-3 GB more,
  and all apps share the rest of 32 GB. Whole-machine slowness means swap. A
  slow model on a healthy machine means depth physics. Tell them apart before
  acting, with `vm_stat`, `sysctl vm.swapusage`, or the memory probe.

## Models under test

| model | files | reports |
|---|---|---|
| Qwen3.6-35B-A3B (MoE) | `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`; `mlx-community/Qwen3.6-35B-A3B-4bit` | [report](./reports/qwen3.6-35b-a3b.md), [benchmarks](./benchmarks/qwen3.6-35b-a3b.md) |
| Gemma-4-26B-A4B (MoE) | `unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL` + MTP draft; `mlx-community/gemma-4-26b-a4b-it-4bit` | [report](./reports/gemma-4-26b-a4b.md), [benchmarks](./benchmarks/gemma-4-26b-a4b.md) |
| Qwen3.8-27B | `bartowski/Qwen3.8-27B-GGUF:Q4_K_M`; `mlx-community/Qwen3.8-27B-4bit` | [report](./reports/qwen3.8-27b.md), [benchmarks](./benchmarks/qwen3.8-27b.md) |
| Ternary Bonsai-27B | `prism-ml/Ternary-Bonsai-27B-mlx-2bit`; GGUF `Q2_g64` + `PQ2_0` + converted dflash drafter (prism fork only) | [report](./reports/bonsai-27b.md), [benchmarks](./benchmarks/bonsai-27b.md) |
| Gemma-4-12B-it | `unsloth/gemma-4-12b-it-GGUF:Q4_K_XL`; `lmstudio-community/gemma-4-12B-it-MLX-4bit` (LM Studio engine only) | [report](./reports/gemma-4-12b-it.md), [benchmarks](./benchmarks/gemma-4-12b-it.md) |

Thinking controls differ by family. Gemma 4 uses a binary `enable_thinking`,
default off. The Qwen3.6 family, including Bonsai, is binary and defaults on.
Qwen3.8 uses graded effort: `low`, `medium`, `xhigh`. 1-bit Bonsai is out of
scope.

## Current state

As of 2026-08-28, end of day.

- Best curves, all quality-unscored: Gemma-12B on LM Studio is flattest at
  30.8 tok/s at 74K in 8.8 GB; Gemma-26B MLX runs 51→22 at 74K in 13.5 GB;
  Qwen3.6 llama never floors inside 96K; Qwen3.6 MLX holds 42 tok/s at 33K.
- Fair EvalPlus scores: Qwen3.8-mlx-medium **0.982/0.939**,
  Qwen3.6-llama-think **0.939/0.921**, Bonsai-mlx-f16 **0.915/0.884**. The
  Gemmas are unscored; their thinking mode sometimes never converges, and the
  12B does it more than the 26B.
- Bonsai extras: the PrismML fork is installed at `~/prism-llama/`. Its
  desktop profile holds q4 KV at 9.8 GB flat with a ~30K floor, and serves
  2×48K slots at 9.8 tok/s each concurrently — 3×48K gives 7.6 each. The
  DSpark drafter is converted and measured; it helps only at shallow context,
  so it is not used for scoring.
- pi wiring today: qwen3.8-mlx at a 26K window, bonsai-mlx at 48K, qwen3.6
  llama at 96K, gemma-26b llama at 256K with q8. Pending decisions: the
  bonsai-prism entry, and the Gemma windows once quality scores exist.
- Seat sketch, pending Gemma quality: main and deep go to Gemma-26B MLX or
  Qwen3.6; hard problems go to Qwen3.8-MLX at 26K; all-day and swarm go to
  Bonsai. Gemma-12B re-entered play through LM Studio.

## Open work

- Gemma scores, including the MLX and LM Studio variants, the bonsai-prism
  q4 A/B, and a Bonsai thinking-off pass. Each block waits for a go-ahead.
- Ceiling brackets for the MLX configs that never floored.
- Aider tier 2, driven from another computer. Docker does not fit here.
- Watch list and owner context: `HANDOFF.md`, not committed.

## Why quality scores needed a correction

EvalPlus's default output cap was too small for a reasoning model: it cut
off mid-thought, and the truncated completion scored as a failure. That
capped every early score to a deflated lower bound. The fix is a budget
calibrated per model from measured reasoning length; every corrected score
went up. Superseded numbers under the old cap live on
[the historical page](./historical.md), never on a current page.

## The wired limit, and why it is 25000

27000 made the machine too slow for normal use. 24000 gave too little
context — Qwen3.6-35B capped at 40K. 25000 is the compromise. Every published
number states the limit it was measured under, and only 25000 numbers appear
on the current site pages. Superseded measurements move to
[the historical page](./historical.md).
