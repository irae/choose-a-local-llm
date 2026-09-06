# Run 11 — every missing Mendel row, best configs first (Mac)

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
  starts; block 13 still runs. The last run lost a night to a dead
  token.
- Before any Mendel block: `git -C ~/code/mendel-benchmark pull
  --ff-only` on `benchmark`. The live loop stop must be in
  (`run-pi-rpc.mjs` ends a run with reason `repetition_loop`; see
  `PLAN.md`). If it is not in, stop and ask; do not start a Mendel run
  without it.
- Read `docs/methodology/mendel.md` before block 1. Every Mendel block
  follows its house rules: server by hand, one model on the GPU,
  `pkill -f "Mendel Daemon"` after each run, score in a subagent on the
  best available model per the Mendel `PLAN.md` "How to score a run",
  verify `peak_context` and `tool_calls` with
  `benchmark/count-tool-calls.mjs` against the row, run
  `generate-report.mjs` (`--guided` for a guided row), commit and push
  `benchmark`, keep the run branch.
- For each pi entry a block names, read it in `~/.pi/agent/models.json`
  and record `thinkingLevelMap`, `contextWindow` and `maxTokens` in
  `state.md`; do not edit it. A block that names an entry that does not
  exist is stop and ask.
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
- Any bug found in a run tool during the run goes to a subagent on the
  best available model at once; the run does not wait for it.
- One model on the GPU at a time, port 8081. Quit the LM Studio app
  before any server work and confirm with `pgrep -fl "LM Studio"`,
  never with `lms`.
- On every scoring block start `benchmarks/run-watch.sh` as the
  checklist says, with its memory log under `results/`. Nothing else
  runs beside it; the old watchers are gone.
- Status lines follow `docs/methodology/status-lines.md`: one short
  line in chat at every 20-minute wakeup, the medium form in `state.md`
  at block close, the large form drafted in `results.md`. A Mendel
  short line carries tasks done, prompt depth, nudges and the last
  commit time.
- **A run that ends on `repetition_loop` is invalid**, with the
  repeated call and the count in `results.md`, and the next block
  starts. No retry in this run.
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

## The order, and why

Thirteen blocks. Twelve are Mendel rows the site does not have; the
last is the deferred EvalPlus score. Configs are sorted by EvalPlus
base score, then decode speed at depth, then context; the config with
an 8K clean depth goes last whatever its score. A row that exists is
not run again.

## Server A, blocks 1, 2 and 5: Gemma-26B GGUF f16

The published `gemma-4-26b-a4b` command, f16 KV, `-c 212992`. Start it
once, keep it up through blocks 1, 2 and 5 (block 5 follows block 4
on another server; restart it then).

```bash
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias gemma-4-26b-a4b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 2 --parallel 1 \
  -ngl 999 -fa on -c 212992 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/server-gemma26-gguf-f16.log
```

Verify with one real chat completion. pi entry `gemma-4-26b-a4b`;
thinking off is level `off`, thinking on is the level the map names
for on (`high` last time). Smokes passed at both levels on 2026-09-06
(9 calls and 11 calls, one clean commit each); no smoke runs again.
Config note on every row: `f16 KV, -c 212992, reserveTokens 16384`.

### Block 1/13 — Gemma-26B, thinking off, Mendel guided

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh gemma-4-26b-a4b pi guided off
```

Done: one scored guided row at `off` in `results-guided.csv`, the
result line and the telemetry in `results.md`, committed. Expected: up
to 5 hours, a night block.

### Block 2/13 — Gemma-26B, thinking off, Mendel blind

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh gemma-4-26b-a4b pi blind off
```

Done: one scored blind row at `off` in `results.csv`. Expected: up to
5 hours.

## Server B, blocks 3 and 13: Qwen3.8 GGUF f16

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 49152 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/server-qwen38-gguf-f16.log
```

pi entry `qwen3.8-27b` (`contextWindow` 49152, `maxTokens` 8192).
Smoke passed 2026-09-06 (8 calls, one commit, 62 s). Config note:
`f16 KV, -c 49152, maxTokens 8192, reserveTokens 16384`.

### Block 3/13 — Qwen3.8 GGUF, effort medium, Mendel guided

The blind row exists (87/100). Only guided is missing.

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh qwen3.8-27b pi guided medium
```

Done: one scored guided row at `medium`. Expected: up to 5 hours (the
blind run took 129 minutes).

Stop server B after this block. Wait for wired memory to return to the
preflight start value (checklist step 13) before the next server.

## Server C, block 4: Gemma-12B GGUF f16, no drafter

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 262144 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/server-gemma12-gguf-f16.log
```

pi entry `gemma-4-12b`, thinking off is level `off`. The guided row at
`off` exists (37.5/100, partial on the model budget). Only blind is
missing. Config note: `f16 KV, no drafter, -c 262144, reserveTokens
16384`.

### Block 4/13 — Gemma-12B GGUF, thinking off, Mendel blind

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh gemma-4-12b pi blind off
```

Done: one scored blind row at `off`. Expected: up to 5 hours. Stop
server C after it; wait for wired recovery.

### Block 5/13 — Gemma-26B, thinking on, Mendel guided

Server A again. The blind row at `high` exists (47.5/100); guided at
any level does not.

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh gemma-4-26b-a4b pi guided <on-level>
```

Done: one scored guided row at the on level. Expected: up to 5 hours.
Stop server A after it; wait for wired recovery.

## Server D, blocks 6 and 7: Qwen3.6 MLX

This model has no agent row at all on MLX. Its window is 37K clean;
the task has needed about 46K on other models, so a partial on the
window is a possible result and still a row.

```bash
mlx_lm.server --model mlx-community/Qwen3.6-35B-A3B-4bit \
  --prompt-cache-size 2 --port 8081 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/server-qwen36-mlx.log
```

pi entry: the one whose model is `mlx-community/Qwen3.6-35B-A3B-4bit`
(record its id, `contextWindow` and `maxTokens`; the window must not
exceed 37K, the last stable depth). No entry is stop and ask. Thinking
on is the level the map names for on. Run the smoke first, because
this serving config never ran the agent task:

```bash
benchmarks/mendel-smoke.sh <pi-id> <on-level> 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/mendel-smoke-qwen36-mlx-on.log
```

A `fail` drops blocks 6 and 7. Config note: `mlx_lm.server,
--prompt-cache-size 2, thinking on, reserveTokens 16384`.

### Block 6/13 — Qwen3.6 MLX, thinking on, Mendel blind

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh <pi-id> pi blind <on-level>
```

### Block 7/13 — Qwen3.6 MLX, thinking on, Mendel guided

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh <pi-id> pi guided <on-level>
```

Done, each: one scored row. Expected: up to 5 hours each. Stop the
server after block 7; wait for wired recovery.

## Server E, blocks 8 and 9: Bonsai MLX, thinking off

The smoke at `off` passed 2026-09-06 (14 calls, one commit, 115 s).
Two guided attempts went invalid on the harness (a dead `gh` token,
then an 85-call identical-command loop). This is the third attempt,
with the live loop stop in the runner and `gh` checked first.

```bash
mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit \
  --prompt-cache-size 2 --port 8081 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/server-bonsai-mlx.log
```

pi entry `prism-ml/Ternary-Bonsai-27B-mlx-2bit`, level `off`. Config
note: `mlx_lm.server, --prompt-cache-size 2, thinking off,
reserveTokens 16384`.

### Block 8/13 — Bonsai MLX, thinking off, Mendel guided

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh prism-ml/Ternary-Bonsai-27B-mlx-2bit pi guided off
```

### Block 9/13 — Bonsai MLX, thinking off, Mendel blind

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh prism-ml/Ternary-Bonsai-27B-mlx-2bit pi blind off
```

Done, each: one scored row, valid or invalid with its reason.
Expected: up to 5 hours each. Stop the server after block 9; wait for
wired recovery.

## Server F, block 10: Bonsai on the PrismML fork, q4 KV

The blind row exists (12.5/100, partial). Guided is missing. The KV
bias file is generated, not downloaded: it must exist at
`~/.local/share/choose-a-local-llm/Ternary-Bonsai-27B-kv-bias.gguf`
(or `/tmp/Ternary-Bonsai-27B-kv-bias.gguf`). When neither exists,
regenerate it with the vendor's `make_kv_bias.sh` per
`docs/setups/m1-max-32gb/benchmarks/bonsai-27b.md`, and record in
`state.md` that the row runs on a regenerated file. The model file is
the committed snapshot under
`~/.cache/huggingface/hub/models--prism-ml--Ternary-Bonsai-27B-gguf/`.

```bash
LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server \
  -m ~/.cache/huggingface/hub/models--prism-ml--Ternary-Bonsai-27B-gguf/snapshots/<rev>/Ternary-Bonsai-27B-Q2_g64.gguf \
  --alias bonsai-prism \
  -ngl 999 -fa on -c 65536 --parallel 1 \
  --cache-type-k q4_0 --cache-type-v q4_0 \
  --kv-mean-center <bias file> \
  --jinja --port 8081 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/server-bonsai-prism.log
```

pi entry `bonsai-prism`, thinking on level as its map names (`high`
last time). Run the smoke first (this config never ran the smoke):

```bash
benchmarks/mendel-smoke.sh bonsai-prism <on-level> 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/mendel-smoke-bonsai-prism.log
```

A `fail` drops block 10. Config note: `prism fork, q4_0 KV + bias, -c
65536, reserveTokens 16384`.

### Block 10/13 — Bonsai fork, thinking high, Mendel guided

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh bonsai-prism pi guided <on-level>
```

Done: one scored guided row. Expected: up to 5 hours; the fork decodes
under 8 tok/s past 33K, so a wall-clock partial is a likely result and
still a row. Stop the server after it; wait for wired recovery.

## Server G, blocks 11 and 12: Qwen3.6 GGUF q8_0, thinking off

Last on purpose: the clean depth is 8K and memory compaction starts by
16K at the only `-c` that loads, so a partial is the likely result.
Both rows at `off` are missing, and the EvalPlus score at `off` is the
model's best (0.951).

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 49152 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081 --offline 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/server-qwen36-gguf-q8.log
```

pi entry `qwen3.6-35b-a3b` (`contextWindow` 49152). Run the smoke at
`off` first:

```bash
benchmarks/mendel-smoke.sh qwen3.6-35b-a3b off 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/mendel-smoke-qwen36-gguf-off.log
```

A `fail` drops blocks 11 and 12. Config note: `q8_0 KV, -c 49152,
reserveTokens 16384; compaction past 8K`.

### Block 11/13 — Qwen3.6 GGUF, thinking off, Mendel guided

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh qwen3.6-35b-a3b pi guided off
```

### Block 12/13 — Qwen3.6 GGUF, thinking off, Mendel blind

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh qwen3.6-35b-a3b pi blind off
```

Done, each: one scored row. Expected: up to 5 hours each. Stop the
server after block 12; wait for wired recovery.

## Block 13/13 — Qwen3.8 GGUF f16, effort medium, EvalPlus

Deferred from the last run. Read `docs/methodology/evalplus.md`. Server
B again. The site cell for this row carries the MLX effort-medium
score (0.982/0.939/100%); this block decides whether the GGUF quant
keeps it.

Calibration: `benchmarks/calibration-qwen38-gguf-medium.json` holds 8
of 10 problems (all `stop`, max 3407 tokens). Recalibrate in full:

```bash
benchmarks/calibrate.py qwen38-gguf-medium qwen3.8-27b \
  '{"chat_template_kwargs":{"reasoning_effort":"medium"}}'
```

Budget = max(observed max x 1.5, 8192). Record the observed max and
the budget in `results.md`. Then, with the run watcher up:

```bash
RESULTS_BASE=hardware/m1-max-32gb/benchmarks/bench11/results \
EVALPLUS_MAX_NEW_TOKENS=<budget> \
benchmarks/run-humaneval.sh qwen38-gguf-medium qwen3.8-27b \
  '{"chat_template_kwargs":{"reasoning_effort":"medium"}}'
```

Done: base, plus, empty, wall in `results.md`, against 0.982/0.939 and
0/164 empty, committed. No gate. Expected: 1 to 2 hours.

## Order

1 to 13, in this file's order. Every Mendel block is a night block: it
starts the moment the previous block ends, per the checklist's rule 1.
Nothing in this run waits for the owner.

## Not in this run

- Qwen3.8 MLX at any effort: every agent attempt went invalid on the
  26624-token window (`backlog/qwen38-mlx-window.md`).
- Gemma-26B MLX: 0.713 on EvalPlus, under the 0.800 gate.
- Gemma-12B on the LM Studio engine: loops on the thought channel in
  tool work. Gemma-12B thinking on: no EvalPlus score.
- Bonsai MLX at thinking high: both rows exist, partial; a retry
  carries the penalty rule and waits for the owner.
- Gemma-26B thinking on, blind: the row exists (47.5/100, complete).

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
or a loop stop dropped and why, machine state left behind (wired
limit, LM Studio, worktrees), evidence archived for runs 10 and 11.
The coordinator adds the findings to
`hardware/m1-max-32gb/benchmarks/INDEX.md`, writes `report.md`, and
publishes.

## Open decisions for the owner

- `reserveTokens` 8192 in the kit's pinned settings: before this run,
  or after it. The runbook assumes after.
- The Bonsai MLX thinking-high retries (penalty rule), and the
  Bonsai fork blind retry: in a later run, or dropped.
