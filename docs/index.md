# Finding the best local coding model for your machine

A repeatable process to answer, for one specific computer: **which local
model, runtime, and configuration should I code with?** Everything runs
against OpenAI-compatible servers that a coding harness can actually use.

## What this project measures

- **Usable speed at real session depth, not benchmark speed.** Decode speed
  falls as the context fills. A model that benchmarks at 60 tok/s can crawl
  at 2 tok/s mid-session.
- **Context that fits the machine while it stays a desktop.** Memory
  footprints are measured so the Mac remains usable during all-day agent
  work.
- **Quality per quantization and per runtime.** Published scores cover
  full-precision models. What you run is a quant.
- **Role assignment, not a single winner.** A thinking main agent, fast
  sub-agents, an all-day background agent, and multi-agent slots — each seat
  can go to a different model and runtime.

Every config gets a decode-vs-used-context sweep and an honest "capped by"
verdict: speed floor, memory OOM, or model window. The usability floor here
is 8 tok/s. EvalPlus gates every config; Aider polyglot ranks the survivors.

Read [the methodology](./methodology.md) before running anything. The flow is
the law.

## Setups

### M1 Max, 32 GB

Apple Silicon, wired limit 25000 MB. Five models, four runtimes:
llama-server, mlx_lm.server, LM Studio, and the PrismML llama.cpp fork. Depth
sweeps are complete for every model and runtime; quality scores are partial.

- **Best quality:** Qwen3.8-27B on MLX — 0.982 / 0.939 EvalPlus. Qwen3.6-35B
  is close behind at 0.939 / 0.921, and four times faster.
- **Best depth:** Gemma-12B on the LM Studio engine — 29.7 tok/s still at
  169.6K used tokens, in 8.8 GB. LM Studio's own MLX loader caps it at 170K
  (a known LM Studio bug, not a memory or speed limit of the model).
- **Best speed with depth:** Gemma-26B on MLX — 51 tok/s at 4K, 22 at 74K.
- **Best all-day agent:** Ternary Bonsai-27B — 27B-class quality from 8 GB of
  weights.
- **The law:** MLX runtimes barely slow down but hit hard memory ceilings;
  llama runtimes slow down faster but never OOM inside their window.

| Suggested for | Config | Gated at | Gated by | tok/s (shallow → deep) | Memory | EvalPlus |
|---|---|--:|:--:|--:|--:|--:|
| **Hard problems** | Qwen3.8 MLX, compact | 28K | mem | 17 → 14 | 14.3 GB | 0.982/0.939 |
| **Deep sessions** | Qwen3.6 llama+MTP q8 | 90K | speed | 44 → 8.1 | 22.8 GB | 0.939/0.921 |
| **Fast + deep (contender)** | Gemma-26B MLX | 74K | mem | 51 → 22 | 13.5 GB | pending |
| **Flattest (contender)** | Gemma-12B via LM Studio (lms CLI) | 170K | engine | 37 → 31 | 8.8 GB | pending |
| **All-day background** | Bonsai MLX, bounded cache | 49K | mem | 24.5 → 18.8 | grows to ~15 GB | 0.915/0.884 |
| **Desktop + multi-agent** | Bonsai prism fork q4, 2×48K slots | 48K per slot | speed | 14.6 solo; 9.8 each concurrent | 10.0 GB flat | pending |

| model | report | benchmarks |
|---|---|---|
| Qwen3.6-35B-A3B (MoE) | [report](./setups/m1-max-32gb/reports/qwen3.6-35b-a3b.md) | [data](./setups/m1-max-32gb/benchmarks/qwen3.6-35b-a3b.md) |
| Gemma-4-26B-A4B (MoE) | [report](./setups/m1-max-32gb/reports/gemma-4-26b-a4b.md) | [data](./setups/m1-max-32gb/benchmarks/gemma-4-26b-a4b.md) |
| Gemma-4-12B-it | [report](./setups/m1-max-32gb/reports/gemma-4-12b-it.md) | [data](./setups/m1-max-32gb/benchmarks/gemma-4-12b-it.md) |
| Ternary Bonsai-27B | [report](./setups/m1-max-32gb/reports/bonsai-27b.md) | [data](./setups/m1-max-32gb/benchmarks/bonsai-27b.md) |
| Qwen3.8-27B | [report](./setups/m1-max-32gb/reports/qwen3.8-27b.md) | [data](./setups/m1-max-32gb/benchmarks/qwen3.8-27b.md) |

Also on this setup: the [comparison page](./setups/m1-max-32gb/comparison.md)
with the full depth and quality tables, the
[setup overview](./setups/m1-max-32gb/index.md) with the machine
configuration, and
[historical measurements](./setups/m1-max-32gb/historical.md) taken under
retired memory limits.

### More setups

A PC with an NVIDIA GPU comes next: Bonsai on the CUDA builds of the prism
fork, and lower quants of the other models. It gets the same shape — setup
overview, comparison, reports, benchmarks.

## Why this exists

This site is the worked example for one machine, but the process applies to
any box: substitute your memory budget and your candidates.

The reason the depth axis matters more than any published benchmark: a real
coding session here measured 1.7 tok/s at 135K used tokens, on a config whose
near-empty benchmark said 62 tok/s. Context maxima alone are storage, not
speed. So every config is swept against *used* context until it drops under
the usability floor or runs out of memory, and the floor — not the window —
sets the harness compaction threshold.

Published quality scores have the same problem. They cover full-precision
weights, and what fits on a desktop is a quant. Quality has to be measured
per quantization and per runtime, because MLX and GGUF weights are different
artifacts of the same model.
