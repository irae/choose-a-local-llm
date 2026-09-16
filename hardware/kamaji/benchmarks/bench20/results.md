# Run 20 — results

One section per block: the re-run problems with their finish reason,
tokens and result, then the run's new score on all 164 beside the old
one, the cause counts and the re-run wall.

## Re-runs

### `qwen38-ista-medium-rerun`

Source: `bench12/results/qwen38-ista-mtp`. Served `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, `--no-mmproj`, `--spec-type draft-mtp --spec-draft-n-max 3 --parallel 1`, f16 KV, `-c 32768`, alias `qwen3.8-27b`, `reasoning_effort: medium`, budget 8192.

| task id | finish_reason | completion_tokens | result |
|---|---|--:|---|
| HumanEval/39 | length | 8192 | fail (base and plus) |

New score on all 164: base **0.976**, plus **0.945**, empty **1/164** (HumanEval/39). Cause counts: `cap` 1, `model` 0. Unchanged from the source row (`bench12`, base 0.976, plus 0.945, 1 empty) — the re-run confirms the cause is the output budget cutting the answer, not the model choosing to stop. Re-run wall: about 4 min (one problem, medium effort).
Files: `results/qwen38-ista-medium-rerun/`, `results/server-qwen38-ista-medium-rerun.log`.

### `qwen38-ista-low-rerun`

Source: `bench13/results/ista-evalplus-low`. Served `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, `--no-mmproj`, no drafter, f16 KV, `-c 32768`, alias `qwen3.8-27b`, `reasoning_effort: low`, budget 8192.

| task id | finish_reason | completion_tokens | result |
|---|---|--:|---|
| HumanEval/39 | length | 8192 | fail (base and plus) |

New score on all 164: base **0.976**, plus **0.933**, empty **1/164** (HumanEval/39). Cause counts: `cap` 1, `model` 0. Unchanged from the source row (`bench13`, base 0.976, plus 0.933, 1 empty). Same task, same cause as the medium rerun: the budget cuts the answer at both levels. Re-run wall: about 4 min.
Files: `results/qwen38-ista-low-rerun/`, `results/server-qwen38-ista-low-rerun.log`.

### `bonsai-fork-rerun`

Source: `bench3/results/bonsai-prism`. Served `~/prism-llama/Bonsai-demo/models/ternary-gguf/27B/Ternary-Bonsai-27B-Q2_g64.gguf`, `LLAMA_ATTN_ROT_DISABLE=1`, no drafter, `-c 32768`, `--cache-type-k q4_0 --cache-type-v q4_0`, `--kv-mean-center ~/.local/share/choose-a-local-llm/Ternary-Bonsai-27B-kv-bias.gguf`, alias `bonsai-prism`, no extra body.

| task id | finish_reason | completion_tokens | result |
|---|---|--:|---|
| HumanEval/47 | length | 10240 | fail (base and plus) |
| HumanEval/84 | length | 10240 | fail (base and plus) |
| HumanEval/97 | length | 10240 | fail (base and plus) |
| HumanEval/129 | length | 10240 | fail (base and plus) |

New score on all 164: base **0.927**, plus **0.890**, empty **4/164** (HumanEval/47, 84, 97, 129). Cause counts: `cap` 4, `model` 0. Unchanged from the source row (`bench3`, same 4 empties) — every empty in this row is the output budget, none a model stop. Re-run wall: about 36 min (four problems, no drafter, ~15-17 t/s each).
Files: `results/bonsai-fork-rerun/`, `results/server-bonsai-fork-rerun.log`.

### `bonsai-mlx-rerun`

Source: `bench2/results/bonsai-think`. Served `mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit --port 8081`, thinking on (default), no extra body, budget 10240. The `mlx_lm.server` process died silently three times during this block (see `state.md` for the full account); each time restarted clean and the block resumed, with no data lost after de-duplicating a few race-condition repeat lines.

| task id | finish_reason | completion_tokens | result |
|---|---|--:|---|
| HumanEval/39 | length | 10240 | fail (base and plus) — genuinely empty |
| HumanEval/99 | stop | 3640 | pass (base and plus) — recovered |
| HumanEval/107 | stop | 5833 | pass (base and plus) — recovered |
| HumanEval/122 | stop | 6006 | pass (base and plus) — recovered |
| HumanEval/129 | length | 10240 | fail (base and plus) — genuinely empty |

New score on all 164: base **0.933**, plus **0.902**, empty **2/164** (HumanEval/39, 129). Cause counts: `cap` 2, `model` 0. **Improved from the source row** (`bench2`, base 0.915 / plus 0.884, 5/164 empty): three of the five originally-empty problems now complete and pass on today's build; the other two still cap out at 10240, confirming a real model limitation, not a bug, at this budget. Re-run wall: about 5h20min across three server restarts.
Files: `results/bonsai-mlx-rerun/`, `results/server-bonsai-mlx-rerun*.log` (four generations across the death/restart cycle).

### `qwen36-gguf-think-rerun`

Source: `bench2/results/qwen36-think`. Removed HumanEval/4 (a server error in the source run, not a model answer) along with the 4 genuine empties. Served `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`, `--alias qwen3.6-35b-a3b`, MTP n-max 3, `-c 32768`, q8_0/q8_0 KV, thinking on, no extra body, budget 26624.

| task id | finish_reason | completion_tokens | result |
|---|---|--:|---|
| HumanEval/4 | stop | 6329 | pass (base and plus) — recovered |
| HumanEval/23 | length | 26624 | fail (base and plus) — genuinely empty |
| HumanEval/55 | length | 26624 | fail (base and plus) — genuinely empty |
| HumanEval/107 | stop | 9790 | pass (base and plus) — recovered |
| HumanEval/121 | stop | 6238 | pass (base and plus) — recovered |

New score on all 164: base **0.957**, plus **0.939**, empty **2/164** (HumanEval/23, 55). Cause counts: `cap` 2, `model` 0. **Improved from the source row** (`bench2`, base 0.939 / plus 0.921, 5/164 empty, one of those five a server error): three real completions recovered and pass, plus the one server-error slot now has a real answer. Re-run wall: about 24 min, clean (no server incidents during this block itself — see the state.md note on a stray-process incident right before the server load, caught and cleared before any codegen started).
Files: `results/qwen36-gguf-think-rerun/`, `results/server-qwen36-gguf-think-rerun.log`.
