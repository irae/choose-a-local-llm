# Run 7 state

Planned 2026-09-01. Mendel re-runs on the Mac: fresh blind v1.1 and
guided v3.0 rows for all local models through `run-pi-rpc.mjs`.
Runbook: `AGENT.md`. Note deviations here as they happen.

## Reporting format the owner wants (2026-09-02)

During an unattended overnight run, do not report the full run
status on every heartbeat tick — only when something changed
(finished, crashed, deviated). But when the owner asks for a status
check, or when writing the wake-up report for the next session, use
this shape:

- `TASKS.md` top-level count: done vs. total (e.g. "6 of 8 done").
- `TASKS.md` sub-task count for the finished top-level items (e.g.
  "21 of 21 sub-tasks complete").
- The current top-level item in progress (infer from the first
  unchecked `TASKS.md` line plus the latest event).
- Elapsed time: run start timestamp vs. now, in `Xh Ym` form.

Read `TASKS.md` from the run's worker worktree
(`../mendel-bench-<guided->-<model>-<thinking>/TASKS.md`), and the
`start` field plus the last line of
`scratchpad/benchmark/runs/<slug>-events.jsonl` for elapsed time.

Any future coordinator/planning agent for a Mendel run: use this
report shape when summarizing a run's progress.

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

- 11:51 local: block 2 run 1 ended on the runner's wall-clock hard stop
  (300 min), partial. 3/8 libraries done (uuid, xtend, urlsafe-base64),
  rimraf partially done but missed the mendel-requirify trap reference.
  One self-inflicted JSON syntax break in
  `mendel-transform-less/package.json` cost 4 commit attempts (~40
  min) before the model fixed it itself. Scored (score_total=55),
  committed+pushed to mendel benchmark (merged cleanly with run8's
  concurrent pushes, now at @97f4977). Worktree removed, server/watcher/
  daemon stopped and confirmed idle.

## Handing over — stopped here on request (2026-09-02, ~11:55 local)

Stopped at a clean boundary: block 2 run 1 is done, scored, and pushed.
**Nothing else was started.** To resume, pick up at block 2 run 2 per
`AGENT.md`:

1. `git -C ../mendel pull origin benchmark` first (other agents/run8
   have been pushing concurrently — expect commits past `97f4977`).
2. Serve: `mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit
   --prompt-cache-size 2 --port 8081`, warmup, restart the mem-watch
   watcher.
3. `./run-worker.sh prism-ml/Ternary-Bonsai-27B-mlx-2bit pi guided low`
   — **watch for the out-prefix collision bug**: this run's output
   files share the same name as run 1's (no bench-type suffix), so the
   raw runner.log/meta.json for run 1 will be overwritten (already
   scored and committed, so harmless, but don't rely on them after).
4. Then blind high, then guided high (block 2's remaining 2 runs).
5. Move to Block 3 (Gemma-12B, LM Studio), Block 4 (Qwen3.6-35B-A3B,
   llama-server), and Block 5 (Qwen3.8-27B-4bit guided xhigh, only if
   time remains) per `AGENT.md`.

Known open issues carried forward:
- mlx entries in `~/.pi/agent/models.json` can have `maxTokens` too
  close to `contextWindow` for models with a small window (hit
  Qwen3.8-27B-4bit hard in block 1); not fixed, just documented.
- `run-worker.sh` names guided and blind runs of the same thinking
  level identically — no fix applied yet.
- mlx_lm.server dead-thread crashes (Metal OOM, `/health` stays 200)
  are a recurring hazard; restart-and-resume per `server-lore.md` is
  the known mitigation, not a fix.

Local repo: worktrees clean (`git worktree list` shows only the main
worktree), no server/daemon/watcher running, mendel benchmark branch
pushed through `97f4977`. This repo's `run7` branch is being merged
into local `master` now (not pushed).

## Session 2026-09-02 — step 1 cleanup, then resume

- Step 1 cleanup done. Found `../mendel-benchmark` worktree missing
  (expected problem from AGENT.md); recreated with `git -C ../mendel
  worktree add ../mendel-benchmark benchmark`, pulled, now at `44a9980`
  (fast-forward from `97f4977`, brought in `run-worker.sh` and
  `score.mjs` changes from other agents). No other cleanup needed:
  both main worktrees already matched the desired state (`master`,
  clean, equal to origin), tags fetched and match origin, no stray
  worktrees, no stray processes.
- GPU confirmed idle (no `llama-server`/`mlx_lm`, `lms ps` empty),
  `iogpu.wired_limit_mb` = 24000.
- Owner note: DB may run today for a while, so reordering the queue —
  Block 2 (Bonsai) first, since it is already in progress, then Block
  1 does not apply (already scored/closed). Resuming at block 2 run 2
  per the hand-over above.
- `run7` worktree/branch created at `../choose-a-local-llm-run7`.
- 14:36 local: `mlx_lm.server` for `prism-ml/Ternary-Bonsai-27B-mlx-2bit`
  up, warmup OK. Memory watcher started, scoped
  (`/tmp/bonsai-run2-memwatch.log`).
- 14:51 local: the qwen3_coder tool-call parser crash from run 1
  recurred (JSONDecodeError on malformed tool-call args, per-request
  exception, server stayed up and kept serving). Same known cause, no
  action needed.
- 14:36 local: block 2 run 2 (guided low) started. Branch
  `prism-ml-Ternary-Bonsai-27B-mlx-2bit-low-guided-v3-issue-13`. The
  out-prefix collision bug from run 1 looks fixed by the
  `run-worker.sh` update pulled in with the worktree setup — this
  run's files carry a `-guided-` suffix
  (`prism-ml-Ternary-Bonsai-27B-mlx-2bit-low-guided-runner.log`), no
  longer colliding with the blind run's names.
- 20:20 local: block 2 run 2 (guided low), still running (~2h45m in).
  Model is looping on a self-authored path typo
  (`.../Ternary-Bonsai-2bit-low/...` — missing `27B-mlx-`), repeating
  the same failing `ls` command many times in a row. Harness/server
  fine throughout; not intervening (no human input goes into a run per
  AGENT.md). Watching tooling-nudge budget; if this loop burns it, the
  run will end `tooling_budget_exhausted` like block 1 and run 1.

- 22:37 local: block 2 run 2 (guided low) ended on the runner's
  wall-clock hard stop (300 min), partial. Scored: score_total=59,
  libraries_done=1 (uuid only). Deviation: the session log's only
  `thinking_level_change` event reads "high", though the worker was
  invoked with `--thinking low` — the flag was not honored; scored and
  reported as the observed level ("high"), noted in the row's
  `config_note`. No bugs found in the one landed commit; most of the
  score loss is incomplete work plus a self-authored path-typo loop
  (see above) that burned a large share of the run.
- Committed+pushed to mendel benchmark. Concurrent pushes from other
  agents (blind Haiku 4.5, guided Haiku 4.5, blind claude-sonnet-4-5)
  landed in between; merged cleanly (own row re-applied alongside
  theirs), pushed @1c1bb9f. Run branch
  `prism-ml-Ternary-Bonsai-27B-mlx-2bit-low-guided-v3-issue-13` pushed
  to origin per the 2026-08-31 policy (run branches are pushed now).
- Worker worktree removed, Mendel Daemon/server/memwatch confirmed
  stopped. Moving to block 2 run 3 (blind high).

## Block 4 — Qwen3.6-35B-A3B (llama-server)

- 23:10 local: server up (`llama-server -hf
  unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`, no MTP drafter flags
  per AGENT.md), loaded from local cache in <1s, no download. Warmup
  OK, memwatch running.
- 23:12 local: blind high started (`qwen3.6-35b-a3b-high-issue-13`).

- 00:29 local: block 4 run 1 (Qwen3.6-35B-A3B blind high) finished
  clean (`end_reason: complete`, 0 nudges). 8/8 libraries done, 13
  commits. Scored: score_total=61/100. Critical defect: trap A hit —
  `apply-extra-options.js` destructures `glob` from `require('fs')`
  (callback API, not `fs.promises`) then calls `.then()` on it,
  throwing at runtime. One self-inflicted trap-C near-miss (added an
  `fs.rmSync` exit-hook cleanup, same pattern trap C warns against)
  was caught and removed by the model two commits later — did not
  land in the final tree. All 13 commits typed `fix` not `chore`; one
  `git add -A`; root `package.json` still declares `tmp`.
- Committed+pushed to mendel benchmark. Concurrent pushes from other
  agents landed in between; merged cleanly, pushed @142d1a8. Run
  branch `qwen3.6-35b-a3b-high-issue-13` pushed to origin.
- Worker worktree removed, server/watcher/daemon confirmed stopped.
  Machine idle. Owner asked to hold — not starting the next block yet
  (block 4 run 2, guided high, is next in queue; Gemma-12B/LM Studio
  block 3 was requested to run after block 4).

## Coordinator recap (2026-09-03)

Written on `master` while block 4 (this section's log above) was
in flight, so it does not yet know block 4 run 1 finished. Kept for
the standing rules and Block 2 details it adds; the resume point is
superseded by the log above — block 4 run 1 (blind high) is done,
scored, and pushed, so the next step is block 4 run 2 (guided high).

Done so far in run 7 (all scored, pushed, merged), per the
coordinator's view at the time of writing:
- Block 1: Qwen3.8-27B-4bit low, blind (67.5, partial) and guided
  (34, partial). Both hit the small mlx context window.
- Bonsai mlx runs: blind (55, partial) and guided v3.0 (59, partial).
  BOTH ran at high — mlx did not honor the low flag; the rows are
  renamed/annotated. No more Bonsai runs on mlx.
- Qwen3.6-35B-A3B blind high: scored and pushed; the coordinator
  re-scored it on Fable (the row in `results.json` is the truth).

New standing rules since the last session (all in `AGENT.md` ground
rules and `AGENTS.md`): score in a Fable subagent only; never
download a model; never bare `git stash` (named stashes only); first
action is the run7 worktree (reuse `../choose-a-local-llm-run7` if it
exists with the `run7` branch, else create it fresh).

Pending item: the Qwen3.6-35B-A3B blind-high session log and meta
file were never committed into `benchmark/runs/` (the Fable re-score
found neither on the Linux box). Copy them from the Mac per PLAN.md
and list them in SESSIONS.md. This is Block 0 in the current
`AGENT.md` queue.

## Session — resuming per merged AGENT.md (Block 0 first)

Master's `AGENT.md` was consolidated 2026-09-03 with a new Block 0
(push everything missing) ahead of Block 1 (Qwen3.6 guided high).
Merged master into `run7` to pick up the queue and standing rules;
this session starts at Block 0 per the owner's instruction to check
in after Block 0 before continuing.

- 22:01 local: Step 1 machine check: all worktrees, tags, and
  `iogpu.wired_limit_mb` (24000) already match the desired state. No
  stray processes except one `llama-server` for `qwen3.6-35b-a3b`,
  idle (a leftover from the prior session's block 4 run 1) — left
  running since it is the exact model Block 1 needs next.
- 22:01 local: Block 0 done. Pulled `origin/benchmark` (already
  current). Found the missing qwen3.6-35b-a3b blind-high session log
  in this Mac's `scratchpad/benchmark/runs/`
  (`qwen3.6-35b-a3b-high-blind-session.jsonl`, session UUID
  `01a06462-b2b1-71c8-8ab4-761271e5e838`, no home-path leaks). Copied
  it to `benchmark/runs/qwen3.6-35b-a3b-high-issue-13-session.jsonl`,
  added a row to `runs/SESSIONS.md`. No meta file exists in the
  committed convention for pi runs (checked `SESSIONS.md` and
  existing rows — only session `.jsonl` files are committed; metas
  stay in `scratchpad/`, which is gitignored). Swept for other
  local-only artifacts: none found (`git status` clean, no commits
  ahead of `origin/benchmark`, no unpushed run branches). Committed
  and pushed to mendel benchmark @866348a.
- Checking in with the owner before starting Block 1 (Qwen3.6-35B-A3B
  guided high) per their instruction.
- Owner said continue the whole run overnight, unattended.

### Block 1 — Qwen3.6-35B-A3B guided high (llama-server)

- 22:03 local: server already up and healthy (left running idle from
  the prior session's block 4 run 1). Started scoped memwatch
  (`MEMWATCH_INTERVAL=20`, log `/tmp/run7-block1-memwatch.log`).
- 22:04 local: `./run-worker.sh qwen3.6-35b-a3b pi guided high`
  started in the background (branch
  `qwen3.6-35b-a3b-high-guided-v3-issue-13`, worktree
  `../mendel-bench-guided-qwen3.6-35b-a3b-high`). Verified
  `thinking_level: "high"` in the meta file and the session events —
  correct, matches the requested level.
- 23:35 local: run finished (`end_reason: complete`), 0 nudges,
  0 respawns, 1 compaction. 8/8 `TASKS.md` items done, all sub-items
  checked. 15 commits (16 counting the pre-existing lockfile-hash
  base commit) in the worker worktree, all typed `chore`/`refactor`.
  Ran `score.mjs` to build the evidence pack; dispatched a Fable
  subagent to apply the rubric per PLAN.md. Awaiting its result before
  committing the row to `results-guided.json`.
