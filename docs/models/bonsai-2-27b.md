# Ternary Bonsai-2-27B

Every config of this model, on every machine, best first. It is a
different model from [Ternary Bonsai-27B](./bonsai-27b.md), not a
re-quantization of it, and the two are compared at the end of this page.

<!-- gen:model-all:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" hide="server" top /> | **208k** | <TokCell shallow="46.0" deep="14.5" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="59.5" pill="mendel-blind" top /> | <span title="EvalPlus 2h56 · Mendel 1h32"><b>4h29</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" hide="server" top /> | 119k | <TokCell shallow="46.3" deep="25.1" cap="mem" top-shallow top-deep /> | <ScoreCell value="pending" /> | <ScoreCell value="72" pill="mendel-blind" top /> | <span title="EvalPlus — · Mendel 1h15">1h15†</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" hide="server" top /> | **240k** | <TokCell shallow="41.7" deep="12.8" cap="mem" top-deep /> | <ScoreCell value="pending" /> | <ScoreCell value="57.5" pill="mendel-blind" top /> | <span title="EvalPlus — · Mendel 2h03">2h03†</span> |
<!-- gen:model-all:end -->

## Files

Every file of this model, on every machine that served it, with every run and a log.

<!-- gen:model-binaries:start -->
- [Ternary-Bonsai-2-27B PQ2_0 (prism-ml, prism fork)](../binaries/bonsai2-prism-pq2.md) — rtx-5060ti-16gb
- [Ternary-Bonsai-2-27B PTQ1_0 (prism-ml, prism fork)](../binaries/bonsai2-prism-ptq1.md) — rtx-5060ti-16gb
<!-- gen:model-binaries:end -->

## Speed and context

<!-- gen:model-curve:start -->
| arm | 4K | 24K | 64K | 128K | 208K | 240K |
|---|--:|--:|--:|--:|--:|--:|
| rtx-5060ti-16gb, PQ2_0, f16 KV, no drafter, -c 120K | <CurveCell value="46.3" /> | <CurveCell value="40.5" /> | <CurveCell value="32.2" /> | <CurveCell value="25.1" /> |  |  |
| rtx-5060ti-16gb, PQ2_0, q8_0 KV, no drafter, -c 208K | <CurveCell value="46.0" served /> | <CurveCell value="38.2" served /> | <CurveCell value="28.2" served /> |  | <CurveCell value="14.5" served /> |  |
| rtx-5060ti-16gb, PTQ1_0, q8_0 KV, no drafter, -c 240K | <CurveCell value="41.7" served /> | <CurveCell value="34.9" served /> | <CurveCell value="26.5" served /> |  |  | <CurveCell value="12.8" served /> |

The served arm of each config is in bold. A pill under a reading is the depth it was read at, where the arms of that column did not share one.
<!-- gen:model-curve:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 27257 | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | none | <TokCell shallow="46.0" deep="14.5" /> | 2h56 |
<!-- gen:model-evalplus:end -->

Every run of this model on every machine, best base score first. The empties column carries the cause word ([what the words mean](../benchmarks/evalplus.md#limits-on-local-hardware)).

## Agent task — Mendel

<!-- gen:model-mendel:start -->
Blind test:

| Model / Config | Score | Wall | Ctx / speed | Out/Total | Ctx use | Bugs | Stats |
|---|--:|--:|--:|--:|--:|---|---|
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" />](../setups/arrietty/reports/bonsai-2-27b.md) | <ScoreCell value="72" top /> | **75 min** | <span class="ctxuse">120k<br><TokCell shallow="46.3" deep="25.1" top-shallow top-deep /></span> | <span class="ctxuse">110k<br><span class="ms-pill cs-pill cs-pill-gray">14.8M</span></span> | <span class="ctxuse">193%<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">2 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 230/0</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 13</span> <span class="ms-pill cs-pill cs-pill-gray">turns 231</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 55%</span></span> |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" />](../setups/arrietty/reports/bonsai-2-27b.md) | <ScoreCell value="59.5" top /> | **92 min** | <span class="ctxuse">**208k**<br><TokCell shallow="46.0" deep="14.5" top-shallow top-deep /></span> | <span class="ctxuse">112k<br><span class="ms-pill cs-pill cs-pill-gray">19.6M</span></span> | **92%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">3 medium</span> <span class="ms-pill cs-pill cs-pill-gray">1 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 245/0</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 16</span> <span class="ms-pill cs-pill cs-pill-gray">turns 216</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 65%</span></span> |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/arrietty/reports/bonsai-2-27b.md) | <ScoreCell value="57.5" top /> | 123 min | <span class="ctxuse">**256k**<br><TokCell shallow="41.7" deep="12.8" top-deep /></span> | <span class="ctxuse">125k<br><span class="ms-pill cs-pill cs-pill-gray">26.0M</span></span> | **93%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">2 medium</span> <span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 254/0</span> <span class="ms-pill cs-pill cs-pill-gray">commits 17</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">turns 256</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 1m</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 50%</span></span> |

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
Every config of [Ternary Bonsai-27B](./bonsai-27b.md), for reading beside the table above.

| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" hide="server" top /> | **40k** | <TokCell shallow="24.5" deep="17.3" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="0.933/0.902" sub="99% completion" top /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" top /> | <span title="EvalPlus 19h24 · Mendel 5h00">24h24</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" top /> | 33k | <TokCell shallow="14.7" deep="7.8" cap="speed" top-shallow /> | <ScoreCell value="0.927/0.890" sub="98% completion" top /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 9h55 · Mendel 5h00"><b>14h55</b></span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" /> | **2x48k** | <TokCell shallow="14.9" deep="7.8" cap="speed" stale top-shallow /> | <ScoreCell value="0.927/0.890" sub="98% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 9h55 · Mendel —">9h55†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" hide="server" /> | **40k** | <TokCell shallow="24.5" deep="17.3" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="0.927/0.902" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h46 · Mendel 3h07"><b>3h53</b></span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" /> | **131k** | <TokCell shallow="15.0" deep="9.7" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="pending" /> | <ScoreCell value="12.5" note="13%" pill="mendel-guided" /> | <span title="EvalPlus — · Mendel 3h15">3h15†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-compare:end -->

Generation 1 carried 8 GB of weights and never reached a usable window
on the Mac: 33K at its scored config, 131K at f16 KV. It has no
complete agent row, because MLX dies near 47K and the fork floors at
33K. Generation 2 carries less weight, holds far more context, and
finishes the task. The quality gate moved with it, from 0.933 / 0.902
to 0.982 / 0.939.
