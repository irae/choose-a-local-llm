# S5-nano

[Publisher model card](https://huggingface.co/maritaca-ai/S5-nano). Full quality and agent results are pending.

## Configurations

<!-- gen:model-all:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/s5-nano-maritaca-q8" hide="server" top /> | **261k** | <TokCell shallow="77.37" deep="30.59" cap="mem" top-shallow top-deep /> | <ScoreCell value="pending" /> | <ScoreCell value="pending" /> | — |
<!-- gen:model-all:end -->

## Files

<!-- gen:model-binaries:start -->
- [S5-nano Q8_0 (Maritaca AI)](../binaries/s5-nano-maritaca-q8.md) — rtx-5060ti-16gb
<!-- gen:model-binaries:end -->

## Speed and context

<!-- gen:model-curve:start -->
| arm | 4K | 24K | 32K | 64K | 128K | 192K | 240K | 256K |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| rtx-5060ti-16gb, Q8_0, q8_0 KV, no drafter, -c 256K | <CurveCell value="77.37" served /> | <CurveCell value="69.0" served /> | <CurveCell value="66.01" served /> | <CurveCell value="56.76" served /> | <CurveCell value="44.29" served /> | <CurveCell value="36.16" served /> | <CurveCell value="31.76" served /> | <CurveCell value="30.59" served /> |

The served arm of each config is in bold. A pill under a reading is the depth it was read at, where the arms of that column did not share one.
<!-- gen:model-curve:end -->

## Quality

<!-- gen:model-evalplus:start -->
No EvalPlus run yet.
<!-- gen:model-evalplus:end -->

## Agent task

<!-- gen:model-mendel:start -->
No agent run yet.
<!-- gen:model-mendel:end -->
