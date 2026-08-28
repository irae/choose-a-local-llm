# Finding the best local coding model for your machine

A repeatable process to answer, for one specific computer: **which local
model, runtime, and configuration should I code with?** Everything runs
against OpenAI-compatible servers that a coding harness (ours: pi) can
actually use.

## Goals

1. **Usable speed at real session depth, not benchmark speed.** Decode
   speed falls as the context fills; a model that benchmarks at 60 tok/s can
   crawl at 2 tok/s mid-session. Every config gets a decode-vs-used-context
   sweep and an honest "capped by" verdict (speed floor, memory OOM, or model
   window). The user's usability floor here is 8 tok/s.
2. **Context that fits the machine while it stays a desktop.** Memory
   footprints are measured so the Mac remains usable during all-day agent
   work; harness compaction thresholds are set from the measured floor.
3. **Quality per quantization and per runtime.** Published scores cover
   full-precision models; what you run is a quant. EvalPlus (HumanEval+)
   gates every config, Aider polyglot ranks the survivors.
4. **Role assignment, not a single winner**: a thinking main agent, fast
   sub-agents, an all-day background agent, and multi-agent slots — each
   seat can go to a different model/runtime.

This site is the worked example for one machine (Apple Silicon M1 Max,
32 GB), but the process applies to any box: substitute your memory budget
and candidates.

Read [the methodology](./methodology.md) before running anything. The flow
is the law.

## Setups

### M1 Max, 32 GB

Apple Silicon, wired limit 25000 MB. Five models, four runtimes
(llama-server, mlx_lm.server, LM Studio, the PrismML llama.cpp fork). Depth
sweeps are complete for every model and runtime; quality scores are partial.

**Current picks by seat** (quality gate pending where noted):

| seat | config | tok/s (shallow → deep) | memory | EvalPlus |
|---|---|---|---|---|
| **Hard problems** | Qwen3.8 MLX, compact ~26K | 17 → 14 at 28K | 14.3 GB | 0.982/0.939 |
| **Deep sessions** | Qwen3.6 llama+MTP q8, 96K | 44 → 8.1 at 90K | 22.8 GB | correction parked |
| **Fast + deep (contender)** | Gemma-26B MLX | 51 → 22 at 74K | 13.5 GB | night 3 |
| **Flattest (contender)** | Gemma-12B via LM Studio (lms CLI) | 37 → 31 at 74K | 8.8 GB | night 3 |
| **All-day background** | Bonsai MLX, 48K, bounded cache | 24.5 → 18.8 at 49K | grows to ~15 GB | 0.915/0.884 |
| **Desktop + multi-agent** | Bonsai prism fork q4, 2×48K slots | 14.6 solo; 9.8 each concurrent | 10.0 GB flat | night 3 (q4) |

**The headline law**: MLX runtimes barely creep but hit hard memory
ceilings; llama runtimes creep faster but never OOM inside their windows.
MoE models on MLX give the two fastest depth curves measured here. The
deepest usable curve of all is Gemma-12B on the LM Studio engine — 25.1
tok/s still at 147K used tokens.

Where to look:

- [Setup overview](./setups/m1-max-32gb/index.md) — machine setup, models
  under test, current state, night-run history.
- [Comparison](./setups/m1-max-32gb/comparison.md) — the cross-model
  picture: the depth/floor table, quality scores, current configs.
- [Historical](/setups/m1-max-32gb/historical.html) — superseded
  measurements. Nothing on the current pages was measured under a retired
  limit.

Per-model reports (copy-paste server commands; aliases match the pi model
ids) and full raw data:

| model | report | benchmarks |
|---|---|---|
| Qwen3.6-35B-A3B (MoE) | [report](/setups/m1-max-32gb/reports/qwen3.6-35b-a3b.html) | [data](./setups/m1-max-32gb/benchmarks/qwen3.6-35b-a3b.md) |
| Gemma-4-26B-A4B (MoE) | [report](/setups/m1-max-32gb/reports/gemma-4-26b-a4b.html) | [data](./setups/m1-max-32gb/benchmarks/gemma-4-26b-a4b.md) |
| Gemma-4-12B-it | [report](/setups/m1-max-32gb/reports/gemma-4-12b-it.html) | [data](./setups/m1-max-32gb/benchmarks/gemma-4-12b-it.md) |
| Ternary Bonsai-27B | [report](/setups/m1-max-32gb/reports/bonsai-27b) | [data](./setups/m1-max-32gb/benchmarks/bonsai-27b.md) |
| Qwen3.8-27B | [report](/setups/m1-max-32gb/reports/qwen3.8-27b.html) | [data](./setups/m1-max-32gb/benchmarks/qwen3.8-27b.md) |

### More setups

A PC with an NVIDIA GPU comes next: Bonsai on the CUDA builds of the prism
fork, and lower quants of the other models. It gets the same shape — setup
overview, comparison, reports, benchmarks.
