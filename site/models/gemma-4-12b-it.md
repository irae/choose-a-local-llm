# Gemma-4-12B

Dense 12B model that achieves the highest HumanEval+ `plus` score on the entire site while scoring **0/100** across every coding-agent run.

## Verdict

- **Single-turn coding leader, zero agent viability:** On RTX 5060 Ti 16 GB, `UD-Q4_K_XL` (`f16` KV, thinking on) reaches **0.988 / 0.963** fast-mode EvalPlus (`34/164` forced) — the top `plus` score measured — and `NVFP4` (`f16` KV, thinking on) scores **0.976 / 0.951** (`44/164` forced). Both fit the full `261k` trained window on 16 GB VRAM (`47.4 → 32.2` and `49.6 → 33.1 tok/s`), yet every guided Mendel run (thinking on and off) ended **model-failed with zero commits** due to repetition loops (`520×` and `818×` repeated thought lines, or repeated failing tool calls).
- **M1 Max 32 GB (`Q4_K_XL`, `f16` KV, thinking off):** Reaches `245k` at `25.0 → 9.2 tok/s` in `13.9 GB` wired memory (`0.976 / 0.939` EvalPlus) and supports multi-slot serving (`2×82k` clean at `15.7 tok/s`), but likewise failed Mendel with zero commits.
- **Serve gotchas:** Thinking-on without a server thinking budget fails badly on single-turn coding (`0.659` NVFP4, `0.793` Q4_K_XL) because 34–53 problems loop past the output cap; fast mode (`--reasoning-budget 8192`) recovers every empty answer. Avoid `q8_0` KV on Metal (drops below `8 tok/s` by `16k`). LM Studio MLX 4-bit is retired ([M1 Max archive](/setups/m1-max-32gb/archive#lm-studio)).

## Configurations

<!-- gen:model-configs:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma12-unsloth-ud-q4kxl" hide="server" top /> | **245k** | <TokCell shallow="25.0" deep="9.2" cap="mem" /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 0h43 · Mendel 1h38"><b>2h21</b></span> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-unsloth-ud-q4kxl" hide="server" /> | **261k** | <TokCell shallow="47.39" deep="32.18" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.988/0.963" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 3h18 · Mendel 0h05">3h23</span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-freedomaisvr-nvfp4" hide="server" /> | **261k** | <TokCell shallow="49.55" deep="33.11" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.976/0.951" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 3h31 · Mendel 0h06">3h37</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma12-unsloth-ud-q4kxl" hide="server" top /> | 2x82k | <TokCell shallow="25.0" deep="15.7" cap="mem" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma12-unsloth-ud-q4kxl" hide="server" top /> | 4x49k | <TokCell shallow="42.9" deep="27.7" cap="mem" stale top-shallow /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/files/gemma12-unsloth-ud-q4kxl" hide="server" top /> | 16k | <TokCell shallow="13.8" deep="6.5" cap="speed" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/files/gemma12-unsloth-ud-q4kxl" hide="server" top /> | **261k** | <TokCell shallow="47.39" deep="32.18" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.951/0.909" sub="100% completion" /> | <ScoreCell value="not run" /> | <span title="EvalPlus 0h26 · Mendel —">0h26†</span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/files/gemma12-freedomaisvr-nvfp4" hide="server" /> | **261k** | <TokCell shallow="49.55" deep="33.11" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.927/0.896" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h51 · Mendel 0h01"><b>0h52</b></span> |

† from an earlier serving config or method; re-run pending.

Retired (M1 Max 32 GB): Gemma-4-12B, LM Studio entry google/gemma-4-12b — thinking-on repetition loop; entry gone from the model store ([archive](/setups/m1-max-32gb/archive#lm-studio)).
<!-- gen:model-configs:end -->

## Decode Speed vs Context Depth

<!-- gen:model-curves:start -->
| arm | 4K | 8K | 16K | 24K | 32K | 40K | 48K | 64K | 80K | 96K | 128K | 160K | 192K | 208K | 240K | 256K |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| rtx-5060ti-16gb, NVFP4, f16 KV, no drafter, -c 256K | <CurveCell value="49.55" served /> |  |  |  |  |  |  |  |  | <CurveCell value="41.57" served /> |  |  |  |  |  | <CurveCell value="33.11" served /> |
| rtx-5060ti-16gb, UD-Q4_K_XL, f16 KV, no drafter, -c 256K | <CurveCell value="47.39" served /> |  |  |  |  |  |  |  |  | <CurveCell value="40.26" served /> |  |  |  |  |  | <CurveCell value="32.18" served /> |
| m1-max-32gb, LM Studio MLX 4-bit, retired, wired 24000 † | <CurveCell value="34.19" /> |  | <CurveCell value="32.05" /> |  | <CurveCell value="30.59" /> |  |  | <CurveCell value="27.08" /> |  | <CurveCell value="24.52" /> | <CurveCell value="23.23" /> |  |  |  |  |  |
| m1-max-32gb, Q4_K_XL, f16 KV, no drafter, 2 slots, -c 96K, wired 25000 † | <CurveCell value="24.98" served /> | <CurveCell value="24.14" served /> | <CurveCell value="22.83" served /> | <CurveCell value="21.53" served /> | <CurveCell value="20.57" served /> | <CurveCell value="19.51" served /> | <CurveCell value="18.63" served /> | <CurveCell value="16.93" served /> | <CurveCell value="15.72" served /> |  |  |  |  |  |  |  |
| m1-max-32gb, Q4_K_XL, f16 KV, no drafter, 1 slot, wired 24000 † | <CurveCell value="24.64" /> | <CurveCell value="24.05" /> | <CurveCell value="22.66" /> | <CurveCell value="21.59" /> | <CurveCell value="20.58" /> |  | <CurveCell value="18.75" /> | <CurveCell value="17.42" /> | <CurveCell value="15.87" /> | <CurveCell value="14.91" /> | <CurveCell value="13.04" /> | <CurveCell value="11.3" /> | <CurveCell value="10.24" /> | <CurveCell value="9.69" /> | <CurveCell value="8.86" /> |  |

The served arm of each config is in bold. A pill under a reading shows its exact depth when arms in that column differed.

† measured with the earlier context-creep tool rather than `llama-benchy` on real code text. The two methods are not directly comparable.
<!-- gen:model-curves:end -->

## HumanEval+

<!-- gen:model-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-unsloth-ud-q4kxl" /> | 8192 | 16384 | <ScoreCell value="0.988/0.963" sub="100% completion" top /> | none | 34/164 | <TokCell shallow="47.39" deep="32.18" /> | 3h18 |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-freedomaisvr-nvfp4" /> | 8192 | 16384 | <ScoreCell value="0.976/0.951" sub="100% completion" top /> | none | 44/164 | <TokCell shallow="49.55" deep="33.11" /> | 3h31 |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma12-unsloth-ud-q4kxl" /> | none | 8192 | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | none | — | <TokCell shallow="25.0" deep="9.2" /> | 0h43 |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/files/gemma12-unsloth-ud-q4kxl" /> | none | 8192 | <ScoreCell value="0.951/0.909" sub="100% completion" /> | none | — | <TokCell shallow="47.39" deep="32.18" /> | 0h26 |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/files/gemma12-freedomaisvr-nvfp4" /> | none | 8192 | <ScoreCell value="0.927/0.896" sub="100% completion" /> | none | — | <TokCell shallow="49.55" deep="33.11" /> | 0h51 |
| <ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma12-lmstudio-mlx-4bit" /> | none | 30000 | <ScoreCell value="0.909/0.872" sub="100% completion" /> | none | — | <TokCell shallow="34.19" deep="23.23" /> | 1h33 |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-freedomaisvr-nvfp4" /> | 7350† | 9398 | <ScoreCell value="0.976/0.951" sub="100% completion" /> | none | 45/164 | <TokCell shallow="49.55" deep="33.11" /> | 3h15 |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-unsloth-ud-q4kxl" /> | —† | 8192 | <ScoreCell value="0.793/0.780" sub="79% completion" /> | † unproven | — | <TokCell shallow="47.39" deep="32.18" /> | 4h19 |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-freedomaisvr-nvfp4" /> | —† | 8192 | <ScoreCell value="0.659/0.640" sub="68% completion" /> | † unproven | — | <TokCell shallow="49.55" deep="33.11" /> | 3h24 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.
<!-- gen:model-evalplus:end -->

## Mendel Agent Runs

<!-- gen:model-mendel:start -->
Blind test:

| Model / Config | Score | Wall | Ctx / speed | Out/Total | Ctx use | Bugs | Stats |
|---|--:|--:|--:|--:|--:|---|---|
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma12-unsloth-ud-q4kxl" /> | <ScoreCell value="0" note="0%" top /> | **80 min** | <span class="ctxuse">**256k**<br><TokCell shallow="25.0" deep="9.2" top-shallow top-deep /></span> | <span class="ctxuse">42k<br><span class="ms-pill cs-pill cs-pill-gray">10.0M</span></span> | **68%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">5 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">3 medium</span> <span class="ms-pill cs-pill cs-pill-gray">4 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">model-failed</span> <span class="ms-pill cs-pill cs-pill-gray">calls 92/30</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 0</span> <span class="ms-pill cs-pill cs-pill-gray">turns 96</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 3m</span></span> |

Guided test:

| Model / Config | Score | Wall | Ctx / speed | Out/Total | Ctx use | Bugs | Stats |
|---|--:|--:|--:|--:|--:|---|---|
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma12-unsloth-ud-q4kxl" /> | <ScoreCell value="37.5" note="38%" top /> | 98 min | <span class="ctxuse">**256k**<br><TokCell shallow="25.0" deep="9.2" /></span> | <span class="ctxuse">79k<br><span class="ms-pill cs-pill cs-pill-gray">6.5M</span></span> | 48% | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 132/42</span> <span class="ms-pill cs-pill cs-pill-gray">commits 3</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 136</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 3m</span> <span class="ms-pill cs-pill cs-pill-red">loop text</span></span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/files/gemma12-freedomaisvr-nvfp4" /> | <ScoreCell value="0" note="0%" top /> | **1 min** | <span class="ctxuse">**252k**<br><TokCell shallow="49.55" deep="33.11" top-shallow top-deep /></span> | <span class="ctxuse">2k<br><span class="ms-pill cs-pill cs-pill-gray">0.3M</span></span> | **5%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">model-failed</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 30/6</span> <span class="ms-pill cs-pill cs-pill-gray">commits 0</span> <span class="ms-pill cs-pill cs-pill-gray">turns 31</span></span> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-unsloth-ud-q4kxl" /> | <ScoreCell value="0" note="0%" top /> | **5 min** | <span class="ctxuse">**252k**<br><TokCell shallow="47.39" deep="32.18" top-shallow top-deep /></span> | <span class="ctxuse">13k<br><span class="ms-pill cs-pill cs-pill-gray">0.2M</span></span> | **10%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">model-failed</span> <span class="ms-pill cs-pill cs-pill-gray">calls 17/2</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 0</span> <span class="ms-pill cs-pill cs-pill-gray">turns 19</span> <span class="ms-pill cs-pill cs-pill-red">loop thinking</span></span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-freedomaisvr-nvfp4" /> | <ScoreCell value="0" note="0%" top /> | **6 min** | <span class="ctxuse">**252k**<br><TokCell shallow="49.55" deep="33.11" top-shallow top-deep /></span> | <span class="ctxuse">14k<br><span class="ms-pill cs-pill cs-pill-gray">0.5M</span></span> | **15%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">model-failed</span> <span class="ms-pill cs-pill cs-pill-gray">calls 24/0</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 0</span> <span class="ms-pill cs-pill cs-pill-gray">turns 25</span> <span class="ms-pill cs-pill cs-pill-red">loop thinking</span></span> |

Older prompt versions of these runs are on [the Mendel page](/benchmarks/mendel#older-prompt-versions).
<!-- gen:model-mendel:end -->

## Model Files

<!-- gen:model-files:start -->
- [Gemma-4-12B UD-Q4_K_XL (unsloth)](/files/gemma12-unsloth-ud-q4kxl) — M1 Max 32 GB, RTX 5060 Ti 16 GB
- [Gemma-4-12B MLX 4-bit (lmstudio-community, LM Studio)](/files/gemma12-lmstudio-mlx-4bit) — M1 Max 32 GB
- [Gemma-4-12B NVFP4 (FreedomAISVR)](/files/gemma12-freedomaisvr-nvfp4) — RTX 5060 Ti 16 GB
<!-- gen:model-files:end -->
