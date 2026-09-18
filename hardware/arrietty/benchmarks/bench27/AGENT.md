# Run 27 — the runtime-ablated ternary model on the RTX 5060 Ti 16 GB

Starts when the coordinator says the card is free. One model serves on
this card at a time. About half a day of machine time. The list below
is the order and the run ends when the list ends or the owner says
stop.

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

The owner's word (2026-09-18): a third party publishes a
refusal-direction ablation of the ternary 27B model, applied **at
runtime** rather than baked into the weights. This run measures what
that costs on the task this project cares about.

It runs on **one configuration only**: the best arm run 24 found, the
dense packing at f16, which scored 82 on the blind agent task. The file
is unchanged and stays byte-identical; the ablation arrives as a
rank-1 LoRA adapter that the server applies while it serves.

The question is narrow: does a runtime ablation move the agent score,
the quality gate or the speed of the arm it is applied to.

**This run measures; it decides nothing.**

## The order

**This list is the order.**

- `machine-setup`
- `orca-ptq1-f16-ladder`
- `sweep-orca-ptq1-f16`
- `orca-ptq1-f16-mendel-blind-xhigh`
- `orca-ptq1-f16-evalplus-calibrate`
- `orca-ptq1-f16-evalplus-budget-xhigh`
- `orca-ptq1-f16-evalplus-forced-rerun`
- `retry-sweep`

The agent row runs before the EvalPlus group, and **no smoke runs**
(owner, 2026-09-18), as in run 24. The 0.800 EvalPlus gate therefore
does not apply to the agent row; write that line in its config note.

## Essentials

- `bench27/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION after the wakeup:** `cd
  ../choose-a-local-llm-run27`, the worktree the coordinator prepared
  for you on branch `run27`. Verify with `pwd` and `git worktree
  list`. If it does not exist: `git worktree add
  ../choose-a-local-llm-run27 -b run27 master`. Every command of this
  run happens there.
- **Branches, exactly.** You work on `run27` and only on `run27`. To
  take an update: `git merge master` from your worktree, then push
  `run27`. Never check out `master`, never merge `run27` into
  `master`, never push `master`.
- Then `docs/methodology/checklist.md` and
  `docs/methodology/status-lines.md`, whole, once per session.
- **This machine is Linux, not the Mac.** Read run 19's runbook,
  `hardware/arrietty/benchmarks/bench19/AGENT.md`, section
  "Essentials", from "This machine is Linux" to the end of the list.
- **Another run may hold the card.** Never touch another run's
  worktree, branch or processes, and never kill a server you did not
  start.
- **Effort xhigh**, the level of every row of this model.
- **No temperature and no sampling parameter is passed to any server.**
  Record what the server applies; run 24 measured `min_p 0.05` where
  the model card publishes `0.0`.
- **The budget message is fixed for the whole run:**

  ```bash
  export BUDGET_MSG="Thinking budget reached. Give the final answer now."
  ```

- **Count empties from the samples, never from a log line**, and count
  forced answers from `finish.jsonl`. Both commands are in
  `hardware/arrietty/benchmarks/bench24/AGENT.md`, Essentials, with
  `bench27` in place of `bench24`.
- Commit on `run27` as results land. Push `run27` at every block close
  and message the coordinator session with the block, the config, the
  result line and the commit id. **No message between pushes.**
- **A recoverable failure is retried at once, inside its block.**
- Archive evidence before a session closes:
  `tools/archive-evidence.sh hardware/arrietty/benchmarks/bench27/results run27`.
- Everything a block writes goes under
  `hardware/arrietty/benchmarks/bench27/results/`,
  `hardware/arrietty/calibrations/` or
  `~/.local/share/choose-a-local-llm/`. Nothing under `/tmp`.

## The config

Nothing is downloaded for this run. Both parts are already on the
machine.

| part | value |
|---|---|
| model file | `prism-ml/Ternary-Bonsai-2-27B-gguf`, `Ternary-Bonsai-2-27B-PTQ1_0.gguf`, revision `6ed5e12bf84b7a63069882c91dd9e9218647d17b` |
| adapter | `/home/irae/code/OrcaBonsai-27B-Uncensored/gguf/bonsai-abliterate-lora.gguf` |
| adapter sha256 | `f1669534803d340a496015f5c45125f3437b4d13ec764f40e34488ce83967f42` |
| adapter size | 9,682,464 bytes |
| adapter repo | `Continuum-AI-Corp/OrcaBonsai-27B-Uncensored`, clone at commit `947a80c` |
| server | the PrismML fork, release `prism-b10685-7dffb15`, commit `7dffb158d` |
| alias | `bonsai2-27b-ptq1-f16-orca` |
| KV | f16 |
| level | xhigh |

**The adapter scale is 1.0, and only 1.0** in this run. The publisher
describes scale 1 as the exact projection, scale 2 as the one that
flips the prompts that still refuse, and scale 3 and above as
over-projection that degrades and then collapses the output. This run
measures the exact projection against run 24's unablated rows. A second
scale is a second row and a later decision.

```bash
$LLAMA_SERVER -m "$(hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PTQ1_0.gguf)" \
  --lora /home/irae/code/OrcaBonsai-27B-Uncensored/gguf/bonsai-abliterate-lora.gguf \
  --alias bonsai2-27b-ptq1-f16-orca --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c <orca_c> \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

The adapter is not merged into the weights. llama.cpp builds a LoRA
into the graph as two extra matmuls on the activation, at 129
intervention sites, which is what lets the edit survive at 1.75 bits.
So it costs graph work on every token, and the speed block below is
what says how much.

## `machine-setup`

1. The read-only machine checks of run 19's Essentials. Record
   `vram_start_mb`, `MemAvailable` and `df -h ~`.
2. Verify the adapter: `sha256sum` and `stat -c%s` against the table
   above. A mismatch is stop and ask.
3. `$LLAMA_SERVER --help | grep -E "lora|lora-scaled"`: both flags must
   print. A build without them is stop and ask.
4. **Prove the pair before any measurement.** Serve the config at a
   small `-c` and send one chat completion with `curl`, thinking on at
   xhigh. The answer must be coherent. Then read the server log for the
   adapter: it must report the LoRA loaded, with its tensor count.
   Garbage text, a refusal to load the adapter, or a silent load with
   no adapter line is **stop and ask**.
5. `export EVALPLUS_PYTHON=...` as run 19's `machine-setup` says.
6. **The corpus server**: `cd hardware/kamaji/research/run4/results &&
   python3 -m http.server 8089 --bind 127.0.0.1` in the background;
   stop it after `sweep-orca-ptq1-f16`. Check for a stale server on
   that port first, and never kill another run's process.
7. `mkdir -p hardware/arrietty/benchmarks/bench27/results`.

Done: the hashes, the flags, the probe answer and the adapter's log
line in `state.md`, committed. No result table.

## `orca-ptq1-f16-ladder`

The adapter adds graph work and a little memory, so the window is not
assumed. Use run 17's ladder,
`hardware/arrietty/benchmarks/bench17/AGENT.md`, section "The ladder",
steps 1 to 4.

Planning value for the first load: **139264**, the f16 ceiling run 24
measured for this file without the adapter. A candidate `-c` counts
only when one real request of about that size serves.

Write `orca_c` and the ladder lines in `state.md`. A ceiling below
139264 is a result, not a fault: it is the adapter's memory cost.

## `sweep-orca-ptq1-f16`

Read `docs/methodology/context-creep.md`, "Speed measurement rules".
`llama-benchy`, run 17's command shape, `bench27` in every path,
`<arm>` equal to `lora1`.

Depths 4096, 24576, 65536 and `orca_c` minus 1024. Tokenizer
`unsloth/Qwen3.8-27B`.

Run 24 measured the same file at f16 without the adapter: 42.1, 37.3,
30.1 and 22.4 tok/s at 4096, 24576, 65536 and 138240. **The difference
against those numbers is the price of the runtime ablation**, and it is
the point of this block. Write `orca_clean` in `state.md`.

Done: one table in `results.md`, one line per depth, beside run 24's
numbers for the same depths. Commit, push, message the coordinator.
Stop the corpus server.

## `orca-ptq1-f16-mendel-blind-xhigh`

Read `docs/methodology/mendel.md`, "House rules for runs from this
project" and "Comparing two builds of one model".

simulator(mendel) blind, prompt v1.1, base tag `benchmark-blind-base`,
level xhigh. **No smoke** (owner, 2026-09-18), and the row runs before
any EvalPlus score of this config, so the 0.800 gate does not apply.

Window `orca_window`: `orca_clean` rounded down to a multiple of 4096,
at or under `orca_c`, never smaller (owner rule, 2026-09-06). **Never
match run 24's window**; give this arm the window its own sweep
measured.

Before the run: `gh auth status` must pass, and `git stash clear` in
`~/code/mendel-benchmark`.

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<orca_window> \
  ./run-worker.sh bonsai2-27b-ptq1-f16-orca pi blind xhigh
```

Row `model` value: `bonsai2-27b-ptq1-f16-orca (prism-ml PTQ1_0, xhigh,
arrietty)`. The config note carries the file and revision, **the
adapter, its sha256 and its scale**, the fork release and commit, the
`-c`, `f16`, the window, the reserve, the keep budget, the compaction
count, `vram 16311 MiB`, the sampling the server applied, and the line
"no smoke, and the row ran before any EvalPlus score of this config, so
the 0.800 gate did not apply (owner, 2026-09-18)".

Verify `peak_context` with `benchmark/count-tool-calls.mjs`, put peak
context and the tool-call count in `results.md` beside the score, and
score it in a subagent **on Fable** (owner rule, 2026-09-18), from the
evidence pack, the session log and the worktree diff, never from the
model's own claims. **Check the subagent's arithmetic**: its
per-criterion breakdown must sum to the score it reports. Record the
scoring model in `results.md` beside the score.

Run 24's unablated row of the same file and cache scored 82, with a
CRITICAL trap A and 17 chore-typed commits. That is the row this one is
read against.

## The EvalPlus group

Same shape as run 24's groups: `orca-ptq1-f16-evalplus-calibrate`, then
`-budget-xhigh`, then `-forced-rerun`.

1. The calibration serves the config with no budget flag at `-c 32768`,
   writes its own file `orca-ptq1-f16-xhigh-think`, then
   `thinking-budget.py derive`. A converged row with an empty answer is
   not converged; the tool drops it, and you write its task id, its
   reasoning length and its wall time in `state.md`.
2. The scored run is the full 164 at the derived budget, at `-c 32768`,
   with the watcher running.
3. The forced re-run is the natural re-run of the forced failures at
   `EVALPLUS_MAX_NEW_TOKENS=30000`, by run 21's block shape.

## `retry-sweep`

The blocks that waited on a human, oldest first.

## Not in this run

- A second adapter scale. Scale 1.0 only.
- The MLX path of that repository, its Swift runtime, its Docker image
  and its own refusal evaluation. This project measures coding work.
- Any other file, any other cache type, any other level, a drafter, a
  smoke, a guided agent row.
- Any measurement taken with a stock llama.cpp binary.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
changed and why, machine state left behind, evidence archived. Push and
message the coordinator. The coordinator writes `report.md`, adds the
findings to `hardware/arrietty/benchmarks/INDEX.md`, decides what
reaches the site, and publishes.
