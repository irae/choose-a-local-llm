# Run 23 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| `budget_message` | `Thinking budget reached. Give the final answer now.` | runbook, Essentials |
| `THINKING_BUDGET_MARGIN` | 1.5 | runbook, planning value |
| `oblit_q3km_c_q8` | pending | `qwen38-oblit-q3km-kvpick` |
| `oblit_q3km_c_f16` | pending | `qwen38-oblit-q3km-kvpick` |
| `oblit_q3km_c` | pending | `qwen38-oblit-q3km-kvpick`, the larger of the two |
| `oblit_q3km_kv` | pending | `qwen38-oblit-q3km-kvpick` |
| `oblit_q3km_clean` | pending | `sweep-qwen38-oblit-q3km` |
| `oblit_q3km_window` | pending | `qwen38-oblit-q3km-smoke-medium` |
| `oblit_q3km_think_budget` | pending | `qwen38-oblit-q3km-calibrate-think` |
| `oblit_q3km_answer_budget` | pending | `qwen38-oblit-q3km-calibrate-think` |
| `oblit_q3km_max_tokens` | pending | `qwen38-oblit-q3km-calibrate-think` |
| `vram_start_mb` | 614 MiB used / 16311 MiB total | `nvidia-smi`, session start, 2026-09-17 |
| `evalplus_python` | `/home/irae/.local/share/pipx/venvs/evalplus/bin/python` | pipx venv, already installed |
| `llama_server` | `0.4.0-dev (build 10809, commit 5266f24da)`, `v0.4.0-sm120` build | run 17 build, this machine |
| `file_sha256` | `2d088b821df3660904dd0006afd126ed9828a5d4fbd4beac43f6bde9a1b33f23` | downloaded file, matches HF blob name |
| `file_size_bytes` | 13500728352 | matches the runbook's stated size |
| `hf_cache_line` | `model/OBLITERATUS/Qwen3.8-27B-OBLITERATED 13.5G ...` | `hf cache ls` |

Planning estimate, not a result: about 34 MiB of KV per 1024 tokens at
q8_0, computed from the model config (16 full-attention layers of 64, 4
KV heads, head dimension 256). The ladder replaces it.

## `machine-setup` — done

- `benchmarks/thinking-budget.py`, `benchmarks/calibrate.py`,
  `benchmarks/run_codegen_wrapper.py` all present. Last touching commit
  `8b49c41`. `calibrate.py` writes `reasoning_len` (line 163). No merge
  needed.
- CUDA exports verified, `llama-server --list-devices` shows `CUDA0`.
  `--reasoning-budget` and `--reasoning-budget-message` both print in
  `--help`.
- `EVALPLUS_PYTHON` set and working, `evalplus.codegen --help` prints.
- Read-only machine checks by hand (Linux, no `preflight.sh`):
  `nvidia-smi` 614/16311 MiB used, no `llama-server` or `mlx_lm`
  process running, `free -m` shows 1.3 GB free / 18.7 GB swap used at
  session start (high swap pre-existing, not this run's doing), `df -h
  ~` 22G available, `gh auth status` passes.
- Deviation: a stale `python3 -m http.server 8089` process from an
  older, deleted `run17` worktree held port 8089 and served 404s (cwd
  pointed at a deleted directory). Killed it (not a model server, not
  on the GPU) and started the corpus server fresh from this worktree's
  `hardware/kamaji/research/run4/results`. Corpus file verified,
  sha256 `f4cbe063ef231d753e736b60107b6601705a1acb448b05d9f8b8afbdfcec583c`.
  Server will run for the whole session and stop after
  `sweep-qwen38-oblit-q3km`.
- Result dirs created: `hardware/arrietty/benchmarks/bench23/results`,
  `~/.local/share/choose-a-local-llm`, `~/.local/share/mendel-benchmark`.

## Handing-over

`machine-setup` done. Next: `qwen38-oblit-q3km-kvpick`.
