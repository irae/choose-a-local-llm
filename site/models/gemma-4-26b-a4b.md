# Gemma-4-26B-A4B

Sparse Mixture-of-Experts (26B total / 4B active) offering the widest complete agent context window on M1 Max 32 GB, with strong single-turn quality but mid-tier agent reliability.

## Verdict

- **M1 Max 32 GB (`UD-Q4_K_XL`, `f16` KV, `mtp/2`, thinking on):** Longest usable agent window on M1 Max at `197k` (`-c 212992`), decoding `60.1 → 19.1 tok/s` with **0.988 / 0.957** fast-mode EvalPlus (`19/164` forced). Agent runs complete cleanly at **47.5/100 blind** (8/8) and **57/100 guided** (7/8; confirmed at **56/100** under an 8192 thinking budget). Also supports 2 parallel slots (`2×82k` clean at `66.6 → 33.6 tok/s`).
- **RTX 5060 Ti 16 GB (`NVFP4Q8`, `--n-cpu-moe 7`, `f16` KV, thinking on):** Partial CPU-MoE offload of 7 expert layers holds `58.8 → 45.6 tok/s` across `97k` context and scores **0.988 / 0.951** fast-mode EvalPlus (`19/164` forced). Guided Mendel scored **37.5/100** (3/8 libraries, stopped on a text loop).
- **Serve gotchas:** Always use `f16` KV on M1 Max — `q8_0` KV collapses speed at depth (`6.3 tok/s` vs `45.9` at 32K). MTP `n=2` is the fastest GGUF drafter arm on M1 Max. The MLX 4-bit build is retired on M1 Max after failing the agent smoke on a truncated tool call ([M1 Max archive](/setups/m1-max-32gb/archive#gemma-4-26b-a4b-mlx)).

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
