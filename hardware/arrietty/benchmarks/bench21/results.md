# Run 21 — results

One section per block: the calibrate blocks with their derived
budgets, the budget blocks with score, empties, forced count and wall
beside the natural run, and the forced re-run blocks with the report
table, the summary line and the corrected budget.

## gemma12-nvfp4-calibrate-think

Gemma-4-12B NVFP4, thinking on, f16 KV, no thinking budget. 4 of 10 converged, 6 cut at 30000. Longest converged reasoning 4900 tokens, longest converged answer 528. With margin 1.5 and floor 2048: think budget 7350, answer budget 2048, `max_tokens` 9398.

## gemma12-nvfp4-budget-on

Gemma-4-12B NVFP4, thinking on, f16 KV, ctx 32k, think budget 7350, answer budget 2048, `max_tokens` 9398, no drafter.

| old/new | # | Config | budget | EvalPlus | empty | forced | wall |
|---|--:|---|--:|--:|--:|--:|--:|
| old | — | Gemma-4-12B, GGUF, NVFP4, f16 KV, no drafter, thinking on (natural, run 19) | 8192 | 0.659/0.640/68% | 53/164 | — | 203.9 min |
| new | — | Gemma-4-12B, GGUF, NVFP4, f16 KV, no drafter, thinking on, think budget 7350 | 9398 (7350 + 2048) | **0.976/0.951/100%** | **0/164** | 45/164 | **194.8 min** |

Wall parts: 10.0 min (21:40 to 21:50 UTC, harness killed the run task) + 184.8 min (21:52 to 00:56:50 UTC, evaluate included) = 194.8 min. Empty count from the samples, forced count from `finish.jsonl` with the budget message. The budget fired on 45 problems; 39 of those passed, 6 failed and go to the forced re-run.
