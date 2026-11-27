# RTX 5060 Ti 16 GB

Desktop Linux CUDA workstation (Blackwell, compute capability 12.0) running `llama-server` and the PrismML `llama.cpp` fork.

## Hardware & Standing Limits

- **GPU & Host:** NVIDIA GeForce RTX 5060 Ti 16 GB (`16,311 MiB`), 12 CPU threads, 32 GB RAM, Linux.
- **Shared display headroom:** Keep ~1–1.2 GB VRAM free for desktop stability during long agent runs.
- **Explicit placement:** Every row runs `-ngl 999 --fit off -fa on` so offload never shifts silently.
- **Retired builds:** Qwen3.8-27B OBLITERATED and dropped repacks live in the [RTX 5060 Ti archive](/setups/rtx-5060ti-16gb/archive).

## Top Picks

- **Best overall coding agent & daily driver:** [Qwen3.8-27B](/models/qwen3.8-27b) IQ3_S-mtp (`ISTA-DASLab`, `q8_0` KV, no drafter, `xhigh`) — **91/100 blind** and **85/100 guided** (both 8/8, `65k` ctx / `61,440` harness window, `29.4 → 21.1 tok/s`), **0.976 / 0.933** fast-mode EvalPlus (`11/164` forced). With an adjusted compaction trigger, this is the author's sole daily-driver local config (~6–12 h/month for personal finance workflows: email, bills, statements, and automation scripts).
- **Best long-context 27B:** [Ternary-Bonsai-2-27B](/models/bonsai-2-27b) (`prism-ml` fork `prism-b10685-7dffb15`, `xhigh`) — **82/100 blind** on `PTQ1_0` `f16` KV (`135k`, `42.1 → 22.4 tok/s`, **0.976 / 0.945**); **77/100** on `PQ2_0` `f16` (`119k`, `46.3 → 25.1 tok/s`); **73.5/100** on `PTQ1_0` `q8_0` (`240k`, peaked `225,161` tokens, 0 compactions); **75/100** with refusal-ablation LoRA 1.0 (0 critical defects). *Requires PrismML fork.*
- **Fastest MoE (CPU-MoE offload):** [Qwen3.6-35B-A3B](/models/qwen3.6-35b-a3b) UD-Q4_K_XL (`--n-cpu-moe 21`, `mtp/2`, `q8_0` KV, `97k`, `61.2 → 45.4 tok/s`, **0.976 / 0.933** EvalPlus, **48.5/100 guided** 6/8).
- **Latest additions (`llama.cpp` v0.9.0 / b12110):** [Arete-27B](/models/arete-27b) Q3_K_M (`64k`, `27.6 → 20.1 tok/s`, **0.976 / 0.951** EvalPlus, `7/164` forced, passed smoke; Mendel pending). [S5-nano](/models/s5-nano) (`Q8_0` `261k` `0.811/0.726`; `BF16` `204k` `0.841/0.774`) failed tool smoke on both quants.

## RTX 5060 Ti CUDA Quirks

- **`q8_0` KV works cleanly on CUDA:** Unlike Metal, `q8_0` KV carries a small speed cost while expanding 27B windows (`65k` vs `53k` on Qwen3.8; `240k` vs `135k` on Bonsai-2 `PTQ1_0`), though `f16` KV led `q8_0` on Bonsai-2 blind Mendel on both packings (`82 vs 73.5`, `77 vs 60.5`, 1 run each).
- **MTP speed vs stability:** On 27B models, `mtp/2` boosts decode (`45.9 → 26.2 tok/s` on Qwen3.8 ISTA) but cut free VRAM to ~440 MiB and crashed 3× under desktop contention. Dropping the drafter leaves ~1.2 GB free and runs clean.
- **MoE vs dense offload:** Partial MoE expert offload (`--n-cpu-moe 7` or `21`) sustains `45+ tok/s` at `97k`, whereas dense layer offload (`-ngl 45/64`) collapsed to `5.1 → 2.3 tok/s`.

## Complete Configurations

<!-- gen:setup-complete:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" page="/files/qwen38-ista-iq3s-mtp" model-page="/models/qwen3.8-27b" top /> | 65k | <TokCell shallow="29.43" deep="21.13" cap="mem" /> | <ScoreCell value="0.976/0.933" sub="100% completion" top /> | <ScoreCell value="91" pill="mendel-blind" top /> | <span title="EvalPlus 2h55 · Mendel 1h15">4h10</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/files/bonsai2-prism-ptq1" model-page="/models/bonsai-2-27b" top /> | 135k | <TokCell shallow="42.1" deep="22.4" cap="mem" /> | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | <ScoreCell value="82" pill="mendel-blind" top /> | <span title="EvalPlus 2h05 · Mendel 1h28"><b>3h33</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" page="/files/qwen38-unsloth-ud-iq3s" model-page="/models/qwen3.8-27b" top /> | 65k | <TokCell shallow="29.36" deep="20.92" cap="mem" /> | <ScoreCell value="0.963/0.921" sub="100% completion" top /> | <ScoreCell value="79" note="88%" pill="mendel-guided" top /> | <span title="EvalPlus 3h08 · Mendel 4h46">7h54</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/files/bonsai2-prism-pq2" model-page="/models/bonsai-2-27b" top /> | 119k | <TokCell shallow="46.3" deep="25.1" cap="mem" /> | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | <ScoreCell value="77" pill="mendel-blind" top /> | <span title="EvalPlus 2h01 · Mendel 1h15"><b>3h16</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" page="/files/bonsai2-prism-ptq1" model-page="/models/bonsai-2-27b" top /> | 135k | <TokCell shallow="40.8" deep="22.0" cap="mem" /> | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | <ScoreCell value="75" pill="mendel-blind" top /> | <span title="EvalPlus 2h32 · Mendel 1h22"><b>3h54</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" page="/files/bonsai2-prism-ptq1" model-page="/models/bonsai-2-27b" /> | **240k** | <TokCell shallow="41.7" deep="12.8" cap="mem" /> | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | <ScoreCell value="73.5" pill="mendel-blind" /> | <span title="EvalPlus 2h20 · Mendel 2h03">4h23</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" page="/files/bonsai2-prism-pq2" model-page="/models/bonsai-2-27b" /> | 208k | <TokCell shallow="46.0" deep="14.5" cap="mem" /> | <ScoreCell value="0.988/0.945" sub="100% completion" top /> | <ScoreCell value="60.5" pill="mendel-blind" /> | <span title="EvalPlus 1h59 · Mendel 1h32"><b>3h31</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" offload="n-cpu-moe 21" kv="q8_0" effort="on" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" /> | 97k | <TokCell shallow="61.16" deep="45.42" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.976/0.933" sub="100% completion" top /> | <ScoreCell value="48.5" note="75%" pill="mendel-guided" /> | <span title="EvalPlus 2h24 · Mendel 0h27"><b>2h51</b></span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" page="/files/gemma26-catlilface-nvfp4q8" model-page="/models/gemma-4-26b-a4b" /> | 97k | <TokCell shallow="58.77" deep="45.59" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.988/0.951" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> | <span title="EvalPlus 2h34 · Mendel 0h23"><b>2h57</b></span> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" page="/files/gemma12-unsloth-ud-q4kxl" model-page="/models/gemma-4-12b-it" /> | **261k** | <TokCell shallow="47.39" deep="32.18" cap="mem" /> | <ScoreCell value="0.988/0.963" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 3h18 · Mendel 0h05"><b>3h23</b></span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" page="/files/gemma12-freedomaisvr-nvfp4" model-page="/models/gemma-4-12b-it" /> | **261k** | <TokCell shallow="49.55" deep="33.11" cap="mem" /> | <ScoreCell value="0.976/0.951" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 3h31 · Mendel 0h06"><b>3h37</b></span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" page="/files/gemma12-freedomaisvr-nvfp4" model-page="/models/gemma-4-12b-it" /> | **261k** | <TokCell shallow="49.55" deep="33.11" cap="mem" /> | <ScoreCell value="0.927/0.896" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h51 · Mendel 0h01"><b>0h52</b></span> |
| <ModelSpec base="S5-nano" quant="BF16" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="f16" effort="on" page="/files/s5-nano-maritaca-bf16" model-page="/models/s5-nano" /> | 204k | <TokCell shallow="45.68" deep="26.41" cap="mem" /> | <ScoreCell value="0.841/0.774" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="failed-smoke" /> | <span title="EvalPlus 3h42 · Mendel —">3h42†</span> |
| <ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" page="/files/s5-nano-maritaca-q8" model-page="/models/s5-nano" /> | **261k** | <TokCell shallow="77.37" deep="30.59" cap="mem" top-shallow /> | <ScoreCell value="0.811/0.726" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="failed-smoke" /> | <span title="EvalPlus 1h56 · Mendel —">1h56†</span> |
<!-- gen:setup-complete:end -->

## In-Progress Configurations

<!-- gen:setup-partial:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Arete-27B" quant="Q3_K_M" server="llama-server" publisher="bartowski" repo="bartowski/NousResearch_Arete-27B-GGUF" kv="q8_0" effort="xhigh" page="/files/arete-bartowski-q3km" model-page="/models/arete-27b" top /> | **64k** | <TokCell shallow="27.60" deep="20.07" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.976/0.951" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 3h24 · Mendel —">3h24†</span> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/files/gemma12-unsloth-ud-q4kxl" model-page="/models/gemma-4-12b-it" top /> | **261k** | <TokCell shallow="47.39" deep="32.18" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.951/0.909" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 0h26 · Mendel —">0h26†</span> |
<!-- gen:setup-partial:end -->

## Fast-Mode HumanEval+

<!-- gen:setup-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" page="/files/gemma12-unsloth-ud-q4kxl" model-page="/models/gemma-4-12b-it" /> | 8192 | 16384 | <ScoreCell value="0.988/0.963" sub="100% completion" top /> | none | 34/164 | <TokCell shallow="47.39" deep="32.18" /> | 3h18 |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" page="/files/gemma26-catlilface-nvfp4q8" model-page="/models/gemma-4-26b-a4b" /> | 8192 | 16384 | <ScoreCell value="0.988/0.951" sub="100% completion" top /> | none | 19/164 | <TokCell shallow="58.77" deep="45.59" /> | 2h34 |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" page="/files/bonsai2-prism-pq2" model-page="/models/bonsai-2-27b" /> | 8192 | 16384 | <ScoreCell value="0.988/0.945" sub="100% completion" top /> | none | 12/164 | <TokCell shallow="46.0" deep="14.5" /> | 1h59 |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/files/bonsai2-prism-pq2" model-page="/models/bonsai-2-27b" /> | 8192 | 16384 | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | none | 12/164 | <TokCell shallow="46.3" deep="25.1" /> | 2h01 |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" page="/files/bonsai2-prism-ptq1" model-page="/models/bonsai-2-27b" /> | 8192 | 16384 | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | none | 16/164 | <TokCell shallow="41.7" deep="12.8" /> | 2h20 |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" page="/files/gemma12-freedomaisvr-nvfp4" model-page="/models/gemma-4-12b-it" /> | 8192 | 16384 | <ScoreCell value="0.976/0.951" sub="100% completion" top /> | none | 44/164 | <TokCell shallow="49.55" deep="33.11" /> | 3h31 |
| <ModelSpec base="Arete-27B" quant="Q3_K_M" server="llama-server" publisher="bartowski" repo="bartowski/NousResearch_Arete-27B-GGUF" kv="q8_0" effort="xhigh" page="/files/arete-bartowski-q3km" model-page="/models/arete-27b" /> | 8192 | 16384 | <ScoreCell value="0.976/0.951" sub="100% completion" top /> | none | 7/164 | <TokCell shallow="27.60" deep="20.07" /> | 3h24 |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/files/bonsai2-prism-ptq1" model-page="/models/bonsai-2-27b" /> | 8192 | 16384 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | 12/164 | <TokCell shallow="42.1" deep="22.4" /> | 2h05 |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" page="/files/bonsai2-prism-ptq1" model-page="/models/bonsai-2-27b" /> | 8192 | 16384 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | 18/164 | <TokCell shallow="40.8" deep="22.0" /> | 2h32 |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" page="/files/qwen38-ista-iq3s-mtp" model-page="/models/qwen3.8-27b" /> | 8192 | 10240 | <ScoreCell value="0.976/0.933" sub="100% completion" top /> | none | 11/164 | <TokCell shallow="29.43" deep="21.13" /> | 2h55 |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" offload="n-cpu-moe 21" kv="q8_0" effort="on" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" /> | 8192 | 16384 | <ScoreCell value="0.976/0.933" sub="100% completion" top /> | none | 12/164 | <TokCell shallow="61.16" deep="45.42" /> | 2h24 |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" page="/files/qwen38-unsloth-ud-iq3s" model-page="/models/qwen3.8-27b" /> | 8192 | 16384 | <ScoreCell value="0.963/0.921" sub="100% completion" top /> | none | 8/164 | <TokCell shallow="29.36" deep="20.92" /> | 3h08 |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/files/gemma12-unsloth-ud-q4kxl" model-page="/models/gemma-4-12b-it" /> | none | 8192 | <ScoreCell value="0.951/0.909" sub="100% completion" top /> | none | — | <TokCell shallow="47.39" deep="32.18" /> | 0h26 |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" page="/files/gemma12-freedomaisvr-nvfp4" model-page="/models/gemma-4-12b-it" /> | none | 8192 | <ScoreCell value="0.927/0.896" sub="100% completion" /> | none | — | <TokCell shallow="49.55" deep="33.11" /> | 0h51 |
| <ModelSpec base="S5-nano" quant="BF16" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="f16" effort="on" page="/files/s5-nano-maritaca-bf16" model-page="/models/s5-nano" /> | 8192 | 16384 | <ScoreCell value="0.841/0.774" sub="100% completion" /> | none | 31/164 | <TokCell shallow="45.68" deep="26.41" /> | 3h42 |
| <ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" page="/files/s5-nano-maritaca-q8" model-page="/models/s5-nano" /> | 8192 | 16384 | <ScoreCell value="0.811/0.726" sub="100% completion" /> | none | 26/164 | <TokCell shallow="77.37" deep="30.59" /> | 1h56 |
| <ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="off" page="/files/s5-nano-maritaca-q8" model-page="/models/s5-nano" /> | none | 16384 | <ScoreCell value="0.720/0.634" sub="100% completion" /> | none | 0/164 | <TokCell shallow="77.37" deep="30.59" /> | 0h26 |
<!-- gen:setup-evalplus:end -->

## Router Serve Presets

<!-- gen:setup-presets:start -->
### Official `llama-server` presets

```ini
[qwen3.8-27b-ista-q8]
hf-repo = ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF
hf-file = Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 65536
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[qwen3.8-27b-iq3s-q8]
hf-repo = unsloth/Qwen3.8-27B-GGUF
hf-file = Qwen3.8-27B-UD-IQ3_S.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 65536
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[qwen3.6-35b-a3b-q4kxl-q8-mtp2]
hf-repo = unsloth/Qwen3.6-35B-A3B-MTP-GGUF
hf-file = Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf
no-mmproj = true
parallel = 1
spec-type = draft-mtp
spec-draft-n-max = 2
n-gpu-layers = 999
fit = off
n-cpu-moe = 21
flash-attn = on
ctx-size = 98304
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[gemma-4-26b-a4b-nvfp4]
hf-repo = catlilface/Gemma-4-26B-A4B-NVFP4-GGUF
hf-file = Gemma4-26b-NVFP4Q8.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
n-cpu-moe = 7
flash-attn = on
ctx-size = 98304
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[gemma-4-12b-q4kxl]
hf-repo = unsloth/gemma-4-12b-it-GGUF
hf-file = gemma-4-12b-it-UD-Q4_K_XL.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 262144
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[gemma-4-12b-nvfp4]
hf-repo = FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF
hf-file = gemma-4-12b-it-nvfp4.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 262144
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[arete-27b-q3km]
hf-repo = bartowski/NousResearch_Arete-27B-GGUF
hf-file = NousResearch_Arete-27B-Q3_K_M.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 65536
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[s5-nano-q8]
hf-repo = maritaca-ai/S5-nano-GGUF
hf-file = S5-nano-Q8_0.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 262144
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```
### PrismML fork (`prism-llama`) presets

```ini
[bonsai2-27b-ptq1-f16]
hf-repo = prism-ml/Ternary-Bonsai-2-27B-gguf
hf-file = Ternary-Bonsai-2-27B-PTQ1_0.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 139264
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[bonsai2-27b-pq2-f16]
hf-repo = prism-ml/Ternary-Bonsai-2-27B-gguf
hf-file = Ternary-Bonsai-2-27B-PQ2_0.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 122880
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[bonsai2-27b-ptq1-f16-orca]
hf-repo = prism-ml/Ternary-Bonsai-2-27B-gguf
hf-file = Ternary-Bonsai-2-27B-PTQ1_0.gguf
lora = ~/.local/share/choose-a-local-llm/OrcaBonsai-27B-Uncensored/gguf/bonsai-abliterate-lora.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 139264
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[bonsai2-27b-ptq1-q8]
hf-repo = prism-ml/Ternary-Bonsai-2-27B-gguf
hf-file = Ternary-Bonsai-2-27B-PTQ1_0.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 245760
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[bonsai2-27b-pq2-q8]
hf-repo = prism-ml/Ternary-Bonsai-2-27B-gguf
hf-file = Ternary-Bonsai-2-27B-PQ2_0.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 212992
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```
<!-- gen:setup-presets:end -->
