# Run 8 — report

The large form of the run's status line. See
`docs/methodology/status-lines.md`, "The site comparison, in full", for
the table rules. This run scored cloud reference models only, no
local GPU work — the Quality and Speed and context tables have no
rows and are left out.

Mendel:

| old/new | test | model | serving | score | worst defect |
|---|---|---|---|--:|---|
| old | blind | kimi-k3 | pi | 80.5/100 8/8 | — |
| new | blind | kimi-k3 | pi | **93.5/100** 8/8 | — |
| old | blind | deepseek-v4-pro-0813 | pi | 70.5/100 8/8 | — |
| new | blind | deepseek-v4-pro-0813 | pi | **79/100** 8/8 | — |
| old | blind | grok-4.6 | pi | 89.5/100 8/8 | — |
| new | blind | grok-4.6 | pi | **92.5/100** 8/8 | — |
| old | blind | gpt-5.6-sol | pi | 65.5/100 8/8 | — |
| new | blind | gpt-5.6-sol | pi | **92/100** 8/8 | — |
| old | blind | claude-haiku-4.5 | pi | 49.5/100 8/8 | — |
| new | blind | claude-haiku-4.5 | pi | **34/100** 6/8 | trap A (`fs.promises.glob()` AsyncIterator) |
| old | blind | claude-opus-5 | pi | 87/100 8/8 | — |
| new | blind | claude-opus-5 | pi | **90.5/100** 8/8 | — |
| new | blind | deepseek-v4-flash-0731 | pi | 84.5/100 8/8 | — |
| new | blind | glm-5p3-flash | pi | 75/100 8/8 | — |
| new | blind | Claude Sonnet 4.5 (new version tag) | pi | 43.5/100 6/8 | trap A (`fs.promises.glob()` AsyncIterator) |
| old | guided | claude-haiku-4.5 | pi | 68/100 8/8 | — |
| new | guided | Claude Haiku 4.5 | pi | **76/100** 8/8 | — |
| new | guided | deepseek-v4-flash-0731 | pi | 97/100 8/8 | — |
| new | guided | gpt-5.6-luna | pi | 88.5/100 8/8 | — |
| new | guided | glm-5p3-flash | pi | **98/100** 8/8 | — |

- **claude-haiku-4.5 and Claude Sonnet 4.5 scored below their
  reputation.** Both hit trap A (the `fs.promises.glob()` AsyncIterator
  trap) on their blind runs, and neither removed the root `rimraf`/
  `tmp` dev dependencies at all. Both used `refactor`/`fix` commit
  types instead of the house `chore` convention. claude-haiku-4.5's
  guided run (76) shows the usual guided lift over its blind run (34),
  the same pattern other weak and local models show in this project's
  Mendel history.
- **glm-5p3-flash's guided run (98) is the strongest score of this
  run.** All three traps handled correctly, including trap C avoided
  by design: the model's own task list reasoned through the issue's
  wrong claim about `tmp` and chose not to add a buggy exit hook.
- **Up to two runs went in parallel, never two on the same account.**
  A shared Mendel worktree caused one commit-mixing incident: the
  claude-opus-5 blind row landed inside a concurrent peer commit
  (`c9e1476`) together with unrelated work. The row content is
  correct and pushed; only the commit message and pairing are messy.
  Flagged for a ground-rule follow-up.
- **The site mirror refreshed to match** (`benchmarks/mendel/`); see
  `docs/methodology/mendel.md` for how the blind and guided tests
  differ.
- **Open item carried from this run**: a stash in the Mendel worktree
  (`generate-report.mjs` and template changes, pre-existing, unrelated
  to any scored run) is still unreviewed.
- **Claude Sonnet 4.5 carries a different version tag** than an earlier
  row already on the site (`claude-sonnet-5`, unaffected by this run),
  so it is shown here as a new row, not a replacement.
- **Mendel score cells now carry the libraries done.** Every old row's
  count is inferred as `8/8`: the pre-run mirror did not yet track a
  libraries-done column, but every one of these old rows is a complete
  (non-partial) run, and a complete run always covers all 8 libraries
  in this rubric.
