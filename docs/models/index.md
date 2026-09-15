# Models

The best config of each model, on any machine. The label under each
name is the machine.

<!-- gen:models-best:start -->
| Model / Config | Ctx | Cap | tok/s | EvalPlus | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" hide="server" top /> | 72k | mem | <TokCell shallow="12.4" deep="9.7" /> | <ScoreCell value="0.957/0.939" sub="96% completion" top /> | <ScoreCell value="93" pill="mendel-blind" top /> | — / 3h33 |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" hide="server" top /> | 82k | speed | <TokCell shallow="43.7" deep="13.0" top-shallow /> | <ScoreCell value="0.939/0.921" sub="97% completion" /> | <ScoreCell value="83" pill="mendel-guided" top /> | — / 1h32 |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" hide="server" /> | **197k** | mem | <TokCell shallow="60.1" deep="19.1" top-shallow top-deep /> | <ScoreCell value="0.884/0.860" sub="89% completion" /> | <ScoreCell value="47.5" pill="mendel-blind" /> | — / 1h21 |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" hide="server" /> | **245k** | mem | <TokCell shallow="25.0" deep="9.2" /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> | — / 1h38 |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" hide="server" /> | 40k | mem | <TokCell shallow="24.5" deep="17.3" stale top-deep /> | <ScoreCell value="0.915/0.884" sub="97% completion" /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" /> | — / 5h00 |

† from an earlier serving config or method; re-run pending.

[Qwen3.8-27B](./qwen3.8-27b.md) · [Qwen3.6-35B-A3B](./qwen3.6-35b-a3b.md) · [Gemma-4-26B-A4B](./gemma-4-26b-a4b.md) · [Gemma-4-12B](./gemma-4-12b-it.md) · [Ternary-Bonsai-27B](./bonsai-27b.md)
<!-- gen:models-best:end -->

Columns and sort: [the legend](../#legend).
