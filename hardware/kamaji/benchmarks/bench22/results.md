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

## `gemma26-gguf-forced-rerun`

2 of the 16 forced problems had failed a test: `HumanEval/141`, `HumanEval/145`. Re-run at a generous budget (30000 tokens, no reasoning flags). Score at close: base 0.988, plus 0.957 — unchanged from the budget block, so no problem was fixed by removing the budget. Wall 8 min 20 s.

| task_id | cell | forced_tokens | natural_finish | natural_tokens | natural_reasoning_tokens |
|---|---|--:|---|--:|--:|
| HumanEval/141 | forced-fail-wrong | 20237 | stop | 2572 | 1850 |
| HumanEval/145 | forced-fail-loop | 21067 | length | 30000 | 30000 |

Summary: forced-pass 14, forced-fail-late 0, forced-fail-loop 1, forced-fail-wrong 1.

`HumanEval/141` fails naturally too, at a short natural answer (2572 tokens): the budget did not cause this failure, the model gets it wrong either way. `HumanEval/145` hits the 30000-token cap even with no budget: a genuine long-running or looping problem, not a budget artifact.

`corrected_think_budget`: unchanged. No late answer appeared once the budget was removed, so 19491 stands as the think budget for this config.
Files: `hardware/kamaji/benchmarks/bench22/results/gemma26-gguf-forced-rerun/`.
