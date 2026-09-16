# Run 22 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| `budget_message` | `Thinking budget reached. Give the final answer now.` | runbook, Essentials |
| `THINKING_BUDGET_MARGIN` | 1.5 | runbook, planning value |
| `fork_has_reasoning_budget` | yes | `machine-setup` |

## `machine-setup`

Worktree `../choose-a-local-llm-run22`, branch `run22`, off `master` at `ce15675`.

Preflight: all lines `ok`. Wired limit 25000. Start numbers: wired 2093 MB, free 19442 MB, swap used 409 MB. Memory line said balloon needed (free below 25600 MB threshold); no balloon was run, the first real server load is the ramp.

Tool commits: `thinking-budget.py`, `calibrate.py`, `run_codegen_wrapper.py` all at `250b0c9`. `calibrate.py` writes `reasoning_len` (line 163).

`llama-server --version`: 0.4.0 (build 10809, commit `5266f24da`). `--reasoning-budget` and `--reasoning-budget-message` both print. `~/prism-llama/llama-server --help` also prints both flags: `fork_has_reasoning_budget` = `yes`.

`evalplus.codegen --help` runs clean.

Message probe, MoE 26B GGUF (`--reasoning-budget 32`, thinking on): `reasoning_content` ends with the budget message, `content` is not empty, `usage.completion_tokens_details` present but empty (no forced-token subfield). Pass.

Message probe, fork (`bonsai-prism`, Q2_g64, q4_0/q4_0 KV, bias file, `-c 32768`, `--reasoning-budget 32`): `reasoning_content` ends with the budget message, `content` is not empty. Pass.

Both probe servers stopped after their probe. Wired after stop: 133919 pages (~2093 MB), matching the preflight start value.

Done: versions, probe results and the message recorded here, committed.
Deviation: none.

## `gemma26-gguf-calibrate-think`

Served without a thinking budget: `llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL --alias gemma-4-26b-a4b --no-mmproj --spec-type draft-mtp --spec-draft-n-max 2 --parallel 1 -ngl 999 -fa on -c 32768 --cache-type-k f16 --cache-type-v f16 --jinja --port 8081`, thinking on (`enable_thinking: true`).

Calibration `calibration-gemma26-gguf-think-budget.json`, 10/10 problems, margin 1.5.

`gemma26_think_budget` = 19491
`gemma26_answer_budget` = 2048
`gemma26_max_tokens` = 21539

Derive output: converged 8, cut 2, max_reasoning_tokens 12994, max_answer_tokens 1098.

Server kept up for the budget block.
Files: `hardware/kamaji/calibrations/calibration-gemma26-gguf-think-budget.json`, `hardware/kamaji/benchmarks/bench22/results/gemma26-gguf-calibrate-think/server.log`.
Deviation: none.

### evalplus gemma-4-26b-a4b think-budget — running

Served with the budget: `--reasoning-budget 19491 --reasoning-budget-message "$BUDGET_MSG"`, `-c 32768`. Verified with a real request (`finish_reason: length` at 512 tokens, expected under budget). Wired after load: ~20161 MB.

Watcher started (pid 37475), `RUNWATCH_MEM_LOG=~/.local/share/choose-a-local-llm/run22-gemma26-budget-think-mem.log`. Codegen started (pid 37728), `EVALPLUS_MAX_NEW_TOKENS=21539`.

still running.
Files: `hardware/kamaji/benchmarks/bench22/results/gemma26-gguf-budget-think/`.
Deviation: none.
