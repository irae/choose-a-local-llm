# Score: bonsai2-27b-ptq1-f16-orca, blind v1.1, xhigh

Scored 2026-09-19 by Claude Fable 5.1 (subagent) from the evidence pack,
the session log and the branch diff. The model's own claims were not used.

- Row: Ternary Bonsai 2 27B PTQ1_0, f16 KV, xhigh, refusal-ablation LoRA
  at runtime (scale 1.0). Harness pi, bench blind, prompt v1.1, base tag
  `benchmark-blind-base` (2652ed6c).
- Branch: `bonsai2-27b-ptq1-f16-orca-xhigh-issue-13` in `~/code/mendel-benchmark`.
- Worktree: `/home/irae/code/mendel-bench-bonsai2-27b-ptq1-f16-orca-xhigh`.
- Evidence pack: `~/.local/share/mendel-benchmark/runs/bonsai2-27b-ptq1-f16-orca-xhigh-issue-13-evidence.json`
  (copy of the file `score.mjs` wrote under `scratchpad/benchmark/runs/`).
- Telemetry: 269 tool calls, 249 assistant messages, peak context 126798 of
  135168, 1 compaction (03:10Z), loop flag ok (ratio 0.23, thinking), wall
  1 h 22 min (02:37Z to 03:59Z), end reason `complete`, 0 tooling nudges,
  0 model nudges, 1 user message (the prompt only). Not assisted.

## Total: 75 / 100

Libraries done: 8/8 in the workspace. No completion cap applies.

| # | Criterion | Max | Points | Evidence |
| --- | --- | --: | --: | --- |
| 1 | Bugs remaining | 25 | 22 | One minor defect (weight 1): `pnpm-lock.yaml` is unchanged from the base (pack `lockfile.numstat: "no change"`) while nine `package.json` files lost specifiers. `pnpm install --frozen-lockfile` will reject the branch. No runtime bug: trap A passes with real work (pack `runtime_checks.trap_a: SYNC OK, pending= 1`; `apply-extra-options.js` wraps callback `fs.glob` in a Promise). Trap C avoided: `validate-manifest.js` keeps the debug manifest, no exit hook. Chalk contract for v1.1 correct: `chalk.level` line removed, plain `styleText`; my runtime check gives no ANSI when piped and ANSI under a pty for both `{enableColor:false}` and `{}`. Tap re-run on the worktree: mendel-core 71/72 (1 pre-existing skip), config 41/41, deps 27/27, development 42/42, extract-bundles 4/4, uglify 3/3, cli-printer 15/15, requirify 0/3 (baseline). 25 - 3 x 1 = 22. |
| 2 | Task completion | 20 | 16 | All 8 libraries replaced in `packages/*` and `examples/*`; root devDeps `rimraf` and `tmp` removed (pack `root_devdeps.removed: true`). Trap B missed: pack `static_completeness.stale_requires` lists `legacy-packages/mendel-requirify/test/mendel-requirify.js:9` and `test/requirify.js:5`, and `stale_package_json` lists `legacy-packages/mendel-requirify/package.json:26`. The model saw these hits (tool results 12 and 15 in the session) and wrote in TASKS.md "legacy-packages is NOT a workspace -> out of scope". The base `AGENTS.md` does not call legacy packages frozen; the prompt warned about missing references. |
| 3 | node_modules actually pruned | 8 | 0 | No `pnpm install`, `pnpm prune` or hand edit of the lockfile in the whole session (0 matches over 186 bash commands). Pack `lockfile.added: 0, removed: 0`. "No pnpm" = 0. |
| 4 | Prettier & ESLint clean | 5 | 5 | Pack `runtime_checks.prettier.ok: true`, `eslint.ok: true`. The model ran `pnpm prettier --write` and `pnpm eslint --fix` on its files before every commit (pack `session_habits.lint_self_runs: 12`); husky hooks also ran (no `--no-verify`). The `node:` prefix trap was not triggered; the branch uses bare `require('crypto')`. |
| 5 | Commit craft | 12 | 7 | Types: 13 `fix`, 2 `chore` (pack `commit_craft.non_chore` has 13 entries) -> 0/4. Split per package: 14 of 15; `05d1e40 fix: replace tmp with fs.mkdtempSync` touches three packages (pack `multi_package`) -> 3/4. No `--no-verify`, no `git add -A`, no TASKS.md leak (pack `no_verify: []`, `git_add_all: []`, `tasks_md_leak: []`; `git ls-tree` at the tip has no TASKS.md) -> 4/4. |
| 6 | Right the first time | 8 | 8 | No repair commits, no amends, no resets in the session log (14 `git commit` commands, 15 commits, the shasum step made two commits in one command). Model nudges 0 (pack `runner.nudges_model: 0`). Two `edit` calls failed on stale text (unix-socket.js, cli-printer.js) and were redone before the commit; not self-inflicted broken commits. The `node:` lint trap was not hit. |
| 7 | Test discipline | 10 | 9 | Narrow `pnpm --filter <pkg> test` after every change to a package with tests (config, core x2, pipeline x2, transform-less, development x3, deps, extract-bundles, uglify). Full suite after commits 5, 10 and 15 as the prompt says (pack `full_suite_runs: 6`; the extra three are grep re-runs of the same final suite). One point off: the commit-5 suite ran in the background with `nohup` and its result was read only after commit 7. |
| 8 | House conventions | 5 | 4 | Diff is 38 files, +101/-92 against the base, all inside the task. Matched `var`/`const` per file, matched multi-line `styleText` style, kept the fixture `browser.js` untouched. One point off: `fs.mkdtempSync(path.join(process.env.TMPDIR \|\| '/tmp', 'mendel-'))` repeated four times instead of `os.tmpdir()`; the `globFiles` Promise wrapper adds a helper where `Array.fromAsync(fs.promises.glob(..))` was the direct form. |
| 9 | Task list built progressively | 4 | 2.5 | TASKS.md written once after a full grep sweep (tool call 27): libraries plus every package sub-item upfront with line numbers. Ticks were per commit at first, but a Prettier reformat of the file made several ticks fail silently; six items were batch-checked at tool call 113 (after commit 7), and the `tmp` items were checked only after commit 15. "Upfront full tree, mostly faithful ticks" = 2.5. |
| 10 | Truncated noisy commands | 3 | 1.5 | Pack `session_habits.truncation_share: 48` (43 of 89 noisy commands piped to `tail`/`head`/`grep`). The full suite went to a file and was grepped; `cat TASKS.md` and several `git diff` calls ran raw. 3 x 0.48 = 1.5. |
| | **Sum** | **100** | **75** | 22 + 16 + 0 + 5 + 7 + 8 + 9 + 4 + 2.5 + 1.5 = 75. Checked. |

## Worst defect

Trap B missed: `legacy-packages/mendel-requirify` still requires `rimraf` in
two test files and declares it in its `package.json`. Severity: medium as a
task gap, scored under criterion 2 only (not a runtime bug; that suite fails
3/3 on every branch). It is an omission, so it has no authoring commit; it is
present at the branch tip `ffc14d0e`. The model saw the grep hits and chose
to exclude `legacy-packages/` as "not a workspace".

Worst criterion-1 bug: stale `pnpm-lock.yaml`, minor, present from the first
commit `b326f63e` through the tip `ffc14d0e`.

## Traps

- Trap A: not hit. `apply-extra-options.js` uses callback `fs.glob` wrapped
  in a Promise; the repro prints `SYNC OK, pending= 1`. The model probed
  `fs.promises.glob` in the session and found it returns an async generator
  before it wrote the replacement.
- Trap B: hit (see above).
- Trap C: not hit. `validate-manifest.js` has no exit hook. The three test
  files add `process.on('exit')` cleanup, which restores the cleanup `tmp`
  did for them.

## Commit facts

- 15 commits on the branch, all present in the session log; no provenance gap.
- Chore-typed commits: 2 (`d4e7b884`, `ffc14d0e`). Fix-typed: 13.
- Multi-package commits: 1 (`05d1e40a`).
- `--no-verify`: 0. `git add -A`: 0. TASKS.md never committed (ignored via
  `.git/info/exclude`).

## Notes for the row

- `telemetry.nudges_tooling` 0, `telemetry.nudges_model` 0,
  `telemetry.loop_flag` ok, `telemetry.loop_ratio` 0.23,
  `telemetry.loop_kind` thinking.
- The run was not assisted: the only user message is the prompt.
- Full-suite noise: `mendel-full-example:test` (karma) failed on a broken
  `node_modules/.bin/mendel` symlink dated before the first commit. The
  model checked the timestamp and correctly called it environmental.
- Not compared against the unablated run 24 row; scored on this evidence.
