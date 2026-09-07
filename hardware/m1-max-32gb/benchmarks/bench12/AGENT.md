# Run 12 — Gemma-12B two-slot window, Bonsai MLX thinking off, the reserve re-runs (Mac)

DRAFT, 2026-09-06. Not started. The coordinator reads run 11's
`report.md` before this file gets its go; block values marked
`<planning>` are the planning-time snapshot and the run replaces them.

You are the runner, on the Mac. Read this file, then the pages each
block names at its start, and nothing else. Write all prose in
ASD-STE100 Simplified Technical English.

## Essentials

- `hardware/m1-max-32gb/benchmarks/bench12/state.md` holds what earlier
  sessions of this run did. Resume where its handing-over section says.
- **FIRST ACTION, before anything else:**
  `git worktree add ../choose-a-local-llm-run12 -b run12` (or `cd`
  into it if it exists), then `cd ../choose-a-local-llm-run12`. Verify
  with `pwd` and `git worktree list`. Every command of this run happens
  there, never in `~/code/choose-a-local-llm`.
- Then `docs/methodology/checklist.md`, whole, once per session.
  `tools/preflight.sh` runs first and must print every line `ok`
  before a block starts. Act on `fix` and `ask` lines the way the
  checklist says; never sudo, never reboot on your own. Record the
  `memory` line's starting numbers in `state.md`.
- **Wired limit: 24000** (settled 2026-09-07 from this run's own
  pre-block prep: six creeps at 24000 with zero swap growth, against
  real swap growth at 25000 under back-to-back sweeps). Verify with
  `sysctl -n iogpu.wired_limit_mb` and preflight's `wired-limit` line
  `ok`. Any other value is stop and ask. Every config note carries
  `wired 24000`.
- **A ceiling test is a real request the size of the block's work.**
  A one-token probe passed at `-c 49920` on Qwen3.6 q8_0 and the first
  real sweep step OOMed; `-c 40960` served. Use the workload size
  (`docs/methodology/context-creep.md`, step 1).
- **Measured parameters come from the newest measurement, never from
  a number in this file** (`docs/methodology/common-rules.md`, rule
  10). Each block below has a parameter table: fixed values are
  identity and never change; derived values name their planning
  source and the run replaces them with its own newer measurement.
  Before a block serves a model, write in `state.md` the values it
  uses and the source of each (a block of this run, or a committed
  result), and put them in the row's config note.
- **Ladder before serve.** A model whose `-c` ladder was not measured
  at this run's wired limit gets one before its first block: the
  published command, `-c` from the newest ceiling upward in 8192
  steps until a real 4096-token completion fails, then the largest
  value that served is the block's `-c`. Record every candidate in
  `results.md`. When the ladder finds a larger `-c` than the newest
  creep was run at, the slow creep runs at the new `-c` too
  (`docs/methodology/context-creep.md`), and the harness window
  follows `docs/methodology/mendel.md`, "Window and budget": the
  clean depth rounded down to a 4096 multiple, never a smaller value;
  step down by 8192 only after an OOM or a server death, and write
  the step.
- `gh auth status` must pass at run start and right before every
  Mendel run. A failing status means no Mendel block starts; creep
  blocks still run.
- Before any Mendel block: `git -C ~/code/mendel-benchmark pull
  --ff-only` on `benchmark`. Read `docs/methodology/mendel.md` before
  the first Mendel block; every Mendel block follows its house rules
  (server by hand, one model on the GPU, `pkill -f "Mendel Daemon"`
  after each run, score in a subagent on the best available model,
  verify `peak_context` and `tool_calls` with
  `benchmark/count-tool-calls.mjs`, build the JSON entry, the CSV row
  and the report together before the commit, commit and push
  `benchmark`).
- **Harness values are per run, and the owner's file is never
  edited.** Pass the block's derived window to the worker:
  `MENDEL_CONTEXT_WINDOW=<window> ./run-worker.sh <model> pi <bench>
  <level>`. `MENDEL_RESERVE_TOKENS` defaults to 8192, and
  `MENDEL_KEEP_RECENT_TOKENS` derives itself (8192 under a
  65536-token window, pi's default above it). The worker pins all of
  it in its own config dir. Write the three values in `state.md` and
  in the row's config note.
- When no pi entry exists for a block's model, run `npm run pi:models`
  in the run worktree: it writes every entry from the site data. A new
  entry needs its thinking map by hand, copied from the sibling entry
  of the same provider; the tool says which. A missing entry is never
  a skip.
- **Every gate and every stop-and-ask goes to the coordinator
  session**, with the block, the condition and your candidate answer.
  Keep the GPU busy with the next block that does not depend on it
  while you wait. The coordinator takes to the owner only what needs
  the owner.
- The Mendel runner ends a run at 300 minutes on its own
  (`--wall-min`), and kills pi five minutes later when the abort does
  not settle the turn. A row that ends on `wall_clock` is a partial,
  not an invalid row, and the next block starts.
- Serve the exact files each block names. No block of this run may
  download anything. A missing file is stop and ask.
- Never run a bare `git stash`. Commit on `run12` as results land:
  `state.md`, `results.md`, the files under `results/`. Push `run12`
  at every block close and message the coordinator session with the
  block, the config, the result line and the commit id. When the
  owner asks to stop, follow the stop-and-sync steps in `AGENTS.md`.
- Any bug found in a run tool during the run goes to a subagent on
  the best available model at once; the run does not wait for it.
- One model on the GPU at a time, port 8081. Quit the LM Studio app
  before any server work and confirm with `pgrep -fl "LM Studio"`.
- Every scoring block starts `benchmarks/run-watch.sh` as the
  checklist says, memory log under `results/`. A creep runs its own
  monitor and starts no watcher. Every MLX creep sets `SERVER_LOG` to
  the server's log file, so the creep sees the thread death itself.
- Status lines follow `docs/methodology/status-lines.md`.
- **A run that ends on `repetition_loop` or `degenerate_output` is
  invalid**, with the repeated unit and the count in `results.md`;
  the next block starts. No retry in this run.
- **Gates drop configs.** A config that fails a gate is dropped from
  the rest of this run: write why in `state.md`, commit, start the
  next block. Only a line in this file that says "stop and ask"
  pauses the run.
- **No cleanup mid-run.** A Mendel run that something else ended (a
  memory kill, a server death, an operator stop) keeps its worktree,
  branch, session file and pinned config; score its commits as a
  partial and leave the rest to the coordinator. Only a run that
  ended on its own and is scored gets its worktree removed.
- **Block 7 is the retry sweep.** When blocks 1 to 6 are done and no
  message from the owner says otherwise, retry every row of this run
  that was killed or interrupted, oldest first, each in a fresh
  worktree with a suffix, under the Mendel retry rule (no penalty
  when the harness caused the loss). The GPU idles only when that
  list is empty.
- Do not change published pages or the site's `models.json`. Every
  number goes into `results.md` with the exact command that produced
  it. The coordinator publishes.
- Archive evidence before the session closes:
  `tools/archive-evidence.sh hardware/m1-max-32gb/benchmarks/bench12/results run12`.

## The order, and why

Seven blocks. The first two are Gemma-12B window measurements the
owner asked for (two agents in parallel on one server). Block 3 asks
what the Bonsai fork does with f16 KV, the one cache type it never
served, and then runs the agent task there. Blocks 4 to 6 re-run the
three valid rows that compacted under pi's old 16384 reserve, at the
8192 reserve every row uses since 2026-09-06. Gemma-26B goes last of
the three (owner, 2026-09-07): it scores worst of them on the agent
task, so it is the one to drop if the run runs short. Block 7 is the retry
sweep. Every block starts the moment the previous one ends.

Every MLX item moved to `../unscheduled/`: those rows wait on the
in-turn margin rule, because that server cannot refuse a request it
cannot serve.

## Tool check — before Block 1

The depth-sweep tool moved out of this repo, to `local-llm-eval-tools`.
The two tools were already compared on this machine, twice, on the
pre-block prep's own arms, and they agree row for row (`results.md`,
"Pre-block prep"). So this check does not measure agreement again. It
proves only that a clean pull of the tool runs on this machine and
that the run records which version it used.

1. `git -C ~/code/local-llm-eval-tools pull --ff-only` (clone first if
   missing: `git clone git@github.com:irae/local-llm-eval-tools.git
   ~/code/local-llm-eval-tools`). Record `git -C
   ~/code/local-llm-eval-tools rev-parse --short HEAD` in `state.md`.
   That hash is pinned for the whole run: do not pull again in the
   middle of the run.
2. `python3 ~/code/local-llm-eval-tools/slow-context-creep/creep.py
   llama --help`. It must exit 0 and print the variables it reads.
3. On the first server this run starts anyway, run the shortest creep
   the block already needs, and read its first two rows. **Pass**: the
   rows carry `decode_toks`, `wired_mb` and `swap_delta_mb`, and the
   run does not stop on its own inside those two rows. **Fail**: the
   tool errors, prints no rows, or stops on a condition the block did
   not expect. On a fail, stop and ask the coordinator; no scoring
   block starts until the coordinator clears it.
4. Write the commit hash and the pass line in `state.md`.

Do not compare decode speed against an older file to pass or fail this
check. Decode on this machine swings run to run on identical code, 40
to 54 tok/s on one run against 21 to 27 on the next (`results.md`,
"Pre-block prep"). A speed comparison would fail on machine noise.

## Block 1/7 — Gemma-12B GGUF, two slots: `-c` ladder and round-robin creep

Read `docs/methodology/context-creep.md` and
`docs/methodology/memory-ceiling.md`.

| parameter | kind | value | source |
| --- | --- | --- | --- |
| files | fixed | `unsloth/gemma-4-12b-it-GGUF:Q4_K_XL`, `--no-mmproj` | published command |
| KV type | fixed | f16 | KV pick, run 9 |
| drafter | fixed | none (`gemma12-gguf-f16` row) | site row |
| slots | fixed | `--parallel 2` | owner, 2026-09-06 |
| `-c` | derived | `<planning>` 262144 (two slots of 131072); run 10 found four slots at 655360 | this block's ladder |
| clean depth per slot | derived | `<planning>` none at two slots; one slot clean 49K at 655360 four-slot (run 10) | this block's creep |

Ladder: start at `-c 262144`, step by 16384 (8192 per slot) upward
until a real 4096-token completion on each of the two slots fails;
then downward from 262144 in the same steps until both slots serve,
when 262144 itself fails. The largest `-c` where both slots serve a
real completion is the value. Record every candidate in
`results.md` with the load result and the two completions.

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b-2x --no-mmproj --parallel 2 \
  -ngl 999 -fa on -c <ladder value> \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench12/results/server-gemma12-gguf-2x-c<value>.log
```

Then the round-robin creep at that `-c`, two contexts, so each slot
holds its own cache:

```bash
DEPTH_LIST="4096,8192,16384,24576,32768,40960,49152,65536,81920,98304,114688,131072" \
N_CONTEXTS=2 MODEL=gemma-4-12b-2x \
  python3 ~/code/local-llm-eval-tools/slow-context-creep/creep.py llama \
  | tee hardware/m1-max-32gb/benchmarks/bench12/results/creep-gemma12-gguf-2x-f16.tsv
```

Done: the ladder table and the creep table with its verdict in
`results.md`, committed. Gate: none; the numbers are the finding.
Write the per-slot clean depth in `state.md` as `gemma12_2x_clean`.
Stop the server; wait for wired recovery.

## Block 2/7 — Gemma-12B GGUF, one slot at `-c 131072`: creep

Same files, KV type and drafter as block 1. Fixed for this block:
`--parallel 1`, `-c 131072` (the owner's comparison point, the same
per-slot window as the two-slot target). Derived: the clean depth,
from this creep.

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 131072 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench12/results/server-gemma12-gguf-1x-c131072.log
```

```bash
DEPTH_LIST="4096,8192,16384,24576,32768,40960,49152,65536,81920,98304,114688,131072" \
N_CONTEXTS=1 MODEL=gemma-4-12b \
  python3 ~/code/local-llm-eval-tools/slow-context-creep/creep.py llama \
  | tee hardware/m1-max-32gb/benchmarks/bench12/results/creep-gemma12-gguf-1x-c131072-f16.tsv
```

Done: the creep table beside block 1's in `results.md`, one
comparison table (depth, tok/s one slot, tok/s per slot at two
slots). Stop the server; wait for wired recovery.

## Block 3/7 — Bonsai on the PrismML fork, f16 KV: ladder, creep, then the agent task

Read `docs/methodology/context-creep.md`. The fork has never served
this model with f16 KV, and the site's own KV study says that is where
its 8 tok/s floor near 30K comes from: quantized KV costs this machine
2 to 4 microseconds per cached token against 0.2 to 0.3 for f16
(`hardware/m1-max-32gb/research/kv-quant-on-m1.md`). This block answers one
question: **at f16 KV, one slot, what is the deepest context that still
decodes at 8 tok/s or more?**

| parameter | kind | value | source |
| --- | --- | --- | --- |
| files | fixed | `Ternary-Bonsai-27B-Q2_g64.gguf`, the fork's local file | site row `bonsai-fork-single` |
| serving | fixed | `~/prism-llama/llama-server`, `LLAMA_ATTN_ROT_DISABLE=1`, no drafter, `--parallel 1` | site row |
| KV type | fixed | f16 (no `--kv-mean-center`; the bias file corrects q4 error only) | this block |
| `-c` | derived | `<planning>` start at 131072; the arithmetic says 98K fits in about 14.9 GB | this block's ladder |
| clean depth | derived | `<planning>` q4 gives about 30K; the projection says past 98K | this block's creep |

Ladder first, from `-c 131072` down in 16384 steps until the server
loads and serves one real 4096-token completion. Record every
candidate with its load result and its wired memory.

```bash
LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server \
  -m ~/.cache/huggingface/hub/models--prism-ml--Ternary-Bonsai-27B-gguf/snapshots/<rev>/Ternary-Bonsai-27B-Q2_g64.gguf \
  --alias bonsai-prism --parallel 1 \
  -ngl 999 -fa on -c <candidate> \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench12/results/server-bonsai-fork-f16-c<candidate>.log
```

Then the slow creep at the largest `-c` that served:

```bash
DEPTH_LIST="4096,8192,16384,24576,32768,40960,49152,65536,81920,98304,114688,131072" \
N_CONTEXTS=1 MODEL=bonsai-prism \
  python3 ~/code/local-llm-eval-tools/slow-context-creep/creep.py llama \
  | tee hardware/m1-max-32gb/benchmarks/bench12/results/creep-bonsai-fork-f16.tsv
```

Then, on the window this creep supports, one agent run: the Mendel
guided test at thinking high, the same test the q4_0 arm scored 31.5
on when the wall clock stopped it.

```bash
MENDEL_CONTEXT_WINDOW=<clean depth, rounded down to 4096> \
  ./run-worker.sh bonsai-prism pi guided high
```

Done: the ladder table, the creep table with its verdict, and the
agent row, all in `results.md`, committed, and one line in `state.md`
that names the deepest step at or above 8 tok/s. No two-slot arm, no
drafter, no EvalPlus: the quality gate at f16 is
`../unscheduled/bonsai-fork-f16-evalplus.md`. Stop the server; wait
for wired recovery.

## Blocks 4 to 6 — the reserve re-runs

Three valid rows compacted under pi's default 16384 reserve before
2026-09-06. Each runs again at reserve 8192, same test and level,
under the Mendel retry rule for a harness-caused re-run: no penalty,
the better row stands, the config note says "re-run at reserveTokens
8192; first row ran at 16384". Ladder-before-serve applies to each
model at this run's wired limit before its block.

### Block 4/7 — Qwen3.8 GGUF, blind, effort medium

| parameter | kind | value | source |
| --- | --- | --- | --- |
| files | fixed | `bartowski/Qwen3.8-27B-GGUF:Q4_K_M`, `--no-mmproj` | published command |
| KV type, drafter | fixed | f16, MTP n-max 3 | site row `qwen38-gguf-medium` |
| thinking | fixed | pi level `medium` | the first row |
| `-c` | derived | `<planning>` 49152, the load ceiling at 24000 (run 9) | ladder at this run's limit |
| window | derived | `<planning>` 49152 | clean depth at the ladder's `-c` |

Serve with the site row's command at the derived `-c`, then:

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<block 4 window> ./run-worker.sh qwen3.8-27b pi blind medium
```

### Block 5/7 — Qwen3.6 GGUF, guided, thinking high

| parameter | kind | value | source |
| --- | --- | --- | --- |
| files | fixed | `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`, `--no-mmproj` | published command |
| KV type, drafter | fixed | q8_0, MTP n-max 3 | KV pick (f16 loads only at 40960) |
| thinking | fixed | pi level for `high` | the first row |
| `-c` | derived | `<planning>` 98304 at 25000 (run 11 block 1) | ladder at this run's limit |
| window | derived | `<planning>` 81920 (run 11, clean depth 81958) | clean depth at the ladder's `-c` |

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<block 6 window> ./run-worker.sh qwen3.6-35b-a3b pi guided high
```

### Block 6/7 — Gemma-26B GGUF, blind, thinking high

| parameter | kind | value | source |
| --- | --- | --- | --- |
| files | fixed | `unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL`, `--no-mmproj` | published command |
| KV type, drafter | fixed | f16, MTP n-max 2 | site row |
| thinking | fixed | pi level for `high` | the first row |
| `-c` | derived | `<planning>` 212992 (run 9 ceiling; run 11 served it at 25000) | ladder at this run's limit |
| window | derived | `<planning>` 212992 | clean depth at the ladder's `-c` |

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<block 5 window> ./run-worker.sh gemma-4-26b-a4b pi blind high
```

## Order

1 to 7 in this file's order. Every block starts the moment the
previous one ends. Nothing in this run waits for the owner.

## Not in this run

- Qwen3.8 effort levels and quants, strip modules, the compaction
  experiment and the container trials: research run 3
  (`hardware/m1-max-32gb/research/run3/index.md`).
- Every MLX row, the Bonsai EvalPlus gate at f16, the small agent
  models and the specialized models: `../unscheduled/`.
- `keepRecentTokens` under small windows: the owner has not decided
  (`backlog/pi-compaction-efficiency.md`); every row keeps pi's
  default and says so.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
or a loop stop dropped and why, machine state left behind, evidence
archived. The coordinator adds the findings to
`hardware/m1-max-32gb/benchmarks/INDEX.md`, writes `report.md`,
writes the final derived values into the owner's `models.json` and
the site, and publishes.
