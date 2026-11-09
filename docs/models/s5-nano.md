# S5-nano

[Publisher model card](https://huggingface.co/maritaca-ai/S5-nano). BF16/f16 Think scored 0.841 base and 0.774 plus at a 65,536-token allocation. Q8_0/q8_0 Think scored 0.811 / 0.726. Both completed all 164 problems without empty answers. The full agent task was not run.

## Configurations

<!-- gen:model-all:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/s5-nano-maritaca-q8" hide="server" top /> | **261k** | <TokCell shallow="77.37" deep="30.59" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.811/0.726" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 1h56 · Mendel —">1h56†</span> |
<!-- gen:model-all:end -->

## Files

<!-- gen:model-binaries:start -->
- [S5-nano Q8_0 (Maritaca AI)](../binaries/s5-nano-maritaca-q8.md) — rtx-5060ti-16gb
- [S5-nano BF16 (Maritaca AI)](../binaries/s5-nano-maritaca-bf16.md) — rtx-5060ti-16gb
<!-- gen:model-binaries:end -->

## Speed and context

<!-- gen:model-curve:start -->
| arm | 4K | 24K | 32K | 64K | 128K | 192K | 240K | 256K |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| rtx-5060ti-16gb, Q8_0, q8_0 KV, no drafter, -c 256K | <CurveCell value="77.37" served /> | <CurveCell value="69.0" served /> | <CurveCell value="66.01" served /> | <CurveCell value="56.76" served /> | <CurveCell value="44.29" served /> | <CurveCell value="36.16" depth="192.0K" served /> | <CurveCell value="31.76" served /> | <CurveCell value="30.59" served /> |
| rtx-5060ti-16gb, BF16, f16 KV, no drafter, -c 200K | <CurveCell value="45.68" /> | <CurveCell value="42.46" /> | <CurveCell value="41.35" /> | <CurveCell value="37.31" /> | <CurveCell value="31.23" /> | <CurveCell value="26.41" depth="199.0K" /> |  |  |

The served arm of each config is in bold. A pill under a reading is the depth it was read at, where the arms of that column did not share one.
<!-- gen:model-curve:end -->

## Quality

<!-- gen:model-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="S5-nano" quant="BF16" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/s5-nano-maritaca-bf16" />](../setups/arrietty/benchmarks/s5-nano.md) | 8192 | 16384 | <ScoreCell value="0.841/0.774" sub="100% completion" top /> | none | 31/164 | — | 3h42 |
| [<ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/s5-nano-maritaca-q8" />](../setups/arrietty/benchmarks/s5-nano.md) | 8192 | 16384 | <ScoreCell value="0.811/0.726" sub="100% completion" top /> | none | 26/164 | <TokCell shallow="77.37" deep="30.59" /> | 1h56 |
| [<ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="off" hardware="rtx-5060ti-16gb" page="/binaries/s5-nano-maritaca-q8" />](../setups/arrietty/benchmarks/s5-nano.md) | none | 16384 | <ScoreCell value="0.720/0.634" sub="100% completion" /> | none | 0/164 | <TokCell shallow="77.37" deep="30.59" /> | 0h26 |
<!-- gen:model-evalplus:end -->

## Agent task

<!-- gen:model-mendel:start -->
No agent run yet.
<!-- gen:model-mendel:end -->
