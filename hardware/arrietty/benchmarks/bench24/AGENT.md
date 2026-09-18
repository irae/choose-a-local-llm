# Run 24 — Ternary Bonsai 2 27B on the RTX 5060 Ti 16 GB (Linux)

Start at once, 2026-09-17, on the owner's word. The card is free: run
23 is paused inside its EvalPlus block and its runner keeps its
worktree. About one day of machine time. The list below is the order
and the run ends when the list ends or the owner says stop.

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

The owner's word (2026-09-17): a model released today, to measure at
effort xhigh. It is a ternary-weight build of a 27B model, in two
packings of about 6.7 and 5.5 GiB. Every other 27B build this card has
served needs 12 GiB or more, so this one changes what the card can
hold: the weights leave far more room for the KV cache than any 27B
build measured here.

The run also feeds the reasoning context cap decision
(`docs/methodology/evalplus.md`, "Unproven yet"), so the EvalPlus
blocks run with a thinking budget when the server supports one.

**This run measures; it decides nothing.**

## The order

**This list is the order.**

- `machine-setup`
- `bonsai2-pq2-kvpick`
- `sweep-bonsai2-pq2`
- `bonsai2-pq2-calibrate-think`
- `bonsai2-pq2-budget-xhigh`
- `bonsai2-pq2-forced-rerun`
- `bonsai2-ptq1-kvpick`
- `sweep-bonsai2-ptq1`
- `bonsai2-pq2-smoke-xhigh`
- `bonsai2-pq2-mendel-blind-xhigh`
- `retry-sweep`

The second file's two blocks sit between the EvalPlus work and the
agent row on purpose: they are speed blocks, and every speed block runs
before the next agent row (owner rule, 2026-09-14).

## Essentials

- `bench24/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION after the wakeup:** `cd
  ../choose-a-local-llm-run24`, the worktree the coordinator prepared
  for you on branch `run24`. Verify with `pwd` and `git worktree
  list`, and `git log --oneline -1` must show this kit. Every command
  of this run happens there.
- **Branches, exactly.** You work on `run24` and only on `run24`. To
  take an update: `git fetch origin && git merge origin/master`, then
  push `run24`. Never check out `master`, never merge `run24` into
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
- **Run 23 is paused, not finished.** Its worktree
  `../choose-a-local-llm-run23` and its branch stay as they are. Never
  touch them, never kill a process you did not start, and never delete
  anything under `hardware/arrietty/benchmarks/bench23/`.
- **This model needs a different llama.cpp**, and that is the first
  gate of the run. See "The server" below.
- **Effort xhigh** is the level of every block. It is this model's
  published default, and the owner named it (owner, 2026-09-17). The
  card says `low` is not supported. No other level runs in this run.
- **The downloads are authorized** (owner, 2026-09-17), for the files
  this runbook names and for no other file.
- **The budget message is fixed for the whole run**, in every serve
  command that carries a thinking budget:

  ```bash
  export BUDGET_MSG="Thinking budget reached. Give the final answer now."
  ```

- **No temperature and no sampling parameter is passed to any
  server.** EvalPlus sends temperature 0 itself. This model publishes
  its own sampling defaults in the GGUF metadata (`general.sampling.*`,
  thinking mode: temperature 1.0, top_p 0.95, top_k 20, min_p 0.0).
  Read what the server actually applies from the load log and write it
  in `state.md`; every config note of this build carries it.
- **The margin.** `THINKING_BUDGET_MARGIN` is 1.5, the planning value.
- **Count empties from the samples, never from a log line.** After
  every scoring run:

  ```bash
  python3 -c 'import json,sys;print(sum(1 for l in open(sys.argv[1]) if l.strip() and not json.loads(l)["solution"].strip()))' \
    hardware/arrietty/benchmarks/bench24/results/<mnemonic>/humaneval/<alias>_openai_temp_0.0.raw.jsonl
  ```

  The forced count is the number of `finish.jsonl` lines whose
  `reasoning_tail` contains `$BUDGET_MSG`:

  ```bash
  python3 -c 'import json,sys,os;m=os.environ["BUDGET_MSG"];print(sum(1 for l in open(sys.argv[1]) if l.strip() and m in (json.loads(l).get("reasoning_tail") or "")))' \
    hardware/arrietty/benchmarks/bench24/results/<mnemonic>/finish.jsonl
  ```

  Both numbers go in the result line. Run 19's runner wrote `0/164
  empty` on rows whose samples held up to 53 empty answers; the
  coordinator corrected the site. Do not repeat that.
- Every scoring run starts `benchmarks/run-watch.sh` as the checklist
  says, with the CUDA signatures.
- **Crashes and wall:** `docs/methodology/evalplus.md`, "Crashes and
  wall time". Write every part in `state.md` in UTC.
- Commit on `run24` as results land. Push `run24` at every block close
  and message the coordinator session with the block, the config, the
  result line and the commit id. **No message between pushes** (owner
  rule, 2026-09-11). Every gate and every stop-and-ask goes to the
  coordinator with the block, the condition and your candidate answer;
  keep the GPU busy with the next block that does not depend on it.
  Never message the run 23 runner. Never ask the owner a
  multiple-choice question. Never run a bare `git stash`.
- **A recoverable failure is retried at once, inside its block.**
  `retry-sweep` holds only what needed a human.
- A bug in a run tool goes to a subagent on the best available model
  at once; the run does not wait for it.
- Archive evidence before a session closes:
  `tools/archive-evidence.sh hardware/arrietty/benchmarks/bench24/results run24`.
- Every file a block writes goes under
  `hardware/arrietty/benchmarks/bench24/results/`,
  `hardware/arrietty/calibrations/` or
  `~/.local/share/choose-a-local-llm/`. Nothing under `/tmp`.

## The files

Fixed identity. Repo `prism-ml/Ternary-Bonsai-2-27B-gguf` at revision
`6ed5e12bf84b7a63069882c91dd9e9218647d17b`, Apache 2.0, architecture
`qwen35`, trained context 262144.

| id | file | size | alias |
|---|---|--:|---|
| primary | `Ternary-Bonsai-2-27B-PQ2_0.gguf` | 7,206,168,928 B | `bonsai2-27b-pq2` |
| second | `Ternary-Bonsai-2-27B-PTQ1_0.gguf` | 5,946,648,928 B | `bonsai2-27b-ptq1` |

```bash
hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PQ2_0.gguf \
  --revision 6ed5e12bf84b7a63069882c91dd9e9218647d17b
hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PTQ1_0.gguf \
  --revision 6ed5e12bf84b7a63069882c91dd9e9218647d17b
```

Fetch both in `machine-setup`; a download never blocks a block.
Record each sha256 and size in `state.md`, and compare the size with
this table. A mismatch is stop and ask.

Every serve command of this run carries `--no-mmproj`. The vision
weights are a separate file of that repository and this run never
fetches them. `--parallel 1`, `-ngl 999`, `--fit off`, `-fa on`, port
8081, as every block on this card.

**Do not fetch** `Ternary-Bonsai-2-27B-F16.gguf` (53.8 GB; the disk
does not hold it) or anything from the `-dev` repository. The `-dev`
file names a fork requirement of its own and is not in this run.

## The server

**This model does not run on the llama.cpp build this machine uses.**
The model card is explicit: stock llama.cpp rejects `PQ2_0` and
`PTQ1_0` as unknown types, and it loads a `Q2_0` file incorrectly and
produces garbage, because it has no Hadamard activation runtime. The
build for this run comes from the publisher's fork,
`PrismML-Eng/llama.cpp`.

This is the first gate of the run, and it has no fallback inside the
run: a wrong binary produces numbers that look like results and are
not.

1. Take the fork's newest release binary with CUDA support, from
   <https://github.com/PrismML-Eng/llama.cpp/releases/latest>, into
   `~/.local/share/choose-a-local-llm/llama.cpp-prism/`. Never under
   `/tmp`.
2. No release binary matches this card (CUDA, compute 12.0, `sm120`):
   build the fork from source in
   `~/.local/share/choose-a-local-llm/llama.cpp-prism/src`, with the
   same CMake flags run 17 used for the stock build. Read the fork's
   own build instructions first; its extra runtime may need a flag the
   stock build does not have. A build needs no `sudo`; a step that
   does is stop and ask.
3. **Prove the binary before any measurement.** Serve the primary file
   at a small `-c` and send one chat completion with `curl`, a short
   coding question, thinking on at xhigh. Record the answer in
   `state.md`. Garbage text, an empty answer, a refusal to load the
   type, or any `unknown type` line in the log is **stop and ask**, and
   no block of this run starts.
4. Record the fork's version, its commit and where the binary lives in
   `state.md`. Every serve command of this run uses that binary, and
   `$LLAMA_SERVER` in the commands below means it.
5. **Check the thinking-budget flags on the fork:**
   `$LLAMA_SERVER --help | grep -A1 reasoning-budget`. Both flags
   present: the run is as written. **Either flag missing:** every
   `*-budget-*` block becomes a natural run at
   `EVALPLUS_MAX_NEW_TOKENS=30000` with no reasoning flag, the
   `*-forced-rerun` blocks do not run, and you write that deviation in
   `state.md` and tell the coordinator at the block close. Do not wait
   for an answer.

## `machine-setup`

Read `docs/methodology/evalplus.md`, whole, with "Unproven yet".

1. `git log --oneline -1 -- benchmarks/thinking-budget.py
   benchmarks/calibrate.py benchmarks/run_codegen_wrapper.py`: all
   three must be present and `calibrate.py` must write
   `reasoning_len`. If not, `git fetch origin && git merge
   origin/master` first.
2. `export EVALPLUS_PYTHON=...` as run 19's `machine-setup` step 1
   says; `evalplus.codegen --help | head -2`.
3. The read-only machine checks of run 19's Essentials. Record
   `vram_start_mb`, `MemAvailable`, and `df -h ~`. The two files need
   13.2 GB of disk.
4. Start both downloads of "The files", then do "The server", steps 1
   to 5, while they run.
5. **The corpus server**: `cd hardware/kamaji/research/run4/results &&
   python3 -m http.server 8089 --bind 127.0.0.1` in the background;
   stop it after `sweep-bonsai2-ptq1`. The file is
   `corpus-mendel-js.txt`, sha256
   `f4cbe063ef231d753e736b60107b6601705a1acb448b05d9f8b8afbdfcec583c`;
   verify it once. Port 8089 may already be busy: check for a stale
   server before you start one, and never kill the run 23 runner's
   processes.
6. `mkdir -p hardware/arrietty/benchmarks/bench24/results
   ~/.local/share/choose-a-local-llm ~/.local/share/mendel-benchmark`.

Done: every version, hash, the fork's commit and the probe answer in
`state.md`, committed. No result table.

## The ladder

Run 17's ladder, `hardware/arrietty/benchmarks/bench17/AGENT.md`,
section "The ladder", steps 1 to 4, with `$LLAMA_SERVER` in place of
`llama-server`. This is a dense model and no part of it goes to host
RAM, so the `--n-cpu-moe` part of that section does not apply.

## The kvpick blocks

Read `docs/methodology/kv-cache-pick.md`.

One block per file: `bonsai2-pq2-kvpick` and `bonsai2-ptq1-kvpick`.

These weights are small, so the KV cache is the large allocation here,
not the model. **Start the ladder at the trained context, `-c 262144`,
and step down from there**; do not start at a value copied from a 12
GiB build. A planning estimate, from the architecture and never a
result: about 34 MiB of KV per 1024 tokens at q8_0, and twice that at
f16. It says the card may hold the whole trained window at q8_0. Prove
it or find where it stops.

1. Ladder at `--cache-type-k q8_0 --cache-type-v q8_0`. Write
   `<alias>_c_q8`.
2. Ladder at `--cache-type-k f16 --cache-type-v f16`. Write
   `<alias>_c_f16`.
3. A candidate `-c` counts only when one real request of about that
   size serves, never a one-token probe
   (`docs/methodology/kv-cache-pick.md`, "Pitfalls").
4. The pick is the type with the larger serving `-c`; at equal `-c`,
   the faster type at 32K from the sweep of that file. Write
   `<alias>_kv` and `<alias>_c` in `state.md`.

There is **no context gate in this run**. A small window is a result
here, not a stop.

Done: both ladders and the pick in `results.md` and `state.md`.
Commit, push, message the coordinator.

## The sweep blocks

Read `docs/methodology/context-creep.md`, "Speed measurement rules".

The creep tool does not run on this machine. Speed comes from
`llama-benchy`, with run 17's command shape,
`hardware/arrietty/benchmarks/bench17/AGENT.md`, section "The benchy
command", `bench24` in every path, `<arm>` the cache type of the pick.

Fixed: the file, its pick, no drafter. Derived: `-c` from
`<alias>_c`; depths 4096, 24576, 65536, and `<alias>_c` minus 1024.
Drop any depth above `<alias>_c` minus 1024.

Tokenizer for `llama-benchy`: this architecture is `qwen35`, so use
`unsloth/Qwen3.8-27B`, the base tokenizer the other blocks of this
card use. A tokenizer that fails to load is a deviation to write down,
and then the block uses the tokenizer the fork's own server reports.

Write `<alias>_clean` in `state.md`: the deepest depth at or above 8
tok/s. **A table and no pick.**

Done: one table per file in `results.md`. Commit, push, message the
coordinator. Stop the corpus server after `sweep-bonsai2-ptq1`.

## `bonsai2-pq2-calibrate-think`

Read `docs/methodology/evalplus.md`, "Calibrate the output budget
FIRST" and "Unproven yet".

Calibration name `bonsai2-pq2-xhigh-think`, alias `bonsai2-27b-pq2`,
extra body `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}`.
Serve at `-c 32768` with the pick, no thinking budget.

```bash
CALIBRATION_DIR=hardware/arrietty/calibrations "$EVALPLUS_PYTHON" \
  benchmarks/calibrate.py bonsai2-pq2-xhigh-think bonsai2-27b-pq2 \
  '{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}'
benchmarks/thinking-budget.py derive \
  hardware/arrietty/calibrations/calibration-bonsai2-pq2-xhigh-think.json
```

Check `resolved_reasoning_effort` on every row. A row that resolves to
another level is stop and ask: the fork's template may not take the
same keyword. Write `bonsai2_pq2_think_budget`,
`bonsai2_pq2_answer_budget` and `bonsai2_pq2_max_tokens` in `state.md`
with the converged and cut counts and the margin.

**A converged row with an empty answer is not a converged row.** The
derive tool already drops it. When one appears, write its task id, its
reasoning length and its wall time in `state.md`: run 23 found one at
effort medium and it is evidence the experiment wants.

Done: the three values in `state.md`, committed. Push, message the
coordinator.

## `bonsai2-pq2-budget-xhigh`

Read `docs/methodology/evalplus.md`, "Steps".

1. **Serve** at `-c 32768` with the pick, plus `--reasoning-budget
   <bonsai2_pq2_think_budget> --reasoning-budget-message "$BUDGET_MSG"`
   (or without them, by "The server" step 5). Log to
   `results/server-bonsai2-pq2-budget-xhigh.log`. Verify with a real
   request, read `nvidia-smi`, write both in `state.md`.
2. **Start the watcher.**
3. **Run** the full 164:

   ```bash
   RESULTS_BASE=hardware/arrietty/benchmarks/bench24/results \
     EVALPLUS_MAX_NEW_TOKENS=<bonsai2_pq2_max_tokens> \
     benchmarks/run-humaneval.sh bonsai2-pq2-budget-xhigh bonsai2-27b-pq2 \
     '{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}'
   ```

4. **Done**: base and plus pass@1, the empty count from the samples,
   the forced count from the finish log, both budgets, `max_tokens`
   and the wall with its parts, as one row in `results.md`. Commit,
   push, message the coordinator. Stop the watcher.

**The agent gate.** A base pass@1 under 0.800 means
`bonsai2-pq2-smoke-xhigh` and the blind row do not run: write the gate
line, tell the coordinator, and go on with the second file's blocks.

## `bonsai2-pq2-forced-rerun`

Follow run 21's block,
`hardware/arrietty/benchmarks/bench21/AGENT.md`, section "The forced
re-run blocks", steps 1 to 6, with the `bench24` paths, the
`bonsai2-pq2-budget-xhigh` directory as the budget directory, and
`EVALPLUS_MAX_NEW_TOKENS=30000`. Zero forced-failed problems: write
that and start the next block. This block does not run when the fork
has no budget flags.

## `bonsai2-pq2-smoke-xhigh`

Read `docs/methodology/mendel.md`, "The smoke" and "Window and
budget".

Serve the primary file with its pick and `-c` from
`bonsai2_27b_pq2_c`, no reasoning flag. Pin
`bonsai2_pq2_window`: `bonsai2_pq2_clean` rounded down to a multiple of
4096, at or under `-c`, never smaller (owner rule, 2026-09-06).

```bash
SMOKE_MENDEL_CONTEXT_WINDOW=<bonsai2_pq2_window> benchmarks/mendel-smoke.sh \
  bonsai2-27b-pq2 xhigh 2>&1 \
  | tee hardware/arrietty/benchmarks/bench24/results/mendel-smoke-bonsai2-pq2.log
```

Pass is one commit, clean tree, no repetition loop, inside the cap. A
fail means the blind row does not run. After the smoke, read its
session log for a thinking block; none means the pi entry did not
reach the server, and that is stop and ask.

## `bonsai2-pq2-mendel-blind-xhigh`

Read `docs/methodology/mendel.md`, whole, with "House rules for runs
from this project".

simulator(mendel) blind, prompt v1.1, base tag `benchmark-blind-base`.
Fixed: the server of the smoke unchanged, level xhigh. Derived: the
window from `bonsai2_pq2_window`; `maxTokens` and `reserveTokens`
8192; keep budget 8192 under a window of 65536, pi's default 20000
above it.

Before the run: `gh auth status` must pass, and `git stash clear` in
`~/code/mendel-benchmark` (owner rule, 2026-09-12).

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<bonsai2_pq2_window> \
  ./run-worker.sh bonsai2-27b-pq2 pi blind xhigh
```

Row `model` value: `bonsai2-27b-pq2 (prism-ml PQ2_0, xhigh,
arrietty)`; `model_id` the repo and file at the revision; `hardware`
`arrietty`. The config note carries the file and its revision, **the
fork and its commit**, the `-c`, the cache type, the window, the
reserve, the keep budget, the compaction count, the source block of
each value, `vram 16311 MiB`, the sampling defaults the server
applied, and the temperature and top_p from the run's `meta.json`.
The fork belongs in the note of every row of this run: a reader who
takes the stock binary gets garbage from these files.

Verify `peak_context` with `benchmark/count-tool-calls.mjs` before the
row commits, and put peak context and the tool-call count in
`results.md`. A row that ends on a repetition loop is a valid partial.
The 300-minute wall gives a partial, which is a row. After the run,
`pkill -f "Mendel Daemon"`.

## `retry-sweep`

The blocks that waited on a human, oldest first.

## Not in this run

- The F16 file, the `-dev` repository, the mmproj files, the MLX
  build, the WebGPU space.
- Any level but xhigh. The card says `low` is not supported, and
  `medium` is not this run's question.
- A drafter, a second cache type after each pick, any weight in host
  RAM, any MLX or LM Studio server, any other model.
- Any measurement taken with the stock llama.cpp binary.
- Anything at all inside run 23's worktree, branch or run folder.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
changed and why, machine state left behind, evidence archived. Push
and message the coordinator. The coordinator writes `report.md`, adds
the findings to `hardware/arrietty/benchmarks/INDEX.md`, decides what
reaches the site, and publishes.
