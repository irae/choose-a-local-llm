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
- Queue item 2 done. `deepseek-v4-flash-0731` blind (v1.1): score
  84.5/100. All 8 libraries replaced, trap A and trap C avoided,
  chalk handled per v1.1 Node-defaults rule, lint and unit suite
  clean (mendel-core batch flake confirmed clean standalone). Trap B
  missed: the model found the `mendel-requirify` `rimraf` references
  (noted in its own TASKS.md) but judged them out of scope and left
  them. Root `package.json` still declares `tmp` as an unused
  devDependency. Commits used `fix`/`test` types, not the house
  `chore` convention. One model nudge at the end. One minor defect
  logged (root `tmp` left declared). Wall clock 100.6 min, cost $0.79
  metered. Scored, committed (`bce066a`, rebased over a concurrent Mac
  push), and pushed to mendel `benchmark`; run branch pushed too.
  Worktree cleaned, no stray daemon.
- Starting queue item 3: `accounts/fireworks/models/kimi-k3` pi blind
  high.
- Queue item 3 done. `kimi-k3` blind (v1.1): score 93.5/100. All 8
  libraries replaced, trap A and trap C avoided, chalk handled per
  v1.1 Node-defaults rule, lint clean, all commits `chore`-typed and
  split per package, root devDeps removed cleanly. mendel-pipeline
  showed 6 flaky timeouts under load in the full-suite run; confirmed
  clean standalone (2/2), not a regression. Trap B missed: the model
  found the `mendel-requirify` `rimraf` references (noted in its own
  TASKS.md) but judged them out of scope and left them — medium
  defect. Zero nudges. Wall clock 20.3 min, cost $2.13 metered.
  Scored, committed (`3eb0fb8`), and pushed to mendel `benchmark`; run
  branch pushed too. Worktree cleaned, no stray daemon. Also fixed a
  scoring-script bug this run surfaced: the existing `v1.0` kimi-k3
  row shares the bare `model` field with this `v1.1` row, so any
  future lookup by `model` alone must also filter by
  `prompt_version`/`branch` — the CSV append hit this and was
  corrected before commit.
- Starting queue item 4: `accounts/fireworks/models/deepseek-v4-pro-0813`
  pi blind high.
