# Run 30 (Mac): the thinking budget on agent rows, at pi's own output budget

Ready to start, 2026-09-22. Five agent rows, about 10 to 12 hours.
Run 29 was planned and folded into run 22; its number is not reused.

You are the runner, on `kamaji`. Read this file and, once per session,
`docs/methodology/checklist.md` and `docs/methodology/status-lines.md`.
Write all prose in ASD-STE100 Simplified Technical English, and pass
that rule to every sub-agent.

## Wakeup, every 20 minutes (mandatory)

`ScheduleWakeup` every 1200 seconds from the first action to the end
of the run, also while a background task runs, with the short status
line at every wakeup (`docs/methodology/checklist.md`, step 7).

## What this run is for

Run 22 put one guided agent row under the fast-mode thinking budget
and the budget never fired: a guided turn at thinking high never
reached 8192 reasoning tokens (`hardware/kamaji/benchmarks/bench22/report.md`).
This run asks the same question on the rows where it matters: a row
that died on a loop, the best row of the machine, a 3-bit row, a MoE
row, and a dense 12B that loops on the card. Two owner decisions of
2026-09-22 apply to every row:

- **The thinking budget is a server property**: `--reasoning-budget
  8192` with the fast-mode message, the same on every row.
- **The output budget is pi's default.** The pi entries carry no
  `maxTokens`; `tools/gen-pi-models.mjs` no longer writes one. The
  worker pins `reserveTokens` to the same value as that default.
  Nothing in this run sets `maxTokens` by hand.

A budgeted row runs under a temporary pi id with the suffix `-tb8192`,
a copy of the row's entry in every field, as run 22 did, so the
worker's branch and slug never collide with the row's earlier run. The
site question of whether it is a new configuration or a retry is the
coordinator's, after the run.

## The order

- `machine-setup`
- `gemma26-q4kxl-mtp2-guided-tb8192`
- `qwen38-q4km-blind-tb8192`
- `gemma12-q4kxl-guided-high-tb8192`
- `qwen38-ista-f16-blind-tb8192`
- `qwen36-q4kxl-q8-mtp3-guided-tb8192`
- `retry-sweep`

## Essentials

- `state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION after the wakeup:** `git fetch origin && git worktree
  add ../choose-a-local-llm-run30 -b run30 origin/master` (or `cd` into
  it if it exists), then `cd ../choose-a-local-llm-run30`. Verify with
  `pwd` and `git worktree list`. Every command of this run happens
  there.
- **Branches, exactly.** You work on `run30` and only on `run30`. To
  take an update: `git fetch origin && git merge origin/master`, then
  push `run30`. Never check out `master`, never merge `run30` into
  `master`, never push `master`.
- `tools/preflight.sh` first, with `PREFLIGHT_PROBE_PORT=8080`; every
  line `ok` before a block starts. Never sudo, never reboot on your
  own.
- **Wired limit: 25000.** Verify with `sysctl -n iogpu.wired_limit_mb`.
  Any other value is stop and ask.
- **Port 8080, not 8081.** The pi `llama` provider now points at
  `http://127.0.0.1:8080/v1` (the router port of the project; the Mac
  has no router service yet, so this run serves each row itself, on
  that port). Every serving command below ends in `--port 8080`.
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
- Commit on `run30` as results land, push at every block close, and
  message the coordinator session once per block with the mnemonic,
  the one-line result and the commit id. Every stop-and-ask goes to
  the coordinator with the condition and your candidate answer. Never
  a bare `git stash`. Never publish, never edit `docs/` or
  `models.json`.
- Archive evidence before the session closes:
  `tools/archive-evidence.sh hardware/kamaji/benchmarks/bench30/results run30`.

## `machine-setup`

Read `docs/methodology/mendel.md`, "House rules" and "Window and
budget", and `docs/methodology/common-rules.md`, rule 7.

1. Back up `~/.pi/agent/models.json` to
   `~/.pi/agent/models.json.bak-run30`. Then `npm run pi:models` in
   the worktree. It rewrites the `llama` provider for this machine
   only: the new pi ids (`docs/methodology/common-rules.md`, rule 7:
   `<model>-<quant>[-<kv>][-mtp<n>][-variant]`), no `maxTokens`,
   `baseUrl` on port 8080, and it removes the entries of the other
   machine and every emptied provider. Write the list of ids it left
   into `state.md`. `node tools/gen-pi-models.mjs --check` must pass.
2. Find pi's default output budget: serve the first row's model as its
   block says, then run `benchmarks/mendel-smoke.sh` on it with
   `SMOKE_MENDEL_CONTEXT_WINDOW=<the row's window>` and
   `SMOKE_MENDEL_RESERVE_TOKENS=16384`. The smoke's `<slug>-meta.json`
   carries the resolved model entry as `model_info`; its
   `model_info.maxTokens` is the default pi filled in.
   Record it in `state.md` as `output_budget`. If the runner refuses
   with `bad_config` because the entry has no `maxTokens`, stop and
   ask; the candidate answer is a `maxTokens` of the value pi
   documents as its default, written into the temporary `-tb8192`
   entries only, and recorded as such.
3. Every agent row of this run then sets
   `MENDEL_RESERVE_TOKENS=<output_budget>` (the rule: `reserveTokens`
   equals `maxTokens`). `MENDEL_KEEP_RECENT_TOKENS` follows
   `mendel.md`: 8192 under a 65536 window, unset above.
4. The smoke must pass (`docs/methodology/mendel.md`). Leave the server
   up for the first row.

Values this block sets in `state.md`: `pi_ids`, `output_budget`,
`smoke_result`.

## How every agent row runs

Fixed: the row's file and revision, its server build, its KV type, its
drafter, the prompt version and level named in the block, the thinking
budget 8192 with `$BUDGET_MSG`. Derived: the window
(`MENDEL_CONTEXT_WINDOW`) from the row's `pi.contextWindow` in
`docs/setups/kamaji/models.json` unless a newer committed creep under
`hardware/kamaji/` says otherwise; the serving `-c` from the row's
command; `output_budget` from `machine-setup`.

1. Add the temporary pi entry `<pi id>-tb8192` to
   `~/.pi/agent/models.json`, under `llama`, a copy of `<pi id>` in
   every field, with the run's window as `contextWindow` if it differs.
   Remove it after the row.
2. Serve with the row's command from `docs/setups/kamaji/models.json`,
   `--port 8080` in place of `8081`, `$FAST_FLAGS` appended. Probe.
3. `cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<window>
   MENDEL_RESERVE_TOKENS=<output_budget> ./run-worker.sh <pi id>-tb8192
   pi <guided|blind> <level>`, watcher up.
4. Score in a subagent. The config note carries `reasoning budget
   8192, message fixed`, the KV type, `-c`, the window, `maxTokens
   <output_budget> (pi default)`, `reserveTokens <output_budget>` and
   `wired 25000`.
5. Done: in `results.md`, one row beside the comparison row named in
   the block: score, libraries, end reason, wall, tool calls, peak
   context, the count of turns where the budget fired (grep
   `$BUDGET_MSG` in the session JSONL), `output_limit_hits` and
   `turn_timeout` from the meta file, and `loop-check.py`'s verdict.
   Commit, push, message the coordinator. Stop the server, wait for
   wired memory to recover, `pkill -f "Mendel Daemon"`.

## `gemma26-q4kxl-mtp2-guided-tb8192`

Row `gemma26-gguf` (pi id `gemma-4-26b-a4b-q4kxl-mtp2`), guided v3.0,
thinking high. The loop case of this machine: its guided row ended on
a loop at 20.4 minutes with 25/100 and 2 of 8 libraries (`LOOP` flag),
and a second run reached 57 with 7 of 8. Comparison rows: both.
Planning window 212992 (the row's `pi` block).

## `qwen38-q4km-blind-tb8192`

Row `qwen38-gguf-medium` (pi id `qwen3.8-27b-q4km`), blind v1.1,
effort xhigh: the best agent row of this machine, 93/100, 8 of 8,
213.3 minutes, no budget. The question is whether the budget costs a
model that does not loop. The level is xhigh, the model's published
default and the level of the 93 row; never medium (owner rule,
2026-09-09). Planning window 65536.

## `gemma12-q4kxl-guided-high-tb8192`

Row `gemma12-gguf-f16` (pi id `gemma-4-12b-q4kxl`), guided v3.0,
thinking high. The row's level on this machine is off; no Mendel run
at thinking off (owner rule, 2026-09-14), so the row uses its
thinking-on level, and this block writes that reason in the config
note. On the card both builds of this model ended their guided rows in
about 5 minutes on a text loop in the answer channel (818 and 520
repeats), zero commits; on this machine the thinking-off guided row
ended on a loop at 58. A thinking budget cannot cut an answer-channel
loop, so this row measures whether thinking high with the budget
changes the loop at all. Comparison rows: the card's two guided rows
at high (both 0, `repetition_loop`) and this machine's 58. Planning
window 262144.

## `qwen38-ista-f16-blind-tb8192`

Row `qwen38-gguf-ista-nodrafter-xhigh` (pi id `qwen3.8-27b-ista-f16`),
blind v1.1, effort xhigh. The 3-bit row: 80.5/100, 8 of 8, 109.4
minutes, no budget. Its fast-mode EvalPlus forced 13 of 164, the most
of the dense Qwen rows here, so it is the dense row most likely to
reach the budget on an agent turn. Planning window 147456.

## `qwen36-q4kxl-q8-mtp3-guided-tb8192`

Row `qwen36-gguf-think` (pi id `qwen3.6-35b-a3b-q4kxl-q8-mtp3`), guided
v3.0, thinking high. The MoE row, with three guided runs at 46.5, 62.5
and 83 (all 8 of 8, about 90 minutes): the widest variance on the
machine, so one budgeted run is a fourth sample, not a verdict.
Planning window 81920; `MENDEL_KEEP_RECENT_TOKENS` unset (window above
65536).

## `retry-sweep`

Only what needed a human: a refused permission, a login, an owner
decision. List each with its condition in `state.md` and ask once.

## After the run

Remove every `-tb8192` entry from `~/.pi/agent/models.json`; the file
must then match what `npm run pi:models --check` expects. Update
`state.md` with a handing-over section: what ran, `output_budget`,
machine state left behind, evidence archived. Push `run30` and message
the coordinator with the last commit id. The coordinator merges,
imports the simulator runs and writes the report.
