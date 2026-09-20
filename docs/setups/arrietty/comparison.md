# Local coding models on RTX 5060 Ti 16 GB

llama-server (CUDA) · measured 2026-09-13 to 2026-09-16

## Highlights

- **Pick: Qwen3.8-27B ISTA IQ3_S-mtp, no drafter, q8_0 KV.** Guided
  85 and blind 91, both 8 of 8. Window 61440. 29.4 → 21.1 tok/s.
- **Longest window: Ternary Bonsai-2-27B.** 240K on PTQ1_0 and 208K
  on PQ2_0 at q8_0 KV, the fastest 27B build here at 46 tok/s at 4K.
  EvalPlus 0.982 / 0.945 on PQ2_0 at f16. Blind 82 on PTQ1_0 at f16.
- **Fastest: Qwen3.6-35B-A3B, MTP n-max 2.** 97K at 61.2 → 45.4
  tok/s. Guided 48.5, 6 of 8.
- **Gemma-4-12B NVFP4 serves 261K** at 49.6 → 33.1 tok/s.

## Models evaluated

<!-- gen:models-evaluated:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" page="/binaries/qwen38-ista-iq3s-mtp" top /> | 65k | <TokCell shallow="29.43" deep="21.13" cap="mem" /> | <ScoreCell value="0.976/0.933" sub="100% completion" top /> | <ScoreCell value="91" pill="mendel-blind" top /> | <span title="EvalPlus 2h55 · Mendel 1h15"><b>4h10</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" top /> | 135k | <TokCell shallow="42.1" deep="22.4" cap="mem" /> | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | <ScoreCell value="82" pill="mendel-blind" top /> | <span title="EvalPlus 2h05 · Mendel 1h28"><b>3h33</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" page="/binaries/qwen38-unsloth-ud-iq3s" top /> | 65k | <TokCell shallow="29.36" deep="20.92" cap="mem" /> | <ScoreCell value="0.963/0.921" sub="100% completion" top /> | <ScoreCell value="79" note="88%" pill="mendel-guided" top /> | <span title="EvalPlus 3h08 · Mendel 4h46">7h54</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-pq2" top /> | 119k | <TokCell shallow="46.3" deep="25.1" cap="mem" /> | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | <ScoreCell value="77" pill="mendel-blind" top /> | <span title="EvalPlus 2h01 · Mendel 1h15"><b>3h16</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" top /> | 135k | <TokCell shallow="40.8" deep="22.0" cap="mem" /> | <ScoreCell value="0.976/0.945†" sub="100% completion" top /> | <ScoreCell value="75" pill="mendel-blind" top /> | <span title="EvalPlus 4h34 · Mendel 1h22">5h56</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" top /> | **240k** | <TokCell shallow="41.7" deep="12.8" cap="mem" /> | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | <ScoreCell value="73.5" pill="mendel-blind" /> | <span title="EvalPlus 2h20 · Mendel 2h03">4h23</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" page="/binaries/bonsai2-prism-pq2" /> | 208k | <TokCell shallow="46.0" deep="14.5" cap="mem" /> | <ScoreCell value="0.988/0.945" sub="100% completion" top /> | <ScoreCell value="60.5" pill="mendel-blind" /> | <span title="EvalPlus 1h59 · Mendel 1h32"><b>3h31</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" offload="n-cpu-moe 21" kv="q8_0" effort="on" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | 97k | <TokCell shallow="61.16" deep="45.42" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.945/0.902†" sub="96% completion" top /> | <ScoreCell value="48.5" note="75%" pill="mendel-guided" /> | <span title="EvalPlus 3h12 · Mendel 0h27"><b>3h39</b></span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" page="/binaries/gemma26-catlilface-nvfp4q8" /> | 97k | <TokCell shallow="58.77" deep="45.59" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.909/0.878†" sub="91% completion" /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> | <span title="EvalPlus 3h35 · Mendel 0h23"><b>3h58</b></span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" page="/binaries/gemma12-freedomaisvr-nvfp4" /> | **261k** | <TokCell shallow="49.55" deep="33.11" cap="mem" /> | <ScoreCell value="0.927/0.896" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h51 · Mendel 0h01"><b>0h52</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="Q3_K_M" server="llama-server" publisher="OBLITERATUS" repo="OBLITERATUS/Qwen3.8-27B-OBLITERATED" kv="q8_0" effort="medium" page="/binaries/qwen38-obliteratus-q3km" /> | 65k | <TokCell shallow="22.67" deep="16.74" cap="mem" /> | <ScoreCell value="0.854/0.787†" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="failed-smoke" /> | <span title="EvalPlus 1h29 · Mendel —">1h29†</span> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" page="/binaries/gemma12-unsloth-ud-q4kxl" /> | **261k** | <TokCell shallow="47.39" deep="32.18" cap="mem" /> | <ScoreCell value="0.793/0.780†" sub="79% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 4h19 · Mendel 0h05">4h24</span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" page="/binaries/gemma12-freedomaisvr-nvfp4" /> | **261k** | <TokCell shallow="49.55" deep="33.11" cap="mem" /> | <ScoreCell value="0.659/0.640†" sub="68% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 3h24 · Mendel 0h06"><b>3h29</b></span> |
<!-- gen:models-evaluated:end -->

Columns and sort: [the legend](../../#legend). Server commands: each
model's report. Aliases equal the pi model ids.

### Rows still being measured

Rows with two of the three measurements, or added in the last 48
hours.

<!-- gen:models-evaluated-partial:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/binaries/gemma12-unsloth-ud-q4kxl" top /> | **261k** | <TokCell shallow="47.39" deep="32.18" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.951/0.909" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 0h26 · Mendel —">0h26†</span> |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="OBLITERATUS" repo="OBLITERATUS/Qwen3.8-27B-OBLITERATED" offload="ngl 45/64" kv="q8_0" effort="medium" page="/binaries/qwen38-obliteratus-q4km" top /> | **64k** | <TokCell shallow="5.13" deep="2.31" cap="speed" top-shallow top-deep /> | <ScoreCell value="not run" /> | <ScoreCell value="not run" /> | — |

Fewer than two rows pass the filter of this table, so it shows every row it can hold.
<!-- gen:models-evaluated-partial:end -->

## Code quality — EvalPlus HumanEval+

<!-- gen:setup-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" page="/binaries/bonsai2-prism-pq2" />](./benchmarks/bonsai-2-27b.md) | 8192 | 16384 | <ScoreCell value="0.988/0.945" sub="100% completion" top /> | none | 12/164 | <TokCell shallow="46.0" deep="14.5" /> | 1h59 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-pq2" />](./benchmarks/bonsai-2-27b.md) | 8192 | 16384 | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | none | 12/164 | <TokCell shallow="46.3" deep="25.1" /> | 2h01 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" />](./benchmarks/bonsai-2-27b.md) | 8192 | 16384 | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | none | 16/164 | <TokCell shallow="41.7" deep="12.8" /> | 2h20 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" />](./benchmarks/bonsai-2-27b.md) | 8192 | 16384 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | 12/164 | <TokCell shallow="42.1" deep="22.4" /> | 2h05 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" page="/binaries/qwen38-ista-iq3s-mtp" />](./benchmarks/qwen3.8-27b.md) | 8192 | 10240 | <ScoreCell value="0.976/0.933" sub="100% completion" top /> | none | 11/164 | <TokCell shallow="29.43" deep="21.13" /> | 2h55 |
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" page="/binaries/qwen38-unsloth-ud-iq3s" />](./benchmarks/qwen3.8-27b.md) | 8192 | 16384 | <ScoreCell value="0.963/0.921" sub="100% completion" /> | none | 8/164 | <TokCell shallow="29.36" deep="20.92" /> | 3h08 |
| [<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/binaries/gemma12-unsloth-ud-q4kxl" />](./benchmarks/gemma-4-12b-it.md) | none | 8192 | <ScoreCell value="0.951/0.909" sub="100% completion" /> | none | — | <TokCell shallow="47.39" deep="32.18" /> | 0h26 |
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" page="/binaries/gemma12-freedomaisvr-nvfp4" />](./benchmarks/gemma-4-12b-it.md) | none | 8192 | <ScoreCell value="0.927/0.896" sub="100% completion" /> | none | — | <TokCell shallow="49.55" deep="33.11" /> | 0h51 |
<!-- gen:setup-evalplus:end -->

- Fast mode only: a thinking budget of 8192 and an output budget of
  16384 on every row ([method](../../methodology/evalplus.md)). A
  forced answer is a problem whose thinking hit the budget. Scores
  from earlier budgets are on each model's page with a †, until the
  fast-mode run lands.
- Empty: a problem with no answer. It counts as failed. The empties
  column carries the cause word
  ([what the words mean](../../benchmarks/evalplus.md#limits-on-local-hardware)).

## Findings

- **Gemma-4-12B: zero commits** on both builds, at thinking off and on.
- **VRAM for the desktop:** about 1.2 GB at idle. The ISTA n-max 2
  server crashed three times at about 440 MiB free.
- **EvalPlus at the default level of each model.** unsloth Qwen3.8
  0.957 / 0.921 and ISTA 0.945 / 0.909 at xhigh; Qwen3.6 0.945 / 0.902
  and Gemma-26B NVFP4Q8 0.909 / 0.878 at thinking on. Gemma-12B at thinking
  off: k-quant 0.951 / 0.909, NVFP4 0.927 / 0.896; at thinking on
  0.793 / 0.780 and 0.659 / 0.640. Every
  thinking-on row left empties; their cause is unproven.

## Per-model reports

- [Qwen3.8-27B](./reports/qwen3.8-27b.md)
- [Qwen3.6-35B-A3B](./reports/qwen3.6-35b-a3b.md)
- [Gemma-4-26B-A4B](./reports/gemma-4-26b-a4b.md)
- [Gemma-4-12B-it](./reports/gemma-4-12b-it.md)

## Benchmarks

- [Decode speed](../../benchmarks/decode-speed.md)
- [EvalPlus](../../benchmarks/evalplus.md): every row at its default
  level, and both Gemma-12B builds at both levels.
- [Mendel](../../benchmarks/mendel.md)
