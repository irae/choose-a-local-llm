# Local coding models on M1 Max 32 GB

llama-server + mlx_lm.server + PrismML fork · wired limit 25000

## Highlights

- **Qwen3.8-27B, best agent rows.** Blind at effort xhigh: 93 on the
  4-bit GGUF (65K window), 90.5 on the unsloth UD-IQ3_S (147K), 80.5 on
  the ISTA IQ3_S-mtp (147K), all 8 of 8. EvalPlus best: 0.988 base
  (AtomicChat), 0.945 plus (ISTA), both at effort medium.
- **Gemma-4-26B-A4B, llama-server, f16 KV, MTP n-max 2.** 197K at
  60.1 → 19.1 tok/s. EvalPlus 0.976 / 0.945 / 100% at thinking off.
  Blind 47.5, 8 of 8.
- **Qwen3.6-35B-A3B, llama-server.** f16 KV, no drafter: 49.8 tok/s at
  4K, 38.3 at 40K. q8_0 KV with the drafter: 82K at 13.0 tok/s. Guided
  83 at thinking on, 62.5 at off.
- **Gemma-4-12B, llama-server, f16 KV.** 245K at 8.86 tok/s; two slots
  of 82K in 13.8 GB. EvalPlus 0.976 / 0.939 / 100% at thinking off.
- **Ternary Bonsai-27B.** 8 GB of weights. Prism fork: two 48K slots at
  9.8 tok/s in 10.0 GB; at f16 KV no speed floor to 131K. No complete
  agent row.
- **MLX 4-bit against GGUF on EvalPlus:** Gemma-4-26B-A4B 0.171 base
  lower on MLX, Gemma-4-12B 0.067 lower, Qwen3.8-27B level
  ([quantization](../../methodology/quantization.md)).

## Models evaluated

<!-- gen:models-evaluated:start -->
| Model / Config | Ctx | Cap | tok/s | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" top /> | 72k | mem | <TokCell shallow="12.4" deep="9.7" /> | <ScoreCell value="0.957/0.939" sub="96% completion" /> | <ScoreCell value="93" pill="mendel-blind" top /> |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="medium" top /> | 72k | mem | <TokCell shallow="12.4" deep="9.7" /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="87" pill="mendel-blind" top /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" top /> | 82k | speed | <TokCell shallow="43.7" deep="13.0" /> | <ScoreCell value="0.939/0.921" sub="97% completion" /> | <ScoreCell value="83" pill="mendel-guided" top /> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" top /> | 147k | speed | <TokCell shallow="14.1" deep="8.1" /> | <ScoreCell value="0.945/0.921" sub="97% completion" /> | <ScoreCell value="80.5" pill="mendel-blind" top /> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" top /> | 128k | mem | <TokCell shallow="15.1" deep="9.7" stale /> | <ScoreCell value="0.976/0.945" sub="99% completion" top /> | <ScoreCell value="76.5" pill="mendel-blind" top /> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" /> | 147k | speed | <TokCell shallow="14.1" deep="8.1" /> | <ScoreCell value="0.976/0.933" sub="99% completion" top /> | <ScoreCell value="66" note="88%" pill="mendel-blind" /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" /> | 82k | speed | <TokCell shallow="43.7" deep="13.0" /> | <ScoreCell value="0.951/0.915" sub="100% completion" /> | <ScoreCell value="62.5" pill="mendel-guided" /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" /> | 66k | mem | <TokCell shallow="50.5" deep="33.6" stale top-shallow top-deep /> | <ScoreCell value="0.939/0.921" sub="97% completion" /> | <ScoreCell value="50" pill="mendel-blind" /> |
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" kv="f16" effort="medium" /> | 104k | mem | <TokCell shallow="14.3" deep="9.6" /> | <ScoreCell value="0.988/0.927" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" /> | **197k** | mem | <TokCell shallow="60.1" deep="19.1" top-shallow /> | <ScoreCell value="0.884/0.860" sub="89% completion" /> | <ScoreCell value="47.5" pill="mendel-blind" /> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" /> | **245k** | mem | <TokCell shallow="25.0" deep="9.2" /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" /> | 37k | mem | <TokCell shallow="54.5" deep="39.1" top-shallow top-deep /> | <ScoreCell value="0.939/0.921" sub="97% completion" /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" /> | 40k | mem | <TokCell shallow="24.5" deep="17.3" stale /> | <ScoreCell value="0.915/0.884" sub="97% completion" /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" /> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" /> | 33k | speed | <TokCell shallow="14.7" deep="7.8" /> | <ScoreCell value="0.927/0.890" sub="98% completion" /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" /> |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" /> | 25k | mem | <TokCell shallow="17.3" deep="14.8" /> | <ScoreCell value="0.976/0.927" sub="100% completion" top /> | <ScoreCell value="12.5†" note="13%" pill="mendel-blind" /> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" /> | 40k | mem | <TokCell shallow="24.5" deep="17.3" stale /> | <ScoreCell value="0.927/0.902" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> |

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
| Model / Config | Ctx | Cap | tok/s | EvalPlus | Coding |
|---|--:|:--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" top /> | 25k | mem | <TokCell shallow="17.3" deep="14.8" /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="not run" /> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" top /> | 2x82k | mem | <TokCell shallow="25.0" deep="15.7" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="f16" effort="off" top /> | 4x49k | mem | <TokCell shallow="42.9" deep="27.7" stale top-deep /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="q8_0" effort="off" top /> | 16k | speed | <TokCell shallow="13.8" deep="6.5" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="f16" effort="on" top /> | 41k | mem | <TokCell shallow="69.1" deep="52.6" stale top-shallow top-deep /> | <ScoreCell value="0.939/0.921" sub="97% completion" /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" top /> | 2x48k | speed | <TokCell shallow="14.9" deep="7.8" stale /> | <ScoreCell value="0.927/0.890" sub="98% completion" /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" top /> | **147k** | speed | <TokCell shallow="13.60" deep="7.97" /> | <ScoreCell value="pending" /> | <ScoreCell value="90.5" pill="mendel-blind" top /> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" top /> | 2x82k | mem | <TokCell shallow="66.6" deep="33.6" stale top-shallow top-deep /> | <ScoreCell value="0.884/0.860" sub="89% completion" /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" /> | **131k** | mem | <TokCell shallow="15.0" deep="9.7" stale /> | <ScoreCell value="pending" /> | <ScoreCell value="12.5" note="13%" pill="mendel-guided" top /> |

† from an earlier serving config or method; re-run pending.
<!-- gen:models-evaluated-partial:end -->

## Per-model reports

- [Qwen3.8-27B](./reports/qwen3.8-27b.md)
- [Qwen3.6-35B-A3B](./reports/qwen3.6-35b-a3b.md)
- [Gemma-4-26B-A4B](./reports/gemma-4-26b-a4b.md)
- [Gemma-4-12B-it](./reports/gemma-4-12b-it.md)
- [Ternary Bonsai-27B](./reports/bonsai-27b.md)

## Decode speed vs used context

Slow creeps, floor 8 tok/s. Rows from 2026-09-06 on ran at wired limit
25000; older rows ran at 24000 and say so in their config notes.

| config | max ctx | tok/s @ 4K | @ 16K | @ 32-33K | @ 49K | @ 74-90K | capped by | EvalPlus (base/plus/completion) |
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

| config | budget | pass@1 base | pass@1 plus | completion | status |
|---|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" top /> | 8886 | **0.988** | 0.927 | 100% | 0 empty, 3h10 |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" /> | 8192 | 0.982 | 0.939 | 100% | 0 empty; the 4-bit GGUF at medium carries this score |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" /> | 8192 | 0.976 | **0.945** | 99% | 1 empty, 3h07 |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" /> | 8192 | 0.976 | 0.933 | 99% | 1 empty, 2h23 |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" /> | 30000 | 0.945 | 0.921 | 97% | 5 empty at the 30000 cap, 9h43 |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" /> | 30000 | 0.957 | 0.939 | 96% | 6 empty at the cap, 8h30 |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" top /> | 8192 | **0.976** | **0.945** | 100% | 0 empty, 19 minutes |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" /> | 30000 | 0.884 | 0.860 | 89% | 18/164 empty |
| <ModelSpec base="Gemma-4-26B-A4B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/gemma-4-26b-a4b-it-4bit" kv="f16" effort="on" /> | 30000 | 0.713 | 0.701 | 72% | 46/164 empty |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" top /> | 8192 | **0.976** | **0.939** | 100% | 0 empty |
| <ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="off" /> | 30000 | 0.909 | 0.872 | 100% | 0 empty |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" top /> | 8192 | **0.951** | 0.915 | 100% | 0 empty, 15 minutes |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" /> | 26624 | 0.939 | **0.921** | 97% | 5/164 empty |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" top /> | 10240 | **0.915** | **0.884** | 97% | 5/164 empty |

- Empty: a problem that ran to the budget with no answer. It counts as
  failed.
- Scores under the uncalibrated budget: [historical](./historical.md).

## Mendel — agentic quality

Every row, blind and guided: [the Mendel page](../../benchmarks/mendel.md).
Hosted reports: <a href="../../mendel/report.html" target="_blank" rel="noreferrer">blind</a> ·
<a href="../../mendel/report-guided.html" target="_blank" rel="noreferrer">guided</a>.
Rows on older prompt versions: [historical](./historical.md).
