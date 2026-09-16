# Gemma-4-26B-A4B

Every config of this model, on every machine, best first.

<!-- gen:model-all:start -->
| Model / Config | Ctx | Cap | tok/s | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" hide="server" top /> | **197k** | mem | <TokCell shallow="60.1" deep="19.1" top-shallow /> | <ScoreCell value="0.896/0.872" sub="90% completion" top /> | <ScoreCell value="47.5" pill="mendel-blind" top /> | <span title="EvalPlus 5h47 · Mendel 1h21">7h08</span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" hide="server" top /> | **97k** | mem | <TokCell shallow="58.77" deep="45.59" top-deep /> | <ScoreCell value="0.909/0.878" sub="91% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 3h35 · Mendel 0h23">3h58</span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" hide="server" /> | **2x82k** | mem | <TokCell shallow="66.6" deep="33.6" stale top-shallow top-deep /> | <ScoreCell value="0.896/0.872" sub="90% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 5h47 · Mendel —">5h47†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-all:end -->

## What the numbers say

- **The deep secondary on the M1 Max.** The unsloth GGUF at f16 KV
  serves 197K at 60 → 17 tok/s and finishes the blind agent task at
  47.5, 8 of 8, at thinking on.
- **Thinking off wins the single-turn test and loses the agent task.**
  0.976 / 0.945 in 20 minutes at thinking off; 0.896 / 0.872 with 16
  empties in almost six hours at thinking on. Both thinking-off agent
  rows ended on a loop of identical edits, so no agent row runs at
  thinking off.
- **The MLX build is retired** after a failed agent smoke; it reads
  0.793 / 0.768 with 31 empties, every one the budget
  ([why](../setups/kamaji/gemma-4-26b-a4b-mlx-retired.md)).
- **On the RTX 5060 Ti the NVFP4Q8 repack** keeps attention at Q8 and
  puts 7 expert layers in host RAM: 97K at 59 → 46 tok/s, 0.909 /
  0.878 with 14 empty at thinking on, guided 37.5 on 3 of 8, ended on
  a text loop.
- **This model loops in both benchmarks.** Its empties at the 30000
  budget are the first case of the thinking-budget test
  ([method](../methodology/evalplus.md#unproven-yet-a-thinking-budget-instead-of-a-larger-output-budget)).
