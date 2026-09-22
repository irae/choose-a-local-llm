# Local coding models on M1 Max 32 GB

llama-server + mlx_lm.server + PrismML fork · wired limit 25000

## Highlights

- **Qwen3.8-27B, best agent rows.** Blind at effort xhigh: 93 on the
  4-bit GGUF (65K window), 90.5 on the unsloth UD-IQ3_S (147K), 80.5 on
  the ISTA IQ3_S-mtp (147K), all 8 of 8. EvalPlus at xhigh: 0.957 /
  0.939 on the 4-bit GGUF, 0.945 / 0.927 on the unsloth 3-bit. The
  project's best base, 0.988 on the AtomicChat 3-bit, came at effort
  medium, a level this model is no longer run at.
- **Gemma-4-26B-A4B, llama-server, f16 KV, MTP n-max 2.** 197K at
  60.1 → 19.1 tok/s. EvalPlus 0.976 / 0.945 / 100% at thinking off.
  Blind 47.5, 8 of 8.
- **Qwen3.6-35B-A3B, llama-server.** f16 KV, no drafter: 49.8 tok/s at
  4K, 38.3 at 40K. q8_0 KV with the drafter: 82K at 13.0 tok/s. Guided
  83 at thinking on, 62.5 at off.
- **Ternary Bonsai-2-27B, prism fork, PTQ1_0, f16 KV.** 160K window,
  17.9 → 9.1 tok/s. EvalPlus 0.988 / 0.939 / 100% at effort xhigh.

## Models evaluated

<!-- gen:models-evaluated:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" page="/binaries/qwen38-bartowski-q4km" top /> | 72k | <TokCell shallow="12.4" deep="9.7" cap="mem" /> | <ScoreCell value="0.982/0.951" sub="100% completion" top /> | <ScoreCell value="93" pill="mendel-blind" top /> | <span title="EvalPlus 5h04 · Mendel 3h33">8h38</span> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" page="/binaries/qwen38-unsloth-ud-iq3s" top /> | 147k | <TokCell shallow="13.60" deep="7.97" cap="speed" /> | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | <ScoreCell value="90.5" pill="mendel-blind" top /> | <span title="EvalPlus 6h29 · Mendel 3h05">9h34</span> |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="medium" page="/binaries/qwen38-bartowski-q4km" top /> | 72k | <TokCell shallow="12.4" deep="9.7" cap="mem" /> | <ScoreCell value="0.982/0.939†" sub="100% completion" top /> | <ScoreCell value="87" pill="mendel-blind" top /> | <span title="EvalPlus 3h32 · Mendel 2h09"><b>5h42</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" page="/binaries/qwen36-unsloth-ud-q4kxl" top /> | 82k | <TokCell shallow="43.7" deep="13.0" cap="speed" /> | <ScoreCell value="0.957/0.939†" sub="99% completion" /> | <ScoreCell value="83" pill="mendel-guided" top /> | <span title="EvalPlus 5h02 · Mendel 1h32">6h33</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" page="/binaries/qwen38-ista-iq3s-mtp" /> | 147k | <TokCell shallow="14.1" deep="8.1" cap="speed" /> | <ScoreCell value="0.945/0.921†" sub="97% completion" /> | <ScoreCell value="80.5" pill="mendel-blind" top /> | <span title="EvalPlus 9h43 · Mendel 1h49">11h33</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" page="/binaries/qwen38-ista-iq3s-mtp" /> | 128k | <TokCell shallow="15.1" deep="9.7" cap="mem" stale /> | <ScoreCell value="0.976/0.945†" sub="99% completion" top /> | <ScoreCell value="76.5" pill="mendel-blind" /> | <span title="EvalPlus 3h12 · Mendel 2h15"><b>5h27</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" page="/binaries/qwen38-ista-iq3s-mtp" /> | 147k | <TokCell shallow="14.1" deep="8.1" cap="speed" /> | <ScoreCell value="0.976/0.933†" sub="99% completion" top /> | <ScoreCell value="66" note="88%" pill="mendel-blind" /> | <span title="EvalPlus 2h27 · Mendel 2h43"><b>5h10</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | 82k | <TokCell shallow="43.7" deep="13.0" cap="speed" /> | <ScoreCell value="0.951/0.915" sub="100% completion" /> | <ScoreCell value="62.5" pill="mendel-guided" /> | <span title="EvalPlus 0h15 · Mendel 1h29"><b>1h44</b></span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" page="/binaries/gemma26-unsloth-ud-q4kxl" /> | **197k** | <TokCell shallow="60.1" deep="19.1" cap="mem" top-shallow /> | <ScoreCell value="0.988/0.957" sub="100% completion" top /> | <ScoreCell value="47.5" pill="mendel-blind" /> | <span title="EvalPlus 1h57 · Mendel 1h21"><b>3h18</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" page="/binaries/qwen36-unsloth-ud-q4kxl" /> | 66k | <TokCell shallow="50.5" deep="33.6" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="0.957/0.939†" sub="99% completion" /> | <ScoreCell value="50" pill="mendel-blind" /> | <span title="EvalPlus 5h02 · Mendel 0h33"><b>5h35</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" kv="f16" effort="medium" page="/binaries/qwen38-atomicchat-ad-iq3s" /> | 104k | <TokCell shallow="14.3" deep="9.6" cap="mem" /> | <ScoreCell value="0.988/0.927†" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 3h11 · Mendel 1h00"><b>4h10</b></span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/binaries/gemma12-unsloth-ud-q4kxl" /> | **245k** | <TokCell shallow="25.0" deep="9.2" cap="mem" /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> | <span title="EvalPlus 0h43 · Mendel 1h38"><b>2h21</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" page="/binaries/qwen36-mlx-4bit" /> | 37k | <TokCell shallow="54.5" deep="39.1" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.957/0.939" sub="99% completion" /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 5h02 · Mendel 0h19"><b>5h20</b></span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" page="/binaries/bonsai-mlx-2bit" /> | 40k | <TokCell shallow="24.5" deep="17.3" cap="mem" stale /> | <ScoreCell value="0.933/0.902" sub="99% completion" /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 19h24 · Mendel 5h00">24h24</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" page="/binaries/bonsai-prism-q2g64" /> | 33k | <TokCell shallow="14.7" deep="7.8" cap="speed" /> | <ScoreCell value="0.951/0.915" sub="100% completion" /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" /> | <span title="EvalPlus 9h11 · Mendel 5h00">14h11</span> |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" page="/binaries/qwen38-mlx-4bit" /> | 25k | <TokCell shallow="17.3" deep="14.8" cap="mem" /> | <ScoreCell value="0.976/0.927" sub="100% completion" top /> | <ScoreCell value="12.5†" note="13%" pill="mendel-blind" /> | <span title="EvalPlus 2h09 · Mendel 1h25"><b>3h34</b></span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" page="/binaries/bonsai-mlx-2bit" /> | 40k | <TokCell shallow="24.5" deep="17.3" cap="mem" stale /> | <ScoreCell value="0.927/0.902" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h46 · Mendel 3h07"><b>3h53</b></span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:models-evaluated:end -->

¹ LM Studio's MLX engine, retired ([why](./lmstudio-retired.md)).
² PrismML's llama.cpp fork, an approved exception to the no-forks rule.

Columns and sort: [the legend](../../#legend). On this machine an MLX
Ctx is the harness window, 5 percent under the measured ceiling. Server
commands: each model's report. Aliases equal the pi model ids.

### Rows still being measured

Rows with two of the three measurements, or added in the last 48
hours.

<!-- gen:models-evaluated-partial:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" top /> | **160k** | <TokCell shallow="17.9" deep="9.1" cap="mem" /> | <ScoreCell value="0.988/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 4h49 · Mendel —">4h49†</span> |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" page="/binaries/qwen38-mlx-4bit" top /> | 25k | <TokCell shallow="17.3" deep="14.8" cap="mem" /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 3h32 · Mendel —">3h32†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/binaries/gemma12-unsloth-ud-q4kxl" top /> | 2x82k | <TokCell shallow="25.0" deep="15.7" cap="mem" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="f16" effort="off" page="/binaries/gemma12-unsloth-ud-q4kxl" top /> | 4x49k | <TokCell shallow="42.9" deep="27.7" cap="mem" stale top-deep /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="q8_0" effort="off" page="/binaries/gemma12-unsloth-ud-q4kxl" top /> | 16k | <TokCell shallow="13.8" deep="6.5" cap="speed" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="f16" effort="on" page="/binaries/qwen36-unsloth-ud-q4kxl" top /> | 41k | <TokCell shallow="69.1" deep="52.6" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="0.957/0.939†" sub="99% completion" /> | <ScoreCell value="pending" /> | <span title="EvalPlus 5h02 · Mendel —">5h02†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" page="/binaries/bonsai-prism-q2g64" top /> | 2x48k | <TokCell shallow="14.9" deep="7.8" cap="speed" stale /> | <ScoreCell value="0.951/0.915" sub="100% completion" /> | <ScoreCell value="pending" /> | <span title="EvalPlus 9h11 · Mendel —">9h11†</span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" page="/binaries/gemma26-unsloth-ud-q4kxl" top /> | 2x82k | <TokCell shallow="66.6" deep="33.6" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="0.896/0.872†" sub="90% completion" /> | <ScoreCell value="pending" /> | <span title="EvalPlus 5h47 · Mendel —">5h47†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" page="/binaries/bonsai-prism-q2g64" /> | **131k** | <TokCell shallow="15.0" deep="9.7" cap="mem" stale /> | <ScoreCell value="pending" /> | <ScoreCell value="12.5" note="13%" pill="mendel-guided" top /> | <span title="EvalPlus — · Mendel 3h15">3h15†</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="MLX 2-bit" server="mlx" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-mlx-2bit" adapter="bonsai2-mlx-server.py" kv="f16" effort="on" /> | 28k | <TokCell shallow="21.47" deep="10.45" cap="mem" /> | <ScoreCell value="not run" /> | <ScoreCell value="not run" /> | — |

† from an earlier serving config or method; re-run pending.
<!-- gen:models-evaluated-partial:end -->

## Findings

- **Gemma-4-12B, llama-server, f16 KV.** 245K at 8.86 tok/s; two slots
  of 82K in 13.8 GB. EvalPlus 0.976 / 0.939 / 100% at thinking off.
- **Ternary Bonsai-27B.** 8 GB of weights. Prism fork: two 48K slots at
  9.8 tok/s in 10.0 GB; at f16 KV no speed floor to 131K. No complete
  agent row.
- **MLX 4-bit against GGUF on EvalPlus:** Gemma-4-26B-A4B 0.171 base
  lower on MLX, Gemma-4-12B 0.067 lower, Qwen3.8-27B level
  ([quantization](../../methodology/quantization.md)).

## Per-model reports

- [Qwen3.8-27B](./reports/qwen3.8-27b.md)
- [Qwen3.6-35B-A3B](./reports/qwen3.6-35b-a3b.md)
- [Gemma-4-26B-A4B](./reports/gemma-4-26b-a4b.md)
- [Gemma-4-12B-it](./reports/gemma-4-12b-it.md)
- [Ternary Bonsai-27B](./reports/bonsai-27b.md)

## Decode speed vs used context

Slow creeps, floor 8 tok/s. Rows from 2026-09-06 on ran at wired limit
25000; older rows ran at 24000 and say so in their config notes.

| config | max ctx | tok/s @ 4K | @ 16K | @ 32-33K | @ 49K | @ 74-90K | capped by | HumanEval+ (base/plus/completion) |
|---|--:|--:|--:|--:|--:|--:|---|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" hide="effort" top /> | 212992 | 60.3 | 56.5 | 45.9 | 45.9 | 26.4 (115K), 17.3 (197K) | mem — 212992 is the largest `-c` that loads; 17.3 tok/s at 197K | 0.976/0.945/100% off, 0.884/0.860/89% on |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" hide="effort" top /> | 41K, last stable step | 55.1 | 47.8 | 38.3 | | 37.4 (41K) | mem — stable to 41K, 37.4 tok/s there, then a Metal OOM | pending |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="f16" hide="effort" /> | 40960 | 69.1 | 65.7 | 56.5 | | 52.6 (41K) | mem — 40960 is the largest `-c` that serves a real request; no ceiling found inside it; a creep with the drafter, a ceiling until read on real text | 0.951/0.915/100% off, 0.939/0.921/97% on |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" hide="effort" top /> | 40960 | 49.8 | | | | 38.3 (40K) | mem — 40960 is the largest `-c` that serves a real request; read on real text at the server's sampling | 0.951/0.915/100% off, 0.939/0.921/97% on |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" hide="effort" /> | 98304 | 43.7 | 31.2 | 19.6 | 19.2 | 11.2 (66K), 13.0 (82K) | speed — 7.86 at 98K, under the floor; zero swap; the 4K, 49K and 82K cells read on real text with acceptance 54 to 85 percent, the others are creep readings | 0.951/0.915/100% off, 0.939/0.921/97% on |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" hide="effort" /> | 58K, last stable step | 24.5 | 22.9 | 20.5 | 18.8 | 17.3 (58K) | mem — stable to 58K, 17.3 tok/s there | 0.915/0.884/97% |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" hide="effort" top /> | 73728 | 11.8 | 16.1 | 16.4 | 15.0 | 8.6 (65.5K) | mem — 73728 is the largest `-c` that loads; the 4K and 65.5K cells read on real text with acceptance 37 to 63 percent, the others are creep readings | 0.982/0.939/100% (MLX score) |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" hide="effort" top /> | 163840 | 14.1 | 13.3 | 12.4 | 11.5 | 10.2 (82K), 8.3 (147K) | speed — 8.30 at 147K, under the floor at 164K; zero swap | 0.976/0.933/99% low, 0.945/0.921/97% xhigh |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" hide="effort" /> | 188416 | 13.7 | 12.9 | 12.0 | 11.3 | 10.0 (82K), 8.2 (147K) | speed — 8.17 at 147K, under the floor at 164K; zero swap; llama-benchy on real text reads 13.6 at 4K and 7.97 at 147K | pending |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" hide="effort" /> | 131072 | 15.1 | 14.7 | 13.7 | 12.7 | 11.0 (82K) | mem — clean to 114.7K at 9.7 tok/s | 0.976/0.945/99% |
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" hide="effort" /> | 106496 | 15.8 | 14.8 | 13.7 | 12.7 | 11.0 (82K) | untested — swept to 98.3K at 10.3 tok/s and never hit a stop | 0.988/0.927/100% |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" hide="effort" /> | 28K, last stable step | 17.1* | 16.4 | | | 15.3 (28K) | mem — stable to 28K, 15.3 tok/s there | 0.982/0.939/100% |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" hide="effort" top /> | 131072 | 15.0 | 15.6 | 14.5 | 13.4 | 11.5 (82K) | untested — no floor found; 9.7 tok/s at 131K, the `-c` boundary itself | pending |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" hide="effort" /> | 65536 | 14.9 | 10.8 | 7.9 | | 7.9 (32K) | speed — under 8 tok/s at 32K, single slot deep, other slot idle-loaded | 0.927/0.890/98% |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="q8_0" hide="effort" /> | 262144 | 13.8 | 6.5 | | | | speed — under 8 tok/s at 16K | 0.976/0.939/100% |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" hide="effort" top /> | 262144 | 24.6 | 22.7 | 20.6 | 18.8 | 8.86 (245K) | mem — 8.86 tok/s at 245K, where the trained window ends | 0.976/0.939/100% |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" hide="effort" /> | 196608, 2 slots | 25.0 | 22.8 | 20.6 | 18.6 | 15.7 (82K) | mem — swap grew at the step past 82K on every larger `-c`; 82K per slot is the ceiling | 0.976/0.939/100% |

- A blank cell: past the cap, or no step at that depth.
- **Max ctx**: the `-c` of the curve on llama-server and the fork; the
  last stable step before the Metal OOM on MLX.
- \*8K value.
- Retired curves: [LM Studio](./lmstudio-retired.md),
  [Gemma-26B MLX](./gemma-4-26b-a4b-mlx-retired.md).

## Code quality — EvalPlus HumanEval+

<!-- gen:setup-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" page="/binaries/gemma26-unsloth-ud-q4kxl" />](./benchmarks/gemma-4-26b-a4b.md) | 8192 | 16384 | <ScoreCell value="0.988/0.957" sub="100% completion" top /> | none | 19/164 | <TokCell shallow="60.1" deep="19.1" /> | 1h57 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/binaries/bonsai2-prism-ptq1" />](./benchmarks/bonsai-2-27b.md) | 8192 | 16384 | <ScoreCell value="0.988/0.939" sub="100% completion" top /> | none | 10/164 | <TokCell shallow="17.9" deep="9.1" /> | 4h49 |
| [<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" page="/binaries/qwen38-bartowski-q4km" />](./benchmarks/qwen3.8-27b.md) | 8192 | 16384 | <ScoreCell value="0.982/0.951" sub="100% completion" top /> | none | 9/164 | <TokCell shallow="12.4" deep="9.7" /> | 5h04 |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" page="/binaries/gemma26-unsloth-ud-q4kxl" />](./benchmarks/gemma-4-26b-a4b.md) | none | 8192 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | — | <TokCell shallow="60.1" deep="19.1" /> | 0h20 |
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" page="/binaries/qwen38-unsloth-ud-iq3s" />](./benchmarks/qwen3.8-27b.md) | 8192 | 16384 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | 17/164 | <TokCell shallow="13.60" deep="7.97" /> | 6h29 |
| [<ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/binaries/gemma12-unsloth-ud-q4kxl" />](./benchmarks/gemma-4-12b-it.md) | none | 8192 | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | none | — | <TokCell shallow="25.0" deep="9.2" /> | 0h43 |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" page="/binaries/qwen36-unsloth-ud-q4kxl" />](./benchmarks/qwen3.6-35b-a3b.md) | none | 8192 | <ScoreCell value="0.951/0.915" sub="100% completion" /> | none | — | <TokCell shallow="43.7" deep="13.0" /> | 0h15 |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" page="/binaries/bonsai-prism-q2g64" />](./benchmarks/bonsai-27b.md) | 8192 | 16384 | <ScoreCell value="0.951/0.915" sub="100% completion" /> | none | 4/164 | <TokCell shallow="14.7" deep="7.8" /> | 9h11 |
| [<ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="off" page="/binaries/gemma12-lmstudio-mlx-4bit" />](./benchmarks/gemma-4-12b-it.md) | none | 30000 | <ScoreCell value="0.909/0.872" sub="100% completion" /> | none | — | <TokCell shallow="34.19" deep="23.23" /> | 1h33 |
<!-- gen:setup-evalplus:end -->

- Fast mode only: a thinking budget of 8192 and an output budget of
  16384 on every row ([method](../../methodology/evalplus.md)). A
  forced answer is a problem whose thinking hit the budget. Scores
  from earlier budgets are on each model's page with a †, until the
  fast-mode run lands.
- Empty: a problem with no answer. It counts as failed. The empties
  column carries the cause word
  ([what the words mean](../../benchmarks/evalplus.md#limits-on-local-hardware)).
- Scores under the uncalibrated budget: [historical](./historical.md).

## Mendel — agentic quality

Every row, blind and guided: [the Mendel page](../../benchmarks/mendel.md).
Hosted reports: <a href="../../mendel/report.html" target="_blank" rel="noreferrer">blind</a> ·
<a href="../../mendel/report-guided.html" target="_blank" rel="noreferrer">guided</a>.
Rows on older prompt versions: [historical](./historical.md).
