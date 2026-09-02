# Run 8 state

Planned 2026-09-01. Mendel re-runs on the Linux box: API models through
`run-pi-rpc.mjs`, blind v1.1 for the strong models, guided v3.0 plus
blind for the cheap probe (deepseek-v4-flash) and the strong reference
(gpt-5.6-luna). Anthropic models are on the list but skipped (no
budget). Runbook: `AGENT.md`. Note deviations here as they happen.

## Run log

- Mendel repo confirmed at `79526d6` on branch `benchmark` (matches or
  is later than the expected commit).
- Checked existing rows: `results.json` has old `v1.0` blind rows for
  grok-4.6, gpt-5.6-luna, kimi-k3, deepseek-v4-pro-0813, gpt-5.6-sol.
  Current blind prompt is `v1.1`, so the queue items for these models
  are re-runs at the new prompt version, not duplicates. No deviation
  needed.
- `deepseek-v4-flash-0731` has no row yet (blind or guided).
  `gpt-5.6-luna` has no guided row yet.
- Started queue item 1: `accounts/fireworks/models/deepseek-v4-flash-0731`
  pi guided high. Worktree
  `../mendel-bench-guided-accounts-fireworks-models-deepseek-v4-flash-0731-high`
  created at `guided-v3-base` (6458616).
