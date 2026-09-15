# Gemma-4-26B-A4B

Every config of this model, on every machine, best first.

<!-- gen:model-all:start -->
| Model / Config | Ctx | Cap | tok/s | EvalPlus | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" hide="server" top /> | **197k** | mem | <TokCell shallow="60.1" deep="19.1" top-shallow /> | <ScoreCell value="0.884/0.860" sub="89% completion" top /> | <ScoreCell value="47.5" pill="mendel-blind" top /> | <span title="EvalPlus — · Mendel 1h21">1h21</span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" hide="server" top /> | **2x82k** | mem | <TokCell shallow="66.6" deep="33.6" stale top-shallow top-deep /> | <ScoreCell value="0.884/0.860" sub="89% completion" top /> | <ScoreCell value="pending" /> | — |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" hide="server" /> | **97k** | mem | <TokCell shallow="58.77" deep="45.59" top-deep /> | <ScoreCell value="pending" /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus — · Mendel 0h23">0h23</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-all:end -->
