# Run 8 state

Planned 2026-09-01. Mendel re-runs on the Linux box: API models through
`run-pi-rpc.mjs`, blind v1.1 for the strong models, guided v3.0 plus
blind for the cheap probe (deepseek-v4-flash) and the strong reference
(gpt-5.6-luna). Anthropic models are on the list but skipped (no
budget). Runbook: `AGENT.md`. Note deviations here as they happen.

**Standing rule (user, 2026-09-02):** keep all main repo worktrees
free for the user's own parallel use. Never run benchmark work
(commits, run-worker.sh, scoring) directly in a repo's main worktree
if that repo has one — use a dedicated sibling worktree instead, and
leave the main worktree checked out to a normal branch (e.g.
`master`) the user can use freely. This applies to future runs, not
only this one.

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
- Queue item 4 done. `deepseek-v4-pro-0813` blind (v1.1): score
  79/100. Trap A hit: `fs.promises.glob()` swapped in with a naive
  `.then()`, throws `TypeError` at runtime — critical defect. Trap B
  missed: `mendel-requirify` still requires `rimraf` in two test files
  and its `package.json` — medium defect. Trap C avoided. Root
  devDeps (`rimraf`, `tmp`) fully removed. Prettier and ESLint clean,
  model ran the tools itself. Commits used `refactor` type, not the
  house `chore` convention (lost commit-craft points). Zero nudges.
  Wall clock 92.5 min, cost $3.33 metered. Scored, committed
  (`fac0c1b`), and pushed to mendel `benchmark`; run branch pushed
  too. Worktree cleaned, no stray daemon. Note: the OpenRouter
  cost-comparison figure in this row's `cost.or_usd` is an estimate
  (no live OpenRouter lookup available to the scoring fork), not a
  looked-up quote — flag for a follow-up correction if exact pricing
  matters later.
- Queue item 5 first attempt hit the config guard (exit `bad_config`):
  `~/.pi/agent/models-store.json` reports `grok-4.6` with
  `maxTokens (500000) == contextWindow (500000)`, so auto-compaction
  cannot trigger. Per AGENT.md ("fix the config, never
  `--allow-bad-config`"), added an operator override at
  `~/.pi/agent/models.json` (`providers.xai.modelOverrides["grok-4.6"].
  maxTokens: 128000`) — the value pi's own built-in catalog uses for
  the same model on other providers (github-copilot, opencode), so it
  is truthful, not a guess. `run-worker.sh` copies this file into the
  per-run pinned config dir automatically. Cleaned up the failed
  worktree/branch and restarted.
- Starting queue item 5 (retry): `grok-4.6` pi blind high. Passed the
  config guard this time, worktree ready, pi started.
- Queue item 5 done. `grok-4.6` blind (v1.1): score 92.5/100. All 8
  libraries replaced, trap A avoided (`SYNC OK`), trap B fixed
  explicitly (`mendel-requirify` rimraf refs replaced with
  `fs.rmSync`, own commit `fb7f406`), lint clean, model ran prettier
  and eslint itself (16×), full unit suite green (260/260; the
  `mendel-resolver` lerna-batch failure was a flake, confirmed clean
  standalone 75/75; `mendel-full-example`'s daemon-socket test fails
  on master too — expected baseline, not a regression). All 18
  commits `chore`-typed, one package each, root devDeps fully
  removed, zero nudges. One medium defect: trap C hit —
  `validate-manifest.js` now registers a `process.on('exit')` hook
  that deletes the debug-manifest temp dir, undoing the point of
  printing its path; this is a self-inflicted regression not present
  on master. Wall clock 21.4 min, cost $7.29 metered (this session's
  xai login is not on a plan — `probe-plan.mjs` returned "no plan
  involved" — unlike the existing v1.0 row, which used plan-share
  accounting). Scored, committed (`3e15cf6`), and pushed to mendel
  `benchmark`; run branch pushed too. Worktree cleaned, no stray
  daemon.
- Paused after item 5: user flagged a possible blind/guided plan
  issue for some queue items. On review the user confirmed the queue
  order is correct (misread on their side) — resuming.
- Starting queue item 6: `gpt-5.6-luna` pi guided high. Passed the
  plan probe and config guard; worktree
  `../mendel-bench-guided-gpt-5.6-luna-high` ready at `guided-v3-base`
  (6458616), pi started. Quiet-account window not required for xai
  (grok) runs — only openai-codex needs it; this is an openai-codex
  model, so per AGENT.md this run should ideally sit in a quiet
  ChatGPT/Codex window. Proceeding since the user asked to continue;
  noting the deviation from "run openai-codex last, in the deepest
  night hours" for the record.
- Queue item 6 done. `gpt-5.6-luna` guided (v3.0): score 88.5/100.
  All 8 libraries replaced, trap A avoided (`SYNC OK`), trap B found
  and fixed (own commit `27ea4bd`), root devDeps fully removed via
  their own commits, prettier/eslint clean (model self-checked 4×),
  full suite run 20× over 18 commits (satisfies the v3.0
  before-every-commit cadence), task list per-file with per-commit
  ticks. One medium defect: trap C hit — `validate-manifest.js`
  registers a `process.once('exit')` hook that deletes the debug
  manifest right after printing its path, a self-inflicted regression
  not on master. Minor dings: one multi-package commit (xtend
  replaced across two packages in one commit) and one self-repair
  commit (dropped an obsolete forced chalk colour option after an
  earlier commit left it in) cost small deductions on commit-craft and
  right-the-first-time. Zero nudges. `mendel-pipeline`'s lerna-batch
  run flaked (0 of 22 suites completing); confirmed clean standalone
  (260/260) — not a regression. Wall clock 40.4 min, cost $0.70
  metered (`probe-plan.mjs` returned "no plan involved" for this
  session's openai-codex login, so no plan-share accounting applies).
  Scored, committed (`e86dd50`), and pushed to mendel `benchmark`; run
  branch pushed too. Worktree cleaned, no stray daemon.
- **Restructure**: per the user's standing rule (see header), moved
  all mendel benchmark work out of the main `../mendel` worktree. That
  repo now sits on `master`, clean, free for the user's own parallel
  use. Created a dedicated worktree `../mendel-benchmark` checked out
  to `benchmark`; all leftover untracked run artifacts (meta/session/
  plan/log files from items 1-6, whose branch-suffixed copies were
  already committed) were moved there too, nothing lost. **From now
  on, every mendel benchmark command (run-worker.sh, score.mjs,
  generate-report.mjs, git commits/pushes on branch `benchmark`) runs
  from `/home/irae/code/mendel-benchmark/benchmark`, not
  `/home/irae/code/mendel/benchmark`.** Update any future step
  accordingly.
- Starting queue item 7: `gpt-5.6-luna` pi blind high, from the new
  path `/home/irae/code/mendel-benchmark/benchmark`.
- Queue item 7 done. `gpt-5.6-luna` blind (v1.1): score 83.5/100. All
  8 libraries replaced, trap A avoided (`SYNC OK`), trap B fixed
  (mendel-requirify's stale rimraf require removed, own commit
  `2768421`), chalk uses `util.styleText` with no forced level per the
  v1.1 Node-defaults rule. One medium defect: trap C hit —
  `validate-manifest.js` registers a `process.once('exit')` hook that
  deletes the debug manifest right after printing its path (same
  regression as the v1.0 row and item 6). Prettier/ESLint clean on
  re-run but the model never ran the tools itself (hook-only credit,
  capped at 3/5). Commit craft took a real hit: 18 of 21 commits used
  `fix`, only 3 used the house `chore` type (all-chore component of
  criterion 5 scored 0/4; package-per-commit and no-violations
  components stayed full). One model nudge (model stopped with
  TASKS.md items unchecked, resumed and finished 3 min later). Full
  suite run 6 times over 21 commits (meets the blind "about every 5
  commits" cadence). `mendel-pipeline`'s lerna-batch run SIGILL'd on
  `dual-package-cjs.js`; confirmed clean standalone (5/5) — a machine-
  load flake, not a regression. `mendel-full-example`'s daemon-socket
  test fails on master too — expected baseline. Wall clock 27.2 min,
  cost $0.47 metered (`probe-plan.mjs` returned "no plan involved" for
  this session's openai-codex login). Scored, committed (`9897c6b`
  in the new `mendel-benchmark` worktree), and pushed to mendel
  `benchmark`; run branch `gpt-5.6-luna-high-issue-13` pushed too.
  Worktree removed, no stray daemon or process. Note: the report's
  OpenRouter cost-comparison figure for this row is an estimate, not a
  live lookup (same caveat as item 4's row).
- **Paused after item 7 per user request.** Queue item 8
  (`gpt-5.6-sol` blind) and the `claude-haiku-4.5` skip note remain
  for a future session. Verified: no `pi --mode rpc` or `Mendel
  Daemon` process running, `git -C ../mendel-benchmark worktree list`
  shows only the main `mendel-benchmark` worktree itself (no stray run
  worktrees), and the main mendel repo (`../mendel`) sits untouched on
  `master`.
- New session, 2026-09-02. Confirmed no leftover daemon or run
  worktrees, `../mendel-benchmark` up to date, `../mendel` tags
  fetched. Created worktree `../choose-a-local-llm-run8` on branch
  `run8`. Starting queue item 8: `gpt-5.6-sol` pi blind high, from
  `/home/irae/code/mendel-benchmark/benchmark`. This is an
  openai-codex model; per AGENT.md it should ideally run in a quiet
  ChatGPT/Codex window, but it is the last queue item with no other
  run in flight, so proceeding now. Worktree
  `../mendel-bench-gpt-5.6-sol-high` ready, pi started.
- User set up an Anthropic login on this box (pi), unlocking
  `claude-haiku-4.5` and `claude-sonnet-4.5`. Updated `AGENT.md`: lifted
  the "never run Anthropic" ban, added queue items 9-11
  (`claude-haiku-4.5` guided, `claude-haiku-4.5` blind,
  `claude-sonnet-4.5` blind). pi+anthropic runs are metered per
  PLAN.md "Plan accounting", not plan-share, so they carry no
  isolation-window requirement and can run alongside the openai-codex
  or xai runs.
- Starting queue item 9: `claude-haiku-4.5` pi guided high, in
  parallel with the still-running queue item 8 (`gpt-5.6-sol` blind).
  Safe: each worker gets its own sibling worktree
  (`../mendel-bench-guided-claude-haiku-4.5-high` vs.
  `../mendel-bench-gpt-5.6-sol-high`), different provider (metered
  anthropic vs. plan-share openai-codex, no plan overlap), different
  branch. Worktree ready, pi started.
- Queue item 8 done. `gpt-5.6-sol` blind (v1.1): score 92/100. All 8
  libraries replaced, trap A avoided (`SYNC OK`), trap B fixed
  (`mendel-requirify` rimraf refs removed, own commit `a9ba7c1`), chalk
  uses plain `util.styleText` with no forced level per the v1.1
  Node-defaults rule. One medium defect: trap C hit —
  `validate-manifest.js` registers a `process.once('exit')` hook that
  deletes the debug manifest right after printing its path (same
  regression as items 6 and 7). All 18 commits `chore`-typed, one
  package each, root devDeps fully removed, lint clean (model self-ran
  prettier/eslint 17 times). Full suite (674/674, 1 skip) clean
  standalone, run 7 times over 18 commits — well inside the blind
  "about every 5 commits" cadence. Zero nudges, zero self-repair
  commits (spot-checked the commit log, one-shot per package). Task
  list built as a full tree upfront with per-package sub-items, ticked
  per commit (not textbook progressive discovery, so docked to 2.5/4
  like item 7's row). Truncation share 21%, docked to 2.5/3. Wall clock
  24.4 min, cost $12.11 metered (`probe-plan.mjs` returned "no plan
  involved" for this session's openai-codex login). Scored, committed
  (`2a5d273` in `mendel-benchmark`), and pushed to mendel `benchmark`;
  run branch `gpt-5.6-sol-high-issue-13` pushed too. Worktree removed,
  no stray daemon or process. Note: the report's OpenRouter
  cost-comparison figure for this row is an estimate, not a live
  lookup (same caveat as items 4 and 7's rows).
