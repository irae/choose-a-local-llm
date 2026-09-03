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
  subagent to apply the rubric per PLAN.md.
- 23:41 local: Fable scored it 83/100 (blind pair was 63). Trap A
  caught: `apply-extra-options.js` calls `.then()` on
  `fs.promises.glob()`, which returns an AsyncIterator, not a
  Promise — runtime TypeError on any bundle with ignore/exclude
  globs. Minor: 5/16 commits typed `refactor` not `chore`; some
  style drift (mixed `node:` prefix, extra test teardowns, a
  drive-by comment). Copied+redacted the session log to
  `benchmark/runs/qwen3.6-35b-a3b-high-guided-v3-issue-13-session.jsonl`,
  added it to `SESSIONS.md`, appended the row to
  `results-guided.json`, regenerated `report-guided.html`. Committed
  and pushed to mendel benchmark @4ac03c3. Pushed the run branch
  `qwen3.6-35b-a3b-high-guided-v3-issue-13` to origin (2026-08-31
  policy: run branches are pushed).
- Cleanup: killed `Mendel Daemon`, `llama-server`, the memwatch;
  confirmed all stopped. Removed the worker worktree
  `../mendel-bench-guided-qwen3.6-35b-a3b-high`. Machine idle.
- Queue item #2 done. Moving to item #3 (Qwen3.6-35B-A3B dagger
  sweep) before item #4 (Bonsai mlx dagger sweep) and item #5
  (Bonsai-PrismML blind low).

### Item #3 — Qwen3.6-35B-A3B dagger sweep — BLOCKED, deferred

- 23:44-23:52 local: served the exact daggered-row config from
  `docs/setups/m1-max-32gb/models.json` (`qwen36-gguf-think`:
  `llama-server ... --spec-type draft-mtp --spec-draft-n-max 3 -c
  98304 ... --cache-type-k q8_0 --cache-type-v q8_0`) at the current
  wired limit (24000, confirmed). Load succeeded (~25 GB wired,
  matches the model's known footprint) but every warmup completion
  request failed with a Metal `kIOGPUCommandBufferCallbackErrorOutOfMemory`
  ("Compute error", `/health` still returned `ok` — the known
  dead-but-alive pattern from `server-lore.md`). Killed, waited for
  memory to settle, restarted once (retry budget from PLAN.md): same
  failure, consistent, not transient.
- This is the exact boundary case `docs/methodology/memory-ceiling.md`
  warns about: "At ~24000 MB and above, physical RAM binds first...
  the crash point stops responding to sysctl changes, and the machine
  locks up." The report's own MTP config previously fit at 22.9 GB
  RSS under this limit (`reports/qwen3.6-35b-a3b.md`, "Context ramp"
  table) — something shifted since (system memory state, or the
  report's number predates a `wired_limit_mb` change). Not
  investigating further unattended: repeated OOM retries at this
  regime risk a full system lockup per the doc's own warning, and
  this is a non-priority sweep, not a Mendel run.
- Stopped retrying. Killed the server, confirmed memory recovered
  (2.8 GB unused, back to idle baseline) and the GPU is idle. **Not**
  an owner-only stop condition (no unexplained commit, no missing
  model, no credit exhaustion) — just deferring this item rather than
  risking the machine. Owner should decide: lower `-c` for this sweep
  specifically (deviates from the exact daggered config), raise the
  wired limit for a dedicated sweep session, or investigate why this
  config no longer fits.
- Per AGENT.md, "Mendel runs keep priority: sweeps fill the gap...
  never delay a Mendel run." Skipping item #4 (Bonsai mlx dagger
  sweep, same OOM-probing risk profile) for the same reason, and
  moving straight to item #5 (Bonsai-PrismML blind low) — the next
  Mendel run in the reordered queue. Made a small tooling change
  along the way: added a `STEP_PAUSE_S`-controlled 25 s pause between
  depth steps in `tools/sweeps/llama_sweep.py`, per the "creep
  slowly" rule in `context-creep.md` (the script had no pause
  before).

### Item #5 — Bonsai-PrismML blind low — STOPPED early (thinking level wrong)

- 23:49-23:52 local: no pi model entry existed yet for `bonsai-prism`
  — added one to `~/.pi/agent/models.json` (provider `llama`,
  `contextWindow: 65536` matching `-c 65536`, `thinkingLevelMap` with
  only `off`/`high` mapped — copied the shape of the existing
  `prism-ml/Ternary-Bonsai-27B-mlx-2bit` entry, since the report page
  for this model only documents a binary "thinking on"/"thinking
  off" toggle, no graduated low/medium/high; there is no evidence
  this architecture supports graduated reasoning effort at all).
- Served the exact `bonsai-prism` config from
  `docs/setups/m1-max-32gb/reports/bonsai-27b.md` #3 (PrismML fork,
  `-c 65536`, q4_0 KV + calibration bias). Warmup OK. Started
  `./run-worker.sh bonsai-prism pi blind low`.
- Checked the meta file within seconds of start per AGENT.md's
  mandatory check: `"thinking": "low"` (requested) but
  `"thinking_level": "high"` (applied) — the low flag was not
  honored, same failure as the earlier mlx Bonsai runs. Because the
  `thinkingLevelMap` I just added has `"low": null` (mirroring the
  mlx entry, which has the same gap), this is a deterministic,
  structural limitation of this model on this harness, not a flaky
  one-off — retrying the identical config would reproduce the same
  result every time, so no retry attempted.
- Per AGENT.md's explicit rule for this block ("If the level is
  wrong, stop the run at once... do not burn wall clock on a wrong
  config"), stopped the run immediately (a few seconds in, before any
  commits). Killed the worker process, removed the worker worktree
  and its branch (nothing to keep — zero commits landed). Server and
  memwatch still up (same model, about to reuse for the next
  attempt).
- Decision: item #6 (Bonsai-PrismML guided low) would hit the exact
  same structural block — same model, same `thinkingLevelMap` lookup
  — so skipping it too rather than repeating a known-dead attempt.
  Bonsai-PrismML "low" appears unsupported end to end on this
  harness/model pair; only items #11/#12 (blind/guided **high**) are
  reachable for this backend. Moving to item #7 (Gemma-12B blind
  high) — the next reachable Mendel run in the reordered queue.
  Owner should decide later whether "low" for this model needs a
  different mechanism (e.g. a prompt-level reasoning-effort
  instruction instead of the harness's thinking-level plumbing) or is
  simply not offered by this build.
- Stopped the Bonsai server and memwatch (Gemma-12B is a different
  serving stack, LM Studio).

### Item #7 — Gemma-12B blind high (LM Studio)

- 23:52 local: `lms load google/gemma-4-12b --parallel 4 --gpu max
  -y` succeeded, verified with `lms ps` (IDLE, 6.77 GB, context
  158464, parallel 4). Deviation: the LM Studio API server itself was
  not running (`lms server status` → not running) even with the
  model loaded — `lms load` does not imply the server is up. Started
  it with `lms server start --port 1234`. Warmup request OK.
- Started scoped memwatch. Launched
  `./run-worker.sh google/gemma-4-12b pi blind high`. Verified
  `thinking_level: "high"` matches the request — correct.
- First attempt failed fast: `end_reason: bad_config` — the pi model
  entry's `contextWindow: 262144` (the trained max) did not match the
  server's actual loaded context (158464, per LM Studio's own
  `/api/v0/models`, since `--parallel 4` splits the window). Per
  AGENT.md, fixed the entry instead of bypassing the check: set
  `contextWindow: 158464` and added the missing `maxTokens: 16384`.
  Removed the aborted worktree/branch (no commits, nothing lost).
  Relaunched; this time no `end_reason` at start (running normally),
  `thinking_level: "high"` confirmed correct.
- 00:45 local: run finished, `end_reason: model_budget_exhausted`,
  **0 commits landed**, `TASKS.md` entirely unchecked (0/8). 3 model
  nudges, each hitting the 16384-token output budget
  (`stop_reason: "length"`) before finishing a turn. Built the
  evidence pack (`score.mjs`); dispatched a Fable subagent to score
  the partial. Started item #8 (Gemma-12B guided high) on the same
  server while scoring runs in parallel — no GPU conflict, scoring
  doesn't touch the GPU. Item #8 running cleanly, `thinking_level:
  "high"` confirmed. Watchdog running for item #8 too.
- 00:52 local: Fable scored item #7 at 30.5/100 (partial). Diagnosis:
  15 tool calls of orientation in the first 23 min, then a failed
  exact-match `edit`, then every later turn collapsed into ~16K
  tokens of newline characters with a stray `<|channel|>` token in
  the thinking channel until the 16384-token output cap — a
  generation collapse, not excessive reasoning. All 3 nudges
  reproduced it. Copied+redacted the session log, added it to
  `SESSIONS.md`, appended the row to `results.json`, regenerated
  `report.html` (note: the second `generate-report.mjs` arg,
  `docs/superpowers/issue13-model-bakeoff.html`, does not exist in
  this worktree — ran with only the first arg). Committed and pushed
  to mendel benchmark @e9bf680. Removed the worktree and branch (0
  commits, nothing to keep).
- Item #8 (Gemma-12B guided high) still running, server healthy.
- 01:32 local: item #8 finished, identical failure signature to item
  #7: `model_budget_exhausted`, 0 commits, `TASKS.md` 0/8, 3 model
  nudges. Ran `score.mjs` for the evidence pack — it crashed:
  `TypeError: c.includes is not a function` at the session-habits
  step. Root cause: the model emitted a malformed `bash` tool call
  with `command: 3` (an integer, not a string) at two points in the
  session — part of the same generation-collapse pattern. Fixed
  `score.mjs` defensively (only push string commands into the
  habits list, at both the `toolCall` and `tool_use` push sites) —
  matches the checklist's "suspect the harness before the model"
  rule; a scoring tool should tolerate garbage tool-call arguments,
  not crash on them. Evidence pack built cleanly after the fix.
  Dispatched a Fable subagent to score item #8 independently (not
  copying item #7's row — instructed to read this run's own session
  log).
- While scoring ran, started item #9 (Gemma-12B guided low) — worth
  trying since less requested reasoning might avoid the collapse
  seen at high. Cleaned up item #8's worktree/branch first (0
  commits, nothing to keep). Verified `thinking_level: "low"` matches
  the request — **this model DOES honor low** (unlike Bonsai-PrismML
  — a real graduated reasoning-effort model, not a binary
  on/off one). Watchdog running.
- 01:37 local: Fable scored item #8 at 30/100 (partial, independent
  scoring — same terminal failure as item #7, but this run collapsed
  earlier: ~18 min in, on a failed `TASKS.md` sub-item edit, before
  any code was touched, vs. item #7's ~23 min collapse on a real code
  edit). Also flagged a milder, separate glitch: two `bash` calls
  with `command: 3` that the model itself noticed and recovered from
  ("I keep typing 3 for some reason") — distinct from the terminal
  newline-flood collapse it never recovered from. Copied+redacted the
  session log, added to `SESSIONS.md`, appended the row to
  `results-guided.json`, regenerated `report-guided.html`. Committed
  and pushed to mendel benchmark @4617fc4.
- Item #9 (Gemma-12B guided low) checked a few minutes in: proper
  detailed `TASKS.md` (per-library AND per-file sub-items, unlike the
  flat lists of items #7/#8), 0 nudges so far. Looking much healthier
  than the two high attempts — low thinking may avoid whatever
  triggers the collapse. Still running, watching.
- Item #9 ran healthily for ~45 min (0 nudges, real orientation work),
  then hit the same newline-flood collapse as items #7/#8 — low
  thinking delayed the collapse, did not avoid it. 3 nudges total
  (first two: output-budget hit; third: a clean 36-token stop with
  unchecked TASKS.md items — a different signature). Ran ~99 min
  total, `model_budget_exhausted`, still 0 commits. Fable scored it
  29.5/100 (independent scoring): the model built a fully correct
  per-file plan in its reasoning by minute 4 — including trap B
  (`legacy-packages/mendel-requirify` rimraf) — then lost it to an
  empty-argument `edit` call, then alternated newline floods with a
  ~12-minute, 100-call loop of a malformed `ls -F_r` command. Never
  edited a file. Copied+redacted the session log, added to
  `SESSIONS.md`, appended the row to `results-guided.json`,
  regenerated `report-guided.html`. Committed and pushed to mendel
  benchmark @4058d37. Cleaned up the worktree/branch (0 commits).
- **Gemma-12B block done — 3 runs complete** (30.5, 30, 29.5, all
  partial with 0 commits — a consistent pattern across all three,
  worth flagging to the owner: this model/harness pairing (LM Studio
  + pi) seems to reliably collapse into a newline-flood generation
  failure after its first real edit attempt, regardless of thinking
  level). Stopped LM Studio (unload + server stop) and memwatch.

### Item #10 — Gemma-12B dagger sweep

- Checked `docs/setups/m1-max-32gb/models.json`: the daggered row
  (`gemma12-gguf-off`) is a llama-server GGUF config with an MTP
  drafter and `-c 262144` — the same risk pattern that OOM'd on
  Qwen3.6-35B-A3B (item #3). Tried it anyway per instruction ("try
  once, defer if it OOMs").
- Server loaded and warmed up cleanly — **no OOM this time** (Gemma-
  12B is much smaller than Qwen3.6-35B-A3B, fits comfortably under
  the current 24000 wired limit even with the large `-c`).
- Ran the context-creep depth sweep (`tools/sweeps/llama_sweep.py`,
  `DEPTH_LIST=4096,8192,16384,24576,32768`): 13.76 tok/s at 4,115
  tokens, 8.76 at 8,234, 6.54 at 16,410 — floor crossed at 16,410.
  Closely matches the report's own existing (unstaled) body-text
  table (14.0/9.0/6.8 at the same depths, measured at wired limit
  25000) — a clean re-confirmation, not a surprise. RSS 10.5 GB, no
  compression/swap events in the memwatch log.
- Updated all surfaces per the record-everywhere rule: `models.json`
  (cleared the `stale` array, new values), regenerated
  `comparison.md`/`decode-speed.md`/the report's summary table via
  `node tools/gen-tables.mjs`, added a re-confirmation note to the
  benchmarks page and the report's "Benchmarked" line and "Weak
  point" bullet (11K → 16K). Committed to this repo's `run7` branch
  @d3c6308.
- Stopped the server and memwatch. GPU idle. Moving to item #11
  (Bonsai-PrismML blind high, PrismML fork).
