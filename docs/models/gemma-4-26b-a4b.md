# Gemma-4-26B-A4B

Every config of this model, on every machine, best first.

<!-- gen:model-all:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" hide="server" top /> | **197k** | <TokCell shallow="60.1" deep="19.1" cap="mem" top-shallow /> | <ScoreCell value="0.896/0.872†" sub="90% completion" top /> | <ScoreCell value="47.5" pill="mendel-blind" top /> | <span title="EvalPlus 5h47 · Mendel 1h21"><b>7h08</b></span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma26-catlilface-nvfp4q8" hide="server" top /> | **97k** | <TokCell shallow="58.77" deep="45.59" cap="mem" top-deep /> | <ScoreCell value="0.988/0.951" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 2h34 · Mendel 0h23"><b>2h57</b></span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" hide="server" /> | **2x82k** | <TokCell shallow="66.6" deep="33.6" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="0.896/0.872†" sub="90% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 5h47 · Mendel —">5h47†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-all:end -->

## Files

Every file of this model, on every machine that served it, with every run and a log.

<!-- gen:model-binaries:start -->
- [Gemma-4-26B-A4B UD-Q4_K_XL (unsloth)](../binaries/gemma26-unsloth-ud-q4kxl.md) — m1-max-32gb
- [Gemma-4-26B-A4B MLX 4-bit (mlx-community)](../binaries/gemma26-mlx-4bit.md) — m1-max-32gb
- [Gemma-4-26B-A4B NVFP4Q8 (catlilface)](../binaries/gemma26-catlilface-nvfp4q8.md) — rtx-5060ti-16gb
<!-- gen:model-binaries:end -->

## Speed and context

<!-- gen:model-curve:start -->
| arm | 4K | 8K | 16K | 24K | 32K | 48K | 64K | 80K | 96K | 128K | 160K | 192K |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| m1-max-32gb, UD-Q4_K_XL, MTP, f16 KV, -c 208K, wired 24000 † | <CurveCell value="61.25" /> | <CurveCell value="64.95" /> | <CurveCell value="56.65" /> | <CurveCell value="52.72" depth="24.0K" /> | <CurveCell value="46.46" depth="32.0K" /> | <CurveCell value="41.04" depth="48.0K" /> | <CurveCell value="36.22" depth="64.0K" /> | <CurveCell value="33.25" /> | <CurveCell value="28.73" depth="96.0K" /> | <CurveCell value="25.17" /> | <CurveCell value="21.25" /> | <CurveCell value="17.3" /> |
| rtx-5060ti-16gb, NVFP4Q8, f16 KV, `--n-cpu-moe 7`, -c 96K | <CurveCell value="58.77" served /> |  |  |  |  |  | <CurveCell value="49.56" depth="64.0K" served /> |  | <CurveCell value="45.59" depth="95.0K" served /> |  |  |  |
| m1-max-32gb, 4-bit, f16 KV, no drafter, -c 64K, wired 24000 † | <CurveCell value="51.1" /> |  | <CurveCell value="43.5" /> | <CurveCell value="39.6" depth="24.5K" /> | <CurveCell value="35.6" depth="33.0K" /> | <CurveCell value="28.8" depth="49.0K" /> | <CurveCell value="12.83" depth="70.0K" /> |  |  |  |  |  |

The served arm of each config is in bold. A pill under a reading is the depth it was read at, where the arms of that column did not share one.

† read with the context-creep tool of an earlier version of this project, not with `llama-benchy` on real text. The two methods do not give the same number. A reading stays until a re-run replaces it.
<!-- gen:model-curve:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma26-catlilface-nvfp4q8" />](../setups/arrietty/benchmarks/gemma-4-26b-a4b.md) | 8192 | 16384 | <ScoreCell value="0.988/0.951" sub="100% completion" top /> | none | 19/164 | <TokCell shallow="58.77" deep="45.59" /> | 2h34 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md) | none | 8192 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | — | <TokCell shallow="60.1" deep="19.1" /> | 0h20 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md) | 19491† | 21539 | <ScoreCell value="0.988/0.957" sub="100% completion" /> | none | 16/164 | <TokCell shallow="60.1" deep="19.1" /> | 2h46 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma26-catlilface-nvfp4q8" />](../setups/arrietty/benchmarks/gemma-4-26b-a4b.md) | —† | 12500 | <ScoreCell value="0.909/0.878" sub="91% completion" /> | † unproven | — | <TokCell shallow="58.77" deep="45.59" /> | 3h35 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md) | —† | 30000 | <ScoreCell value="0.896/0.872" sub="90% completion" /> | 16 budget | — | <TokCell shallow="60.1" deep="19.1" /> | 5h47 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/gemma-4-26b-a4b-it-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-mlx-4bit" />](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md) | —† | 30000 | <ScoreCell value="0.793/0.768" sub="81% completion" /> | 31 budget | — | <TokCell shallow="49.3" deep="23.4" /> | 9h06 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.
<!-- gen:model-evalplus:end -->

Every run of this model on every machine, best base score first. The empties column carries the cause word ([what the words mean](../benchmarks/evalplus.md#limits-on-local-hardware)).

## Agent task — Mendel

<!-- gen:model-mendel:start -->
Blind test:

| Model / Config | Score | Wall | Ctx / speed | Out/Total | Ctx use | Bugs | Stats |
|---|--:|--:|--:|--:|--:|---|---|
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" />](../setups/kamaji/reports/gemma-4-26b-a4b.md) | <ScoreCell value="47.5" top /> | **81 min** | **208k** | <span class="ctxuse">63k<br><span class="ms-pill cs-pill cs-pill-gray">23.8M</span></span> | <span class="ctxuse">**198%**<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 246/40</span> <span class="ms-pill cs-pill cs-pill-gray">commits 21</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 6</span> <span class="ms-pill cs-pill cs-pill-gray">turns 250</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 2m</span></span> |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" />](../setups/kamaji/reports/gemma-4-26b-a4b.md) | <ScoreCell value="12.5" note="13%" top /> | **28 min** | **208k** | <span class="ctxuse">29k<br><span class="ms-pill cs-pill cs-pill-gray">8.1M</span></span> | **64%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">2 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">4 medium</span> <span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 120/21</span> <span class="ms-pill cs-pill cs-pill-gray">commits 7</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 121</span> <span class="ms-pill cs-pill cs-pill-red">loop tool call</span></span> |

Guided test:

| Model / Config | Score | Wall | Ctx / speed | Out/Total | Ctx use | Bugs | Stats |
|---|--:|--:|--:|--:|--:|---|---|
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" />](../setups/kamaji/reports/gemma-4-26b-a4b.md) | <ScoreCell value="57" note="88%" top /> | 115 min | **208k** | <span class="ctxuse">61k<br><span class="ms-pill cs-pill cs-pill-gray">24.8M</span></span> | <span class="ctxuse">298%<br><span class="ms-pill cs-pill cs-pill-yellow">2 compactions</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">4 medium</span> <span class="ms-pill cs-pill cs-pill-gray">5 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 269/42</span> <span class="ms-pill cs-pill cs-pill-gray">commits 13</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 2</span> <span class="ms-pill cs-pill cs-pill-gray">turns 273</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 1m</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 27%</span></span> |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma26-catlilface-nvfp4q8" />](../setups/arrietty/reports/gemma-4-26b-a4b.md) | <ScoreCell value="37.5" note="38%" top /> | **23 min** | <span class="ctxuse">**92k**<br><TokCell shallow="58.77" deep="45.59" top-shallow top-deep /></span> | <span class="ctxuse">45k<br><span class="ms-pill cs-pill cs-pill-gray">6.7M</span></span> | <span class="ctxuse">**196%**<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">2 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">4 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 137/13</span> <span class="ms-pill cs-pill cs-pill-gray">commits 6</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 139</span> <span class="ms-pill cs-pill cs-pill-red">loop thinking</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 91%</span></span> |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" />](../setups/kamaji/reports/gemma-4-26b-a4b.md) | <ScoreCell value="25" note="25%" /> | **20 min** | **208k** | <span class="ctxuse">16k<br><span class="ms-pill cs-pill cs-pill-gray">2.6M</span></span> | **34%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">2 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 91/28</span> <span class="ms-pill cs-pill cs-pill-gray">commits 3</span> <span class="ms-pill cs-pill cs-pill-gray">turns 93</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">nudges 1t</span> <span class="ms-pill cs-pill cs-pill-red">loop tool call</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 4%</span></span> |

Older prompt versions of these runs are on [the agent-task page](../benchmarks/mendel.md).
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
