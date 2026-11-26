# Ternary-Bonsai-2-27B

Second-generation 27B ternary model (5.5–6.7 GiB weights) that unlocks 120k–240k coding-agent windows on 16 GB VRAM and 160k on M1 Max 32 GB — a dramatic jump over first-generation [Ternary-Bonsai-27B](/models/bonsai-27b).

## Verdict

- **RTX 5060 Ti 16 GB (best long-context 27B):** On the PrismML fork (`prism-b10685-7dffb15`, `xhigh`), `PTQ1_0` with `f16` KV leads at **82/100 blind** (`135k` window, `42.1 → 22.4 tok/s`, **0.976 / 0.945** fast-mode EvalPlus, 1 compaction). `PQ2_0` `f16` KV scores **77/100 blind** (`119k`, `46.3 → 25.1 tok/s`, **0.982 / 0.945**). Switching to `q8_0` KV stretches `PTQ1_0` to `240k` (**73.5/100 blind**, peaking at `225,161` tokens with zero compactions, **0.982 / 0.945**) and `PQ2_0` to `208k` (**60.5/100 blind**, **0.988 / 0.945**). Adding the rank-1 refusal-ablation LoRA at scale `1.0` (`PTQ1_0` `f16`) costs ~3% speed, holds **0.976 / 0.945** EvalPlus, and scores **75/100 blind** with zero critical defects (vs trap A on the unablated run).
- **M1 Max 32 GB (`PTQ1_0` beats `PQ2_0` on Metal):** Opposite of CUDA, `PTQ1_0` (`f16` KV) is both faster and 4× deeper than `PQ2_0` on Apple Silicon — `160k` clean at `17.9 → 9.1 tok/s` with **0.988 / 0.939** fast-mode EvalPlus (`10/164` forced; Mendel pending), whereas `PQ2_0` crosses the `8 tok/s` floor by `41k`. The MLX 2-bit pack is fastest at 4K (`21.5 tok/s`) but swap-caps at `28k` (`10.5 tok/s`) and has no stock server (served via custom wrapper `tools/sweeps/bonsai2-mlx-server.py`, no prompt cache).
- **Serve gotchas:** **Requires the PrismML `llama.cpp` fork** (`prism-b10685-7dffb15`); stock `llama-server` rejects `PQ2_0` and `PTQ1_0` because it lacks the Hadamard activation runtime. Across one run per arm on CUDA, `f16` KV outperformed `q8_0` KV on Mendel on both packings (`82 vs 73.5` and `77 vs 60.5`).

## Configurations

<!-- gen:model-configs:start -->
<!-- gen:model-configs:end -->

## Compared with Ternary-Bonsai-27B

<!-- gen:model-compare:start -->
<!-- gen:model-compare:end -->

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
