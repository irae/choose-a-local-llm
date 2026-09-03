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
- Queue item 9 first attempt failed instantly: bare `claude-haiku-4.5`
  is ambiguous across providers (`cloudflare-ai-gateway`,
  `github-copilot`), neither authenticated, `pi` refused with
  `runner_error`. Checked `~/.pi/agent/models-store.json`: the
  anthropic-authenticated ids use dashes, not dots
  (`claude-haiku-4-5`, `claude-sonnet-4-5`), and need the
  `anthropic/` provider prefix to disambiguate. Cleaned the failed
  worktree/branch (no work had started), fixed `AGENT.md` items 9-11
  to `anthropic/claude-haiku-4-5` / `anthropic/claude-sonnet-4-5`, and
  added a note for future Anthropic id corrections.
- Restarted queue item 9: `anthropic/claude-haiku-4-5` pi guided high.
  Worktree `../mendel-bench-guided-anthropic-claude-haiku-4-5-high`
  ready, pi started.
- User added queue items 12-13: `accounts/fireworks/models/glm-5p3-flash`
  blind then guided. Also clarified the parallel rule in `AGENT.md`:
  at most two runs in flight, never two on the same account (not just
  per plan-provider).
- Starting queue item 12: `accounts/fireworks/models/glm-5p3-flash` pi
  blind high, in parallel with the still-running queue item 9
  (`anthropic/claude-haiku-4-5` guided). Safe: different account
  (metered fireworks vs. metered anthropic), separate sibling
  worktree (`../mendel-bench-accounts-fireworks-models-glm-5p3-flash-high`),
  separate branch. Worktree ready, pi started.
- Queue item 9 done. `claude-haiku-4-5` guided (v3.0): score 76/100.
  First-ever Anthropic-model row in this benchmark. All 8 libraries
  replaced. Trap A HIT: `apply-extra-options.js` calls
  `fs.promises.glob(i).then(...)` — `fs.promises.glob()` returns an
  AsyncIterator, not a Promise, throws `TypeError: glob(...).then is
  not a function` — critical defect. Trap B fixed (`mendel-requirify`
  has zero rimraf refs left). Trap C avoided (no exit hook in
  `validate-manifest.js`). Chalk uses plain `util.styleText`, no
  forced colour, correct per v3.0 Node-defaults rule. Full suite
  clean standalone (674/674, 1 skip), same baseline as item 8. 16 of
  19 commits used `fix`, not the house `chore` (lost most of
  commit-craft's all-chore points), plus one multi-package commit
  (all remaining package.json edits batched into one "chore" commit).
  Only the two root-level deps (`rimraf`, `tmp`) went through a real
  `pnpm remove -w`; the rest were manual package.json edits with no
  verifying install afterward — scored as "install unverified", not
  a real prune. Guided v3.0 wants a full-suite run before every
  commit; only 13 of 21 commit attempts had one — short of the
  mandate. Lint clean, model self-ran prettier and eslint after its
  last commit (full lint credit). TASKS.md is gitignored in this repo
  (not a defect) — per-file granularity grouped by package, fully
  ticked, matches commit order. Zero nudges, zero self-repair
  commits. Truncation share 96% (69 of 72 noisy commands piped
  through `tail`/`head`) — the highest seen in this queue, heavily
  docked. Wall clock 27.3 min, cost $1.73 metered (`probe-plan.mjs`
  returned "no plan involved" for this session's Anthropic login, so
  metered like item 8, not plan-share). Scored, committed (`af3c011`
  in `mendel-benchmark`), and pushed to mendel `benchmark`; run
  branch `anthropic-claude-haiku-4-5-high-guided-v3-issue-13` pushed
  too. Worktree removed. Did not run `pkill -f "Mendel Daemon"` since
  other runs (`claude-haiku-4-5` blind, `glm-5p3-flash` blind/guided)
  were still in flight in other worktrees at the time.
- Started queue item 10 (`anthropic/claude-haiku-4-5` pi blind high)
  and queue item 13 (`accounts/fireworks/models/glm-5p3-flash` pi
  guided high) once their respective predecessor runs freed up:
  worktrees `../mendel-bench-anthropic-claude-haiku-4-5-high` and
  `../mendel-bench-guided-accounts-fireworks-models-glm-5p3-flash-high`
  both ready, pi started for both. Two runs in flight
  (`anthropic/claude-haiku-4-5` blind, `glm-5p3-flash` guided),
  different accounts, safe pair.
- Queue item 12 done. `glm-5p3-flash` blind (v1.1): score 75/100.
  First-ever row for this model. All 8 libraries replaced, root
  devDeps removed, static completeness clean. Trap A HIT (critical
  defect): `apply-extra-options.js` swaps in `fs.promises.glob()` with
  a naive `.then()` chain, throws `TypeError: glob(...).then is not a
  function` at runtime (repro confirmed) — same trap-A failure mode as
  item 9's `claude-haiku-4-5` row. No unit test covers this file, so
  the full suite still passes (674/674, 1 skip). Trap B fixed
  (`mendel-requirify` rimraf refs removed). Trap C avoided. Chalk uses
  plain `util.styleText`, no forced `enableColor`, per the v1.1
  Node-defaults rule. Commit craft is weak: 9 commits, all
  `refactor`/`test` typed (0 `chore`), 5 of them multi-package. Real
  `pnpm install` verified (not lockfile-only). Lint not clean on
  re-run: `prettier --check` flags `TASKS.md` itself, and the model
  never ran the lint tools itself. `TASKS.md` is a flat, coarse
  checklist with no per-package sub-items (all pre-checked, not
  progressive). High truncation share (69%). Zero nudges. Wall clock
  21.4 min, cost $0.19 metered (`no plan involved`, fireworks is
  metered). Scored, committed (`cb73cf5` in `mendel-benchmark`), and
  pushed to mendel `benchmark`; run branch
  `accounts-fireworks-models-glm-5p3-flash-high-issue-13` pushed too.
  Worktree removed, no stray process for this run (did not run
  `pkill -f "Mendel Daemon"`, since `claude-haiku-4-5` blind and
  `glm-5p3-flash` guided were still in flight at the time).
- Queue item 13 done. `glm-5p3-flash` guided (v3.0): score 98/100.
  All 8 libraries replaced, all three traps handled: trap A avoided
  (`SYNC OK`), trap B fixed (`mendel-requirify` rimraf refs replaced
  across two commits), trap C avoided by design — the model's own
  `TASKS.md` notes the debug-manifest dump is "intentionally left
  behind, same as tmp's default", i.e. it read the issue's `tmp`
  claim correctly and chose not to add the buggy exit hook. Chalk
  uses plain `util.styleText`, no forced level, per the v3.0
  Node-defaults rule. Lint clean, model self-ran `prettier --check`
  and `eslint .` after its last edits. All 18 commits `chore`-typed,
  one package each, no multi-package, no `--no-verify`/`git add -A`,
  root devDeps removed via verified `pnpm remove -w`. Full suite
  clean standalone (680/680, 1 skip), 14 full-suite runs across 18
  commits (a handful of commit batches ran without an immediately
  preceding full run, short of the guided "before every commit" bar,
  hence 9/10 not 10/10). Task list textbook progressive, per-file
  sub-items grouped by package, ticked per commit. Zero nudges, zero
  self-repair commits. Truncation share 66%, but by deliberate
  `| tail -N` noise reduction on the model's own test/build output,
  not lossy harness capping — scored full marks per the rubric's
  "truncation is about effect, not just the pipe count" note (same
  precedent as `deepseek-v4-flash-0731`'s 75%-truncation full-score
  guided row). No defects. Wall clock 24.0 min, cost $0.25 metered
  (`no plan involved`, fireworks is metered). Scored, committed
  (`c2807c4` in `mendel-benchmark`), and pushed to mendel `benchmark`;
  run branch
  `accounts-fireworks-models-glm-5p3-flash-high-guided-v3-issue-13`
  pushed too. Worktree removed. Did not run `pkill -f "Mendel
  Daemon"` — `claude-haiku-4-5` blind scoring and `claude-sonnet-4-5`
  blind may still be in flight.
- Queue item 10 done. `claude-haiku-4-5` blind (v1.1): score 34/100.
  Weak run overall, consistent with a small/fast model on the harder
  blind prompt. Only 6 of 8 libraries functionally correct: trap A HIT
  (critical) — `apply-extra-options.js`'s naive `.then()` on
  `fs.promises.glob()` throws `TypeError` (same failure mode as items
  9 and 12). Trap B missed: `mendel-requirify` still requires `rimraf`
  in two test files and its `package.json`, never touched. A second
  critical defect: root `package.json` still declares BOTH `rimraf`
  and `tmp` — neither was ever removed, no `pnpm install` ran at any
  point, lockfile shows zero change at all (RUBRIC.md scores
  never-removing-root-deps-at-all as its own critical defect, separate
  from trap B). `node_modules` pruning scored 0/8 (no install
  attempted, verified or not). Chalk correct (plain `util.styleText`,
  no forced colour). Trap C avoided (no exit hook added). Commit craft
  weak: all 8 commits used `fix`, not `chore` (0/4), 5 of 8
  multi-package, and 10 separate `git add -A` calls (a real
  commit-craft violation, not just a missed convention). No `TASKS.md`
  was ever created — the coarsest possible outcome, scored 0/4 (worse
  than "coarse or unmaintained", since there was no list at all).
  Lint clean on re-run but hook-only, model never self-ran the tools —
  capped at 3/5. Only 2 full-suite runs across 8 commits, no visible
  narrow per-package runs. Truncation share 70% (highest in the blind
  queue this run alongside item 12's 69%). Full test suite is clean
  standalone regardless (674/674, 1 skip) since no unit test covers
  trap A's file. Zero nudges. Wall clock 10.2 min, cost $1.05 metered
  (`probe-plan.mjs` returned "no plan involved", same as items 8, 9,
  and 12). Scored, committed (`c51f802` in `mendel-benchmark`), and
  pushed to mendel `benchmark`; run branch
  `anthropic-claude-haiku-4-5-high-issue-13` pushed too. Worktree
  removed. Did not run `pkill -f "Mendel Daemon"` — `claude-sonnet-4-5`
  blind (item 11) was still in flight at the time.
- Queue is now fully started: items 8-13 have all run, and 8, 9, 10,
  12, 13 are scored and pushed. Remaining work for a future check:
  confirm item 11 (`claude-sonnet-4-5` blind) finishes and is scored,
  then run the AGENT.md closing/stop-and-sync steps.
- Mirrored items 8, 9, 10, 12, 13 into `benchmarks/mendel/` (site
  reports and CSVs) and regenerated the site tables, per
  `docs/methodology/mendel.md` and `benchmarks/mendel/README.md`.
  While doing this, found and fixed a gap: the `claude-haiku-4-5` and
  `glm-5p3-flash` scoring forks (items 9, 10, 12, 13) updated
  `results.json`/`results-guided.json` and the reports but never
  appended the matching `results.csv`/`results-guided.csv` rows
  (unlike item 8's fork, which did). Backfilled all four rows from the
  JSON, committed to `mendel-benchmark` (`dc4efca`), then mirrored.
  claude-sonnet-4-5 is not in this mirror; it will need another
  refresh once item 11 scores.
- **Correction**: the two `AGENT.md` queue-edit commits made earlier
  this session (add Haiku/Sonnet/glm items, then fix the Anthropic
  model ids to `anthropic/<id>` form) were made directly on `master`
  in the main `choose-a-local-llm` worktree — a mistake, violating the
  standing rule that the main worktree stays free for the user.
  Corrected: cherry-picked both onto `run8` (plus the pending
  uncommitted id-fix, committed here as a third commit), then
  rebased `master` to drop them, keeping only the (legitimate) site
  mirror commit. `master` pushed clean. `AGENT.md`'s history now
  lives entirely on `run8`, as it should.
- Queue item 11 done. `claude-sonnet-4-5` blind (v1.1): score
  43.5/100. First-ever row for this model. Weak run for a strong
  reference model. Trap A HIT (critical):
  `apply-extra-options.js`'s naive `.then()` on `fs.promises.glob()`
  throws `TypeError` (repro confirmed). Trap B missed (medium):
  `mendel-requirify` still requires `rimraf` in two test files and its
  `package.json`; never mentioned in `TASKS.md`. A second critical
  defect: root `package.json` still declares both `rimraf` and `tmp`;
  no `pnpm install` ran at any point in the whole session, lockfile
  shows zero change — per RUBRIC.md this is its own critical defect,
  separate from trap B. `node_modules` pruning scored 0/8. Trap C
  avoided (no exit hook added). Chalk correct (plain `util.styleText`,
  no forced colour). Commit craft weak: all 13 commits typed
  `refactor`, not `chore` (0/4), 2 of 13 multi-package, and 15 separate
  `git add -A` calls (a real violation, not just a missed convention).
  `TASKS.md` checked off all 8 libraries as done despite the
  incomplete root-dependency work — ticks did not reflect reality,
  scored 1.5/4. Lint clean on re-run but hook-only, model never
  self-ran the tools (capped at 3/5). 6 full-suite runs across 13
  commits (some duplicate `git add -A`/commit attempts point to
  friction, e.g. `mendel-mocha-runner` and the chalk commit each
  appear twice). Full test suite clean standalone otherwise (674/674,
  1 skip; `mendel-full-example`'s daemon-socket test fails on master
  too — expected baseline). Zero nudges, no self-repair commits.
  Truncation share 41%. Wall clock 30.9 min, cost $2.99 metered
  (`probe-plan.mjs` returned "no plan involved" for this session's
  Anthropic login, metered like items 9 and 10). Scored, committed
  (`5740f5d` in `mendel-benchmark`, including the CSV row this time),
  and pushed to mendel `benchmark`; run branch
  `anthropic-claude-sonnet-4-5-high-issue-13` pushed too. Worktree
  removed.
- Mirrored item 11 into `benchmarks/mendel/` (site reports and CSVs),
  regenerated site tables, committed and pushed directly on `master`
  (`2284041`) — correct location for mirror work per
  `docs/methodology/mendel.md`.
- All 13 queue items are now done and scored. `pkill -f "Mendel
  Daemon"` run (safe, this was the last in-flight run). Verified: no
  `pi --mode rpc` or `Mendel Daemon` process running; `git -C
  ../mendel worktree list` and `git -C ../mendel-benchmark worktree
  list` show no stray run worktrees.

## Handing over

Run 8 is complete. All 13 queue items (1-13) ran and scored:
deepseek-v4-flash-0731 (guided 97, blind 84.5), kimi-k3 (blind 93.5),
deepseek-v4-pro-0813 (blind 79), grok-4.6 (blind 92.5), gpt-5.6-luna
(guided 88.5, blind 83.5), gpt-5.6-sol (blind 92), claude-haiku-4-5
(guided 76, blind 34), claude-sonnet-4-5 (blind 43.5), glm-5p3-flash
(blind 75, guided 98). All rows are committed and pushed on the
`mendel-benchmark` worktree's `benchmark` branch, with every run
branch also pushed to the `mendel` repo. The site mirror in
`benchmarks/mendel/` is up to date with all of the above. No stray
processes or worktrees remain in either repo. `run8`'s own history
(this file and `AGENT.md`) is about to be merged into `master` and the
branch/worktree retired, per `AGENT.md`'s "Closing" section and this
repo's `AGENTS.md` stop-and-sync steps.

## Reopened, 2026-09-02

User asked for one more model: `anthropic/claude-sonnet-4-5` guided
(item 14), to pair with its existing blind row (43.5). Recreated the
worktree (`../choose-a-local-llm-run8` on branch `run8`, fresh off the
merged `master`) and `../mendel-benchmark`/`../mendel` are already up
to date from the close-out. Added item 14 to `AGENT.md`'s queue.
Started: worktree `../mendel-bench-guided-anthropic-claude-sonnet-4-5-high`
ready, pi started.
- Item 14 done. `claude-sonnet-4-5` guided (v3.0): score 88/100 — a big
  lift over the same model's 43.5 blind score, consistent with the
  guided prompt's purpose. Trap A HIT (critical):
  `apply-extra-options.js` calls `fs.promises.glob(...).then(...)` at
  three call sites, throws `TypeError: glob(...).then is not a
  function` (repro confirmed). Trap B fixed (`mendel-requirify` has
  zero `rimraf` refs left). Trap C avoided (no exit hook in
  `validate-manifest.js`). Chalk correct (plain `util.styleText`, no
  forced colour). All 16 commits `chore`-typed, one package each (two
  bundle the root `package.json` change with a package commit, allowed
  under the v3.0 criterion-5 note), no `--no-verify`/`git add -A`/
  TASKS.md leak. Root devDeps removed via real `pnpm remove` (verified,
  not just a lockfile-only edit). Lint clean, model self-ran
  `eslint`/`prettier` after its last change. Full suite clean
  standalone (674/674, 1 skip), same baseline as this model's blind
  run. `TASKS.md` textbook per-file, grouped by package, fully ticked
  and (unlike the blind sibling) the ticks matched reality. Test
  discipline docked: only 12 full-suite runs across 16 commits, short
  of guided v3.0's "before every commit" mandate. Truncation share
  72%, scored full marks — spot-checked as deliberate `| tail -N`
  noise reduction on the model's own output, same precedent as
  `glm-5p3-flash`'s guided row. Zero nudges, zero self-repair commits.
  Wall clock 32.2 min, cost $3.92 metered (`no plan involved` for this
  session's Anthropic login). Scored, CSV row appended this time (no
  repeat of the earlier session's omission), committed
  (`1200322` in `mendel-benchmark`), then a concurrent Mac push
  (`Ternary-Bonsai-27B` guided row) required a merge (`01de789`) —
  resolved a trivial JSON trailing-brace conflict and regenerated
  `report-guided.html` fresh rather than hand-merging the generated
  HTML. Pushed. Run branch
  `anthropic-claude-sonnet-4-5-high-guided-v3-issue-13` pushed too.
  **Found pre-existing uncommitted local changes** to
  `generate-report.mjs`, `report-template.html`,
  `report-guided-template.html`, and `report.html` in the
  `mendel-benchmark` worktree, unrelated to this item (they predate
  this session's work here) — stashed rather than committed or
  discarded (`git stash list` in `../mendel-benchmark`, entry "On
  benchmark: pre-existing uncommitted generate-report.mjs/template/
  report.html changes, unrelated to sonnet-guided scoring, left for
  the coordinator to review"). A future session should look at that
  stash and decide whether to commit or drop it.
- Mirrored item 14 into `benchmarks/mendel/` (site reports and CSVs;
  also picked up the concurrent `Ternary-Bonsai-27B` guided row from
  the merge), regenerated site tables, committed and pushed directly
  on `master` (`ab507c2`).
- Item 14 closing: `pkill -f "Mendel Daemon"` run (safe, this was the
  only in-flight item this session). Verified: no `pi --mode rpc` or
  `Mendel Daemon` process running; `git -C ../mendel worktree list`
  and `git -C ../mendel-benchmark worktree list` show no stray run
  worktrees.

## Handing over (second close)

Item 14 (`claude-sonnet-4-5` guided, 88/100) is done, scored, pushed,
and mirrored. This reopened run8 session is otherwise identical in
shape to the first close: no stray processes or worktrees, both repos
pushed. One open item for a future session: the stash left in
`../mendel-benchmark` (see above) needs review. `run8`'s history (this
file and `AGENT.md`) is about to be merged into `master` again and the
branch/worktree retired, per `AGENT.md`'s "Closing" section and this
repo's `AGENTS.md` stop-and-sync steps.

## Correction (2026-09-02, coordinator)

The item-5 note "xai login is not on a plan" was wrong. run-worker.sh
matched plan providers only on provider-prefixed model ids; bare-name
runs (grok-4.6, gpt-5.6-*) probed as `none` and were recorded as
metered. The worker patterns are fixed. The grok v1.1 row is corrected
to plan share (the run used the SuperGrok OAuth login; no xai API key
or credits exist). The codex v1.1/v3.0 rows (luna, sol) are still
recorded as metered and wait for the owner's estimator choice.

## Reopened, 2026-09-02 (third open — item 15, Opus)

User added item 15 to `AGENT.md`'s queue: `anthropic/claude-opus-5 pi
blind high`, the owner's one granted Opus run. Recreated the worktree
(`../choose-a-local-llm-run8` on branch `run8`, fresh off `master`).

- First attempt: started `run-worker.sh` with `nohup ... &` from a
  Bash tool call. The process was killed when the tool call's shell
  exited (no true detach in this sandbox); only 3 commits landed in
  the run worktree (`replace xtend with Object.assign` x2, `use
  crypto.randomUUID instead of uuid`) before it died silently, no
  score, no "done" line. Cleaned up: killed any leftover process,
  `git worktree remove --force`, deleted branch
  `anthropic-claude-opus-5-high-issue-13`. Lesson: always use the
  harness's `run_in_background` Bash mode for `run-worker.sh`, never
  bare `nohup ... &`, in this sandbox.
- Second attempt: relaunched with the harness's `run_in_background`
  Bash mode. The worker exited clean (code 0, `anthropic-claude-opus-5-high:
  done`) but the run itself failed immediately: `tooling_budget_exhausted`
  after all 10 tooling nudges, each caused by the same API error:
  `invalid_request_error — "Third-party apps now draw from your extra
  usage, not your plan limits. Add more at claude.ai/settings/usage
  and keep going."` Zero commits landed (`HEAD` stayed at the base
  commit `2652ed6`). This is an account/billing gate on the
  Anthropic side for pi (a third-party app) calling `claude-opus-5` —
  not a code or prompt problem. Cleaned up: `git worktree remove
  --force ../mendel-bench-anthropic-claude-opus-5-high`, deleted
  branch `anthropic-claude-opus-5-high-issue-13`.
- **Blocked.** Item 15 needs the owner to add "extra usage" budget at
  claude.ai/settings/usage (or otherwise clear the third-party-app
  gate) before a retry can work. Not attempting a third retry without
  that. Raw evidence left in `../mendel-benchmark`'s gitignored
  scratchpad: `scratchpad/benchmark/runs/anthropic-claude-opus-5-high-blind-*`
  (meta, session, events, logs) — transient, not committed, safe to
  discard once reviewed or once a successful retry supersedes them.
- No Mendel Daemon or stray Mendel worktrees left running. `run8`'s
  history (this file and `AGENT.md`) is about to be merged into
  `master` and the branch/worktree retired, per `AGENT.md`'s "Closing"
  section, since there is nothing further this session can do on item
  15. A future session resumes item 15 once the owner has cleared the
  usage gate; the run8 branch/worktree should be recreated fresh for
  that (per AGENT.md's ground rules), not resumed from here.
