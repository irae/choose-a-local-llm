# Run 31 (card): the thinking budget on the agent rows only this machine has

Ready to start, 2026-09-22, after the owner frees the card. Four agent
rows, about 7 hours. Run 30 on the Mac runs the same question on the
rows both machines share; this run takes only what the Mac cannot
answer: the two NVFP4 builds, the ternary build, and the reference
3-bit build at q8_0 KV on a guided row.

You are the runner, on `arrietty`. Read this file and, once per
session, `docs/methodology/checklist.md` and
`docs/methodology/status-lines.md`. Write all prose in ASD-STE100
Simplified Technical English, and pass that rule to every sub-agent.

## Wakeup, every 20 minutes (mandatory)

`ScheduleWakeup` every 1200 seconds from the first action to the end
of the run, also while a background task runs, with the short status
line at every wakeup (`docs/methodology/checklist.md`, step 7).

## What this run is for

The owner decisions of 2026-09-22, the same as run 30
(`hardware/kamaji/benchmarks/bench30/AGENT.md`, "What this run is
for"): the thinking budget is a server property, `--reasoning-budget
8192` with the fast-mode message on every row; the output budget is
pi's default, no `maxTokens` anywhere, `reserveTokens` pinned to that
default. A budgeted row runs under a temporary pi id with the suffix
`-tb8192`. Whether it is a new configuration or a retry on the site is
the coordinator's call after the run.

## The order

- `machine-setup`
- `gemma26-nvfp4-guided-tb8192`
- `bonsai2-ptq1-f16-guided-tb8192`
- `qwen38-ista-q8-guided-tb8192`
- `gemma12-nvfp4-guided-high-tb8192`
- `retry-sweep`

## Essentials

- `state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION after the wakeup:** `git fetch origin && git worktree
  add ../choose-a-local-llm-run31 -b run31 origin/master` (or `cd` into
  it if it exists), then `cd ../choose-a-local-llm-run31`. Verify with
  `pwd` and `git worktree list`. Every command of this run happens
  there.
- **Branches, exactly.** You work on `run31` and only on `run31`. To
  take an update: `git fetch origin && git merge origin/master`, then
  push `run31`. Never check out `master`, never merge `run31` into
  `master`, never push `master`.
- `tools/preflight.sh` first, with `PREFLIGHT_PROBE_PORT=8080`; every
  line `ok` before a block starts. Never sudo, never reboot on your
  own.
- **The router service must be down.** `tools/llama-router.sh status`
  and `tools/llama-router.sh status prism` must both say "not
  running". If one runs, stop and ask; the owner uses it. Do not stop
  it yourself. This run serves each row itself, on port 8080, the
  port the pi `llama` provider points at.
- One model on the GPU at a time. Before you start a server,
  `pgrep -fl llama-server` must be empty and `nvidia-smi` shows no
  compute process of yours. Never kill a server you did not start.
  Record `vram_start_mb` from `nvidia-smi` before the first server
  and wait for it after every row.
- The fast-mode flags, on every server of this run:
  ```bash
  export BUDGET_MSG="Thinking budget reached. Give the final answer now."
  export FAST_FLAGS="--reasoning-budget 8192 --reasoning-budget-message \"$BUDGET_MSG\""
  ```
  Verify each server before its row: one request that thinks long
  (`docs/methodology/evalplus.md`, fast mode, the probe); pass is
  `finish_reason` `stop` and a non-empty answer.
- **The PrismML build** serves the Bonsai row and nothing else. Binary:
  `~/.local/share/choose-a-local-llm/llama.cpp-prism/release/bin/llama-prism-b10685-7dffb15/llama-server`,
  with `LD_LIBRARY_PATH` listing that directory first, then
  `~/.local/share/choose-a-local-llm/llama.cpp/v0.4.0-sm120/lib`
  (the reverse order loads the official ggml and fails on the ternary
  types; `hardware/arrietty/benchmarks/bench27/state.md`). The
  official `llama-server` on `PATH` serves the other three rows.
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
- Commit on `run31` as results land, push at every block close, and
  message the coordinator session once per block with the mnemonic,
  the one-line result and the commit id. Every stop-and-ask goes to
  the coordinator with the condition and your candidate answer. Never
  a bare `git stash`. Never publish, never edit `docs/` or
  `models.json`.
- Archive evidence before the session closes:
  `tools/archive-evidence.sh hardware/arrietty/benchmarks/bench31/results run31`.

## `machine-setup`

Read `docs/methodology/mendel.md`, "House rules" and "Window and
budget", and `docs/methodology/common-rules.md`, rule 7.

1. `node tools/gen-pi-models.mjs --check` must pass: the pi file of
   this machine was regenerated on 2026-09-22 (new ids, no
   `maxTokens`, `baseUrl` on port 8080). If it reports STALE, stop and
   ask; the candidate answer is `npm run pi:models` after a backup to
   `~/.pi/agent/models.json.bak-run31`. Write the list of `llama` ids
   into `state.md`.
2. Find pi's default output budget: serve the first row's model as its
   block says, then run `benchmarks/mendel-smoke.sh` on it with
   `SMOKE_MENDEL_CONTEXT_WINDOW=<the row's window>` and
   `SMOKE_MENDEL_RESERVE_TOKENS=16384`. The smoke's `<slug>-meta.json`
   carries the resolved model entry as `model_info`; its
   `model_info.maxTokens` is the default pi filled in. Record it in
   `state.md` as `output_budget`. If the runner refuses with
   `bad_config` because the entry has no `maxTokens`, stop and ask;
   the candidate answer is a `maxTokens` of the value pi documents as
   its default, written into the temporary `-tb8192` entries only,
   and recorded as such. If run 30 has already recorded
   `output_budget` on `origin/run30`, take that value and skip the
   smoke's reading, not the smoke.
3. Every agent row then sets `MENDEL_RESERVE_TOKENS=<output_budget>`.
   `MENDEL_KEEP_RECENT_TOKENS` follows `mendel.md`: 8192 under a
   65536 window, unset above.
4. The smoke must pass. Leave the server up for the first row.

Values this block sets in `state.md`: `pi_ids`, `output_budget`,
`smoke_result`, `vram_start_mb`.

## How every agent row runs

Fixed: the row's file and revision, its server build, its KV type, its
drafter, the prompt version and level named in the block, the thinking
budget 8192 with `$BUDGET_MSG`. Derived: the window
(`MENDEL_CONTEXT_WINDOW`) from the row's `pi.contextWindow` in
`docs/setups/arrietty/models.json` unless a newer committed creep
under `hardware/arrietty/` says otherwise; the serving `-c` from the
row's command; `output_budget` from `machine-setup`.

1. Add the temporary pi entry `<pi id>-tb8192` to
   `~/.pi/agent/models.json`, under `llama`, a copy of `<pi id>` in
   every field, with the run's window as `contextWindow` if it differs.
   Remove it after the row.
2. Serve with the row's command from `docs/setups/arrietty/models.json`,
   `--port 8080` in place of `8081`, `$FAST_FLAGS` appended. Probe.
   Record `nvidia-smi` at load in `state.md`.
3. `cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<window>
   MENDEL_RESERVE_TOKENS=<output_budget> ./run-worker.sh <pi id>-tb8192
   pi guided <level>`, watcher up.
4. Score in a subagent. The config note carries `reasoning budget
   8192, message fixed`, the KV type, `-c`, the window, `maxTokens
   <output_budget> (pi default)`, `reserveTokens <output_budget>` and
   the VRAM at load.
5. Done: in `results.md`, one row beside the comparison row named in
   the block: score, libraries, end reason, wall, tool calls, peak
   context, the count of turns where the budget fired (grep
   `$BUDGET_MSG` in the session JSONL), `output_limit_hits` and
   `turn_timeout` from the meta file, and `loop-check.py`'s verdict.
   Commit, push, message the coordinator. Stop the server, wait for
   `vram_start_mb`, `pkill -f "Mendel Daemon"`.

## `gemma26-nvfp4-guided-tb8192`

Row `gemma26-nvfp4-on` (pi id `gemma-4-26b-a4b-nvfp4`), guided v3.0,
thinking high, official build. The loop case of this machine on a
build the Mac cannot serve: its guided row ended on a loop at 22.5
minutes with 37.5/100 and 3 of 8 libraries (`LOOP` flag). Comparison
row: that one. Planning window 94208.

## `bonsai2-ptq1-f16-guided-tb8192`

Row `bonsai2-ptq1-f16-xhigh` (pi id `bonsai2-27b-ptq1-f16`), guided
v3.0, effort xhigh, **PrismML build**. The fastest build of this
machine (42.1 tok/s shallow; blind 82/100, 8 of 8, 88.4 minutes) has
no guided row. This row gives the guided score and the first budget
data on a ternary model on this machine. Comparison row: its blind
row, for wall and completion only; there is no guided row to compare
a score with. Planning window 135168.

## `qwen38-ista-q8-guided-tb8192`

Row `qwen38-ista-xhigh` (pi id `qwen3.8-27b-ista-q8`), guided v3.0,
effort xhigh, official build. The best guided row of this machine and
the reference config: 85/100, 8 of 8, 214.8 minutes, no budget. The
question is whether the budget costs a guided row that does not loop;
run 30 asks it on a blind row. The level is xhigh, never medium (owner
rule, 2026-09-09). Planning window 61440;
`MENDEL_KEEP_RECENT_TOKENS=8192` (window under 65536). The long row of
the run, about 3.5 hours.

## `gemma12-nvfp4-guided-high-tb8192`

Row `gemma12-nvfp4-on` (pi id `gemma-4-12b-nvfp4`), guided v3.0,
thinking high, official build. Its guided row died at 5.5 minutes on a
text loop in the answer channel (one line 520 times, `repetition_loop`,
zero commits); the Q4_K_XL build did the same at 5.3 minutes, and run
30 runs that build on the Mac. A thinking budget cannot cut an
answer-channel loop, so this row costs 5 minutes if the loop returns,
and is the finding if it does not. Comparison row: the 5.5-minute one.
Planning window 258048.

## `retry-sweep`

Only what needed a human: a refused permission, a login, an owner
decision. List each with its condition in `state.md` and ask once.

## After the run

Remove every `-tb8192` entry from `~/.pi/agent/models.json`;
`node tools/gen-pi-models.mjs --check` must pass again. Update
`state.md` with a handing-over section: what ran, `output_budget`,
machine state left behind (no server, VRAM at `vram_start_mb`, no
Mendel Daemon), evidence archived. Push `run31` and message the
coordinator with the last commit id. The coordinator merges, imports
the simulator runs, writes the report, and brings the router service
back up.
