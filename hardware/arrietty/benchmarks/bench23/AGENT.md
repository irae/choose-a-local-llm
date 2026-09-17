# Run 23 — a new Qwen3.8-27B binary on the RTX 5060 Ti 16 GB (Linux)

Ready to start on the owner's word, 2026-09-17. About one day of
machine time. The list below is the order and the run ends when the
list ends, when the context gate below aborts it, or when the owner
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

The owner's word (2026-09-17): adopt one more community binary of
Qwen3.8-27B on this card, in a Q3_K_M build, and measure it under the
thinking budget. It is a new binary of a model the site already
carries, beside the ISTA and unsloth builds, and not a new model.

The run also feeds the reasoning context cap decision
(`docs/methodology/evalplus.md`, "Unproven yet"), so the EvalPlus
block runs with the thinking budget and the forced re-run follows it.

**This run measures; it decides nothing.**

## The order

**This list is the order.**

- `machine-setup`
- `qwen38-oblit-q3km-kvpick`
- `sweep-qwen38-oblit-q3km`
- `qwen38-oblit-q3km-calibrate-think`
- `qwen38-oblit-q3km-budget-medium`
- `qwen38-oblit-q3km-forced-rerun`
- `qwen38-oblit-q3km-smoke-medium`
- `qwen38-oblit-q3km-mendel-blind-medium`
- `retry-sweep`

## Essentials

- `bench23/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION after the wakeup:** `cd
  ../choose-a-local-llm-run23`, the worktree the coordinator created
  for you on branch `run23`. Verify with `pwd` and `git worktree
  list`. If it does not exist: `git fetch origin && git worktree add
  ../choose-a-local-llm-run23 -b run23 origin/master`. Every command
  of this run happens there.
- **Branches, exactly.** You work on `run23` and only on `run23`. To
  take an update: `git fetch origin && git merge origin/master`, then
  push `run23`. Never check out `master`, never merge `run23` into
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
- **Effort medium on Qwen3.8 is an owner overrule for this run**
  (owner, 2026-09-17). `AGENTS.md` bans medium for this model and the
  ban stays in force everywhere else. Here the owner named medium as
  the level of this binary's first rows. Serve medium and do not stop
  and ask about it. No other level runs in this run.
- **The download is authorized** (owner, 2026-09-17), for the one file
  this runbook names and for no other file of that repository.
- **The budget message is fixed for the whole run**, in every serve
  command that carries a thinking budget:

  ```bash
  export BUDGET_MSG="Thinking budget reached. Give the final answer now."
  ```

  The finish log keeps the last 200 characters of the reasoning, and
  the message lands there, so a forced answer is one whose reasoning
  tail contains it.
- **No temperature and no sampling parameter is passed to any
  server.** EvalPlus sends temperature 0 itself. This file's own
  sampling defaults come from the GGUF; read them from the load log
  and write them in `state.md`, because every config note of this
  build must carry them.
- **The margin.** `THINKING_BUDGET_MARGIN` is 1.5, the planning value.
  If a coordinator message names a new margin before the
  `*-calibrate-*` block starts, use it and write the value and the
  message time in `state.md`. Never wait for one.
- **Count empties from the samples, never from a log line.** After
  every scoring run:

  ```bash
  python3 -c 'import json,sys;print(sum(1 for l in open(sys.argv[1]) if l.strip() and not json.loads(l)["solution"].strip()))' \
    hardware/arrietty/benchmarks/bench23/results/<mnemonic>/humaneval/<alias>_openai_temp_0.0.raw.jsonl
  ```

  The forced count is the number of `finish.jsonl` lines whose
  `reasoning_tail` contains `$BUDGET_MSG`:

  ```bash
  python3 -c 'import json,sys,os;m=os.environ["BUDGET_MSG"];print(sum(1 for l in open(sys.argv[1]) if l.strip() and m in (json.loads(l).get("reasoning_tail") or "")))' \
    hardware/arrietty/benchmarks/bench23/results/<mnemonic>/finish.jsonl
  ```

  Both numbers go in the result line. Run 19's runner wrote `0/164
  empty` on rows whose samples held up to 53 empty answers; the
  coordinator corrected the site. Do not repeat that.
- Every scoring run starts `benchmarks/run-watch.sh` as the checklist
  says, with the CUDA signatures.
- **Crashes and wall:** `docs/methodology/evalplus.md`, "Crashes and
  wall time". Write every part in `state.md` in UTC.
- Commit on `run23` as results land. Push `run23` at every block close
  and message the coordinator session with the block, the config, the
  result line and the commit id. **No message between pushes** (owner
  rule, 2026-09-11). Every gate and every stop-and-ask goes to the
  coordinator with the block, the condition and your candidate answer;
  keep the GPU busy with the next block that does not depend on it.
  Never ask the owner a multiple-choice question. Never run a bare
  `git stash`.
- **A recoverable failure is retried at once, inside its block.**
  Resume the same run directory; `run-humaneval.sh` skips the problems
  it already has. `retry-sweep` holds only what needed a human.
- A bug in a run tool goes to a subagent on the best available model
  at once; the run does not wait for it.
- Archive evidence before a session closes:
  `tools/archive-evidence.sh hardware/arrietty/benchmarks/bench23/results run23`.
- Every file a block writes goes under
  `hardware/arrietty/benchmarks/bench23/results/`,
  `hardware/arrietty/calibrations/` or
  `~/.local/share/choose-a-local-llm/`. Nothing under `/tmp`.

## The file

Fixed identity, the same in every block:

| field | value |
|---|---|
| repo | `OBLITERATUS/Qwen3.8-27B-OBLITERATED` |
| file | `Qwen3.8-27B-OBLITERATED-Q3_K_M.gguf` |
| revision | `a58c3b53b3ce71551eafde2ed5ec8df48e0f4ff8` |
| size | 13,500,728,352 bytes |
| alias | `qwen3.8-27b-oblit-q3km` |
| level | medium (owner overrule, 2026-09-17) |
| extra body | `{"chat_template_kwargs":{"reasoning_effort":"medium"}}` |
| tokenizer | `unsloth/Qwen3.8-27B` |
| vision | off, always: `--no-mmproj` |
| drafter | none, always |

```bash
hf download OBLITERATUS/Qwen3.8-27B-OBLITERATED Qwen3.8-27B-OBLITERATED-Q3_K_M.gguf \
  --revision a58c3b53b3ce71551eafde2ed5ec8df48e0f4ff8
```

The vision weights sit in a separate `mmproj` file of that repository.
Do not fetch it. `--no-mmproj` is in every serve command of this run,
so vision costs this run no VRAM at all.

The file carries no MTP head. No drafter arm runs in this run. If the
load log does prove a draft head, write that in `state.md` and go on
without a drafter; a drafter is a speed decision and this run does not
take it.

Record the sha256 of the downloaded file in `state.md`. No earlier
sha256 of this file exists in the project, so there is nothing to
compare it with, and a value on its own is not a stop.

## `machine-setup`

Read `docs/methodology/evalplus.md`, whole, with "Unproven yet", and
`docs/methodology/kv-cache-pick.md`, whole.

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
4. Fetch the file of "The file" above, and record its sha256 and the
   `hf cache ls` line in `state.md`.
5. **The corpus server**, for the speed block: `cd
   hardware/kamaji/research/run4/results && python3 -m http.server 8089
   --bind 127.0.0.1` in the background for the whole run; stop it after
   `sweep-qwen38-oblit-q3km`. The file is `corpus-mendel-js.txt`,
   sha256
   `f4cbe063ef231d753e736b60107b6601705a1acb448b05d9f8b8afbdfcec583c`;
   verify it once.
6. `mkdir -p hardware/arrietty/benchmarks/bench23/results
   ~/.local/share/choose-a-local-llm ~/.local/share/mendel-benchmark`.

Done: every version and every hash in `state.md`, committed. No result
table.

## The ladder

Every serving block needs the largest `-c` that serves. Use run 17's
ladder, `hardware/arrietty/benchmarks/bench17/AGENT.md`, section "The
ladder", steps 1 to 4, with the `-ngl 999 --fit off` rule it states.
This is a dense model, so the `--n-cpu-moe` part of that section does
not apply, and no part of the weights goes to host RAM in this run.

## `qwen38-oblit-q3km-kvpick`

Read `docs/methodology/kv-cache-pick.md`.

This build is about 0.6 GiB larger than the 3-bit builds this card
already serves, so the window it can hold is the open question of the
whole run. The block answers it before any hour of scoring is spent.

Fixed: the file, `--no-mmproj`, `--parallel 1`, no drafter, `-ngl 999`,
`--fit off`, `-fa on`, `--cache-ram 0` for the measurement only, port
8081. Derived: `-c` per cache type.

1. Run the ladder at `--cache-type-k q8_0 --cache-type-v q8_0`.
   Planning value for the first load: `-c 65536`, from the ISTA
   3-bit build of the same base on this card (run 17). A computed
   planning estimate for this file: about 34 MiB of KV per 1024
   tokens at q8_0, from the model config, 16 full-attention layers of
   64, 4 KV heads, head dimension 256. The estimate is a starting
   point and never a result. Write `oblit_q3km_c_q8` in `state.md`.
2. Run the ladder again at `--cache-type-k f16 --cache-type-v f16`.
   Write `oblit_q3km_c_f16`.
3. Each candidate `-c` is real only when one real request of about
   that size serves, not a one-token probe
   (`docs/methodology/kv-cache-pick.md`, "Pitfalls"). A server that
   loads and answers 500 with "Insufficient Memory" is a fail of that
   `-c`.
4. Record for each type: the ladder lines, the largest serving `-c`,
   the VRAM used at load from `nvidia-smi`, and the `MemAvailable`
   line.

**The gate, and it can end the run.** Let `oblit_q3km_c` be the larger
of the two serving values, with its cache type.

- `oblit_q3km_c` is **32768 or more**: the type of that value is the
  pick for this run, write `oblit_q3km_kv` in `state.md`, and the run
  goes on to `sweep-qwen38-oblit-q3km`. The published pick still needs
  the EvalPlus smoke of the method page; this run does not run that
  smoke, and the config note says the pick is a fit pick of this run.
- `oblit_q3km_c` is **under 32768**: **stop the run here.** A window
  under 32K does not pass EvalPlus on this task, so no calibration and
  no scoring block runs (owner, 2026-09-17). Write the two ladders,
  both values and the abort line in `results.md` and `state.md`,
  commit, push `run23`, and message the coordinator with the words
  "bench23 aborted at the context gate", both values and the commit
  id. Then do the "After the run" section and stop. Do not lower the
  window, do not try another cache type, do not move weights to host
  RAM, and do not start any later block. Run 24 exists for that case
  and is not yours.

Done: the two ladders, the gate outcome and the pick in `results.md`
and `state.md`. Commit, push, message the coordinator.

## `sweep-qwen38-oblit-q3km`

Read `docs/methodology/context-creep.md`, "Speed measurement rules"
and "The order for a model with a drafter" (this block has no
drafter, so it reads as the single-arm case).

The creep tool does not run on this machine (it reads `vm_stat`).
Speed comes from `llama-benchy`, with run 17's command shape,
`hardware/arrietty/benchmarks/bench17/AGENT.md`, section "The benchy
command", with `bench23` in every path and `<arm>` equal to the
cache type this run picked.

Fixed: the file, the pick from `oblit_q3km_kv`, no drafter.
Derived: `-c` from `oblit_q3km_c`; depths 4096, 24576 and
`oblit_q3km_c` minus 1024.

Write `oblit_q3km_clean` in `state.md`: the deepest depth at or above
8 tok/s. **A table and no pick.** The coordinator names what the row
serves.

Done: one table in `results.md`, one line per depth, with tok/s, sd,
prompt tok/s, VRAM used and `MemAvailable`. Commit, push, message the
coordinator. Stop the corpus server.

## `qwen38-oblit-q3km-calibrate-think`

Read `docs/methodology/evalplus.md`, "Calibrate the output budget
FIRST" and "Unproven yet".

Calibration name: `qwen38-oblit-q3km-medium-think`. Serve the config
without a thinking budget, at `-c 32768`.

1. **Serve**, then

   ```bash
   CALIBRATION_DIR=hardware/arrietty/calibrations "$EVALPLUS_PYTHON" \
     benchmarks/calibrate.py qwen38-oblit-q3km-medium-think qwen3.8-27b-oblit-q3km \
     '{"chat_template_kwargs":{"reasoning_effort":"medium"}}'
   ```

   Check `resolved_reasoning_effort` on every row. A row that resolves
   to another level is stop and ask.
2. **Derive**:

   ```bash
   benchmarks/thinking-budget.py derive \
     hardware/arrietty/calibrations/calibration-qwen38-oblit-q3km-medium-think.json
   ```

   Write `oblit_q3km_think_budget`, `oblit_q3km_answer_budget` and
   `oblit_q3km_max_tokens` in `state.md` with the converged and cut
   counts and the margin used. Keep the server up for the next block
   only if its `-c` is the same; else stop it.

Done: the three values in `state.md`, committed. Push, message the
coordinator.

## `qwen38-oblit-q3km-budget-medium`

Read `docs/methodology/evalplus.md`, "Steps".

1. **Serve** with the thinking budget:

   ```bash
   llama-server -m "$(hf download OBLITERATUS/Qwen3.8-27B-OBLITERATED Qwen3.8-27B-OBLITERATED-Q3_K_M.gguf --revision a58c3b53b3ce71551eafde2ed5ec8df48e0f4ff8)" \
     --alias qwen3.8-27b-oblit-q3km --no-mmproj --parallel 1 \
     -ngl 999 --fit off -fa on -c 32768 \
     --cache-type-k <oblit_q3km_kv> --cache-type-v <oblit_q3km_kv> \
     --reasoning-budget <oblit_q3km_think_budget> \
     --reasoning-budget-message "$BUDGET_MSG" \
     --jinja --port 8081 2>&1 \
     | tee hardware/arrietty/benchmarks/bench23/results/server-qwen38-oblit-q3km-budget-medium.log
   ```

   `-c 32768` is the scoring window of every EvalPlus block on this
   card, not a ceiling. Verify with a real request, read `nvidia-smi`,
   write both in `state.md`.
2. **Start the watcher** as the checklist says.
3. **Run** the full 164:

   ```bash
   RESULTS_BASE=hardware/arrietty/benchmarks/bench23/results \
     EVALPLUS_MAX_NEW_TOKENS=<oblit_q3km_max_tokens> \
     benchmarks/run-humaneval.sh qwen38-oblit-q3km-budget-medium qwen3.8-27b-oblit-q3km \
     '{"chat_template_kwargs":{"reasoning_effort":"medium"}}'
   ```

4. **Done**: base and plus pass@1, the empty count from the samples,
   the forced count from the finish log, the think and answer budgets,
   `max_tokens` and the wall with its parts, as one row in
   `results.md`. Commit, push, message the coordinator. Stop the
   watcher.

**The agent gate.** `docs/methodology/evalplus.md` gates an agent row
at 0.800 base pass@1. A score under 0.800 means
`qwen38-oblit-q3km-smoke-medium` and the blind row do not run: write
the gate line, tell the coordinator, and go to `retry-sweep`.

## `qwen38-oblit-q3km-forced-rerun`

The natural re-run of the problems where the budget fired and the
answer failed, without the flag, at a generous budget. Follow run 21's
block, `hardware/arrietty/benchmarks/bench21/AGENT.md`, section "The
forced re-run blocks", steps 1 to 6, with these values:

- budget directory:
  `hardware/arrietty/benchmarks/bench23/results/qwen38-oblit-q3km-budget-medium`
- this block's directory:
  `hardware/arrietty/benchmarks/bench23/results/qwen38-oblit-q3km-forced-rerun`
- `EVALPLUS_MAX_NEW_TOKENS=30000`
- the same serve command as the block above, with the two reasoning
  flags removed.

Zero forced-failed problems: write that in `results.md` and
`state.md`, skip the rest of the block, start the next.

## `qwen38-oblit-q3km-smoke-medium`

Read `docs/methodology/mendel.md`, "The smoke" and "Window and
budget".

Serve the build with the pick and `-c` from `oblit_q3km_c`, with
`--cache-ram 0` removed and no reasoning flag. Pin the harness window
`oblit_q3km_window`: `oblit_q3km_clean` rounded down to a multiple of
4096, at or under `-c`, never smaller (owner rule, 2026-09-06). Write
the window and its source in `state.md` before the smoke.

```bash
SMOKE_MENDEL_CONTEXT_WINDOW=<oblit_q3km_window> benchmarks/mendel-smoke.sh \
  qwen3.8-27b-oblit-q3km medium 2>&1 \
  | tee hardware/arrietty/benchmarks/bench23/results/mendel-smoke-qwen38-oblit-q3km.log
```

Pass is one commit, clean tree, no repetition loop, inside the cap. A
fail means the blind row does not run; write the smoke line and go on.
A server that dies during the smoke is a fail of this config, not a
retry. After the smoke, read its session log for a thinking block:
medium is thinking on, so most turns show one. No thinking block means
the pi entry did not reach the server, and that is stop and ask.

## `qwen38-oblit-q3km-mendel-blind-medium`

Read `docs/methodology/mendel.md`, whole, with "House rules for runs
from this project" and "Comparing two builds of one model".

simulator(mendel) blind, prompt v1.1, base tag `benchmark-blind-base`.
The owner asked for blind before guided on this binary (owner,
2026-09-17). Fixed: the server of the smoke unchanged, level medium.
Derived: the window from `oblit_q3km_window`; `maxTokens` and
`reserveTokens` 8192, the worker's pin; keep budget 8192 under a
window of 65536, pi's default above it.

Before the run: `gh auth status` must pass, and `git stash clear` in
`~/code/mendel-benchmark` (owner rule, 2026-09-12).

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<oblit_q3km_window> \
  ./run-worker.sh qwen3.8-27b-oblit-q3km pi blind medium
```

Row `model` value: `qwen3.8-27b-oblit-q3km (OBLITERATUS Q3_K_M,
medium, arrietty)`; `model_id` the repo and file at the revision;
`hardware` `arrietty`. The config note carries the file and its
revision, the llama.cpp version, the `-c`, the cache type, the window,
the reserve, the keep budget, the compaction count, the source block
of each value, `vram 16311 MiB`, the sampling defaults the file sets,
the temperature and top_p from the run's `meta.json`, and the line
"effort medium by owner overrule, 2026-09-17".

Verify `peak_context` with `benchmark/count-tool-calls.mjs` before the
row commits, and put peak context and the tool-call count in
`results.md` beside the score. A row that ends on the model's own
repetition loop is a valid partial. A server that dies mid-run is a
row at the state it reached, and never a reason to lower the window on
your own. The 300-minute wall gives a partial, which is a row and not
a failure. After the run, `pkill -f "Mendel Daemon"`.

Write `oblit_q3km_blind` in `state.md` with the score, the libraries
done and the end reason.

## `retry-sweep`

The blocks that waited on a human, oldest first. A run the machine
killed was already resumed inside its block.

## Not in this run

- Any other file of that repository, the `mmproj` file included.
- Any other level. Medium is the only level of this run.
- A guided simulator(mendel) row. The owner keeps it optional and the
  coordinator decides it after the blind row (owner, 2026-09-17).
- A drafter arm, a second cache type after the pick, any weight in
  host RAM, any MLX or LM Studio server, any other model.
- Any change to the margin on your own reading of a re-run.
- Any step past the context gate when the gate aborts the run.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
changed and why, machine state left behind, evidence archived. Push
and message the coordinator. The coordinator writes `report.md`, adds
the findings to `hardware/arrietty/benchmarks/INDEX.md`, decides what
reaches the site, and publishes.
