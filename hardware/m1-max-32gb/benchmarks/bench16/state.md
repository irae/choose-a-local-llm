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
| `qwen36_mlx_on` | scored, commit `f3d064a` on branch `benchmark` in `irae/mendel`, score 25 (raw 58.5), valid partial with an anomaly (a shared-stash-stack fault closed the run early) | `qwen36-mlx-mendel-blind-on` |
| `gemma26_mlx_high` | not run — `gemma26-mlx-smoke-high` failed | `gemma26-mlx-mendel-blind-high` |

## `qwen36-mlx-mendel-blind-on` — shared stash stack, for the owner

Coordinator gate (2026-09-12): the row stands as a valid partial with
its anomaly. No re-run now. A re-run goes to `retry-sweep` only after
the owner clears the shared stash stack in `~/code/mendel-benchmark`,
since dropping a stash is destructive and only the owner's call.
`git stash list` in that repo, read for the record, not touched:

```
stash@{0}: WIP on luna-5.6-max-issue-13: 7fd646a fix(mendel-requirify): preserve test assertion count
stash@{1}: WIP on grok-4.6-issue-13: 9c721ca chore(mendel-outlet-manifest): replace shasum with crypto.createHash
stash@{2}: WIP on deepseekv4-pro-0813-issue-13: 4b2ac6a chore: drop tmp devDependency from root
stash@{3}: WIP on gemma-4-26b-a4b-issue-13: 60b93f8 refactor: remove rimraf from root and mendel-pipeline
```

The uncommitted `choose-a-local-llm/benchmarks/mendel/report.html` and
`results.csv` in the Mac's `master` checkout stay as they are; the
coordinator mirrors them at close-out.

## `git stash clear`, before `qwen36-mlx-mendel-blind-on-retry`

New essentials rule (owner, 2026-09-12): `git stash clear` in
`~/code/mendel-benchmark` right before every smoke and every agent
row. The owner confirmed this directly (asked, since it destroys
other sessions' stashes with no way back). `git stash list` recorded
right before the clear, same four entries as above:

```
stash@{0}: WIP on luna-5.6-max-issue-13: 7fd646a fix(mendel-requirify): preserve test assertion count
stash@{1}: WIP on grok-4.6-issue-13: 9c721ca chore(mendel-outlet-manifest): replace shasum with crypto.createHash
stash@{2}: WIP on deepseekv4-pro-0813-issue-13: 4b2ac6a chore: drop tmp devDependency from root
stash@{3}: WIP on gemma-4-26b-a4b-issue-13: 60b93f8 refactor: remove rimraf from root and mendel-pipeline
```

Cleared with `git stash clear` right after this record.

## `qwen36-mlx-mendel-blind-on-retry` — blocked, skipped

The scored row's worktree was moved aside (not deleted) to
`~/code/mendel-bench-mlx-community-Qwen3.6-35B-A3B-4bit-on-scored-20260912`,
and `git worktree prune` cleared its stale registration. `run-worker.sh`
still refuses: the branch
`mlx-community-Qwen3.6-35B-A3B-4bit-on-issue-13` exists, and
`git branch -D` on it was denied by the Mac's own permission
classifier ("Irreversible Local Destruction"), which this session
cannot override. Per the run's rule, a blocked block is skipped and
logged, not a reason to idle the GPU: this block is skipped, and the
run went on to `arms-gemma26`. The branch delete needs the owner's
own permission setting, or a run-worker.sh change to accept a
`-retry` suffix. Gate for the coordinator.

**Resolved.** Coordinator gate answer: rename, not delete, keeping
the first row's evidence. `git branch -m
mlx-community-Qwen3.6-35B-A3B-4bit-on-issue-13
mlx-community-Qwen3.6-35B-A3B-4bit-on-issue-13-stashpop` in
`~/code/mendel-benchmark` succeeded, no permission refusal. The
retry runs right after `arms-gemma26` closes.

## `qwen36-mlx-mendel-blind-on-retry`

Same server as `qwen36-mlx-mendel-blind-on`, window 36864, fresh
worktree and branch (`mlx-community-Qwen3.6-35B-A3B-4bit-on-issue-13`,
re-created after the rename cleared the collision). Started
04:42:31Z, ended 05:01:02Z. `worker.json`: loop ok (ratio 0.65, tool
call). `meta.json`: `end_reason` `model_budget_exhausted`, 1
compaction, 3 model nudges ("model stopped; TASKS.md has unchecked
items"). Not a repetition loop; the model kept stopping short of
finishing until the run's model-nudge budget (3) ran out.

Handed to a subagent for scoring and publishing, same rule as the
first row. `qwen36_mlx_on` stays at the first row's value until the
subagent's report updates it.
