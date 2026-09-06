# Gemma-4-26B-A4B (MoE) on M1 Max 32 GB

Backends: llama-server, mlx-lm · [GGUF on Hugging Face](https://huggingface.co/unsloth/gemma-4-26b-a4b-it-GGUF) · [MLX 4-bit](https://huggingface.co/mlx-community/gemma-4-26b-a4b-it-4bit)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>197K</b><span>GGUF f16 KV ceiling, 60.3 tok/s at 4K, 17.3 there</span></div>
  <div class="kpi"><b>0.976 / 0.945 / 100%</b><span>EvalPlus, thinking off (GGUF f16), 0 empty</span></div>
  <div class="kpi"><b>0.884 / 0.860 / 89%</b><span>EvalPlus, thinking on (GGUF f16); MLX 0.713 / 0.701 / 72%</span></div>
  <div class="kpi"><b>47.5 / 100</b><span>Mendel blind, thinking high (GGUF f16), complete</span></div>
</div>
<!-- gen:model-kpis:end -->

Benchmarked 2026-08-25 (llama build 10621, unsloth UD-Q4_K_XL + MTP draft, wired limit 24000). GGUF re-measured at f16 KV 2026-09-05, scored and run on Mendel 2026-09-06. MLX scored 2026-08-29.

## Highlights

- **The GGUF at f16 KV is the secondary-model pick.** Thinking off it
  scores 0.976 / 0.945 / 100% on EvalPlus, 0 empty, in 19 minutes. On the
  Mendel blind task at thinking high it scores 47.5 of 100, complete,
  all eight libraries, one critical trap hit.
- **The fastest depth curve on this machine.** 60.3 tok/s at 4K and 17.3
  at 197K, the largest context this machine loads for it. Two slots hold
  101K each: 66.6 tok/s at 4K, 33.6 at 82K on one slot with the other
  idle, no speed or memory stop before the slot window.
- **Thinking costs answers on the single-turn test.** Thinking on reads
  0.884 / 0.860 / 89% with 18 of 164 empty; the MLX build 0.713 / 0.701 /
  72% with 46 empty. The two builds do not share a score.
- Weak point: wired memory sits at 25.6 GB on the deep config, above the
  24000 limit, flat but with no room for anything beside it. MLX is the
  small option: 51 tok/s at 4K, 12.8 at 70K, in 20 GB.

## All configs — this model

<!-- gen:model-table:start -->
| # | Config | Max ctx | Gated by | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus |
|--:|---|--:|:--:|--:|--:|--:|
| 1 | Gemma-4-26B-A4B, MLX | 70k | mem | 51 → 12.8 | 20.0 GB | 0.713/0.701/72% |
| 2 | Gemma-4-26B-A4B, GGUF, MTP f16 | 197k | mem | 60.3 → 17.3 | 25.6 GB | 0.884/0.860/89% |
| 3 | Gemma-4-26B-A4B, GGUF, MTP f16, 2 slots | 2x82k | mem | 66.6 → 33.6 | 25.3 GB | 0.884/0.860/89% |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
**#1 — Gemma-4-26B-A4B, MLX.**

```bash
mlx_lm.server --model mlx-community/gemma-4-26b-a4b-it-4bit \
  --prompt-cache-size 2 --port 8081
```

**#2 — Gemma-4-26B-A4B, GGUF, MTP f16.** pi id `gemma-4-26b-a4b`. Measured 2026-09-05 at f16 KV, the KV pick: 212992 is the largest `-c` that loads; 229376 and 262144 OOM at load. Wired sits above the 24000 limit but stays flat. EvalPlus scored on this config 2026-09-06: 0.884/0.860/89% thinking on (18/164 empty, budget 30000), 0.976/0.945/100% thinking off (budget 8192). Mendel blind at thinking high: 47.5/100, complete.

```bash
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias gemma-4-26b-a4b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 2 --parallel 1 \
  -ngl 999 -fa on -c 212992 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

**#3 — Gemma-4-26B-A4B, GGUF, MTP f16, 2 slots.** pi id `gemma-4-26b-a4b-2x`. Measured 2026-09-05 at f16 KV: 202752 is the largest `-c` that serves a real 4096-token completion (208896 and above fail on compute buffers or at load), 101376 per slot. One slot swept with the other loaded and idle: no speed or memory stop before the slot window; the deepest row is 82K at 33.6 tok/s. The EvalPlus score is the single-slot f16 config's, same weights and cache type.

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

**Back in the running as a secondary model.** The model was parked on
2026-08-30 after the quality gate: 28% empty completions on the MLX
build and an agentic run stopped in a thinking loop. Moving the KV cache
to f16 took the llama row from 23.5 to 8 tok/s at 24K to 60.3 to 17.3
tok/s at 197K. Scored on its own at f16 KV it passed the 0.800 gate
(0.884 base, thinking on), passed the Mendel smoke in 31 seconds, and
finished the Mendel blind task at thinking high: 47.5 of 100, all eight
libraries touched, one critical trap hit (a `.then()` left on a
promise-based glob), leftover `rimraf` calls and a stray `package.json`
costing completion points, 21 commits in 81 minutes, peak context at 98
percent of the 212992 window, no loop. The earlier blind row at q8_0 KV
scored 38, partial.

**f16 KV is the pick, and q8_0 was the speed problem.** A short creep
read 6.3 tok/s at 32K for q8_0 against 45.9 for f16, at almost the same
wired memory. The full f16 creep then held above 17 tok/s to 197K.
212992 is the largest `-c` that loads; 229376 and 262144 OOM at load.
The four-problem smoke read level between the two cache types, both
failing the same hard problem the same way. q8_0 also lowered js draft
acceptance from 81% to 68%. The old claim that f16 did not fit came from
the published `-c 262144`, which loads at neither type.

**llama is the deep config; MLX the small one.** The MLX build stays
fast to about 68K, then swings between 13 and 24 tok/s at 62 to 70K
before it OOMs at about 72K (limit 24000, slow creep, 2026-08-29), in 20
GB. llama at f16 holds three times that depth in 25.6 GB wired, flat.

**Thinking is binary here.** Gemma 4 has trained-in reasoning toggled by
`enable_thinking` in the chat template, on or off, default off, with no
graded effort levels. The speed numbers on this page were measured with
thinking off; thinking costs about 3 tok/s.

**Thinking on has a convergence problem on both builds.** Calibration
showed that at a 30K output cap 2 of 10 sample problems never finished
reasoning. The full runs confirmed it: 46 of 164 empty on MLX, 18 of 164
on the GGUF at f16, same budget. Every empty completion still had budget
left, so this is model behaviour, not a harness limit. Like Gemma-12B,
this model does not share a score across its two quants.

Pending: Mendel at thinking off, guided and blind, and Mendel guided at
thinking on.

## Which to pick for a coding task

| need | config | tok/s | context |
|---|---|--:|--:|
| **Max context** | llama-server + MTP n=2, f16 KV, `-c 212992`, 1 slot | 60.3 at 4K, 17.3 at 197K | 197K measured |
| **Max js speed** | f16 KV at small context (32K) | 74.8 / 71.6 | 32K |
| **Two agents** | `--parallel 2 -c 202752`, f16 KV | 66.6 at 4K, 33.6 at 82K, one slot | 2×101K allocated, 82K measured |

## Quality — EvalPlus HumanEval+

| config scored | pass@1 base | pass@1 plus | empty completions | completion |
|---|--:|--:|--:|--:|
| llama-server UD-Q4_K_XL, f16 KV, thinking off, budget 8192 | 0.976 | 0.945 | 0/164 | 100% |
| llama-server UD-Q4_K_XL, f16 KV, thinking on, budget 30000 | 0.884 | 0.860 | 18/164 | 89% |
| mlx_lm.server 4-bit, thinking on, budget 30000 | 0.713 | 0.701 | 46/164 | 72% |

The two GGUF rows share the thinking-on score; the MLX row keeps its own.

## Agentic quality — Mendel

| test | config | score | worst defect | status |
|---|---|--:|---|---|
| blind | llama-server, f16 KV, `-c 212992`, thinking high | **47.5/100** | critical | complete, 8/8 libraries |

The full table and the rubric are on [the Mendel page](../benchmarks/mendel.md).

## Decode speed vs used context (llama f16 KV, slow creep, 2026-09-05; mlx slow creep, 2026-08-29; limit 24000)

| depth | llama+MTP f16, 1 slot | llama+MTP f16, 2 slots (one decoding) | MLX (gemma-4-26b-a4b-it-4bit) |
|---|--:|--:|--:|
| 4K | 60.3 | 66.6 | 51.1 |
| 16K | 56.5 | 60.8 | 43.5 |
| 24.5K | | 52.6 | 39.6 |
| 33K | 45.9 | 50.6 | 35.6 |
| 49K | 45.9 | 36.1 | 28.8 |
| 60K | | | 24.96 |
| 66K | | 34.4 | 13.07 |
| **70K** | | | **12.83 — last stable** |
| 82K | | **33.6 — last row inside the slot window** | |
| 115K | 26.4 | | |
| **197K** | **17.3 — last stable, 212992 is the largest `-c` that loads** | | |

Wired memory at the last row: 25.6 GB on one slot, 25.3 GB on two, 20.0
GB on MLX. Full curves in [the benchmarks](../benchmarks/gemma-4-26b-a4b.md).
The q8_0 KV curve and the allocation-only context table are on
[the historical page](../historical.md).

## MTP draft depth sweep (32K, f16 KV)

Thinking ON (chat endpoint, `enable_thinking: true`, 1024 tokens):

| --spec-draft-n-max | py tok/s | py accept | js tok/s | js accept |
|---|--:|--:|--:|--:|
| **2** | **71.88** | **84%** | **69.25** | **78%** |
| 3 | 67.94 | 74% | 64.90 | 69% |
| 4 | 63.97 | 69% | 61.00 | 65% |

Thinking OFF: peak 74.8 py / 71.6 js, also at n-max 2. Full thinking-off
tables in [the benchmarks](../benchmarks/gemma-4-26b-a4b.md).

---

Method: warmup before every measurement; identical prompts across models;
temp 0. Raw numbers in
[the benchmarks](../benchmarks/gemma-4-26b-a4b.md). Cross-model picks on
[the comparison page](../comparison.md).
