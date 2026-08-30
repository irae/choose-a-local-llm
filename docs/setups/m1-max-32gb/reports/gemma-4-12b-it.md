# Gemma-4-12B-it on M1 Max 32 GB

Backends: llama-server, LM Studio MLX engine · [GGUF on Hugging Face](https://huggingface.co/unsloth/gemma-4-12b-it-GGUF) · [MLX 4-bit](https://huggingface.co/lmstudio-community/gemma-4-12B-it-MLX-4bit)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>29.3 tok/s</b><span>at 65K used (LM Studio)</span></div>
  <div class="kpi"><b>65-74K</b><span>ceiling: compression onset (LM Studio)</span></div>
  <div class="kpi"><b>0.909 / 0.872</b><span>EvalPlus, thinking off</span></div>
  <div class="kpi"><b>4×256K</b><span>llama q8 slots, 16.9 GB</span></div>
</div>
<!-- gen:model-kpis:end -->

Benchmarked 2026-08-25 (llama build 10621, unsloth Q4_K_XL); LM Studio ceiling re-measured 2026-08-30 under the compression-onset criterion.

## Highlights

- **The deepest and flattest usable curve of the whole project** (LM
  Studio): 25.1 tok/s still at 147K used tokens, in the smallest
  footprint of any usable config.
- **Two ceiling readings, two uses.** Memory compression starts between
  65K and 74K — the benchmark-grade ceiling. The engine stays functional
  to ~150K, the safe practical limit for harness work. See "Two
  ceilings" below.
- **The best concurrency story.** Four 256K slots fit with q8_0 KV, in
  16.9 GB (llama).
- Weak point: on llama it floors at ~11K — the depth belongs to LM
  Studio. Quality: 0.909/0.872 thinking off; thinking on is pending, and
  its thinking fails to converge more often than the larger 26B.

## All configs — this model

<!-- gen:model-table:start -->
| # | Config | Max ctx | Gated by | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus |
|--:|---|--:|:--:|--:|--:|--:|
| 1 | Gemma-4-12B, MLX³ | 158k* | mem | 37† → 29.29 | 8.8 GB† | pending |
| 2 | Gemma-4-12B, MLX³, thinking off | 158k* | mem | 37† → 29.29 | 8.8 GB† | 0.909/0.872 |
| 3 | Gemma-4-12B, GGUF, MTP q8, thinking off | 11k† | speed | 14.0† → 8† | 8.2 GB† | 0.909/0.872 |
| 4 | Gemma-4-12B, GGUF, MTP q8, 4 slots, thinking off | 4x256k† | speed | 33.7† → pending | 16.9 GB† | 0.909/0.872 |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
**#1 — Gemma-4-12B, MLX³.** Thinking is always on with this engine; context is auto-fit (158,464 at wired limit 24000).

```bash
~/.cache/lm-studio/bin/lms server start --port 8081
~/.cache/lm-studio/bin/lms load google/gemma-4-12b --parallel 4 --gpu max -y
```

**#2 — Gemma-4-12B, MLX³, thinking off.** Archived score: current engine builds always think, so this config is not reproducible today.

```bash
~/.cache/lm-studio/bin/lms server start --port 8081
~/.cache/lm-studio/bin/lms load google/gemma-4-12b --parallel 4 --gpu max -y
```

**#3 — Gemma-4-12B, GGUF, MTP q8, thinking off.** pi id `gemma-4-12b`.

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 4 --parallel 1 \
  -ngl 999 -fa on -c 262144 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

**#4 — Gemma-4-12B, GGUF, MTP q8, 4 slots, thinking off.** pi id `gemma-4-12b-4x`.

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b-4x --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 4 --parallel 4 \
  -ngl 999 -fa on -c 1048576 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

**This model re-entered play because of the runtime, not the weights.**
mlx-lm cannot serve it: it lacks the `gemma4_unified` model type. LM Studio's
engine supports that type and implements its attention properly. That single
fact turned a model that floors at 11K on llama into the deepest usable
config in the project. Serving it from the `lms` CLI is an approved exception
to the no-GUI rule — everything still runs command-line only, and the model
store is shared with the app.

**The draft depth optimum moves with thinking.** n-max 3 is best with
thinking on, because thinking text drafts worse; n-max 4 is best with
thinking off. For a mixed setup, use n=3 on a thinking main-agent server and
n=4 on thinking-off sub-agent slots.

**The context ceiling is the model, not the machine.** GGUF metadata gives a
trained context of 262,144, and a sliding window of 1024 on 5 of every 6
layers, so KV grows only ~1 GB per 64K tokens. No Metal OOM appeared at any
size tested. Context limits are mode-independent, since KV is preallocated by
`-c`. Four 256K slots do hit Metal OOM with f16 — 3 is the f16 maximum at
full window, while q8_0 reaches 4.

**The speed numbers here were measured with f16 KV.** On this model f16 beat
q8_0 by +5.5 py tok/s, which is why it was used. q8_0 is now the default on
every config, per the KV policy, so a re-probe under the current wired limit
is pending. MTP uses the separate `mtp-gemma-4-12b-it.gguf` draft from the
unsloth repo.

**Two ceilings: what the findings mean (2026-08-30).** The two
context figures on this page describe two different limits, and both are
real:

- **~170K is the functional limit.** The engine serves requests to
  ~158-170K used tokens (auto-fit window; the loader refuses beyond it).
  The curve stays above 22 tok/s the whole way. This config "sort of
  works": past ~74K the system leans on memory compression, and near the
  window edge a request can force a full ~150K-token recompute when the
  disk cache evicts. For harness use, stay near **~150K** to keep a
  margin below the window edge.
- **~65-74K is the clean limit.** Memory compression and swap start
  inside the 74K step. Below it the system is free of memory pressure.
  Benchmarks and depth sweeps use this reading, because they hold deep
  contexts hot for hours. A harness does not hit the machine that hard —
  occasional deep calls above the onset are fine.
- The context column in the tables keeps the auto-fit estimate (158,464)
  flagged as a loader estimate; the trained max is 262,144 and does not
  fit on this machine.
- None of this is tunable. The engine ignores every context-length
  setting for this model (CLI flags, REST body, per-model config file,
  app default). Auto-fit computes the window from the GPU wired limit.
  `--parallel` is the one load knob that works.

**Thinking is binary.** Gemma 4 has trained-in reasoning (`<|think|>`),
toggled by `enable_thinking` — on/off, default off, no graded effort levels.

Quality is unscored; the EvalPlus gate for the LM Studio config is
pending.

## Decode speed vs used context (depth sweeps, limit 25000)

| depth | llama+MTP q8 | LM Studio MLX engine (lms CLI, port 1234) |
|---|--:|--:|
| 4K | 14.0 | 36.7 |
| 8K | 9.0 | |
| 16K | 6.8 — under the 8 tok/s floor | 36.9 |
| 33K / 49K | | 34.8 / 33.1 |
| 74K / 98K | | 30.8 / 28.6 |
| 131K / 147K | | 26.1 / 25.1 |
| **169.6K** | | **29.7 — deepest healthy point; 171K fails clean, LM Studio's loader caps it at 170K, not this model or this machine** |

**Ceiling, revised criterion (2026-08-30):** context length cannot be
pinned for this model — the engine ignores every `-c`/`--context-length`
path; auto-fit always gives 158,464 at wired limit 24000. The ceiling is
now the onset of memory compression/swap, not the loader's raw context
cap. Confirmation sweep (`--parallel 4`, watcher at 20 s interval):

| depth | decode tok/s | watcher state |
|---|--:|---|
| 41,095 | 31.05 | clean |
| 49,112 | 30.25 | clean |
| 57,077 | 29.25 | clean |
| **65,094** | **29.29 — last clean step** | clean |
| 74,099 | 27.95 | compression/swap onset inside this step (d_compress up to 114,012 pages, d_swapout 128) |

**Ceiling = onset between 65K and 74K, tok/s 29.29 at 65,094 tokens.**
The 158,464 context-window figure is the loader's auto-fit estimate,
not a true measured ceiling — the trained max is 262,144 (footnote).

llama RSS at floor depth (11K, q8_0 KV, 16K alloc): 8.2 GB.

## Context (n-max 4, f16 KV)

| -c | slots | result | RSS |
|---|---|---|--:|
| 131,072 | 1 | OK | 10.4 GB |
| **262,144** | **1** | **OK — trained maximum, validated with 4K-token prompt** | **12.4 GB** |
| **524,288** | **2×256K** | **OK — MTP active on both slots** | **16.9 GB** |

## MTP sweep — thinking ON

Chat endpoint, `enable_thinking: true`, 1024 tokens.

| --spec-draft-n-max | py tok/s | py accept | js tok/s | js accept |
|---|--:|--:|--:|--:|
| **3** | **35.00** | **70%** | **35.55** | **72%** |
| 4 | 33.34 | 64% | 33.91 | 65% |
| 6 | 26.80 | 55% | 25.92 | 53% |

Thinking OFF (sub-agent / fast mode) peaks at **45.2 py / 31.3 js tok/s**, at
n-max 4 with f16 KV — against 22.3 without MTP. Full thinking-off sweep and
KV tables in [the benchmarks](../benchmarks/gemma-4-12b-it.md).

---

Method: fresh server start per configuration; identical curl per run;
temperature 0. Full raw numbers in
[the benchmarks](../benchmarks/gemma-4-12b-it.md). Cross-model picks on
[the comparison page](../comparison.md).
