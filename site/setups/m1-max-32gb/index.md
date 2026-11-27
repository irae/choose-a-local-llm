# Apple M1 Max 32 GB

Unified-memory Apple Silicon workstation serving local coding models over Metal (`llama-server`, PrismML `llama.cpp` fork, and `mlx_lm.server`).

## Hardware & Standing Limits

- **SoC & Memory:** Apple M1 Max, 32 GB unified memory, macOS.
- **Standing Metal limit:** `iogpu.wired_limit_mb=25000` (25 GB GPU wired cap; leaves headroom for macOS without swap thrashing during dedicated model-server runs).
- **Workload profile:** Dedicated single-stream model server (`--parallel 1`, `-ngl 999 -fa on`).
- **Retired runtimes & older eras:** LM Studio, Gemma-4-26B-A4B MLX, and pre-25000 measurements live in the [M1 Max archive](/setups/m1-max-32gb/archive).

## Top Picks

- **Best overall coding agent:** [Qwen3.8-27B](/models/qwen3.8-27b) Q4_K_M (`bartowski`, `f16` KV, no drafter, `xhigh`) — **93/100 blind** (8/8 libraries, 0 critical, 1 medium, 64k window, 3 compactions, 213 min; also **91/100** under an 8192 thinking budget), **0.982 / 0.951** fast-mode EvalPlus (`9/164` forced), `72k` ctx at `12.4 → 9.7 tok/s`.
- **Best long-context 27B:** [Qwen3.8-27B](/models/qwen3.8-27b) 3-bit (`ISTA IQ3_S-mtp` or `unsloth UD-IQ3_S`, `f16` KV, no drafter, `xhigh`) — `147k` speed-capped window (~8 tok/s floor), both **0.976 / 0.945** fast-mode EvalPlus. ISTA scores **80.5/100** blind (**87/100** under 8192 thinking budget); unsloth scored **90.5/100** blind *(anomaly: merged `master` mid-run; not strictly base-comparable)*.
- **Best fast MoE:** [Qwen3.6-35B-A3B](/models/qwen3.6-35b-a3b) UD-Q4_K_XL (`unsloth`, `q8_0` KV, `mtp/3`, thinking on) — **83/100 guided** / **63/100 blind** (both 8/8), **0.976 / 0.939** fast-mode EvalPlus, `82k` ctx at `43.7 → 13.0 tok/s`. *(Note: `llama-server` b10964 crashes when combining MTP `n=3` with `--reasoning-budget`; no-drafter diagnostic completed cleanly at 79/100.)*
- **Longest complete agent window:** [Gemma-4-26B-A4B](/models/gemma-4-26b-a4b) UD-Q4_K_XL (`unsloth`, `f16` KV, `mtp/2`, thinking on) — `197k` ctx at `60.1 → 19.1 tok/s`, **0.988 / 0.957** fast-mode EvalPlus, **47.5/100 blind** / **57/100 guided**.

## M1 Max Metal Quirks

- **Prefer `f16` KV over `q8_0`:** Metal dequantization of `q8_0` KV costs 2–4 µs/token vs 0.2–0.3 µs for `f16` (dropping Gemma-4-26B from `45.9` to `6.3 tok/s` at 32K). Use `q8_0` only when memory forces it (such as Qwen3.6 at `82k`).
- **MTP helps MoEs, hurts dense 27B models:** On real code text, MTP loses at every depth on dense Qwen3.8 builds, so serve them without a drafter. MTP wins on Qwen3.6 (`mtp/3`) and Gemma-4-26B (`mtp/2`).
- **Ternary packing flips on Metal:** [Ternary-Bonsai-2-27B](/models/bonsai-2-27b) (PrismML fork) `PTQ1_0` (`160k`, `17.9 → 9.1 tok/s`, **0.988 / 0.939** EvalPlus) beats `PQ2_0` (`41k` floor) at every depth — opposite of CUDA.
- **MLX trade-off:** `mlx_lm.server` lacks slots, ignores `--reasoning-budget`, and OOMs abruptly in the generation thread (always pass `--prompt-cache-size 2` and keep a 5% harness margin).

## Complete Configurations

<!-- gen:setup-complete:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" page="/files/qwen38-bartowski-q4km" model-page="/models/qwen3.8-27b" top /> | 72k | <TokCell shallow="12.4" deep="9.7" cap="mem" /> | <ScoreCell value="0.982/0.951" sub="100% completion" top /> | <ScoreCell value="93" pill="mendel-blind" top /> | <span title="EvalPlus 5h04 · Mendel 3h33">8h38</span> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" page="/files/qwen38-unsloth-ud-iq3s" model-page="/models/qwen3.8-27b" top /> | 147k | <TokCell shallow="13.60" deep="7.97" cap="speed" /> | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | <ScoreCell value="90.5" pill="mendel-blind" top /> | <span title="EvalPlus 6h29 · Mendel 3h05">9h34</span> |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="medium" page="/files/qwen38-bartowski-q4km" model-page="/models/qwen3.8-27b" top /> | 72k | <TokCell shallow="12.4" deep="9.7" cap="mem" /> | <ScoreCell value="0.982/0.939†" sub="100% completion" top /> | <ScoreCell value="87" pill="mendel-blind" top /> | <span title="EvalPlus 3h32 · Mendel 2h09"><b>5h42</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" top /> | 82k | <TokCell shallow="43.7" deep="13.0" cap="speed" /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="83" pill="mendel-guided" top /> | <span title="EvalPlus 2h27 · Mendel 1h32"><b>3h59</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" page="/files/qwen38-ista-iq3s-mtp" model-page="/models/qwen3.8-27b" top /> | 147k | <TokCell shallow="14.1" deep="8.1" cap="speed" /> | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | <ScoreCell value="80.5" pill="mendel-blind" top /> | <span title="EvalPlus 5h32 · Mendel 1h49">7h21</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" page="/files/qwen38-ista-iq3s-mtp" model-page="/models/qwen3.8-27b" /> | 128k | <TokCell shallow="15.1" deep="9.7" cap="mem" stale /> | <ScoreCell value="0.976/0.945†" sub="99% completion" top /> | <ScoreCell value="76.5" pill="mendel-blind" /> | <span title="EvalPlus 3h12 · Mendel 2h15"><b>5h27</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" page="/files/qwen38-ista-iq3s-mtp" model-page="/models/qwen3.8-27b" /> | 147k | <TokCell shallow="14.1" deep="8.1" cap="speed" /> | <ScoreCell value="0.976/0.933†" sub="99% completion" top /> | <ScoreCell value="66" note="88%" pill="mendel-blind" /> | <span title="EvalPlus 2h27 · Mendel 2h43"><b>5h10</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" /> | 82k | <TokCell shallow="43.7" deep="13.0" cap="speed" /> | <ScoreCell value="0.951/0.915" sub="100% completion" /> | <ScoreCell value="62.5" pill="mendel-guided" /> | <span title="EvalPlus 0h15 · Mendel 1h29"><b>1h44</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" /> | 66k | <TokCell shallow="50.5" deep="33.6" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="50" pill="mendel-blind" /> | <span title="EvalPlus 2h27 · Mendel 0h33"><b>3h00</b></span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" page="/files/gemma26-unsloth-ud-q4kxl" model-page="/models/gemma-4-26b-a4b" /> | **197k** | <TokCell shallow="60.1" deep="19.1" cap="mem" top-shallow /> | <ScoreCell value="0.988/0.957" sub="100% completion" top /> | <ScoreCell value="47.5" pill="mendel-blind" /> | <span title="EvalPlus 1h57 · Mendel 1h21"><b>3h18</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" kv="f16" effort="medium" page="/files/qwen38-atomicchat-ad-iq3s" model-page="/models/qwen3.8-27b" /> | 104k | <TokCell shallow="14.3" deep="9.6" cap="mem" /> | <ScoreCell value="0.988/0.927†" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 3h11 · Mendel 1h00"><b>4h10</b></span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/files/gemma12-unsloth-ud-q4kxl" model-page="/models/gemma-4-12b-it" /> | **245k** | <TokCell shallow="25.0" deep="9.2" cap="mem" /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> | <span title="EvalPlus 0h43 · Mendel 1h38"><b>2h21</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" page="/files/qwen36-mlx-4bit" model-page="/models/qwen3.6-35b-a3b" /> | 37k | <TokCell shallow="54.5" deep="39.1" cap="mem" top-shallow top-deep /> | <ScoreCell value="0.957/0.939" sub="99% completion" /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 5h02 · Mendel 0h19"><b>5h20</b></span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" page="/files/bonsai-mlx-2bit" model-page="/models/bonsai-27b" /> | 40k | <TokCell shallow="24.5" deep="17.3" cap="mem" stale /> | <ScoreCell value="0.933/0.902" sub="99% completion" /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" /> | <span title="EvalPlus 19h24 · Mendel 5h00">24h24</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" page="/files/bonsai-prism-q2g64" model-page="/models/bonsai-27b" /> | 33k | <TokCell shallow="14.7" deep="7.8" cap="speed" /> | <ScoreCell value="0.951/0.915" sub="100% completion" /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" /> | <span title="EvalPlus 9h11 · Mendel 5h00">14h11</span> |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" page="/files/qwen38-mlx-4bit" model-page="/models/qwen3.8-27b" /> | 25k | <TokCell shallow="17.3" deep="14.8" cap="mem" /> | <ScoreCell value="0.976/0.927" sub="100% completion" top /> | <ScoreCell value="12.5†" note="13%" pill="mendel-blind" /> | <span title="EvalPlus 2h09 · Mendel 1h25"><b>3h34</b></span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" page="/files/bonsai-mlx-2bit" model-page="/models/bonsai-27b" /> | 40k | <TokCell shallow="24.5" deep="17.3" cap="mem" stale /> | <ScoreCell value="0.927/0.902" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h46 · Mendel 3h07"><b>3h53</b></span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:setup-complete:end -->

## In-Progress Configurations

<!-- gen:setup-partial:start -->
| Model / Config | Ctx | tok/s | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/files/bonsai2-prism-ptq1" model-page="/models/bonsai-2-27b" top /> | **160k** | <TokCell shallow="17.9" deep="9.1" cap="mem" /> | <ScoreCell value="0.988/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 4h49 · Mendel —">4h49†</span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" page="/files/gemma26-unsloth-ud-q4kxl" model-page="/models/gemma-4-26b-a4b" top /> | 2x82k | <TokCell shallow="66.6" deep="33.6" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="0.988/0.957" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 1h57 · Mendel —">1h57†</span> |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" page="/files/qwen38-mlx-4bit" model-page="/models/qwen3.8-27b" top /> | 25k | <TokCell shallow="17.3" deep="14.8" cap="mem" /> | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 3h32 · Mendel —">3h32†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/files/gemma12-unsloth-ud-q4kxl" model-page="/models/gemma-4-12b-it" top /> | 2x82k | <TokCell shallow="25.0" deep="15.7" cap="mem" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="f16" effort="off" page="/files/gemma12-unsloth-ud-q4kxl" model-page="/models/gemma-4-12b-it" top /> | 4x49k | <TokCell shallow="42.9" deep="27.7" cap="mem" stale top-deep /> | <ScoreCell value="0.976/0.939" sub="100% completion" /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="f16" effort="on" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" top /> | 41k | <TokCell shallow="69.1" deep="52.6" cap="mem" stale top-shallow top-deep /> | <ScoreCell value="0.976/0.939" sub="100% completion" /> | <ScoreCell value="pending" /> | <span title="EvalPlus 2h27 · Mendel —">2h27†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="q8_0" effort="off" page="/files/gemma12-unsloth-ud-q4kxl" model-page="/models/gemma-4-12b-it" top /> | 16k | <TokCell shallow="13.8" deep="6.5" cap="speed" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" page="/files/bonsai-prism-q2g64" model-page="/models/bonsai-27b" top /> | 2x48k | <TokCell shallow="14.9" deep="7.8" cap="speed" stale /> | <ScoreCell value="0.951/0.915" sub="100% completion" /> | <ScoreCell value="pending" /> | <span title="EvalPlus 9h11 · Mendel —">9h11†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" page="/files/bonsai-prism-q2g64" model-page="/models/bonsai-27b" /> | **131k** | <TokCell shallow="15.0" deep="9.7" cap="mem" stale /> | <ScoreCell value="pending" /> | <ScoreCell value="12.5" note="13%" pill="mendel-guided" top /> | <span title="EvalPlus — · Mendel 3h15">3h15†</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:setup-partial:end -->

## Fast-Mode HumanEval+

<!-- gen:setup-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" page="/files/gemma26-unsloth-ud-q4kxl" model-page="/models/gemma-4-26b-a4b" /> | 8192 | 16384 | <ScoreCell value="0.988/0.957" sub="100% completion" top /> | none | 19/164 | <TokCell shallow="60.1" deep="19.1" /> | 1h57 |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" page="/files/bonsai2-prism-ptq1" model-page="/models/bonsai-2-27b" /> | 8192 | 16384 | <ScoreCell value="0.988/0.939" sub="100% completion" top /> | none | 10/164 | <TokCell shallow="17.9" deep="9.1" /> | 4h49 |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" page="/files/qwen38-bartowski-q4km" model-page="/models/qwen3.8-27b" /> | 8192 | 16384 | <ScoreCell value="0.982/0.951" sub="100% completion" top /> | none | 9/164 | <TokCell shallow="12.4" deep="9.7" /> | 5h04 |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" page="/files/gemma26-unsloth-ud-q4kxl" model-page="/models/gemma-4-26b-a4b" /> | none | 8192 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | — | <TokCell shallow="60.1" deep="19.1" /> | 0h20 |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" page="/files/qwen38-unsloth-ud-iq3s" model-page="/models/qwen3.8-27b" /> | 8192 | 16384 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | 17/164 | <TokCell shallow="13.60" deep="7.97" /> | 6h29 |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" page="/files/qwen38-ista-iq3s-mtp" model-page="/models/qwen3.8-27b" /> | 8192 | 16384 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | 13/164 | <TokCell shallow="14.1" deep="8.1" /> | 5h32 |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" page="/files/gemma12-unsloth-ud-q4kxl" model-page="/models/gemma-4-12b-it" /> | none | 8192 | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | none | — | <TokCell shallow="25.0" deep="9.2" /> | 0h43 |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" /> | 8192 | 16384 | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | none | 17/164 | <TokCell shallow="43.7" deep="13.0" /> | 2h27 |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" /> | none | 8192 | <ScoreCell value="0.951/0.915" sub="100% completion" /> | none | — | <TokCell shallow="43.7" deep="13.0" /> | 0h15 |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" page="/files/bonsai-prism-q2g64" model-page="/models/bonsai-27b" /> | 8192 | 16384 | <ScoreCell value="0.951/0.915" sub="100% completion" /> | none | 4/164 | <TokCell shallow="14.7" deep="7.8" /> | 9h11 |
| <ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="off" page="/files/gemma12-lmstudio-mlx-4bit" model-page="/models/gemma-4-12b-it" /> | none | 30000 | <ScoreCell value="0.909/0.872" sub="100% completion" /> | none | — | <TokCell shallow="34.19" deep="23.23" /> | 1h33 |
<!-- gen:setup-evalplus:end -->

## Router Serve Presets

<!-- gen:setup-presets:start -->
### Official `llama-server` presets

```ini
[qwen3.8-27b-iq3s-f16]
hf = unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 188416
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[qwen3.8-27b-q4km]
hf = bartowski/Qwen3.8-27B-GGUF:Q4_K_M
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 73728
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[qwen3.6-35b-a3b-q4kxl-q8-mtp3]
hf = unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL
no-mmproj = true
spec-type = draft-mtp
spec-draft-n-max = 3
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 98304
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[qwen3.8-27b-ista-f16]
hf = ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 163840
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[qwen3.8-27b-ista-f16-mtp3]
hf = ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp
no-mmproj = true
spec-type = draft-mtp
spec-draft-n-max = 3
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 131072
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[qwen3.6-35b-a3b-q4kxl-f16]
hf = unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 65536
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[gemma-4-26b-a4b-q4kxl-mtp2]
hf = unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL
no-mmproj = true
spec-type = draft-mtp
spec-draft-n-max = 2
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 212992
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[qwen3.8-27b-ad-iq3s]
hf = AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 106496
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[gemma-4-12b-q4kxl]
hf = unsloth/gemma-4-12b-it-GGUF:Q4_K_XL
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 262144
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[gemma-4-12b-q4kxl-2slot]
hf = unsloth/gemma-4-12b-it-GGUF:Q4_K_XL
no-mmproj = true
parallel = 2
n-gpu-layers = 999
flash-attn = on
ctx-size = 196608
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```
### PrismML fork (`prism-llama`) presets

```ini
[bonsai-27b-q2g64-q4bias]
n-gpu-layers = 999
flash-attn = on
ctx-size = 65536
parallel = 1
cache-type-k = q4_0
cache-type-v = q4_0
kv-mean-center = ~/.local/share/choose-a-local-llm/Ternary-Bonsai-27B-kv-bias.gguf
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.

[bonsai-27b-q2g64-f16]
n-gpu-layers = 999
flash-attn = on
ctx-size = 131072
parallel = 1
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```
<!-- gen:setup-presets:end -->
