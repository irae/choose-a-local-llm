# Gemma-4-12B-it

Every config of this model, on every machine, best first.

<!-- gen:model-all:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" hide="server" top /> | **245k** | <TokCell shallow="25.0" deep="9.2" cap="mem" /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 0h43 · Mendel 1h38"><b>2h21</b></span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" hide="server" top /> | 2x82k | <TokCell shallow="25.0" deep="15.7" cap="mem" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" hide="server" top /> | 4x49k | <TokCell shallow="42.9" deep="27.7" cap="mem" stale top-shallow /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" hide="server" top /> | 16k | <TokCell shallow="13.8" deep="6.5" cap="speed" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-unsloth-ud-q4kxl" hide="server" top /> | **261k** | <TokCell shallow="47.39" deep="32.18" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.951/0.909" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 0h26 · Mendel —">0h26†</span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-freedomaisvr-nvfp4" hide="server" /> | **261k** | <TokCell shallow="49.55" deep="33.11" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.927/0.896" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h51 · Mendel 0h01"><b>0h52</b></span> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-unsloth-ud-q4kxl" hide="server" /> | **261k** | <TokCell shallow="47.39" deep="32.18" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.793/0.780" sub="79% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 4h19 · Mendel 0h05">4h24</span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-freedomaisvr-nvfp4" hide="server" /> | **261k** | <TokCell shallow="49.55" deep="33.11" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.659/0.640" sub="68% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 3h24 · Mendel 0h06">3h29</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-all:end -->

## Files

Every file of this model, on every machine that served it, with every run and a log.

<!-- gen:model-binaries:start -->
- [Gemma-4-12B UD-Q4_K_XL (unsloth)](../binaries/gemma12-unsloth-ud-q4kxl.md) — m1-max-32gb, rtx-5060ti-16gb
- [Gemma-4-12B MLX 4-bit (lmstudio-community, LM Studio)](../binaries/gemma12-lmstudio-mlx-4bit.md) — m1-max-32gb
- [Gemma-4-12B NVFP4 (FreedomAISVR)](../binaries/gemma12-freedomaisvr-nvfp4.md) — rtx-5060ti-16gb
<!-- gen:model-binaries:end -->

## Speed and context

<!-- gen:model-curve:start -->
No decode curve recorded yet.
<!-- gen:model-curve:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | none | <TokCell shallow="25.0" deep="9.2" /> | 0h43 |
| [<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-unsloth-ud-q4kxl" />](../setups/arrietty/benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.951/0.909" sub="100% completion" top /> | none | <TokCell shallow="47.39" deep="32.18" /> | 0h26 |
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-freedomaisvr-nvfp4" />](../setups/arrietty/benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.927/0.896" sub="100% completion" top /> | none | <TokCell shallow="49.55" deep="33.11" /> | 0h51 |
| [<ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-lmstudio-mlx-4bit" />](../setups/kamaji/benchmarks/gemma-4-12b-it.md) | 30000 | <ScoreCell value="0.909/0.872" sub="100% completion" top /> | none | <TokCell shallow="34.19" deep="23.23" /> | 1h33 |
| [<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-unsloth-ud-q4kxl" />](../setups/arrietty/benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.793/0.780" sub="79% completion" /> | † unproven | <TokCell shallow="47.39" deep="32.18" /> | 4h19 |
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-freedomaisvr-nvfp4" />](../setups/arrietty/benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.659/0.640" sub="68% completion" /> | † unproven | <TokCell shallow="49.55" deep="33.11" /> | 3h24 |
<!-- gen:model-evalplus:end -->

Every run of this model on every machine, best base score first. The empties column carries the cause word ([what the words mean](../benchmarks/evalplus.md#limits-on-local-hardware)).

## Agent task — Mendel

<!-- gen:model-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" /> | blind-v1.1 | ?k | **0** | 0/8/done | NaN | — | — | 0 | 0 | 0 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" /> | guided-v3.0 | ?k | **37.5** (raw 58) | 3/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-freedomaisvr-nvfp4" /> | guided-v3.0 | ?k | **0** (raw 34) | 0/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-unsloth-ud-q4kxl" /> | guided-v3.0 | ?k | **0** (raw 34) | 0/8/done | NaN | — | — | 0 | 0 | 0 |  |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-freedomaisvr-nvfp4" /> | guided-v3.0 | ?k | **0** (raw 34) | 0/8/done | NaN | — | — | 0 | 0 | 0 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:model-mendel:end -->

The window cell is the harness context window of that run.

## What the numbers say

- **One configuration works: llama-server, f16 KV, no drafter,
  thinking off.** 0.976 / 0.939 on the M1 Max and 0.927 / 0.896 on the
  RTX 5060 Ti, every answer delivered, above 8 tok/s to 245K on the Mac
  and 261K on the card.
- **Thinking on is the pitfall, and a thinking budget removes it.** On
  the card thinking on scores 0.659 / 0.640 with 53 of 164 empty; under
  a 7350-token thinking budget the same config scores 0.976 / 0.951
  with no empty answer, 45 forced answers of which 42 pass (under
  test). On the Mac the thinking-on LM
  Studio entry was retired for a repetition loop. The 12B fails to
  converge more often than the 26B.
- **It fails the agent task everywhere.** Zero commits on the card on
  both builds and both levels; 37.5 guided on 3 of 8 on the Mac. MLX
  and LM Studio are ruled out for thinking-on agent work; the GGUF
  stays in scope. A row with zero commits is never retried on its own.
- **NVFP4 on the card** fits the trained window in 12.3 GB and reads 2
  to 5 percent faster than the k-quant. Both are community repacks.
