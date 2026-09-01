# Run 6 EvalPlus results

One row per block: budget used, pass@1 base/plus, empty count, incidents.
Earlier blocks: `benchmarks/bench4/results.md`, `benchmarks/bench3/results.md`.

| block | model | budget | pass@1 base | pass@1 plus | empty | incidents |
|---|---|---|---|---|---|---|
| 1 | gemma12-lmstudio-thinking-on (resumed from 98/164) | 12000 | 0.622 | 0.610 | 61/164 | 2 tasks (161, 164) hit long reasoning passes (44 min, 45 min); confirmed active, not stalls |
| 2 | qwen38-mlx-low | 8192 | 0.976 | 0.927 | 0/164 | none; `--reasoning-effort` CLI flag doesn't exist in mlx-lm 0.31.3, used `--chat-template-args` instead |
| 3 | bonsai-off | | | | | |

## Block 4: Qwen3.6-35B-A3B MTP drafter re-check (not EvalPlus, no table row)

(pending)
