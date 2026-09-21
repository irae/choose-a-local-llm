# Gemma-4-12B-it on RTX 5060 Ti 16 GB

Backends: llama-server · [NVFP4 GGUF on Hugging Face](https://huggingface.co/FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF) · [UD-Q4_K_XL GGUF](https://huggingface.co/unsloth/gemma-4-12b-it-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>261k</b><span>usable context, NVFP4, f16 KV</span></div>
  <div class="kpi"><b>0.927 / 0.896</b><span>EvalPlus base / plus, NVFP4, thinking off</span><small>100% completion</small></div>
  <div class="kpi"><b>0.659 / 0.640</b><span>EvalPlus base / plus, NVFP4, thinking on</span><small>68% completion</small></div>
  <div class="kpi"><b>model-failed</b><span>Mendel guided, both builds, off and on</span></div>
</div>
<!-- gen:model-kpis:end -->

Speed, context and the guided agent task measured 2026-09-13 to 2026-09-15; EvalPlus scored 2026-09-16 on both builds at both thinking levels.

## Highlights

- **The NVFP4 build is the run's headline row.** A 7 GB file leaves
  room for the trained 262,144 window at f16 KV on 16 GB, and the
  card runs NVFP4 natively.
- **Thinking off is the level for this model on this card.** Every
  answer delivered on both builds, 0.951 / 0.909 on the k-quant in 26
  minutes and 0.927 / 0.896 on NVFP4 in 51. Thinking on loses a third
  of the answers on NVFP4 and a fifth on the k-quant.

## All configs — this model

<!-- gen:model-table:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" page="/binaries/gemma12-unsloth-ud-q4kxl" /> | **261k** | <TokCell shallow="47.39" deep="32.18" cap="mem" top-shallow top-deep /> | **12.7 GB** | <ScoreCell value="0.988/0.963" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 3h18 · Mendel 0h05"><b>3h23</b></span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" page="/binaries/gemma12-freedomaisvr-nvfp4" /> | **261k** | <TokCell shallow="49.55" deep="33.11" cap="mem" top-shallow top-deep /> | **12.3 GB** | <ScoreCell value="0.976/0.951" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 3h31 · Mendel 0h06"><b>3h37</b></span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" page="/binaries/gemma12-freedomaisvr-nvfp4" /> | **261k** | <TokCell shallow="49.55" deep="33.11" cap="mem" top-shallow top-deep /> | **12.3 GB** | <ScoreCell value="0.927/0.896" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h51 · Mendel 0h01"><b>0h52</b></span> |

Rows below 100 percent completeness. Completeness counts three measurements: tok/s, EvalPlus and Mendel.

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/binaries/gemma12-unsloth-ud-q4kxl" top /> | **261k** | <TokCell shallow="47.39" deep="32.18" cap="mem" top-shallow top-deep /> | **12.7 GB** | <ScoreCell value="0.951/0.909" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 0h26 · Mendel —">0h26†</span> |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" page="/binaries/gemma12-unsloth-ud-q4kxl" />

pi id `gemma-4-12b-q4kxl`, thinking on. The same server and speed as the thinking-off row. The guided task ended model-failed: right after it found the first dependency, the thinking repeated one line 818 times and filled the output budget, with zero commits. EvalPlus at thinking on, scored 2026-09-16 at `-c 32768`, budget 8192: 0.793/0.780, 34 empty answers of 164 whose cause is unproven because the run saved no finish log, in 259.0 minutes of active time. Every answered problem passed the base tests: the whole loss is thinking that did not end inside the budget, as the calibration predicted with four of ten answers at the 30000 cap. The NVFP4 build at the same level lost 53 answers, so this k-quant converges more often on this card. Thinking off is pending. The published score is the fast-mode run of 2026-09-20: thinking closed at 8192 tokens, output budget 16384, all 164 problems generated. It reads 0.988/0.963 with no empty answer and 34 forced answers of 164, in 198 minutes of active time. The earlier run left 35 answers empty and scored 0.793/0.780 on the same file; closing the thinking recovered every one of them. The coordinator recomputed this score from the per-problem results because the block ran the evaluator by hand.

```bash
llama-server -m "$(hf download unsloth/gemma-4-12b-it-GGUF gemma-4-12b-it-UD-Q4_K_XL.gguf)" \
  --alias gemma-4-12b-q4kxl --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 262144 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" page="/binaries/gemma12-freedomaisvr-nvfp4" />

pi id `gemma-4-12b-nvfp4`, thinking on. The same server and speed as the thinking-off row. The guided task ended model-failed: after a broken `xtend` edit, the thinking repeated the planned fix 520 times and never made the tool call, with zero commits. EvalPlus at thinking on, scored 2026-09-16 at `-c 32768`, budget 8192: 0.659/0.640, 53 empty answers of 164 whose cause is unproven because the run saved no finish log, in 203.9 minutes of active time in two parts. The calibration ended 5 of 10 answers at the 30000 cap, so the runner first set 1700 as a waste limiter; the owner restored the 8192 floor after 32 answers, and those 32 stayed. Thinking on scores far below thinking off on this build, 0.659 against 0.927, and 53 of the 56 failures are empty answers: the thinking did not end inside 8192 tokens on a third of the problems, as the calibration predicted with five of ten answers at the 30000 cap. This is the first EvalPlus score for this build at thinking on. Under a server thinking budget of 7350 tokens (answer budget 2048, `max_tokens` 9398, from a calibration with reasoning lengths and the margin 1.5; the thinking-budget test, 2026-09-16), the same file and level scored 0.976/0.951 with no empty answer in 194.8 minutes: 45 problems hit the budget and were forced to answer, and 42 of those 45 passed the base tests. That is above the thinking-off row of this build, 0.927/0.896. The natural re-run of the six forced failures changed nothing: all six hit the 30000 cap without the budget too, so the budget cost no answer and stands. The owner's word on how a budgeted score is shown is pending. The published score is the fast-mode run of 2026-09-20: thinking closed at 8192 tokens, output budget 16384, 119 answers kept from the run 21 score and 45 regenerated. It reads 0.976/0.951 with no empty answer and 44 forced answers of 164, in 211 minutes of active time, 135 of them its own. The earlier run left 53 answers empty and scored 0.659/0.640 on the same file; closing the thinking recovered every one of them. The run 21 budget of 7350 read the same 0.976/0.951 with 45 forced answers, so the wider fast-mode budget changed no score on this file. One problem, HumanEval/145, also ran its answer to the 16384 cap; it holds code, so it counts as complete.

```bash
llama-server -m "$(hf download FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF gemma-4-12b-it-nvfp4.gguf)" \
  --alias gemma-4-12b-nvfp4 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 262144 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" page="/binaries/gemma12-freedomaisvr-nvfp4" />

pi id `gemma-4-12b-nvfp4`. A community NVFP4 repack of the model, the run's headline NVFP4 row: the weights leave room for the trained 262,144 window at f16 KV. `-c 262144` loads at once and serves the deep cell at 261,120; the window is the model's own limit, not the card's. It reads 2 to 5 percent faster than the k-quant build on this card. The guided task at thinking off ended model-failed: the same tool call five times in a row, before the first commit. EvalPlus at thinking off, scored 2026-09-16 at `-c 32768`, budget 8192: 0.927/0.896, no empty answer of 164, in 51.1 minutes of active time. This is the first EvalPlus score for this build. The budget floors at 8192 because the longest calibration answer ran 949 tokens, so thinking off costs almost nothing here.

```bash
llama-server -m "$(hf download FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF gemma-4-12b-it-nvfp4.gguf)" \
  --alias gemma-4-12b-nvfp4 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 262144 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/binaries/gemma12-unsloth-ud-q4kxl" />

pi id `gemma-4-12b-q4kxl`. The k-quant build the Mac serves, the control for the NVFP4 row on this card. `-c 262144` loads at once and serves the deep cell at 261,120. The agent task runs at thinking on only (owner, 2026-09-14); see the row below. EvalPlus at thinking off, scored 2026-09-16 at `-c 32768`, budget 8192: 0.951/0.909, no empty answer of 164, in 26.1 minutes of active time; the longest calibration answer ran 1011 tokens. The Mac's row of the same file reads 0.976/0.939, and the NVFP4 build on this card 0.927/0.896. Thinking off beats thinking on on both Gemma-12B builds here, 0.951 against 0.793 on this one.

```bash
llama-server -m "$(hf download unsloth/gemma-4-12b-it-GGUF gemma-4-12b-it-UD-Q4_K_XL.gguf)" \
  --alias gemma-4-12b-q4kxl --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 262144 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

- **The k-quant build is the control.** The same file the reference
  setup serves, read on this card at the same depths, so the NVFP4
  row has a pair.
- **The agent task fails on every build and level**, with zero commits
  each time.

- **NVFP4 fits the trained window and reads fast.** 49.6 tok/s at 4K
  and 33.1 at 261K, 2 to 5 percent over the k-quant, at 12.3 GB.
- **The model fails the agent task on this card**, on both builds and
  at both thinking levels, with zero commits each time. At thinking
  off it sent one tool call five times in a row. At thinking on the
  thinking repeated a planned step hundreds of times and never made
  the tool call: 818 times on the first dependency (UD-Q4_K_XL), 520
  times on a broken `xtend` edit (NVFP4).
- **EvalPlus, NVFP4 at thinking off:** 0.927/0.896, no empty answer of
  164, budget 8192, 51.1 minutes of active time. The longest
  calibration answer ran 949 tokens, so the budget floors and the gate
  costs little.
- **EvalPlus, NVFP4 at thinking on:** 0.659/0.640, 53 empty answers of
  164, budget 8192, 203.9 minutes. The calibration had five of ten
  answers still thinking at 30000 tokens, so most of the loss is
  thinking that never ends, not wrong code; the cause of each empty is
  unproven because the run saved no finish log. The 12B fails to
  converge more often than the 26B, on both machines. This config is
  the first case of the thinking-budget test
  ([method](../../../methodology/reasoning-budget.md)).
  Under a 7350-token thinking budget from its calibration the same
  config scored 0.976/0.951 with no empty answer in 195 minutes: 45
  problems were forced to answer and 42 of them passed, above the
  thinking-off row. The six forced failures hit the 30000 cap without
  the budget too, so the budget cost no answer. The site shows the
  natural score until the owner decides how a budgeted row reads.
- **EvalPlus, UD-Q4_K_XL at thinking on:** 0.793/0.780, 34 empty answers
  of 164, budget 8192, 259.0 minutes. Every answered problem passed the
  base tests, so the whole loss is thinking that did not end; the cause
  is unproven for want of a finish log. The k-quant converges more often
  than the NVFP4 build at this level, 34 empties against 53.
- **EvalPlus, UD-Q4_K_XL at thinking off:** 0.951/0.909, no empty
  answer, budget 8192, 26.1 minutes. The Mac's row of the same file
  reads 0.976/0.939. On this card the k-quant beats the NVFP4 build at
  both levels on the single-turn test, and reads 2 to 5 percent slower.

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" page="/binaries/gemma12-unsloth-ud-q4kxl" />](../benchmarks/gemma-4-12b-it.md) | 8192 | 16384 | <ScoreCell value="0.988/0.963" sub="100% completion" top /> | none | 34/164 | <TokCell shallow="47.39" deep="32.18" /> | 3h18 |
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" page="/binaries/gemma12-freedomaisvr-nvfp4" />](../benchmarks/gemma-4-12b-it.md) | 8192 | 16384 | <ScoreCell value="0.976/0.951" sub="100% completion" top /> | none | 44/164 | <TokCell shallow="49.55" deep="33.11" /> | 3h31 |
| [<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/binaries/gemma12-unsloth-ud-q4kxl" />](../benchmarks/gemma-4-12b-it.md) | none | 8192 | <ScoreCell value="0.951/0.909" sub="100% completion" /> | none | — | <TokCell shallow="47.39" deep="32.18" /> | 0h26 |
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" page="/binaries/gemma12-freedomaisvr-nvfp4" />](../benchmarks/gemma-4-12b-it.md) | none | 8192 | <ScoreCell value="0.927/0.896" sub="100% completion" /> | none | — | <TokCell shallow="49.55" deep="33.11" /> | 0h51 |
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" page="/binaries/gemma12-freedomaisvr-nvfp4" />](../benchmarks/gemma-4-12b-it.md) | 7350† | 9398 | <ScoreCell value="0.976/0.951" sub="100% completion" /> | none | 45/164 | <TokCell shallow="49.55" deep="33.11" /> | 3h15 |
| [<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" page="/binaries/gemma12-unsloth-ud-q4kxl" />](../benchmarks/gemma-4-12b-it.md) | —† | 8192 | <ScoreCell value="0.793/0.780" sub="79% completion" /> | † unproven | — | <TokCell shallow="47.39" deep="32.18" /> | 4h19 |
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" page="/binaries/gemma12-freedomaisvr-nvfp4" />](../benchmarks/gemma-4-12b-it.md) | —† | 8192 | <ScoreCell value="0.659/0.640" sub="68% completion" /> | † unproven | — | <TokCell shallow="49.55" deep="33.11" /> | 3h24 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.
<!-- gen:model-evalplus:end -->

Every run of this model on this machine, best base score first. The empties column carries the cause word ([what the words mean](../../../benchmarks/evalplus.md#limits-on-local-hardware)).

## Agentic quality — Mendel

<!-- gen:model-mendel:start -->
Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" page="/binaries/gemma12-freedomaisvr-nvfp4" /> | guided-v3.0 | 256k | **0** (raw 34) | 0/8/model-failed | 1.0 | 296k | 13k | 0 | 30 | 0 |  |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" page="/binaries/gemma12-unsloth-ud-q4kxl" /> | guided-v3.0 | 256k | **0** (raw 34) | 0/8/model-failed | 5.3 | 213k | 25k | 0 | 17 | 0 | thinking |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" page="/binaries/gemma12-freedomaisvr-nvfp4" /> | guided-v3.0 | 256k | **0** (raw 34) | 0/8/model-failed | 5.5 | 496k | 39k | 0 | 24 | 0 | thinking |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:model-mendel:end -->

Full data: [the benchmarks page](../benchmarks/gemma-4-12b-it.md).
