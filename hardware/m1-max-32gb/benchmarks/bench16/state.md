# Run 16 — state

Created 2026-09-12 by the coordinator. Not started.

Start here: read `AGENT.md`. The list at the top of that file is the
order. Log every session below, and close each one with a
handing-over section.

## Session 1, 2026-09-12 (executor: Claude Sonnet 5, Mac)

Worktree `../choose-a-local-llm-run16`, branch `run16`, from `master`
at `f82f4fe`. Preflight: every line `ok`. Starting numbers: wired 1834
MB, free 15157 MB, swap used 447 MB. Wired limit 25000. Memory line:
balloon needed. No `llama-server`, no `mlx_lm`, no LM Studio, no
Docker before the first server.

## Values the blocks write

| name | value | source block |
|---|---|---|
| `qwen36_mlx_window` | 36864 | planning value, 5 percent under the last measured ceiling. Coordinator gate (2026-09-12): the `sweep-qwen36-mlx` dead cell was a 40449-token prompt, above 36864, so it says nothing about the window; a step down applies only after a death at the window itself. If the smoke or the blind row dies at 36864, step down to 28672 and record the step here. |
| `gemma26_mlx_window` | 65536 | planning value, 5 percent under the last measured ceiling (site row `maxCtx` 70K). Not moved by `sweep-gemma26-mlx`, whose deep cell (65536) completed with no death. |
| `qwen36_mlx_on` | | `qwen36-mlx-mendel-blind-on` |
| `gemma26_mlx_high` | | `gemma26-mlx-mendel-blind-high` |
