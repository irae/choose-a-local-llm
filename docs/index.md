# Local coding models, measured

Which local model, runtime and config to code with, per machine. Every
number comes from an OpenAI-compatible server that a coding harness
uses.

## Best config per build

The label under each name is the machine.

<!-- gen:models-evaluated:all:start -->
| Model / Config | Ctx | Cap | tok/s | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" top /> | 72k | mem | <TokCell shallow="12.4" deep="9.7" /> | <ScoreCell value="0.957/0.939" sub="96% completion" /> | <ScoreCell value="93" pill="mendel-blind" top /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" top /> | 82k | speed | <TokCell shallow="43.7" deep="13.0" /> | <ScoreCell value="0.939/0.921" sub="97% completion" /> | <ScoreCell value="83" pill="mendel-guided" top /> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" top /> | 147k | speed | <TokCell shallow="14.1" deep="8.1" /> | <ScoreCell value="0.945/0.921" sub="97% completion" /> | <ScoreCell value="80.5" pill="mendel-blind" top /> |
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" kv="f16" effort="medium" hardware="m1-max-32gb" /> | 104k | mem | <TokCell shallow="14.3" deep="9.6" /> | <ScoreCell value="0.988/0.927" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" /> | 197k | mem | <TokCell shallow="60.1" deep="19.1" top-shallow /> | <ScoreCell value="0.884/0.860" sub="89% completion" /> | <ScoreCell value="47.5" pill="mendel-blind" /> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" /> | **245k** | mem | <TokCell shallow="25.0" deep="9.2" /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" hardware="m1-max-32gb" /> | 37k | mem | <TokCell shallow="54.5" deep="39.1" top-shallow /> | <ScoreCell value="0.939/0.921" sub="97% completion" /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" /> | 40k | mem | <TokCell shallow="24.5" deep="17.3" stale /> | <ScoreCell value="0.915/0.884" sub="97% completion" /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" /> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" /> | 33k | speed | <TokCell shallow="14.7" deep="7.8" /> | <ScoreCell value="0.927/0.890" sub="98% completion" /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" /> |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" hardware="m1-max-32gb" /> | 25k | mem | <TokCell shallow="17.3" deep="14.8" /> | <ScoreCell value="0.976/0.927" sub="100% completion" top /> | <ScoreCell value="12.5†" note="13%" pill="mendel-blind" /> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" /> | 65k | mem | <TokCell shallow="29.43" deep="21.13" /> | <ScoreCell value="pending" /> | <ScoreCell value="91" pill="mendel-blind" top /> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" /> | 147k | speed | <TokCell shallow="13.60" deep="7.97" /> | <ScoreCell value="pending" /> | <ScoreCell value="90.5" pill="mendel-blind" top /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" /> | 97k | mem | <TokCell shallow="61.16" deep="45.42" top-shallow top-deep /> | <ScoreCell value="pending" /> | <ScoreCell value="48.5" note="75%" pill="mendel-guided" /> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" /> | 97k | mem | <TokCell shallow="58.77" deep="45.59" top-shallow top-deep /> | <ScoreCell value="pending" /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" /> | **261k** | mem | <TokCell shallow="49.55" deep="33.11" /> | <ScoreCell value="pending" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> |

† from an earlier serving config or method; re-run pending.
<!-- gen:models-evaluated:all:end -->

¹ LM Studio's MLX engine, retired ([why](./setups/kamaji/lmstudio-retired.md)).
² PrismML's llama.cpp fork, an approved exception to the no-forks rule.

#### Legend

- **Ctx**: the deepest context served at 8 tok/s or more. The harness
  window is Ctx rounded down to a multiple of 4096; on MLX, 5 percent
  under the measured ceiling.
- **Cap**: `mem`, memory ran out first; `speed`, decode fell under
  8 tok/s first.
- **tok/s**: decode on real code text, near an empty context → at
  Ctx.
- **EvalPlus**: HumanEval+ pass@1, base over plus, and the share of
  problems that finished inside the output budget (cap 30000 tokens).
- **Coding**: the Mendel score out of 100, a multi-turn agent task on
  a real repository with known traps. The pill names the test, blind
  or guided. A muted percentage is the share of libraries done when
  the run did not finish. `model-failed`: zero commits.
- **Sort**: the average of EvalPlus base × 100 and Coding; a missing
  score counts as 0. EvalPlus, then Ctx, break ties.

## Machines

| machine | runtimes | pages |
|---|---|---|
| M1 Max 32 GB, `m1-max-32gb` | llama-server, mlx_lm.server, PrismML fork | [comparison](./setups/kamaji/comparison.md) · [setup](./setups/kamaji/index.md) · [historical](./setups/kamaji/historical.md) |
| RTX 5060 Ti 16 GB, `rtx-5060ti-16gb` | llama-server, CUDA | [comparison](./setups/arrietty/comparison.md) · [setup](./setups/arrietty/index.md) |

Every config of one model on every machine: [Models](./models/).

## Method

Read [the methodology](./methodology.md) before you run anything.
Speed is read at depth: one real session read 1.7 tok/s at 135K used
tokens, on a config that read 62 tok/s near an empty context.
