# Qwen3.6-35B-A3B (MoE) on M1 Max 32 GB

Backends: llama-server, mlx-lm · [Qwen3.6-35B-A3B-MTP GGUF on Hugging Face](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>53.3 tok/s</b><span>decode, shallow (MLX)</span></div>
  <div class="kpi"><b>0.939 / 0.921 / 97%</b><span>EvalPlus, thinking on</span></div>
  <div class="kpi"><b>8K</b><span>GGUF clean depth before memory compaction (q8_0, -c 49152)</span></div>
  <div class="kpi"><b>37K</b><span>MLX last stable depth (OOM ~41K)</span></div>
</div>
<!-- gen:model-kpis:end -->

Benchmarked 2026-08-25 (llama build 10621, unsloth UD-Q4_K_XL, embedded MTP, wired limit 24000); EvalPlus corrected 2026-08-29, thinking off scored 2026-09-06; GGUF re-measured with the slow creep 2026-09-04.

## Highlights

- **The speed king: 68 py / 74 js tok/s.** 1.5× Gemma-12B, 4× dense Qwen3.8.
- **Second-best quality measured here, and thinking off is better on
  base.** Thinking on 0.939 / 0.921 / 97%; thinking off 0.951 / 0.915 /
  100% with no empty completion, in 15 minutes. Only Qwen3.8 scores
  higher, and Qwen3.8 is four times slower.
- **The deep-context claim did not survive the slow creep.** The
  published `-c 98304` OOMs at load under the 24000 limit; 49152 loads
  with wired memory at 25 GB, and macOS compacts from 16K on without
  recovering. The last clean row is 8K at 43.8 tok/s. The old 90K figure
  came from the fast sweep and is on the historical page.
- Weak point: on the agent task it scores 63 blind and 83 guided at
  thinking high, with one critical trap hit blind; no thinking-off
  agent row exists yet, and the 8K clean depth is too small for one.

## All configs — this model

<!-- gen:model-table:start -->
| # | Config | Max ctx | Gated by | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus |
|--:|---|--:|:--:|--:|--:|--:|
| 1 | Qwen3.6-35B-A3B, MLX, thinking on | 37k | mem | 53.3 → 42.0 | 18.7 GB | 0.939/0.921/97% |
| 2 | Qwen3.6-35B-A3B, GGUF, MTP q8, thinking on | 8k | mem | 36.4 → 43.8 | 25.0 GB | 0.939/0.921/97% |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
**#1 — Qwen3.6-35B-A3B, MLX, thinking on.**

```bash
mlx_lm.server --model mlx-community/Qwen3.6-35B-A3B-4bit \
  --prompt-cache-size 2 --port 8081
```

**#2 — Qwen3.6-35B-A3B, GGUF, MTP q8, thinking on.** pi id `qwen3.6-35b-a3b`. Measured 2026-09-04 with the slow creep: q8_0 KV stays, because f16 does not load even at 40960. The published `-c 98304` and 65536 OOM at load; 49152 loads. Wired sits at 25 GB, over the limit, and memory compaction starts by 16K without recovering, so the last clean row is 8K. That row is faster than 4K because the MTP drafter warms up over the first rows.

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 49152 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

**The first quality score was broken, and the correction moved it
further than any other model's.** An early pass capped output at 3072
tokens. This model's reasoning exhausted that budget on 38% of the
problems, and each empty completion scores as a hard failure, so the
first score was a floor rather than a measurement. The fix regenerated
the 56 missing or empty completions at the calibrated budget of 26624,
which is safe because temperature 0 is deterministic. The deflated
numbers are on [the historical page](../historical.md); do not use
them. Full data: [the benchmarks page](../benchmarks/qwen3.6-35b-a3b.md).

**Thinking off scores higher on base and loses nothing that matters.**
0.951 base against 0.939, 0.915 plus against 0.921, and the five
thinking-on empties are gone. The five empties with thinking on stay
empty at the full budget, so they are a real model limit.

**The wired limit and the slow creep cost this model its depth.** At
27000 the machine became too slow for normal use. At 24000 the
published `-c 98304` and 65536 OOM at load; 49152 loads, but wired sits
at 25 GB, over the limit, and memory compaction starts by 16K without
recovering. The last clean row is 8K, faster than 4K because the MTP
drafter warms up over the first rows. The larger single-slot and
two-agent configs of the old limit, and the 90K fast-sweep curve, are
on [the historical page](../historical.md). f16 KV does not load even
at 40960, so q8_0 stays.

**MoE on MLX is the faster curve, but it cannot hold the depth.** MLX is
2.2× faster than llama at 33K, with 18.7 GB RSS, and then dies between
37K and 41K. This is the whole project's pattern in one model.

MTP acceptance does not degrade at the maximum (py 80%, js 90%). KV is
only about 19 KB per token, so decode speed does not fall as allocated
context grows, only as used context grows. Prompt processing is healthy
on this architecture (62 to 93 tok/s even on tiny prompts, against
about 22 for dense Qwen3.8). Sweep prompts are synthetic continuations,
so MTP numbers there read below the py/js bench.

## Which to pick for a coding task

| need | config | tok/s (py/js) | context |
|---|---|--:|--:|
| **Max speed** | llama-server + MTP n=3, q8_0 KV, `-c 49152`, 1 slot, near-empty context | 68 / 74 | 8K clean; compaction past it |
| **Max depth** | mlx_lm.server 4-bit | 53.3 at 4K, 42.0 at 37K | 37K, OOM at about 41K |
| **Multi-agent** | untested at limit 24000 (OOM even at 2×20K) | – | – |

## Quality — EvalPlus HumanEval+

| config scored | budget | pass@1 base | pass@1 plus | empty completions | completion |
|---|--:|--:|--:|--:|--:|
| llama-server + MTP, q8_0 KV, `-c 49152`, thinking off | 8192 | **0.951** | 0.915 | 0/164 | 100% |
| llama-server + MTP, thinking on | 26624 | 0.939 | **0.921** | 5/164 | 97% |

## Agentic quality — Mendel

| test | config | score | worst defect | status |
|---|---|--:|---|---|
| guided | llama-server, thinking high | **83/100** | – | complete, 8/8 libraries |
| blind | llama-server, thinking high | **63/100** | critical | complete, 8/8 libraries |

The full table and the rubric are on [the Mendel page](../benchmarks/mendel.md).

## Decode speed vs used context (llama slow creep at `-c 49152`, 2026-09-04; mlx slow creep, 2026-08-29; limit 24000)

| depth | llama+MTP q8_0 | MLX (Qwen3.6-35B-A3B-4bit) |
|---|--:|--:|
| 4K | 36.4 | 53.3 |
| **8K** | **43.8 — last clean row; compaction from 16K** | |
| 16K | 31.0 | 49.6 |
| 33K | 19.6 | 42.2 |
| **37K** | | **42.0 — last stable** |
| ~41K | | Metal OOM |

Wired memory: 25.0 GB on llama at `-c 49152`, 18.7 GB on MLX at 37K.
The llama rows past 8K ran under memory compaction and are not clean
readings.

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
