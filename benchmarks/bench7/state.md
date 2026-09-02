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

- 02:10 local: server crashed mid guided-low run — dead-thread trap
  (`RuntimeError: [METAL] Command buffer execution failed: Insufficient
  Memory`), `/health` still returned 200. Killed and restarted
  `mlx_lm.server` per server-lore.md; the hung request errored and the
  harness resumed the same session (server log shows a fresh prompt
  request right after restart). Not a model-authored fault.

- 02:53 local: second server crash, same dead-thread trap (Metal OOM),
  now at 8/10 tooling nudges. Server prompt had grown past its own
  26624-token window (29639 tokens seen). Restarted the server again;
  resumed. If this run reaches `tooling_budget_exhausted` it will score
  as partial like the blind row; the harness's fixed 26624 window for
  this mlx entry is the recurring root cause, not the model.

- 03:35 local: third server crash (same dead-thread trap), right as
  guided low reached 10/10 tooling nudges. Restarted the server so the
  hung request could resolve and the run could finalize.

- 06:42 local: guided low scored (partial, tooling_budget_exhausted,
  three mlx server crashes, zero commits, libraries_done=0,
  score_total=34). run8 (Linux/API queue) pushed a deepseek-v4-flash
  guided row to mendel benchmark concurrently; merged cleanly (own row
  re-applied on top of theirs) and pushed @8460cc6.
- Block 1 closed. Cleaning worktree, moving to Block 2
  (Ternary-Bonsai-27B-mlx-2bit, four runs).

### Block 2 — Ternary-Bonsai-27B-mlx-2bit

- 03:49 local: server up, warmup OK, memwatch restarted.
- 03:50 local: run 1 (blind low) started.

- 09:26-09:31 UTC: block 2 run 1 hit 3 tooling nudges ("Stream ended
  without finish_reason") caused by a tool-call parser crash in
  mlx-lm's qwen3_coder parser (JSONDecodeError on malformed tool-call
  args) — matches the previously-documented failure for this exact
  model (see SESSIONS.md blind-runs note on the first Bonsai attempt).
  Per-request exception, not a server crash; server stayed up and kept
  serving. No restart needed.
