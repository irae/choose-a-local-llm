# Ternary Bonsai-27B

Every config of this model, on every machine, best first. Its successor
is [Ternary Bonsai-2-27B](./bonsai-2-27b.md), a different model rather
than a re-quantization, and the two are compared at the end of this
page.

<!-- gen:model-all:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" hide="server" top /> | **40k** | <TokCell shallow="24.5" deep="17.3" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="0.933/0.902" sub="99% completion" top /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" top /> | <span title="EvalPlus 19h24 · Mendel 5h00">24h24</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" top /> | 33k | <TokCell shallow="14.7" deep="7.8" cap="speed" top-shallow /> | <ScoreCell value="0.927/0.890†" sub="98% completion" top /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 9h55 · Mendel 5h00"><b>14h55</b></span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" /> | **2x48k** | <TokCell shallow="14.9" deep="7.8" cap="speed" stale top-shallow /> | <ScoreCell value="0.927/0.890†" sub="98% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 9h55 · Mendel —">9h55†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" hide="server" /> | **40k** | <TokCell shallow="24.5" deep="17.3" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="0.927/0.902" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h46 · Mendel 3h07"><b>3h53</b></span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" /> | **131k** | <TokCell shallow="15.0" deep="9.7" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="pending" /> | <ScoreCell value="12.5" note="13%" pill="mendel-guided" /> | <span title="EvalPlus — · Mendel 3h15">3h15†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-all:end -->

## Files

Every file of this model, on every machine that served it, with every run and a log.

<!-- gen:model-binaries:start -->
- [Ternary-Bonsai-27B MLX 2-bit (prism-ml)](../binaries/bonsai-mlx-2bit.md) — m1-max-32gb
- [Ternary-Bonsai-27B Q2_g64 (prism-ml, prism fork)](../binaries/bonsai-prism-q2g64.md) — m1-max-32gb
<!-- gen:model-binaries:end -->

## Speed and context

<!-- gen:model-curve:start -->
| arm | 4K | 8K | 16K | 24K | 32K | 40K | 48K | 64K | 80K | 96K | 128K |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| m1-max-32gb, 2-bit, f16 KV, no drafter (MLX), wired 24000 † | <CurveCell value="24.5" /> | <CurveCell value="24.2" /> | <CurveCell value="22.9" /> | <CurveCell value="22.0" depth="24.0K" /> | <CurveCell value="20.5" depth="32.0K" /> | <CurveCell value="12.1" depth="44.0K" /> | <CurveCell value="17.69" depth="56.0K" /> | <CurveCell value="17.27" depth="58.0K" /> |  |  |  |
| m1-max-32gb, Q2_g64, f16 KV, no drafter (prism fork), -c 128K, wired 25000 † | <CurveCell value="14.95" /> | <CurveCell value="16.25" /> | <CurveCell value="15.62" /> | <CurveCell value="15.07" depth="25.0K" /> | <CurveCell value="14.45" depth="33.0K" /> | <CurveCell value="13.92" depth="41.0K" /> | <CurveCell value="13.4" depth="49.0K" /> | <CurveCell value="12.5" depth="66.0K" /> | <CurveCell value="11.45" /> | <CurveCell value="10.76" /> | <CurveCell value="9.67" /> |
| m1-max-32gb, Q4_0 KV + bias, no drafter (prism fork), wired 24000 † | <CurveCell value="14.79" /> | <CurveCell value="13.22" /> | <CurveCell value="10.77" /> | <CurveCell value="9.08" depth="24.0K" /> | <CurveCell value="7.85" depth="32.0K" /> |  |  |  |  |  |  |

The served arm of each config is in bold. A pill under a reading is the depth it was read at, where the arms of that column did not share one.

† read with the context-creep tool of an earlier version of this project, not with `llama-benchy` on real text. The two methods do not give the same number. A reading stays until a re-run replaces it.
<!-- gen:model-curve:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" />](../setups/kamaji/benchmarks/bonsai-27b.md) | —† | 10240 | <ScoreCell value="0.933/0.902" sub="99% completion" /> | 2 budget | — | <TokCell shallow="24.5" deep="17.3" /> | 19h24 |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" />](../setups/kamaji/benchmarks/bonsai-27b.md) | —† | 10240 | <ScoreCell value="0.927/0.890" sub="98% completion" /> | 4 budget | — | <TokCell shallow="14.7" deep="7.8" /> | 9h55 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.
<!-- gen:model-evalplus:end -->

Every run of this model on every machine, best base score first. The empties column carries the cause word ([what the words mean](../benchmarks/evalplus.md#limits-on-local-hardware)).

## Agent task — Mendel

<!-- gen:model-mendel:start -->
Blind test:

| Model / Config | Score | Wall | Ctx / speed | Out/Total | Ctx use | Bugs | Stats |
|---|--:|--:|--:|--:|--:|---|---|
| [<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" />](../setups/kamaji/reports/bonsai-27b.md) | <ScoreCell value="37.5" note="38%" top /> | **300 min** | **56k** | <span class="ctxuse">35k<br><span class="ms-pill cs-pill cs-pill-gray">3.6M</span></span> | **87%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 135/25</span> <span class="ms-pill cs-pill cs-pill-gray">commits 4</span> <span class="ms-pill cs-pill cs-pill-red">failed commits 3</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">turns 149</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 3t 1m</span> <span class="ms-pill cs-pill cs-pill-red">loop thinking</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 13%</span></span> |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" />](../setups/kamaji/reports/bonsai-27b.md) | <ScoreCell value="12.5" note="13%" top /> | **43 min** | **64k** | <span class="ctxuse">16k<br><span class="ms-pill cs-pill cs-pill-gray">1.7M</span></span> | **77%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 76/22</span> <span class="ms-pill cs-pill cs-pill-gray">commits 2</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 4</span> <span class="ms-pill cs-pill cs-pill-gray">turns 79</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 69%</span></span> |

Guided test:

| Model / Config | Score | Wall | Ctx / speed | Out/Total | Ctx use | Bugs | Stats |
|---|--:|--:|--:|--:|--:|---|---|
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" />](../setups/kamaji/reports/bonsai-27b.md) | <ScoreCell value="31.5" note="38%" top /> | 300 min | **64k** | 0k | <span class="ctxuse">1096%<br><span class="ms-pill cs-pill cs-pill-yellow">10 compactions</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">2 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">4 medium</span> <span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 343/96</span> <span class="ms-pill cs-pill cs-pill-gray">commits 3</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 352</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 35%</span></span> |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" />](../setups/kamaji/reports/bonsai-27b.md) | <ScoreCell value="12.5" note="13%" top /> | 300 min | **56k** | <span class="ctxuse">18k<br><span class="ms-pill cs-pill cs-pill-gray">3.6M</span></span> | **80%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">1 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 122/0</span> <span class="ms-pill cs-pill cs-pill-gray">commits 1</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">turns 128</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 2t</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 61%</span></span> |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" />](../setups/kamaji/reports/bonsai-27b.md) | <ScoreCell value="12.5" note="13%" top /> | **195 min** | **128k** | <span class="ctxuse">65k<br><span class="ms-pill cs-pill cs-pill-gray">21.0M</span></span> | <span class="ctxuse">**197%**<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">2 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 376/74</span> <span class="ms-pill cs-pill cs-pill-gray">commits 2</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 307</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 1m</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 53%</span></span> |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" />](../setups/kamaji/reports/bonsai-27b.md) | <ScoreCell value="0" note="0%" /> | **187 min** | **56k** | <span class="ctxuse">13k<br><span class="ms-pill cs-pill cs-pill-gray">2.0M</span></span> | **47%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">model-failed</span> <span class="ms-pill cs-pill cs-pill-gray">calls 105/93</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 0</span> <span class="ms-pill cs-pill cs-pill-gray">turns 105</span> <span class="ms-pill cs-pill cs-pill-red">loop tool call</span></span> |

Older prompt versions of these runs are on [the agent-task page](../benchmarks/mendel.md).
<!-- gen:model-mendel:end -->

The window cell is the harness context window of that run.

## What the numbers say

- **The ternary claim holds up.** 0.933 / 0.902 on MLX 2-bit and
  0.927 / 0.890 on the fork with the vendor's q4 KV bias, from 8 GB of
  weights.
- **No complete agent row.** MLX dies near 47K under the agent task;
  the fork at q4_0 KV floors at 33K used tokens; at f16 KV it holds
  131K and scored 12.5 guided on 1 of 8. Thinking off looped on
  identical commands and is not run again.
- **The fork is the path.** It is the only backend for the ternary
  GGUF, its q4 KV calibration and the DSpark drafter, and two 48K slots
  leave the Mac usable while an agent runs.
- **The retry rule was born here.** A model that does not finish the
  task cannot score as if it had; a retry after a model failure loses
  points for each earlier valid attempt.
- **Pending**: the fork's EvalPlus at f16 KV, and a guided agent row
  under a thinking budget if the fork build takes the flag.

## Against Ternary Bonsai-2-27B

<!-- gen:model-compare:start -->
Every config of both models, ranked together. The other model is [Ternary Bonsai-2-27B](./bonsai-2-27b.md).

| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" hide="server" top /> | 135k | <TokCell shallow="42.1" deep="22.4" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | <ScoreCell value="82" pill="mendel-blind" top /> | <span title="EvalPlus 2h05 · Mendel 1h28"><b>3h33</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" hide="server" top /> | 119k | <TokCell shallow="46.3" deep="25.1" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | <ScoreCell value="77" pill="mendel-blind" top /> | <span title="EvalPlus 2h01 · Mendel 1h15"><b>3h16</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" hide="server" top /> | 135k | <TokCell shallow="40.8" deep="22.0" cap="mem" top-deep /> | <ScoreCell value="0.976/0.945†" sub="100% completion" top /> | <ScoreCell value="75" pill="mendel-blind" top /> | <span title="EvalPlus 4h34 · Mendel 1h22"><b>5h56</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" hide="server" top /> | **240k** | <TokCell shallow="41.7" deep="12.8" cap="mem" top-shallow /> | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | <ScoreCell value="73.5" pill="mendel-blind" top /> | <span title="EvalPlus 2h20 · Mendel 2h03"><b>4h23</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" hide="server" top /> | **208k** | <TokCell shallow="46.0" deep="14.5" cap="mem" top-shallow /> | <ScoreCell value="0.988/0.945" sub="100% completion" top /> | <ScoreCell value="60.5" pill="mendel-blind" /> | <span title="EvalPlus 1h59 · Mendel 1h32"><b>3h31</b></span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" hide="server" /> | 40k | <TokCell shallow="24.5" deep="17.3" cap="mem" stale /> | <ScoreCell value="0.933/0.902" sub="99% completion" /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 19h24 · Mendel 5h00">24h24</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" /> | 33k | <TokCell shallow="14.7" deep="7.8" cap="speed" /> | <ScoreCell value="0.927/0.890†" sub="98% completion" /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" /> | <span title="EvalPlus 9h55 · Mendel 5h00">14h55</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/bonsai2-prism-ptq1" hide="server" /> | 160k | <TokCell shallow="17.9" deep="9.1" cap="mem" /> | <ScoreCell value="0.988/0.939†" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 5h37 · Mendel —">5h37†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" /> | 2x48k | <TokCell shallow="14.9" deep="7.8" cap="speed" stale /> | <ScoreCell value="0.927/0.890†" sub="98% completion" /> | <ScoreCell value="pending" /> | <span title="EvalPlus 9h55 · Mendel —">9h55†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" hide="server" /> | 40k | <TokCell shallow="24.5" deep="17.3" cap="mem" stale /> | <ScoreCell value="0.927/0.902" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h46 · Mendel 3h07"><b>3h53</b></span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" /> | 131k | <TokCell shallow="15.0" deep="9.7" cap="mem" stale /> | <ScoreCell value="pending" /> | <ScoreCell value="12.5" note="13%" pill="mendel-guided" /> | <span title="EvalPlus — · Mendel 3h15">3h15†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-compare:end -->

The successor is the same idea with less weight and a far larger
window: 6.71 and 5.54 GiB against this model's 8 GB, 208K and 240K
tokens of context on a 16 GB card, and a blind agent row that finishes.
This generation's rows stay as the record of what the first ternary
build did.
