# Qwen3.6-35B-A3B (MoE) on M1 Max 32 GB

Backends: llama-server, mlx-lm · [Qwen3.6-35B-A3B-MTP GGUF on Hugging Face](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>69.1 tok/s</b><span>decode, shallow (GGUF, f16 KV)</span></div>
  <div class="kpi"><b>41K</b><span>GGUF f16 KV depth, 52.6 tok/s, no ceiling found inside the largest `-c` that loads</span></div>
  <div class="kpi"><b>0.951 / 0.915 / 100%</b><span>EvalPlus, thinking off (GGUF q8_0), 0 empty</span></div>
  <div class="kpi"><b>41K</b><span>MLX last stable depth, 37.4 tok/s, then a Metal OOM</span></div>
</div>
<!-- gen:model-kpis:end -->

Benchmarked 2026-08-25 (llama build 10621, unsloth UD-Q4_K_XL, embedded MTP); EvalPlus corrected 2026-08-29, thinking off scored 2026-09-06; all three arms re-measured with the slow creep at wired limit 25000 on 2026-09-06 and 2026-09-07; the thinking-off guided rows run the same days.

## Highlights

- **The speed king: 68 py / 74 js tok/s.** 1.5× Gemma-12B, 4× dense Qwen3.8.
- **Second-best quality measured here, and thinking off is better on
  base.** Thinking on 0.939 / 0.921 / 97%; thinking off 0.951 / 0.915 /
  100% with no empty completion, in 15 minutes. Only Qwen3.8 scores
  higher, and Qwen3.8 is four times slower.
- **The KV type is a window-against-speed trade on this model.** At
  wired limit 25000 the q8_0 arm serves `-c 98304` and creeps clean to
  82K at 9.24 tok/s before the speed floor; the f16 arm loads only
  `-c 40960` and holds 52.6 tok/s at 41K, 2.8x the q8_0 speed at 33K.
  Every larger `-c` on either arm loads and then OOMs on the first real
  request. On the agent task the q8_0 arm scores 63 blind and 83 guided
  at thinking high, and 62.5 guided at thinking off on the 81920 window
  its creep supports, against 46.5 for the same config on a 49152
  window that compacted twelve times.
- **The window decides the score, not only the model.** The same
  config, the same prompt and the same level scored 16 points apart on
  two windows. A harness window comes from the config's own creep, and
  a row's config note names it.

## All configs — this model

<!-- gen:model-table:start -->
| # | Config | Max ctx | Gated by | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus | Mendel |
|--:|---|--:|:--:|--:|--:|--:|--:|
| 1 | Qwen3.6-35B-A3B, MLX, unquantized KV, thinking on | 41k | mem | 55.1 → 37.4 | 24.6 GB | 0.939/0.921/97% | pending |
| 2 | Qwen3.6-35B-A3B, GGUF, MTP, q8_0 KV, thinking on | 82k | speed | 36.5 → 9.2 | 25.8 GB | 0.939/0.921/97% | 63 |
| 3 | Qwen3.6-35B-A3B, GGUF, MTP, f16 KV, thinking on | 41k | mem | 69.1 → 52.6 | 25.1 GB | 0.939/0.921/97% | pending |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
**#1 — Qwen3.6-35B-A3B, MLX, unquantized KV, thinking on.** Measured 2026-09-06 at wired limit 25000: last stable depth 40982 at 37.4 tok/s, then the generation thread died on a Metal OOM at the next step while the models endpoint kept answering. Wired memory grows with the session and peaked at 24.6 GB. At wired 24000 the same server stopped at 37K in 18.7 GB.

```bash
mlx_lm.server --model mlx-community/Qwen3.6-35B-A3B-4bit \
  --prompt-cache-size 2 --port 8081
```

**#2 — Qwen3.6-35B-A3B, GGUF, MTP, q8_0 KV, thinking on.** pi id `qwen3.6-35b-a3b`. Measured 2026-09-06 and confirmed 2026-09-07 at wired limit 25000 with a real completion as the ceiling test: `-c 98304` serves; every `-c` from 100864 up loads and then OOMs on the first real request. The creep runs clean to 81958 tokens at 9.24 tok/s and crosses the 8 tok/s floor at 98K, with zero swap growth on a fresh server. This is the arm with the window: the f16 KV row below is 2.8x faster at 33K and loads only `-c 40960`. Mendel at thinking off, guided: 62.5/100 on the 81920 window, complete, against 46.5 for the same config on a 49152 window with twelve compactions.

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 98304 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

**#3 — Qwen3.6-35B-A3B, GGUF, MTP, f16 KV, thinking on.** Measured 2026-09-06 and confirmed 2026-09-07 at wired limit 25000: `-c 40960` serves; 44032, 47104, 53248 and 65536 all load and then OOM on the first real completion. The creep found no ceiling to 40982, at 52.6 tok/s there and zero swap growth. At wired 24000 this arm loads only `-c 33792`. The cache type is worth 2.8x at 33K against the q8_0 row, for a window less than half its size.

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 40960 \
  --cache-type-k f16 --cache-type-v f16 \
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

**The wired limit and the KV type set this model's depth.** At 27000
the machine became too slow for normal use. At 25000, the standing
value, a real completion is the ceiling test, because a one-token
probe passes at allocations that OOM on the first real request. The
q8_0 arm serves `-c 98304` and every `-c` from 100864 up fails; the
f16 arm serves `-c 40960` and 44032, 47104, 53248 and 65536 all fail.
The q8_0 creep runs clean to 81958 tokens at 9.24 tok/s and crosses
the floor at 98K; the f16 creep finds no ceiling inside its window,
52.6 tok/s at 40982. So the cache type buys 2.8x the speed at 33K and
costs more than half the window. At 24000 the same arms serve `-c
40960` and `-c 33792`; those readings and the 90K fast-sweep curve are
on [the historical page](../historical.md).

**MLX reaches 41K and then dies.** The MLX server holds 55.1 tok/s at
4K and 37.4 at 40982, its last stable depth, and at the next step its
generation thread died on a Metal OOM while the models endpoint kept
answering. Against llama at f16 KV it is slower at every depth, 38.3
against 56.5 at 33K, and holds no extra window; its wired memory grows
with the session and peaked at 24.6 GB.

MTP acceptance does not degrade at the maximum (py 80%, js 90%). KV is
only about 19 KB per token, so decode speed does not fall as allocated
context grows, only as used context grows. Prompt processing is healthy
on this architecture (62 to 93 tok/s even on tiny prompts, against
about 22 for dense Qwen3.8). Sweep prompts are synthetic continuations,
so MTP numbers there read below the py/js bench.

## Which to pick for a coding task

| need | config | tok/s (py/js) | context |
|---|---|--:|--:|
| **Max speed at depth** | llama-server + MTP n=3, f16 KV, `-c 40960`, 1 slot | 69.1 at 4K, 52.6 at 41K | 41K, no ceiling found inside the largest `-c` that loads |
| **Max window, agent work** | llama-server + MTP n=3, q8_0 KV, `-c 98304`, 1 slot | 36.5 at 4K, 9.24 at 82K | 82K clean, floor at 98K |
| **Small option** | mlx_lm.server 4-bit, unquantized KV | 55.1 at 4K, 37.4 at 41K | 41K, then a Metal OOM |
| **Multi-agent** | untested at limit 25000 | – | – |

## Quality — EvalPlus HumanEval+

| config scored | budget | pass@1 base | pass@1 plus | empty completions | completion |
|---|--:|--:|--:|--:|--:|
| llama-server + MTP, q8_0 KV, `-c 49152`, thinking off | 8192 | **0.951** | 0.915 | 0/164 | 100% |
| llama-server + MTP, q8_0 KV, thinking on | 26624 | 0.939 | **0.921** | 5/164 | 97% |

## Agentic quality — Mendel

<!-- gen:model-mendel:start -->
| test | build | config | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|---|--:|---|--:|--:|--:|--:|--:|--:|---|
| guided-v3.0 | UD-Q4_K_XL unsloth | llama-q8_0-high-ctx.112k ⏳ | **83** | 8/8/done | 91.9 | 12,712k | 94k | 1 | 285 | 16 |  |
| guided-v2.1 | UD-Q4_K_XL unsloth | llama-q8_0-default-ctx.96k | **65.5** | 8/8/done | 75.6 | 12,081k | 94k | 0 | 251 | 8 |  |
| blind-v1.1 | UD-Q4_K_XL unsloth | llama-q8_0-high-ctx.96k | **63** | 8/8/done | 79.2 | 7,933k | 94k | 0 | 203 | 13 |  |
| guided-v3.0 | UD-Q4_K_XL unsloth | llama-q8_0-off-ctx.80k | **62.5** | 8/8/done | 89.4 | 13,045k | 78k | 1 | 264 | 16 |  |
| guided-v3.0 | UD-Q4_K_XL unsloth | llama-q8_0-off-ctx.48k | **46.5** | 8/8/done | 95.6 | 9,473k | 52k | 12 | 299 | 7 |  |
| blind-v1.0 | UD-Q4_K_XL unsloth | llama-q8_0-default-ctx.96k | **41.5** | 8/8/done | 132.0 | 10,090k | 94k | 1 | 258 | 13 |  |

The build cell names the quant and its publisher. The config cell names the server, the KV cache type, the thinking level and the harness window. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.

⏳ this row ran on a 122880-token harness window; at wired 25000 the q8_0 arm serves `-c 98304`, so the window is out of reach. The score stands as a record; a re-run at the served window is pending, at low priority. [What the machine serves at wired 25000](../index.md#the-wired-limit-25000).
<!-- gen:model-mendel:end -->

The full table and the rubric are on [the Mendel page](../benchmarks/mendel.md).

## Decode speed vs used context

The llama arms share one depth ladder, so they share a table, in the
shape of
[the comparison table](../comparison.md#decode-speed-vs-used-context-the-8-tok-s-usability-floor).
Both measured at wired limit 25000, fresh server, one creep each, zero
swap growth on every row.

| config | @ 4K | @ 8K | @ 16K | @ 25K | @ 33K | @ 41K | @ 49K | @ 66K | @ 82K | capped by |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|---|
| **llama+MTP, f16 KV, `-c 40960`** | **69.1** | **71.3** | **65.7** | **61.0** | **56.5** | **52.6** | | | | mem — 40960 is the largest `-c` that serves a real request; no ceiling found inside it |
| llama+MTP, q8_0 KV, `-c 98304` | 36.5 | 44.1 | 31.2 | 24.2 | 19.6 | 16.6 | 14.3 | 11.2 | 9.24 | speed — 7.86 at 98K, under the floor; 98304 is the largest `-c` that serves a real request |

Wired memory at the deepest row: 25.1 GB on f16, 25.8 GB on q8_0. The
24000 readings, `-c 33792` at f16 and `-c 40960` at q8_0 with its
stop at 33K, are superseded and on [the historical page](../historical.md).

### MLX, its own creep (2026-09-06, wired limit 25000)

The MLX server ran a different depth ladder, so its numbers stay in
their own table rather than borrow the columns above. Its cache is
unquantized and the server offers no KV option.

| depth | 4K | 8K | 16K | 25K | 33K | 37K | 41K | ~45K |
|---|--:|--:|--:|--:|--:|--:|--:|---|
| `mlx-community/Qwen3.6-35B-A3B-4bit` | 55.1 | 53.8 | 47.8 | 43.0 | 38.3 | 39.0 | **37.4 — last stable** | Metal OOM, thread dead, endpoint alive |

Wired memory peaked at 24.6 GB. At wired 24000 the same server
stopped at 37K in 18.7 GB ([historical](../historical.md)).

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
