# Ternary-Bonsai-27B

First-generation 27B ternary model (8 GB weights), now superseded for coding-agent work by [Ternary-Bonsai-2-27B](/models/bonsai-2-27b).

## Verdict

- **Superseded by Bonsai-2:** While its tiny footprint enabled `131k` context (`f16` KV) and `2×48k` multi-slot serving on M1 Max 32 GB, first-generation Bonsai struggled badly on multi-turn agent coding: the PrismML fork `f16` KV row ended partial at **12.5/100 guided** (1/8 libraries, 376 tool calls, 74 tool errors), and MLX 2-bit runs hit loops or stalled on memory ceilings near `47k`.
- **Single-turn quality:** Fast-mode EvalPlus on the PrismML fork (`Q2_g64`, `q4_0+bias` KV) scores **0.951 / 0.915** (`4/164` forced, `0` empty) — trailing Bonsai-2's `0.976–0.988 / 0.939–0.945`. MLX 2-bit scored `0.933 / 0.902` pre-fast-mode (thinking on) and `0.927 / 0.902` (thinking off).
- **Serve gotchas:** On `mlx_lm.server`, always pass `--prompt-cache-size 2` (the default cache leaks memory and causes early Metal OOMs near `47k`, leaving a `40k` harness window). On the PrismML fork, `q4_0+bias` KV requires a generated KV bias file and speed-floors at `33k` (`14.7 → 7.8 tok/s`); switching to `f16` KV removes the floor (`131k` at `15.0 → 9.7 tok/s`).

## Configurations

<!-- gen:model-configs:start -->
<!-- gen:model-configs:end -->

## Compared with Ternary-Bonsai-2-27B

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
