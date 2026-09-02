# Run 7 state

Planned 2026-09-01. Mendel re-runs on the Mac: fresh blind v1.1 and
guided v3.0 rows for all local models through `run-pi-rpc.mjs`.
Runbook: `AGENT.md`. Note deviations here as they happen.

## Run log

### Block 1 — Qwen3.8-27B-4bit, effort low

- 21:24 local: server up, warmup OK.
- 21:25 local: blind low run started (`mlx-community-Qwen3.8-27B-4bit-low`).
- 22:24-22:28 local: three tooling nudges in a row, each a premature length
  stop at 1 output token (budget 16384). No death signature in the server
  log. `contextWindow` (26624) is unverified for mlx_lm.server per PLAN.md;
  prompt tokens had grown to ~20318 at the time, leaving little of the
  26624 window for a 16384-token completion — likely cause. Tooling
  nudges are never scored; watching the tooling-nudge budget (max 10) in
  case the run ends `tooling_budget_exhausted`.

- 01:51 local: blind low scored (partial, tooling_budget_exhausted,
  libraries_done=1, score_total=67.5). Committed+pushed to mendel
  benchmark @6394cf7. Worktree cleaned, Mendel Daemon killed.
- 01:53 local: guided low started, same server.

- 01:53 local: guided low failed immediately: `fatal: invalid reference:
  guided-v3-base` — tag existed on origin but not fetched locally.
  Fixed with `git fetch origin --tags`. Restarting guided low.

- 02:20 local: found run-worker.sh names guided-low's output files
  identically to blind-low's (`runs/mlx-community-Qwen3.8-27B-4bit-low-*`,
  no bench-type suffix) — the guided run overwrote the blind run's raw
  `runner.log`/`meta.json`/etc. No data lost: the blind row was already
  scored, and its committed artifact (the redacted, `-issue-13-`-suffixed
  session copy) has a distinct name. Deviation only; harness bug worth a
  fix later (not touched now, mid-queue).
