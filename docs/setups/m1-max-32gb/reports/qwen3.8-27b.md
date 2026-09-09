# Qwen3.8-27B on M1 Max 32 GB

Backends: llama-server, mlx-lm · [Qwen3.8-27B MLX 4-bit on Hugging Face](https://huggingface.co/mlx-community/Qwen3.8-27B-4bit)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>0.988 / 0.945 / 100%</b><span>EvalPlus, effort medium — best base is the AtomicChat 3-bit GGUF, best plus is the ISTA 3-bit GGUF</span></div>
  <div class="kpi"><b>87 / 100</b><span>Mendel blind, effort medium, 4-bit GGUF f16 at reserve 16384; the same build re-run at reserve 8192 scored 76</span></div>
  <div class="kpi"><b>115K</b><span>deepest clean GGUF f16 KV depth, the 3-bit ISTA build, 9.7 tok/s there</span></div>
  <div class="kpi"><b>28K</b><span>MLX memory ceiling</span></div>
</div>
<!-- gen:model-kpis:end -->

Benchmarked 2026-08-25 (llama build 10621, mlx-lm 0.31.3); EvalPlus at effort medium re-scored 2026-08-28 with the calibrated budget; GGUF re-measured at f16 KV 2026-09-05 and run on Mendel 2026-09-06.

## Highlights

- **The first local model to finish the agent task.** On llama-server at
  f16 KV the 4-bit GGUF build scores 87 of 100 on the Mendel blind run:
  all eight libraries replaced, no bug defect, all three traps handled.
  Every earlier attempt, all on the MLX build, was partial or invalid.
  That row used a 16384-token harness reserve. The same build re-run on
  2026-09-08 at the current 8192 reserve scored 76 and failed trap A,
  so the 87 has not been reproduced under the harness we run today.
- **Three bits cost no measurable agent score here.** The ISTA 3-bit
  GGUF build scores 76.5 against the 4-bit build's 76 under the same
  reserve, and it fails trap A in the same shape. It also reaches
  114.7K of clean context where the 4-bit build reaches 65.5K.
- **The best quality score of any config measured here.** EvalPlus
  0.988 base on the AtomicChat 3-bit build and 0.945 plus on the ISTA
  3-bit build, both at 100% completion. The model to send hard problems
  to.
- **llama at f16 KV holds 15 tok/s to 49K**, the largest context this
  machine loads for it, at the MLX speed with almost twice the MLX
  window. MLX holds 14 to 17 tok/s across its whole window and OOMs
  between 28K and 30K.
- Weak point: the slowest model on this hardware (19.7 tok/s ceiling),
  with poor prompt processing (~123 tok/s).

## All configs — this model

<!-- gen:model-table:start -->
| # | Config | Max ctx | Gated by | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus |
|--:|---|--:|:--:|--:|--:|--:|
| 1 | Qwen3.8-27B, MLX 4-bit, unquantized KV, effort medium | 28k | mem | 17 → 15.3 | 22.0 GB | 0.982/0.939/100% |
| 2 | Qwen3.8-27B, MLX 4-bit, unquantized KV, effort low | 28k | mem | 17 → 15.3 | 22.0 GB | 0.976/0.927/100% |
| 3 | Qwen3.8-27B, GGUF Q4_K_M (bartowski), MTP, f16 KV, effort medium | 72k | mem | 20.0 → 13.7 | 25.4 GB | 0.982/0.939/100% |
| 4 | Qwen3.8-27B, GGUF IQ3_S-mtp (ISTA GSQ-RCO), MTP, f16 KV, effort medium | 128k | mem | 15.1 → 9.7 | 24.2 GB | 0.976/0.945/100% |
| 5 | Qwen3.8-27B, GGUF AD-IQ3_S (AtomicChat), MTP, f16 KV, effort medium | 104k | untested | 15.8 → 10.3 | 24.1 GB | 0.988/0.927/100% |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
**#1 — Qwen3.8-27B, MLX 4-bit, unquantized KV, effort medium.** Set the harness compaction threshold at ~26K.

```bash
mlx_lm.server --model mlx-community/Qwen3.8-27B-4bit \
  --reasoning-effort medium --port 8081
```

**#2 — Qwen3.8-27B, MLX 4-bit, unquantized KV, effort low.** Curve shared with the effort-medium row: same server, same weights. The reasoning effort changes the output, not the decode speed at a depth.

```bash
mlx_lm.server --model mlx-community/Qwen3.8-27B-4bit \
  --chat-template-args '{"reasoning_effort":"low"}' --prompt-cache-size 2 --port 8081
```

**#3 — Qwen3.8-27B, GGUF Q4_K_M (bartowski), MTP, f16 KV, effort medium.** pi id `qwen3.8-27b`. Re-measured 2026-09-08 at wired limit 25000: `-c 73728` serves, `-c 81920` OOMs at load, and decode and draft acceptance stay flat across the whole served range, so the boundary is memory alone. Clean depth 65578 at 13.7 tok/s. The older `-c 49152` was the ceiling at wired 24000. The EvalPlus score is still the MLX effort-medium run, carried by the shared-score rule; this build has no full EvalPlus of its own, so it cannot be read against the two 3-bit builds below, which do. Mendel blind at effort medium: 87/100 at reserve 16384 and window 49152, and 76/100 on the 2026-09-08 re-run at reserve 8192 and window 65536. The two are different configurations, not a repeat: the second failed trap A, which the first passed.

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 73728 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

**#4 — Qwen3.8-27B, GGUF IQ3_S-mtp (ISTA GSQ-RCO), MTP, f16 KV, effort medium.** A 3-bit build of the same model, revision `d562806`. Measured 2026-09-08 at wired limit 25000. Clean depth 114718 at 9.7 tok/s, the only measured ceiling of the three 3-bit builds tried; `-c 131072` serves. `n-max 3` is this build's own value, confirmed by a sweep: 4 and 6 were both slower. EvalPlus 0.976/0.945, one empty at budget 8192, its own score and not a carried one. Mendel blind at effort medium: 76.5/100, complete 8/8, window 114688. It failed trap A in the same shape as the 4-bit row's own re-run, so on this hardware the 3 bits cost no measurable agent score against a control measured the same way.

```bash
llama-server -hf ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 131072 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

**#5 — Qwen3.8-27B, GGUF AD-IQ3_S (AtomicChat), MTP, f16 KV, effort medium.** A second 3-bit build of the same model, revision `ca10ebc`. Measured 2026-09-08 at wired limit 25000. Its sweep reached 98338 at 10.3 tok/s and never hit a stop condition, so that depth is where the sweep ended and not a ceiling this machine refused to pass. `n-max 3` is this build's own value, confirmed by a sweep: 4 and 6 were both slower. EvalPlus 0.988/0.927, no empty completions, the best base score of any local build here and its own score, not a carried one. Its Mendel run is pending.

```bash
llama-server -hf AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 106496 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

**The window decides whether it finishes engineering tasks.** The
Mendel blind task needs about 46K of context. The GGUF at f16 holds 49K
at 15 tok/s and completed it: 87 of 100, 10 commits in 129 minutes, peak
context 45,705 of the 49,152 window, no loop; points went on a
lockfile-only install and on commit craft. It is the highest valid blind
score of any local model here; the next is Qwen3.6 GGUF at 63. The MLX
build holds 26K at the same speed, and every run on it was partial or
invalid: blind at effort medium 80 partial, blind at low 67.5 partial,
guided at low 34 with three server crashes, then a retry invalid after
three attempts, two of them Metal OOM crashes when the context grew past
the 26,624-token window. The llama row is the daily-driver candidate for
hard problems; its own EvalPlus score is pending, so its cell carries
the MLX score. The MLX row stays the low-memory option.

**The equilibrium moved to llama at f16 KV.** At q8_0 KV llama crossed
the 8 tok/s floor at about 19K, so MLX won on usable speed. At f16 KV
the same server decodes 20.0 tok/s at 4K and 15.0 at 49K, and 49152 is
the largest `-c` this machine loads for it (65536 and above OOM at
load). The four-problem smoke read level with q8_0, so the cache type
cost no answers. KV grows only about 0.8 GB per 16K tokens, because the
hybrid DeltaNet layers keep no KV; only the full-attention layers do,
which is why f16 fits.

**The quality score is fair, and it is the project's best.** The output
budget was calibrated to 8192 (its longest observed reasoning was about
2.6K tokens) and the three empty completions left from an earlier,
uncalibrated pass were regenerated. Zero empty completions remain. Full
data: [the benchmarks](../benchmarks/qwen3.8-27b.md).

**Medium reasoning effort is faster for a mechanical reason.** The MTP
head predicts medium-effort text better than xhigh-effort text, so
acceptance climbs from 58 to 61% to 73 to 81%. That is where the 21%
per-token gain comes from. The n-max 3 result repeated exactly on a
second run, and a second JS prompt matched within 0.3 tok/s, so the JS
penalty comes from the language, not the task.

**The old context maxima are withdrawn.** Every allocation figure for
this model was measured at the retired 27000 wired limit. Those tables
and the q8_0 KV curve are on [the historical page](../historical.md);
do not use them. The f16 ceiling at 49K is a load limit, not a decode
floor. MTP-on-MLX exists only as a CLI with no API, so it is
disqualified for harness use; its raw numbers stay in
[the benchmarks](../benchmarks/qwen3.8-27b.md).

**Open issue: prompt processing.** About 20 tok/s on short prompts and
only 123 to 127 tok/s on 1.5K to 4K prompts, low for this hardware
class. It is independent of MTP, so it looks like a Metal kernel limit
of the hybrid DeltaNet architecture in the current build. Worth
re-testing on future llama.cpp releases.

## Which to pick for a coding task

| need | config | tok/s | context |
|---|---|--:|--:|
| **Hard problems, agent work** | llama-server + MTP n=3, f16 KV, Q4_K_M bartowski, `-c 73728` | 20.0 shallow, 13.7 at 65.5K | 65.5K clean, `-c 73728` the largest that loads |
| **Long tasks** | llama-server + MTP n=3, f16 KV, IQ3_S-mtp ISTA, `-c 131072` | 15.1 shallow, 9.7 at 114.7K | 114.7K clean |
| **Low memory** | mlx_lm.server, unquantized KV | 14-17 across the window | to ~28K ceiling |

## Quality — EvalPlus HumanEval+

| config scored | pass@1 base | pass@1 plus | empty completions | completion |
|---|--:|--:|--:|--:|
| mlx_lm.server 4-bit, f16 KV, reasoning_effort=medium | 0.982 | 0.939 | 0/164 | 100% |

## Agentic quality — Mendel

<!-- gen:model-mendel:start -->
| test | config | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|---|--:|--:|--:|--:|--:|--:|---|
| blind-v1.1 | llama-f16-medium-ctx.48k | **87** | 8/8/done | 129.3 | 5,947k | 46k | 4 | 210 | 10 |  |
| guided-v2.1 | mlx-unquantized-low-ctx.26k † | **75** (raw 84) | 6/8/partial | 153.8 | 1,123k | 23k | 0 | 95 | 6 |  |
| blind-v1.0 | mlx-unquantized-default-ctx.26k † | **37.5** (raw 80) | 3/8/partial | 253.5 | 1,777k | 24k | 0 | 135 | 6 |  |
| blind-v1.1 | mlx-unquantized-low-ctx.26k † | **12.5** (raw 67.5) | 1/8/partial | 85.2 | 610k | 24k | 0 | 29 | 1 |  |
| guided-v3.0 | mlx-unquantized-low-ctx.?k † | **0** (raw 34) | 0/8/invalid | 261.3 | 1,254k | 30k | 0 | 48 | 0 |  |

The config cell names the server, the KV cache type, the thinking level and the harness window. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.

† a 26624-token window with a 16384-token output budget, our config arithmetic, not the model
<!-- gen:model-mendel:end -->

The full table and the rubric are on [the Mendel page](../benchmarks/mendel.md).

The MLX build gives a 26624-token window. That window stopped the low-effort run.

## Decode speed vs used context

The llama arm, in the shape of
[the comparison table](../comparison.md#decode-speed-vs-used-context-the-8-tok-s-usability-floor).
Slow creep 2026-09-08, wired limit 25000. Every row is f16 KV with the
MTP drafter at n-max 3, which each build's own sweep confirmed.

| config | @ 4-8K | @ 16K | @ 33K | @ 49K | capped by |
|---|--:|--:|--:|--:|---|
| **llama, Q4_K_M bartowski, `-c 73728`** | **20.0** | **16.1** | **16.4** | **15.0** | mem — swap grew at 73.7K; clean to 65578 at 13.7 tok/s |
| llama, AD-IQ3_S AtomicChat, `-c 106496` | 15.8 | 14.8 | 13.7 | 12.7 | untested — swept to 98338 at 10.3 tok/s and never hit a stop |
| llama, IQ3_S-mtp ISTA, `-c 131072` | 15.1 | 14.7 | 13.7 | 12.7 | mem — swap grew at 131.1K; clean to 114718 at 9.7 tok/s |

Wired memory 25.4 GB for the 4-bit build, 24.1 to 24.2 GB for the two
3-bit builds. The 4-bit build runs against the wired limit the whole
way; the 3-bit builds keep about 1 GB of headroom.

### MLX, its own creep (2026-08-29, wired limit 24000)

The MLX server ran its own depth ladder on a different day, so its
numbers keep their own table. Its cache is unquantized and the server
offers no KV option.

| depth | 8K | 16K | 22K | 24K | 26K | 28K | ~30K |
|---|--:|--:|--:|--:|--:|--:|---|
| `mlx-community/Qwen3.8-27B-4bit` | 17.1 | 16.4 | 10.23 | 14.79 | 15.19 | **15.29 — last stable** | Metal OOM |

The 22K reading is a dip that recovers by 24K, not a decline. At the
OOM the generation thread dies and `/health` still returns 200. Wired
memory 22.0 GB at 28K.

## Backend comparison: llama-server (GGUF) vs mlx-lm (MLX)

| variant | py tok/s | js tok/s | memory |
|---|--:|--:|--:|
| llama-server Q4_K_M, f16 KV, no MTP | 12.44 | 12.44 | ~21 GB RSS |
| llama-server Q4_K_M + MTP n=3, f16 KV | 16.93 | 15.73 | ~21 GB RSS |
| **mlx-lm MLX 4-bit, f16 KV, no MTP** | **19.69** | **19.58** | **15.5 GB peak** |

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

Shallow only. At depth the gap opens: 7.1 tok/s at 32K for q8_0 against
16.4 for f16, at almost the same wired memory.

---

Method: fresh server start per configuration; identical curl per run;
temperature 0. Full raw numbers in
[the benchmarks](../benchmarks/qwen3.8-27b.md). Cross-model picks on
[the comparison page](../comparison.md).
