# Run 28 — every scored row of the RTX 5060 Ti 16 GB in EvalPlus fast mode

Starts when the coordinator says the card is free. One model serves on
this card at a time. About two days of machine time. The list below is
the order and the run ends when the list ends or the owner says stop.

You are the runner, on the Linux machine. Read this file, then the
pages each block names at its start, and nothing else. Write all prose
in ASD-STE100 Simplified Technical English.

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
compare. This run gives every scored thinking row of this machine its
fast-mode score. Where an earlier run of the same config left a finish
log, the run splices it and generates only the problems that went past
8192 tokens; where none exists, the run scores all 164.

**This run measures; it decides nothing.**

## The order

**This list is the order.**

- `machine-setup`
- `fast-qwen38-iq3s-xhigh`
- `fast-bonsai2-ptq1-f16-xhigh`
- `fast-bonsai2-pq2-f16-xhigh`
- `fast-bonsai2-ptq1-xhigh`
- `fast-bonsai2-pq2-xhigh`
- `fast-bonsai2-ptq1-f16-orca-xhigh`
- `fast-gemma26-nvfp4-on`
- `fast-qwen36-q4kxl-on`
- `fast-gemma12-nvfp4-on`
- `fast-gemma12-q4kxl-on`
- `fast-qwen38-oblit-q3km-medium`
- `retry-sweep`

## Essentials

- `bench28/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION after the wakeup:** `cd
  ../choose-a-local-llm-run28`, the worktree the coordinator prepared
  for you on branch `run28`. Verify with `pwd` and `git worktree
  list`. If it does not exist: `git worktree add
  ../choose-a-local-llm-run28 -b run28 master`. Every command of this
  run happens there.
- **Branches, exactly.** You work on `run28` and only on `run28`. To
  take an update: `git merge master` from your worktree, then push
  `run28`. Never check out `master`, never merge `run28` into
  `master`, never push `master`.
- Then `docs/methodology/checklist.md` and
  `docs/methodology/status-lines.md`, whole, once per session.
- **This machine is Linux, not the Mac.** Read run 19's runbook,
  `hardware/arrietty/benchmarks/bench19/AGENT.md`, section
  "Essentials", from "This machine is Linux" to the end of the list.
- **Another run may hold the card.** Never touch another run's
  worktree, branch or processes, and never kill a server you did not
  start.
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
- **`vram 16311 MiB` is the card's capacity, not a measurement.** The
  memory a config used goes in `state.md`, from `nvidia-smi` at load
  and under the first real request.
- **The ternary rows serve on the PrismML fork**, release
  `prism-b10685-7dffb15`, the binary run 24 recorded in
  `hardware/arrietty/benchmarks/bench24/state.md`, `machine-setup`.
  `$LLAMA_SERVER` in those rows means it. The stock binary makes
  garbage from those files. Every other row serves on the CUDA
  `llama-server` of run 19.
- Commit on `run28` as results land. Push `run28` at every block close
  and message the coordinator session with the block, the config, the
  result line and the commit id. **No message between pushes.**
- **A recoverable failure is retried at once, inside its block.**
- Archive evidence before a session closes:
  `tools/archive-evidence.sh hardware/arrietty/benchmarks/bench28/results run28`.
- Everything a block writes goes under
  `hardware/arrietty/benchmarks/bench28/results/` or
  `~/.local/share/choose-a-local-llm/`. Nothing under `/tmp`.

## `machine-setup`

1. The read-only machine checks of run 19's Essentials. Record
   `vram_start_mb`, `MemAvailable` and `df -h ~`.
2. Both binaries print the flags: `llama-server --help | grep -A1
   reasoning-budget` and `$LLAMA_SERVER --help | grep -A1
   reasoning-budget`. A binary without them is stop and ask.
3. `export EVALPLUS_PYTHON=...` as run 19's `machine-setup` says.
4. Nothing is downloaded for this run: every file below is in the
   default `hf` cache from runs 19 to 27. A missing file is fetched
   with `hf download <repo> <file>` and noted in `state.md`.
5. `mkdir -p hardware/arrietty/benchmarks/bench28/results`.

Done: the checks in `state.md`, committed. No result table.

## The table

One block per row. The serve command is the row's `command` in
`docs/setups/arrietty/models.json` (the `id` column) with three
changes: `-c 32768` (the problems are short; the fastest config at
shallow depth scores), `$FAST_FLAGS` appended, and `$LLAMA_SERVER` in
place of `llama-server` on the ternary rows. The alias and the KV type
stay as the row writes them. The extra body is mandatory on every
call.

| block | row `id` | server | extra body | splice source (`finish.jsonl` present) | to generate |
|---|---|---|---|---|--:|
| `fast-qwen38-iq3s-xhigh` | `qwen38-iq3s-xhigh` | run 19's | `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}` | none | 164 |
| `fast-bonsai2-ptq1-f16-xhigh` | `bonsai2-ptq1-f16-xhigh` | fork | `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}` | `bench24/results/bonsai2-ptq1-f16-evalplus-budget-xhigh` | 12 |
| `fast-bonsai2-pq2-f16-xhigh` | `bonsai2-pq2-f16-xhigh` | fork | same | `bench24/results/bonsai2-pq2-f16-evalplus-budget-xhigh` | 12 |
| `fast-bonsai2-ptq1-xhigh` | `bonsai2-ptq1-xhigh` | fork | same | `bench24/results/bonsai2-ptq1-evalplus-budget-xhigh` | 16 |
| `fast-bonsai2-pq2-xhigh` | `bonsai2-pq2-xhigh` | fork | same | `bench24/results/bonsai2-pq2-budget-xhigh` | 12 |
| `fast-bonsai2-ptq1-f16-orca-xhigh` | `bonsai2-ptq1-f16-orca-xhigh` | fork, with `--lora` as the row writes it | same | `bench27/results/orca-ptq1-f16-budget-xhigh` | 18 |
| `fast-gemma26-nvfp4-on` | `gemma26-nvfp4-on` | run 19's | `{"chat_template_kwargs":{"enable_thinking":true}}` | none | 164 |
| `fast-qwen36-q4kxl-on` | `qwen36-q4kxl-on` | run 19's | `{"chat_template_kwargs":{"enable_thinking":true}}` | none | 164 |
| `fast-gemma12-nvfp4-on` | `gemma12-nvfp4-on` | run 19's | `{"chat_template_kwargs":{"enable_thinking":true}}` | `bench21/results/gemma12-nvfp4-budget-on` | 45 |
| `fast-gemma12-q4kxl-on` | `gemma12-q4kxl-on` | run 19's | `{"chat_template_kwargs":{"enable_thinking":true}}` | none | 164 |
| `fast-qwen38-oblit-q3km-medium` | `qwen38-oblit-q3km-medium` | run 19's | `{"chat_template_kwargs":{"reasoning_effort":"medium"}}` | `bench23/results/qwen38-oblit-q3km-budget-medium` | 5 |

The "to generate" column is the planning count from the source's
finish log; the splice prints the real one. Every splice source is
under `hardware/arrietty/benchmarks/`. The two MoE rows keep their
`--n-cpu-moe` and drafter flags from the row command: a drafter never
changes an answer at temperature 0, and the row's arm is the arm that
serves.

The Qwen3.8 ISTA row (`qwen38-ista-xhigh`) already has its fast-mode
score from run 21 and is not in this run. The thinking-off rows have no
thinking and need no fast run. The Q4_K_M abliterated row has no score
and gets none here (the level is banned for this model beyond the row
the owner overruled).

## The fast block, one shape for every row

Read `docs/methodology/evalplus.md`, "Fast mode", "Reuse of an earlier
run: the splice" and "Steps", once, before the first block.

1. Serve the row's command as the table says, with `$FAST_FLAGS`. Wait
   for the load, record `nvidia-smi` in `state.md`.
2. Verify with one real chat completion at the row's level (the extra
   body): the response carries a reasoning field, `content` is not
   empty, and the server log shows no error. On a problem that thinks
   past 8192 tokens the reasoning tail must end with the budget
   message; a short probe that converges early does not show it, and
   that is fine. Record the probe in `state.md`.
3. Splice when the table names a source:
   ```bash
   python3 benchmarks/thinking-budget.py splice \
     hardware/arrietty/benchmarks/<source> \
     hardware/arrietty/benchmarks/bench28/results/<block> \
     --message "$BUDGET_MSG"
   ```
   Write the kept and to-generate counts in `state.md`. A source whose
   samples file name does not match the alias the row serves is stop
   and ask (the splice copies the file under its own name, and
   `run-humaneval.sh` resumes only a file named for the model id).
4. Start the watcher (`benchmarks/run-watch.sh`, checklist step 6),
   `RUNWATCH_SILENCE` at 2700: a forced problem runs 8192 thinking
   tokens plus its answer on one slot, and the probe must not read a
   busy server as dead.
5. Score:
   ```bash
   RESULTS_BASE=hardware/arrietty/benchmarks/bench28/results \
     EVALPLUS_MAX_NEW_TOKENS=16384 \
     benchmarks/run-humaneval.sh <block> <alias> '<extra body>'
   ```
   The script skips every problem the splice seeded. Wall parts in
   `state.md` as they happen, UTC, per `docs/methodology/evalplus.md`,
   "Crashes and wall time". A spliced block's wall is its own
   generation time plus the source's time for the kept problems: the
   source's `finish.jsonl` `wall_s` of every kept task id, summed;
   write both parts.
6. Count: `thinking-budget.py count` on the block directory. Then the
   block's table in `results.md`: base, plus, completion, empty
   (`N/164`), forced (`N/164`), the forced task ids, the empty task
   ids with their cause word, the wall with its parts, the splice
   source and the kept count. Beside it, the row's score before fast
   mode, from `docs/setups/arrietty/models.json`.
7. Stop the watcher and the server, wait for `vram_start_mb`, commit,
   push, message the coordinator, start the next block.

A forced answer is an answer. Nothing is re-run in this run: no proof
run, no natural re-run. An answer that ends on `length` at 16384 is
`budget`; write its task id, it is a finding.

## `retry-sweep`

The blocks that waited on a human, oldest first.

## Not in this run

- A calibration, a proof run, a natural re-run, any budget other than
  8192 and 16384.
- Any speed measurement, any agent row, any smoke.
- Effort medium on any Qwen3.8 file beyond the one row named above.
- Any file not already scored on this machine.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
changed and why, machine state left behind, evidence archived. Push and
message the coordinator. The coordinator writes `report.md`, adds the
findings to `hardware/arrietty/benchmarks/INDEX.md`, fills the fast
rows on the site (`evalplusRuns` with `think` 8192 and `forced`, the
row cells, `evalplus` out of `stale`) and publishes.
