# Run 22 — results

One section per block: the calibrate blocks with their derived
budgets, the budget blocks with score, empties, forced count and wall
beside the natural run, the forced re-run blocks with the report
table, the summary line and the corrected budget, and the guided
agent row beside its natural pair.

## `gemma26-gguf-calibrate-think`

Think budget 19491, answer budget 2048, max tokens 21539. Margin 1.5. 8/10 calibration problems converged, 2 cut.

## `gemma26-gguf-budget-think`

| old/new | Config | Max ctx | pass@1 base | pass@1 plus | empty | forced | wall |
|---|---|--:|--:|--:|--:|--:|--:|
| old | MoE 26B GGUF, thinking on, no budget | 32k | 0.896 | 0.872 | 16/164 | — | 347.0 min |
| new | MoE 26B GGUF, thinking on, budget 19491 | 32k | **0.988** | **0.957** | **0/164** | 16/164 | 165.8 min |

The old row is the planning snapshot from `docs/setups/kamaji/models.json` (no thinking budget, no forced re-run). The new row is this run, budget 19491 think / 2048 answer / 21539 total. 16 of 164 problems hit the budget message; none of those 16 came back empty, so the forced re-run block runs only on the problems that hit the budget and still failed a test.
Files: `hardware/kamaji/benchmarks/bench22/results/gemma26-gguf-budget-think/`.
