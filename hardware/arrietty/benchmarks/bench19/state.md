# Run 19 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| vram_start_mb | 921 | `nvidia-smi`, session start |
| vram_total_mb | 16311 | `nvidia-smi` |
| disk_free_home | 5.3G | `df -h ~`, session start |
| evalplus_python | `/home/irae/.local/share/pipx/venvs/evalplus/bin/python` (Python 3.14.7) | pipx venv, EvalPlus 0.3.1 |

## `machine-setup`

- Installed EvalPlus 0.3.1 with pipx. `evalplus.codegen --help` runs
  clean.
- The dataset downloader (`evalplus.codegen`'s own fetch) never
  triggered in time to test; fetched
  `HumanEvalPlus-v0.1.10.jsonl` (164 rows) straight from
  `evalplus/humanevalplus_release` on GitHub instead, into
  `~/.cache/evalplus/`, per the runbook's fallback.
- `llama-server --version` prints no "cuda" string on this build (same
  as run 17); `llama-server --list-devices` confirms `CUDA0: NVIDIA
  GeForce RTX 5060 Ti`. Treat `--list-devices`, not `--version`, as
  the CUDA check on this build.
- Tool check: served `gemma-4-12b-nvfp4` (FreedomAISVR NVFP4 build,
  `-c 32768`, f16 KV, thinking off), ran `calibrate.py` into
  `results/calibration-toolcheck.json`. Ten rows, `resolved_reasoning_effort`
  null on every row, consistent with the thinking-off request. Pass.
  Server stopped, vram back to 1036 MiB (near the 921 MiB start).

Deviation: none that blocks the run.

## Handing over

`machine-setup` done. On to `qwen38-ista-evalplus-xhigh`.
