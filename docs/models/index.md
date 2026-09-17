# Models

Every config of every model, on every machine. The label under each
name is the machine. Columns and sort: [the legend](../#legend).

## Complete

tok/s, EvalPlus and Mendel are all measured.

<!-- gen:models-complete:start -->
| Model / Config | Ctx | Cap | tok/s | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" hide="server" top /> | 72k | mem | <TokCell shallow="12.4" deep="9.7" /> | <ScoreCell value="0.957/0.939" sub="96% completion" top /> | <ScoreCell value="93" pill="mendel-blind" top /> | <span title="EvalPlus 8h30 · Mendel 3h33">12h04</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-ista-iq3s-mtp" hide="server" top /> | 65k | mem | <TokCell shallow="29.43" deep="21.13" /> | <ScoreCell value="0.945/0.909" sub="96% completion" top /> | <ScoreCell value="91" pill="mendel-blind" top /> | <span title="EvalPlus 3h38 · Mendel 1h15">4h53</span> |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" hide="server" top /> | 72k | mem | <TokCell shallow="12.4" deep="9.7" /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="87" pill="mendel-blind" top /> | <span title="EvalPlus 3h32 · Mendel 2h09">5h42</span> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-unsloth-ud-iq3s" hide="server" top /> | 147k | speed | <TokCell shallow="13.60" deep="7.97" /> | <ScoreCell value="0.945/0.927" sub="100% completion" top /> | <ScoreCell value="90.5" pill="mendel-blind" top /> | <span title="EvalPlus 13h36 · Mendel 3h05">16h41</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" hide="server" top /> | 82k | speed | <TokCell shallow="43.7" deep="13.0" /> | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | <ScoreCell value="83" pill="mendel-guided" top /> | <span title="EvalPlus 5h02 · Mendel 1h32">6h33</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" hide="server" top /> | 147k | speed | <TokCell shallow="14.1" deep="8.1" /> | <ScoreCell value="0.945/0.921" sub="97% completion" top /> | <ScoreCell value="80.5" pill="mendel-blind" top /> | <span title="EvalPlus 9h43 · Mendel 1h49">11h33</span> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-unsloth-ud-iq3s" hide="server" top /> | 65k | mem | <TokCell shallow="29.36" deep="20.92" /> | <ScoreCell value="0.957/0.921" sub="98% completion" top /> | <ScoreCell value="79" note="88%" pill="mendel-guided" top /> | <span title="EvalPlus 4h50 · Mendel 4h46">9h36</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" hide="server" top /> | 128k | mem | <TokCell shallow="15.1" deep="9.7" stale /> | <ScoreCell value="0.976/0.945" sub="99% completion" top /> | <ScoreCell value="76.5" pill="mendel-blind" /> | <span title="EvalPlus 3h12 · Mendel 2h15">5h27</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" hide="server" /> | 147k | speed | <TokCell shallow="14.1" deep="8.1" /> | <ScoreCell value="0.976/0.933" sub="99% completion" top /> | <ScoreCell value="66" note="88%" pill="mendel-blind" /> | <span title="EvalPlus 2h27 · Mendel 2h43">5h10</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" hide="server" /> | 82k | speed | <TokCell shallow="43.7" deep="13.0" /> | <ScoreCell value="0.951/0.915" sub="100% completion" top /> | <ScoreCell value="62.5" pill="mendel-guided" /> | <span title="EvalPlus 0h15 · Mendel 1h29">1h44</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" hide="server" /> | 66k | mem | <TokCell shallow="50.5" deep="33.6" stale /> | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | <ScoreCell value="50" pill="mendel-blind" /> | <span title="EvalPlus 5h02 · Mendel 0h33">5h35</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/qwen36-unsloth-ud-q4kxl" hide="server" /> | 97k | mem | <TokCell shallow="61.16" deep="45.42" top-shallow top-deep /> | <ScoreCell value="0.945/0.902" sub="96% completion" top /> | <ScoreCell value="48.5" note="75%" pill="mendel-guided" /> | <span title="EvalPlus 3h12 · Mendel 0h27">3h39</span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" hide="server" /> | 197k | mem | <TokCell shallow="60.1" deep="19.1" top-shallow /> | <ScoreCell value="0.896/0.872" sub="90% completion" /> | <ScoreCell value="47.5" pill="mendel-blind" /> | <span title="EvalPlus 5h47 · Mendel 1h21">7h08</span> |
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-atomicchat-ad-iq3s" hide="server" /> | 104k | mem | <TokCell shallow="14.3" deep="9.6" /> | <ScoreCell value="0.988/0.927" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 3h11 · Mendel 1h00">4h10</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" hide="server" /> | **245k** | mem | <TokCell shallow="25.0" deep="9.2" /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> | <span title="EvalPlus 0h43 · Mendel 1h38">2h21</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-mlx-4bit" hide="server" /> | 37k | mem | <TokCell shallow="54.5" deep="39.1" top-shallow /> | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 5h02 · Mendel 0h19">5h20</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" hide="server" /> | 40k | mem | <TokCell shallow="24.5" deep="17.3" stale /> | <ScoreCell value="0.933/0.902" sub="99% completion" top /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 19h24 · Mendel 5h00">24h24</span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma26-catlilface-nvfp4q8" hide="server" /> | 97k | mem | <TokCell shallow="58.77" deep="45.59" top-shallow top-deep /> | <ScoreCell value="0.909/0.878" sub="91% completion" /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> | <span title="EvalPlus 3h35 · Mendel 0h23">3h58</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" /> | 33k | speed | <TokCell shallow="14.7" deep="7.8" /> | <ScoreCell value="0.927/0.890" sub="98% completion" /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" /> | <span title="EvalPlus 9h55 · Mendel 5h00">14h55</span> |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" hardware="m1-max-32gb" page="/binaries/qwen38-mlx-4bit" hide="server" /> | 25k | mem | <TokCell shallow="17.3" deep="14.8" /> | <ScoreCell value="0.976/0.927" sub="100% completion" top /> | <ScoreCell value="12.5†" note="13%" pill="mendel-blind" /> | <span title="EvalPlus 2h09 · Mendel 1h25">3h34</span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-freedomaisvr-nvfp4" hide="server" /> | **261k** | mem | <TokCell shallow="49.55" deep="33.11" /> | <ScoreCell value="0.927/0.896" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h51 · Mendel 0h01">0h52</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" hide="server" /> | 40k | mem | <TokCell shallow="24.5" deep="17.3" stale /> | <ScoreCell value="0.927/0.902" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h46 · Mendel 3h07">3h53</span> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-unsloth-ud-q4kxl" hide="server" /> | **261k** | mem | <TokCell shallow="47.39" deep="32.18" /> | <ScoreCell value="0.793/0.780" sub="79% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 4h19 · Mendel 0h05">4h24</span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-freedomaisvr-nvfp4" hide="server" /> | **261k** | mem | <TokCell shallow="49.55" deep="33.11" /> | <ScoreCell value="0.659/0.640" sub="68% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 3h24 · Mendel 0h06">3h29</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:models-complete:end -->

## Incomplete

One or two of the three are missing.

<!-- gen:models-incomplete:start -->
| Model / Config | Ctx | Cap | tok/s | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-mlx-4bit" hide="server" top /> | 25k | mem | <TokCell shallow="17.3" deep="14.8" /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 3h32 · Mendel —">3h32†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" hide="server" top /> | 2x82k | mem | <TokCell shallow="25.0" deep="15.7" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" hide="server" top /> | 4x49k | mem | <TokCell shallow="42.9" deep="27.7" stale top-deep /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" hide="server" top /> | 16k | speed | <TokCell shallow="13.8" deep="6.5" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" hide="server" top /> | 41k | mem | <TokCell shallow="69.1" deep="52.6" stale top-shallow top-deep /> | <ScoreCell value="0.957/0.939" sub="99% completion" /> | <ScoreCell value="pending" /> | <span title="EvalPlus 5h02 · Mendel —">5h02†</span> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-unsloth-ud-q4kxl" hide="server" top /> | **261k** | mem | <TokCell shallow="47.39" deep="32.18" top-deep /> | <ScoreCell value="0.951/0.909" sub="100% completion" /> | <ScoreCell value="not run" /> | <span title="EvalPlus 0h26 · Mendel —">0h26†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" top /> | 2x48k | speed | <TokCell shallow="14.9" deep="7.8" stale /> | <ScoreCell value="0.927/0.890" sub="98% completion" /> | <ScoreCell value="pending" /> | <span title="EvalPlus 9h55 · Mendel —">9h55†</span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" hide="server" top /> | 2x82k | mem | <TokCell shallow="66.6" deep="33.6" stale top-shallow top-deep /> | <ScoreCell value="0.896/0.872" sub="90% completion" /> | <ScoreCell value="pending" /> | <span title="EvalPlus 5h47 · Mendel —">5h47†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" hide="server" /> | **131k** | mem | <TokCell shallow="15.0" deep="9.7" stale /> | <ScoreCell value="pending" /> | <ScoreCell value="12.5" note="13%" pill="mendel-guided" top /> | <span title="EvalPlus — · Mendel 3h15">3h15†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:models-incomplete:end -->

## Choosing a quant or a provider

- **Qwen3.8-27B, M1 Max, blind at effort xhigh:** bartowski Q4_K_M 93
  (65K window), unsloth UD-IQ3_S 90.5 (147K), ISTA IQ3_S-mtp 80.5
  (147K). All three finished 8 of 8.
- **Qwen3.8-27B, RTX 5060 Ti, effort xhigh, q8_0 KV:** ISTA IQ3_S-mtp
  85 guided and 91 blind, both 8 of 8. unsloth UD-IQ3_S 79 guided, 7 of
  8. Both read about 29 → 21 tok/s.
- **Qwen3.8-27B EvalPlus at effort xhigh:** M1 Max, bartowski Q4_K_M
  0.957 / 0.939 (96%), unsloth UD-IQ3_S 0.945 / 0.927 (95%), ISTA
  IQ3_S-mtp 0.945 / 0.921 (97%). RTX 5060 Ti, unsloth 0.957 / 0.921
  (98%), ISTA 0.945 / 0.909 (96%). The two 3-bit builds sit within one
  point of each other on both machines. The best base scores of the
  project, 0.988 (AtomicChat) and 0.982 (MLX), came at effort medium,
  a level this model is no longer run at; the AtomicChat build ended
  its blind run on a loop at 3 of 8.
- **Qwen3.6-35B-A3B UD-Q4_K_XL, thinking on:** M1 Max 0.957 / 0.939
  and guided 83 on an 82K window; RTX 5060 Ti 0.945 / 0.902 and guided
  48.5 on a 97K window, one run each side.
- **MLX 4-bit against a GGUF k-quant, EvalPlus base:** Gemma-4-26B-A4B
  0.171 lower on MLX, Gemma-4-12B 0.067 lower, Qwen3.8-27B level.
- **MLX 4-bit Qwen3.8-27B on the agent task:** 12.5, 1 of 8, on a
  26624 window.
- **Gemma-4-12B, RTX 5060 Ti:** NVFP4 reads 2 to 5 percent faster than
  UD-Q4_K_XL. Both builds end the agent task with zero commits. EvalPlus
  on NVFP4: 0.927 / 0.896 at thinking off, 0.659 / 0.640 with 53
  empties at thinking on.
- **Gemma-4-26B-A4B:** unsloth UD-Q4_K_XL on the M1 Max, blind 47.5, 8
  of 8, EvalPlus 0.976 / 0.945 at thinking off and 0.896 / 0.872 at
  thinking on. catlilface NVFP4Q8 on the RTX 5060 Ti, guided 37.5, 3 of
  8, EvalPlus 0.909 / 0.878 at thinking on.

## Best per machine

| machine | best agent score | long window |
|---|---|---|
| M1 Max 32 GB | Qwen3.8-27B Q4_K_M, f16 KV, xhigh: blind 93, 65K window, 12.4 → 9.7 tok/s | Gemma-4-26B-A4B UD-Q4_K_XL, f16 KV: 197K at 60.1 → 19.1 tok/s, blind 47.5 |
| RTX 5060 Ti 16 GB | Qwen3.8-27B ISTA IQ3_S-mtp, q8_0 KV, xhigh: blind 91, 61K window, 29.4 → 21.1 tok/s | Qwen3.6-35B-A3B UD-Q4_K_XL, MTP n-max 2: 97K at 61.2 → 45.4 tok/s, guided 48.5 |
