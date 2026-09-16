# Run 21 — the thinking budget on the RTX 5060 Ti 16 GB (Linux)

Ready to start after run 19 ends, 2026-09-16. About one day of machine
time. The list below is the order and the run ends when the list ends
or the owner says stop.

You are the runner, on the Linux machine. Read this file, then the
pages each block names at its start, and nothing else. Write all prose
in ASD-STE100 Simplified Technical English.

## Wakeup, every 20 minutes (mandatory)

**Before any other action, schedule `ScheduleWakeup` with 1200
seconds. At every wakeup, schedule the next one. Do this from the
first action to the end of the run, also while a background task, a
`Monitor` or `run-watch.sh` runs** (owner rule, 2026-09-15,
`docs/methodology/checklist.md`, step 7).

The majority of agents that thought a background task was enough were
wrong, and their runs stalled until a person came back. The wakeup is
also for human inspection: at every wakeup send the short status line
(`docs/methodology/status-lines.md`), so the owner can read the run at
any time. A wakeup with nothing new still sends its line and schedules
the next one. If `ScheduleWakeup` is not available in your session,
tell the coordinator before the first block.

## What this run is for

The owner's word (2026-09-16): an EvalPlus run under a thinking budget
on the server, so a problem whose thinking does not converge still
gets an answer, and the run counts those problems. Then a natural
re-run of the problems where the budget fired and the answer failed,
so each one gets its cause. Two configs of run 19: the one that lost
a third of its answers to thinking that never ended, and the one with
the best agent score on this card. The method text is
`docs/methodology/evalplus.md`, "Unproven yet". This run measures; it
decides nothing.

## The order

**This list is the order.**

- `machine-setup`
- `gemma12-nvfp4-calibrate-think`
- `gemma12-nvfp4-budget-on`
- `gemma12-nvfp4-forced-rerun`
- `qwen38-ista-calibrate-think`
- `qwen38-ista-budget-xhigh`
- `qwen38-ista-forced-rerun`
- `qwen38-ista-budget8192-xhigh`
- `qwen38-ista-forced-rerun-8192`
- `retry-sweep`

## Essentials

- `bench21/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION after the wakeup:** `git fetch origin && git worktree
  add ../choose-a-local-llm-run21 -b run21 origin/master` (or `cd` into
  it if it exists), then `cd ../choose-a-local-llm-run21`. Verify with
  `pwd` and `git worktree list`. Every command of this run happens
  there.
- **Branches, exactly.** You work on `run21` and only on `run21`. To
  take an update: `git fetch origin && git merge origin/master`, then
  push `run21`. Never check out `master`, never merge `run21` into
  `master`, never push `master`.
- Then `docs/methodology/checklist.md` and
  `docs/methodology/status-lines.md`, whole, once per session.
- **This machine is Linux, not the Mac.** Read run 19's runbook,
  `hardware/arrietty/benchmarks/bench19/AGENT.md`, section
  "Essentials", from "This machine is Linux" to the end of the list,
  and do the same here: the read-only machine checks, `vram 16311
  MiB`, the CUDA death signatures, the CUDA exports in every new
  shell, one model on the GPU at a time on port 8081, the desktop
  shares the card, no sudo, downloads never block, `hf cache ls`.
- **The budget message is fixed for the whole run**, in every serve
  command that carries a thinking budget:

  ```bash
  export BUDGET_MSG="Thinking budget reached. Give the final answer now."
  ```

  The finish log keeps the last 200 characters of the reasoning, and
  the message lands there, so a forced answer is one whose reasoning
  tail contains it.
- **No temperature and no sampling parameter is passed to any
  server.** EvalPlus sends temperature 0 itself.
- **Effort medium is banned for Qwen3.8** (owner rule, 2026-09-09).
- **The margin.** `THINKING_BUDGET_MARGIN` is 1.5, the planning value.
  Run 22 on the Mac runs the same test. If a coordinator message names
  a new margin before a `*-calibrate-*` block starts, use it for that
  block and every later one, and write the value and the message time
  in `state.md`. Never wait for one.
- **Count empties from the samples, never from a log line.** After
  every scoring run:

  ```bash
  python3 -c 'import json,sys;print(sum(1 for l in open(sys.argv[1]) if l.strip() and not json.loads(l)["solution"].strip()))' \
    hardware/arrietty/benchmarks/bench21/results/<mnemonic>/humaneval/<alias>_openai_temp_0.0.raw.jsonl
  ```

  The forced count is the number of `finish.jsonl` lines whose
  `reasoning_tail` contains `$BUDGET_MSG`:

  ```bash
  python3 -c 'import json,sys,os;m=os.environ["BUDGET_MSG"];print(sum(1 for l in open(sys.argv[1]) if l.strip() and m in (json.loads(l).get("reasoning_tail") or "")))' \
    hardware/arrietty/benchmarks/bench21/results/<mnemonic>/finish.jsonl
  ```

  Both numbers go in the result line. Run 19's runner wrote `0/164
  empty` on rows whose samples held up to 53 empty answers; the
  coordinator corrected the site. Do not repeat that.
- Every scoring run starts `benchmarks/run-watch.sh` as the checklist
  says, with the CUDA signatures.
- **Crashes and wall:** `docs/methodology/evalplus.md`, "Crashes and
  wall time". Write every part in `state.md` in UTC.
- Commit on `run21` as results land. Push `run21` at every block close
  and message the coordinator session `local-llm coordinator sept-16`
  with the block, the config, the result line and the commit id. **No
  message between pushes** (owner rule, 2026-09-11). Every gate and
  every stop-and-ask goes to the coordinator with the block, the
  condition and your candidate answer; keep the GPU busy with the next
  block that does not depend on it. Never message the Mac runner; the
  coordinator relays what a gate needs. Never ask the owner a
  multiple-choice question. Never run a bare `git stash`.
- **A recoverable failure is retried at once, inside its block.**
  Resume the same run directory; `run-humaneval.sh` skips the problems
  it already has. `retry-sweep` holds only what needed a human.
- A bug in a run tool goes to a subagent on the best available model
  at once; the run does not wait for it.
- Archive evidence before a session closes:
  `tools/archive-evidence.sh hardware/arrietty/benchmarks/bench21/results run21`.
- Every file a block writes goes under
  `hardware/arrietty/benchmarks/bench21/results/`,
  `hardware/arrietty/calibrations/` or
  `~/.local/share/choose-a-local-llm/`. Nothing under `/tmp`.

## `machine-setup`

Read `docs/methodology/evalplus.md`, whole, with "Unproven yet".

1. `git log --oneline -1 -- benchmarks/thinking-budget.py
   benchmarks/calibrate.py benchmarks/run_codegen_wrapper.py`: all
   three must be present and `calibrate.py` must write
   `reasoning_len` (grep it). If not, `git fetch origin && git merge
   origin/master` first.
2. The CUDA exports, then `llama-server --help | grep -A1
   reasoning-budget`: both flags must print. A build without them is
   stop and ask.
3. `export EVALPLUS_PYTHON=...` as run 19's `machine-setup` step 1
   says; `evalplus.codegen --help | head -2`.
4. **The message probe.** Serve the dense 12B NVFP4 file as its budget
   block below says, with `--reasoning-budget 32`, thinking on. Send
   one chat completion with `curl` (a short problem, `max_tokens`
   2048, thinking on in the body) and read the JSON:
   `.choices[0].message.reasoning_content` must end with `$BUDGET_MSG`,
   `.choices[0].message.content` must not be empty, and
   `.usage.completion_tokens_details` is recorded whether present or
   not. A response with no `reasoning_content` field, or a tail
   without the message, is stop and ask: the finish log cannot count
   forced answers then, and no budget block starts. Stop the server.
5. `mkdir -p hardware/arrietty/benchmarks/bench21/results`.

Done: versions, the probe result and the message in `state.md`,
committed.

## The calibrate blocks

Each block writes a new calibration file, because the run 19 files
carry no reasoning length and `calibrate.py` resumes a file that
exists. The name in the table is new.

1. **Serve** the block's config, without a thinking budget, with the
   arm the table names.
2. **Calibrate**, extra body mandatory:

   ```bash
   CALIBRATION_DIR=hardware/arrietty/calibrations "$EVALPLUS_PYTHON" benchmarks/calibrate.py <calibration> <alias> '<extra body>'
   ```

   Check `resolved_reasoning_effort` or the thinking switch on every
   row.
3. **Derive**:

   ```bash
   benchmarks/thinking-budget.py derive hardware/arrietty/calibrations/calibration-<calibration>.json
   ```

   Write `<config>_think_budget`, `<config>_answer_budget` and
   `<config>_max_tokens` in `state.md` with the converged and cut
   counts and the margin used. Keep the server up for the budget
   block.

Done: the three values in `state.md`, committed.

## The budget blocks

1. **Serve** the config with the thinking budget appended to the arm:

   ```bash
   llama-server -m "$(hf download <repo> <file>)" \
     --alias <alias> --no-mmproj --parallel 1 <arm flags> \
     -ngl 999 --fit off -fa on -c 32768 \
     --cache-type-k <kv> --cache-type-v <kv> \
     --reasoning-budget <think budget> --reasoning-budget-message "$BUDGET_MSG" \
     --jinja --port 8081 2>&1 \
     | tee hardware/arrietty/benchmarks/bench21/results/server-<mnemonic>.log
   ```

   The think budget is the block's value from `state.md`; for
   `qwen38-ista-budget8192-xhigh` it is 8192, an owner-chosen round
   value for a second point on the curve (run decision, 2026-09-16),
   with the same answer budget as the calibrated block. Verify with a
   real request, read `nvidia-smi`, write both in `state.md`. A `CUDA
   error` death is the fallback arm of the table, inside the block.
2. **Start the watcher** as the checklist says.
3. **Run** the full 164:

   ```bash
   RESULTS_BASE=hardware/arrietty/benchmarks/bench21/results \
     EVALPLUS_MAX_NEW_TOKENS=<max_tokens of the block> \
     benchmarks/run-humaneval.sh <mnemonic> <alias> '<extra body>'
   ```

   For `qwen38-ista-budget8192-xhigh`, `max_tokens` is 8192 plus the
   answer budget.
4. **Done**: base and plus pass@1, the empty count from the samples,
   the forced count from the finish log, the think and answer budgets,
   `max_tokens`, the served arm and the wall with its parts. One table
   row in `results.md` beside the natural run of the same config from
   `docs/setups/arrietty/models.json` (`evalplusRuns`: the row's base,
   plus, empty, budget and wall). Commit, push, message the
   coordinator. Stop the watcher. Keep the server up only if the next
   block is the same config without the budget; else stop it and wait
   for `vram_start_mb`.

## The forced re-run blocks

The natural re-run of the problems where the budget fired and the
answer failed, without the flag, at a generous budget.

1. **Prepare** from the budget block's directory:

   ```bash
   benchmarks/thinking-budget.py prepare \
     hardware/arrietty/benchmarks/bench21/results/<budget mnemonic> \
     hardware/arrietty/benchmarks/bench21/results/<mnemonic> \
     --message "$BUDGET_MSG"
   ```

   It prints the forced count, the forced-failed count and their ids,
   and copies the samples without them. Zero forced-failed problems:
   write that in `results.md` and `state.md`, skip the rest of the
   block, start the next.
2. **Serve** the same config without the two reasoning flags, same arm.
3. **Start the watcher.**
4. **Run** at the generous budget; the script generates only the
   removed problems:

   ```bash
   RESULTS_BASE=hardware/arrietty/benchmarks/bench21/results \
     EVALPLUS_MAX_NEW_TOKENS=30000 \
     benchmarks/run-humaneval.sh <mnemonic> <alias> '<extra body>'
   ```

5. **Report**:

   ```bash
   benchmarks/thinking-budget.py report \
     hardware/arrietty/benchmarks/bench21/results/<budget mnemonic> \
     hardware/arrietty/benchmarks/bench21/results/<mnemonic> \
     --message "$BUDGET_MSG"
   ```

6. **Done**: the report's table in `results.md` as it prints, the
   summary line, the corrected think budget line, and the re-run wall
   with its parts. Commit, push, message the coordinator. Stop the
   watcher and the server, wait for `vram_start_mb`.

## The table

| config | file (`<repo>` and `<file>` for `hf download <repo> <file>`) | alias | kv | arm flags | fallback arm | extra body | calibration | calibrate block | budget block | forced re-run block |
|---|---|---|---|---|---|---|---|---|---|---|
| dense 12B NVFP4, thinking on | `FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF/gemma-4-12b-it-nvfp4.gguf` | `gemma-4-12b-nvfp4` | `f16` | none | none | `{"chat_template_kwargs":{"enable_thinking":true}}` | `gemma12-nvfp4-on-think` | `gemma12-nvfp4-calibrate-think` | `gemma12-nvfp4-budget-on` | `gemma12-nvfp4-forced-rerun` |
| dense 27B ISTA 3-bit, effort xhigh | `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF/Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf` | `qwen3.8-27b-ista` | `q8_0` | none (the arm that ran clean in run 19; a drafter never changes an answer) | none | `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}` | `qwen38-ista-xhigh-think` | `qwen38-ista-calibrate-think` | `qwen38-ista-budget-xhigh`, then `qwen38-ista-budget8192-xhigh` | `qwen38-ista-forced-rerun`, then `qwen38-ista-forced-rerun-8192` |

The natural runs to compare against, planning snapshot from
`docs/setups/arrietty/models.json` (read the newest values there):
the 12B at thinking on scored 0.659/0.640 with 53 of 164 empty at
budget 8192 in 203.9 min; the 27B at xhigh scored 0.945/0.909 with 7
of 164 empty at budget 20500 in 217.6 min.

## `retry-sweep`

The blocks that waited on a human, oldest first. A run the machine
killed was already resumed inside its block.

## Not in this run

- Speed sweeps, Mendel rows, any other model, any other level, a KV
  type other than the table's, any MLX or LM Studio server.
- Any change to the margin on your own reading of a re-run.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
changed and why, machine state left behind, evidence archived. Push
and message the coordinator. The coordinator writes `report.md`, adds
the findings to `hardware/arrietty/benchmarks/INDEX.md`, decides what
reaches the site, and publishes.
