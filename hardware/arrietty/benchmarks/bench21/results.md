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

## gemma12-nvfp4-forced-rerun

Gemma-4-12B NVFP4, thinking on, f16 KV, no reasoning flags, `max_tokens` 30000, the 6 forced-failed problems of the budget block.

| task_id | cell | forced_tokens | natural_finish | natural_tokens | natural_reasoning_tokens |
|---|---|---|---|---|---|
| HumanEval/1 | forced-pass | 7824 |  |  |  |
| HumanEval/4 | forced-pass | 7827 |  |  |  |
| HumanEval/18 | forced-pass | 7688 |  |  |  |
| HumanEval/32 | forced-fail-loop | 8044 | length | 30000 | 30000 |
| HumanEval/39 | forced-fail-loop | 7733 | length | 30000 | 30000 |
| HumanEval/41 | forced-pass | 7801 |  |  |  |
| HumanEval/47 | forced-pass | 7631 |  |  |  |
| HumanEval/64 | forced-pass | 7957 |  |  |  |
| HumanEval/65 | forced-pass | 7791 |  |  |  |
| HumanEval/75 | forced-pass | 7992 |  |  |  |
| HumanEval/76 | forced-pass | 8096 |  |  |  |
| HumanEval/81 | forced-pass | 7816 |  |  |  |
| HumanEval/83 | forced-pass | 8214 |  |  |  |
| HumanEval/84 | forced-pass | 7844 |  |  |  |
| HumanEval/91 | forced-fail-loop | 7769 | length | 30000 | 30000 |
| HumanEval/93 | forced-pass | 7779 |  |  |  |
| HumanEval/94 | forced-pass | 7976 |  |  |  |
| HumanEval/95 | forced-pass | 7742 |  |  |  |
| HumanEval/99 | forced-pass | 7946 |  |  |  |
| HumanEval/100 | forced-pass | 7938 |  |  |  |
| HumanEval/102 | forced-pass | 7868 |  |  |  |
| HumanEval/103 | forced-pass | 7901 |  |  |  |
| HumanEval/105 | forced-pass | 8122 |  |  |  |
| HumanEval/109 | forced-pass | 8283 |  |  |  |
| HumanEval/110 | forced-pass | 7890 |  |  |  |
| HumanEval/113 | forced-pass | 7881 |  |  |  |
| HumanEval/115 | forced-pass | 8106 |  |  |  |
| HumanEval/116 | forced-pass | 7975 |  |  |  |
| HumanEval/118 | forced-pass | 7796 |  |  |  |
| HumanEval/119 | forced-pass | 7982 |  |  |  |
| HumanEval/124 | forced-pass | 8388 |  |  |  |
| HumanEval/125 | forced-pass | 7923 |  |  |  |
| HumanEval/129 | forced-pass | 8318 |  |  |  |
| HumanEval/130 | forced-pass | 8121 |  |  |  |
| HumanEval/132 | forced-fail-loop | 7969 | length | 30000 | 30000 |
| HumanEval/134 | forced-fail-loop | 7839 | length | 30000 | 30000 |
| HumanEval/140 | forced-pass | 7802 |  |  |  |
| HumanEval/141 | forced-pass | 8001 |  |  |  |
| HumanEval/145 | forced-fail-loop | 9398 | length | 30000 | 30000 |
| HumanEval/147 | forced-pass | 8445 |  |  |  |
| HumanEval/154 | forced-pass | 7750 |  |  |  |
| HumanEval/156 | forced-pass | 7806 |  |  |  |
| HumanEval/158 | forced-pass | 7853 |  |  |  |
| HumanEval/160 | forced-pass | 8059 |  |  |  |
| HumanEval/163 | forced-pass | 7770 |  |  |  |

`summary	forced-pass=39	forced-fail-late=0	forced-fail-loop=6	forced-fail-wrong=0`  
`corrected_think_budget	unchanged	no late answer`  

Summary: forced-pass 39, forced-fail-late 0, forced-fail-loop 6, forced-fail-wrong 0. Corrected think budget: unchanged, no late answer. Every forced failure is a loop at 30000 without the flag, so 7350 loses no answer that more thinking would have found. Re-run wall 62.3 min (one part, 01:09 to 02:11:17 UTC, evaluate included).

## qwen38-ista-calibrate-think

Qwen3.8-27B ISTA GSQ-RCO IQ3_S, effort xhigh, q8_0 KV, no drafter, no thinking budget. 8 of 10 converged, 2 cut at 30000. Longest converged reasoning 22947 tokens, longest converged answer 1045. With margin 1.5, floor 2048 and the 30000 cap: think budget 30000, answer budget 2048, `max_tokens` 32048.
