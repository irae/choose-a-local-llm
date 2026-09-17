# Run 23 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| `budget_message` | `Thinking budget reached. Give the final answer now.` | runbook, Essentials |
| `THINKING_BUDGET_MARGIN` | 1.5 | runbook, planning value |
| `oblit_q3km_c_q8` | 65536 | `qwen38-oblit-q3km-kvpick`, 73728 OOMs |
| `oblit_q3km_c_f16` | 32768 | `qwen38-oblit-q3km-kvpick`, 40960 OOMs |
| `oblit_q3km_c` | 65536 (q8_0) | `qwen38-oblit-q3km-kvpick`, the larger of the two |
| `oblit_q3km_kv` | `q8_0` | `qwen38-oblit-q3km-kvpick`, gate passed (65536 ≥ 32768) |
| `oblit_q3km_clean` | 64512 | `sweep-qwen38-oblit-q3km`, deepest tested depth, 16.74 tok/s, all depths above the 8 tok/s floor |
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

## `qwen38-oblit-q3km-kvpick` — done

Ladders in `results.md`. q8_0 serves at 65536, fails at 73728. f16
serves at 32768, fails at 40960. Gate: `oblit_q3km_c` = 65536 (q8_0),
at or above the 32768 floor. Gate passes, pick `q8_0`. Run goes on to
`sweep-qwen38-oblit-q3km`.

Deviation: the load log shows `blk.64.nextn.*` tensors (an MTP/draft
head) present in the file and ignored as unused on every load. No
drafter arm runs in this run regardless (runbook, "The file").

## `sweep-qwen38-oblit-q3km` — done

Table in `results.md`. Tool `llama-benchy` `204acec`. All three depths
(4096, 24576, 64512) served cleanly, tg tok/s 22.67 to 16.74, never
under the 8 tok/s floor. `oblit_q3km_clean` = 64512. Corpus server
stopped after this block, as the runbook requires.

## Handing-over

`machine-setup`, `qwen38-oblit-q3km-kvpick`, `sweep-qwen38-oblit-q3km`
done. Next: `qwen38-oblit-q3km-calibrate-think`.
