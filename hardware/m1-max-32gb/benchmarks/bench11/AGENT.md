# Run 11 — Gemma-26B GGUF Mendel at both thinking levels, the deferred Qwen3.8 score (Mac)

You are the runner, on the Mac. Read this file, then the pages each
block names at its start, and nothing else. Write all prose in
ASD-STE100 Simplified Technical English.

## Essentials

- `hardware/m1-max-32gb/benchmarks/bench11/state.md` holds what earlier
  sessions of this run did. Resume where its handing-over section says.
- **FIRST ACTION, before anything else:**
  `git worktree add ../choose-a-local-llm-run11 -b run11` (or `cd`
  into it if it exists), then `cd ../choose-a-local-llm-run11`. Verify
  with `pwd` and `git worktree list`. Every command of this run happens
  there, never in `~/code/choose-a-local-llm`.
- Then `docs/methodology/checklist.md`, whole, once per session. Its
  step 2 is new for this run: `tools/preflight.sh` runs first and must
  print every line `ok` before a block starts. Act on `fix` and `ask`
  lines the way the checklist says; never sudo, never reboot on your
  own. Record the `memory` line's starting numbers in `state.md`.
- `gh auth status` must pass at run start and again right before every
  Mendel run, blind or guided. A failing status means no Mendel block
  starts; block 5 still runs. Run 10 lost a night to a dead token.
- Before any Mendel block: `git -C ~/code/mendel-benchmark pull
  --ff-only` on `benchmark`. Read the entry `gemma-4-26b-a4b` in
  `~/.pi/agent/models.json` and record its `thinkingLevelMap`,
  `contextWindow` (212992) and `maxTokens`; do not edit it. Thinking
  off is pi level `off`; thinking on is the level the map names for on
  (`high` in run 10).
- Known condition of every Mendel row in this run: the pinned pi
  config the worker builds uses pi's default `reserveTokens` 16384,
  not 8192. Do not change it. Write it in the row's config note.
- Serve the exact files each block names. No block of this run may
  download anything. A missing file is stop and ask.
- Never run a bare `git stash`. WIP commits on `run11` instead. Commit
  on `run11` as results land: `state.md`, `results.md`, the files
  under `results/`. Push `run11` to origin at every block close and
  message the coordinator session with the block, the config, the
  result line and the commit id; the coordinator merges. When the
  owner asks to stop, follow the stop-and-sync steps in `AGENTS.md`.
- Scoring is LLM judgment: score every Mendel run in a subagent on the
  best available model, per the Mendel `PLAN.md` "How to score a run".
  Any bug found in a run tool during the run goes to a subagent on the
  best available model at once; the run does not wait for it.
- One model on the GPU at a time, port 8081. Quit the LM Studio app
  before any llama-server work and confirm with `pgrep -fl "LM
  Studio"`, never with `lms`.
- **The watcher trial continues.** Run 10 had one mismatch (the sunset
  liveness watcher called a false server death on a probe queued
  behind a live turn). On every scoring block start
  `benchmarks/run-watch.sh` as the checklist says, and beside it
  `sunset/mem-watch.sh` and `sunset/liveness-watch.sh` with their own
  log files under `results/`. At block close write in `state.md` what
  each saw. When the new watcher matched the old ones over the whole
  run, delete `sunset/` in the same commit as the closing `state.md`.
- **Manual loop check at every wakeup of a Mendel run.** The runner has
  no live alarm for a fast loop of identical tool calls (run 10: 85
  identical shell calls, zero commits, three hours). At every 20-minute
  wakeup run
  `python3 benchmarks/loop-check.py ~/code/mendel-benchmark/scratchpad/benchmark/runs/<slug>-events.jsonl`
  on the live events log. Exit 1 (ratio under 0.10) with no new commit
  on the run branch since the previous wakeup is a confirmed loop: kill
  the worker and the Mendel daemon, record the row as invalid with
  reason `repetition_loop`, the repeated command and the count, in
  `results.md`, and start the next block. A ratio under 0.10 with a
  new commit is a flag only; write it and continue.
- Status lines follow `docs/methodology/status-lines.md`: one short
  line in chat at every wakeup, the medium form in `state.md` at block
  close, the large form drafted in `results.md`.
- **Gates drop configs.** A config that fails a gate below is dropped
  from the rest of this run: write why in `state.md`, commit, start the
  next block. Only a line in this file that says "stop and ask" pauses
  the run.
- Do not change published pages or `models.json`. Every number goes
  into `results.md` with the exact command that produced it. The
  coordinator publishes.
- Archive evidence before the session closes, for run 10 too, which
  the last session did not do:
  `tools/archive-evidence.sh hardware/m1-max-32gb/benchmarks/bench10/results run10`
  `tools/archive-evidence.sh hardware/m1-max-32gb/benchmarks/bench11/results run11`

## The Gemma-26B server, blocks 1 to 4

Read `docs/methodology/mendel.md`. One server for four blocks; start it
once, keep it up between blocks. The published `gemma-4-26b-a4b`
command, f16 KV, `-c 212992`:

```bash
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias gemma-4-26b-a4b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 2 --parallel 1 \
  -ngl 999 -fa on -c 212992 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/server-gemma26-gguf-f16.log
```

Verify with one real chat completion before the first block. The file
is on disk (run 9 and run 10 served it).

The thinking level goes to the worker as its fourth argument. The
smoke at `off` passed in run 10 (9 calls, 1 commit, 16 s); the smoke
at `high` passed in run 10 (11 calls, 1 commit, 31 s). No smoke runs
again in this run.

After every Mendel run: score per `PLAN.md` "How to score a run" in a
subagent on the best available model, one new row, verify
`peak_context` and `tool_calls` with `benchmark/count-tool-calls.mjs`
against the row, `generate-report.mjs` (`--guided` for a guided row),
commit and push `benchmark`. Then `pkill -f "Mendel Daemon"`, clean
per `PLAN.md` "Cleanup", keep the run branch. The row's config note
says `f16 KV, -c 212992, reserveTokens 16384`.

## Block 1/5 — Gemma-26B, thinking off, Mendel guided

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh gemma-4-26b-a4b pi guided off
```

Done means: one scored guided row at `off`, valid or invalid with its
reason, in `results-guided.csv`, the `SMOKE`-style result line and the
telemetry in `results.md`, committed.

Expected cost: up to 5 hours, a night block.

## Block 2/5 — Gemma-26B, thinking off, Mendel blind

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh gemma-4-26b-a4b pi blind off
```

Done means: one scored blind row at `off` in `results.csv`, the same
records as block 1.

Expected cost: up to 5 hours.

## Block 3/5 — Gemma-26B, thinking on, Mendel guided

No guided row exists for this model at any level.

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh gemma-4-26b-a4b pi guided <on-level>
```

Done means: one scored guided row at the on level, the same records as
block 1. Expected cost: up to 5 hours; thinking on took 81 minutes for
the blind run in run 10.

## Block 4/5 — Gemma-26B, thinking on, Mendel blind: cite, unless the owner says rerun

A complete, valid blind row exists at `high` from run 10 (47.5/100,
8/8, branch `gemma-4-26b-a4b-high-issue-13`). The house rule is: do
not re-run a model that has a row. So this block is a citation: write
in `results.md` that the on/blind cell is the run 10 row, with its
score and branch, and go on to block 5.

The owner may say "rerun" before this block starts. Then:

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh gemma-4-26b-a4b pi blind <on-level>
```

and the new row replaces the old one under `PLAN.md`'s retry rule (a
valid earlier attempt by the model costs the fixed penalty; the
runbook does not decide that, the scorer applies the formula).

Stop the Gemma-26B server after this block. Wait for wired memory to
return to the preflight start value (checklist step 13) before block 5.

## Block 5/5 — Qwen3.8 GGUF f16, effort medium, EvalPlus

Deferred from run 10. Read `docs/methodology/evalplus.md`. The site
cell for this row carries the MLX effort-medium score
(0.982/0.939/100%); this run decides whether the GGUF quant keeps it.

Server:

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 49152 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/server-qwen38-gguf-f16-evalplus.log
```

Calibration: `benchmarks/calibration-qwen38-gguf-medium.json` exists
from run 10's start of this block. Open it. When it holds all 10
problems with a `finish_reason`, use it; when it is partial,
recalibrate:

```bash
benchmarks/calibrate.py qwen38-gguf-medium qwen3.8-27b \
  '{"chat_template_kwargs":{"reasoning_effort":"medium"}}'
```

Budget = max(observed max x 1.5, 8192). Record the observed max and
the budget in `results.md`. Then, with the run watcher and the sunset
scripts up:

```bash
RESULTS_BASE=hardware/m1-max-32gb/benchmarks/bench11/results \
EVALPLUS_MAX_NEW_TOKENS=<budget> \
benchmarks/run-humaneval.sh qwen38-gguf-medium qwen3.8-27b \
  '{"chat_template_kwargs":{"reasoning_effort":"medium"}}'
```

Done means: base, plus, empty, wall in `results.md`, against
0.982/0.939 and 0/164 empty, committed. No gate: the row keeps its
place either way, the score is the finding.

Expected cost: 1 to 2 hours with effort medium.

## Order

1, 2, 3, 4, 5. Blocks 1 to 3 are night blocks; a night block starts
the moment the previous block ends, per the checklist's rule 1. Block
4 is a citation unless the owner said rerun before it starts. Nothing
in this run waits for the owner.

## Not in this run

- Qwen3.6 GGUF thinking-off Mendel (the same gap): its real context
  ceiling is 8222 tokens (run 9), too small for the task before a `-c`
  fix. `backlog/mendel-thinking-off-gaps.md`.
- Bonsai MLX guided at thinking off: invalid twice in run 10; no third
  attempt without the owner's word. Its loop worktree
  (`../mendel-bench-guided-prism-ml-Ternary-Bonsai-27B-mlx-2bit-off`)
  stays for the owner's inspection; do not remove it.
- Qwen3.8 MLX guided and blind at effort low: the window question,
  `backlog/qwen38-mlx-window.md`.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
dropped and why, machine state left behind (wired limit, LM Studio,
worktrees), the watcher comparison verdict and whether `sunset/` was
deleted, evidence archived for runs 10 and 11. The coordinator adds
the findings to `hardware/m1-max-32gb/benchmarks/INDEX.md`, writes
`report.md`, and publishes.

## Open decisions for the owner

- Block 4: cite the run 10 row (the runbook's default) or rerun.
- `reserveTokens` 8192 in the kit's pinned settings: before this run,
  or after it. The runbook assumes after.
