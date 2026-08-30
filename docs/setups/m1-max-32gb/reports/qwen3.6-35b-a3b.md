# Qwen3.6-35B-A3B (MoE) on M1 Max 32 GB

Backends: llama-server, mlx-lm · [Qwen3.6-35B-A3B-MTP GGUF on Hugging Face](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>53.3 tok/s</b><span>decode, shallow (MLX)</span></div>
  <div class="kpi"><b>0.939 / 0.921</b><span>EvalPlus, thinking on</span></div>
  <div class="kpi"><b>90K</b><span>GGUF depth to the 8 tok/s floor</span></div>
  <div class="kpi"><b>34.9K</b><span>MLX memory ceiling</span></div>
</div>
<!-- gen:model-kpis:end -->

Benchmarked 2026-08-25 (llama build 10621, unsloth UD-Q4_K_XL, embedded MTP, wired limit 24000); EvalPlus corrected 2026-08-29.

## Highlights

- **The speed king: 68 py / 74 js tok/s.** 1.5× Gemma-12B, 4× dense Qwen3.8.
- **The deep-context king.** llama never crosses the 8 tok/s floor inside its
  whole 96K window — still 8.1 tok/s at 90K.
- **Second-best quality measured here: 0.939 / 0.921 EvalPlus.** Only
  Qwen3.8 scores higher, and Qwen3.8 is four times slower.
- Weak point: decode falls to ~17 tok/s past ~30K used, and there is no
  thinking-off score yet, so sub-agent use is unmeasured.

## All configs — this model

<!-- gen:model-table:start -->
| Config | Max ctx | Gated by | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus |
|---|--:|:--:|--:|--:|--:|
| Qwen3.6-35B-A3B, GGUF, MTP q8, thinking on | 90k | speed | 44 → 8.1 | 22.8 GB | 0.939/0.921 |
| Qwen3.6-35B-A3B, MLX, thinking on | 34.9k | mem | 53.3 → 41.5 | 22.1 GB | 0.939/0.921 |
<!-- gen:model-table:end -->

## Configs

**llama-server + MTP n=3, q8_0 KV, one 96K slot.** 62-68 tok/s shallow, and
it stays usable all the way to 90K. pi id `qwen3.6-35b-a3b`.

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 98304 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

## Model details and findings

**The first quality score was broken, and the correction moved it further
than any other model's.** An early pass capped output at 3072 tokens. This
model's reasoning exhausted that budget on 38% of the problems, and each
empty completion scores as a hard failure, so the first score was a floor
rather than a measurement. The fix regenerated the 56 missing or empty
completions at the calibrated budget of 26624, which is safe because
temperature 0 is deterministic. The prediction held — its base model reports
73.4 SWE-bench Verified, and the real capability was far higher than the
flawed cap suggested. The deflated numbers are on
[the historical page](../historical.md); do not use them. Full data:
[the benchmarks page](../benchmarks/qwen3.6-35b-a3b.md).

**The wired limit cost this model most of its context.** The limit is now
24000. At 27000 the machine became too slow for normal use; at 24000 context
capped at 40K. Under the current limit, single-session context reaches 96K.
The larger single-slot and two-agent configs that the 27000 limit allowed are
retired; their numbers are on
[the historical page](../historical.md). Raise the limit
again only for a dedicated session.

**Deep fill is the accepted trade.** Decode collapses to ~17 tok/s once ~30K+
tokens are in use — measured at 16.7 tok/s with 31,365 used tokens, while
prompt processing stayed healthy at 556 tok/s. This is accepted, because the
initial part of a session is where speed matters most. A deep-fill check at
96K is still pending.

**MoE on MLX is the faster curve, but it cannot hold the depth.** MLX is 2.2×
faster than llama at 33K, with 18.7 GB RSS, and then dies between 37K and
41K. llama at 22.8 GB RSS never OOMs inside its window. This is the whole
project's pattern in one model.

MTP acceptance does not degrade at the maximum (py 80%, js 90%). KV is only
~19 KB/token, so decode speed does not fall as *allocated* context grows —
only as used context grows. Prompt processing is healthy on this architecture
(62–93 tok/s even on tiny prompts, against ~22 for dense Qwen3.8). A no-MTP
baseline is still in progress. Sweep prompts are synthetic continuations, so
MTP numbers there read below the py/js bench.

## Which to pick for a coding task

| need | config | tok/s (py/js) | context |
|---|---|--:|--:|
| **Max context** | llama-server + MTP n=3, q8_0 KV, 1 slot | 62.0 / 67.7 | 96K |
| **Max speed** | same config (near-empty context) | 68 / 74 | same |
| **Multi-agent** | untested at limit 25000 (at 24000: OOM even at 2×20K) | – | – |

## Quality — EvalPlus HumanEval+

| config scored | budget | pass@1 base | pass@1 plus | empty completions |
|---|--:|--:|--:|--:|
| llama-server + MTP, thinking on | 26624 | **0.939** | **0.921** | 5/164 (~3%) |

The 5 empty completions are a real model limit, not a harness artifact — they
stay empty at the full budget.

## Decode speed vs used context (llama at limit 25000, 2026-08-28; mlx re-tested at limit 24000, slow creep, 2026-08-29)

| depth | llama+MTP q8 (96K alloc) | MLX (Qwen3.6-35B-A3B-4bit) |
|---|--:|--:|
| 4K | 44.5 | 53.3 |
| 16K | 30.1 | 49.6 |
| 33K | 18.8 | 42.2 |
| 37K | | 42.0 |
| ~41K | | Metal OOM — ceiling 37-41K |
| 49K | 13.5 | |
| 65K / 82K / 90K | 10.7 / 8.8 / 8.1 | |

## Context ramp (n-max 3, q8_0 KV, limit 24000 — current)

| -c | result | tok/s | RSS |
|---|---|--:|--:|
| **98,304** | **OK — maximum (256-tok verified)** | **62.0 / 67.7** | **22.9 GB** |
| 106,496 | Metal OOM | – | – |
| 114,688 | Metal OOM | – | – |
| 131,072 | Metal OOM | – | – |

## MTP draft depth sweep (32K, f16 KV)

| --spec-draft-n-max | py tok/s | py accept | js tok/s | js accept |
|---|--:|--:|--:|--:|
| 2 | 67.75 | 88% | 70.67 | 94% |
| **3** | **68.21** | **82%** | **73.53** | **90%** |
| 4 | 63.53 | 73% | 69.42 | 81% |

---

Method: warmup before every measurement; identical prompts across models;
temp 0. Raw numbers in
[the benchmarks](../benchmarks/qwen3.6-35b-a3b.md). Cross-model picks on
[the comparison page](../comparison.md).
