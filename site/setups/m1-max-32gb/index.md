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
- **Ternary packing flips on Metal:** [Ternary-Bonsai-2-27B](/models/bonsai-2-27b) `PTQ1_0` (`160k`, `17.9 → 9.1 tok/s`, **0.988 / 0.939** EvalPlus) beats `PQ2_0` (`41k` floor) at every depth — opposite of CUDA.
- **MLX trade-off:** `mlx_lm.server` lacks slots, ignores `--reasoning-budget`, and OOMs abruptly in the generation thread (always pass `--prompt-cache-size 2` and keep a 5% harness margin).

## Complete Configurations

<!-- gen:setup-complete:start -->
<!-- gen:setup-complete:end -->

## In-Progress Configurations

<!-- gen:setup-partial:start -->
<!-- gen:setup-partial:end -->

## Fast-Mode HumanEval+

<!-- gen:setup-evalplus:start -->
<!-- gen:setup-evalplus:end -->

## Router Serve Presets

<!-- gen:setup-presets:start -->
<!-- gen:setup-presets:end -->
