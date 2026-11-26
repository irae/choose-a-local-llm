# Qwen3.6-35B-A3B

Sparse Mixture-of-Experts (35B total / 3B active) with an embedded MTP speculative head — the strongest fast MoE coding agent tested.

## Verdict

- **M1 Max 32 GB (`UD-Q4_K_XL`, `q8_0` KV, `mtp/3`, thinking on):** Best fast MoE agent on Apple Silicon at **83/100 guided** and **63/100 blind** (both 8/8 libraries), **0.976 / 0.939** fast-mode EvalPlus (`17/164` forced), `82k` window at `43.7 → 13.0 tok/s`. Trading down to `f16` KV gives `50.5 → 33.6 tok/s` without drafter (`66k` window, `50/100` blind) or `69.1 → 52.6 tok/s` with `mtp/3` (`41k` window).
- **RTX 5060 Ti 16 GB (`UD-Q4_K_XL`, `--n-cpu-moe 21`, `mtp/2`, `q8_0` KV, thinking on):** Proves partial CPU-MoE expert offload works cleanly on 16 GB VRAM — holding `61.2 → 45.4 tok/s` across `97k` context with **0.976 / 0.933** fast-mode EvalPlus (`12/164` forced). Guided Mendel scored **48.5/100** (6/8 libraries, ended on a loop at library 7).
- **Serve gotchas:** On `llama-server` b10964 (M1 Max), combining MTP `n=3` with `--reasoning-budget` triggered a server crash; a no-drafter diagnostic completed cleanly at **79/100**. On MLX (`37k` window, `54.5 → 39.1 tok/s`), the server ignores thinking budgets and OOMs in the generation thread past `41k`. The community NVFP4 repack failed to load on CUDA (tensor-count defect) and was dropped.

## Configurations

<!-- gen:model-configs:start -->
<!-- gen:model-configs:end -->

## Decode Speed vs Context Depth

<!-- gen:model-curves:start -->
<!-- gen:model-curves:end -->

## HumanEval+

<!-- gen:model-evalplus:start -->
<!-- gen:model-evalplus:end -->

## Mendel Agent Runs

<!-- gen:model-mendel:start -->
<!-- gen:model-mendel:end -->

## Model Files

<!-- gen:model-files:start -->
<!-- gen:model-files:end -->
