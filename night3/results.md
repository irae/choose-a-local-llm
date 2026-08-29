# Night 3 EvalPlus results

One row per block: budget used, pass@1 base/plus, empty count, regenerated
count, incidents. Timing is a secondary signal per the user; not chased
for precision.

| block | model | budget | pass@1 base | pass@1 plus | empty | regenerated | incidents |
|---|---|---|---|---|---|---|---|
| qwen36-think (correction) | unsloth/Qwen3.6-35B-A3B-MTP-GGUF Q4_K_XL | 26624 | 0.939 | 0.921 | 5/164 | 56 (54 missing + 2 previously-empty) | None. Server and mem-watch stayed healthy through all heartbeat checks. 5 completions stayed genuinely empty at the full 26624 budget, a real model limit (same pattern as bonsai-think in night 2) |
| gemma12-lmstudio, thinking-off | lmstudio-community/gemma-4-12B-it-MLX-4bit | 7500 | 0.909 | 0.872 | 0/164 | fresh (not a correction) | None. LM Studio server on port 8081 (not the runbook's 1234, to match the hardcoded scripts). Server and mem-watch stayed healthy through all heartbeat checks |
| gemma26-mlx, thinking-on | mlx-community/gemma-4-26b-a4b-it-4bit | 30000 | 0.713 | 0.701 | 46/164 (~28%) | fresh (not a correction) | None. Ran across two sessions — paused at 130/164, resumed from the same jsonl (evalplus native resume), finished cleanly. Server and mem-watch stayed healthy throughout. 46 empty completions is a real model limit, not a harness artifact: matches the documented Gemma thinking-convergence problem (calibration already showed 2/10 sample problems never finishing reasoning at this budget) |

Night 2 (uncorrected, partial): 102/164 lines banked, not a valid score.
Night 1 (flawed 3072-token cap): 0.560/0.552.

## Blocked

gemma12-lmstudio thinking-on: LM Studio's REST API exposes no working
thinking toggle for this model, and mlx_lm.server cannot load it
(`gemma4_unified` unsupported). Needs the owner's decision. See
HANDOFF.md.

## Not yet run

bonsai-prism, bonsai-off. Blocks run one at a time.
