# Models

Every config of every model, on every machine. The label under each
name is the machine. Columns and sort: [the legend](../#legend).

## Complete

tok/s, EvalPlus and Mendel are all measured.

<!-- gen:models-complete:start -->
| Model / Config | Ctx | Cap | tok/s | EvalPlus | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" hide="server" top /> | 72k | mem | <TokCell shallow="12.4" deep="9.7" /> | <ScoreCell value="0.957/0.939" sub="96% completion" /> | <ScoreCell value="93" pill="mendel-blind" top /> | <span title="EvalPlus 8h30 · Mendel 3h33">12h04</span> |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="medium" hardware="m1-max-32gb" hide="server" top /> | 72k | mem | <TokCell shallow="12.4" deep="9.7" /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="87" pill="mendel-blind" top /> | <span title="EvalPlus 2h50 · Mendel 2h09">4h59</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" hide="server" top /> | 82k | speed | <TokCell shallow="43.7" deep="13.0" /> | <ScoreCell value="0.939/0.921" sub="97% completion" /> | <ScoreCell value="83" pill="mendel-guided" top /> | <span title="EvalPlus 9h05 · Mendel 1h32">10h37</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" hide="server" top /> | 147k | speed | <TokCell shallow="14.1" deep="8.1" /> | <ScoreCell value="0.945/0.921" sub="97% completion" /> | <ScoreCell value="80.5" pill="mendel-blind" top /> | <span title="EvalPlus 9h43 · Mendel 1h49">11h33</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" hide="server" top /> | 128k | mem | <TokCell shallow="15.1" deep="9.7" stale /> | <ScoreCell value="0.976/0.945" sub="99% completion" top /> | <ScoreCell value="76.5" pill="mendel-blind" top /> | <span title="EvalPlus 3h08 · Mendel 2h15">5h23</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" hardware="m1-max-32gb" hide="server" /> | 147k | speed | <TokCell shallow="14.1" deep="8.1" /> | <ScoreCell value="0.976/0.933" sub="99% completion" top /> | <ScoreCell value="66" note="88%" pill="mendel-blind" /> | <span title="EvalPlus 2h23 · Mendel 2h43">5h06</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" hide="server" /> | 82k | speed | <TokCell shallow="43.7" deep="13.0" /> | <ScoreCell value="0.951/0.915" sub="100% completion" /> | <ScoreCell value="62.5" pill="mendel-guided" /> | <span title="EvalPlus 0h15 · Mendel 1h29">1h44</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" hardware="m1-max-32gb" hide="server" /> | 66k | mem | <TokCell shallow="50.5" deep="33.6" stale top-shallow top-deep /> | <ScoreCell value="0.939/0.921" sub="97% completion" /> | <ScoreCell value="50" pill="mendel-blind" /> | <span title="EvalPlus 9h05 · Mendel 0h33">9h38</span> |
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" kv="f16" effort="medium" hardware="m1-max-32gb" hide="server" /> | 104k | mem | <TokCell shallow="14.3" deep="9.6" /> | <ScoreCell value="0.988/0.927" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 3h11 · Mendel 1h00">4h10</span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" hide="server" /> | **197k** | mem | <TokCell shallow="60.1" deep="19.1" top-shallow /> | <ScoreCell value="0.884/0.860" sub="89% completion" /> | <ScoreCell value="47.5" pill="mendel-blind" /> | <span title="EvalPlus 3h47 · Mendel 1h21">5h08</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" hide="server" /> | **245k** | mem | <TokCell shallow="25.0" deep="9.2" /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> | <span title="EvalPlus 0h12 · Mendel 1h38">1h49</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" hardware="m1-max-32gb" hide="server" /> | 37k | mem | <TokCell shallow="54.5" deep="39.1" top-shallow top-deep /> | <ScoreCell value="0.939/0.921" sub="97% completion" /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 9h05 · Mendel 0h19">9h24</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" hide="server" /> | 40k | mem | <TokCell shallow="24.5" deep="17.3" stale /> | <ScoreCell value="0.915/0.884" sub="97% completion" /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 3h20 · Mendel 5h00">8h20</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" hide="server" /> | 33k | speed | <TokCell shallow="14.7" deep="7.8" /> | <ScoreCell value="0.927/0.890" sub="98% completion" /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" /> | <span title="EvalPlus 16h20 · Mendel 5h00">21h20</span> |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" hardware="m1-max-32gb" hide="server" /> | 25k | mem | <TokCell shallow="17.3" deep="14.8" /> | <ScoreCell value="0.976/0.927" sub="100% completion" top /> | <ScoreCell value="12.5†" note="13%" pill="mendel-blind" /> | <span title="EvalPlus 2h09 · Mendel 1h25">3h34</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" hardware="m1-max-32gb" hide="server" /> | 40k | mem | <TokCell shallow="24.5" deep="17.3" stale /> | <ScoreCell value="0.927/0.902" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h46 · Mendel 3h07">3h53</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:models-complete:end -->

## Incomplete

One or two of the three are missing.

<!-- gen:models-incomplete:start -->
| Model / Config | Ctx | Cap | tok/s | EvalPlus | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" hardware="m1-max-32gb" hide="server" top /> | 25k | mem | <TokCell shallow="17.3" deep="14.8" /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 2h50 · Mendel —">2h50†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" hide="server" top /> | 2x82k | mem | <TokCell shallow="25.0" deep="15.7" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h12 · Mendel —">0h12†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="f16" effort="off" hardware="m1-max-32gb" hide="server" top /> | 4x49k | mem | <TokCell shallow="42.9" deep="27.7" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h12 · Mendel —">0h12†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="q8_0" effort="off" hardware="m1-max-32gb" hide="server" top /> | 16k | speed | <TokCell shallow="13.8" deep="6.5" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h12 · Mendel —">0h12†</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="f16" effort="on" hardware="m1-max-32gb" hide="server" top /> | 41k | mem | <TokCell shallow="69.1" deep="52.6" stale top-shallow top-deep /> | <ScoreCell value="0.939/0.921" sub="97% completion" /> | <ScoreCell value="pending" /> | <span title="EvalPlus 9h05 · Mendel —">9h05†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" hide="server" top /> | 2x48k | speed | <TokCell shallow="14.9" deep="7.8" stale /> | <ScoreCell value="0.927/0.890" sub="98% completion" /> | <ScoreCell value="pending" /> | <span title="EvalPlus 16h20 · Mendel —">16h20†</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" hide="server" top /> | 65k | mem | <TokCell shallow="29.43" deep="21.13" /> | <ScoreCell value="pending" /> | <ScoreCell value="91" pill="mendel-blind" top /> | <span title="EvalPlus — · Mendel 1h15">1h15†</span> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" hide="server" top /> | **147k** | speed | <TokCell shallow="13.60" deep="7.97" /> | <ScoreCell value="pending" /> | <ScoreCell value="90.5" pill="mendel-blind" top /> | <span title="EvalPlus — · Mendel 3h05">3h05†</span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" hide="server" top /> | 2x82k | mem | <TokCell shallow="66.6" deep="33.6" stale top-shallow /> | <ScoreCell value="0.884/0.860" sub="89% completion" /> | <ScoreCell value="pending" /> | <span title="EvalPlus 3h47 · Mendel —">3h47†</span> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" hide="server" /> | 65k | mem | <TokCell shallow="29.36" deep="20.92" /> | <ScoreCell value="pending" /> | <ScoreCell value="79" note="88%" pill="mendel-guided" top /> | <span title="EvalPlus — · Mendel 4h46">4h46†</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" hide="server" /> | 97k | mem | <TokCell shallow="61.16" deep="45.42" top-shallow top-deep /> | <ScoreCell value="pending" /> | <ScoreCell value="48.5" note="75%" pill="mendel-guided" /> | <span title="EvalPlus — · Mendel 0h27">0h27†</span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" hide="server" /> | 97k | mem | <TokCell shallow="58.77" deep="45.59" top-shallow top-deep /> | <ScoreCell value="pending" /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> | <span title="EvalPlus — · Mendel 0h23">0h23†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" hardware="m1-max-32gb" hide="server" /> | **131k** | mem | <TokCell shallow="15.0" deep="9.7" stale /> | <ScoreCell value="pending" /> | <ScoreCell value="12.5" note="13%" pill="mendel-guided" /> | <span title="EvalPlus — · Mendel 3h15">3h15†</span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" hide="server" /> | **261k** | mem | <TokCell shallow="49.55" deep="33.11" /> | <ScoreCell value="pending" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus — · Mendel 0h01">0h01†</span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" hide="server" /> | **261k** | mem | <TokCell shallow="49.55" deep="33.11" /> | <ScoreCell value="pending" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus — · Mendel 0h06">0h06†</span> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" hide="server" /> | **261k** | mem | <TokCell shallow="47.39" deep="32.18" /> | <ScoreCell value="pending" /> | <ScoreCell value="not run" /> | — |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" hide="server" /> | **261k** | mem | <TokCell shallow="47.39" deep="32.18" /> | <ScoreCell value="pending" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus — · Mendel 0h05">0h05†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:models-incomplete:end -->

## Choosing a quant or a provider

- **Qwen3.8-27B, M1 Max, blind at effort xhigh:** bartowski Q4_K_M 93
  (65K window), unsloth UD-IQ3_S 90.5 (147K), ISTA IQ3_S-mtp 80.5
  (147K). All three finished 8 of 8.
- **Qwen3.8-27B, RTX 5060 Ti, effort xhigh, q8_0 KV:** ISTA IQ3_S-mtp
  85 guided and 91 blind, both 8 of 8. unsloth UD-IQ3_S 79 guided, 7 of
  8. Both read about 29 → 21 tok/s.
- **Qwen3.8-27B EvalPlus, M1 Max, effort medium:** AtomicChat AD-IQ3_S
  0.988 base, ISTA IQ3_S-mtp 0.945 plus, MLX 4-bit 0.982 / 0.939. The
  AtomicChat build ended its blind run on a loop at 3 of 8.
- **MLX 4-bit against a GGUF k-quant, EvalPlus base:** Gemma-4-26B-A4B
  0.171 lower on MLX, Gemma-4-12B 0.067 lower, Qwen3.8-27B level.
- **MLX 4-bit Qwen3.8-27B on the agent task:** 12.5, 1 of 8, on a
  26624 window.
- **Gemma-4-12B, RTX 5060 Ti:** NVFP4 reads 2 to 5 percent faster than
  UD-Q4_K_XL. Both builds end the agent task with zero commits.
- **Gemma-4-26B-A4B:** unsloth UD-Q4_K_XL on the M1 Max, blind 47.5, 8
  of 8. catlilface NVFP4Q8 on the RTX 5060 Ti, guided 37.5, 3 of 8.

## Best per machine

| machine | best agent score | long window |
|---|---|---|
| M1 Max 32 GB | Qwen3.8-27B Q4_K_M, f16 KV, xhigh: blind 93, 65K window, 12.4 → 9.7 tok/s | Gemma-4-26B-A4B UD-Q4_K_XL, f16 KV: 197K at 60.1 → 19.1 tok/s, blind 47.5 |
| RTX 5060 Ti 16 GB | Qwen3.8-27B ISTA IQ3_S-mtp, q8_0 KV, xhigh: blind 91, 61K window, 29.4 → 21.1 tok/s | Qwen3.6-35B-A3B UD-Q4_K_XL, MTP n-max 2: 97K at 61.2 → 45.4 tok/s, guided 48.5 |
