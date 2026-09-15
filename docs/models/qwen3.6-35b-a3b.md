# Qwen3.6-35B-A3B

Every config of this model, on every machine, best first.

<!-- gen:model-all:start -->
| Model / Config | Ctx | Cap | tok/s | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" hide="server" top /> | **82k** | speed | <TokCell shallow="43.7" deep="13.0" /> | <ScoreCell value="0.939/0.921" sub="97% completion" top /> | <ScoreCell value="83" pill="mendel-guided" top /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" hide="server" top /> | **82k** | speed | <TokCell shallow="43.7" deep="13.0" /> | <ScoreCell value="0.951/0.915" sub="100% completion" top /> | <ScoreCell value="62.5" pill="mendel-guided" top /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" hardware="m1-max-32gb" hide="server" top /> | 66k | mem | <TokCell shallow="50.5" deep="33.6" stale /> | <ScoreCell value="0.939/0.921" sub="97% completion" top /> | <ScoreCell value="50" pill="mendel-blind" /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" hardware="m1-max-32gb" hide="server" /> | 37k | mem | <TokCell shallow="54.5" deep="39.1" /> | <ScoreCell value="0.939/0.921" sub="97% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="f16" effort="on" hardware="m1-max-32gb" hide="server" /> | 41k | mem | <TokCell shallow="69.1" deep="52.6" stale top-shallow top-deep /> | <ScoreCell value="0.939/0.921" sub="97% completion" top /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" hide="server" /> | **97k** | mem | <TokCell shallow="61.16" deep="45.42" top-shallow top-deep /> | <ScoreCell value="pending" /> | <ScoreCell value="48.5" note="75%" pill="mendel-guided" /> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-all:end -->
