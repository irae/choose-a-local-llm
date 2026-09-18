# Run 25 — the same binary in Q4_K_M, with weights in host RAM

**This run waits its turn on the card** (owner, 2026-09-17). One model
serves on this card at a time, so the run starts only when the
coordinator tells you to start. Run 23 measures the Q3_K_M build of the
same binary inside the card and is paused; run 24 measures a model
released on 2026-09-17. This run is last of the three, and it runs
whatever run 23 did: when run 23 aborted at its context gate, this run
is the answer to that abort; when run 23 finished, this run is the
second point of the pair, the larger quantization at a window the card
alone cannot hold. Either way, the blocks below do not change.

About one and a half days of machine time, because host RAM is slower
than VRAM. The list below is the order and the run ends when the list
ends or the owner says stop.

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

The owner's word (2026-09-17): when the 3-bit build of this binary
cannot hold a useful window inside the card, try the Q4_K_M build the
other way round. Fix the window at 64K, keep the KV cache and as many
layers as fit in VRAM, and let host RAM hold the rest.

The run answers two questions: what this build costs in speed when
part of it lives in host RAM, and what it scores at that window. It
also feeds the reasoning context cap decision
(`docs/methodology/evalplus.md`, "Unproven yet"), so the EvalPlus
block runs with the thinking budget and the forced re-run follows it.

**This run measures; it decides nothing.**

## The order

**This list is the order.**

- `machine-setup`
- `qwen38-oblit-q4km-offload-ladder`
- `sweep-qwen38-oblit-q4km`
- `qwen38-oblit-q4km-calibrate-think`
- `qwen38-oblit-q4km-budget-medium`
- `qwen38-oblit-q4km-forced-rerun`
- `qwen38-oblit-q4km-smoke-medium`
- `qwen38-oblit-q4km-mendel-blind-medium`
- `retry-sweep`

## Essentials

- `bench25/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION after the wakeup:** `cd
  ../choose-a-local-llm-run25`, the worktree the coordinator created
  for you on branch `run25`. Verify with `pwd` and `git worktree
  list`. If it does not exist: `git fetch origin && git worktree add
  ../choose-a-local-llm-run25 -b run25 origin/master`. Every command
  of this run happens there.
- **Branches, exactly.** You work on `run25` and only on `run25`. To
  take an update: `git fetch origin && git merge origin/master`, then
  push `run25`. Never check out `master`, never merge `run25` into
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
- **This run has a VRAM reserve, and it is the only one that has.**
  This card has no reserve rule (owner, 2026-09-15); every other run
  fills the card. Here the owner set one, because the weights spill to
  host RAM anyway and the desktop must keep drawing: **used VRAM stays
  at or below 13811 MiB**, which leaves 2.5 GB of the 16311 MiB free
  for the system (owner, 2026-09-17). Read `nvidia-smi` after every
  load and after the first real request of every block, and write both
  numbers in `state.md`. A load over the cap is a fail of that
  `-ngl`, not a result.
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
  and write them in `state.md`.
- **The margin.** `THINKING_BUDGET_MARGIN` is 1.5, the planning value.
  If a coordinator message names a new margin before the
  `*-calibrate-*` block starts, use it and write the value and the
  message time in `state.md`. Never wait for one.
- **Count empties from the samples, never from a log line.** After
  every scoring run:

  ```bash
  python3 -c 'import json,sys;print(sum(1 for l in open(sys.argv[1]) if l.strip() and not json.loads(l)["solution"].strip()))' \
    hardware/arrietty/benchmarks/bench25/results/<mnemonic>/humaneval/<alias>_openai_temp_0.0.raw.jsonl
  ```

  The forced count is the number of `finish.jsonl` lines whose
  `reasoning_tail` contains `$BUDGET_MSG`:

  ```bash
  python3 -c 'import json,sys,os;m=os.environ["BUDGET_MSG"];print(sum(1 for l in open(sys.argv[1]) if l.strip() and m in (json.loads(l).get("reasoning_tail") or "")))' \
    hardware/arrietty/benchmarks/bench25/results/<mnemonic>/finish.jsonl
  ```

  Both numbers go in the result line. Run 19's runner wrote `0/164
  empty` on rows whose samples held up to 53 empty answers; the
  coordinator corrected the site. Do not repeat that.
- Every scoring run starts `benchmarks/run-watch.sh` as the checklist
  says, with the CUDA signatures. **Raise `RUNWATCH_SILENCE`** for
  this run: a one-slot server under a large thinking budget, with part
  of its weights in host RAM, is slow enough for the silence probe to
  read a busy server as dead (run 22 saw the false exit 42 on faster
  hardware). Write the value you used in `state.md`.
- **Crashes and wall:** `docs/methodology/evalplus.md`, "Crashes and
  wall time". Write every part in `state.md` in UTC.
- Commit on `run25` as results land. Push `run25` at every block close
  and message the coordinator session with the block, the config, the
  result line and the commit id. **No message between pushes** (owner
  rule, 2026-09-11). Every gate and every stop-and-ask goes to the
  coordinator with the block, the condition and your candidate answer.
  Never ask the owner a multiple-choice question. Never run a bare
  `git stash`.
- **A recoverable failure is retried at once, inside its block.**
  Resume the same run directory; `run-humaneval.sh` skips the problems
  it already has. `retry-sweep` holds only what needed a human.
- A bug in a run tool goes to a subagent on the best available model
  at once; the run does not wait for it.
- Archive evidence before a session closes:
  `tools/archive-evidence.sh hardware/arrietty/benchmarks/bench25/results run25`.
- Every file a block writes goes under
  `hardware/arrietty/benchmarks/bench25/results/`,
  `hardware/arrietty/calibrations/` or
  `~/.local/share/choose-a-local-llm/`. Nothing under `/tmp`.

## The file

Fixed identity, the same in every block:

| field | value |
|---|---|
| repo | `OBLITERATUS/Qwen3.8-27B-OBLITERATED` |
| file | `Qwen3.8-27B-OBLITERATED-Q4_K_M.gguf` |
| revision | `a58c3b53b3ce71551eafde2ed5ec8df48e0f4ff8` |
| size | 16,810,705,952 bytes |
| alias | `qwen3.8-27b-oblit-q4km` |
| level | medium (owner overrule, 2026-09-17) |
| extra body | `{"chat_template_kwargs":{"reasoning_effort":"medium"}}` |
| tokenizer | `unsloth/Qwen3.8-27B` |
| vision | off, always: `--no-mmproj` |
| drafter | none, always |
| serving `-c` | **65536, fixed** (owner, 2026-09-17) |
| KV type | `q8_0`, fixed: f16 at this window does not fit on this card |

```bash
hf download OBLITERATUS/Qwen3.8-27B-OBLITERATED Qwen3.8-27B-OBLITERATED-Q4_K_M.gguf \
  --revision a58c3b53b3ce71551eafde2ed5ec8df48e0f4ff8
```

The file is 15.66 GiB, larger than the card, so this build cannot serve
from VRAM alone. That is the point of the run, not a fault.

The vision weights sit in a separate `mmproj` file of that repository.
Do not fetch it. `--no-mmproj` is in every serve command.

Record the sha256 of the downloaded file in `state.md`. Check that
`df -h ~` leaves 20 GB free before the download, and that `free -m`
shows at least 8 GB of `MemAvailable` before every load, because host
RAM holds the layers the card does not.

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
4. Fetch the file of "The file" above, and record its sha256 and the
   `hf cache ls` line in `state.md`.
5. **The corpus server**, for the speed block: `cd
   hardware/kamaji/research/run4/results && python3 -m http.server 8089
   --bind 127.0.0.1` in the background for the whole run; stop it after
   `sweep-qwen38-oblit-q4km`. The file is `corpus-mendel-js.txt`,
   sha256
   `f4cbe063ef231d753e736b60107b6601705a1acb448b05d9f8b8afbdfcec583c`;
   verify it once.
6. Read run 23's `state.md` and `results.md` on `master` and copy its
   two ladder values and its abort line into this run's `state.md`.
   They say why this run exists.
7. `mkdir -p hardware/arrietty/benchmarks/bench25/results
   ~/.local/share/choose-a-local-llm ~/.local/share/mendel-benchmark`.

Done: every version and every hash in `state.md`, committed. No result
table.

## `qwen38-oblit-q4km-offload-ladder`

Read `docs/methodology/memory-ceiling.md`, "Know which limit actually
gates the OOM", and run 17's ladder,
`hardware/arrietty/benchmarks/bench17/AGENT.md`, section "The ladder",
for the load-failure signatures.

Here `-c` is fixed and the layer count is the variable, the opposite of
every earlier ladder on this card. This is a dense model, so the knob
is `-ngl N`, the count of layers on the GPU, and **not**
`--n-cpu-moe`.

Fixed: the file, `-c 65536`, `--cache-type-k q8_0 --cache-type-v q8_0`,
`--no-mmproj`, `--parallel 1`, no drafter, `--fit off`, `-fa on`, port
8081, and the VRAM cap of 13811 MiB. Derived: `-ngl`.

```bash
llama-server -m "$(hf download OBLITERATUS/Qwen3.8-27B-OBLITERATED Qwen3.8-27B-OBLITERATED-Q4_K_M.gguf --revision a58c3b53b3ce71551eafde2ed5ec8df48e0f4ff8 | sed 's/^path=//')" \
  --alias qwen3.8-27b-oblit-q4km --no-mmproj --parallel 1 \
  -ngl <N> --fit off -fa on -c 65536 \
  --cache-type-k q8_0 --cache-type-v q8_0 --cache-ram 0 \
  --jinja --port 8081 2>&1 \
  | tee hardware/arrietty/benchmarks/bench25/results/server-offload-ladder-ngl<N>.log
```

1. Read `n_layer` from the load log of the first load, whatever that
   load does. The planning value is 64. A layer count you cannot read
   is stop and ask.
2. Start at `-ngl 43`, the planning value. It comes from this
   arithmetic, which is a planning estimate and never a result: 16040
   MiB of weights, 2176 MiB of KV at 65536 tokens at q8_0, about 200
   MiB of linear-attention state, about 600 MiB of compute buffers, and
   the cap of 13811 MiB.
3. A load is a **fail** when it ends in `CUDA error`, `out of memory`
   or `cudaMalloc failed`, or when `nvidia-smi` reads over 13811 MiB.
   Lower `-ngl` by 8 and load again.
4. A load is a **pass** only when one real request of about 64K tokens
   serves and `nvidia-smi` stays at or below the cap under that
   request. A one-token probe proves nothing here
   (`docs/methodology/kv-cache-pick.md`, "Pitfalls").
5. Bisect between the last fail and the last pass in steps of 2, at
   most eight loads in all, and end on the **largest passing `-ngl`**.
   More layers on the card is more speed, so this ladder climbs to the
   limit and does not settle for a safe value (owner rule, 2026-09-06,
   the same rule the window follows).
6. Write `oblit_q4km_ngl`, the ladder lines, the VRAM used at load and
   under the deep request, and the `MemAvailable` before and after the
   load, in `state.md`.

**The gate.** No `-ngl` from 0 upward serves 65536 tokens inside the
cap: that is stop and ask to the coordinator, with the ladder, both
memory readings and your candidate answer. Do not lower `-c` on your
own; 65536 is the owner's fixed value for this run.

Done: the ladder and `oblit_q4km_ngl` in `results.md` and `state.md`.
Commit, push, message the coordinator.

## `sweep-qwen38-oblit-q4km`

Read `docs/methodology/context-creep.md`, "Speed measurement rules".

The creep tool does not run on this machine (it reads `vm_stat`).
Speed comes from `llama-benchy`, with run 17's command shape,
`hardware/arrietty/benchmarks/bench17/AGENT.md`, section "The benchy
command", with `bench25` in every path and `<arm>` equal to
`ngl<oblit_q4km_ngl>`.

Fixed: the file, `-c 65536`, q8_0 KV, `oblit_q4km_ngl`, no drafter.
Depths: 4096, 24576, 49152 and 64512 (`-c` minus 1024).

Write `oblit_q4km_clean` in `state.md`: the deepest depth at or above 8
tok/s. **A table and no pick.**

**The speed gate.** The deep cell reads under 8 tok/s: write the table,
tell the coordinator with your candidate answer, and wait for its
answer before the calibrate block starts. A full EvalPlus at that
speed is many hours, and whether the run spends them is the
coordinator's call, not yours. The rest of the run is unchanged when
the answer is to go on.

Done: one table in `results.md`, one line per depth, with tok/s, sd,
prompt tok/s, VRAM used and `MemAvailable`. Commit, push, message the
coordinator. Stop the corpus server.

## `qwen38-oblit-q4km-calibrate-think`

Read `docs/methodology/evalplus.md`, "Calibrate the output budget
FIRST" and "Unproven yet".

Calibration name: `qwen38-oblit-q4km-medium-think`. Serve the config of
the ladder, at `-c 65536` with `oblit_q4km_ngl`, without a thinking
budget and without `--cache-ram 0`.

1. **Serve**, then

   ```bash
   CALIBRATION_DIR=hardware/arrietty/calibrations "$EVALPLUS_PYTHON" \
     benchmarks/calibrate.py qwen38-oblit-q4km-medium-think qwen3.8-27b-oblit-q4km \
     '{"chat_template_kwargs":{"reasoning_effort":"medium"}}'
   ```

   Check `resolved_reasoning_effort` on every row. A row that resolves
   to another level is stop and ask.
2. **Derive**:

   ```bash
   benchmarks/thinking-budget.py derive \
     hardware/arrietty/calibrations/calibration-qwen38-oblit-q4km-medium-think.json
   ```

   Write `oblit_q4km_think_budget`, `oblit_q4km_answer_budget` and
   `oblit_q4km_max_tokens` in `state.md` with the converged and cut
   counts and the margin used. Keep the server up for the next block.

Done: the three values in `state.md`, committed. Push, message the
coordinator.

## `qwen38-oblit-q4km-budget-medium`

Read `docs/methodology/evalplus.md`, "Steps".

1. **Serve** the ladder's config with the thinking budget appended:
   `--reasoning-budget <oblit_q4km_think_budget>
   --reasoning-budget-message "$BUDGET_MSG"`, log to
   `results/server-qwen38-oblit-q4km-budget-medium.log`. Verify with a
   real request, read `nvidia-smi` against the cap, write both in
   `state.md`.
2. **Start the watcher** as the checklist says, with the raised
   `RUNWATCH_SILENCE`.
3. **Run** the full 164:

   ```bash
   RESULTS_BASE=hardware/arrietty/benchmarks/bench25/results \
     EVALPLUS_MAX_NEW_TOKENS=<oblit_q4km_max_tokens> \
     benchmarks/run-humaneval.sh qwen38-oblit-q4km-budget-medium qwen3.8-27b-oblit-q4km \
     '{"chat_template_kwargs":{"reasoning_effort":"medium"}}'
   ```

4. **Done**: base and plus pass@1, the empty count from the samples,
   the forced count from the finish log, the think and answer budgets,
   `max_tokens`, `-ngl`, and the wall with its parts, as one row in
   `results.md`. Commit, push, message the coordinator. Stop the
   watcher.

**The agent gate.** `docs/methodology/evalplus.md` gates an agent row
at 0.800 base pass@1. A score under 0.800 means
`qwen38-oblit-q4km-smoke-medium` and the blind row do not run: write
the gate line, tell the coordinator, and go to `retry-sweep`.

## `qwen38-oblit-q4km-forced-rerun`

The natural re-run of the problems where the budget fired and the
answer failed, without the flag, at a generous budget. Follow run 21's
block, `hardware/arrietty/benchmarks/bench21/AGENT.md`, section "The
forced re-run blocks", steps 1 to 6, with these values:

- budget directory:
  `hardware/arrietty/benchmarks/bench25/results/qwen38-oblit-q4km-budget-medium`
- this block's directory:
  `hardware/arrietty/benchmarks/bench25/results/qwen38-oblit-q4km-forced-rerun`
- `EVALPLUS_MAX_NEW_TOKENS=30000`
- the same serve command as the block above, with the two reasoning
  flags removed.

Zero forced-failed problems: write that in `results.md` and
`state.md`, skip the rest of the block, start the next.

## `qwen38-oblit-q4km-smoke-medium`

Read `docs/methodology/mendel.md`, "The smoke" and "Window and
budget".

Serve the ladder's config, without `--cache-ram 0` and without a
reasoning flag. Pin the harness window `oblit_q4km_window`:
`oblit_q4km_clean` rounded down to a multiple of 4096, at or under
65536, never smaller (owner rule, 2026-09-06). Write the window and its
source in `state.md` before the smoke.

```bash
SMOKE_MENDEL_CONTEXT_WINDOW=<oblit_q4km_window> benchmarks/mendel-smoke.sh \
  qwen3.8-27b-oblit-q4km medium 2>&1 \
  | tee hardware/arrietty/benchmarks/bench25/results/mendel-smoke-qwen38-oblit-q4km.log
```

Pass is one commit, clean tree, no repetition loop, inside the cap. A
fail means the blind row does not run; write the smoke line and go on.
A server that dies during the smoke is a fail of this config, not a
retry. After the smoke, read its session log for a thinking block:
medium is thinking on, so most turns show one. No thinking block means
the pi entry did not reach the server, and that is stop and ask.

## `qwen38-oblit-q4km-mendel-blind-medium`

Read `docs/methodology/mendel.md`, whole, with "House rules for runs
from this project" and "Comparing two builds of one model".

simulator(mendel) blind, prompt v1.1, base tag `benchmark-blind-base`.
The owner asked for blind before guided on this binary (owner,
2026-09-17). Fixed: the server of the smoke unchanged, level medium.
Derived: the window from `oblit_q4km_window`; `maxTokens` and
`reserveTokens` 8192, the worker's pin; keep budget pi's default 20000
when the window is above 65536, 8192 under it.

Before the run: `gh auth status` must pass, and `git stash clear` in
`~/code/mendel-benchmark` (owner rule, 2026-09-12).

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<oblit_q4km_window> \
  ./run-worker.sh qwen3.8-27b-oblit-q4km pi blind medium
```

Row `model` value: `qwen3.8-27b-oblit-q4km (OBLITERATUS Q4_K_M,
medium, arrietty)`; `model_id` the repo and file at the revision;
`hardware` `arrietty`. The config note carries the file and its
revision, the llama.cpp version, `-c 65536`, the q8_0 cache, `-ngl
<oblit_q4km_ngl>` of `n_layer` with the rest in host RAM, the VRAM cap
of 13811 MiB with its owner date, the window, the reserve, the keep
budget, the compaction count, the source block of each value, `vram
16311 MiB`, the sampling defaults the file sets, the temperature and
top_p from the run's `meta.json`, and the line "effort medium by owner
overrule, 2026-09-17".

Verify `peak_context` with `benchmark/count-tool-calls.mjs` before the
row commits, and put peak context and the tool-call count in
`results.md` beside the score. This is the first row of this project
served with weights in host RAM, so the tool-call count and the wall
matter as much as the score. A row that ends on the model's own
repetition loop is a valid partial. A server that dies mid-run is a
row at the state it reached. The 300-minute wall gives a partial, which
is a row and not a failure. After the run, `pkill -f "Mendel Daemon"`.

Write `oblit_q4km_blind` in `state.md` with the score, the libraries
done and the end reason.

## `retry-sweep`

The blocks that waited on a human, oldest first. A run the machine
killed was already resumed inside its block.

## Not in this run

- Any other file of that repository, the `mmproj` file included.
- Any other level. Medium is the only level of this run.
- A guided simulator(mendel) row. The owner keeps it optional and the
  coordinator decides it after the blind row (owner, 2026-09-17).
- A `-c` other than 65536, an f16 KV cache, a drafter arm, any MLX or
  LM Studio server, any other model.
- Any change to the VRAM cap or to the margin on your own reading.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
changed and why, machine state left behind, evidence archived. Push
and message the coordinator. The coordinator writes `report.md`, adds
the findings to `hardware/arrietty/benchmarks/INDEX.md`, decides what
reaches the site, and publishes.
