# S5-nano

Compact 4B-class reasoning model (`maritaca-ai/S5-nano-GGUF`) measured on RTX 5060 Ti 16 GB under `llama.cpp` v0.9.0 (`b12110`). Fast with huge context, but not viable as a coding agent.

## Verdict

- **Failed the coding-agent gate on both quants:** Both `Q8_0` (`q8_0` KV) and `BF16` (`f16` KV) failed the Mendel tool-calling smoke — deleting the fixture's `.git` directory and committing against the outer repository — so full Mendel runs were skipped.
- **High speed and deep context:** `Q8_0` / `q8_0` KV reaches the full `261k` context cap (`-c 262144`, harness window `258,048`) at **77.37 → 30.59 tok/s** in `10.9 GiB` VRAM. `BF16` / `f16` KV reaches `203,776` clean tokens (`-c 204800`, window `200,704`) at **45.68 → 26.41 tok/s** in `15.5 GiB` VRAM (`37%` slower at 32K than `Q8_0`/`q8_0`).
- **Single-turn coding quality:** Passes the `0.800` base gate with thinking on — **0.811 / 0.726** on `Q8_0` (`26/164` forced) and **0.841 / 0.774** on `BF16` / `f16` KV (`31/164` forced, measured at `-c 65536`). Thinking-off (`Q8_0` Instruct) drops to **0.720 / 0.634** (`0` forced), confirming thinking helps even at 4B scale.

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
