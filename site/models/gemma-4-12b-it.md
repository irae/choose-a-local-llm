# Gemma-4-12B

Dense 12B model that achieves the highest HumanEval+ `plus` score on the entire site while scoring **0/100** across every coding-agent run.

## Verdict

- **Single-turn coding leader, zero agent viability:** On RTX 5060 Ti 16 GB, `UD-Q4_K_XL` (`f16` KV, thinking on) reaches **0.988 / 0.963** fast-mode EvalPlus (`34/164` forced) — the top `plus` score measured — and `NVFP4` (`f16` KV, thinking on) scores **0.976 / 0.951** (`44/164` forced). Both fit the full `261k` trained window on 16 GB VRAM (`47.4 → 32.2` and `49.6 → 33.1 tok/s`), yet every guided Mendel run (thinking on and off) ended **model-failed with zero commits** due to repetition loops (`520×` and `818×` repeated thought lines, or repeated failing tool calls).
- **M1 Max 32 GB (`Q4_K_XL`, `f16` KV, thinking off):** Reaches `245k` at `25.0 → 9.2 tok/s` in `13.9 GB` wired memory (`0.976 / 0.939` EvalPlus) and supports multi-slot serving (`2×82k` clean at `15.7 tok/s`), but likewise failed Mendel with zero commits.
- **Serve gotchas:** Thinking-on without a server thinking budget fails badly on single-turn coding (`0.659` NVFP4, `0.793` Q4_K_XL) because 34–53 problems loop past the output cap; fast mode (`--reasoning-budget 8192`) recovers every empty answer. Avoid `q8_0` KV on Metal (drops below `8 tok/s` by `16k`). LM Studio MLX 4-bit is retired ([M1 Max archive](/setups/m1-max-32gb/archive#lm-studio)).

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
