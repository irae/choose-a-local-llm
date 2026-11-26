# Gemma-4-26B-A4B

Sparse Mixture-of-Experts (26B total / 4B active) offering the widest complete agent context window on M1 Max 32 GB, with strong single-turn quality but mid-tier agent reliability.

## Verdict

- **M1 Max 32 GB (`UD-Q4_K_XL`, `f16` KV, `mtp/2`, thinking on):** Longest usable agent window on M1 Max at `197k` (`-c 212992`), decoding `60.1 → 19.1 tok/s` with **0.988 / 0.957** fast-mode EvalPlus (`19/164` forced). Agent runs complete cleanly at **47.5/100 blind** (8/8) and **57/100 guided** (7/8; confirmed at **56/100** under an 8192 thinking budget). Also supports 2 parallel slots (`2×82k` clean at `66.6 → 33.6 tok/s`).
- **RTX 5060 Ti 16 GB (`NVFP4Q8`, `--n-cpu-moe 7`, `f16` KV, thinking on):** Partial CPU-MoE offload of 7 expert layers holds `58.8 → 45.6 tok/s` across `97k` context and scores **0.988 / 0.951** fast-mode EvalPlus (`19/164` forced). Guided Mendel scored **37.5/100** (3/8 libraries, stopped on a text loop).
- **Serve gotchas:** Always use `f16` KV on M1 Max — `q8_0` KV collapses speed at depth (`6.3 tok/s` vs `45.9` at 32K). MTP `n=2` is the fastest GGUF drafter arm on M1 Max. The MLX 4-bit build is retired on M1 Max after failing the agent smoke on a truncated tool call ([M1 Max archive](/setups/m1-max-32gb/archive#gemma-4-26b-a4b-mlx)).

## Configurations

<!-- gen:model-configs:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" hide="server" top /> | **197k** | <TokCell shallow="60.1" deep="19.1" cap="mem" top-shallow /> | <ScoreCell value="0.988/0.957" sub="100% completion" top /> | <ScoreCell value="47.5" pill="mendel-blind" top /> | <span title="EvalPlus 1h57 · Mendel 1h21"><b>3h18</b></span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma26-catlilface-nvfp4q8" hide="server" top /> | **97k** | <TokCell shallow="58.77" deep="45.59" cap="mem" top-deep /> | <ScoreCell value="0.988/0.951" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 2h34 · Mendel 0h23"><b>2h57</b></span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" hide="server" /> | **2x82k** | <TokCell shallow="66.6" deep="33.6" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="0.988/0.957" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 1h57 · Mendel —">1h57†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:model-configs:end -->

## Decode Speed vs Context Depth

<!-- gen:model-curves:start -->
| arm | 4K | 8K | 16K | 24K | 32K | 48K | 64K | 80K | 96K | 128K | 160K | 192K |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| m1-max-32gb, UD-Q4_K_XL, MTP, f16 KV, -c 208K, wired 24000 † | <CurveCell value="61.25" /> | <CurveCell value="64.95" /> | <CurveCell value="56.65" /> | <CurveCell value="52.72" depth="24.0K" /> | <CurveCell value="46.46" depth="32.0K" /> | <CurveCell value="41.04" depth="48.0K" /> | <CurveCell value="36.22" depth="64.0K" /> | <CurveCell value="33.25" /> | <CurveCell value="28.73" depth="96.0K" /> | <CurveCell value="25.17" /> | <CurveCell value="21.25" /> | <CurveCell value="17.3" /> |
| rtx-5060ti-16gb, NVFP4Q8, f16 KV, `--n-cpu-moe 7`, -c 96K | <CurveCell value="58.77" served /> |  |  |  |  |  | <CurveCell value="49.56" depth="64.0K" served /> |  | <CurveCell value="45.59" depth="95.0K" served /> |  |  |  |
| m1-max-32gb, 4-bit, f16 KV, no drafter, -c 64K, wired 24000 † | <CurveCell value="51.1" /> |  | <CurveCell value="43.5" /> | <CurveCell value="39.6" depth="24.5K" /> | <CurveCell value="35.6" depth="33.0K" /> | <CurveCell value="28.8" depth="49.0K" /> | <CurveCell value="12.83" depth="70.0K" /> |  |  |  |  |  |

The served arm of each config is in bold. A pill under a reading shows its exact depth when arms in that column differed.

† measured with the earlier context-creep tool rather than `llama-benchy` on real code text. The two methods are not directly comparable.
<!-- gen:model-curves:end -->

## HumanEval+

<!-- gen:model-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" /> | 8192 | 16384 | <ScoreCell value="0.988/0.957" sub="100% completion" top /> | none | 19/164 | <TokCell shallow="60.1" deep="19.1" /> | 1h57 |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma26-catlilface-nvfp4q8" /> | 8192 | 16384 | <ScoreCell value="0.988/0.951" sub="100% completion" top /> | none | 19/164 | <TokCell shallow="58.77" deep="45.59" /> | 2h34 |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" /> | none | 8192 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | — | <TokCell shallow="60.1" deep="19.1" /> | 0h20 |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" /> | 19491† | 21539 | <ScoreCell value="0.988/0.957" sub="100% completion" /> | none | 16/164 | <TokCell shallow="60.1" deep="19.1" /> | 2h46 |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma26-catlilface-nvfp4q8" /> | —† | 12500 | <ScoreCell value="0.909/0.878" sub="91% completion" /> | † unproven | — | <TokCell shallow="58.77" deep="45.59" /> | 3h35 |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" /> | —† | 30000 | <ScoreCell value="0.896/0.872" sub="90% completion" /> | 16 budget | — | <TokCell shallow="60.1" deep="19.1" /> | 5h47 |
| <ModelSpec base="Gemma-4-26B-A4B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/gemma-4-26b-a4b-it-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-mlx-4bit" /> | —† | 30000 | <ScoreCell value="0.793/0.768" sub="81% completion" /> | 31 budget | — | <TokCell shallow="49.3" deep="23.4" /> | 9h06 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.
<!-- gen:model-evalplus:end -->

## Mendel Agent Runs

<!-- gen:model-mendel:start -->
Blind test:

| Model / Config | Score | Wall | Ctx / speed | Out/Total | Ctx use | Bugs | Stats |
|---|--:|--:|--:|--:|--:|---|---|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" /> | <ScoreCell value="47.5" top /> | **81 min** | <span class="ctxuse">**208k**<br><TokCell shallow="60.1" deep="19.1" top-shallow top-deep /></span> | <span class="ctxuse">63k<br><span class="ms-pill cs-pill cs-pill-gray">23.8M</span></span> | <span class="ctxuse">**198%**<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 246/40</span> <span class="ms-pill cs-pill cs-pill-gray">commits 21</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 6</span> <span class="ms-pill cs-pill cs-pill-gray">turns 250</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 2m</span></span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" /> | <ScoreCell value="12.5" note="13%" top /> | **28 min** | **208k** | <span class="ctxuse">29k<br><span class="ms-pill cs-pill cs-pill-gray">8.1M</span></span> | **64%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">2 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">4 medium</span> <span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 120/21</span> <span class="ms-pill cs-pill cs-pill-gray">commits 7</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 121</span> <span class="ms-pill cs-pill cs-pill-red">loop tool call</span></span> |

Guided test:

| Model / Config | Score | Wall | Ctx / speed | Out/Total | Ctx use | Bugs | Stats |
|---|--:|--:|--:|--:|--:|---|---|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" /> | <ScoreCell value="57" note="88%" top /> | 115 min | <span class="ctxuse">**208k**<br><TokCell shallow="60.1" deep="19.1" top-shallow top-deep /></span> | <span class="ctxuse">61k<br><span class="ms-pill cs-pill cs-pill-gray">24.8M</span></span> | <span class="ctxuse">298%<br><span class="ms-pill cs-pill cs-pill-yellow">2 compactions</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">4 medium</span> <span class="ms-pill cs-pill cs-pill-gray">5 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 269/42</span> <span class="ms-pill cs-pill cs-pill-gray">commits 13</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 2</span> <span class="ms-pill cs-pill cs-pill-gray">turns 273</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 1m</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 27%</span></span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma26-catlilface-nvfp4q8" /> | <ScoreCell value="37.5" note="38%" top /> | **23 min** | <span class="ctxuse">**92k**<br><TokCell shallow="58.77" deep="45.59" top-shallow top-deep /></span> | <span class="ctxuse">45k<br><span class="ms-pill cs-pill cs-pill-gray">6.7M</span></span> | <span class="ctxuse">**196%**<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">2 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">4 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 137/13</span> <span class="ms-pill cs-pill cs-pill-gray">commits 6</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 139</span> <span class="ms-pill cs-pill cs-pill-red">loop thinking</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 91%</span></span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" /> | <ScoreCell value="25" note="25%" /> | **20 min** | **208k** | <span class="ctxuse">16k<br><span class="ms-pill cs-pill cs-pill-gray">2.6M</span></span> | **34%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">2 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 91/28</span> <span class="ms-pill cs-pill cs-pill-gray">commits 3</span> <span class="ms-pill cs-pill cs-pill-gray">turns 93</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">nudges 1t</span> <span class="ms-pill cs-pill cs-pill-red">loop tool call</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 4%</span></span> |

Older prompt versions of these runs are on [the Mendel page](/benchmarks/mendel#older-prompt-versions).
<!-- gen:model-mendel:end -->

## Model Files

<!-- gen:model-files:start -->
- [Gemma-4-26B-A4B UD-Q4_K_XL (unsloth)](/files/gemma26-unsloth-ud-q4kxl) — M1 Max 32 GB
- [Gemma-4-26B-A4B MLX 4-bit (mlx-community)](/files/gemma26-mlx-4bit) — M1 Max 32 GB
- [Gemma-4-26B-A4B NVFP4Q8 (catlilface)](/files/gemma26-catlilface-nvfp4q8) — RTX 5060 Ti 16 GB
<!-- gen:model-files:end -->
