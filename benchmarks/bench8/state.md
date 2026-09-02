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
- Queue item 1 done. `deepseek-v4-flash-0731` guided (v3.0): score
  97/100. All 8 libraries replaced, all three traps handled, lint and
  full test suite clean. One model nudge (output budget hit once,
  docked on criterion 6). No critical or medium defects. Wall clock
  249 min, cost $2.47 metered. Scored, committed, and pushed to mendel
  `benchmark` (`c261517`); run branch pushed too. Worktree cleaned,
  no stray daemon.
- Starting queue item 2: `accounts/fireworks/models/deepseek-v4-flash-0731`
  pi blind high.
- Quirk found: `runs/<model>-<thinking>-meta.json` (and the sibling
  `-session.jsonl`, `-session.html`, `-runner.log`, `-events.jsonl`,
  `-install.log`, `-worker.json`, `-plan-before/after.json`) are named
  by model+thinking only, not by bench. Starting a blind run for a
  model right after its guided run overwrites these files. The
  branch-suffixed evidence and session copies made during scoring are
  safe; only the live in-progress files collide. Scoring the guided
  run before starting the blind run (as this queue already does)
  avoids data loss, since the guided copies were already made.
