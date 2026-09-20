# Run 28 — state

One section per block, in the order the runbook lists, as it happens.

## `machine-setup`

- 2026-09-19: `vram_start_mb` 837 (desktop only). `MemAvailable` 19172104 kB. `df -h ~`: 13 GB free of 231 GB (95%). `gh auth status` passes. No `llama-server` running.
- Stock binary: run 19's CUDA `llama-server`, `CUDA0` found, `--reasoning-budget` and `--reasoning-budget-message` listed.
- Fork binary (`prism-b10685-7dffb15`): flags listed. It needs `LD_LIBRARY_PATH` with its own directory and run 17's `lib` directory (`libcudart.so.12`).
- `EVALPLUS_PYTHON` = `/home/irae/.local/share/pipx/venvs/evalplus/bin/python`.
- No download needed for the first block. Disk is low: 13 GB free.

## `fast-qwen38-iq3s-xhigh`

- Serve: row command with `-c 32768` and `$FAST_FLAGS`, run 19's binary. `hf download` on this machine prints `path=` before the path; every serve command uses `hf download --quiet`.
- `nvidia-smi` at load: 13093 MiB used of 16311 (desktop included, `vram_start_mb` 837). After the probe: 13101 MiB.
- Probe (xhigh, palindrome prompt): `finish_reason` stop, 245 completion tokens, `reasoning_content` present, `content` 465 characters, no error in the server log. It converged early, so the budget message did not show. The response has no `resolved_reasoning_effort` field on this binary.
- Part 1 start 2026-09-20T02:48:08Z
- Part 1: 2026-09-20T02:48:08Z to about 05:56Z (finish, evaluate included). No crash, no restart. Wall about 188 min; the request walls in `finish.jsonl` sum to 177.1 min.
- Result: base 0.963, plus 0.921. Empty 0/164, forced 8/164, no answer on `length`.
