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
  Block 1 needs a clean machine: if preflight says `fix reboot`, that
  reboot happens before block 1, not after it.
- **This run runs at `iogpu.wired_limit_mb=25000`** (owner decision,
  2026-09-06). The owner sets the sysctl and the machine file's
  `iogpu.wired_limit_mb` row before the run. Verify with
  `sysctl -n iogpu.wired_limit_mb`: 25000, and preflight's
  `wired-limit` line `ok`. Any other value is stop and ask; the runner
  never runs sudo. Every row's config note in this run carries
  `wired 25000`. Only Qwen3.6 gets new depth numbers at this limit
  (block 1); every other model runs its known combination unchanged,
  and its published depth numbers stay as measured at 24000.
- `gh auth status` must pass at run start and again right before every
  Mendel run, blind or guided. A failing status means no Mendel block
  starts; block 1 still runs. The last run lost a night to a dead
  token.
- Before any Mendel block: `git -C ~/code/mendel-benchmark pull
  --ff-only` on `benchmark`. The live loop stop must be in
  (`run-pi-rpc.mjs` ends a run with reason `repetition_loop` or
  `degenerate_output`; see `PLAN.md`). If it is not in, stop and ask;
  do not start a Mendel run without it.
- Read `docs/methodology/mendel.md` before block 2. Every Mendel block
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
- The pinned pi config the worker builds sets `reserveTokens` 8192
  since 2026-09-06 (the output budget rule's value; rows before that
  date ran at pi's default 16384). Confirm it in the pinned
  `settings.json` the worker writes before the first Mendel run, and
  write `reserveTokens 8192` in every row's config note.
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
  runs beside it; the old watchers are gone. A depth creep runs its
  own monitor and starts no watcher.
- Status lines follow `docs/methodology/status-lines.md`: one short
  line in chat at every 20-minute wakeup, the medium form in `state.md`
  at block close, the large form drafted in `results.md`. A Mendel
  short line carries tasks done, prompt depth, nudges and the last
  commit time.
- **A run that ends on `repetition_loop` or `degenerate_output` is
  invalid**, with the repeated unit and the count in `results.md`, and
  the next block starts. No retry in this run.
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

Twelve blocks. The first is a depth creep that decides where the
Qwen3.6 GGUF Mendel pair goes. The other eleven are Mendel rows the
site does not have, sorted by EvalPlus base score, then decode speed
at depth, then context. A row that exists is not run again. Qwen3.8
has no block in this run: its reasoning-effort question is a research
item (`hardware/m1-max-32gb/research/qwen38-configs.md`).

## Block 1/12 — Qwen3.6 at wired 25000 on clean memory: both backends, both KV types

Read `docs/methodology/context-creep.md` and
`docs/methodology/memory-ceiling.md`. The site rows say 8K clean depth
at `-c 49152`, q8_0 KV, 25 GB wired, compaction from 16K on the GGUF,
and 37K on MLX. The GGUF reading came from 2026-09-04 at limit 24000,
on a machine whose memory state is not recorded, and it conflicts with
two facts: the Mendel rows of 2026-08-30 to 2026-09-02 ran this config
at `-c 98304` under the same limit and peaked at 94K used tokens
without a crash, and the fast sweep of 2026-08-28 at limit 25000 held
8.1 tok/s at 90K. This block repeats every Qwen3.6 measurement at the
run's limit of 25000, on a machine that preflight calls clean, right
after the reboot, before any other model has loaded: three creeps, in
this order, with a wired-recovery wait between them.

Serve with the published command and this `-c` ladder, one at a time:
98304, 65536, 49152. Each candidate that logs `model loaded` gets one
real 4096-token completion (the trivial warmup is not enough; run 10
A1). Record every line for every candidate in `results.md`: loaded or
`Insufficient Memory`, wired at load, the completion result.

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c <candidate> \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081 --offline 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/server-qwen36-gguf-q8-c<candidate>.log
```

Then the full slow creep at the largest `-c` that served the
completion:

```bash
DEPTH_LIST="4096,8192,16384,24576,32768,40960,49152,57344,65536,81920,98304" \
MODEL=qwen3.6-35b-a3b python3 tools/sweeps/creep_llama.py \
  | tee hardware/m1-max-32gb/benchmarks/bench11/results/creep-qwen36-gguf-q8-clean.tsv
```

Then one f16 arm at `-c 40960` (it did not load on 2026-09-04): the
same command with `--cache-type-k f16 --cache-type-v f16`, one real
completion, log to `results/server-qwen36-gguf-f16-c40960.log`. When it
serves, run the same creep on it to `creep-qwen36-gguf-f16-clean.tsv`;
when it does not, record the log line and move on.

Then the MLX arm, the published `qwen36-mlx-think` command, whose
ceiling was 37K at limit 24000:

```bash
mlx_lm.server --model mlx-community/Qwen3.6-35B-A3B-4bit \
  --prompt-cache-size 2 --port 8081 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/server-qwen36-mlx-creep.log
```

```bash
DEPTH_LIST="4096,8192,16384,24576,32768,36864,40960,45056,49152,57344,65536" \
MODEL=mlx-community/Qwen3.6-35B-A3B-4bit python3 tools/sweeps/creep_mlx.py \
  | tee hardware/m1-max-32gb/benchmarks/bench11/results/creep-qwen36-mlx-25000.tsv
```

An MLX server dies on a Metal OOM without refusing the request; the
creep's own probe reads that as the stop. Quit the server after.

Done means: the `-c` ladder table, the three creep tables with their
verdicts (or the load failure line where an arm did not load), the
starting memory numbers from preflight beside them, all in
`results.md`, committed. Then the gates:

- **GGUF, clean depth of 46K or more at 8 tok/s or more on either KV
  arm**: blocks 11 and 12 (Qwen3.6 GGUF Mendel, thinking off) run
  right after block 3, on the arm and `-c` this block found, and the
  config note names them. Otherwise they stay last, at the `-c` this
  block found, and the partial they produce is the finding.
- **MLX**: blocks 6 and 7 run at the last stable depth this arm
  found, whatever it is; their pi window must not exceed it. Write
  both decisions in `state.md`.

Expected cost: 30 minutes for the ladder, 1 to 1.5 hours per creep,
about 5 hours in all. Wait for wired recovery (checklist step 13)
between arms and after the last one.

## Server A, blocks 2, 3 and 5: Gemma-26B GGUF f16

The published `gemma-4-26b-a4b` command, f16 KV, `-c 212992`. Start it
once, keep it up through blocks 2 and 3; block 5 follows block 4 on
another server, so restart it then.

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
Config note on every row: `f16 KV, -c 212992, reserveTokens 8192, wired 25000`.

### Block 2/12 — Gemma-26B, thinking off, Mendel guided

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh gemma-4-26b-a4b pi guided off
```

Done: one scored guided row at `off` in `results-guided.csv`, the
result line and the telemetry in `results.md`, committed. Expected: up
to 5 hours, a night block.

### Block 3/12 — Gemma-26B, thinking off, Mendel blind

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh gemma-4-26b-a4b pi blind off
```

Done: one scored blind row at `off` in `results.csv`. Expected: up to
5 hours. When block 1 promoted the Qwen3.6 GGUF pair, stop this server
after this block and run blocks 11 and 12 now, then continue with
block 4.

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

### Block 4/12 — Gemma-12B GGUF, thinking off, Mendel blind

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh gemma-4-12b pi blind off
```

Done: one scored blind row at `off`. Expected: up to 5 hours. Stop
server C after it; wait for wired recovery.

### Block 5/12 — Gemma-26B, thinking on, Mendel guided

Server A again. The blind row at `high` exists (47.5/100); guided at
any level does not.

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh gemma-4-26b-a4b pi guided <on-level>
```

Done: one scored guided row at the on level. Expected: up to 5 hours.
Stop server A after it; wait for wired recovery.

## Server D, blocks 6 and 7: Qwen3.6 MLX

This model has no agent row at all on MLX. Its window is the last
stable depth block 1's MLX arm found (37K at limit 24000 before); the
task has needed about 46K on other models, so a partial on the window
is a possible result and still a row.

```bash
mlx_lm.server --model mlx-community/Qwen3.6-35B-A3B-4bit \
  --prompt-cache-size 2 --port 8081 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/server-qwen36-mlx.log
```

pi entry: the one whose model is `mlx-community/Qwen3.6-35B-A3B-4bit`
(record its id, `contextWindow` and `maxTokens`; the window must not
exceed the last stable depth of block 1's MLX arm; when it does, the
entry stays as it is, the runner never edits it, and the run is stop
and ask). No entry is stop and ask. Thinking
on is the level the map names for on. Run the smoke first, because
this serving config never ran the agent task:

```bash
benchmarks/mendel-smoke.sh <pi-id> <on-level> 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/mendel-smoke-qwen36-mlx-on.log
```

A `fail` drops blocks 6 and 7. Config note: `mlx_lm.server,
--prompt-cache-size 2, thinking on, reserveTokens 8192, wired 25000`.

### Block 6/12 — Qwen3.6 MLX, thinking on, Mendel blind

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh <pi-id> pi blind <on-level>
```

### Block 7/12 — Qwen3.6 MLX, thinking on, Mendel guided

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
reserveTokens 8192, wired 25000`.

### Block 8/12 — Bonsai MLX, thinking off, Mendel guided

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh prism-ml/Ternary-Bonsai-27B-mlx-2bit pi guided off
```

### Block 9/12 — Bonsai MLX, thinking off, Mendel blind

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh prism-ml/Ternary-Bonsai-27B-mlx-2bit pi blind off
```

Done, each: one scored row, valid or invalid with its reason.
Expected: up to 5 hours each. Stop the server after block 9; wait for
wired recovery.

## Server F, block 10: Bonsai on the PrismML fork, q4 KV

The blind row exists (12.5/100, partial). Guided is missing. The KV
bias file is generated, not downloaded. Not the main task of this
block, but look for it first: it must exist at
`~/.local/share/choose-a-local-llm/Ternary-Bonsai-27B-kv-bias.gguf`
(or `/tmp/Ternary-Bonsai-27B-kv-bias.gguf`). Record in `state.md`
whether it exists and its size and date; the owner has an open
question on the corpus behind it (`backlog/bonsai-kv-bias-corpus.md`).
When neither exists, regenerate it with the vendor's `make_kv_bias.sh`
per `docs/setups/m1-max-32gb/benchmarks/bonsai-27b.md`, and record
that the row runs on a regenerated file. The model file is the
committed snapshot under
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
65536, reserveTokens 8192, wired 25000`.

### Block 10/12 — Bonsai fork, thinking high, Mendel guided

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh bonsai-prism pi guided <on-level>
```

Done: one scored guided row. Expected: up to 5 hours; the fork decodes
under 8 tok/s past 33K, so a wall-clock partial is a likely result and
still a row. Stop the server after it; wait for wired recovery.

## Server G, blocks 11 and 12: Qwen3.6 GGUF, thinking off

Block 1 decided where these two run and at which `-c` and KV type.
Both rows at `off` are missing, and the EvalPlus score at `off` is the
model's best (0.951). Serve with the published command at the `-c`
and cache type block 1 found:

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c <from block 1> \
  --cache-type-k <from block 1> --cache-type-v <from block 1> \
  --jinja --port 8081 --offline 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/server-qwen36-gguf-mendel.log
```

pi entry `qwen3.6-35b-a3b`. Its `contextWindow` is 49152 today. When
block 1 found a larger `-c`, the entry stays as it is (the runner never
edits it) and the row's config note says both numbers; the window
under 46K is then a known condition, not a deviation. Run the smoke at
`off` first:

```bash
benchmarks/mendel-smoke.sh qwen3.6-35b-a3b off 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench11/results/mendel-smoke-qwen36-gguf-off.log
```

A `fail` drops blocks 11 and 12. Config note: `<KV> KV, -c <value>,
clean depth <value> (block 1), reserveTokens 8192, wired 25000`.

### Block 11/12 — Qwen3.6 GGUF, thinking off, Mendel guided

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh qwen3.6-35b-a3b pi guided off
```

### Block 12/12 — Qwen3.6 GGUF, thinking off, Mendel blind

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh qwen3.6-35b-a3b pi blind off
```

Done, each: one scored row. Expected: up to 5 hours each. Stop the
server after block 12; wait for wired recovery.

## Order

1 to 12 in this file's order, with one conditional move: when block 1
passes its gate, blocks 11 and 12 run right after block 3. Every
Mendel block is a night block: it starts the moment the previous block
ends, per the checklist's rule 1. Nothing in this run waits for the
owner.

## Not in this run

- Qwen3.8, every build and every effort level: the reasoning-effort
  question (medium reported worst for agent work; low and xhigh to
  try), the deferred GGUF EvalPlus at medium and the guided run wait
  for `hardware/m1-max-32gb/research/qwen38-configs.md`. The MLX
  window question is `backlog/qwen38-mlx-window.md`.
- Gemma-26B MLX: 0.713 on EvalPlus, under the 0.800 gate.
- Gemma-12B on the LM Studio engine: loops on the thought channel in
  tool work. Gemma-12B thinking on: no EvalPlus score.
- Bonsai MLX at thinking high: both rows exist, partial; a retry
  carries the penalty rule and waits for the owner.
- Gemma-26B thinking on, blind: the row exists (47.5/100, complete).
- The wired-limit ladder (`hardware/m1-max-32gb/research/wired-limit-retest.md`):
  a research run, 10 to 12 hours, needs the owner present for sudo.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
or a loop stop dropped and why, machine state left behind (wired
limit, LM Studio, worktrees), evidence archived for runs 10 and 11.
The coordinator adds the findings to
`hardware/m1-max-32gb/benchmarks/INDEX.md`, writes `report.md`, and
publishes.

## Open decisions for the owner

- The Bonsai MLX thinking-high retries (penalty rule), and the
  Bonsai fork blind retry: in a later run, or dropped.
- The corpus behind the Bonsai KV bias file
  (`backlog/bonsai-kv-bias-corpus.md`).
