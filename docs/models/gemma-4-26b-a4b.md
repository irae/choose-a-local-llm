# Gemma-4-26B-A4B

Every config of this model, on every machine, best first.

<!-- gen:model-all:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" hide="server" top /> | **197k** | <TokCell shallow="60.1" deep="19.1" cap="mem" top-shallow /> | <ScoreCell value="0.896/0.872" sub="90% completion" top /> | <ScoreCell value="47.5" pill="mendel-blind" top /> | <span title="EvalPlus 5h47 · Mendel 1h21">7h08</span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma26-catlilface-nvfp4q8" hide="server" top /> | **97k** | <TokCell shallow="58.77" deep="45.59" cap="mem" top-deep /> | <ScoreCell value="0.909/0.878" sub="91% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 3h35 · Mendel 0h23">3h58</span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" hide="server" /> | **2x82k** | <TokCell shallow="66.6" deep="33.6" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="0.896/0.872" sub="90% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 5h47 · Mendel —">5h47†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-all:end -->

## Files

Every file of this model, on every machine that served it, with every run and a log.

<!-- gen:model-binaries:start -->
- [Gemma-4-26B-A4B UD-Q4_K_XL (unsloth)](../binaries/gemma26-unsloth-ud-q4kxl.md) — m1-max-32gb
- [Gemma-4-26B-A4B MLX 4-bit (mlx-community)](../binaries/gemma26-mlx-4bit.md) — m1-max-32gb
- [Gemma-4-26B-A4B NVFP4Q8 (catlilface)](../binaries/gemma26-catlilface-nvfp4q8.md) — rtx-5060ti-16gb
<!-- gen:model-binaries:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md) | 8192 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | <TokCell shallow="60.1" deep="19.1" /> | 0h20 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma26-catlilface-nvfp4q8" />](../setups/arrietty/benchmarks/gemma-4-26b-a4b.md) | 12500 | <ScoreCell value="0.909/0.878" sub="91% completion" top /> | † unproven | <TokCell shallow="58.77" deep="45.59" /> | 3h35 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md) | 30000 | <ScoreCell value="0.896/0.872" sub="90% completion" top /> | 16 budget | <TokCell shallow="60.1" deep="19.1" /> | 5h47 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/gemma-4-26b-a4b-it-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-mlx-4bit" />](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md) | 30000 | <ScoreCell value="0.793/0.768" sub="81% completion" /> | 31 budget | <TokCell shallow="49.3" deep="23.4" /> | 9h06 |
<!-- gen:model-evalplus:end -->

Every run of this model on every machine, best base score first. The empties column carries the cause word ([what the words mean](../benchmarks/evalplus.md#limits-on-local-hardware)).

## Agent task — Mendel

<!-- gen:model-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" /> | blind-v1.1 | ?k | **47.5** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" /> | blind-v1.0 | ?k | **38** | 8/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" /> | blind-v1.1 | ?k | **12.5** | 1/8/done | NaN | — | — | 0 | 0 | 0 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" /> | guided-v3.0 | ?k | **57** | 7/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma26-catlilface-nvfp4q8" /> | guided-v3.0 | ?k | **37.5** | 3/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" /> | guided-v3.0 | ?k | **25** | 2/8/done | NaN | — | — | 0 | 0 | 0 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:model-mendel:end -->

The window cell is the harness context window of that run.

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
- **This model loops in both benchmarks, and a thinking budget fixes
  the single-turn side.** Under test on the M1 Max: the GGUF at
  thinking on with a 19491-token thinking budget scored 0.988 / 0.957,
  no empty answer, in 166 minutes, against 0.896 / 0.872 with 16
  empties in 347 minutes without it. 15 of the 16 forced answers
  passed ([method](../methodology/evalplus.md#unproven-yet-a-thinking-budget-instead-of-a-larger-output-budget)).
