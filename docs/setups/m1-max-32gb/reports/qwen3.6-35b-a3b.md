# Qwen3.6-35B-A3B (MoE) on M1 Max 32 GB

Backends: llama-server, mlx-lm · [Qwen3.6-35B-A3B-MTP GGUF on Hugging Face](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>67.7 tok/s</b><span>decode, shallow (GGUF, f16 KV)</span></div>
  <div class="kpi"><b>33K</b><span>GGUF f16 KV depth, 56.0 tok/s, no ceiling found</span></div>
  <div class="kpi"><b>0.951 / 0.915 / 100%</b><span>EvalPlus, thinking off (GGUF q8_0), 0 empty</span></div>
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
  with wired memory near 25 GB. Re-measured 2026-09-07 at wired limit
  24000: the GGUF serves `-c 40960` at q8_0 KV and `-c 33792` at f16 KV,
  and the older published `-c 49152` is not safe. The old 90K figure
  came from the fast sweep and is on the historical page.
- **f16 KV is 2.8x faster at depth than q8_0 on this model**, 56.0
  against 19.7 tok/s at 32818 used tokens, for a window 7K smaller.
  Four creeps across two tools found no ceiling for the f16 arm and
  zero swap growth. The earlier reading that f16 does not load was
  taken at a larger `-c`.
- Weak point: on the agent task it scores 63 blind and 83 guided at
  thinking high, with one critical trap hit blind. Its two thinking-off
  agent rows ran on windows that need the retired 25000 limit.

## All configs — this model

<!-- gen:model-table:start -->
| # | Config | Max ctx | Gated by | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus |
|--:|---|--:|:--:|--:|--:|--:|
| 1 | Qwen3.6-35B-A3B, MLX, unquantized KV, thinking on | 37k | mem | 53.3 → 42.0 | 18.7 GB | 0.939/0.921/97% |
| 2 | Qwen3.6-35B-A3B, GGUF, MTP, q8_0 KV, thinking on | 33k | mem | 36.7 → 19.7 | 24.8 GB | 0.939/0.921/97% |
| 3 | Qwen3.6-35B-A3B, GGUF, MTP, f16 KV, thinking on | 33k | mem | 67.7 → 56.0 | 24.9 GB | 0.939/0.921/97% |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
**#1 — Qwen3.6-35B-A3B, MLX, unquantized KV, thinking on.**

```bash
mlx_lm.server --model mlx-community/Qwen3.6-35B-A3B-4bit \
  --prompt-cache-size 2 --port 8081
```

**#2 — Qwen3.6-35B-A3B, GGUF, MTP, q8_0 KV, thinking on.** pi id `qwen3.6-35b-a3b`. Re-measured 2026-09-07 at wired limit 24000 with a real sweep step as the ceiling test: `-c 40960` serves; `-c 49920` passes a one-token probe and then OOMs on the first real step, so the older published `-c 49152` is not safe. Two creeps, two tools, agree row for row and stop at depth 32818 on the compaction rule with zero swap growth; that stop is under review, because the same rule fires from ordinary speed decay at this depth. The f16 KV row below is 2.8x faster at that depth.

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 40960 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

**#3 — Qwen3.6-35B-A3B, GGUF, MTP, f16 KV, thinking on.** Measured 2026-09-07 at wired limit 24000: `-c 33792` serves, `-c 33920` fails with a Metal OOM. Four creeps across two tools found no ceiling to 32818 and zero swap growth, at 56.0 tok/s there against 19.7 for the q8_0 row. This overturns the older reading that f16 KV does not load for this model, which was measured at a larger `-c`. The window is 7K smaller than the q8_0 row and the speed at depth is 2.8x.

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 33792 \
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

**The wired limit and the KV type set this model's depth.** At 27000 the
machine became too slow for normal use. At 24000, re-measured
2026-09-07 with a real sweep step as the ceiling test, the model serves
`-c 40960` at q8_0 KV and `-c 33792` at f16 KV; the published `-c 98304`
and 65536 OOM at load, and `-c 49152` is not safe either. The f16 arm
holds 56.0 tok/s at 32818 used tokens against 19.7 for q8_0, so the
cache type is worth more here than the 7K of window it costs. The
larger single-slot and two-agent configs of the old limit, and the 90K
fast-sweep curve, are on [the historical page](../historical.md). The
sentence below was measured
before that. f16 KV does not load even
at 40960, so q8_0 stays.

**MLX was the faster curve until the KV type was fixed.** Against llama
at q8_0 KV, MLX is 2.2x faster at 33K, with 18.7 GB RSS, and then dies
between 37K and 41K. Against llama at f16 KV, measured 2026-09-07, it
is slower: 42.0 tok/s at 33K against 56.0. The llama arm holds its
speed and does not OOM inside its window; the MLX arm still reaches
37K against llama's 33K.

MTP acceptance does not degrade at the maximum (py 80%, js 90%). KV is
only about 19 KB per token, so decode speed does not fall as allocated
context grows, only as used context grows. Prompt processing is healthy
on this architecture (62 to 93 tok/s even on tiny prompts, against
about 22 for dense Qwen3.8). Sweep prompts are synthetic continuations,
so MTP numbers there read below the py/js bench.

## Which to pick for a coding task

| need | config | tok/s (py/js) | context |
|---|---|--:|--:|
| **Max speed at depth** | llama-server + MTP n=3, f16 KV, `-c 33792`, 1 slot | 67.7 at 4K, 56.0 at 33K | 33K, no ceiling found |
| **Max window on llama** | llama-server + MTP n=3, q8_0 KV, `-c 40960`, 1 slot | 36.7 at 4K, 19.7 at 33K | 33K, stop under review |
| **Max depth** | mlx_lm.server 4-bit, f16 KV | 53.3 at 4K, 42.0 at 37K | 37K, OOM at about 41K |
| **Multi-agent** | untested at limit 24000 (OOM even at 2×20K) | – | – |

## Quality — EvalPlus HumanEval+

| config scored | budget | pass@1 base | pass@1 plus | empty completions | completion |
|---|--:|--:|--:|--:|--:|
| llama-server + MTP, q8_0 KV, `-c 49152`, thinking off | 8192 | **0.951** | 0.915 | 0/164 | 100% |
| llama-server + MTP, q8_0 KV, thinking on | 26624 | 0.939 | **0.921** | 5/164 | 97% |

## Agentic quality — Mendel

<!-- gen:model-mendel:start -->
| test | config | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|---|--:|--:|--:|--:|--:|--:|---|
| guided-v3.0 | llama-q8_0-high-ctx.128k ⏳ | **83** | 8/8/done | 91.9 | 12,712k | 94k | 1 | 285 | 16 |  |
| guided-v2.1 | llama-q8_0-default-ctx.96k ⏳ | **65.5** | 8/8/done | 75.6 | 12,081k | 94k | 0 | 251 | 8 |  |
| blind-v1.1 | llama-q8_0-high-ctx.96k ⏳ | **63** | 8/8/done | 79.2 | 7,933k | 94k | 0 | 203 | 13 |  |
| guided-v3.0 | llama-q8_0-off-ctx.80k ⏳ | **62.5** | 8/8/done | 89.4 | 13,045k | 78k | 1 | 264 | 16 |  |
| guided-v3.0 | llama-q8_0-off-ctx.48k ⏳ | **46.5** | 8/8/done | 95.6 | 9,473k | 52k | 12 | 299 | 7 |  |
| blind-v1.0 | llama-q8_0-default-ctx.96k ⏳ | **41.5** | 8/8/done | 132.0 | 10,090k | 94k | 1 | 258 | 13 |  |

The config cell names the server, the KV cache type, the thinking level and the harness window. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.

⏳ every Qwen3.6 agent score ran on a harness window this machine cannot serve at wired 24000, which now tops out at `-c 40960`; the scores stand as records and a re-run at the serving window is pending, at low priority. [What the machine serves at wired 24000](../index.md#the-wired-limit-24000).
<!-- gen:model-mendel:end -->

The full table and the rubric are on [the Mendel page](../benchmarks/mendel.md).

## Decode speed vs used context

The llama arms share one depth ladder, so they share a table, in the
shape of
[the comparison table](../comparison.md#decode-speed-vs-used-context-the-8-tok-s-usability-floor).
Both re-measured 2026-09-07 at wired limit 24000.

| config | @ 4K | @ 8K | @ 16K | @ 25K | @ 33K | capped by |
|---|--:|--:|--:|--:|--:|---|
| **llama+MTP, f16 KV, `-c 33792`** | **67.7** | **70.0** | **64.5** | **60.2** | **56.0** | mem — 33792 is the largest `-c` that loads; no ceiling found to 33K, zero swap |
| llama+MTP, q8_0 KV, `-c 40960` | 36.7 | 44.2 | 31.3 | 24.2 | 19.7 | mem — stopped at 33K on the memory-compression rule, which is under review; zero swap |

Wired memory at the deepest row: 24.9 GB on f16, 24.8 GB on q8_0. The
older q8_0 curve at `-c 49152`, with its 8K clean row, is superseded:
that `-c` is not safe under real traffic
([historical](../historical.md)).

### MLX, its own creep (2026-08-29, wired limit 24000)

The MLX server ran a different depth ladder on a different day, so its
numbers stay in their own table rather than borrow the columns above.
Its cache is unquantized and the server offers no KV option.

| depth | 4K | 16K | 33K | 37K | ~41K |
|---|--:|--:|--:|--:|---|
| `mlx-community/Qwen3.6-35B-A3B-4bit` | 53.3 | 49.6 | 42.2 | **42.0 — last stable** | Metal OOM |

Wired memory 18.7 GB at 37K.

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
