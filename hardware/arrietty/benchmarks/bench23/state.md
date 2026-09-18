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
| `oblit_q3km_think_budget` | 3986 | `qwen38-oblit-q3km-calibrate-think`, max_reasoning 2657 × 1.5 |
| `oblit_q3km_answer_budget` | 2048 | `qwen38-oblit-q3km-calibrate-think`, max_answer 548 × 1.5 = 822, floor 2048 |
| `oblit_q3km_max_tokens` | 6034 | `qwen38-oblit-q3km-calibrate-think`, think + answer |
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

## `qwen38-oblit-q3km-calibrate-think` — done

Served without a thinking budget, q8_0 KV, `-c 32768`. All 10
calibration rows resolved to `medium` (`resolved_reasoning_effort`,
source `requested`). 9 converged, 0 cut. `HumanEval/32` finished on
its own (`finish_reason: stop`) with an empty answer after a very long
reasoning chain (`content_empty: true`, `wall_s` 257.8); this is the
model's own natural non-convergence, not a budget artifact, and the
derive tool counted it as converged from its measured reasoning token
count. Derived: think budget 3986 (2657 × 1.5), answer budget 2048
(548 × 1.5 = 822, floor 2048), max_tokens 6034.
Files: `hardware/arrietty/calibrations/calibration-qwen38-oblit-q3km-medium-think.json`,
`results/calibrate-think-stdout.log`, `results/server-calibrate-think.log`.

## `qwen38-oblit-q3km-budget-medium` — running

Served q8_0 KV, `-c 32768`, `--reasoning-budget 3986`,
`--reasoning-budget-message "$BUDGET_MSG"`. Verified with a real
200-token request, `finish_reason: length` as expected mid-reasoning.
VRAM 14437 / 16311 MiB. Starting the watcher and the full 164-problem
run next.

## Pause (owner needs the card, 2026-09-17)

Stopped inside `qwen38-oblit-q3km-budget-medium`. Its samples file
holds **132 of 164** problems when the stop happened:
`hardware/arrietty/benchmarks/bench23/results/qwen38-oblit-q3km-budget-medium/humaneval/qwen3.8-27b-oblit-q3km_openai_temp_0.0.raw.jsonl`.
Nothing in that directory was touched or cleaned up.

Stopped, in order: the scoring script
(`run_codegen_wrapper.py`), the watcher (`run-watch.sh`), then
`llama-server` (`pkill -x llama-server`). `nvidia-smi` read 626 MiB
used after the stop, against a session-start baseline of 614 MiB
(`vram_start_mb` in "Values" above) — the card is free.

**To resume the block**, bring the server back first:

```bash
export PATH="$HOME/.local/share/choose-a-local-llm/llama.cpp/v0.4.0-sm120/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/.local/share/choose-a-local-llm/llama.cpp/v0.4.0-sm120/lib:$LD_LIBRARY_PATH"
export BUDGET_MSG="Thinking budget reached. Give the final answer now."
llama-server -m "/home/irae/.cache/huggingface/hub/models--OBLITERATUS--Qwen3.8-27B-OBLITERATED/snapshots/a58c3b53b3ce71551eafde2ed5ec8df48e0f4ff8/Qwen3.8-27B-OBLITERATED-Q3_K_M.gguf" \
  --alias qwen3.8-27b-oblit-q3km --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 32768 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --reasoning-budget 3986 \
  --reasoning-budget-message "$BUDGET_MSG" \
  --jinja --port 8081 2>&1 \
  | tee hardware/arrietty/benchmarks/bench23/results/server-qwen38-oblit-q3km-budget-medium.log
```

Then start the watcher, then resume the run — it skips the 132
problems already in the samples file and generates only the rest:

```bash
export EVALPLUS_PYTHON="/home/irae/.local/share/pipx/venvs/evalplus/bin/python"
RESULTS_BASE=hardware/arrietty/benchmarks/bench23/results \
  EVALPLUS_MAX_NEW_TOKENS=6034 \
  benchmarks/run-humaneval.sh qwen38-oblit-q3km-budget-medium qwen3.8-27b-oblit-q3km \
  '{"chat_template_kwargs":{"reasoning_effort":"medium"}}'
```

Machine state left behind: no `llama-server` process, no watcher, no
scoring process. Corpus server (port 8089) was already stopped after
`sweep-qwen38-oblit-q3km`. The worktree and branch `run23` stay as
they are; this is a pause, not a close-out. No later block started.

## Resume (2026-09-18)

Card confirmed free (626 MiB used, no `llama-server` process). Merged
`origin/master` (fast-forward, brought in bench24 close-out and
bench25 setup, no conflict). Server brought back with the command in
"Pause" above, watcher armed, run resumed: it skipped the 132
existing problems and is generating the remaining 32.

## Handing-over

`machine-setup`, `qwen38-oblit-q3km-kvpick`, `sweep-qwen38-oblit-q3km`,
`qwen38-oblit-q3km-calibrate-think` done.
`qwen38-oblit-q3km-budget-medium` resumed, generating problems 132
through 164.
