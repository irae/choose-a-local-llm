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
- Weak point: the scored fork config has no depth curve yet — its floor
  is pending.

## All configs — this model

<!-- gen:model-table:start -->
| Config | Max ctx | Gated by | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus |
|---|--:|:--:|--:|--:|--:|
| Ternary-Bonsai-27B, GGUF⁴, q4, thinking on | 2x48k | speed | 14.9 → 7.9 | 10.0 GB | 0.927/0.890 |
| Ternary-Bonsai-27B, MLX, bounded cache, thinking on | 58k | mem | 24.5 → 17.3 | 22.5 GB | 0.915/0.884 |
<!-- gen:model-table:end -->

## Configs

Three configs matter for this model. Everything on this page is one of
them:

1. **MLX** — max usable depth, and f16 KV (slightly higher fidelity).
2. **Fork, single agent, full optimizations** — the EvalPlus-scored
   config (q4 KV + PrismML's calibration bias).
3. **Fork, 2×48K slots** — the multi-agent config.

**Config 1 — MLX, for one agent that needs depth.** Fastest at every
depth it reaches: 24.5 tok/s shallow, 17.27 at 58K, OOM ~60K (limit
24000). Keep `--prompt-cache-size 2`: the default cache pool behaves
like a memory leak and once faked a 44K OOM.

```bash
mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit \
  --prompt-cache-size 2 --port 8081
```

**Config 2 — fork, single agent, the scored config.** 9.8 GB flat, the
Mac stays usable. This exact command carries the EvalPlus score; without
the rotation flag and the `--kv-mean-center` bias you are serving an
unscored variant:

```bash
LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server \
  -m ~/.cache/huggingface/hub/models--prism-ml--Ternary-Bonsai-27B-gguf/snapshots/<rev>/Ternary-Bonsai-27B-Q2_g64.gguf \
  --alias bonsai-prism \
  -ngl 999 -fa on -c 65536 \
  --cache-type-k q4_0 --cache-type-v q4_0 \
  --kv-mean-center /tmp/Ternary-Bonsai-27B-kv-bias.gguf \
  --jinja --port 8081
```

(Regenerate the bias file with the vendor's `make_kv_bias.sh` if `/tmp`
was wiped — see [the benchmarks](../benchmarks/bonsai-27b.md).)

**Config 3 — fork, two agents.** Same flags as config 2 with
`--parallel 2 -c 98304` (2×48K slots), 10.0 GB RSS.

## Model details and findings

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
| **Light desktop, one agent** | fork scored #2 | 14.6 shallow (plain-q4 proxy) | speed: floor pending; plain-q4 proxy ~30K |
| **Two agents** | fork 2×48K #3 | 14.89 shallow, one slot decoding | speed: slot floor ~32K used |

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

## Config 2 (fork scored) — depth: pending

The scored config (bias + rotation flag) has no depth curve yet. The
closest measured proxy is plain q4 (no bias): floor ~30K used, 9.8 GB
RSS, allocation size irrelevant below 262K. **Pending: a slow-creep
depth sweep of the exact scored config** — the bias and rotation flag
could move the floor and the gating. Until then, treat ~30K as the
planning number. Full plain-q4 variant tables (q8, DSpark drafter,
262K alloc) are in [the benchmarks](../benchmarks/bonsai-27b.md).

## Config 3 (fork 2×48K) — single-slot depth (one slot decoding, other idle)

| depth (used tokens) | slot-0 tok/s |
|---|--:|
| 4K | 14.89 |
| 8K | 13.21 |
| 16K | 10.81 |
| 24K | 9.15 |
| **32K** | **7.88 — crosses the 8 tok/s floor** |

The idle second slot costs almost nothing (floor matches single-slot
plain q4). Both slots decoding at once — the worst case, not the
reported number — ran 9.8/9.9 tok/s each, aggregate 19.7. This sweep
also predates the bias flags; it re-runs with them when config 2 gets
its curve.

---

Method: warmup before every measurement; identical prompts across models;
temp 0. Full raw numbers in
[the benchmarks](../benchmarks/bonsai-27b.md). Cross-model picks on
[the comparison page](../comparison.md).
