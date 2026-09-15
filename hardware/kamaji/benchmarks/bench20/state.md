# Run 20 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| llama-server version | 0.4.0 (build 10809, commit 5266f24da) | `machine-setup`, `llama-server --version` |
| mlx-lm version | 0.31.3_2 (homebrew) | `machine-setup`, `/opt/homebrew/Cellar/mlx-lm` |
| prism-llama llama-server version | 0.2.0-dev (build 10660, commit e311ed38f) | `machine-setup`, `~/prism-llama/llama-server --version` |
| preflight starting memory | wired 1897 MB, free 19580 MB, swap used 381 MB | `machine-setup`, `tools/preflight.sh` |

### `machine-setup`

`git log` for `benchmarks/run_codegen_wrapper.py` and `benchmarks/run-humaneval.sh` shows `b72fb56`, which carries the finish-log change (`EVALPLUS_FINISH_LOG` exported in `run-humaneval.sh`, line 18). `evalplus.codegen --help` runs. Preflight: all lines `ok`, wired limit 25000, no llama-server or mlx_lm running.
Deviation: none.

### `qwen38-ista-medium-rerun`

Served `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, `--no-mmproj`, `--spec-type draft-mtp --spec-draft-n-max 3 --parallel 1`, f16 KV, `-c 32768` (bench20 fixed value), alias `qwen3.8-27b`. Probe: a full chat completion, finish_reason `stop`, verified before the watcher started. Watcher and codegen both closed clean; `finish.jsonl` (one level above `humaneval/`, not inside it — the log writes beside the `humaneval/` folder) shows HumanEval/39 at `finish_reason: length`, `completion_tokens: 8192`, `empty: true`. Cause is `cap`.
Full re-scored result: base 0.976, plus 0.945, 1/164 empty, unchanged from the source row. Server and watcher stopped (pids 89982, 90738).
Files: `results/qwen38-ista-medium-rerun/`, `results/server-qwen38-ista-medium-rerun.log`, `results/run-watch-qwen38-ista-medium-rerun.log`.
Deviation: none.

## Handing over

`machine-setup` and `qwen38-ista-medium-rerun` done. Begin with `qwen38-ista-low-rerun`.
