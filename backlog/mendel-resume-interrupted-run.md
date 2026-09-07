# Resume an interrupted Mendel run in place

Status: pending owner review. Filed 2026-09-07 at the owner's request
(design decision: no cleanup mid-run, recover killed runs).
Needs hardware: no for the tool; one interrupted run on the Mac to
prove it.

## The gap

`run-worker.sh` builds a fresh worktree and branch per run and aborts
when the branch exists, so a run that something else ended (a memory
kill, a server death, an operator stop) can only start over. Run 11
block 5 lost an 8/8 attempt this way, and its retry died the same
way. The pieces of a resume exist: `run-pi-rpc.mjs` respawns pi on the
same session file and takes `--session`; the worktree and branch
survive a process kill; `PLAN.md` scores a row across more than one
session. The design rule since 2026-09-07 keeps every artifact of an
interrupted run in place (`PLAN.md`, "Cleanup").

## The ask

- `run-worker.sh --resume <slug>`: reuse the existing worktree and
  branch, read the previous session file path from the run's
  `meta.json`, rebuild the pinned config dir the same way (a newer
  kit may change it, that is the point), and start `run-pi-rpc.mjs`
  with `--session <file>` and an `--out` prefix with a `-resume<n>`
  suffix, so the first attempt's events and meta stay intact.
- The runner, on `--session`, counts the elapsed wall clock of the
  earlier sessions toward `--wall-min`, and records `resumed_from` in
  the meta file.
- Scoring: `count-tool-calls.mjs` and the report take the row's
  sessions as a list; `peak_context`, `tool_calls` and the wall clock
  aggregate over them the way `PLAN.md` already describes for
  multi-session rows. The row's config note says "resumed after
  <cause> at <minute>".
- Worker cleanup: the pinned config dir and the worktree are removed
  only by an explicit `run-worker.sh --close <slug>`, run after the
  row is scored; the plain run never removes anything.

## Out of scope

Resuming across a base-commit change or a prompt version change: that
is a new row.
