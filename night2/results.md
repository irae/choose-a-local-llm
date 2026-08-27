# Night 2 EvalPlus results

One row per block: budget used, pass@1 base/plus, empty count (must be 0
for a corrected/fresh block), regenerated count, incidents. Timing is a
secondary signal per the user; not chased for precision.

| block | model | budget | pass@1 base | pass@1 plus | empty | regenerated | incidents |
|---|---|---|---|---|---|---|---|
| qwen38-mlx-medium | mlx-community/Qwen3.8-27B-4bit | 8192 | 0.982 | 0.939 | 0/164 | 3 (HumanEval/39, 132, 145) | mlx_lm.server crashed one request with a Metal resource-limit error mid-run (`[metal::malloc] Resource limit (499000) exceeded`); server stayed "healthy" but that request hung forever under EvalPlus's infinite-retry loop. Fixed by restarting the server and resuming; see state.md |
| bonsai-think | prism-ml/Ternary-Bonsai-27B-mlx-2bit | 10240 | 0.915 | 0.884 | 5/164 | 55 (all previously-empty entries) | Found and fixed a critical bug in `run_codegen_wrapper.py` shared by every block: EvalPlus's own request code hardcodes a 100s `signal.alarm` plus a ~600s client default timeout, so any completion needing longer than that retried forever at temperature 0 and never finished. Fixed for good (plain retry loop, 7200s client timeout). Also found 5 completions still genuinely empty even at 10240 tokens — a real model limit, not a bug. 5/164 empty is a true model ceiling, not a harness artifact |

Night 1 comparison (flawed `max_tokens=3072`): qwen38-mlx-medium 0.970/0.939,
bonsai-think 0.640/0.634.

## Not yet corrected

qwen36-think: 5 of 62 empty completions regenerated (paused mid-run,
resumable). gemma26-think, gemma12-think: calibrated only (budget 30000
each), no problems run yet. Per user instruction, none of these three
restart without explicit go-ahead.
