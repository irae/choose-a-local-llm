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

## `qwen38-ista-evalplus-xhigh` — running

`ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, MTP draft n-max 2, one
slot, q8_0 KV, ctx 32768 served, wired (vram) 14583 MiB. Served with
`--spec-type draft-mtp --spec-draft-n-max 2`.

Calibration `qwen38-ista-xhigh`, xhigh reasoning: 10/10 rows, 2 `length`
stops (`HumanEval/32`, `HumanEval/99`, both hit the 30000 cap, empty).
Non-converging pattern (`docs/methodology/evalplus.md`, calibration step
3): budget is not the observed-max × 1.5 formula. Longest SUCCESSFUL
completion is `HumanEval/145` at 20324 tokens. `qwen38-ista_budget` =
20500 (just above 20324), source: calibration-qwen38-ista-xhigh.json,
non-converging rule. Expect a real empty rate near 20% (2/10 in
calibration) and do not chase it with a bigger budget.

Deviation: none — non-converging calibration handled per the runbook's
own rule, not a stop-and-ask condition.

## Handing over

`machine-setup` done. `qwen38-ista-evalplus-xhigh` calibrated, budget
set. Starting the watcher and the full EvalPlus run next.
