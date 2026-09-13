# Gemma-4-26B-A4B (MoE) on M1 Max 32 GB

Backends: llama-server, mlx-lm · [GGUF on Hugging Face](https://huggingface.co/unsloth/gemma-4-26b-a4b-it-GGUF) · [MLX 4-bit](https://huggingface.co/mlx-community/gemma-4-26b-a4b-it-4bit)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>197K</b><span>GGUF f16 KV ceiling, 17.3 tok/s there</span></div>
  <div class="kpi"><b>0.976 / 0.945</b><span>EvalPlus base / plus, GGUF, thinking off</span><small>100% completion</small></div>
  <div class="kpi"><b>0.884 / 0.860</b><span>EvalPlus base / plus, GGUF, thinking on</span><small>89% completion</small></div>
  <div class="kpi"><b>47.5 / 100</b><span>Mendel blind, GGUF f16 KV, thinking on</span><small>complete</small></div>
</div>
<!-- gen:model-kpis:end -->

Benchmarked 2026-08-25 (llama build 10621, unsloth UD-Q4_K_XL + MTP draft, wired limit 24000). GGUF re-measured at f16 KV 2026-09-05, scored and run on Mendel 2026-09-06. MLX scored 2026-08-29.

## Highlights

- **The GGUF at f16 KV is the secondary-model pick.** Thinking off it
  scores 0.976 / 0.945 / 100% on EvalPlus, 0 empty, in 19 minutes. On the
  Mendel blind task at thinking high it scores 47.5 of 100, complete,
  all eight libraries, one critical trap hit; guided at thinking high
  it scores 57, seven of eight. Thinking off it loops on the agent
  task: both thinking-off rows ended on five identical edit calls.
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
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" top /> | **197k** | mem | <TokCell shallow="60.3" deep="17.3" stale top-shallow top-deep /> | **25.6 GB** | <ScoreCell value="0.884/0.860" sub="89% completion" top /> | <ScoreCell value="47.5" pill="mendel-blind" top /> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/gemma-4-26b-a4b-it-4bit" kv="f16" effort="on" top /> 💀 | ***66k*** | *mem* | ****51†*** → ***12.8†**** | ***20.0 GB*** | <ScoreCell value="0.713/0.701" sub="72% completion" top /> | <ScoreCell value="0" note="0%" pill="failed-smoke" top /> |

† from an earlier serving config or method; re-run pending.

💀 This MLX build is retired here: it failed the agent smoke on a truncated tool call, while the GGUF build of the same model completes the task. [Why it is not a candidate](../benchmarks/gemma-4-26b-a4b.md#the-retired-mlx-build).

Rows below 100 percent completeness. Completeness counts three measurements: tok/s, EvalPlus and Mendel.

| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" /> | **2x82k** | mem | <TokCell shallow="66.6" deep="33.6" stale top-shallow top-deep /> | **25.3 GB** | <ScoreCell value="0.884/0.860" sub="89% completion" top /> | <ScoreCell value="pending" /> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" />

pi id `gemma-4-26b-a4b`. Measured 2026-09-05 at f16 KV, the KV pick: 212992 is the largest `-c` that loads; 229376 and 262144 OOM at load. Wired sits above the 24000 limit but stays flat. EvalPlus scored on this config 2026-09-06: 0.884/0.860/89% thinking on (18/164 empty, budget 30000), 0.976/0.945/100% thinking off (budget 8192). Mendel blind at thinking high: 47.5/100, complete.

```bash
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias gemma-4-26b-a4b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 2 --parallel 1 \
  -ngl 999 -fa on -c 212992 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

<ModelSpec base="Gemma-4-26B-A4B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/gemma-4-26b-a4b-it-4bit" kv="f16" effort="on" />

Retired 2026-09-12 (owner). The agent smoke at thinking high on a 65536 window ended with zero commits on a tool call the server truncated mid-generation, with no OOM and no server death; the GGUF UD-Q4_K_XL build of the same model completes the agent task, so this quant is not a candidate and is not run again. Real-text speed read 2026-09-12 with llama-benchy: 49.3 tok/s at 4K and 23.4 at 64K; the earlier creep read the same server alternating between 13 and 24 tok/s from 60K up, with 12.83 the last stable step at 70K.

```bash
mlx_lm.server --model mlx-community/gemma-4-26b-a4b-it-4bit \
  --prompt-cache-size 2 --port 8081
```

<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" />

pi id `gemma-4-26b-a4b-2x`. Measured 2026-09-05 at f16 KV: 202752 is the largest `-c` that serves a real 4096-token completion (208896 and above fail on compute buffers or at load), 101376 per slot. One slot swept with the other loaded and idle: no speed or memory stop before the slot window; the deepest row is 82K at 33.6 tok/s. The EvalPlus score is the single-slot f16 config's, same weights and cache type.

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

**Thinking off is where the agent task breaks.** Both thinking-off
rows, guided and blind, ended on the harness's live loop stop after
five identical edit calls: 25 capped from 44 raw with two libraries
done, and 12.5 from 21 with one. The loop is the model's own failure,
so both rows count as partials. The guided row at thinking high the
same week completed seven of eight at 57, on its third attempt; the
first two were killed by a system-wide memory squeeze from a macOS
media indexing process, not by the model. On the single-turn gate
thinking off is the better setting; on the agent loop it is the worse
one.

## Which to pick for a coding task

| need | config | tok/s | context |
|---|---|--:|--:|
| **Max context** | llama-server + MTP n=2, f16 KV, `-c 212992`, 1 slot | 60.3 at 4K, 17.3 at 197K | 197K measured |
| **Max js speed** | f16 KV at small context (32K) | 74.8 / 71.6 | 32K |
| **Two agents** | `--parallel 2 -c 202752`, f16 KV | 66.6 at 4K, 33.6 at 82K, one slot | 2×101K allocated, 82K measured |

## Quality — EvalPlus HumanEval+

| config | budget | pass@1 base | pass@1 plus | empty completions | completion |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" /> | 8192 | 0.976 | 0.945 | 0/164 | 100% |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" /> | 30000 | 0.884 | 0.860 | 18/164 | 89% |
| <ModelSpec base="Gemma-4-26B-A4B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/gemma-4-26b-a4b-it-4bit" kv="f16" effort="on" /> | 30000 | 0.713 | 0.701 | 46/164 | 72% |

The two GGUF rows share the thinking-on score; the MLX row keeps its own.

## Agentic quality — Mendel

<!-- gen:model-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" /> | blind-v1.1 | 208k | **47.5** | 8/8/done | 80.8 | 23,832k | 209k | 1 | 246 | 21 |  |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="q8_0" effort="on" /> | blind-v1.0 | 256k | **38** | 8/8/partial | 104.0 | 8,150k | 142k | 0 | 115 | 9 |  |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" /> | blind-v1.1 | 208k | **12.5** | 1/8/partial | 28.0 | 8,053k | 136k | 0 | 120 | 7 | tool call |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" /> | guided-v3.0 | 208k | **57** | 7/8/partial | 115.1 | 24,803k | 209k | 2 | 269 | 13 |  |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" /> | guided-v3.0 | 208k | **25** | 2/8/partial | 20.4 | 2,605k | 73k | 0 | 91 | 3 | tool call |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:model-mendel:end -->

The full table and the rubric are on [the Mendel page](../benchmarks/mendel.md).

## Decode speed vs used context

<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" hide="effort" />

The two llama arms share one depth ladder, so they share a table, in
the shape of
[the comparison table](../comparison.md#decode-speed-vs-used-context-the-8-tok-s-usability-floor).
Slow creep 2026-09-05, wired limit 24000.

| config | @ 4K | @ 16K | @ 24.5K | @ 33K | @ 49K | @ 66K | capped by |
|---|--:|--:|--:|--:|--:|--:|---|
| **1 slot, `-c 212992`** | **60.3** | **56.5** | | **45.9** | **45.9** | | mem — 212992 is the largest `-c` that loads; 26.4 at 115K and 17.3 at 197K, the deepest step |
| 2 slots, `-c 202752` | 66.6 | 60.8 | 52.6 | 50.6 | 36.1 | 34.4 | mem — 33.6 at 82K, the last row inside the slot window |

Cells are blank where no step was measured at that depth. Wired memory
at the deepest row: 25.6 GB on one slot, 25.3 GB on two.

### MLX, its own creep (2026-08-29, wired limit 24000)

The MLX server ran its own depth ladder on a different day, so its
numbers keep their own table. Its cache is unquantized and the server
offers no KV option.

| depth | 4K | 16K | 24.5K | 33K | 49K | 60K | 66K | 70K |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| `mlx-community/gemma-4-26b-a4b-it-4bit` | 51.1 | 43.5 | 39.6 | 35.6 | 28.8 | 24.96 | 13.07 | **12.83 — last stable** |

Wired memory 20.0 GB at 70K. Full curves in
[the benchmarks](../benchmarks/gemma-4-26b-a4b.md).

## MTP draft depth sweep (32K)

<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" kv="f16" hide="drafter,effort" />

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
