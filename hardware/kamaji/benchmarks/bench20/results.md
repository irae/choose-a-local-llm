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
