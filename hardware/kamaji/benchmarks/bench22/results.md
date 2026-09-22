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

## `qwen38-bartowski-calibrate-xhigh`

Think budget 30000, answer budget 2048, max tokens 32048. Margin 1.5. 9/10 calibration problems converged, 1 cut.

## `qwen38-bartowski-budget-xhigh`

| old/new | Config | Max ctx | pass@1 base | pass@1 plus | empty | forced | wall |
|---|---|--:|--:|--:|--:|--:|--:|
| old | dense 27B 4-bit, effort xhigh, no budget | 32k | 0.957 | 0.939 | 6/164 | — | 510.3 min |
| new | dense 27B 4-bit, effort xhigh, budget 30000 | 32k | **0.982** | **0.951** | **0/164** | 3/164 | 447.8 min |

The old row is the planning snapshot from `docs/setups/kamaji/models.json` (no thinking budget, no forced re-run). The new row is this run, budget 30000 think / 2048 answer / 32048 total. 3 of 164 problems hit the budget message; none of those 3 came back empty.
Files: `hardware/kamaji/benchmarks/bench22/results/qwen38-bartowski-budget-xhigh/`.

## `qwen38-bartowski-forced-rerun`

1 of the 3 forced problems had failed a test: `HumanEval/99`. Re-run at a generous budget (30000 tokens, no reasoning flags). Score at close: base 0.976, plus 0.951. Wall 27 min 30 s.

| task_id | cell | forced_tokens | natural_finish | natural_tokens | natural_reasoning_tokens |
|---|---|--:|---|--:|--:|
| HumanEval/99 | forced-fail-loop | 30212 | length | 30000 | 30000 |

Summary: forced-pass 2, forced-fail-late 0, forced-fail-loop 1, forced-fail-wrong 0.

`HumanEval/99` hits the 30000-token cap even with no budget: a genuine long-running or looping problem, not a budget artifact. The base score moved from 0.982 to 0.976 because the natural length-capped continuation for this one task differs slightly at the cutoff from the budget-message continuation and lands on the other side of a base test; the plus score, the score this run is judged on, is unchanged.

`corrected_think_budget`: unchanged. No late answer appeared once the budget was removed, so 30000 stands as the think budget for this config.
Files: `hardware/kamaji/benchmarks/bench22/results/qwen38-bartowski-forced-rerun/`.

## `bonsai-fork-fast-think`

Fast mode: `--reasoning-budget 8192`, `EVALPLUS_MAX_NEW_TOKENS=16384`, no calibration, no forced re-run. No splice source; all 164 generated.

| old/new | Config | base | plus | empty | forced | wall |
|---|---|--:|--:|--:|--:|--:|
| old (`bonsai-fork-single`, budget 10240) | Ternary-Bonsai-27B fork, Q2_g64, q4_0 KV + bias, thinking on | 0.927 | 0.890 | 4/164 | — | 594.8 min |
| new (fast, budget 8192) | Ternary-Bonsai-27B fork, Q2_g64, q4_0 KV + bias, thinking on | **0.951** | **0.915** | **0/164** | 4/164 | 551.4 min |

Forced task ids: `HumanEval/47`, `84`, `97`, `129`. None came back empty. Wall 21 Sep 16:12 – 22 Sep 01:23 UTC.
Files: `hardware/kamaji/benchmarks/bench22/results/bonsai-fork-fast-think/`.

## `fast-qwen38-gguf-xhigh`

Fast mode, effort xhigh. Spliced from `bench22/results/qwen38-bartowski-budget-xhigh` (alias `qwen3.8-27b`): kept 153, regenerated 11, matching the table's planning count.

| old/new | Config | base | plus | empty | forced | wall |
|---|---|--:|--:|--:|--:|--:|
| old (budget 30000) | Qwen3.8-27B, GGUF Q4_K_M, f16 KV, xhigh | 0.982 | 0.951 | 0/164 | 3/164 | 447.8 min |
| new (fast, budget 8192, spliced) | Qwen3.8-27B, GGUF Q4_K_M, f16 KV, xhigh | 0.982 | 0.951 | 0/164 | 9/164 | 304.4 min |

Score unchanged from the budget-30000 row. Forced task ids: `HumanEval/2, 32, 39, 76, 99, 116, 129, 132, 137`. `HumanEval/75` and `127` converged inside 8192 on the regenerate pass and are not forced. None came back empty. Wall: 95.7 min of new generation (02:02–03:38 UTC) plus 208.7 min of spliced-source time for the 153 kept problems.
Files: `hardware/kamaji/benchmarks/bench22/results/fast-qwen38-gguf-xhigh/`.

## `fast-gemma26-gguf`

Fast mode, thinking on. Spliced from `bench22/results/gemma26-gguf-budget-think`: kept 145, regenerated 19, matching the table's planning count.

| old/new | Config | base | plus | empty | forced | wall |
|---|---|--:|--:|--:|--:|--:|
| old (budget 19491) | Gemma-4-26B-A4B, GGUF, MTP f16, thinking on | 0.988 | 0.957 | 0/164 | 16/164 | 165.8 min |
| new (fast, budget 8192, spliced) | Gemma-4-26B-A4B, GGUF, MTP f16, thinking on | 0.988 | 0.957 | 0/164 | 19/164 | 117.1 min |

Score unchanged from the budget-19491 row. All 19 regenerated problems hit the budget message; none came back empty. Wall: 38.4 min of new generation (03:56–04:34 UTC) plus 78.6 min of spliced-source time for the 145 kept problems.
Files: `hardware/kamaji/benchmarks/bench22/results/fast-gemma26-gguf/`.

## `fast-bonsai2-ptq1-mac-xhigh`

Fast mode, effort xhigh, fork (Metal build, bench26's). Spliced from `bench26/results/bonsai2-budget-xhigh-mac`: kept 154, regenerated 10, matching the table's planning count.

| old/new | Config | base | plus | empty | forced | wall |
|---|---|--:|--:|--:|--:|--:|
| old (bench26, budget 16056) | Ternary-Bonsai-2-27B, PTQ1_0, f16 KV, xhigh | 0.988 | 0.939 | 0/164 | 7/164 | 482.9 min |
| new (fast, budget 8192, spliced) | Ternary-Bonsai-2-27B, PTQ1_0, f16 KV, xhigh | 0.988 | 0.939 | 0/164 | 10/164 | 289.3 min |

Score unchanged from the bench26 row. All 10 regenerated problems hit the budget message; none came back empty. Wall: 72.1 min of new generation (04:47–05:59 UTC) plus 217.2 min of spliced-source time for the 154 kept problems.
Files: `hardware/kamaji/benchmarks/bench22/results/fast-bonsai2-ptq1-mac-xhigh/`.

## `fast-qwen38-gguf-unsloth-iq3s-xhigh`

Fast mode, effort xhigh. No splice source; all 164 generated.

| old/new | Config | base | plus | empty | forced | wall |
|---|---|--:|--:|--:|--:|--:|
| old (no budget, `docs/setups/kamaji/models.json`) | Qwen3.8-27B, GGUF UD-IQ3_S, f16 KV, xhigh | 0.945 | 0.927 | — | — | — |
| new (fast, budget 8192) | Qwen3.8-27B, GGUF UD-IQ3_S, f16 KV, xhigh | **0.976** | **0.945** | 0/164 | 17/164 | 388.6 min |

Forced task ids: `HumanEval/10, 32, 36, 39, 47, 76, 91, 99, 116, 129, 132, 134, 137, 138, 145, 146, 160`. None came back empty. Wall 22 Sep 06:11–12:39 UTC.
Files: `hardware/kamaji/benchmarks/bench22/results/fast-qwen38-gguf-unsloth-iq3s-xhigh/`.

## `fast-qwen38-gguf-ista-nodrafter-xhigh`

Fast mode, effort xhigh, no drafter. No splice source; all 164 generated.

| old/new | Config | base | plus | empty | forced | wall |
|---|---|--:|--:|--:|--:|--:|
| old (no budget, `docs/setups/kamaji/models.json`) | Qwen3.8-27B, GGUF IQ3_S-mtp (ISTA GSQ-RCO), no drafter, f16 KV, xhigh | 0.945 | 0.921 | — | — | — |
| new (fast, budget 8192) | Qwen3.8-27B, GGUF IQ3_S-mtp (ISTA GSQ-RCO), no drafter, f16 KV, xhigh | **0.976** | **0.945** | 0/164 | 13/164 | 331.7 min |

Forced task ids: `HumanEval/2, 32, 36, 39, 47, 75, 76, 99, 108, 116, 132, 134, 145`. None came back empty. Wall 22 Sep 12:52–18:23 UTC.
Files: `hardware/kamaji/benchmarks/bench22/results/fast-qwen38-gguf-ista-nodrafter-xhigh/`.

## `fast-qwen36-gguf-think`

Fast mode, thinking on. No splice source; all 164 generated. Last row of the fast table; `qwen36-gguf-f16` and `qwen36-gguf-f16-nodrafter` share this score under the shared-score rule, for the coordinator to write.

| old/new | Config | base | plus | empty | forced | wall |
|---|---|--:|--:|--:|--:|--:|
| old (no budget, `docs/setups/kamaji/models.json`) | Qwen3.6-35B-A3B, GGUF MTP q8_0, thinking on | 0.957 | 0.939 | — | — | — |
| new (fast, budget 8192) | Qwen3.6-35B-A3B, GGUF MTP q8_0, thinking on | **0.976** | 0.939 | 0/164 | 17/164 | 147.4 min |

Plus unchanged, base up one problem. Forced task ids: `HumanEval/4, 14, 23, 31, 32, 33, 39, 55, 62, 76, 81, 113, 130, 137, 139, 142, 160`. None came back empty. Wall 22 Sep 18:39–21:07 UTC.
Files: `hardware/kamaji/benchmarks/bench22/results/fast-qwen36-gguf-think/`.
