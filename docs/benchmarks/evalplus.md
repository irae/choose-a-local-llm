# HumanEval+

pass@1 at temperature 0 in fast mode: every model thinks for at most
8192 tokens, then answers, with 16384 tokens of output in total
([method](../methodology/evalplus.md)). One rule for every model, so
the rows compare. The KV cache type does not move a score; a row names
it only where it is part of the quant. Scores measured under an
earlier budget are on each model's page, marked, until the fast-mode
run lands.

<!-- gen:evalplus-table:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-unsloth-ud-q4kxl" />](../setups/arrietty/benchmarks/gemma-4-12b-it.md) | 8192 | 16384 | <ScoreCell value="0.988/0.963" sub="100% completion" top /> | none | 34/164 | <TokCell shallow="47.39" deep="32.18" /> | 3h18 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md) | 8192 | 16384 | <ScoreCell value="0.988/0.957" sub="100% completion" top /> | none | 19/164 | <TokCell shallow="60.1" deep="19.1" /> | 1h57 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma26-catlilface-nvfp4q8" />](../setups/arrietty/benchmarks/gemma-4-26b-a4b.md) | 8192 | 16384 | <ScoreCell value="0.988/0.951" sub="100% completion" top /> | none | 19/164 | <TokCell shallow="58.77" deep="45.59" /> | 2h34 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 8192 | 16384 | <ScoreCell value="0.988/0.945" sub="100% completion" top /> | none | 12/164 | <TokCell shallow="46.0" deep="14.5" /> | 1h59 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/kamaji/benchmarks/bonsai-2-27b.md) | 8192 | 16384 | <ScoreCell value="0.988/0.939" sub="100% completion" top /> | none | 10/164 | <TokCell shallow="17.9" deep="9.1" /> | 4h49 |
| [<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 8192 | 16384 | <ScoreCell value="0.982/0.951" sub="100% completion" top /> | none | 9/164 | <TokCell shallow="12.4" deep="9.7" /> | 5h04 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 8192 | 16384 | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | none | 12/164 | <TokCell shallow="46.3" deep="25.1" /> | 2h01 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 8192 | 16384 | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | none | 16/164 | <TokCell shallow="41.7" deep="12.8" /> | 2h20 |
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-freedomaisvr-nvfp4" />](../setups/arrietty/benchmarks/gemma-4-12b-it.md) | 8192 | 16384 | <ScoreCell value="0.976/0.951" sub="100% completion" top /> | none | 44/164 | <TokCell shallow="49.55" deep="33.11" /> | 3h31 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md) | none | 8192 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | — | <TokCell shallow="60.1" deep="19.1" /> | 0h20 |
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-unsloth-ud-iq3s" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 8192 | 16384 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | 17/164 | <TokCell shallow="13.60" deep="7.97" /> | 6h29 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 8192 | 16384 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | 12/164 | <TokCell shallow="42.1" deep="22.4" /> | 2h05 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 8192 | 16384 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | 18/164 | <TokCell shallow="40.8" deep="22.0" /> | 2h32 |
| [<ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/gemma-4-12b-it.md) | none | 8192 | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | none | — | <TokCell shallow="25.0" deep="9.2" /> | 0h43 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-ista-iq3s-mtp" />](../setups/arrietty/benchmarks/qwen3.8-27b.md) | 8192 | 10240 | <ScoreCell value="0.976/0.933" sub="100% completion" top /> | none | 11/164 | <TokCell shallow="29.43" deep="21.13" /> | 2h55 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" offload="n-cpu-moe 21" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/arrietty/benchmarks/qwen3.6-35b-a3b.md) | 8192 | 16384 | <ScoreCell value="0.976/0.933" sub="100% completion" top /> | none | 12/164 | <TokCell shallow="61.16" deep="45.42" /> | 2h24 |
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-unsloth-ud-iq3s" />](../setups/arrietty/benchmarks/qwen3.8-27b.md) | 8192 | 16384 | <ScoreCell value="0.963/0.921" sub="100% completion" /> | none | 8/164 | <TokCell shallow="29.36" deep="20.92" /> | 3h08 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/qwen3.6-35b-a3b.md) | none | 8192 | <ScoreCell value="0.951/0.915" sub="100% completion" /> | none | — | <TokCell shallow="43.7" deep="13.0" /> | 0h15 |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" />](../setups/kamaji/benchmarks/bonsai-27b.md) | 8192 | 16384 | <ScoreCell value="0.951/0.915" sub="100% completion" /> | none | 4/164 | <TokCell shallow="14.7" deep="7.8" /> | 9h11 |
| [<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-unsloth-ud-q4kxl" />](../setups/arrietty/benchmarks/gemma-4-12b-it.md) | none | 8192 | <ScoreCell value="0.951/0.909" sub="100% completion" /> | none | — | <TokCell shallow="47.39" deep="32.18" /> | 0h26 |
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-freedomaisvr-nvfp4" />](../setups/arrietty/benchmarks/gemma-4-12b-it.md) | none | 8192 | <ScoreCell value="0.927/0.896" sub="100% completion" /> | none | — | <TokCell shallow="49.55" deep="33.11" /> | 0h51 |
| [<ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-lmstudio-mlx-4bit" />](../setups/kamaji/benchmarks/gemma-4-12b-it.md) | none | 30000 | <ScoreCell value="0.909/0.872" sub="100% completion" /> | none | — | <TokCell shallow="34.19" deep="23.23" /> | 1h33 |
<!-- gen:evalplus-table:end -->

- **think**: the thinking budget on the server, 8192 in fast mode;
  `none` for a row with no thinking.
- **budget**: the output budget, thinking and answer together.
- **Empty**: a problem with no answer. It counts as failed.
- **Completion**: the share of the 164 problems that got an answer.
- **forced**: the problems whose thinking hit the budget and were made
  to answer. A forced answer counts by its tests like any other.
- Scores under the uncalibrated budget:
  [historical](../setups/kamaji/historical.md).

## Limits on local hardware

HumanEval+ was built for models that answer at once. A reasoning model
can spend tens of thousands of tokens on one problem, and some of its
thinking never ends: the same few problems loop on every model we
measured. So every run here serves with a thinking budget of 8192
tokens. When the thinking hits it, the server closes it and the model
answers with what it has; the run counts those problems as `forced`.
A forced answer passes most of the time, and the ones that fail loop
or are wrong at any budget: across twelve runs at larger budgets, no
forced answer ever passed with more thinking. The budget is what these
machines can wait for: at 8 to 15 tok/s, 30000 tokens is 35 to 60
minutes on one problem. Why this budget, and what it did to every
score: [the thinking budget](../methodology/reasoning-budget.md).

Read the score with its counts:

- **forced:** how often the model did not converge inside 8192 tokens.
  A low count with a high score is a model that thinks to the point.
- **100% completion:** every problem got an answer, so every lost point
  is code that failed the tests.
- **Under 100%:** an empty has a cause word, explained below. The table
  lists the empty runs measured before fast mode.

| run | budget | empty | cause | pass among answered |
|---|--:|--:|---|--:|
| Qwen3.8-27B Q4_K_M, xhigh | 30000 | 6/164 | budget | 0.993 |
| Qwen3.8-27B ISTA IQ3_S-mtp, xhigh | 30000 | 5/164 | budget | 0.975 |
| Gemma-4-26B-A4B GGUF, thinking on | 30000 | 16/164 | budget | 0.993 |
| Gemma-4-26B-A4B MLX 4-bit, thinking on | 30000 | 31/164 | budget | 0.978 |
| Qwen3.6-35B-A3B GGUF, thinking on | 26624 | 2/164 | budget | 0.969 |
| Ternary-Bonsai-27B MLX 2-bit, thinking on | 10240 | 2/164 | budget | 0.944 |
| Ternary-Bonsai-27B fork q4 KV, thinking on | 10240 | 4/164 | budget | 0.950 |
| Qwen3.8-27B unsloth UD-IQ3_S, xhigh, M1 Max | 20000 | 8/164 | budget | 0.994 |
| Gemma-4-12B NVFP4, thinking on, RTX 5060 Ti | 8192 | 53/164 | † unproven | 0.974 |
| Gemma-4-12B UD-Q4_K_XL, thinking on, RTX 5060 Ti | 8192 | 34/164 | † unproven | 1.000 |
| Gemma-4-26B-A4B NVFP4Q8, thinking on, RTX 5060 Ti | 12500 | 14/164 | † unproven | 0.993 |
| Qwen3.8-27B ISTA IQ3_S-mtp, xhigh, RTX 5060 Ti | 20500 | 7/164 | † unproven | 0.987 |
| Qwen3.6-35B-A3B UD-Q4_K_XL, thinking on, RTX 5060 Ti | 24154 | 6/164 | † unproven | 0.981 |
| Qwen3.8-27B unsloth UD-IQ3_S, xhigh, RTX 5060 Ti | 19000 | 3/164 | † unproven | 0.975 |

**The cause column** says what ended an empty answer. The run's finish
log proves it, one line per problem.

- **`budget`** — the answer was still coming when the output budget ran
  out. Before fast mode the budget was calibrated per model and held at
  30000 tokens or less; a thinking loop also ends this way, so the word
  never said whether more budget would have helped. Fast mode makes it
  rare: the thinking closes at 8192 and the answer keeps 8192 of room.
- **`forced`** — the thinking budget fired and the answer was still no
  code.
- **`model`** — the model ended on its own with no answer, and budget
  was left. More budget changes nothing.
- **`† unproven`** — the run recorded no finish reason, so nothing is
  proven.

Pass among answered is base pass@1 divided by completion.

## Thinking off against thinking on

Thinking off runs HumanEval+ 10 to 40 times faster on the same build,
and its score is level or higher on every build but one:
Gemma-4-26B-A4B GGUF reads 0.976 / 0.945 in 20 minutes at thinking off
and 0.896 / 0.872 in 5h47 at thinking on. Qwen3.6-35B-A3B GGUF is the
exception after its empty problems were re-run: 0.951 / 0.915 in 15
minutes at thinking off against 0.957 / 0.939 in 5h02 at thinking on. On the RTX 5060 Ti the gap is the largest measured: Gemma-4-12B NVFP4
reads 0.927 / 0.896 in 51 minutes at thinking off and 0.659 / 0.640 in
204 minutes at thinking on, with 53 empties. Every thinking-off run here finished under 2
hours, and every run with thinking on or an effort level took 2 hours
or more. The single-turn score does not carry over to the agent task:
Qwen3.6-35B-A3B scored 83 guided at thinking on and 62.5 at thinking
off.
