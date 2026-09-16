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
