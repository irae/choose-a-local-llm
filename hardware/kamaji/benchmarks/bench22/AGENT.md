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

**This list is the order.**

- `machine-setup`
- `gemma26-gguf-calibrate-think`
- `gemma26-gguf-budget-think`
- `gemma26-gguf-forced-rerun`
- `qwen38-bartowski-calibrate-xhigh`
- `qwen38-bartowski-budget-xhigh`
- `qwen38-bartowski-forced-rerun`
- `bonsai-fork-calibrate-think`
- `bonsai-fork-budget-think`
- `bonsai-fork-forced-rerun`
- `bonsai-fork-budget-mendel-guided`
- `retry-sweep`

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

## The calibrate blocks

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

## The budget blocks

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

## The forced re-run blocks

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

## The table

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
pins it; the think budget is `bonsai-fork-think_think_budget` from
`state.md`.

1. `gh auth status`, `git stash clear` in `~/code/mendel-benchmark`.
2. Serve the fork with the row's serving `-c` from its report page
   (not 32768) and the two reasoning flags appended.
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
