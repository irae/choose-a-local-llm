# Gemma-4-12B-it on M1 Max 32 GB

Backends: llama-server, LM Studio MLX engine · [GGUF on Hugging Face](https://huggingface.co/unsloth/gemma-4-12b-it-GGUF) · [MLX 4-bit](https://huggingface.co/lmstudio-community/gemma-4-12B-it-MLX-4bit)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>245K</b><span>llama f16 depth, 8.86 tok/s</span></div>
  <div class="kpi"><b>131K</b><span>LM Studio ceiling, 23.23 tok/s</span></div>
  <div class="kpi"><b>0.976 / 0.939 / 100%</b><span>EvalPlus, thinking off (GGUF); LM Studio MLX 0.909 / 0.872 / 100%</span></div>
  <div class="kpi"><b>4×49K</b><span>llama f16 slots, one swept, 25.1 GB</span></div>
</div>
<!-- gen:model-kpis:end -->

Benchmarked 2026-08-25 (llama build 10621, unsloth Q4_K_XL); both depth curves re-measured 2026-09-04 at wired limit 24000; EvalPlus scored on the LM Studio MLX container 2026-09-03 and on the GGUF quant 2026-09-05 (run 9), thinking off; the two do not share a score.

## Highlights

- **The usable agent configuration is llama-server, f16 KV, no MTP
  drafter, thinking off.** It decodes 24.64 tok/s at 4K and 8.86 at
  245K, so it reaches the model's own 262,144 window and stays above the
  8 tok/s floor. Wired memory holds flat at 13.9 GB. On the Mendel
  guided run (run 9, no drafter) it replaced 3 of 8 libraries and
  scored 37.5 capped, ending on the model budget after three nudges.
- **The GGUF quant scores 0.976 / 0.939 with thinking off, all 164
  answers delivered (run 9).** That is 0.067 above the LM Studio MLX
  entry's 0.909 / 0.872, so the two quants do not share a score here.
  The LM Studio entry keeps the fastest curve, 34.19 tok/s at 4K down
  to 23.23 at 131K, in 17.2 GB wired at that depth (run 10), and it is
  not usable for multi-turn tool work: on the same tool task, with
  thinking off, it looped on the thought channel for 2679 lines and
  committed nothing.
- **The KV type sets the depth on this model, not the weights.** With
  q8_0 KV the same server drops under the 8 tok/s floor by 16K. With f16
  KV it is 3.2x faster at 16K and stays usable eight times deeper.
- **Four slots at f16 KV hold 49K each** (run 10): 42.9 tok/s at 4K and
  27.7 at 49K on one slot with the other three idle, in 25.1 GB wired,
  before swap growth ended the sweep. The old "four 256K slots in
  16.9 GB" was an allocation at q8_0, not a measured depth.

## All configs — this model

<!-- gen:model-table:start -->
| # | Config | Max ctx | Gated by | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus |
|--:|---|--:|:--:|--:|--:|--:|
| 1 | Gemma-4-12B, MLX³, thinking off | 131k | mem | 34.19 → 23.23 | 17.2 GB | 0.909/0.872/100% |
| 2 | Gemma-4-12B, GGUF, f16 KV, no drafter, thinking off | 245k | mem | 24.64 → 8.86 | 13.9 GB | 0.976/0.939/100% |
| 3 | Gemma-4-12B, GGUF, MTP q8, thinking off | 16k | speed | 13.8 → 6.5 | 10.5 GB | 0.976/0.939/100% |
| 4 | Gemma-4-12B, GGUF, MTP f16, 4 slots, thinking off | 4x49k | mem | 42.9 → 27.7 | 25.1 GB | 0.976/0.939/100% |

Retired entries: Gemma-4-12B, LM Studio entry google/gemma-4-12b — thinking-on repetition loop; entry gone from the model store ([details](../benchmarks/gemma-4-12b-it.md#the-retired-entry)).
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
**#1 — Gemma-4-12B, MLX³, thinking off.** LM Studio entry `gemma-4-12b-it-mlx` (`lmstudio-community/gemma-4-12B-it-MLX-4bit`): thinking is off and the API cannot turn it on (probed 2026-09-04). Single-turn work only — in multi-turn tool work it loops on the thought channel.

```bash
~/.cache/lm-studio/bin/lms server start --port 8081
~/.cache/lm-studio/bin/lms load gemma-4-12b-it-mlx --parallel 4 --gpu max -y
```

**#2 — Gemma-4-12B, GGUF, f16 KV, no drafter, thinking off.** pi id `gemma-4-12b`. Measured 2026-09-04 at wired limit 24000; wired memory stays flat from load to the trained window. The trained window ends at 262,144; the deepest step measured is 245K, still above the floor.

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 262144 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

**#3 — Gemma-4-12B, GGUF, MTP q8, thinking off.** The q8 KV variant with the MTP drafter. Re-measured 2026-09-03 under wired limit 24000: no OOM at load, unlike the qwen3.6 MTP dagger sweep.

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 4 --parallel 1 \
  -ngl 999 -fa on -c 262144 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

**#4 — Gemma-4-12B, GGUF, MTP f16, 4 slots, thinking off.** pi id `gemma-4-12b-4x`. Measured 2026-09-05 (run 10) at f16 KV: 655360 is the largest `-c` that serves a real completion (688128 loads but fails on compute buffers at the first depth step), 163840 per slot. One slot swept with the other three loaded and idle: swap grew at 66K, so the last clean row is 49K at 27.7 tok/s. The machine ran this sweep with free memory near zero and heavy compaction on every step, with swap already in use at session start; the row is honest to that state and a re-measure after a reboot may read deeper.

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b-4x --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 4 --parallel 4 \
  -ngl 999 -fa on -c 655360 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

**The runtime decides what this model can do.** mlx-lm cannot serve it:
it lacks the `gemma4_unified` model type. LM Studio's engine supports
that type and gives the flattest decode curve on this machine.
llama-server serves the GGUF quant, and it is the only path that
survives multi-turn tool work. Serving from the `lms` CLI is an approved
exception to the no-GUI rule — every step runs command-line only, and
the model store is shared with the app.

**The two backends fail differently, and that decides the pick.**
llama-server allocates its KV from `-c`, so wired memory stays flat at
59% of the limit from load to the trained window; it runs out of model,
not of machine. The LM Studio engine grows into the cap instead: wired
reaches 87% of the limit past 131K, and the sweep stops on swap growth.
So LM Studio is faster at every depth it survives — 1.4x at 4K, 1.8x at
131K — and llama-server is the one that finishes.

**The chat path costs nothing on llama-server.** 24.68 tok/s against
24.64 at 4K, and 22.59 against 22.66 at 16K. The raw-prompt curve below
transfers to harness use.

**The context ceiling of the GGUF is the model, not the machine.** GGUF
metadata gives a trained context of 262,144, and a sliding window of
1024 on 5 of every 6 layers, so KV grows only ~1 GB per 64K tokens. No
Metal OOM appeared at any size tested. Context limits are
mode-independent, since KV is preallocated by `-c`. Four slots at f16
load at 163,840 each (run 10, `-c 655360`); the next step up fails on
compute buffers at the first real request, which a trivial warmup does
not show.

**The context window cannot be pinned on the MLX path.** The engine
ignores every context-length setting for this model: CLI flags, REST
body, per-model config file, app default. Auto-fit computes the window
from the GPU wired limit and gives 158,464 tokens at a 24000 limit.
`--parallel` is the one load knob that works.

**The two quants carry their own scores.** The GGUF quant scored
0.976 / 0.939 thinking off in run 9, 0.067 above the LM Studio MLX
container's 0.909 / 0.872, so the shared-score rule does not apply to
this pair. A thinking-on score is pending: the earlier one was
measured on a retired entry and moved to
[the historical page](../historical.md).

**Thinking on is a pitfall of this model, on both backends.** The
evidence, the retired LM Studio entry, and the chat-template history are
on [the benchmarks page](../benchmarks/gemma-4-12b-it.md#the-retired-entry).

## Decode speed vs used context (2026-09-04, wired limit 24000)

Thinking off on every column. llama-server: raw `/completion`, with the
allocation always above the deepest step measured. LM Studio: chat
endpoint, `--parallel 4`. Pause 25 s per step.

| used tokens | llama f16, no drafter | llama q8 + MTP | LM Studio MLX engine |
|---|--:|--:|--:|
| 4K | 24.64 | 13.82 | 34.19 |
| 8K | 24.05 | 8.74 | |
| 16K | 22.66 | **6.53 — under the 8 tok/s floor** | 32.05 |
| 33K | 20.58 | | 30.59 |
| 65K | 17.42 | | 27.08 |
| 98K | 14.91 | | 24.52 |
| 131K | 12.67 | | **23.23 — last stable; memory gates it here** |
| 147K | 11.72 | | |
| 180K | 10.72 | | |
| 213K | 9.69 | | |
| **245K** | **8.86 — deepest step inside the trained window** | | |

Cells are blank past a column's cap.

---

Method: fresh server start per configuration; identical curl per run;
temperature 0. Full raw numbers, the MTP sweeps and the thinking-on
evidence in [the benchmarks](../benchmarks/gemma-4-12b-it.md).
Cross-model picks on [the comparison page](../comparison.md).
