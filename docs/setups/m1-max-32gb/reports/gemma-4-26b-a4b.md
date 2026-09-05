# Gemma-4-26B-A4B (MoE) on M1 Max 32 GB

Backends: llama-server, mlx-lm · [GGUF on Hugging Face](https://huggingface.co/unsloth/gemma-4-26b-a4b-it-GGUF) · [MLX 4-bit](https://huggingface.co/mlx-community/gemma-4-26b-a4b-it-4bit)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>51 tok/s</b><span>decode, shallow (MLX)</span></div>
  <div class="kpi"><b>70K</b><span>last stable depth, 12.8 tok/s (MLX)</span></div>
  <div class="kpi"><b>0.713 / 0.701</b><span>EvalPlus, thinking on</span></div>
  <div class="kpi"><b>46/164</b><span>empty: thinking non-convergence</span></div>
</div>
<!-- gen:model-kpis:end -->

Benchmarked 2026-08-25 (llama build 10621, unsloth UD-Q4_K_XL + MTP draft, wired limit 24000); EvalPlus scored 2026-08-29 at q8_0 KV; GGUF re-measured at f16 KV 2026-09-05 (run 9). The f16 re-score is a run 10 item.

## Highlights

- **The fastest depth curve measured on this machine**, now on llama at
  f16 KV: 60.3 tok/s at 4K, still 17.3 at 197K, the largest context this
  machine loads for it (run 9). MLX: 51 tok/s at 4K, 12.8 at 70K.
- **Two slots at f16 KV hold 101K each** (run 10): 66.6 tok/s at 4K and
  33.6 at 82K on one slot with the other idle, in 25.3 GB wired, no
  speed or memory stop before the slot window. The old "two agents get
  184K each" was an allocation at q8_0, not a measured depth.
- Weak point: wired memory sits at 25.6 GB on that config, above the
  24000 limit, flat but with no headroom for anything beside it.
- Weak point: EvalPlus 0.713/0.701 with 46/164 (~28%) empty — its thinking
  often never converges, the worst convergence rate of any scored model.

## All configs — this model

<!-- gen:model-table:start -->
| # | Config | Max ctx | Gated by | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus |
|--:|---|--:|:--:|--:|--:|--:|
| 1 | Gemma-4-26B-A4B, MLX | 70k | mem | 51 → 12.8 | 20.0 GB | 0.713/0.701 |
| 2 | Gemma-4-26B-A4B, GGUF, MTP f16 | 197k | mem | 60.3 → 17.3 | 25.6 GB | 0.713/0.701 |
| 3 | Gemma-4-26B-A4B, GGUF, MTP f16, 2 slots | 2x82k | mem | 66.6 → 33.6 | 25.3 GB | 0.713/0.701 |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
**#1 — Gemma-4-26B-A4B, MLX.**

```bash
mlx_lm.server --model mlx-community/gemma-4-26b-a4b-it-4bit \
  --prompt-cache-size 2 --port 8081
```

**#2 — Gemma-4-26B-A4B, GGUF, MTP f16.** pi id `gemma-4-26b-a4b`. Re-measured 2026-09-05 at f16 KV, the run 9 pick: 212992 is the largest `-c` that loads; 229376 and 262144 OOM at load. Wired sits above the 24000 limit but stays flat. The EvalPlus score was measured at q8_0 KV; the f16 re-score is a run 10 item.

```bash
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias gemma-4-26b-a4b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 2 --parallel 1 \
  -ngl 999 -fa on -c 212992 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

**#3 — Gemma-4-26B-A4B, GGUF, MTP f16, 2 slots.** pi id `gemma-4-26b-a4b-2x`. Measured 2026-09-05 (run 10) at f16 KV: 202752 is the largest `-c` that serves a real 4096-token completion (208896 and above fail on compute buffers or at load), 101376 per slot. One slot swept with the other loaded and idle: no speed or memory stop before the slot window; the deepest row is 82K at 33.6 tok/s. The EvalPlus score was measured at q8_0 KV on the single-slot config.

```bash
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias gemma-4-26b-a4b-2x --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 2 --parallel 2 \
  -ngl 999 -fa on -c 202752 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

**Back in the running as a secondary model (run 9).** The model was
parked on 2026-08-30 after the quality gate: 28% empty completions and
an agentic run stopped in a thinking loop. Run 9 changed its llama row
from 23.5 to 8 tok/s gated by speed at 24K to 60.3 to 17.3 tok/s at
197K, by moving the KV cache to f16. Served at 128K on purpose it keeps
the machine usable and finishes simple tasks faster than a smarter,
slower model. The EvalPlus score on this page was measured at q8_0 KV.
Run 10 re-scores it at f16, thinking on; a base pass@1 at or above
0.800 sends it to Mendel blind in the same run.

**f16 KV is the pick, and q8_0 was the speed problem.** The run 9 short
creep read 6.3 tok/s at 32K for q8_0 against 45.9 for f16, at almost the
same wired memory. The full f16 creep then held above 17 tok/s to
197K; 212992 is the largest `-c` that loads, 229376 and 262144 OOM at
load. The four-problem smoke read level between the two types, both
failing the same hard problem the same way. The older claim that f16
did not fit came from the published `-c 262144`, which does not load
at either type. q8_0 also lowered js draft acceptance from 81% to 68%.

**llama is now the deep config; MLX the small one.** The MLX build
stays fast to about 68K, then swings between 13 and 24 tok/s at 62-70K
before OOMing at about 72K (limit 24000, slow creep, 2026-08-29; 20.0 GB
gfx-resident at the last stable depth), in 20 GB. llama at f16 holds
three times that depth in 25.6 GB wired, flat.

**Thinking is binary here.** Gemma 4 has trained-in reasoning
(`<|think|>`) toggled by `enable_thinking` in the chat template. It is
on/off, default off, with no graded effort levels. The speed numbers on this
page were measured with thinking off. Thinking costs only ~3 tok/s, so there
is little reason to avoid it on quality grounds.

**Quality is scored, and the convergence problem is real.** Calibration
alone showed that at a 30K output cap, 2 of 10 sample problems never
finished reasoning at all. The full 164-problem run confirmed it at scale:
46/164 (~28%) empty completions, well above the calibration sample's rate,
for a final EvalPlus of 0.713/0.701. This is model behavior, not a harness
limit — every empty completion still had budget left in the 30000-token
cap. Its smaller sibling, the 12B, does it more often — counterintuitively.

A deep-fill decode check on the llama config is still pending.

## Which to pick for a coding task

| need | config | tok/s | context |
|---|---|--:|--:|
| **Max context** | llama-server + MTP n=2, f16 KV, `-c 212992`, 1 slot | 60.3 at 4K, 17.3 at 197K | 197K measured (run 9) |
| **Max js speed** | f16 KV at small context (32K) | 74.8 / 71.6 | 32K |
| **Two agents** | `--parallel 2 -c 202752`, f16 KV | 66.6 at 4K, 33.6 at 82K, one slot | 2×101K allocated, 82K measured (run 10) |

## Quality — EvalPlus HumanEval+

| config scored | pass@1 base | pass@1 plus | empty completions |
|---|--:|--:|--:|
| mlx_lm.server 4-bit, thinking on, budget 30000 | 0.713 | 0.701 | 46/164 (~28%) |

Score is shared with the llama+MTP config at the same quant (both serve the
same weights).

## Decode speed vs used context (llama at limit 25000, 2026-08-28; mlx re-tested at limit 24000, slow creep, 2026-08-29)

| depth | llama+MTP q8 | MLX (gemma-4-26b-a4b-it-4bit) |
|---|--:|--:|
| 4K | 23.5 | 51.1 |
| 16K | 11.2 | 43.5 |
| 24.5K | 7.97 — under the 8 tok/s floor | 39.6 |
| 33K | | 35.6 |
| 49K | | 28.8 |
| 60K | | 24.96 |
| 62K | | 13.44 |
| 64K | | 23.91 |
| 66K | | 13.07 |
| 68K | | 23.08 |
| **70K** | | **12.83 — last stable, limit 24000** |
| ~72K | | Metal OOM — ceiling ~70-72K at limit 24000 |

llama RSS at floor depth (24.5K, q8_0 KV, 32K alloc): 15.4 GB.

## Context (n-max 2, q8_0 KV, limit 24000 — superseded by the f16 creep of run 9)

| -c | slots | result | RSS |
|---|---|---|--:|
| 262,144 | 1 (f16 KV) | Metal OOM — f16 no longer fits | – |
| **262,144** | **1** | **OK, 62.4/53.3 tok/s — full window (256-tok verified)** | **19.3 GB** |
| 327,680 | 2×160K | OK, 67.6/52.7 tok/s | 20.1 GB |
| **376,832** | **2×184K** | **OK, 58.4/56.5 tok/s — two-slot max (256-tok verified)** | **20.4 GB** |
| 385,024 | 2×188K | Metal OOM | – |
| 393,216 | 2×192K | Metal OOM | – |

## MTP draft depth sweep (32K, f16 KV)

Thinking ON (chat endpoint, `enable_thinking: true`, 1024 tokens):

| --spec-draft-n-max | py tok/s | py accept | js tok/s | js accept |
|---|--:|--:|--:|--:|
| **2** | **71.88** | **84%** | **69.25** | **78%** |
| 3 | 67.94 | 74% | 64.90 | 69% |
| 4 | 63.97 | 69% | 61.00 | 65% |

Thinking OFF (sub-agent / fast mode): peak 74.8 py / 71.6 js, also at n-max 2.
Full thinking-off tables in
[the benchmarks](../benchmarks/gemma-4-26b-a4b.md).

---

Method: warmup before every measurement; identical prompts across models;
temp 0. Raw numbers in
[the benchmarks](../benchmarks/gemma-4-26b-a4b.md). Cross-model picks on
[the comparison page](../comparison.md).
