# Models

Every active configuration measured across all machines, ranked by combined HumanEval+ and Mendel agent score. Click a model name for its cross-machine report or a quant name for exact serve presets and file hashes.

- **Ctx:** Largest verified usable context window (before OOM, swap growth, or the 8 tok/s speed floor).
- **tok/s:** Shallow (4K) → deep decode speed, tagged by whether `mem` or `speed` gated the window.
- **HumanEval+:** `base/plus` pass@1 and completion rate (fast mode: `8192` think / `16384` output).
- **Coding:** Best valid Mendel agent score (`mendel-blind` or `mendel-guided`, out of 100).
- **Wall:** Combined EvalPlus + Mendel active GPU time (`†` indicates one part is not yet run).
- **Bold:** Top tier within each column.

## Complete Configurations

<!-- gen:models-complete:start -->
<!-- gen:models-complete:end -->

## In-Progress Configurations

<!-- gen:models-incomplete:start -->
<!-- gen:models-incomplete:end -->
