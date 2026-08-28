# Ternary Bonsai-27B on M1 Max 32 GB

mlx-lm 0.31.3 (llama-server pending a release) · prism-ml ternary 2-bit ·
benchmarked 2026-08-25

## Summary

Ternary (2-bit) Bonsai — PrismML's quality-oriented compression of
Qwen3.6-27B, claiming 95% of full-precision performance — decodes at **~24
tok/s** on mlx-lm with only ~8 GB of weights, and holds **49K context at 18.8
tok/s** under the current wired limit (25000; OOM before 65K — the 262K
trained window is memory-capped). The flattest speed-vs-depth curve of any
model tested. The PrismML llama.cpp fork (installed, night-3 candidate) adds
q4 KV and speculative decoding for bigger context. EvalPlus verified:
**0.915 / 0.884** HumanEval+ (fair budget, night 2) — 27B-class quality from
8 GB of weights.

**24.5 tok/s** decode at shallow context · **57K** max healthy context at
limit 25000 · **18.8 tok/s at 49K**, the flattest creep measured · **no MTP**
— DSpark drafter via the prism fork instead.

## Quality — EvalPlus HumanEval+ (fair score, night 2)

| config scored | pass@1 base | pass@1 plus | empty completions |
|---|--:|--:|--:|
| mlx_lm.server 2-bit, thinking on, budget 10240 | 0.915 | 0.884 | 5/164 (~3%) |

**Fair score — the token-budget flaw is fixed.** Night 2 calibrated the
budget (10240) and regenerated all 55 budget-truncated completions: the score
jumped from night 1's 0.640/0.634 to **0.915/0.884**, the biggest correction
of any model. The remaining 5 empty completions are a real model ceiling
(still empty at the full budget), not a harness artifact. The ternary claim
holds up: 2-bit compression kept near-27B-class quality. Practical note:
Bonsai is the least disruptive model to work alongside (moderate fan noise,
low memory footprint) — a good all-day background agent. Details in
`night2/results.md`.

## Which to pick for a coding task

| need | config | tok/s | context |
|---|---|--:|--:|
| **Max context** | mlx_lm.server, bounded prompt cache | 18.8 at 49K | 57K OK; OOM before 61K (limit 25000) |
| **Max speed** | same config, shallow context | 24.5 | ≤8K |
| **Multi-agent** | prism fork `--parallel 2 -c 98304`, q4 KV — 9.8 tok/s each concurrent, 10.0 GB | 9.8×2 | 2×48K |

One command — requests queue (no slots). **Keep `--prompt-cache-size 2`**: by
default the server pools several distinct KV caches (multi-gigabyte each at
depth) and behaves like a memory leak across differently-shaped requests;
bounding the pool removed a false 44K OOM and reduced depth creep.

```bash
mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit \
  --prompt-cache-size 2 --port 8081
```

## Decode speed vs used context (sweep, limit 25000)

| depth (used tokens) | decode tok/s |
|---|--:|
| 4K | 24.5 |
| 8K | 24.2 |
| 16K | 22.9 |
| 24K | 22.0 |
| 32K | 20.5 |
| 49K | 18.8 |
| **57K** | **18.2 — deepest healthy point** |
| ~61K | Metal OOM — ceiling 57-61K |

The flattest depth curve of all models measured: −23% from 4K to 49K, never
approaching the 8 tok/s usability floor — Bonsai's limit is memory, not
speed. PrismML's own figures (100K at ~15 GB; 262K with 4-bit KV) need their
serving stack: the 4-bit KV path is llama.cpp-only, so the prism-fork run
(night 3) is where the bigger context lives.

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

**Two serving profiles.** Speed: MLX (above) — fastest at every depth it
reaches, but memory grows with the session and hard-OOMs by ~49–65K. Desktop:
fork q4 plain at 64K alloc — **9.8 GB flat**, floor ~30K, the Mac stays
usable while the agent runs; q4 quality (with PrismML's calibration bias) is
pending the night-3 EvalPlus check. The DSpark drafter is output-lossless and
lifts shallow decode (19.1/21.5 py/js at n-max 2, 69/84% acceptance) but
lowers the floor at every draft depth tried (n1 least: ~23K vs plain q4's
~30K) and adds 4-5 GB — use it only for shallow-context serving. Drafter file
must be converted locally (`gguf-dspark-to-dflash`); the published Q4_1
sidecar and plain Q2_0 GGUF are legacy layouts that do not load on current
fork builds.

Desktop-profile command (fork binary, `prism-llama` alias):

```bash
~/prism-llama/llama-server \
  -m ~/.cache/huggingface/hub/models--prism-ml--Ternary-Bonsai-27B-gguf/snapshots/<rev>/Ternary-Bonsai-27B-Q2_g64.gguf \
  --alias bonsai-prism \
  -ngl 999 -fa on -c 65536 \
  --cache-type-k q4_0 --cache-type-v q4_0 \
  --jinja --port 8081
```

## Blocked / parked

GGUF Q2_0 (6.7 GB, on disk, byte-verified): the current brew llama.cpp
(build 10621) predates the final Q2_0 tensor layout and refuses to load it.
Parked until the next stable release — that unlocks llama-server slots,
preallocated context, and a possible multi-slot story. When starting it, pin
the file: `--hf-file Ternary-Bonsai-27B-Q2_0.gguf` (the `:Q2_0` tag wrongly
matches the PQ2_0 variant).

---

Method: warmup before every measurement; identical prompts across models;
temp 0. Full raw numbers in
[the benchmarks](../benchmarks/bonsai-27b.md). Cross-model picks on
[the comparison page](../comparison.md). 1-bit variants were dropped from
scope and deleted.
