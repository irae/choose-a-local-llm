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
- **Quality per quantization.** Published scores cover full-precision
  models. What you run is a quant. One score per model and thinking
  mode; runtimes at standard quants share it.
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

Apple Silicon, wired limit 24000 MB. Five models, four runtimes:
llama-server, mlx_lm.server, LM Studio, and the PrismML llama.cpp fork.
Depth sweeps are complete; quality scores are partial. The law: MLX
runtimes barely slow down but hit hard memory ceilings; llama runtimes
slow down faster but never OOM inside their window.

<!-- gen:models-evaluated:start -->
| # | Config | Max ctx | Gated by¹ | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus² |
|--:|---|--:|:--:|--:|--:|--:|
| 1 | Qwen3.8-27B | 28k | mem | 17 → 15.3 | 22.0 GB | 0.982/0.939 |
| 2 | Qwen3.6-35B-A3B | 90k† | speed | 44† → 8.1† | 22.8 GB† | 0.939/0.921 |
| 3 | Ternary-Bonsai-27B | 2x48k | speed | 14.9 → 7.8 | 10.9 GB | 0.927/0.890 |
| 4 | Gemma-4-12B | 158k* | mem | 37† → 29.29 | 8.8 GB† | 0.909/0.872 |
| 5 | Gemma-4-26B-A4B | 70k | mem | 51 → 12.8 | 20.0 GB | 0.713/0.701 |

† from an earlier serving config or method; re-run pending.
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
see the setup's comparison page.

⁴ PrismML's llama.cpp fork, an approved exception to the no-forks rule.

*Italic* values are fast-sweep ceilings from before the slow-creep rule;
a re-test comes soon and their memory figures are suspect. See
[the measurement rules](./methodology/context-creep) for why the slow creep
is more realistic.

"Memory (at max ctx)" is the wired GPU memory the config holds at max ctx.

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
weights, and what fits on a desktop is a quant, so quality is measured on
the quant actually served. Narrow differences between runtimes' standard
quants do not count: one score per model and thinking mode covers them.
Aggressive or calibrated quants get their own gate.
