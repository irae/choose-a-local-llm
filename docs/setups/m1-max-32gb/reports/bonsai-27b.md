# Ternary Bonsai-27B on M1 Max 32 GB

Backends: mlx-lm, prism-llama fork · [Ternary-Bonsai-27B on Hugging Face](https://huggingface.co/prism-ml/Ternary-Bonsai-27B-mlx-2bit) ([GGUF](https://huggingface.co/prism-ml/Ternary-Bonsai-27B-gguf))

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>24.5 tok/s</b><span>decode, shallow (MLX)</span></div>
  <div class="kpi"><b>58K</b><span>max healthy depth, 17.3 tok/s (MLX)</span></div>
  <div class="kpi"><b>0.927 / 0.890</b><span>EvalPlus base/plus (fork, calibrated q4)</span></div>
  <div class="kpi"><b>2×48K</b><span>fork slots in 10.0 GB</span></div>
</div>
<!-- gen:model-kpis:end -->

Benchmarked 2026-08-25 on mlx-lm 0.31.3; quality and fork figures updated 2026-08-30 (prism fork build prism-b10660).

## Highlights

- **27B-class quality from 8 GB of weights** — EvalPlus 0.927 / 0.890,
  and the vendor's q4-KV calibration costs no quality (it beats plain
  MLX 2-bit's 0.915 / 0.884).
- **The flattest speed curve of any model here** (MLX): −23% from 4K to
  49K, never hits the speed floor; the limit is memory (~58-60K).
- **The only multi-agent setup that leaves the machine free**: 2×48K
  fork slots in 10.0 GB — but window is not usable depth: the fork's
  speed floor is ~30K used tokens.
- The scored fork config's speed floor is 33K used tokens, 9.6 GB flat —
  the calibration bias and rotation flag do not move it versus the plain
  q4 proxy.

## All configs — this model

<!-- gen:model-table:start -->
| # | Config | Max ctx | Gated by | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus |
|--:|---|--:|:--:|--:|--:|--:|
| 1 | Ternary-Bonsai-27B, MLX, bounded cache, thinking on | 58k | mem | 24.5 → 17.3 | 22.5 GB | 0.915/0.884 |
| 2 | Ternary-Bonsai-27B, MLX, bounded cache, thinking off | 58k† | mem | 24.5† → 17.3† | 22.5 GB† | 0.927/0.902 |
| 3 | Ternary-Bonsai-27B, GGUF⁴, q4, thinking on | 33k | speed | 14.8 → 7.9 | 9.6 GB | 0.927/0.890 |
| 4 | Ternary-Bonsai-27B, GGUF⁴, q4, 2 slots, thinking on | 2x48k | speed | 14.9 → 7.8 | 10.9 GB | 0.927/0.890 |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
**#1 — Ternary-Bonsai-27B, MLX, bounded cache, thinking on.** Keep `--prompt-cache-size 2`: the default cache pool behaves like a memory leak.

```bash
mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit \
  --prompt-cache-size 2 --port 8081
```

**#2 — Ternary-Bonsai-27B, MLX, bounded cache, thinking off.** Extra body per request: `{"chat_template_kwargs":{"enable_thinking":false}}`. Speed/memory copied from bonsai-mlx; no depth sweep yet.

```bash
mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit \
  --prompt-cache-size 2 --port 8081
```

**#3 — Ternary-Bonsai-27B, GGUF⁴, q4, thinking on.** The scored config. Regenerate the bias file with the vendor's `make_kv_bias.sh` if `/tmp` was wiped — see [the benchmarks](../benchmarks/bonsai-27b.md).

```bash
LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server \
  -m ~/.cache/huggingface/hub/models--prism-ml--Ternary-Bonsai-27B-gguf/snapshots/<rev>/Ternary-Bonsai-27B-Q2_g64.gguf \
  --alias bonsai-prism \
  -ngl 999 -fa on -c 65536 --parallel 1 \
  --cache-type-k q4_0 --cache-type-v q4_0 \
  --kv-mean-center /tmp/Ternary-Bonsai-27B-kv-bias.gguf \
  --jinja --port 8081
```

**#4 — Ternary-Bonsai-27B, GGUF⁴, q4, 2 slots, thinking on.**

```bash
LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server \
  -m ~/.cache/huggingface/hub/models--prism-ml--Ternary-Bonsai-27B-gguf/snapshots/<rev>/Ternary-Bonsai-27B-Q2_g64.gguf \
  --alias bonsai-prism-2x \
  -ngl 999 -fa on -c 98304 --parallel 2 \
  --cache-type-k q4_0 --cache-type-v q4_0 \
  --kv-mean-center /tmp/Ternary-Bonsai-27B-kv-bias.gguf \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

**Window is not usable depth** on the fork. It allocates huge windows in
little memory (the full 262K trained window fits in 17.1 GB with q8 KV)
and never OOMs inside them — but decode crosses the 8 tok/s floor at
~30K used tokens. MLX is the opposite: fastest at every depth it
reaches, and memory-limited at ~58K. For one agent that needs depth,
MLX (#1) wins on both axes; the fork's niches are the light desktop
(#2) and multi-agent slots (#3).

**The quality number was wrong at first, and the correction was the biggest
of any model.** Ternary Bonsai is PrismML's quality-oriented compression of
Qwen3.6-27B, and they claim 95% of full-precision performance. An early pass
scored it far too low, with a token budget that was too small. Calibrating
the budget (10240) and regenerating all 55 truncated completions moved the
score to 0.915/0.884, the second-largest correction in the project. The
flawed cap had been hiding most of its ability. The deflated number is on
[the historical page](../historical.md). The 4-5 empty completions that
remain are a real model ceiling — they stay empty at the full budget — not
a harness artifact. The ternary claim holds up: 2-bit compression kept
near-27B-class quality, and the vendor's q4-KV calibration then held it
again (0.927/0.890, slightly above MLX 2-bit).

**Two serving profiles, and they trade against each other.** MLX is fastest
at every depth it reaches, but memory grows with the session and hard-OOMs
by ~58-60K. The fork stays at ~10 GB flat with a ~30K speed floor, so the
Mac stays usable while the agent runs. For one agent that needs depth, MLX
wins on both axes; the fork's niches are multi-agent slots and a light
desktop.

**The DSpark drafter is not worth it past shallow context.** It is
output-lossless and lifts shallow decode (19.1/21.5 py/js at n-max 2,
69/84% acceptance), but it lowers the floor at every draft depth tried and
adds 4-5 GB. Shallow-context serving only. The drafter file must be
converted locally with `gguf-dspark-to-dflash`; the published Q4_1 sidecar
and the plain Q2_0 GGUF are legacy layouts that do not load on current fork
builds.

**PrismML's own published figures need their serving stack.** They report
100K at ~15 GB, and 262K with 4-bit KV. The 4-bit KV path is llama.cpp-only,
so the fork is where the bigger context lives.

**Blocked: GGUF Q2_0 on brew llama.cpp.** The file is on disk, 6.7 GB,
byte-verified. The current brew build (10621) predates the final Q2_0
tensor layout and refuses to load it. Parked until the next stable release,
which would unlock mainline llama-server slots. When starting it, pin the
file: `--hf-file Ternary-Bonsai-27B-Q2_0.gguf` — the `:Q2_0` tag wrongly
matches the PQ2_0 variant.

1-bit variants were dropped from scope and deleted.

## Which to pick

| need | config | tok/s (used depth) | gated by |
|---|---|--:|---|
| **Depth + speed, one agent** | MLX #1 | 24.5 shallow; 17.27 at 58K | mem: OOM ~58-60K |
| **Light desktop, one agent** | fork scored #2 | 14.8 shallow, 7.9 at 33K | speed: floor 33K used |
| **Two agents** | fork 2×48K #3 | 14.94 shallow, 7.78 at 33K, one slot decoding | speed: slot floor 33K used |

## Quality — EvalPlus HumanEval+

| config scored | pass@1 base | pass@1 plus | empty completions |
|---|--:|--:|--:|
| fork, q4_0 KV + calibration bias, thinking on, budget 10240 #2 | 0.927 | 0.890 | 4/164 (~2%) |
| MLX 2-bit, thinking on, budget 10240 #1 | 0.915 | 0.884 | 5/164 (~3%) |

## Config 1 (MLX) — decode speed vs used context (slow creep, limit 24000)

| depth (used tokens) | decode tok/s |
|---|--:|
| 4K | 24.5 |
| 8K | 24.2 |
| 16K | 22.9 |
| 24K | 22.0 |
| 32K | 20.5 |
| 40K | 18.60 |
| 42K | 18.66 |
| 50K | 18.36 |
| 52K | 18.09 |
| 54K | 17.64 |
| 56K | 17.69 |
| **58K** | **17.27 — last stable** |
| ~60K | Metal OOM — ceiling ~58-60K |

(A transient 44-48K dip from an earlier pass is on
[the historical page](../historical.md); the watched re-test recovered
to ~18 tok/s past it.)

## Config 2 (fork scored) — depth: measured 2026-08-30

| depth (used tokens) | decode tok/s |
|---|--:|
| 4K | 14.79 |
| 8K | 13.22 |
| 16K | 10.77 |
| 24K | 9.08 |
| **33K** | **7.85 — crosses the 8 tok/s floor** |

9.6 GB RSS at the floor, no compression or swap in the watcher log.
Matches the plain-q4 proxy (~30K) and the 2×48K single-slot sweep
almost exactly — the bias and rotation flags do not move the floor.
Full plain-q4 variant tables (q8, DSpark drafter, 262K alloc) are in
[the benchmarks](../benchmarks/bonsai-27b.md).

## Config 3 (fork 2×48K) — single-slot depth (one slot decoding, other idle), measured 2026-08-30

| depth (used tokens) | slot-0 tok/s |
|---|--:|
| 4K | 14.94 |
| 8K | 13.15 |
| 16K | 10.65 |
| 24K | 9.10 |
| **33K** | **7.78 — crosses the 8 tok/s floor** |

10.9 GB RSS at the floor, no compression or swap. The idle second slot
costs almost nothing (floor matches config 2's single-slot floor and
the plain-q4 proxy). Both slots decoding at once — the worst case, not
the reported number — ran 9.8/9.9 tok/s each, aggregate 19.7 (from an
earlier pass, predates the bias flags).

---

Method: warmup before every measurement; identical prompts across models;
temp 0. Full raw numbers in
[the benchmarks](../benchmarks/bonsai-27b.md). Cross-model picks on
[the comparison page](../comparison.md).
