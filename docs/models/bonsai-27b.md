# Ternary Bonsai 27B

Both generations of the ternary 27B model, on every machine, best
first. Generation 2 is a different model, not a re-quantization of
generation 1, and its rows carry the base `Ternary-Bonsai-2-27B`. They
share a page because they share a lineage, a publisher and a backend:
neither runs on stock llama.cpp.

<!-- gen:model-all:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" hide="server" top /> | **208k** | <TokCell shallow="46.0" deep="14.5" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="59.5" pill="mendel-blind" top /> | <span title="EvalPlus 2h56 · Mendel 1h32"><b>4h29</b></span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" hide="server" top /> | 40k | <TokCell shallow="24.5" deep="17.3" cap="mem" stale top-deep /> | <ScoreCell value="0.933/0.902" sub="99% completion" top /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" top /> | <span title="EvalPlus 19h24 · Mendel 5h00">24h24</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" top /> | 33k | <TokCell shallow="14.7" deep="7.8" cap="speed" /> | <ScoreCell value="0.927/0.890" sub="98% completion" top /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 9h55 · Mendel 5h00">14h55</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" /> | 2x48k | <TokCell shallow="14.9" deep="7.8" cap="speed" stale /> | <ScoreCell value="0.927/0.890" sub="98% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 9h55 · Mendel —">9h55†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" hide="server" /> | 40k | <TokCell shallow="24.5" deep="17.3" cap="mem" stale top-deep /> | <ScoreCell value="0.927/0.902" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h46 · Mendel 3h07"><b>3h53</b></span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" /> | 131k | <TokCell shallow="15.0" deep="9.7" cap="mem" stale /> | <ScoreCell value="pending" /> | <ScoreCell value="12.5" note="13%" pill="mendel-guided" /> | <span title="EvalPlus — · Mendel 3h15">3h15†</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" hide="server" /> | **240k** | <TokCell shallow="41.7" deep="12.8" cap="mem" top-shallow /> | <ScoreCell value="pending" /> | <ScoreCell value="pending" /> | — |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-all:end -->

## Files

Every file of this model, on every machine that served it, with every run and a log.

<!-- gen:model-binaries:start -->
- [Ternary-Bonsai-27B MLX 2-bit (prism-ml)](../binaries/bonsai-mlx-2bit.md) — m1-max-32gb
- [Ternary-Bonsai-27B Q2_g64 (prism-ml, prism fork)](../binaries/bonsai-prism-q2g64.md) — m1-max-32gb
- [Ternary-Bonsai-2-27B PQ2_0 (prism-ml, prism fork)](../binaries/bonsai2-prism-pq2.md) — rtx-5060ti-16gb
- [Ternary-Bonsai-2-27B PTQ1_0 (prism-ml, prism fork)](../binaries/bonsai2-prism-ptq1.md) — rtx-5060ti-16gb
<!-- gen:model-binaries:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" />](../setups/arrietty/benchmarks/bonsai-27b.md) | 27257 | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | none | <TokCell shallow="46.0" deep="14.5" /> | 2h56 |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" />](../setups/kamaji/benchmarks/bonsai-27b.md) | 10240 | <ScoreCell value="0.933/0.902" sub="99% completion" top /> | 2 budget | <TokCell shallow="24.5" deep="17.3" /> | 19h24 |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" />](../setups/kamaji/benchmarks/bonsai-27b.md) | 10240 | <ScoreCell value="0.927/0.890" sub="98% completion" top /> | 4 budget | <TokCell shallow="14.7" deep="7.8" /> | 9h55 |
<!-- gen:model-evalplus:end -->

Every run of this model on every machine, best base score first. The empties column carries the cause word ([what the words mean](../benchmarks/evalplus.md#limits-on-local-hardware)).

## Agent task — Mendel

<!-- gen:model-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" /> | blind-v1.1 | ?k | **59.5** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" /> | blind-v1.0 | ?k | **37.5** (raw 58) | 3/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" /> | blind-v1.1 | ?k | **37.5** (raw 55) | 3/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" /> | blind-v1.1 | ?k | **12.5** (raw 60.5) | 1/8/done | NaN | — | — | 0 | 0 | 0 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" /> | guided-v2.1 | ?k | **37.5** (raw 69) | 3/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" /> | guided-v3.0 | ?k | **31.5** | 3/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" /> | guided-v3.0 | ?k | **12.5** (raw 59) | 1/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" /> | guided-v3.0 | ?k | **12.5** | 1/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" /> | guided-v3.0 | ?k | **0** (raw 25) | 0/8/done | NaN | — | — | 0 | 0 | 0 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:model-mendel:end -->

The window cell is the harness context window of that run.

## What the numbers say

- **Generation 2 ships one model in two packings, not two models.**
  Both hold the same ternary weights: one gives each trit a 2-bit slot
  at 2.13 bits per weight, the other packs trits densely at 1.75. The
  publisher reports no quality difference and picks by hardware, and
  this card agrees with that guidance: the 2-bit-slot pack decodes
  faster here at every depth, and the dense pack buys 32K more window.
- **Generation 2 is the one that changed what a 16 GB card holds.** Its
  packings cost 6.71 and 5.54 GiB, so the KV cache becomes the large
  allocation, not the model. The card serves 208K tokens on the larger
  packing and 240K on the smaller one, where every 12 GiB 27B build on
  the same machine serves 64K. Generation 1 never reached a usable
  window on the Mac: 33K at its scored config, 131K at f16 KV.
- **Generation 2 is the first row in this project where the agent task
  itself went past 64K.** It peaked at 192679 tokens of a 208896
  window, 92.2%, with zero compactions.
- **The quality gate rises with the generation**: 0.982 / 0.939 at
  effort xhigh on generation 2, against 0.933 / 0.902 on generation 1's
  MLX build and 0.927 / 0.890 on its fork build. Generation 1 carried
  8 GB of weights and generation 2 carries 6.7.
- **The agent task separates them further.** Generation 1 has no
  complete agent row: MLX dies near 47K, the fork at q4_0 KV floors at
  33K, and its best guided row reached 1 of 8 libraries. Generation 2
  completed the blind task with 16 commits, no repetition loop and no
  nudge, and scored 59.5.
- **A fork is the only backend for either generation.** Stock
  llama.cpp has no Hadamard activation runtime, so it rejects the
  ternary packings or makes garbage from them. The fork release is part
  of each row's identity.
- **The retry rule was born here.** A model that does not finish the
  task cannot score as if it had; a retry after a model failure loses
  points for each earlier valid attempt.
- **Pending**: a quality gate and an agent row on generation 2's
  smaller packing, its f16 KV arm, a guided row to pair with its blind
  59.5, and a mainline row for either generation when mainline learns
  these types.
