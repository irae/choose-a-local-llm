# Run 10 — the missing curves, the Mendel smoke, the f16 re-scores (Mac)

You are the runner, on the Mac. Read this file, then the pages each
block names at its start, and nothing else. Write all prose in
ASD-STE100 Simplified Technical English.

## Essentials

- `hardware/m1-max-32gb/benchmarks/bench10/state.md` holds what earlier sessions of this run
  did. Resume where its handing-over section says.
- **FIRST ACTION, before anything else:**
  `git worktree add ../choose-a-local-llm-run10 -b run10` (or `cd`
  into it if it exists), then `cd ../choose-a-local-llm-run10`. Verify
  with `pwd` and `git worktree list`. Every command of this run happens
  there, never in `~/code/choose-a-local-llm`.
- Then `docs/methodology/checklist.md`, whole, once per session. Its
  rule 1 is this run's rule too: the GPU does not sit idle while a
  block is runnable. The cold-start sequence takes its values from
  `~/.config/choose-a-local-llm/machine.md`. The reboot is
  conditional; the checklist says when.
- Before any Mendel block: `git -C ~/code/mendel-benchmark pull
  --ff-only` on `benchmark` (the runner alarms, commit `a41170a4`,
  must be in). The Mendel smoke tool is `benchmarks/mendel-smoke.sh`;
  this run is its first use against a real server, so a bug in it goes
  to the subagent rule above.
- Serve the exact files each block names. No block of this run may
  download anything. A missing file is stop and ask.
- Never run a bare `git stash`. WIP commits on `run10` instead. Commit
  on `run10` as results land: `state.md`, `results.md`, the files
  under `results/`. Never push the run branch. When the owner asks to
  stop, follow the stop-and-sync steps in `AGENTS.md`.
- Scoring is LLM judgment: score every Mendel run in a subagent on the
  best available model, per the Mendel `PLAN.md` "How to score a run".
  Any bug found in a run tool during the run (the run watcher, the
  Mendel smoke, the creep runner) goes to a subagent on the best
  available model at once; the run does not wait for it.
- One model on the GPU at a time, port 8081. Quit the LM Studio app
  before any llama-server or mlx work and confirm with
  `pgrep -fl "LM Studio"`, never with `lms`.
- **The run watcher is on trial in this run.** On every scoring block
  start `benchmarks/run-watch.sh` as the checklist says, and beside it
  the two `sunset/` scripts with their own log files
  (`sunset/mem-watch.sh`, `sunset/liveness-watch.sh`). At block close
  write in `state.md` what each saw: memory lines against memory
  lines, every stall or death verdict against the other's. When the
  new watcher matched the old ones over the whole run, delete
  `sunset/` in the same commit as the closing `state.md`.
- **Gates drop configs.** A config that fails a gate below is dropped
  from the rest of this run: write why in `state.md`, commit, start the
  next block. Only a line in this file that says "stop and ask" pauses
  the run.
- Do not change published pages or `models.json`. Every number goes
  into `results.md` with the exact command that produced it. The
  coordinator publishes.
- Archive evidence before the session closes:
  `tools/archive-evidence.sh hardware/m1-max-32gb/benchmarks/bench10/results run10`.

## Block A — the curves still missing

Read `docs/methodology/context-creep.md` and `docs/methodology/kv-cache-pick.md`.
Three server configs have no current curve. The KV type is already
picked for both models (Gemma-4 family: f16, run 2 and run 9), so the
slot configs run at f16, not at their published q8_0. `-c` is the total
across slots; when the published value does not load, binary-search the
largest `-c` that loads toward it, verify each candidate with one real
completion, and record the search. Sweep one slot; the other slots stay
loaded and idle (`context-creep.md`, "Multi-context configs").

```bash
# A1 gemma12-gguf-4x, f16, published -c 1048576 (will not load; search down from 262144 x 4)
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b-4x --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 4 --parallel 4 \
  -ngl 999 -fa on -c <largest that loads> \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench10/results/server-gemma12-gguf-4x-f16.log

# A2 gemma26-gguf-2x, f16, published -c 376832 (will not load; the single slot loads 212992)
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias gemma-4-26b-a4b-2x --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 2 --parallel 2 \
  -ngl 999 -fa on -c <largest that loads> \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench10/results/server-gemma26-gguf-2x-f16.log
```

For A1 and A2, the full creep on one slot:

```bash
DEPTH_LIST="4096,8192,16384,24576,32768,49152,65536,81920,98304,114688,131072,147456,163840,180224,196608,212992,229376,245760,262144" \
MODEL=<alias> python3 tools/sweeps/creep_llama.py \
  | tee hardware/m1-max-32gb/benchmarks/bench10/results/creep-<slug>-f16.tsv
```

A3, LM Studio `gemma-4-12b-it-mlx`: the row reads `pending` for memory.
Load per the published command (`lms load gemma-4-12b-it-mlx --parallel 4
--gpu max -y`, `lms server start --port 8081`, verify with `curl -s
http://127.0.0.1:8081/v1/models`), then one prefill-jump creep with a
control point: `DEPTH_LIST="4096,131072"` on
`tools/sweeps/creep_lmstudio.py`, output to
`results/creep-gemma12-lmstudio-131k.tsv`. The `wired_mb` of the
131072 row is the number. Quit the app after.

Done means, per config: the `-c` search table where one happened, the
curve, the verdict (speed or mem, with the finer reason), draft
acceptance beside every tok/s where a drafter ran, all in `results.md`,
committed. No gate here: these are existing rows.

Expected cost: 1 to 1.5 hours per full creep, minutes for A3.

## Block B — Mendel smoke, Qwen3.8 GGUF at f16

Read `docs/methodology/mendel.md`. The first question of this run: can
the llama row do agent work where the MLX row never completed a run.

Server:

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 49152 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench10/results/server-qwen38-gguf-f16-smoke.log
```

Check `~/.pi/agent/models.json` entry `qwen3.8-27b` reads
`contextWindow` 49152 and `maxTokens` 8192 (set 2026-09-05); do not
edit it. Then:

```bash
benchmarks/mendel-smoke.sh qwen3.8-27b medium 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench10/results/mendel-smoke-qwen38-gguf-medium.log
```

Gate: `pass` sends the row to block E. `fail` drops Qwen3.8 GGUF from
blocks E and F of this run; the model goes to research. Either way the
`SMOKE-MENDEL` line goes into `results.md`.

Expected cost: under 30 minutes.

## Block C — Gemma-26B GGUF at f16, EvalPlus thinking on, then the gate

Read `docs/methodology/evalplus.md`. The score on the site was measured
at q8_0 KV; the row moved to f16 in run 9. Same server as the published
`gemma-4-26b-a4b` command (f16, `-c 212992`), server log to
`results/server-gemma26-gguf-f16-evalplus.log`. Start the run watcher
and the sunset scripts.

Calibrate first, thinking on:

```bash
benchmarks/calibrate.py gemma26-gguf-think gemma-4-26b-a4b \
  '{"chat_template_kwargs":{"enable_thinking":true}}'
```

The old calibration did not converge (two `length` stops), and the old
full run used `EVALPLUS_MAX_NEW_TOKENS=30000` by hand. Use 30000 again,
whatever the new calibration says, so the two scores compare; record
the new calibration beside it.

```bash
RESULTS_BASE=hardware/m1-max-32gb/benchmarks/bench10/results \
EVALPLUS_MAX_NEW_TOKENS=30000 \
benchmarks/run-humaneval.sh gemma26-gguf-think gemma-4-26b-a4b \
  '{"chat_template_kwargs":{"enable_thinking":true}}'
```

Record base, plus, empty, wall in `results.md`, against 0.713/0.701
and 46/164 empty.

Gate, the owner's rule: base pass@1 at or above 0.800 continues, in
this block, to the Mendel smoke and then Mendel blind. Below 0.800 the
model stops here; blocks D and F still run, and the owner decides
later against the competing models.

On a pass: `benchmarks/mendel-smoke.sh gemma-4-26b-a4b <on-level>`,
where `<on-level>` is the pi level the entry's `thinkingLevelMap` maps
to thinking on (read the entry, record the level). A smoke `fail` ends
the model's part of this run. A smoke `pass`:

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh gemma-4-26b-a4b pi blind <on-level>
```

Score per `PLAN.md` "How to score a run" in a subagent on the best
available model, one new row, `generate-report.mjs`, commit and push
`benchmark`. The row's config note says `f16 KV, -c 212992`. After
the run: `pkill -f "Mendel Daemon"`, clean per `PLAN.md` "Cleanup".

Expected cost: EvalPlus 1 to 2 hours with thinking on; Mendel up to 5
hours, a night block.

## Block D — Bonsai MLX thinking off: smoke, then guided

Run 9's deferred block C. Read `docs/methodology/mendel.md`. Owner
decision of 2026-09-03: Bonsai Mendel runs use thinking OFF. Check the
`prism-ml/Ternary-Bonsai-27B-mlx-2bit` entry has `"off": "off"` in
`thinkingLevelMap`. The worker starts the server its entry needs; no
server by hand.

1. `benchmarks/mendel-smoke.sh prism-ml/Ternary-Bonsai-27B-mlx-2bit off`.
   A `fail` ends the block.
2. `cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh prism-ml/Ternary-Bonsai-27B-mlx-2bit pi guided off`

Score as in block C, one row, the guided report with `--guided`. After
the run: `pkill -f "Mendel Daemon"`, clean, keep the branch. The blind
run is not in this run: the owner decides it from the guided score.

Expected cost: up to 5 hours, a night block.

## Block E — Qwen3.8 GGUF at f16, Mendel blind

Only if block B passed. Same server as block B. Start the run watcher
and the sunset scripts.

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh qwen3.8-27b pi blind medium
```

Score as in block C. The row's config note says `f16 KV, -c 49152,
maxTokens 8192`. This is the lowest Mendel priority of the run: every
other night block goes first.

Expected cost: up to 5 hours.

## Block F — full EvalPlus for the survivors, last

Read `docs/methodology/evalplus.md`. Calibrate each config first
(budget = max x 1.5, floor 8192; the non-converging rule where it
applies). Watcher and sunset scripts on every run. In this order:

1. Gemma-26B GGUF f16, thinking off (the secondary-model use):
   `run-humaneval.sh gemma26-gguf-off gemma-4-26b-a4b '{"chat_template_kwargs":{"enable_thinking":false}}'`
   on the block C server.
2. Qwen3.6 GGUF thinking off, never scored: the published
   `qwen3.6-35b-a3b` command (q8_0, `-c 49152`),
   `run-humaneval.sh qwen36-gguf-off qwen3.6-35b-a3b '{"chat_template_kwargs":{"enable_thinking":false}}'`.
3. Qwen3.8 GGUF f16, effort medium, only if block B passed: the block
   B server,
   `run-humaneval.sh qwen38-gguf-medium qwen3.8-27b '{"chat_template_kwargs":{"reasoning_effort":"medium"}}'`.
   Its cell carries the MLX score today; this decides whether the
   GGUF quant keeps it.

Record base, plus, empty, wall per run in `results.md`.

Expected cost: about 1 hour per config with thinking off, more with
effort medium.

## Order

A, B, C, D, E, F. Night blocks are C's Mendel run, D and
E; a night block starts the moment the previous block ends, per the
checklist's rule 1. Nothing in this run waits for the owner except the
two items below, which are not in it.

## Not in this run, waiting on owner decisions

- Qwen3.8 MLX guided and blind at effort low: the context grows past
  the 26624 window in agentic use and Metal OOMs (run 9 block E). A
  smaller `contextWindow` or an earlier compaction trigger first.
- Bonsai on the PrismML fork, blind thinking-high retry and the q8_0
  KV arm without the bias file: the KV bias corpus question.
- Bonsai MLX thinking off, blind: after the owner reads the guided
  score from block D.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
dropped and why, machine state left behind (wired limit, LM Studio,
worktrees), the watcher comparison verdict, evidence archived. The
coordinator adds the findings to `hardware/m1-max-32gb/benchmarks/INDEX.md` and publishes.
