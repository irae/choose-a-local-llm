# Mendel's 300-minute wall clock cap is documented but never enforced

Found in run 11, block 8 (Bonsai fork, guided, thinking high).

## What happened

Every run's `meta.json` policy block records `wall_min: 300` — a
5-hour wall-clock cap that `PLAN.md`'s `end_reason` list names as
`wall_clock`, with the report generator even carrying a label for it
("hit the 300 min time budget", `generate-report.mjs:213`).

But `wall_min` is never read back and enforced anywhere in the code.
A search across `mendel-benchmark/benchmark/*.mjs` for `wall_min` or
`wallMin` finds it written into `meta.json` and nowhere else — not in
`run-pi-rpc.mjs`, which is the process that would need to check
elapsed time against the policy and stop the run.

Block 8 ran to 469 minutes (nearly 8 hours) before a person caught it
and stopped it by hand. Nothing in the harness would have stopped it
on its own.

## Why this matters

Every block's "up to 5 hours" expectation in the run11 runbook
assumes the 300-minute cap is real. It is not. A slow model (this
fork decodes under 8 tok/s past ~33K depth, a documented, expected
behavior) can run indefinitely, consuming GPU time the run schedule
did not budget for, and blocking every block behind it.

## What was done this time

Caught by hand at 469 min. Scored as a capped `wall_clock`-equivalent
run: the session log was truncated to the first 300 minutes, the
worktree was reset to its last commit before the 300-minute mark (no
commits were lost — all three landed well before the cutoff), and
`peak_context`/`tool_calls` were recomputed from the truncated
session only, so the row is directly comparable to a real
`wall_clock` end reason.

## Ask

- Add the actual enforcement: `run-pi-rpc.mjs` should compare elapsed
  wall time against `policy.wall_min` on each turn boundary (the same
  place `turn_min` and the nudge budgets are already checked) and end
  the run with `end_reason: "wall_clock"` when it is exceeded.
- Until fixed, a human watching a long block should treat 300 minutes
  as the real cap and stop the run by hand, the way this session did.

Evidence: this conversation, run 11, block 8, 2026-09-07, run started
02:35:58Z, caught and stopped at 469 minutes elapsed (07:44Z).
