# Run 32 (Mac): retry the agent rows hit by the compaction summary cap

Ready to start, 2026-09-25. Two agent rows, about 10 hours.

You are the runner, on `kamaji`. Read this file and, once per session,
`docs/methodology/checklist.md` and `docs/methodology/status-lines.md`.
Write all prose in ASD-STE100 Simplified Technical English, and pass
that rule to every sub-agent.

## Wakeup, every 20 minutes (mandatory)

`ScheduleWakeup` every 1200 seconds from the first action to the end
of the run, also while a background task runs, with the short status
line at every wakeup (`docs/methodology/checklist.md`, step 7).

## What this run is for

From 2026-09-06 to 2026-09-24 the simulator pinned pi `reserveTokens`
8192. pi caps a compaction summary at `0.8 x reserveTokens` (6553) and
a split-turn prefix summary at `0.5 x reserveTokens` (4096), thinking
included. pi 0.84.3 on this Mac kept an empty or cut summary with no
error (`/history/compaction-summary-cap.html`). Two guided rows of this
machine ran into that cap. The owner decided on 2026-09-25 to retry
them and replace them; the harness caused the failure, so there is no
retry penalty (`docs/methodology/mendel.md`).

The third row that touched the cap, the Qwen3.8 Q4_K_M blind row (93),
is not in this run: run 30 already ran it again under the new budget
(`qwen38-q4km-blind-tb8192`, 91, no summary near its cap).

Every row runs under the current method: the newest pi, a run config
that the worker builds from the site data, no `maxTokens` and no
`reserveTokens`, `keepRecentTokens` from the window curve, and the
fast-mode thinking budget on the server. The re-run changes the
thinking budget too, so the config note says a score change does not
come from compaction alone.

## The order

- `machine-setup`
- `bonsai-q4bias-guided-tb8192`
- `qwen38-iq3s-f16-guided-tb8192`
- `retry-sweep`

## Essentials

- `state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION after the wakeup:** `git fetch origin && git worktree
  add ../choose-a-local-llm-run32 -b run32 origin/master` (or `cd` into
  it if it exists), then `cd ../choose-a-local-llm-run32`. Verify with
  `pwd` and `git worktree list`. Every command of this run happens
  there.
- **The Mendel kit changed on 2026-09-25.** In
  `~/code/mendel-benchmark`, on branch `benchmark`: `git fetch origin &&
  git merge --ff-only origin/benchmark` before the first row. The
  worker must know `MENDEL_SITE_ID` (`./run-worker.sh` header); if it
  does not, the merge did not land: stop and ask.
- **Branches, exactly.** You work on `run32` and only on `run32`. To
  take an update: `git fetch origin && git merge origin/master`, then
  push `run32`. Never check out `master`, never merge `run32` into
  `master`, never push `master`.
- `tools/preflight.sh` first, with `PREFLIGHT_PROBE_PORT=8080`; every
  line `ok` before a block starts. Never sudo, never reboot on your
  own. On this Mac a `fix pi-version` line goes to the owner: the
  upgrade is a download.
- **Wired limit: 25000.** Verify with `sysctl -n iogpu.wired_limit_mb`.
  Any other value is stop and ask.
- **Port 8080.** The run config the worker builds points pi at
  `http://127.0.0.1:8080/v1`. This run serves each row itself on that
  port. Every serving command below ends in `--port 8080`.
- **Never edit `~/.pi/agent/`.** The worker and the smoke build their
  own config for the one model the server holds.
- One model on the GPU at a time. Before you start a server,
  `pgrep -fl "llama-server|mlx_lm"` must be empty. Never kill a server
  you did not start. Quit the LM Studio app first and confirm with
  `pgrep -fl "LM Studio"`.
- The fast-mode flags, on every server of this run:
  ```bash
  export BUDGET_MSG="Thinking budget reached. Give the final answer now."
  export FAST_FLAGS="--reasoning-budget 8192 --reasoning-budget-message \"$BUDGET_MSG\""
  ```
  Verify each server before its row: one request that thinks long
  (`docs/methodology/evalplus.md`, fast mode, the probe); pass is
  `finish_reason` `stop` and a non-empty answer.
- Every agent row: `benchmarks/run-watch.sh` as a background task
  (`RUNWATCH_SILENCE=2700`, the checklist's memory log path); the
  worker from `~/code/mendel-benchmark/benchmark`; `gh auth status`
  and `git stash clear` there first; scoring in a subagent on the best
  available model, never a smaller one (`PLAN.md`); `pkill -f "Mendel
  Daemon"` after every row; verify `peak_context` with
  `benchmark/count-tool-calls.mjs` before the row commits.
- A bug in a run tool goes to a subagent on the best available model.
  A recoverable failure is retried at once, inside its block.
  `retry-sweep` holds only what needed a human.
- Commit on `run32` as results land, push at every block close, and
  message the coordinator session once per block with the mnemonic,
  the one-line result and the commit id. Every stop-and-ask goes to
  the coordinator with the condition and your candidate answer. Never
  a bare `git stash`. Never publish, never edit `docs/` or
  `models.json`.
- Archive evidence before the session closes:
  `tools/archive-evidence.sh hardware/kamaji/benchmarks/bench32/results run32`.

## `machine-setup`

Read `docs/methodology/mendel.md`, "Output budget" and "Window and
budget".

1. `tools/preflight.sh` prints `ok pi-version`. Record `pi --version`
   in `state.md` as `pi_version`.
2. Serve the first row's model as its block says, then run
   `benchmarks/mendel-smoke.sh bonsai-27b-q2g64-q4bias-tb8192 high`
   with `SMOKE_MENDEL_SITE_ID=bonsai-27b-q2g64-q4bias` and
   `SMOKE_MENDEL_CONTEXT_WINDOW=<the row's window>`. The SMOKE-MENDEL
   line carries the pi version.
3. The smoke must pass. Leave the server up for the first row.

Values this block sets in `state.md`: `pi_version`, `smoke_result`.

## How every agent row runs

Fixed: the row's file and revision, its server build, its KV type, the
prompt version and level named in the block, the thinking budget 8192
with `$BUDGET_MSG`. Derived: the window (`MENDEL_CONTEXT_WINDOW`) from
the row's `pi.contextWindow` in `docs/setups/kamaji/models.json` unless
a newer committed creep under `hardware/kamaji/` says otherwise; the
serving `-c` from the row's command; `keepRecentTokens` from the window
curve, which the generator applies.

1. The run id is `<pi id>-tb8192`. The worker builds its config from
   `MENDEL_SITE_ID=<pi id>`.
2. Serve with the row's command from `docs/setups/kamaji/models.json`,
   `--port 8080` in place of `8081`, `$FAST_FLAGS` appended. Probe.
3. `cd ~/code/mendel-benchmark/benchmark && MENDEL_SITE_ID=<pi id>
   MENDEL_CONTEXT_WINDOW=<window> ./run-worker.sh <pi id>-tb8192
   pi guided <level>`, watcher up.
4. Score in a subagent. The config note carries `reasoning budget
   8192, message fixed`, the KV type, `-c`, the window, `maxTokens and
   reserveTokens pi default`, the keep value, the pi version (the meta
   file's `pi_version`), `wired 25000`, and the line "Retry of
   <comparison slug>, which hit pi's compaction summary cap; this run
   also adds the thinking budget."
5. Done: in `results.md`, one row beside the comparison row named in
   the block: score, libraries, end reason, wall, tool calls, peak
   context, the number of compactions and the output tokens of each
   summary (the `compaction` entries of the session JSONL; a split
   turn's summary begins `No prior history`), any summary at or near
   its cap, the count of turns where the budget fired (grep
   `$BUDGET_MSG` in the session JSONL), `output_limit_hits` and
   `turn_timeout` from the meta file, and `loop-check.py`'s verdict.
   Commit, push, message the coordinator. Stop the server, wait for
   wired memory to recover, `pkill -f "Mendel Daemon"`.

## `bonsai-q4bias-guided-tb8192`

Row `bonsai-fork-single` (pi id `bonsai-27b-q2g64-q4bias`), guided
v3.0, thinking high, the PrismML fork (`~/prism-llama/llama-server`,
with `LLAMA_ATTN_ROT_DISABLE=1` as the row's command sets it). Serve
with the row's KV bias file,
`~/.local/share/choose-a-local-llm/Ternary-Bonsai-27B-kv-bias.gguf`.
The file is generated, not downloaded: if it is missing, stop and ask;
never generate a new one, because a new file is a different config.
Comparison row: `bonsai-prism-high-guided-v3-issue-13`, 31.5/100,
`wall_clock`. One of its eleven summaries came back empty at exactly
6553 tokens, and the model then repeated failing `git show` calls. The
retry is certain to be fair only if no summary here comes near its
cap; the `results.md` row says. Planning window 65536; the generator
sets keep 16384.

## `qwen38-iq3s-f16-guided-tb8192`

Row `qwen38-gguf-unsloth-iq3s-xhigh` (pi id `qwen3.8-27b-iq3s-f16`),
guided v3.0, effort xhigh, never medium (owner rule, 2026-09-09),
official build. Comparison row:
`qwen3.8-27b-iq3s-m1-xhigh-guided-v3-issue-13`, 62.5/100, 5 of 8
libraries, a valid partial at the 300-minute wall cap. Its one prefix
summary reports 9482 output tokens against a 4096 cap and ends on a
path list; the cause is not known, so the impact is possible, not
certain. Planning window 147456; above 131072 the generator sets no
keep override. The long row of the run, up to the 300-minute cap.

## `retry-sweep`

Only what needed a human: a refused permission, a login, an owner
decision, a missing bias file. List each with its condition in
`state.md` and ask once.

## After the run

Update `state.md` with a handing-over section: what ran, `pi_version`,
machine state left behind, evidence archived. Push `run32` and message
the coordinator with the last commit id. The coordinator merges,
imports the simulator runs, replaces the two rows on the site and
writes the report.
