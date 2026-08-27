# Night 2 EvalPlus results

One row per block: budget used, pass@1 base/plus, empty count (must be 0
for a corrected/fresh block), regenerated count, incidents. Timing is a
secondary signal per the user; not chased for precision.

| block | model | budget | pass@1 base | pass@1 plus | empty | regenerated | incidents |
|---|---|---|---|---|---|---|---|
| qwen38-mlx-medium | mlx-community/Qwen3.8-27B-4bit | 8192 | 0.982 | 0.939 | 0/164 | 3 (HumanEval/39, 132, 145) | mlx_lm.server crashed one request with a Metal resource-limit error mid-run (`[metal::malloc] Resource limit (499000) exceeded`); server stayed "healthy" but that request hung forever under EvalPlus's infinite-retry loop. Fixed by restarting the server and resuming; see state.md |

Night 1 comparison (flawed `max_tokens=3072`): qwen38-mlx-medium 0.970/0.939.
