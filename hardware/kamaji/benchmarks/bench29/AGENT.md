# Run 29 — every scored row of the M1 Max 32 GB in EvalPlus fast mode

Starts when the owner says the Mac is free, after run 26 ends. One
model on the GPU at a time. About two days of machine time. The list
below is the order and the run ends when the list ends or the owner
says stop.

You are the runner, on the Mac. Read this file, then the pages each
block names at its start, and nothing else. Write all prose in
ASD-STE100 Simplified Technical English.

## Wakeup, every 20 minutes (mandatory)

**Before any other action, schedule `ScheduleWakeup` with 1200
seconds. At every wakeup, schedule the next one. Do this from the
first action to the end of the run, also while a background task, a
`Monitor` or `run-watch.sh` runs** (owner rule, 2026-09-15,
`docs/methodology/checklist.md`, step 7).

## What this run is for

The owner's word (2026-09-19): EvalPlus runs in **fast mode** on every
row, `docs/methodology/evalplus.md`, "Fast mode": the server closes the
thinking at 8192 tokens and the model answers, `max_tokens` 16384, no
calibration, no forced re-run. One rule for every model, so the rows
compare. This run gives every scored thinking row of this machine that
serves on llama.cpp its fast-mode score. Where an earlier run of the
same config left a finish log, the run splices it and generates only
the problems that went past 8192 tokens; where none exists, the run
scores all 164.

This run replaces the budget blocks that run 22 left unrun
(`bonsai-fork-budget-think` and its forced re-run): the fork's row gets
its fast-mode score here instead. Run 22's guided agent row under a
budget is not in this run; it waits for the owner.

**This run measures; it decides nothing.**

## The order

**This list is the order.**

- `machine-setup`
- `fast-qwen38-gguf-xhigh`
- `fast-bonsai2-ptq1-mac-xhigh`
- `fast-gemma26-gguf`
- `fast-qwen38-gguf-unsloth-iq3s-xhigh`
- `fast-qwen38-gguf-ista-nodrafter-xhigh`
- `fast-qwen36-gguf-think`
- `fast-bonsai-fork-single`
- `retry-sweep`

## Essentials

- `bench29/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION after the wakeup:** `git fetch origin && git worktree
  add ../choose-a-local-llm-run29 -b run29 origin/master` (or `cd` into
  it if it exists), then `cd ../choose-a-local-llm-run29`. Verify with
  `pwd` and `git worktree list`. Every command of this run happens
  there.
- **Branches, exactly.** You work on `run29` and only on `run29`. To
  take an update: `git fetch origin && git merge origin/master`, then
  push `run29`. Never check out `master`, never merge `run29` into
  `master`, never push `master`.
- Then `docs/methodology/checklist.md` and
  `docs/methodology/status-lines.md`, whole, once per session.
  `tools/preflight.sh` first, every line `ok` before a block starts.
  Never sudo, never reboot on your own.
- **Wired limit: 25000.** Verify with `sysctl -n iogpu.wired_limit_mb`.
  Any other value is stop and ask.
- One model on the GPU at a time, port 8081. Before you start a server,
  `pgrep -fl "llama-server|mlx_lm"` must be empty. Never kill a server
  you did not start. Quit the LM Studio app first.
- **No download is approved for this run.** Every file below is on the
  Mac from earlier runs. A missing file is stop and ask.
- **The fast-mode flags are fixed for the whole run:**

  ```bash
  export BUDGET_MSG="Thinking budget reached. Give the final answer now."
  export FAST_FLAGS="--reasoning-budget 8192 --reasoning-budget-message $BUDGET_MSG"
  export EVALPLUS_MAX_NEW_TOKENS=16384
  ```

  Every serve command of this run carries `$FAST_FLAGS` (quote
  `"$BUDGET_MSG"` when you expand it by hand) and every
  `run-humaneval.sh` call runs with `EVALPLUS_MAX_NEW_TOKENS=16384`.
- **Count from the files, never from a log line:**
  `python3 benchmarks/thinking-budget.py count <run-dir> --message
  "$BUDGET_MSG"` prints the forced count from `finish.jsonl` and the
  empty count from the samples. Those two numbers go beside the score
  on every surface.
- **No temperature and no sampling parameter is passed to any server.**
  Read what the server applies from the load log and write it in
  `state.md`.
- **The two ternary rows serve on the PrismML fork**: the Bonsai 2 row
  on the fork release run 26 recorded in
  `hardware/kamaji/benchmarks/bench26/state.md`, the Bonsai 27B row on
  `~/prism-llama/llama-server` with `LLAMA_ATTN_ROT_DISABLE=1` as run
  22 recorded in `hardware/kamaji/benchmarks/bench22/state.md`
  (`bonsai-fork-calibrate-think`). Both print the budget flags; run 22
  verified the older one. `$LLAMA_SERVER` in those rows means the fork
  the row names.
- Every scoring run starts `benchmarks/run-watch.sh` as the checklist
  says, `RUNWATCH_SILENCE` at 2700 on this machine: a forced problem
  runs 8192 thinking tokens plus its answer on one slot at 8 to 15
  tok/s, and run 22 saw the probe read a busy server as dead.
- **Crashes and wall:** `docs/methodology/evalplus.md`, "Crashes and
  wall time". Write every part in `state.md` in UTC.
- Commit on `run29` as results land. Push `run29` at every block close
  and message the coordinator session with the block, the config, the
  result line and the commit id. **No message between pushes** (owner
  rule, 2026-09-11). Every gate and stop-and-ask goes to the coordinator
  with your candidate answer.
- **A recoverable failure is retried at once, inside its block.**
- Archive evidence before a session closes:
  `tools/archive-evidence.sh hardware/kamaji/benchmarks/bench29/results run29`.
- Everything a block writes goes under
  `hardware/kamaji/benchmarks/bench29/results/` or
  `~/.local/share/choose-a-local-llm/`. Nothing under `/tmp`.

## `machine-setup`

1. `tools/preflight.sh`, the wired limit, `pgrep`, free disk.
2. Both binaries print the flags: `llama-server --help | grep -A1
   reasoning-budget` and the same on each fork. A binary without them
   is stop and ask.
3. `mkdir -p hardware/kamaji/benchmarks/bench29/results`.

Done: the checks in `state.md`, committed. No result table.

## The table

One block per row. The serve command is the row's `command` in
`docs/setups/kamaji/models.json` (the `id` column) with three changes:
`-c 32768` (the problems are short; the fastest config at shallow
depth scores), `$FAST_FLAGS` appended, and the fork binary on the
ternary rows. The alias, the drafter and the KV type stay as the row
writes them; a drafter never changes an answer at temperature 0. The
extra body is mandatory on every call.

| block | row `id` | server | extra body | splice source (`finish.jsonl` present) | to generate |
|---|---|---|---|---|--:|
| `fast-qwen38-gguf-xhigh` | `qwen38-gguf-xhigh` | llama-server | `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}` | `bench22/results/qwen38-bartowski-budget-xhigh` (alias `qwen3.8-27b`, drafter n-max 3 as that block served) | 11 |
| `fast-bonsai2-ptq1-mac-xhigh` | `bonsai2-ptq1-mac-xhigh` | fork (run 26's) | same | `bench26/results/bonsai2-budget-xhigh-mac` | 10 |
| `fast-gemma26-gguf` | `gemma26-gguf` | llama-server | `{"chat_template_kwargs":{"enable_thinking":true}}` | `bench22/results/gemma26-gguf-budget-think` | 19 |
| `fast-qwen38-gguf-unsloth-iq3s-xhigh` | `qwen38-gguf-unsloth-iq3s-xhigh` | llama-server | `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}` | none | 164 |
| `fast-qwen38-gguf-ista-nodrafter-xhigh` | `qwen38-gguf-ista-nodrafter-xhigh` | llama-server | same | none | 164 |
| `fast-qwen36-gguf-think` | `qwen36-gguf-think` | llama-server | `{"chat_template_kwargs":{"enable_thinking":true}}` | none | 164 |
| `fast-bonsai-fork-single` | `bonsai-fork-single` | `~/prism-llama` fork, the `bonsai-fork-calibrate-think` command of run 22 with `$FAST_FLAGS` | none (thinking on is the default) | none | 164 |

The "to generate" column is the planning count from the source's
finish log; the splice prints the real one. Every splice source is
under `hardware/kamaji/benchmarks/`. A splice source must have been
served under the same alias as the block serves (the samples file is
named for it); a mismatch is stop and ask.

Rows that share a score under the shared-score rule take the block's
result: `qwen36-gguf-f16` and `qwen36-gguf-f16-nodrafter` from
`fast-qwen36-gguf-think`, `gemma26-gguf-2x` from `fast-gemma26-gguf`,
`bonsai-fork-2x` from `fast-bonsai-fork-single`. The coordinator
writes them; the runner scores the one row.

Not scored here: every MLX and LM Studio row (`mlx_lm` does not enforce
a thinking budget; the site says so on the row), every thinking-off row
(no thinking, no fast run needed), and every effort-medium and
effort-low row of the dense 27B (the owner's level rule; they keep
their earlier score with the marker).

## The fast block, one shape for every row

Read `docs/methodology/evalplus.md`, "Fast mode", "Reuse of an earlier
run: the splice" and "Steps", once, before the first block.

1. Serve the row's command as the table says, with `$FAST_FLAGS`. Wait
   for the load, record the memory in `state.md`.
2. Verify with one real chat completion at the row's level (the extra
   body): the response carries a reasoning field, `content` is not
   empty, and the server log shows no error. On a problem that thinks
   past 8192 tokens the reasoning tail must end with the budget
   message; a short probe that converges early does not show it, and
   that is fine. Record the probe in `state.md`.
3. Splice when the table names a source:
   ```bash
   python3 benchmarks/thinking-budget.py splice \
     hardware/kamaji/benchmarks/<source> \
     hardware/kamaji/benchmarks/bench29/results/<block> \
     --message "$BUDGET_MSG"
   ```
   Write the kept and to-generate counts in `state.md`.
4. Start the watcher, `RUNWATCH_SILENCE=2700`.
5. Score:
   ```bash
   RESULTS_BASE=hardware/kamaji/benchmarks/bench29/results \
     EVALPLUS_MAX_NEW_TOKENS=16384 \
     benchmarks/run-humaneval.sh <block> <alias> '<extra body>'
   ```
   The script skips every problem the splice seeded. Wall parts in
   `state.md` as they happen, UTC. A spliced block's wall is its own
   generation time plus the source's time for the kept problems: the
   source's `finish.jsonl` `wall_s` of every kept task id, summed;
   write both parts.
6. Count: `thinking-budget.py count` on the block directory. Then the
   block's table in `results.md`: base, plus, completion, empty
   (`N/164`), forced (`N/164`), the forced task ids, the empty task
   ids with their cause word, the wall with its parts, the splice
   source and the kept count. Beside it, the row's score before fast
   mode, from `docs/setups/kamaji/models.json`.
7. Stop the watcher and the server, wait for the memory to return,
   commit, push, message the coordinator, start the next block.

A forced answer is an answer. Nothing is re-run in this run: no proof
run, no natural re-run. An answer that ends on `length` at 16384 is
`budget`; write its task id, it is a finding.

## `retry-sweep`

The blocks that waited on a human, oldest first.

## Not in this run

- A calibration, a proof run, a natural re-run, any budget other than
  8192 and 16384.
- Any speed measurement, any agent row, any smoke, any MLX or LM
  Studio server.
- Effort medium or low on any dense 27B file.
- Any file not already scored on this machine.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
changed and why, machine state left behind, evidence archived. Push and
message the coordinator. The coordinator writes `report.md`, adds the
findings to `hardware/kamaji/benchmarks/INDEX.md`, fills the fast rows
on the site (`evalplusRuns` with `think` 8192 and `forced`, the row
cells and the rows that share them, `evalplus` out of `stale`) and
publishes.
