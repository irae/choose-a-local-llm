# Local coding models on RTX 5060 Ti 16 GB

llama-server (CUDA) · measured 2026-09-13 to 2026-09-16

## Highlights

- **Pick: Qwen3.8-27B ISTA IQ3_S-mtp, no drafter, q8_0 KV.** Guided
  85 and blind 91, both 8 of 8. Window 61440. 29.4 → 21.1 tok/s.
- **Long window: Qwen3.6-35B-A3B, MTP n-max 2.** 97K at 61.2 → 45.4
  tok/s. Guided 48.5, 6 of 8.
- **Gemma-4-12B: zero commits** on both builds, at thinking off and on.
  NVFP4 serves 261K at 49.6 → 33.1 tok/s.
- **VRAM for the desktop:** about 1.2 GB at idle. The ISTA n-max 2
  server crashed three times at about 440 MiB free.
- **EvalPlus at the default level of each model.** unsloth Qwen3.8
  0.957 / 0.921 and ISTA 0.945 / 0.909 at xhigh; Qwen3.6 0.945 / 0.902
  and Gemma-26B NVFP4Q8 0.909 / 0.878 at thinking on. Gemma-12B at thinking
  off: k-quant 0.951 / 0.909, NVFP4 0.927 / 0.896; at thinking on
  0.793 / 0.780 and 0.659 / 0.640. Every
  thinking-on row left empties; their cause is unproven.

## Models evaluated

<!-- gen:models-evaluated:start -->
| Model / Config | Ctx | Cap | tok/s | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" page="/setups/arrietty/binaries/qwen38-ista-iq3s-mtp" top /> | 65k | mem | <TokCell shallow="29.43" deep="21.13" /> | <ScoreCell value="0.945/0.909" sub="96% completion" top /> | <ScoreCell value="91" pill="mendel-blind" top /> | <span title="EvalPlus 3h38 · Mendel 1h15">4h53</span> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" page="/setups/arrietty/binaries/qwen38-unsloth-ud-iq3s" top /> | 65k | mem | <TokCell shallow="29.36" deep="20.92" /> | <ScoreCell value="0.957/0.921" sub="98% completion" top /> | <ScoreCell value="79" note="88%" pill="mendel-guided" top /> | <span title="EvalPlus 4h50 · Mendel 4h46">9h36</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" page="/setups/arrietty/binaries/qwen36-unsloth-ud-q4kxl" /> | **97k** | mem | <TokCell shallow="61.16" deep="45.42" top-shallow top-deep /> | <ScoreCell value="0.945/0.902" sub="96% completion" top /> | <ScoreCell value="48.5" note="75%" pill="mendel-guided" /> | <span title="EvalPlus 3h12 · Mendel 0h27">3h39</span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" page="/setups/arrietty/binaries/gemma26-catlilface-nvfp4q8" /> | **97k** | mem | <TokCell shallow="58.77" deep="45.59" top-shallow top-deep /> | <ScoreCell value="0.909/0.878" sub="91% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> | <span title="EvalPlus 3h35 · Mendel 0h23">3h58</span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" page="/setups/arrietty/binaries/gemma12-freedomaisvr-nvfp4" /> | **261k** | mem | <TokCell shallow="49.55" deep="33.11" /> | <ScoreCell value="0.927/0.896" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h51 · Mendel 0h01">0h52</span> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" page="/setups/arrietty/binaries/gemma12-unsloth-ud-q4kxl" /> | **261k** | mem | <TokCell shallow="47.39" deep="32.18" /> | <ScoreCell value="0.793/0.780" sub="79% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 4h19 · Mendel 0h05">4h24</span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" page="/setups/arrietty/binaries/gemma12-freedomaisvr-nvfp4" /> | **261k** | mem | <TokCell shallow="49.55" deep="33.11" /> | <ScoreCell value="0.659/0.640" sub="68% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 3h24 · Mendel 0h06">3h29</span> |
<!-- gen:models-evaluated:end -->

Columns and sort: [the legend](../../#legend). Server commands: each
model's report. Aliases equal the pi model ids.

### Rows still being measured

Rows with two of the three measurements, or added in the last 48
hours.

<!-- gen:models-evaluated-partial:start -->
| Model / Config | Ctx | Cap | tok/s | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/setups/arrietty/binaries/gemma12-unsloth-ud-q4kxl" top /> | **261k** | mem | <TokCell shallow="47.39" deep="32.18" top-shallow top-deep /> | <ScoreCell value="0.951/0.909" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 0h26 · Mendel —">0h26†</span> |
<!-- gen:models-evaluated-partial:end -->

## Code quality — EvalPlus HumanEval+

<!-- gen:setup-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" page="/setups/arrietty/binaries/qwen38-unsloth-ud-iq3s" />](./benchmarks/qwen3.8-27b.md) | 19000 | <ScoreCell value="0.957/0.921" sub="98% completion" top /> | † unproven | <TokCell shallow="29.36" deep="20.92" /> | 4h50 |
| [<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/setups/arrietty/binaries/gemma12-unsloth-ud-q4kxl" />](./benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.951/0.909" sub="100% completion" top /> | none | <TokCell shallow="47.39" deep="32.18" /> | 0h26 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" page="/setups/arrietty/binaries/qwen38-ista-iq3s-mtp" />](./benchmarks/qwen3.8-27b.md) | 20500 | <ScoreCell value="0.945/0.909" sub="96% completion" top /> | † unproven | <TokCell shallow="29.43" deep="21.13" /> | 3h38 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" page="/setups/arrietty/binaries/qwen36-unsloth-ud-q4kxl" />](./benchmarks/qwen3.6-35b-a3b.md) | 24154 | <ScoreCell value="0.945/0.902" sub="96% completion" top /> | † unproven | <TokCell shallow="61.16" deep="45.42" /> | 3h12 |
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" page="/setups/arrietty/binaries/gemma12-freedomaisvr-nvfp4" />](./benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.927/0.896" sub="100% completion" top /> | none | <TokCell shallow="49.55" deep="33.11" /> | 0h51 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" page="/setups/arrietty/binaries/gemma26-catlilface-nvfp4q8" />](./benchmarks/gemma-4-26b-a4b.md) | 12500 | <ScoreCell value="0.909/0.878" sub="91% completion" top /> | † unproven | <TokCell shallow="58.77" deep="45.59" /> | 3h35 |
| [<ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" page="/setups/arrietty/binaries/gemma12-unsloth-ud-q4kxl" />](./benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.793/0.780" sub="79% completion" /> | † unproven | <TokCell shallow="47.39" deep="32.18" /> | 4h19 |
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" page="/setups/arrietty/binaries/gemma12-freedomaisvr-nvfp4" />](./benchmarks/gemma-4-12b-it.md) | 8192 | <ScoreCell value="0.659/0.640" sub="68% completion" /> | † unproven | <TokCell shallow="49.55" deep="33.11" /> | 3h24 |
<!-- gen:setup-evalplus:end -->

- Empty: a problem that ran to the budget with no answer. It counts as
  failed. The empties column carries the cause word
  ([what the words mean](../../benchmarks/evalplus.md#limits-on-local-hardware)).

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
