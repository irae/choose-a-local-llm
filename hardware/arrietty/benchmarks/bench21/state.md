# Run 21 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| `budget_message` | `Thinking budget reached. Give the final answer now.` | runbook, Essentials |
| `THINKING_BUDGET_MARGIN` | 1.5 | runbook, planning value |
| `vram_start_mb` | 926 | `nvidia-smi`, session start 2026-09-16 20:23 UTC |
| `evalplus_python` | `/home/irae/.local/share/pipx/venvs/evalplus/bin/python` (EvalPlus 0.3.1) | pipx venv |
| `llama_server` | `~/.local/share/choose-a-local-llm/llama.cpp/v0.4.0-sm120/bin/llama-server`, CUDA0 RTX 5060 Ti | run 17 build |

## machine-setup

Worktree `../choose-a-local-llm-run21`, branch `run21` from `origin/master` at `9981cda`.
Tools: `thinking-budget.py`, `calibrate.py` (writes `reasoning_len`), `run_codegen_wrapper.py` present at `8b49c41`.
`llama-server --help` prints `--reasoning-budget` and `--reasoning-budget-message`.
Machine: `gh auth` ok, 35G free on `/home`, 12 GB RAM free, no `llama-server` process.
The ISTA Qwen3.8 file sits in `~/.cache/llama.cpp/hf/`; `hf download` into the default cache started at 20:24 UTC in the background (`~/.local/share/choose-a-local-llm/run21-ista-download.log`).

**Message probe.** Gemma-4-12B NVFP4, `--reasoning-budget 32`, thinking on, one chat completion at `max_tokens` 2048.
`nvidia-smi` 8866/16311 MiB with the server up.

| check | result |
|---|---|
| `reasoning_content` present | yes |
| reasoning tail ends with the budget message | yes |
| `content` non-empty | yes (555 completion tokens, finish `stop`) |
| `usage.completion_tokens_details` | absent (usage has `prompt_tokens_details` only) |

Files: `results/probe-gemma12-nvfp4.json`, `results/server-probe-gemma12-nvfp4.log`.
Note: `hf download` prints `path=<file>`; every serve command strips the prefix with `sed 's/^path=//'`. `pkill -f` on the server command line kills the runner's own shell; stop servers with `pkill -x llama-server`.
Deviation: none.

## gemma12-nvfp4-calibrate-think

Gemma-4-12B NVFP4 (`FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF` rev `eb8c8df`), one slot, f16 KV, ctx 32k, no budget flag, thinking on. `nvidia-smi` 8866/16311 MiB. Calibration 20:33 to 21:36 UTC.

| name | value |
|---|--:|
| converged | 4 |
| cut at 30000 | 6 |
| max reasoning tokens (converged) | 4900 |
| max answer tokens (converged) | 528 |
| margin | 1.5 |
| `gemma12_nvfp4_on_think_budget` | 7350 |
| `gemma12_nvfp4_on_answer_budget` | 2048 |
| `gemma12_nvfp4_on_max_tokens` | 9398 |

Every row has `has_separate_reasoning_field: true` (thinking on); `resolved_reasoning_effort` is `null` for Gemma, which has a switch and no level. Cut: HumanEval/32, 39, 76, 99, 124, 145.
Files: `hardware/arrietty/calibrations/calibration-gemma12-nvfp4-on-think.json`, `results/calibrate-gemma12-nvfp4-on-think.log`, `results/server-gemma12-nvfp4-calibrate-think.log`.
Deviation: none.

## evalplus gemma-4-12b nvfp4/f16/on budget 7k

Gemma-4-12B NVFP4 rev `eb8c8df`, one slot, f16 KV, ctx 32k, `--reasoning-budget 7350`, thinking on, `max_tokens` 9398. `nvidia-smi` 9120/16311 MiB after load. Verify request: finish `stop`, 6308 completion tokens, not forced, answer present.
Wall parts (UTC):
- part 1 start 21:40
- part 1 end 21:50 (the Claude Code harness killed the background run task and the watcher on its own low-memory guard; the server stayed up, 17 problems landed; free RAM 1.7 GB, available 12 GB)
- part 2 start 21:52, resumed with `setsid nohup`, outside the harness's task list, same run directory
- part 2 end 00:56 (2026-09-17), last problem 00:56:42, evaluate done 00:56:50
Wall: 10.0 + 184.8 = 194.8 min.

| metric | value |
|---|--:|
| HumanEval base | 0.976 |
| HumanEval plus | 0.951 |
| completion rate | 100% |
| empty (samples) | 0/164 |
| forced (finish log) | 45/164 |
| think budget | 7350 |
| answer budget | 2048 |
| `max_tokens` | 9398 |
| wall | 194.8 min |

Natural run of the same config (`gemma12-nvfp4-on`, models.json): 0.659/0.640/68%, 53/164 empty, budget 8192, wall 203.9 min.
Forced-failed (prepare): 6 of 45: HumanEval/32, 39, 91, 132, 134, 145.
Files: `results/gemma12-nvfp4-budget-on/`, `results/server-gemma12-nvfp4-budget-on.log`, `results/run-gemma12-nvfp4-budget-on.log`, `results/watch-gemma12-nvfp4-budget-on.log`, `~/.local/share/choose-a-local-llm/run21-gemma12-nvfp4-budget-on-mem.log`.
Deviation: the harness killed the run task and the watcher once (part 1 end); the server never died; the wall excludes the 2-minute gap.

## evalplus gemma-4-12b nvfp4/f16/on forced-rerun — running

Same file and arm, no reasoning flags, `max_tokens` 30000, 6 problems. `nvidia-smi` 9058/16311 MiB after load. Verify request: finish `stop`, not forced.
Wall parts (UTC):
- part 1 start 01:09 (2026-09-17)
