# Run 28 — state

One section per block, in the order the runbook lists, as it happens.

## `machine-setup`

- 2026-09-19: `vram_start_mb` 837 (desktop only). `MemAvailable` 19172104 kB. `df -h ~`: 13 GB free of 231 GB (95%). `gh auth status` passes. No `llama-server` running.
- Stock binary: run 19's CUDA `llama-server`, `CUDA0` found, `--reasoning-budget` and `--reasoning-budget-message` listed.
- Fork binary (`prism-b10685-7dffb15`): flags listed. It needs `LD_LIBRARY_PATH` with its own directory and run 17's `lib` directory (`libcudart.so.12`).
- `EVALPLUS_PYTHON` = `/home/irae/.local/share/pipx/venvs/evalplus/bin/python`.
- No download needed for the first block. Disk is low: 13 GB free.
