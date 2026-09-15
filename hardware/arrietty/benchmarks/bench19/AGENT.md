# Run 19 — EvalPlus on every row of the RTX 5060 Ti 16 GB (Linux)

Ready to start, 2026-09-15. About two days of machine time; the list
below is the order and the run ends when the list ends or the owner
says stop.

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

The owner's word (2026-09-15): run 17 measured speed and the agent task
on this card and skipped EvalPlus. Every row of
`docs/setups/arrietty/models.json` now gets its EvalPlus score. The
blocks run in the order of the row's site score, the highest Mendel
score first, so the site tables fill from the top down as the results
land.

## The order

**This list is the order.**

- `machine-setup`
- `qwen38-ista-evalplus-xhigh`
- `qwen38-iq3s-evalplus-xhigh`
- `qwen36-q4kxl-evalplus-on`
- `gemma26-nvfp4-evalplus-on`
- `gemma12-nvfp4-evalplus-off`
- `gemma12-nvfp4-evalplus-on`
- `gemma12-q4kxl-evalplus-on`
- `gemma12-q4kxl-evalplus-off`
- `retry-sweep`

## Essentials

- `bench19/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION after the wakeup:** `git fetch origin && git worktree
  add ../choose-a-local-llm-run19 -b run19 origin/master` (or `cd` into
  it if it exists), then `cd ../choose-a-local-llm-run19`. Verify with
  `pwd` and `git worktree list`. Every command of this run happens
  there.
- **Branches, exactly.** You work on `run19` and only on `run19`. To
  take an update: `git fetch origin && git merge origin/master`, then
  push `run19`. Never check out `master`, never merge `run19` into
  `master`, never push `master`.
- Then `docs/methodology/checklist.md` and
  `docs/methodology/status-lines.md`, whole, once per session.
- **This machine is Linux, not the Mac.** Read run 17's runbook,
  `hardware/arrietty/benchmarks/bench17/AGENT.md`, section
  "Essentials", the part that starts "This machine is Linux", and do
  the same here: `nvidia-smi`, `pgrep -fl llama-server`, `free -m`,
  `df -h ~` and `gh auth status` by hand instead of
  `tools/preflight.sh`; `vram 16311 MiB` instead of a wired limit; the
  CUDA death signatures in every `RUNWATCH_SIGNATURES`. No sudo: a
  step that needs `sudo` or `pacman` is stop and ask.
- **The CUDA build, in every new shell.** A context compaction starts a
  new shell without the exports (run 17). Before every server start:

  ```bash
  export PATH="$HOME/.local/share/choose-a-local-llm/llama.cpp/v0.4.0-sm120/bin:$PATH"
  export LD_LIBRARY_PATH="$HOME/.local/share/choose-a-local-llm/llama.cpp/v0.4.0-sm120/lib:$LD_LIBRARY_PATH"
  command -v llama-server; llama-server --list-devices 2>&1 | grep CUDA0
  ```

  A `llama-server` outside that directory, or no `CUDA0` device, is a
  fail: do not start the server; fix the exports first. The version
  line of this build names no CUDA.
- One model on the GPU at a time, port 8081. Before you start a
  server, `pgrep -fl llama-server` must be empty. Never kill a server
  you did not start.
- **The desktop shares the card.** Record `vram_start_mb` from
  `nvidia-smi` before the first block (about 1170 MiB idle on
  2026-09-15). After every server load, read `nvidia-smi` once more;
  write the used and total values in `state.md`.
- **No temperature and no sampling parameter is passed to any
  server.** EvalPlus sends temperature 0 itself.
- **Effort medium is banned for Qwen3.8** (owner rule, 2026-09-09).
- **Downloads never block this run** (owner rule, 2026-09-14). Every
  model file is already in `~/.cache/llama.cpp/hf/` from run 17 (should
  have used `hf download` with its default cache, not `--local-dir` —
  migrated to the default Hugging Face hub cache on 2026-09-15, except
  the file this run has open); a missing one is fetched with
  `hf download <repo> <file>` (default cache, no `--local-dir`), by the
  repository and file name in `bench17/state.md`, "Files and revisions".
  Check presence with `hf cache ls`, not by listing the filesystem.
- Every scoring run starts `benchmarks/run-watch.sh` as the checklist
  says, with the CUDA signatures.
- Commit on `run19` as results land. Push `run19` at every block close
  and message the coordinator session `local-llm coordinator sept-14`
  with the block, the config, the result line and the commit id. **No
  message between pushes** (owner rule, 2026-09-11). Every gate and
  every stop-and-ask goes to the coordinator with the block, the
  condition and your candidate answer; keep the GPU busy with the next
  block that does not depend on it. Never ask the owner a
  multiple-choice question. Never run a bare `git stash`.
- **A recoverable failure is retried at once, inside its block**: a
  server that died under a request, a run the machine killed. Resume
  the same run directory; `run-humaneval.sh` skips the problems it
  already has. `retry-sweep` holds only what needed a human.
- A bug in a run tool goes to a subagent on the best available model
  at once; the run does not wait for it.
- Status lines follow `docs/methodology/status-lines.md`. Archive
  evidence before a session closes:
  `tools/archive-evidence.sh hardware/arrietty/benchmarks/bench19/results run19`.
- Every file a block writes goes under
  `hardware/arrietty/benchmarks/bench19/results/`,
  `hardware/arrietty/calibrations/` or
  `~/.local/share/choose-a-local-llm/`. Nothing under `/tmp`.

## `machine-setup`

Read `docs/methodology/evalplus.md`, whole. The llama.cpp build, the
model files and `hf` are in place from run 17. EvalPlus is not
installed on this machine.

1. **EvalPlus 0.3.1**, the version every score of the project used:
   `pipx install evalplus==0.3.1`. Record `evalplus.codegen --help |
   head -2` and the venv python in `state.md` as `evalplus_python`.
   In every new shell, set it with the CUDA exports:
   `export EVALPLUS_PYTHON="$(head -1 "$(command -v evalplus.codegen)" | sed 's/^#!//; s/ -E$//')"`.
   `benchmarks/calibrate.py` runs with that python;
   `benchmarks/run-humaneval.sh` finds it itself.
   The macOS `setrlimit` patch of the Mac venv is not needed on Linux;
   if `evalplus.evaluate` fails on `setrlimit`, that is a tool bug for
   a subagent.
2. **The dataset.** EvalPlus caches `HumanEvalPlus-v0.1.10.jsonl` under
   `~/.cache/evalplus/` on first use. Its downloader hung on the Mac
   (`hardware/kamaji/benchmarks/bench1/state.md`); if the first
   `evalplus.codegen` call prints nothing for 5 minutes, fetch the file
   from the URL in `evalplus/data/humaneval.py` with `curl` into that
   directory, unpack it, and record it.
3. **Directories.** `mkdir -p hardware/arrietty/calibrations
   hardware/arrietty/benchmarks/bench19/results`.
4. **A tool check on the smallest row.** Serve the Gemma-4-12B NVFP4
   build as in "The EvalPlus blocks" and run
   `benchmarks/calibrate.py` once against it with thinking off, into
   `results/`, not into the calibrations directory. Pass: ten rows,
   `resolved` values that match the request. Then stop the server.

Done: versions and paths in `state.md`, committed.

## The EvalPlus blocks

Every block below has the same steps. Its row in the table gives the
values.

1. **Serve.** The arm is the fastest at 4K in run 17
   (`docs/methodology/evalplus.md`, "Which serving config to score"),
   at `-c 32768`: the problems are short, and a small `-c` leaves VRAM
   for the desktop. A drafter never changes an output at temperature 0.

   ```bash
   llama-server -m "$(hf download <repo> <file>)" \
     --alias <alias> --no-mmproj --parallel 1 <arm flags> \
     -ngl 999 --fit off -fa on -c 32768 \
     --cache-type-k <kv> --cache-type-v <kv> \
     --jinja --port 8081 2>&1 \
     | tee hardware/arrietty/benchmarks/bench19/results/server-<mnemonic>.log
   ```

   Verify with a real request, then read `nvidia-smi`. **When less
   than 1200 MiB of the card is free with the server loaded**, stop
   the server and serve the fallback arm of the table; write the swap
   and both readings in `state.md`. A server that dies with `CUDA
   error` during the block is also a switch to the fallback arm,
   inside the block, and the run resumes in the same directory.
2. **Calibrate.** The extra body is mandatory on the calibration and
   on the full run.

   ```bash
   CALIBRATION_DIR=hardware/arrietty/calibrations "$EVALPLUS_PYTHON" benchmarks/calibrate.py <calibration> <alias> '<extra body>'
   ```

   Check that every row's `resolved_reasoning_effort` (or the thinking
   switch) matches the level of the block. The budget is the observed
   maximum times 1.5, floor 8192, cap 30000; when the calibration has
   `length` stops, the budget is just above the longest successful
   completion and the expected empty rate goes beside it (the page,
   step 3). Never take a budget from another model or level. Write
   `<mnemonic>_budget` with its source in `state.md`.
3. **Start the watcher**, as the checklist says, with
   `RUNWATCH_SERVER_LOG` the server log above, `RUNWATCH_OUTPUT`
   `hardware/arrietty/benchmarks/bench19/results/<mnemonic>/codegen.log`,
   `RUNWATCH_MODEL` the alias and the CUDA signatures.
4. **Run.**

   ```bash
   RESULTS_BASE=hardware/arrietty/benchmarks/bench19/results \
     EVALPLUS_MAX_NEW_TOKENS=<mnemonic>_budget \
     benchmarks/run-humaneval.sh <mnemonic> <alias> '<extra body>'
   ```

5. **Done**: base and plus pass@1, the empty count out of 164, the
   budget, the served arm and the active wall time. Write
   `<mnemonic>` = `base/plus/completion%` in `state.md`, one table
   row in `results.md` beside the Mac's EvalPlus row of the same model
   and level from `docs/setups/kamaji/models.json` when one exists,
   commit, push, message the coordinator. Stop the watcher and the
   server, wait for `vram_start_mb`, start the next block.

| mnemonic | file (`<repo>` and `<file>` for `hf download <repo> <file>`, default cache) | alias | kv | arm flags | fallback arm | extra body | calibration |
|---|---|---|---|---|---|---|---|
| `qwen38-ista-evalplus-xhigh` | `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF/Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf` | `qwen3.8-27b-ista` | `q8_0` | `--spec-type draft-mtp --spec-draft-n-max 2` | no drafter | `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}` | `qwen38-ista-xhigh` |
| `qwen38-iq3s-evalplus-xhigh` | `unsloth/Qwen3.8-27B-GGUF/Qwen3.8-27B-UD-IQ3_S.gguf` | `qwen3.8-27b-iq3s` | `q8_0` | `--spec-type draft-mtp --spec-draft-n-max 2` | no drafter | `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}` | `qwen38-iq3s-xhigh` |
| `qwen36-q4kxl-evalplus-on` | `unsloth/Qwen3.6-35B-A3B-MTP-GGUF/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf` | `qwen3.6-35b-a3b-q4kxl` | `q8_0` | `--spec-type draft-mtp --spec-draft-n-max 2 --n-cpu-moe 21` | no drafter, `--n-cpu-moe 17` | `{"chat_template_kwargs":{"enable_thinking":true}}` | `qwen36-q4kxl-on` |
| `gemma26-nvfp4-evalplus-on` | `catlilface/Gemma-4-26B-A4B-NVFP4-GGUF/Gemma4-26b-NVFP4Q8.gguf` | `gemma-4-26b-a4b-nvfp4` | `f16` | `--n-cpu-moe 7` | `--n-cpu-moe 9` | `{"chat_template_kwargs":{"enable_thinking":true}}` | `gemma26-nvfp4-on` |
| `gemma12-nvfp4-evalplus-off` | `FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF/gemma-4-12b-it-nvfp4.gguf` | `gemma-4-12b-nvfp4` | `f16` | none | none | `{"chat_template_kwargs":{"enable_thinking":false}}` | `gemma12-nvfp4-off` |
| `gemma12-nvfp4-evalplus-on` | same as above | `gemma-4-12b-nvfp4` | `f16` | none | none | `{"chat_template_kwargs":{"enable_thinking":true}}` | `gemma12-nvfp4-on` |
| `gemma12-q4kxl-evalplus-on` | `unsloth/gemma-4-12b-it-GGUF/gemma-4-12b-it-UD-Q4_K_XL.gguf` | `gemma-4-12b-q4kxl` | `f16` | none | none | `{"chat_template_kwargs":{"enable_thinking":true}}` | `gemma12-q4kxl-on` |
| `gemma12-q4kxl-evalplus-off` | same as above | `gemma-4-12b-q4kxl` | `f16` | none | none | `{"chat_template_kwargs":{"enable_thinking":false}}` | `gemma12-q4kxl-off` |

The two Gemma-12B blocks of one file serve the same server; start the
second block on the running server when the first one closes.

## `retry-sweep`

The blocks that waited on a human, oldest first. A run the machine
killed was already resumed inside its block.

## Not in this run

- Speed sweeps, Mendel rows, any other model, any other level, a KV
  type other than the table's.
- The EvalPlus smoke: every row here gets the full score.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
changed and why, machine state left behind, evidence archived. Push
and message the coordinator. The coordinator writes `report.md`, adds
the findings to `hardware/arrietty/benchmarks/INDEX.md`, fills the
`evalplus` cells in `docs/setups/arrietty/models.json`, and publishes.
