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

## For `retry-sweep`: `sweep-bonsai-mlx` reads again

Coordinator gate (2026-09-13): `sweep-bonsai-mlx` closed with no
number at all, so both its cells go to `retry-sweep`, not moved up
the order. Read depth 4096 and depth 52224 (the deep cell, 1024 under
the 53248 window) in one benchy call, same server and command as
`sweep-bonsai-mlx`, and add the two rows to that block's table in
`results.md`.

## Server lore: MLX generation-thread death leaves the process alive

Finding (2026-09-13, `sweep-bonsai-mlx`): on `mlx_lm.server`, a Metal
OOM inside the generation thread kills that thread but not the
process. The HTTP endpoint never answers again, but `pgrep` still
shows the server running and CPU sits at 0%. A `Monitor` armed only on
process exit never fires on this failure. A 20-minute `ScheduleWakeup`
heartbeat checking server-log growth and process CPU caught it, about
an hour after the death. From here on, every MLX block keeps a
liveness heartbeat beside the process-exit monitor, not only the
exit-based one. This belongs in `docs/methodology/server-lore.md` at
close-out.

## `sweep-bonsai-fork-single` — blocked, skipped

The KV bias file `/tmp/Ternary-Bonsai-27B-kv-bias.gguf` does not
exist (`/tmp` is wiped on reboot, per the site's own note). The
snapshot `abbae72` and `~/prism-llama/llama-server` are both present.
Per the run's rule, a missing bias file is stop and ask, never a
rebuild on my own. Skipped; the run went on to `sweep-qwen38-bartowski`
to keep the GPU busy. Gate for the coordinator: regenerate the bias
file with the vendor's `make_kv_bias.sh` (the owner names the corpus,
since a regenerated file with an unrecorded corpus is a different
calibration than the scored one), or confirm the block is dropped for
this run.

Coordinator gate answer (2026-09-13): the bias file question is with
the owner now. `sweep-bonsai-fork-single` and `sweep-bonsai-fork-2slot`
stay skipped in `retry-sweep` until the owner answers.
`sweep-bonsai-fork-f16` needs no bias file (no `--kv-mean-center` in
its command), so it runs in their place in the order.

**Resolved.** The bias file is not lost: bench 11 (2026-09-06)
regenerated it with the vendor's `make_kv_bias.sh` and its own
corpus, at the persistent path `~/.local/share/choose-a-local-llm/
Ternary-Bonsai-27B-kv-bias.gguf` (nothing of a run goes under `/tmp`,
owner rule). The `/tmp` path in the runbook and the site command is
stale. Confirmed: 65K, modified 2026-09-06 23:32, sha256
`f61d1350643a0f1656f1312dc337758bd80c456c44390e82b071982f4da4ded9`.
Both q4_0 prism blocks (`sweep-bonsai-fork-single`,
`sweep-bonsai-fork-2slot`) run with `--kv-mean-center` pointing at
this path, everything else unchanged, out of `retry-sweep` and back
in the order, right after the block in progress.

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

**Scored.** Commit `fe692ec` on branch `benchmark`. Score 37.5 (raw
51.5, capped at 3/8 done), against the first row's 25. This row
replaces `f3d064a` in the live results, marked `best_of: 2`, no
reruns penalty (benchmark-failed retry rule). Valid partial:
`model_budget_exhausted`, not a loop. Peak context 31118 (84% of
36864), tool_calls 63, compactions 1, wall 18.5 min.

**Blocked, for the owner.** The subagent could not push the reused
branch `mlx-community-Qwen3.6-35B-A3B-4bit-on-issue-13` to
`origin`, because the remote still holds the first run's tip and the
push needs `--force-with-lease`. I tried it myself after confirming
the first run's tip is safe on `origin/…-issue-13-stashpop`; my own
session's permission classifier denied it too ("Git Destructive").
The local branch and its commits are intact; only the push to
`origin` is missing. The owner needs to run this by hand or grant the
permission:
`cd ~/code/mendel-benchmark && git push --force-with-lease origin mlx-community-Qwen3.6-35B-A3B-4bit-on-issue-13`.
(Done: the owner ran this by hand; the branch is on `origin` at commit
`a6f5c9b`.)

## Handing over, session 1, 2026-09-13

Owner order: the run ends after the homepage cells. Every block from
`benchy-qwen38-atomicchat-drafter` through the `sweep-bonsai-mlx`
retry ran; nothing after that in the order list ran
(`sweep-bonsai-fork-2slot`, `sweep-qwen36-q8`, and the rest of the
`sweep-*` blocks are not started).

What ran, in order: `benchy-qwen38-atomicchat-drafter`,
`benchy-gemma26-drafter`, `sweep-qwen36-mlx` (dead deep cell),
`sweep-gemma26-mlx`, `qwen36-mlx-smoke-on` (pass), `qwen36-mlx-mendel-blind-on`
(scored 25, then re-scored 37.5 on retry after a shared-stash-stack
fault, `best_of: 2`), `gemma26-mlx-smoke-high` (fail, no blind row),
`arms-qwen38-atomicchat`, `arms-gemma26` (climbed to n-max 3),
`sweep-qwen38-ista-nodrafter`, `sweep-gemma12-f16`, `sweep-bonsai-mlx`
(dead cell, retried once more, dead again), `sweep-qwen38-mlx`,
`sweep-bonsai-fork-single`, `sweep-qwen38-bartowski`, then the
`retry-sweep` cells: `sweep-qwen36-mlx` at depth 35840 (clean) and
`sweep-bonsai-mlx` at depths 4096/52224 (dead again).

What a gate dropped and why:
- `qwen36-mlx-mendel-blind-on-retry`'s branch collision needed a
  rename, not a delete, because this session's own permission
  classifier denies destructive git operations (branch delete,
  force-push). The rename worked; the retry's own branch still
  needed a force-push, which the owner ran by hand.
- `gemma26-mlx-mendel-blind-high` never ran: its smoke failed on a
  truncated tool-call parse, not a server death.
- `sweep-bonsai-fork-single` was briefly blocked on a missing KV bias
  file at a stale `/tmp` path; the owner pointed to the real,
  persistent path and the block ran clean.
- `sweep-bonsai-mlx` died twice, at two different depths (56320 and
  52224), both past roughly 47-49K on this machine, well under its
  53248 window. The 4096 cell's number was lost both times, since
  `llama-benchy` writes `--save-result` once, at the end of the whole
  run, not per depth.

Server lore for `docs/methodology/server-lore.md`: on `mlx_lm.server`,
a Metal OOM kills the generation thread but not the process; the HTTP
endpoint never answers again, but `pgrep` and `/health` still show it
alive. A `Monitor` armed only on process exit never fires. The first
time this happened (`sweep-bonsai-mlx`, first attempt) it went
undetected for about an hour, caught only by a 20-minute
`ScheduleWakeup` heartbeat checking log growth and process CPU. From
then on, every MLX block ran a live watch on the server log (grepping
for the Metal OOM signature) alongside the process-exit monitor; the
second `sweep-bonsai-mlx` death was caught within seconds.

Machine state left behind: no `llama-server`, no `mlx_lm`, no
`llama-benchy`, no `http.server` process. Wired 1855 MB (recovered to
baseline). Wired limit 25000, unchanged. LM Studio not started, not
touched. `~/.pi/agent/models.json` has the two new MLX entries
(`mlx-community/Qwen3.6-35B-A3B-4bit` window 36864,
`mlx-community/gemma-4-26b-a4b-it-4bit` window 65536), both with the
`qwen-chat-template` thinking map copied from their `llama` provider
siblings. The `mendel-benchmark` repo's shared stash stack was
cleared once (recorded before clearing) per the owner-confirmed new
essentials rule.

Gates left for the coordinator at close-out: name the served arm of
every drafter row (six benchy blocks plus their arms), take the
daggers off in `models.json`, weigh the `sweep-bonsai-mlx` ceiling
finding (roughly 47-49K, well under the current 53248 window) when
next revisiting that model's MLX window, and decide whether either
q4_0 bonsai-fork block still needs the retired `/tmp` path fixed at
its source in `docs/setups/m1-max-32gb/reports/bonsai-27b.md`.

Evidence archived: `tools/archive-evidence.sh
hardware/m1-max-32gb/benchmarks/bench16/results run16`.
