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
