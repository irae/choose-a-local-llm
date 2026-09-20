# Ternary Bonsai-2-27B

Every config of this model, on every machine, best first. It is a
different model from [Ternary Bonsai-27B](./bonsai-27b.md), not a
re-quantization of it, and the two are compared at the end of this page.

<!-- gen:model-all:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" hide="server" top /> | 135k | <TokCell shallow="42.1" deep="22.4" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.970/0.939†" sub="100% completion" /> | <ScoreCell value="82" pill="mendel-blind" top /> | <span title="EvalPlus 3h16 · Mendel 1h28"><b>4h44</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" hide="server" top /> | 119k | <TokCell shallow="46.3" deep="25.1" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.982/0.945†" sub="100% completion" top /> | <ScoreCell value="77" pill="mendel-blind" top /> | <span title="EvalPlus 3h03 · Mendel 1h15"><b>4h17</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" hide="server" top /> | 135k | <TokCell shallow="40.8" deep="22.0" cap="mem" top-deep /> | <ScoreCell value="0.976/0.945†" sub="100% completion" /> | <ScoreCell value="75" pill="mendel-blind" top /> | <span title="EvalPlus 4h34 · Mendel 1h22">5h56</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" hide="server" top /> | **240k** | <TokCell shallow="41.7" deep="12.8" cap="mem" /> | <ScoreCell value="0.982/0.945†" sub="100% completion" top /> | <ScoreCell value="73.5" pill="mendel-blind" /> | <span title="EvalPlus 4h05 · Mendel 2h03">6h08</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" hide="server" /> | **208k** | <TokCell shallow="46.0" deep="14.5" cap="mem" top-shallow /> | <ScoreCell value="0.982/0.939†" sub="100% completion" top /> | <ScoreCell value="60.5" pill="mendel-blind" /> | <span title="EvalPlus 2h56 · Mendel 1h32"><b>4h29</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/bonsai2-prism-ptq1" hide="server" /> | 160k | <TokCell shallow="17.9" deep="9.1" cap="mem" /> | <ScoreCell value="0.988/0.939†" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 5h37 · Mendel —">5h37†</span> |
<!-- gen:model-all:end -->

## Files

Every file of this model, on every machine that served it, with every run and a log.

<!-- gen:model-binaries:start -->
- [Ternary-Bonsai-2-27B PQ2_0 (prism-ml, prism fork)](../binaries/bonsai2-prism-pq2.md) — rtx-5060ti-16gb, m1-max-32gb
- [Ternary-Bonsai-2-27B PTQ1_0 (prism-ml, prism fork)](../binaries/bonsai2-prism-ptq1.md) — rtx-5060ti-16gb, m1-max-32gb
<!-- gen:model-binaries:end -->

## Speed and context

<!-- gen:model-curve:start -->
| arm | 4K | 24K | 64K | 128K | 160K | 208K | 240K |
|---|--:|--:|--:|--:|--:|--:|--:|
| rtx-5060ti-16gb, PQ2_0, f16 KV, no drafter, -c 120K | <CurveCell value="46.3" /> | <CurveCell value="40.5" /> | <CurveCell value="32.2" /> | <CurveCell value="25.1" depth="119.0K" /> |  |  |  |
| rtx-5060ti-16gb, PQ2_0, q8_0 KV, no drafter, -c 208K | <CurveCell value="46.0" served /> | <CurveCell value="38.2" served /> | <CurveCell value="28.2" served /> |  |  | <CurveCell value="14.5" served /> |  |
| rtx-5060ti-16gb, PTQ1_0, f16 KV, no drafter, -c 136K | <CurveCell value="42.1" served /> | <CurveCell value="37.3" served /> | <CurveCell value="30.1" served /> | <CurveCell value="22.4" depth="135.0K" served /> |  |  |  |
| rtx-5060ti-16gb, PTQ1_0, q8_0 KV, no drafter, -c 240K | <CurveCell value="41.7" served /> | <CurveCell value="34.9" served /> | <CurveCell value="26.5" served /> |  |  |  | <CurveCell value="12.8" served /> |
| rtx-5060ti-16gb, PTQ1_0, f16 KV, refusal-ablation LoRA at scale 1.0, -c 136K | <CurveCell value="40.8" served /> | <CurveCell value="36.2" served /> | <CurveCell value="29.2" served /> | <CurveCell value="22.0" depth="135.0K" served /> |  |  |  |
| m1-max-32gb, PTQ1_0, f16 KV, no drafter, -c 256K, wired 25000 † | <CurveCell value="17.86" served /> | <CurveCell value="16.05" served /> | <CurveCell value="13.05" served /> |  | <CurveCell value="9.07" served /> |  |  |
| m1-max-32gb, PQ2_0, f16 KV, no drafter, -c 256K, wired 25000 † | <CurveCell value="17.05" /> | <CurveCell value="12.26" /> | <CurveCell value="7.91" /> |  |  |  |  |

The served arm of each config is in bold. A pill under a reading is the depth it was read at, where the arms of that column did not share one.

† read with the context-creep tool of an earlier version of this project, not with `llama-benchy` on real text. The two methods do not give the same number. A reading stays until a re-run replaces it.
<!-- gen:model-curve:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/kamaji/benchmarks/bonsai-2-27b.md) | 16056† | 18104 | <ScoreCell value="0.988/0.939" sub="100% completion" /> | none | 7/164 | <TokCell shallow="17.9" deep="9.1" /> | 5h37 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 30000† | 32048 | <ScoreCell value="0.982/0.945" sub="100% completion" /> | none | 6/164 | <TokCell shallow="46.3" deep="25.1" /> | 3h03 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 30000† | 32048 | <ScoreCell value="0.982/0.945" sub="100% completion" /> | none | 9/164 | <TokCell shallow="41.7" deep="12.8" /> | 4h05 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 25209† | 27257 | <ScoreCell value="0.982/0.939" sub="100% completion" /> | none | 7/164 | <TokCell shallow="46.0" deep="14.5" /> | 2h56 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 30000† | 32048 | <ScoreCell value="0.976/0.945" sub="100% completion" /> | none | 10/164 | <TokCell shallow="40.8" deep="22.0" /> | 4h34 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 30000† | 32048 | <ScoreCell value="0.970/0.939" sub="100% completion" /> | none | 6/164 | <TokCell shallow="42.1" deep="22.4" /> | 3h16 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.
<!-- gen:model-evalplus:end -->

Every run of this model on every machine, best base score first. The empties column carries the cause word ([what the words mean](../benchmarks/evalplus.md#limits-on-local-hardware)).

## Agent task — Mendel

<!-- gen:model-mendel:start -->
Blind test:

| Model / Config | Score | Wall | Ctx / speed | Out/Total | Ctx use | Bugs | Stats |
|---|--:|--:|--:|--:|--:|---|---|
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/arrietty/reports/bonsai-2-27b.md) | <ScoreCell value="82" top /> | **88 min** | <span class="ctxuse">132k<br><TokCell shallow="42.1" deep="22.4" top-deep /></span> | <span class="ctxuse">120k<br><span class="ms-pill cs-pill cs-pill-gray">15.7M</span></span> | <span class="ctxuse">194%<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 258/0</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 17</span> <span class="ms-pill cs-pill cs-pill-gray">turns 235</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 74%</span></span> |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" />](../setups/arrietty/reports/bonsai-2-27b.md) | <ScoreCell value="77" top /> | **75 min** | <span class="ctxuse">116k<br><TokCell shallow="46.3" deep="25.1" top-shallow top-deep /></span> | <span class="ctxuse">110k<br><span class="ms-pill cs-pill cs-pill-gray">14.8M</span></span> | <span class="ctxuse">193%<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">2 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 230/0</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 13</span> <span class="ms-pill cs-pill cs-pill-gray">turns 231</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 55%</span></span> |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/arrietty/reports/bonsai-2-27b.md) | <ScoreCell value="75" top /> | **82 min** | <span class="ctxuse">132k<br><TokCell shallow="40.8" deep="22.0" top-deep /></span> | <span class="ctxuse">105k<br><span class="ms-pill cs-pill cs-pill-gray">17.3M</span></span> | <span class="ctxuse">194%<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">1 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 269/14</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 15</span> <span class="ms-pill cs-pill cs-pill-gray">turns 249</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 48%</span></span> |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/arrietty/reports/bonsai-2-27b.md) | <ScoreCell value="73.5" /> | 123 min | <span class="ctxuse">**236k**†<br><TokCell shallow="41.7" deep="12.8" /></span> | <span class="ctxuse">125k<br><span class="ms-pill cs-pill cs-pill-gray">26.0M</span></span> | **93%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">3 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 254/0</span> <span class="ms-pill cs-pill cs-pill-gray">commits 17</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">turns 256</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 1m</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 50%</span></span> |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" />](../setups/arrietty/reports/bonsai-2-27b.md) | <ScoreCell value="60.5" /> | 92 min | <span class="ctxuse">**204k**<br><TokCell shallow="46.0" deep="14.5" top-shallow /></span> | <span class="ctxuse">112k<br><span class="ms-pill cs-pill cs-pill-gray">19.6M</span></span> | **92%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">4 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">1 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 245/0</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 16</span> <span class="ms-pill cs-pill cs-pill-gray">turns 216</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 65%</span></span> |

Older prompt versions of these runs are on [the agent-task page](../benchmarks/mendel.md).
<!-- gen:model-mendel:end -->

The window cell is the harness context window of that run.

## What the numbers say

- **One model in two packings, not two models.** Both hold the same
  ternary weights: one gives each trit a 2-bit slot at 2.13 bits per
  weight, the other packs trits densely at 1.75. The publisher reports
  no quality difference and picks by hardware, and this card agrees:
  the 2-bit-slot pack decodes faster here at every depth, and the dense
  pack buys 32K more window.
- **It changed what a 16 GB card holds.** The packings cost 6.71 and
  5.54 GiB, so the KV cache becomes the large allocation, not the
  model. The card serves 208K tokens on the larger packing and 240K on
  the smaller one, where every 12 GiB 27B build on the same machine
  serves 64K.
- **The window is used, not offered.** The blind agent row peaked at
  192679 tokens of a 208896 window, 92.2%, with zero compactions. It is
  the first row in this project where the agent task itself went past
  64K.
- **The fastest and the highest-scoring 27B build on that card**: 46.0
  tok/s at 4K, and 0.982 / 0.939 on HumanEval+ with no empty answer
  under a 25209-token thinking budget.
- **The agent score does not follow the quality gate.** 59.5 blind,
  against 91 for a 3-bit build of another model on the same machine.
  The row completed with 16 commits, no repetition loop and no nudge,
  so the loss is judgment: a critical regression that deletes a debug
  file in an exit hook, a missed trap, no dependency pruning, and a
  formatter left failing.
- **A fork is the only backend.** Stock llama.cpp has no Hadamard
  activation runtime, so it rejects these packings and makes garbage
  from the plain 2-bit file. The fork release is part of each row's
  identity.

## Against Ternary Bonsai-27B

<!-- gen:model-compare:start -->
Every config of both models, ranked together. The other model is [Ternary Bonsai-27B](./bonsai-27b.md).

| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" hide="server" top /> | 135k | <TokCell shallow="42.1" deep="22.4" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.970/0.939†" sub="100% completion" /> | <ScoreCell value="82" pill="mendel-blind" top /> | <span title="EvalPlus 3h16 · Mendel 1h28"><b>4h44</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" hide="server" top /> | 119k | <TokCell shallow="46.3" deep="25.1" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.982/0.945†" sub="100% completion" top /> | <ScoreCell value="77" pill="mendel-blind" top /> | <span title="EvalPlus 3h03 · Mendel 1h15"><b>4h17</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" hide="server" top /> | 135k | <TokCell shallow="40.8" deep="22.0" cap="mem" top-deep /> | <ScoreCell value="0.976/0.945†" sub="100% completion" top /> | <ScoreCell value="75" pill="mendel-blind" top /> | <span title="EvalPlus 4h34 · Mendel 1h22"><b>5h56</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" hide="server" top /> | **240k** | <TokCell shallow="41.7" deep="12.8" cap="mem" top-shallow /> | <ScoreCell value="0.982/0.945†" sub="100% completion" top /> | <ScoreCell value="73.5" pill="mendel-blind" top /> | <span title="EvalPlus 4h05 · Mendel 2h03"><b>6h08</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" hide="server" top /> | **208k** | <TokCell shallow="46.0" deep="14.5" cap="mem" top-shallow /> | <ScoreCell value="0.982/0.939†" sub="100% completion" top /> | <ScoreCell value="60.5" pill="mendel-blind" /> | <span title="EvalPlus 2h56 · Mendel 1h32"><b>4h29</b></span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" hide="server" /> | 40k | <TokCell shallow="24.5" deep="17.3" cap="mem" stale /> | <ScoreCell value="0.933/0.902" sub="99% completion" /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 19h24 · Mendel 5h00">24h24</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" /> | 33k | <TokCell shallow="14.7" deep="7.8" cap="speed" /> | <ScoreCell value="0.927/0.890†" sub="98% completion" /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" /> | <span title="EvalPlus 9h55 · Mendel 5h00">14h55</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/bonsai2-prism-ptq1" hide="server" /> | 160k | <TokCell shallow="17.9" deep="9.1" cap="mem" /> | <ScoreCell value="0.988/0.939†" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 5h37 · Mendel —">5h37†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" /> | 2x48k | <TokCell shallow="14.9" deep="7.8" cap="speed" stale /> | <ScoreCell value="0.927/0.890†" sub="98% completion" /> | <ScoreCell value="pending" /> | <span title="EvalPlus 9h55 · Mendel —">9h55†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" hide="server" /> | 40k | <TokCell shallow="24.5" deep="17.3" cap="mem" stale /> | <ScoreCell value="0.927/0.902" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h46 · Mendel 3h07"><b>3h53</b></span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" /> | 131k | <TokCell shallow="15.0" deep="9.7" cap="mem" stale /> | <ScoreCell value="pending" /> | <ScoreCell value="12.5" note="13%" pill="mendel-guided" /> | <span title="EvalPlus — · Mendel 3h15">3h15†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-compare:end -->

Generation 1 carried 8 GB of weights and never reached a usable window
on the Mac: 33K at its scored config, 131K at f16 KV. It has no
complete agent row, because MLX dies near 47K and the fork floors at
33K. Generation 2 carries less weight, holds far more context, and
finishes the task. The quality gate moved with it, from 0.933 / 0.902
to 0.982 / 0.939.
