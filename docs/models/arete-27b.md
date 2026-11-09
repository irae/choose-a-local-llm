# Arete-27B

[Publisher model card](https://huggingface.co/NousResearch/Arete-27B). Full quality and agent results are pending.

## Configurations

<!-- gen:model-all:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Arete-27B" quant="Q3_K_M" server="llama-server" publisher="bartowski" repo="bartowski/NousResearch_Arete-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/arete-bartowski-q3km" hide="server" top /> | **64k** | <TokCell shallow="27.60" deep="20.07" cap="mem" top-shallow top-deep /> | <ScoreCell value="pending" /> | <ScoreCell value="pending" /> | — |
<!-- gen:model-all:end -->

## Files

<!-- gen:model-binaries:start -->
- [Arete-27B Q3_K_M (bartowski)](../binaries/arete-bartowski-q3km.md) — rtx-5060ti-16gb
<!-- gen:model-binaries:end -->

## Speed and context

<!-- gen:model-curve:start -->
| arm | 4K | 24K | 32K | 64K |
|---|--:|--:|--:|--:|
| rtx-5060ti-16gb, Q3_K_M, q8_0 KV, no drafter, -c 64K | <CurveCell value="27.6" served /> | <CurveCell value="24.49" served /> | <CurveCell value="23.4" served /> | <CurveCell value="20.07" served /> |

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
