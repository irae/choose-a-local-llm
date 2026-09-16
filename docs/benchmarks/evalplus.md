# HumanEval+

pass@1 at temperature 0, with an output budget calibrated per model
([method](../methodology/evalplus.md)). The KV cache type does not move
a score; a row names it only where it is part of the quant.

<!-- gen:evalplus-table:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 8886 | <ScoreCell value="0.988/0.927" sub="100% completion" top /> | none | <TokCell shallow="14.3" deep="9.6" /> | 3h11 |
| [<ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" hardware="m1-max-32gb" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 8192 | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | none | <TokCell shallow="17.3" deep="14.8" /> | 3h32 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 8192 | <ScoreCell value="0.976/0.945" sub="99% completion" top /> | 1 cap | <TokCell shallow="15.1" deep="9.7" /> | 3h08 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" hardware="m1-max-32gb" />](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md) | 8192 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | <TokCell shallow="60.1" deep="19.1" /> | 0h20 |
| [<ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" />](../setups/kamaji/benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | none | <TokCell shallow="25.0" deep="9.2" /> | 0h43 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" hardware="m1-max-32gb" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 8192 | <ScoreCell value="0.976/0.933" sub="99% completion" top /> | 1 cap | <TokCell shallow="14.1" deep="8.1" /> | 2h23 |
| [<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" hardware="m1-max-32gb" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 30000 | <ScoreCell value="0.957/0.939" sub="96% completion" top /> | 6 cap | <TokCell shallow="12.4" deep="9.7" /> | 8h30 |
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" />](../setups/arrietty/benchmarks/qwen3.8-27b.md) | 19000 | <ScoreCell value="0.957/0.921" sub="100% completion" top /> | none | <TokCell shallow="29.36" deep="20.92" /> | 4h50 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" />](../setups/kamaji/benchmarks/qwen3.6-35b-a3b.md) | 8192 | <ScoreCell value="0.951/0.915" sub="100% completion" top /> | none | <TokCell shallow="43.7" deep="13.0" /> | 0h15 |
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 20000 | <ScoreCell value="0.945/0.927" sub="95% completion" top /> | † unproven | <TokCell shallow="13.60" deep="7.97" /> | 10h16 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 30000 | <ScoreCell value="0.945/0.921" sub="97% completion" top /> | 5 cap | <TokCell shallow="14.1" deep="8.1" /> | 9h43 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" />](../setups/arrietty/benchmarks/qwen3.8-27b.md) | 20500 | <ScoreCell value="0.945/0.909" sub="100% completion" top /> | none | <TokCell shallow="29.43" deep="21.13" /> | 3h38 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" />](../setups/arrietty/benchmarks/qwen3.6-35b-a3b.md) | 24154 | <ScoreCell value="0.945/0.902" sub="100% completion" top /> | none | <TokCell shallow="61.16" deep="45.42" /> | 3h12 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" />](../setups/kamaji/benchmarks/qwen3.6-35b-a3b.md) | 26624 | <ScoreCell value="0.939/0.921" sub="97% completion" /> | † unproven | <TokCell shallow="43.7" deep="13.0" /> | 4h38 |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" />](../setups/kamaji/benchmarks/bonsai-27b.md) | 10240 | <ScoreCell value="0.927/0.890" sub="98% completion" /> | † unproven | <TokCell shallow="14.7" deep="7.8" /> | 9h19 |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" />](../setups/kamaji/benchmarks/bonsai-27b.md) | 10240 | <ScoreCell value="0.915/0.884" sub="97% completion" /> | † unproven | <TokCell shallow="24.5" deep="17.3" /> | 14h04 |
| [<ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="off" hardware="m1-max-32gb" />](../setups/kamaji/benchmarks/gemma-4-12b-it.md) | 30000 | <ScoreCell value="0.909/0.872" sub="100% completion" /> | none | <TokCell shallow="34.19" deep="23.23" /> | 1h33 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" />](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md) | 30000 | <ScoreCell value="0.884/0.860" sub="89% completion" /> | † unproven | <TokCell shallow="60.1" deep="19.1" /> | 3h47 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/gemma-4-26b-a4b-it-4bit" kv="f16" effort="on" hardware="m1-max-32gb" />](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md) | 30000 | <ScoreCell value="0.713/0.701" sub="72% completion" /> | † unproven | <TokCell shallow="49.3" deep="23.4" /> | 2h16 |
<!-- gen:evalplus-table:end -->

- **Empty**: a problem that ran to the budget with no answer. It counts
  as failed.
- **Completion**: the share of the 164 problems that got an answer.
- RTX 5060 Ti 16 GB: run 19 is scoring every row.
- Scores under the uncalibrated budget:
  [historical](../setups/kamaji/historical.md).

## Limits on local hardware

HumanEval+ was built for models that answer at once. A reasoning model
can spend tens of thousands of tokens on one problem, so every run here
has an output budget, calibrated per model and capped at 30000 tokens
([method](../methodology/evalplus.md)). A problem with no answer inside
the budget is empty, and it counts as failed. The cap is what these
machines can wait for, not the model's ceiling: at 8 to 15 tok/s, 30000
tokens is 35 to 60 minutes on one problem, and an effort-xhigh run
already takes 8h30 to 9h43.

Read the score with its completion:

- **100% completion:** every problem got an answer, so every lost point
  is code that failed the tests. That is the model's own limit.
- **Under 100%:** an empty has one of two causes.
  - **The budget.** The answer was still coming at the cap. More budget
    would likely raise the score.
  - **Thinking that does not converge.** The thinking ends with no
    answer, with budget left. That is the model, at any budget.

| run | budget | empty | cause | pass among answered |
|---|--:|--:|---|--:|
| Qwen3.8-27B Q4_K_M, xhigh | 30000 | 6/164 | cap | 0.993 |
| Qwen3.8-27B ISTA IQ3_S-mtp, xhigh | 30000 | 5/164 | cap | 0.975 |
| Gemma-4-26B-A4B GGUF, thinking on | 30000 | 18/164 | † unproven | 0.993 |
| Gemma-4-26B-A4B MLX 4-bit, thinking on | 30000 | 46/164 | † unproven | 0.991 |
| Qwen3.6-35B-A3B GGUF, thinking on | 26624 | 5/164 | † unproven | 0.969 |
| Ternary-Bonsai-27B MLX 2-bit, thinking on | 10240 | 5/164 | † unproven | 0.944 |
| Ternary-Bonsai-27B fork q4 KV, thinking on | 10240 | 4/164 | † unproven | 0.950 |

Pass among answered is base pass@1 divided by completion.

## Thinking off against thinking on

Thinking off runs HumanEval+ 10 to 40 times faster on the same build,
and its score is level or higher: Gemma-4-26B-A4B GGUF reads 0.976 /
0.945 in 20 minutes at thinking off and 0.884 / 0.860 in 3h47 at
thinking on; Qwen3.6-35B-A3B GGUF reads 0.951 / 0.915 in 15 minutes and
0.939 / 0.921 in 4h38. Every thinking-off run here finished under 2
hours, and every run with thinking on or an effort level took 2 hours
or more. The single-turn score does not carry over to the agent task:
Qwen3.6-35B-A3B scored 83 guided at thinking on and 62.5 at thinking
off.
