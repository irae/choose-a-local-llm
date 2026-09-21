# Run 22 — the thinking budget on the Mac

Ready to start after run 20 ends, 2026-09-16. About two days of
machine time. The list below is the order and the run ends when the
list ends or the owner says stop. Run 21 runs the same test on the
Linux card; this run does not wait for it.

You are the runner, on the Mac. Read this file, then the pages each
block names at its start, and nothing else. Write all prose in
ASD-STE100 Simplified Technical English.

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
so each one gets its cause. Three configs of this Mac: the MoE 26B
GGUF at thinking on, the config with the most proven `budget` empties
at the 30000 cap; the dense 27B 4-bit at effort xhigh, the best score
of the project at the longest wall; and the ternary 27B fork, if its
server takes the flag, with one guided agent row under the budget. The
method text is `docs/methodology/evalplus.md`, "Unproven yet". This
run measures; it decides nothing.

## The order

**This list is the order.** The run changed to fast mode on 2026-09-19
(owner): the closed blocks stay as they ran; every block from
`bonsai-fork-fast-think` on follows "Fast mode" below.

- `machine-setup` (closed)
- `gemma26-gguf-calibrate-think` (closed)
- `gemma26-gguf-budget-think` (closed)
- `gemma26-gguf-forced-rerun` (closed)
- `qwen38-bartowski-calibrate-xhigh` (closed)
- `qwen38-bartowski-budget-xhigh` (closed)
- `qwen38-bartowski-forced-rerun` (closed)
- `bonsai-fork-calibrate-think` (closed)
- `bonsai-fork-fast-think`
- `fast-qwen38-gguf-xhigh`
- `fast-gemma26-gguf`
- `fast-bonsai2-ptq1-mac-xhigh`
- `fast-qwen38-gguf-unsloth-iq3s-xhigh`
- `fast-qwen38-gguf-ista-nodrafter-xhigh`
- `fast-qwen36-gguf-think`
- `bonsai-fork-budget-mendel-guided`
- `retry-sweep`

The blocks `bonsai-fork-budget-think` and `bonsai-fork-forced-rerun`
of the first list are gone: fast mode has no derived budget and no
forced re-run.

## Fast mode, from 2026-09-19 (owner)

Read `docs/methodology/evalplus.md`, "Fast mode", "Reuse of an earlier
run: the splice" and "Steps", once, before the first fast block. The
rule: the server closes the thinking at 8192 tokens and the model
answers, `max_tokens` 16384, no calibration, no forced re-run. This
replaces the derived budgets of the Essentials below for every block
that is not closed. `THINKING_BUDGET_MARGIN` and
`thinking-budget.py derive` are no longer used.

```bash
export BUDGET_MSG="Thinking budget reached. Give the final answer now."
export FAST_FLAGS="--reasoning-budget 8192 --reasoning-budget-message $BUDGET_MSG"
export EVALPLUS_MAX_NEW_TOKENS=16384
```

Every serve command of a fast block carries `$FAST_FLAGS` (quote
`"$BUDGET_MSG"` when you expand it by hand) and every
`run-humaneval.sh` call runs with `EVALPLUS_MAX_NEW_TOKENS=16384`.
Count from the files, never from a log line:
`python3 benchmarks/thinking-budget.py count <run-dir> --message
"$BUDGET_MSG"` prints the forced count from `finish.jsonl` and the
empty count from the samples. `RUNWATCH_SILENCE=2700` on every
scoring run. No download is approved: every file below is on the Mac;
a missing file is stop and ask.

### The fast table

One block per row. The serve command is the row's `command` in
`docs/setups/kamaji/models.json` (the `id` column) with three changes:
`-c 32768`, `$FAST_FLAGS` appended, and the fork binary on the ternary
rows (the Bonsai 2 row on the fork release run 26 recorded in
`hardware/kamaji/benchmarks/bench26/state.md`; the Bonsai 27B row on
`~/prism-llama/llama-server` with `LLAMA_ATTN_ROT_DISABLE=1`, the
`bonsai-fork-calibrate-think` command of this run's `state.md`). The
alias, the drafter and the KV type stay as the row writes them; a
drafter never changes an answer at temperature 0. The extra body is
mandatory on every call.

| block | row `id` | server | extra body | splice source (`finish.jsonl` present) | to generate |
|---|---|---|---|---|--:|
| `bonsai-fork-fast-think` | `bonsai-fork-single` | `~/prism-llama` fork | none (thinking on is the default) | none | 164 |
| `fast-qwen38-gguf-xhigh` | `qwen38-gguf-xhigh` | llama-server | `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}` | `bench22/results/qwen38-bartowski-budget-xhigh` (alias `qwen3.8-27b`) | 11 |
| `fast-gemma26-gguf` | `gemma26-gguf` | llama-server | `{"chat_template_kwargs":{"enable_thinking":true}}` | `bench22/results/gemma26-gguf-budget-think` | 19 |
| `fast-bonsai2-ptq1-mac-xhigh` | `bonsai2-ptq1-mac-xhigh` | fork (run 26's) | `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}` | `bench26/results/bonsai2-budget-xhigh-mac` | 10 |
| `fast-qwen38-gguf-unsloth-iq3s-xhigh` | `qwen38-gguf-unsloth-iq3s-xhigh` | llama-server | same | none | 164 |
| `fast-qwen38-gguf-ista-nodrafter-xhigh` | `qwen38-gguf-ista-nodrafter-xhigh` | llama-server | same | none | 164 |
| `fast-qwen36-gguf-think` | `qwen36-gguf-think` | llama-server | `{"chat_template_kwargs":{"enable_thinking":true}}` | none | 164 |

The "to generate" column is the planning count from the source's
finish log; the splice prints the real one. Every splice source is
under `hardware/kamaji/benchmarks/`. A splice source must have been
served under the same alias as the block serves (the samples file is
named for it); a mismatch is stop and ask.

Rows that share a score under the shared-score rule take the block's
result: `qwen36-gguf-f16` and `qwen36-gguf-f16-nodrafter` from
`fast-qwen36-gguf-think`, `gemma26-gguf-2x` from `fast-gemma26-gguf`,
`bonsai-fork-2x` from `bonsai-fork-fast-think`. The coordinator writes
them; the runner scores the one row.

Not scored: every MLX and LM Studio row (`mlx_lm` does not enforce a
thinking budget), every thinking-off row (no thinking), and every
effort-medium and effort-low row of the dense 27B (owner, 2026-09-19:
they keep their earlier score with the marker).

### The fast block, one shape for every row

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
     hardware/kamaji/benchmarks/bench22/results/<block> \
     --message "$BUDGET_MSG"
   ```
   Write the kept and to-generate counts in `state.md`.
4. Start the watcher, `RUNWATCH_SILENCE=2700`.
5. Score:
   ```bash
   RESULTS_BASE=hardware/kamaji/benchmarks/bench22/results \
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

A forced answer is an answer. Nothing is re-run: no proof run, no
natural re-run. An answer that ends on `length` at 16384 is `budget`;
write its task id, it is a finding.

## Essentials

- `bench22/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION after the wakeup:** `git fetch origin && git worktree
  add ../choose-a-local-llm-run22 -b run22 origin/master` (or `cd` into
  it if it exists), then `cd ../choose-a-local-llm-run22`. Verify with
  `pwd` and `git worktree list`. Every command of this run happens
  there.
- **Branches, exactly.** You work on `run22` and only on `run22`. To
  take an update: `git fetch origin && git merge origin/master`, then
  push `run22`. Never check out `master`, never merge `run22` into
  `master`, never push `master`.
- Then `docs/methodology/checklist.md` and
  `docs/methodology/status-lines.md`, whole, once per session.
  `tools/preflight.sh` first, every line `ok` before a block starts.
  Never sudo, never reboot on your own.
- **Wired limit: 25000.** Verify with `sysctl -n iogpu.wired_limit_mb`.
  Any other value is stop and ask.
- One model on the GPU at a time, port 8081. Before you start a
  server, `pgrep -fl "llama-server|mlx_lm"` must be empty. Never kill a
  server you did not start. Quit the LM Studio app first.
- **Downloads.** On the Mac a download needs the owner's approval. None
  is approved for this run: every model file named below was served
  before on this Mac. A missing file, or a missing bias file for the
  fork, is stop and ask; skip that block and start the next.
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
  Run 21 on the Linux card runs the same test first. If a coordinator
  message names a new margin before a `*-calibrate-*` block starts,
  use it for that block and every later one, and write the value and
  the message time in `state.md`. Never wait for one: a block that
  starts on 1.5 finishes on 1.5, and the owner accepts the parallel
  work (2026-09-16).
- **Count empties from the samples, never from a log line.** After
  every scoring run:

  ```bash
  python3 -c 'import json,sys;print(sum(1 for l in open(sys.argv[1]) if l.strip() and not json.loads(l)["solution"].strip()))' \
    hardware/kamaji/benchmarks/bench22/results/<mnemonic>/humaneval/<alias>_openai_temp_0.0.raw.jsonl
  ```

  The forced count is the number of `finish.jsonl` lines whose
  `reasoning_tail` contains `$BUDGET_MSG`:

  ```bash
  python3 -c 'import json,sys,os;m=os.environ["BUDGET_MSG"];print(sum(1 for l in open(sys.argv[1]) if l.strip() and m in (json.loads(l).get("reasoning_tail") or "")))' \
    hardware/kamaji/benchmarks/bench22/results/<mnemonic>/finish.jsonl
  ```

  Both numbers go in the result line.
- Every scoring run starts `benchmarks/run-watch.sh` as the checklist
  says.
- **Crashes and wall:** `docs/methodology/evalplus.md`, "Crashes and
  wall time". Write every part in `state.md` in UTC.
- Commit on `run22` as results land. Push `run22` at every block close
  and message the coordinator session `local-llm coordinator sept-16`
  with the block, the config, the result line and the commit id. **No
  message between pushes** (owner rule, 2026-09-11). Every gate and
  every stop-and-ask goes to the coordinator with the block, the
  condition and your candidate answer; keep the GPU busy with the next
  block that does not depend on it. Never message the Linux runner;
  the coordinator relays what a gate needs. Never ask the owner a
  multiple-choice question. Never run a bare `git stash`.
- **A recoverable failure is retried at once, inside its block.**
  Resume the same run directory; `run-humaneval.sh` skips the problems
  it already has. `retry-sweep` holds only what needed a human.
- A bug in a run tool goes to a subagent on the best available model
  at once; the run does not wait for it.
- Archive evidence before a session closes:
  `tools/archive-evidence.sh hardware/kamaji/benchmarks/bench22/results run22`.
- Every file a block writes goes under
  `hardware/kamaji/benchmarks/bench22/results/`,
  `hardware/kamaji/calibrations/` or under `~/.local/share/`. Nothing
  under `/tmp`.

## `machine-setup`

Read `docs/methodology/evalplus.md`, whole, with "Unproven yet".

1. `git log --oneline -1 -- benchmarks/thinking-budget.py
   benchmarks/calibrate.py benchmarks/run_codegen_wrapper.py`: all
   three must be present and `calibrate.py` must write
   `reasoning_len` (grep it). If not, `git fetch origin && git merge
   origin/master` first.
2. `llama-server --version` and `llama-server --help | grep -A1
   reasoning-budget`: both flags must print. A build without them is
   stop and ask. Then `~/prism-llama/llama-server --help | grep -A1
   reasoning-budget`; write `fork_has_reasoning_budget` = `yes` or
   `no` in `state.md`. `no` drops the four `bonsai-fork-*` blocks;
   write that under each of them in `state.md` and `results.md`.
3. Confirm the EvalPlus venv: `evalplus.codegen --help | head -2`.
4. **The message probe.** Serve the MoE 26B GGUF as its budget block
   below says, with `--reasoning-budget 32`, thinking on. Send one
   chat completion with `curl` (a short problem, `max_tokens` 2048,
   thinking on in the body) and read the JSON:
   `.choices[0].message.reasoning_content` must end with `$BUDGET_MSG`,
   `.choices[0].message.content` must not be empty, and
   `.usage.completion_tokens_details` is recorded whether present or
   not. A response with no `reasoning_content` field, or a tail
   without the message, is stop and ask: the finish log cannot count
   forced answers then, and no budget block starts. Stop the server.
   If `fork_has_reasoning_budget` is `yes`, repeat the probe once on
   the fork with the Bonsai file before its blocks.

Done: versions, the probe results and the message in `state.md`,
committed.

## The calibrate blocks (closed blocks; the shape they ran in before fast mode)

Each block writes a new calibration file, because the old files carry
no reasoning length and `calibrate.py` resumes a file that exists. The
name in the table is new.

1. **Serve** the block's config, without a thinking budget.
2. **Calibrate**, extra body mandatory where the table has one:

   ```bash
   CALIBRATION_DIR=hardware/kamaji/calibrations benchmarks/calibrate.py <calibration> <alias> ['<extra body>']
   ```

   Check `resolved_reasoning_effort` or the thinking switch on every
   row.
3. **Derive**:

   ```bash
   benchmarks/thinking-budget.py derive hardware/kamaji/calibrations/calibration-<calibration>.json
   ```

   Write `<config>_think_budget`, `<config>_answer_budget` and
   `<config>_max_tokens` in `state.md` with the converged and cut
   counts and the margin used. Keep the server up for the budget
   block.

Done: the three values in `state.md`, committed.

## The budget blocks (closed blocks; the shape they ran in before fast mode)

1. **Serve** the config's command from the table with the thinking
   budget appended, `-c 32768`:

   ```
   --reasoning-budget <think budget> --reasoning-budget-message "$BUDGET_MSG"
   ```

   The think budget is the block's value from `state.md`. Verify with a
   real request; write the wired reading in `state.md`.
2. **Start the watcher** as the checklist says.
3. **Run** the full 164:

   ```bash
   RESULTS_BASE=hardware/kamaji/benchmarks/bench22/results \
     EVALPLUS_MAX_NEW_TOKENS=<max_tokens of the block> \
     benchmarks/run-humaneval.sh <mnemonic> <alias> ['<extra body>']
   ```

4. **Done**: base and plus pass@1, the empty count from the samples,
   the forced count from the finish log, the think and answer budgets,
   `max_tokens` and the wall with its parts. One table row in
   `results.md` beside the natural run of the same config from
   `docs/setups/kamaji/models.json` (`evalplusRuns`: base, plus,
   empty, budget and wall). Commit, push, message the coordinator.
   Stop the watcher. Keep the server up only if the next block is the
   same config without the budget; else stop it and wait for wired
   memory to recover.

## The forced re-run blocks (closed blocks; the shape they ran in before fast mode)

The natural re-run of the problems where the budget fired and the
answer failed, without the flag, at a generous budget.

1. **Prepare** from the budget block's directory:

   ```bash
   benchmarks/thinking-budget.py prepare \
     hardware/kamaji/benchmarks/bench22/results/<budget mnemonic> \
     hardware/kamaji/benchmarks/bench22/results/<mnemonic> \
     --message "$BUDGET_MSG"
   ```

   Zero forced-failed problems: write that in `results.md` and
   `state.md`, skip the rest of the block, start the next.
2. **Serve** the same config without the two reasoning flags.
3. **Start the watcher.**
4. **Run** at the generous budget; the script generates only the
   removed problems:

   ```bash
   RESULTS_BASE=hardware/kamaji/benchmarks/bench22/results \
     EVALPLUS_MAX_NEW_TOKENS=30000 \
     benchmarks/run-humaneval.sh <mnemonic> <alias> ['<extra body>']
   ```

5. **Report**:

   ```bash
   benchmarks/thinking-budget.py report \
     hardware/kamaji/benchmarks/bench22/results/<budget mnemonic> \
     hardware/kamaji/benchmarks/bench22/results/<mnemonic> \
     --message "$BUDGET_MSG"
   ```

6. **Done**: the report's table in `results.md` as it prints, the
   summary line, the corrected think budget line, and the re-run wall
   with its parts. Commit, push, message the coordinator. Stop the
   watcher and the server, wait for wired memory to recover.

## The table (closed blocks; the shape they ran in before fast mode)

| config | serve command (the source bench holds the exact files and flags) | alias | extra body | calibration | blocks |
|---|---|---|---|---|---|
| MoE 26B GGUF, thinking on | `llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL --alias gemma-4-26b-a4b --no-mmproj --spec-type draft-mtp --spec-draft-n-max 2 --parallel 1 -ngl 999 -fa on -c 32768 --cache-type-k f16 --cache-type-v f16 --jinja --port 8081` (`bench10`, `gemma26-gguf-think`) | `gemma-4-26b-a4b` | `{"chat_template_kwargs":{"enable_thinking":true}}` | `gemma26-gguf-think-budget` | `gemma26-gguf-calibrate-think`, `gemma26-gguf-budget-think`, `gemma26-gguf-forced-rerun` |
| dense 27B 4-bit, effort xhigh | `llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M --alias qwen3.8-27b --no-mmproj --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 -ngl 999 -fa on -c 32768 --cache-type-k f16 --cache-type-v f16 --jinja --port 8081` (`bench15`, `bartowski-evalplus-xhigh`) | `qwen3.8-27b` | `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}` | `qwen38-bartowski-xhigh-budget` | `qwen38-bartowski-calibrate-xhigh`, `qwen38-bartowski-budget-xhigh`, `qwen38-bartowski-forced-rerun` |
| ternary 27B fork, thinking on | the `bonsai-fork-rerun` command of `bench20/state.md`: `LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server`, the Q2_g64 file, no drafter, `-c 32768`, q4_0/q4_0 KV, the bias file, alias `bonsai-prism` | `bonsai-prism` | none | `bonsai-fork-think-budget` | `bonsai-fork-calibrate-think`, `bonsai-fork-budget-think`, `bonsai-fork-forced-rerun`, `bonsai-fork-budget-mendel-guided`; all four only when `fork_has_reasoning_budget` is `yes` |

The natural runs to compare against, planning snapshot from
`docs/setups/kamaji/models.json` (read the newest values there): the
MoE 26B at thinking on scored 0.896/0.872 with 16 of 164 empty at
budget 30000 in 347.0 min; the dense 27B 4-bit at xhigh scored
0.957/0.939 with 6 of 164 empty at budget 30000 in 510.3 min; the
fork scored 0.927/0.890 with 4 of 164 empty at budget 10240 in
594.8 min.

## `bonsai-fork-budget-mendel-guided`

Only when `fork_has_reasoning_budget` is `yes`. Read
`docs/methodology/mendel.md`, "House rules" and "Window and budget".
The guided agent row of the fork, thinking on, with the thinking
budget on the server: the same row the fork scored 31.5 on
(`bonsai-prism high guided`, q4_0 KV + bias), so the pair is the same
config with and without the budget. Fixed: the fork build, the Q2_g64
file, the bias file, q4_0 KV, prompt guided v3, level high. Derived:
the window from the row's `pi` block in `docs/setups/kamaji/models.json`
(planning value 65536); the harness output budget 8192 as the worker
pins it; the think budget is 8192, fast mode (owner, 2026-09-19).

1. `gh auth status`, `git stash clear` in `~/code/mendel-benchmark`.
2. Serve the fork with the row's serving `-c` from its report page
   (not 32768) and `$FAST_FLAGS` appended.
3. `cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<window> ./run-worker.sh bonsai-prism pi guided high`,
   with the watcher at `RUNWATCH_SILENCE=2700`. Score per `PLAN.md`
   in a subagent on the best available model.
4. `model_id` names the fork build; the config note carries
   `reasoning budget <N>, message fixed`, the KV type, `-c`, the
   window, the harness reserve and `wired 25000`. Verify
   `peak_context` with the counter before the row commits.
5. Done: score, libraries, end reason, wall, the number of turns where
   the budget fired (grep the session log's reasoning for
   `$BUDGET_MSG`), and `loop-check.py`'s verdict on the session log.
   One row in `results.md` beside the 31.5 row. Commit, push, message
   the coordinator. `pkill -f "Mendel Daemon"`.

## `retry-sweep`

The blocks that waited on a human, oldest first.

## Not in this run

- Any MLX or LM Studio server: `mlx_lm` does not enforce a thinking
  budget (2026-09-16); those rows keep the output budget rule.
- Speed sweeps, any other model, any other level, any other Mendel
  row.
- Any change to the margin on your own reading of a re-run.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
dropped and why, machine state, evidence archived. Push and message
the coordinator. The coordinator writes `report.md`, adds the findings
to `hardware/kamaji/benchmarks/INDEX.md`, decides what reaches the
site, and publishes.
