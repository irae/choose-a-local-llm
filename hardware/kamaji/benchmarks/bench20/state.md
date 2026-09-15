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

## Handing over

Not started past `machine-setup`. Begin with `qwen38-ista-medium-rerun`.
