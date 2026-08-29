# Ternary Bonsai-27B on M1 Max 32 GB

mlx-lm 0.31.3 · prism-ml ternary 2-bit · benchmarked 2026-08-25

## Highlights

- **27B-class quality from 8 GB of weights.** EvalPlus 0.915 / 0.884.
- **The flattest speed curve of any model here.** Only −23% from 4K to 49K.
- **Never hits the speed floor.** Its limit is memory, not speed.
- **The least disruptive model to work beside.** Moderate fan noise, small
  footprint. The best all-day background agent.
- **The only multi-agent setup that leaves the machine free.** The prism fork
  serves 2×48K slots at 9.8 tok/s each, in 10.0 GB flat.
- Weak point: memory grows with the session on MLX and OOMs by ~58-60K
  (limit 24000).

## Best option

**mlx_lm.server, 2-bit, bounded prompt cache.** 24.5 tok/s shallow, 18.8
tok/s at 49K, healthy to 58K (17.27 tok/s there, limit 24000).

```bash
mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit \
  --prompt-cache-size 2 --port 8081
```

**Keep `--prompt-cache-size 2`.** By default the server pools several
distinct KV caches, multi-gigabyte each at depth, and behaves like a memory
leak across differently-shaped requests. Bounding the pool removed a false
44K OOM and reduced depth creep.

For a desktop that must stay usable, or for multiple agents, use the prism
fork instead — 9.8 GB flat, floor ~30K:

```bash
~/prism-llama/llama-server \
  -m ~/.cache/huggingface/hub/models--prism-ml--Ternary-Bonsai-27B-gguf/snapshots/<rev>/Ternary-Bonsai-27B-Q2_g64.gguf \
  --alias bonsai-prism \
  -ngl 999 -fa on -c 65536 \
  --cache-type-k q4_0 --cache-type-v q4_0 \
  --jinja --port 8081
```

## Which to pick for a coding task

| need | config | tok/s | context |
|---|---|--:|--:|
| **Max context** | mlx_lm.server, bounded prompt cache | 17.27 at 58K | 58K OK; OOM ~60K (limit 24000) |
| **Max speed** | same config, shallow context | 24.5 | ≤8K |
| **Multi-agent** | prism fork `--parallel 2 -c 98304`, q4 KV | 9.8×2 | 2×48K |

## Quality — EvalPlus HumanEval+

| config scored | pass@1 base | pass@1 plus | empty completions |
|---|--:|--:|--:|
| mlx_lm.server 2-bit, thinking on, budget 10240 | 0.915 | 0.884 | 5/164 (~3%) |

## Decode speed vs used context (shallow: limit 25000, 2026-08-28; deep re-test: limit 24000, slow creep, 2026-08-29)

| depth (used tokens) | decode tok/s |
|---|--:|
| 4K | 24.5 |
| 8K | 24.2 |
| 16K | 22.9 |
| 24K | 22.0 |
| 32K | 20.5 |
| 40K | 18.60 |
| 42K | 18.66 |
| 44K | 12.10 |
| 46K | 11.89 |
| 48K | 11.33 |
| 50K | 18.36 |
| 52K | 18.09 |
| 54K | 17.64 |
| 56K | 17.69 |
| **58K** | **17.27 — last stable, limit 24000** |
| ~60K | Metal OOM — ceiling ~58-60K at limit 24000 |

## PrismML llama.cpp fork (measured 2026-08-28)

| config (alloc) | shallow tok/s | 8 tok/s floor | RSS |
|---|--:|--:|--:|
| **q4_0 KV plain (64K)** | **14.6** | **~30K** | **9.8 GB** |
| q4_0 KV plain (128K) | 14.6 | ~30K | 11.0 GB |
| q4_0 + DSpark n2 (128K) | 16–17 | ~20K | 16.2 GB |
| q4_0 + DSpark n1 (64K) | 16.4 | ~23K | 14.1 GB |
| q8_0 KV plain (128K) | 13.8 | ~21K | 12.8 GB |
| q8_0 + DSpark n2 (128K) | 16.5 | ~20K | 18.2 GB |
| q8_0 KV plain (262K) | 12.8 | ~21K | 17.1 GB — full window fits |
| **q4_0, 2 slots (2×48K)** | **9.8 each, both decoding** | – | **10.0 GB** |

## History and reasoning

**The quality number was wrong at first, and the correction was the biggest
of any model.** Ternary Bonsai is PrismML's quality-oriented compression of
Qwen3.6-27B, and they claim 95% of full-precision performance. An early pass
scored it far too low, with a token budget that was too small. Calibrating
the budget (10240) and regenerating all 55 truncated completions moved the
score to 0.915/0.884, the second-largest correction in the project. The
flawed cap had been hiding most of its ability. The deflated number is on
[the historical page](../historical.md).
The 5 empty completions that remain are a real model ceiling — they stay
empty at the full budget — not a harness artifact. The ternary claim holds
up: 2-bit compression kept near-27B-class quality.

**Two serving profiles, and they trade against each other.** MLX is fastest
at every depth it reaches, but memory grows with the session and hard-OOMs by
~57-61K. The prism fork q4 at 64K alloc stays at 9.8 GB flat with a ~30K
floor, so the Mac stays usable while the agent runs. The q4 quality, which
carries PrismML's own calibration bias, still needs its EvalPlus check —
pending.

**The DSpark drafter is not worth it past shallow context.** It is
output-lossless and lifts shallow decode to 19.1/21.5 py/js at n-max 2, with
69/84% acceptance. But it lowers the floor at every draft depth tried — n1 is
the least harmful at ~23K, against plain q4's ~30K — and it adds 4-5 GB. Use
it only for shallow-context serving. The drafter file must be converted
locally with `gguf-dspark-to-dflash`; the published Q4_1 sidecar and the
plain Q2_0 GGUF are legacy layouts that do not load on current fork builds.

**PrismML's own published figures need their serving stack.** They report
100K at ~15 GB, and 262K with 4-bit KV. The 4-bit KV path is llama.cpp-only,
so the fork is where the bigger context lives.

**Blocked: GGUF Q2_0.** The file is on disk, 6.7 GB, byte-verified. The
current brew llama.cpp (build 10621) predates the final Q2_0 tensor layout
and refuses to load it. Parked until the next stable release, which would
unlock llama-server slots, preallocated context, and a possible multi-slot
story. When starting it, pin the file: `--hf-file
Ternary-Bonsai-27B-Q2_0.gguf` — the `:Q2_0` tag wrongly matches the PQ2_0
variant.

1-bit variants were dropped from scope and deleted.

---

Method: warmup before every measurement; identical prompts across models;
temp 0. Full raw numbers in
[the benchmarks](../benchmarks/bonsai-27b.md). Cross-model picks on
[the comparison page](../comparison.md).
