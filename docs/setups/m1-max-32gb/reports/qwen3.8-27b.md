# Qwen3.8-27B on M1 Max 32 GB

Backends: llama-server, mlx-lm · [Qwen3.8-27B MLX 4-bit on Hugging Face](https://huggingface.co/mlx-community/Qwen3.8-27B-4bit)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>0.982 / 0.939</b><span>EvalPlus, effort medium — best score</span></div>
  <div class="kpi"><b>17 tok/s</b><span>decode, shallow (MLX)</span></div>
  <div class="kpi"><b>28K</b><span>MLX memory ceiling</span></div>
  <div class="kpi"><b>~26K</b><span>pi compaction setting</span></div>
</div>
<!-- gen:model-kpis:end -->

Benchmarked 2026-08-25 (llama build 10621, mlx-lm 0.31.3); EvalPlus at effort medium re-scored 2026-08-28 with the calibrated budget; GGUF re-measured at f16 KV 2026-09-05 (run 9).

## Highlights

- **The best quality score of any config measured here.** EvalPlus 0.982 /
  0.939, zero empty completions — the model to send hard problems to.
- **MLX holds 14-17 tok/s across its whole usable window.** It never gets
  slow inside the context it can hold.
- Weak point: the slowest model on this hardware (19.7 tok/s ceiling),
  with poor prompt processing (~123 tok/s).
- Weak point: a small window on MLX, which OOMs between 28K and 30K.
  llama at f16 KV now holds 15 tok/s to 49K, the largest context this
  machine loads for it (run 9).

## Can it finish engineering tasks? Not yet

Every Mendel run of this model is partial, and the last one is invalid.
Blind at effort medium scored 80 partial; blind at low 67.5 partial;
guided at low 84 partial on the first prompt version and 34 on the
current one, with three server crashes; the run 9 retry at low ended
invalid after three attempts, two of them real Metal OOM crashes when
the context grew past the 26624-token MLX window in agentic use. The
best single-turn score on this hardware has never delivered a complete
multi-file task through the harness.

So this page reads as a caution. Either the model does not fit this
machine for agent work, or the right configuration is not found yet.
The llama-server row at f16 KV, 15 tok/s to 49K, passed the Mendel
smoke in run 10 (one handed two-file task: 8 tool calls, one clean
commit, no loop, 62 seconds), so it gets a Mendel blind run in the
same run. Research looks at community builds,
a smaller window with earlier compaction, and 3-bit weights that buy
context. If none of that produces a completed run, the model retires
from the daily-driver question and keeps its single-turn score.

## All configs — this model

<!-- gen:model-table:start -->
| # | Config | Max ctx | Gated by | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus |
|--:|---|--:|:--:|--:|--:|--:|
| 1 | Qwen3.8-27B, MLX, compaction ~26k, effort medium | 28k | mem | 17 → 15.3 | 22.0 GB | 0.982/0.939 |
| 2 | Qwen3.8-27B, MLX, effort low | 28k | mem | 17 → 15.3 | 22.0 GB | 0.976/0.927 |
| 3 | Qwen3.8-27B, GGUF, MTP f16, effort medium | 49k | mem | 20.0 → 15.0 | 23.5 GB | 0.982/0.939 |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
**#1 — Qwen3.8-27B, MLX, compaction ~26k, effort medium.** Set the harness compaction threshold at ~26K.

```bash
mlx_lm.server --model mlx-community/Qwen3.8-27B-4bit \
  --reasoning-effort medium --port 8081
```

**#2 — Qwen3.8-27B, MLX, effort low.** Curve shared with the effort-medium row: same server, same weights. The reasoning effort changes the output, not the decode speed at a depth.

```bash
mlx_lm.server --model mlx-community/Qwen3.8-27B-4bit \
  --chat-template-args '{"reasoning_effort":"low"}' --prompt-cache-size 2 --port 8081
```

**#3 — Qwen3.8-27B, GGUF, MTP f16, effort medium.** pi id `qwen3.8-27b`. Re-measured 2026-09-05 at f16 KV, the run 9 pick: 49152 is the largest `-c` that loads under wired limit 24000; 65536 and above OOM at load. The EvalPlus score is the MLX effort-medium run, carried by the shared-score rule; the GGUF quant is not scored on its own yet.

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 49152 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

**The equilibrium moved to llama at f16 KV (run 9).** At q8_0 KV llama
crossed the 8 tok/s floor at about 19K, so MLX won on usable speed. At
f16 KV the same server decodes 20.0 tok/s at 4K and 15.0 at 49K, and
49152 is the largest `-c` this machine loads for it (65536 and above
OOM at load). That is the MLX speed with almost twice the MLX window,
plus prompt caching and slots. The four-problem smoke read level with
q8_0, so the cache type cost no answers. MLX keeps its place as the
config with the lowest memory.

**The quality score is fair, and it is the project's best.** The output
budget was calibrated to 8192 — its longest observed reasoning was only
~2.6K tokens — and the three empty completions left from an earlier,
uncalibrated pass were regenerated. Zero empty completions remain. Full
data: [the benchmarks](../benchmarks/qwen3.8-27b.md).

**Medium reasoning effort is faster for a mechanical reason.** The MTP head
predicts medium-effort text better than xhigh-effort text, so acceptance
climbs from 58–61% to 73–81%. That is where the ~21% per-token gain comes
from.

**q8_0 KV was not free here.** It looked free in a 512-token output
comparison at the retired 27000 limit, but the run 9 short creep showed
it at 7.1 tok/s at 32K against 16.4 for f16, more than a 2x gap, at
almost the same wired memory. The KV pick is f16. KV grows only about
0.8 GB per 16K tokens, because the hybrid DeltaNet layers keep no KV;
only the full-attention layers do, which is why f16 fits.

**The n-max 3 result is real.** It repeated exactly on a second run (16.77).
A second JS prompt — debounce, run twice — matched deep clone within 0.3
tok/s, so the JS penalty comes from the language, not the task. The settings
choice is the same for both languages.

**The old context maxima are withdrawn.** Every allocation figure for this
model was measured at the retired 27000 wired limit and awaits a re-probe at
24000. Those tables are on
[the historical page](../historical.md); do not use them.
The f16 ceiling at 49K is a load limit, not a decode floor.
[The benchmarks](../benchmarks/qwen3.8-27b.md) keep the labeled archive.
MTP-on-MLX exists only as a CLI with no API, so it is disqualified for
harness use; its raw numbers stay in the benchmarks too.

**Open issue: prompt processing.** It is ~20 tok/s on short prompts and
reaches only ~123–127 tok/s on 1.5K–4K prompts, which is low for this
hardware class. It is independent of MTP — the no-MTP baseline shows the same
numbers — so it looks like a Metal kernel limitation of the new hybrid
DeltaNet architecture in the current build. Worth re-testing on future
llama.cpp releases.

## Which to pick for a coding task

| need | config | tok/s (py/js) | context |
|---|---|--:|--:|
| **Daily driver** | mlx_lm.server, compaction at ~26K | 14-17 across the window | to ~28K ceiling |
| **llama alternative** | llama-server + MTP n=3, f16 KV, `-c 49152` | 20.0 shallow, 15.0 at 49K | 49K, the largest `-c` that loads (run 9) |

## Quality — EvalPlus HumanEval+

| config scored | pass@1 base | pass@1 plus | empty completions |
|---|--:|--:|--:|
| mlx_lm.server 4-bit, reasoning_effort=medium | 0.982 | 0.939 | 0/164 |

## Decode speed vs used context (llama at limit 25000, 2026-08-28; mlx re-tested at limit 24000, slow creep, 2026-08-29)

| depth | llama+MTP q8 | mlx |
|---|--:|--:|
| 4-8K | 14.1 / 12.8 | 17.1 |
| 16K | 8.6 | 16.4 |
| 22K | – | 10.23 |
| 24K | – | 14.79 |
| 24.5K | 7.3 — below the 8 tok/s floor | – |
| 26K | – | 15.19 |
| **28K** | – | **15.29 — last stable** |
| ~30K | – | Metal OOM — server thread dies, /health stays 200; gfx-resident ~22 GB at last stable depth |

llama RSS at floor depth (19K, q8_0 KV, 32K alloc): 18.9 GB.

## Backend comparison: llama-server (GGUF) vs mlx-lm (MLX)

| variant | py tok/s | js tok/s | memory |
|---|--:|--:|--:|
| llama-server Q4_K_M, no MTP | 12.44 | 12.44 | ~21 GB RSS |
| llama-server Q4_K_M + MTP n=3, f16 KV | 16.93 | 15.73 | ~21 GB RSS |
| **mlx-lm MLX 4-bit, no MTP** | **19.69** | **19.58** | **15.5 GB peak** |

## MTP draft depth sweep

256 tokens, temperature 0, q8_0 KV, 32K context.

| --spec-draft-n-max | py tok/s | py accept | js tok/s | js accept |
|---|--:|--:|--:|--:|
| off (baseline) | 12.44 | – | 12.44 | – |
| 1 | 12.39 | 91% | 12.02 | 85% |
| 2 | 11.98 | 87% | 10.68 | 72% |
| **3** | **16.79** | **77%** | **15.58** | **69%** |
| 4 | 16.33 | 75% | 13.03 | 55% |
| 6 | 13.12 | 61% | 10.21 | 44% |
| 7 | 12.73 | 53% | 10.16 | 40% |

## Reasoning effort (chat endpoint, 1024-token replies)

| effort | py tok/s | js tok/s | acceptance |
|---|--:|--:|--:|
| xhigh (default) | 14.44 | 13.96 | 58–61% |
| **medium** | **17.50** | **16.30** | **73–81%** |

At medium effort the llama peak stays at n-max 3:

| --spec-draft-n-max | py tok/s | py accept | js tok/s | js accept |
|---|--:|--:|--:|--:|
| **3** | **17.52** | **81%** | **16.31** | **73%** |
| 4 | 16.57 | 75% | 14.86 | 65% |
| 6 | 13.44 | 61% | 11.60 | 51% |

## KV cache: q8_0 vs f16 (at n-max 3)

| KV type | py tok/s | js tok/s | quality |
|---|--:|--:|---|
| q8_0 | 16.79 | 15.58 | near-lossless |
| **f16** | **16.93** | **15.73** | **lossless** |

---

Method: fresh server start per configuration; identical curl per run;
temperature 0. Full raw numbers in
[the benchmarks](../benchmarks/qwen3.8-27b.md). Cross-model picks on
[the comparison page](../comparison.md).
