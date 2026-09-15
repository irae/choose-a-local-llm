# Run 20 — re-run the empty EvalPlus problems (Mac)

Ready to start after run 18 ends, 2026-09-15. A short run: seven blocks,
each re-running only a few problems of a scored EvalPlus run. The list
below is the order and the run ends when the list ends or the owner says
stop.

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

The owner's word (2026-09-15): some scored EvalPlus runs have empty
answers whose cause is unproven. An empty answer is either the output
budget cutting the answer (finish reason `length`) or the model ending
with no code (finish reason `stop`). The saved samples of those runs do
not record which. This run re-runs only the empty problems of each run,
with the same model, KV type, thinking level and budget, so
`finish.jsonl` records the cause of each one, and the run's score is
evaluated again on the full 164.

## The order

**This list is the order.**

- `machine-setup`
- `qwen38-ista-medium-rerun`
- `qwen38-ista-low-rerun`
- `bonsai-fork-rerun`
- `bonsai-mlx-rerun`
- `qwen36-gguf-think-rerun`
- `gemma26-gguf-think-rerun`
- `gemma26-mlx-think-rerun`
- `retry-sweep`

## Essentials

- `bench20/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION after the wakeup:** `git fetch origin && git worktree
  add ../choose-a-local-llm-run20 -b run20 origin/master` (or `cd` into
  it if it exists), then `cd ../choose-a-local-llm-run20`. Verify with
  `pwd` and `git worktree list`. Every command of this run happens
  there.
- **Branches, exactly.** You work on `run20` and only on `run20`. To
  take an update: `git fetch origin && git merge origin/master`, then
  push `run20`. Never check out `master`, never merge `run20` into
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
- **No temperature and no sampling parameter is passed to any
  server.** EvalPlus sends temperature 0 itself.
- **Effort medium is banned for new Qwen3.8 rows** (owner rule,
  2026-09-09). The medium block here re-runs one problem of an existing
  row; it adds no new row.
- Every scoring run starts `benchmarks/run-watch.sh` as the checklist
  says.
- **Crashes and wall:** `docs/methodology/evalplus.md`, "Crashes and
  wall time". Write every part in `state.md` in UTC.
- Commit on `run20` as results land. Push `run20` at every block close
  and message the coordinator session `local-llm coordinator sept-14`
  with the block, the result line and the commit id. **No message
  between pushes.** Every gate and every stop-and-ask goes to the
  coordinator with the block, the condition and your candidate answer;
  keep the GPU busy with the next block that does not depend on it.
  Never ask the owner a multiple-choice question. Never run a bare
  `git stash`.
- A bug in a run tool goes to a subagent on the best available model
  at once; the run does not wait for it.
- Archive evidence before a session closes:
  `tools/archive-evidence.sh hardware/kamaji/benchmarks/bench20/results run20`.
- Every file a block writes goes under
  `hardware/kamaji/benchmarks/bench20/results/` or under
  `~/.local/share/`. Nothing under `/tmp`.

## `machine-setup`

1. `git log --oneline -1 -- benchmarks/run_codegen_wrapper.py
   benchmarks/run-humaneval.sh`: both must carry the finish-log change
   (`run-humaneval.sh` exports `EVALPLUS_FINISH_LOG`). If not, merge
   `origin/master` first.
2. Confirm the EvalPlus venv: `evalplus.codegen --help | head -2`.
3. Record `llama-server --version`, `pip show mlx-lm | grep Version` (in
   the venv the MLX blocks use) and `~/prism-llama/llama-server
   --version` in `state.md`. These differ from the original runs; the
   re-run is a new measurement of those problems on today's builds.

Done: versions in `state.md`, committed.

## The re-run blocks

Every block below has the same steps. Its row in the table gives the
values. Read `docs/methodology/evalplus.md`, whole, once.

1. **Copy the samples.** Copy the source folder's `humaneval/` files
   (`<file>.jsonl` and `<file>.raw.jsonl`) into
   `hardware/kamaji/benchmarks/bench20/results/<mnemonic>/humaneval/`.
   Do not touch the source folder.
2. **Remove the empty problems.** In both copied files, delete the
   lines whose `task_id` is in the block's list. Check: the `.jsonl`
   file then has 164 minus that many lines.
3. **Serve.** Use the serve command of the source run, from the source
   bench named in the table (its `AGENT.md`, `state.md`, or the server
   script it names), with the same model file, KV type, drafter and
   flags, and `-c 32768` for a llama-server block. The alias must equal
   the samples file prefix in the table, so EvalPlus writes to the
   copied files. If you cannot find the source command, stop and ask.
4. **Start the watcher** as the checklist says.
5. **Run.** `run-humaneval.sh` generates only the removed problems:

   ```bash
   RESULTS_BASE=hardware/kamaji/benchmarks/bench20/results \
     EVALPLUS_MAX_NEW_TOKENS=<budget> \
     benchmarks/run-humaneval.sh <mnemonic> <alias> ['<extra body>']
   ```

   Pass the extra body exactly as the table gives it; `none` means no
   third argument, as the source run did.
6. **Done.** In `results.md`, one line per re-run problem: task id,
   `finish_reason`, `completion_tokens` (from `finish.jsonl`), and pass
   or fail (from `<file>_eval_results.json`). Then the run's new base
   and plus pass@1 and empty count on all 164, the cause counts (`cap`:
   empty with `length`; `model`: empty with `stop`), and the re-run
   wall in minutes with its parts. Commit, push, message the
   coordinator. Stop the watcher and the server, wait for wired memory
   to recover, start the next block.

| mnemonic | source folder (under `hardware/kamaji/benchmarks/`) | source bench for the serve command | samples file prefix = alias | extra body | budget | empty task ids |
|---|---|---|---|---|--:|---|
| `qwen38-ista-medium-rerun` | `bench12/results/qwen38-ista-mtp` | `bench12` | `qwen3.8-27b` | `{"chat_template_kwargs":{"reasoning_effort":"medium"}}` | 8192 | 39 |
| `qwen38-ista-low-rerun` | `bench13/results/ista-evalplus-low` | `bench13` | `qwen3.8-27b` | `{"chat_template_kwargs":{"reasoning_effort":"low"}}` | 8192 | 39 |
| `bonsai-fork-rerun` | `bench3/results/bonsai-prism` | `bench3`, `bench4` | `bonsai-prism` | none | 10240 | 47, 84, 97, 129 |
| `bonsai-mlx-rerun` | `bench2/results/bonsai-think` | `bench2` (`benchmarks/bench1/30-server-bonsai.sh`) | `prism-ml/Ternary-Bonsai-27B-mlx-2bit` | none | 10240 | 39, 99, 107, 122, 129 |
| `qwen36-gguf-think-rerun` | `bench2/results/qwen36-think` | `bench2` (`benchmarks/bench1/20-server-qwen36.sh`) | `qwen3.6-35b-a3b` | none | 26624 | 4, 23, 55, 107, 121 |
| `gemma26-gguf-think-rerun` | `bench10/results/gemma26-gguf-think` | `bench10` | `gemma-4-26b-a4b` | `{"chat_template_kwargs":{"enable_thinking":true}}` | 30000 | 33, 38, 40, 41, 62, 86, 93, 94, 105, 108, 115, 130, 141, 145, 147, 153, 158, 160 |
| `gemma26-mlx-think-rerun` | `bench3/results/gemma26-mlx` | `bench3` | `mlx-community/gemma-4-26b-a4b-it-4bit` | `{"chat_template_kwargs":{"enable_thinking":true}}` | 30000 | 1, 10, 17, 32, 33, 38, 46, 47, 70, 76, 81, 84, 85, 86, 90, 93, 94, 95, 99, 103, 108, 110, 113, 115, 116, 118, 119, 120, 122, 123, 124, 125, 126, 127, 128, 129, 130, 132, 134, 141, 143, 145, 147, 151, 154, 156 |

In the `qwen36-gguf-think-rerun` block, HumanEval/4 in the source run
was a server error, not an answer. It re-runs like the others.

## `retry-sweep`

The blocks that waited on a human, oldest first.

## Not in this run

- Any problem that is not in a block's list, any other model, any other
  level, any new calibration.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
dropped and why, machine state, evidence archived. Push and message the
coordinator. The coordinator updates each run's score, `emptyCause` and
wall on the site.
