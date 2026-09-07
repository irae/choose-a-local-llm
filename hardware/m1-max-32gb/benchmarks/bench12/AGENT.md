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
- **Wired limit: `<owner sets it before the run: 24000 or 25000>`**
  (owner decision, dated in `state.md` at run start). Verify with
  `sysctl -n iogpu.wired_limit_mb` and preflight's `wired-limit` line
  `ok`. Any other value is stop and ask. Every config note carries
  `wired <value>`.
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
- Harness values live in the run's pinned pi config. The worker
  copies `~/.pi/agent/models.json`; when a block's derived window
  differs from the entry, the runner sets `contextWindow` on that one
  entry to the derived value (the owner authorizes this edit, run 11
  precedent), writes old and new in `state.md`, and leaves it. The
  pinned `settings.json` sets `reserveTokens` 8192; confirm it before
  the first Mendel run.
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
- Do not change published pages or the site's `models.json`. Every
  number goes into `results.md` with the exact command that produced
  it. The coordinator publishes.
- Archive evidence before the session closes:
  `tools/archive-evidence.sh hardware/m1-max-32gb/benchmarks/bench12/results run12`.

## The order, and why

Seven blocks. The first two are Gemma-12B window measurements the
owner asked for (two agents in parallel on one server). Block 3 is
the Bonsai MLX thinking-off pair, moved out of run 11. Blocks 4 to 6
re-run the three valid rows that compacted under pi's old 16384
reserve, at the 8192 reserve every row uses since 2026-09-06. Every
block starts the moment the previous one ends.

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
N_CONTEXTS=2 MODEL=gemma-4-12b-2x python3 tools/sweeps/creep_llama.py \
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
N_CONTEXTS=1 MODEL=gemma-4-12b python3 tools/sweeps/creep_llama.py \
  | tee hardware/m1-max-32gb/benchmarks/bench12/results/creep-gemma12-gguf-1x-c131072-f16.tsv
```

Done: the creep table beside block 1's in `results.md`, one
comparison table (depth, tok/s one slot, tok/s per slot at two
slots). Stop the server; wait for wired recovery.

## Block 3/7 — Bonsai MLX, thinking off: smoke, Mendel guided, Mendel blind

Third attempt of the guided row (two invalid on the harness: a dead
`gh` token, then an 85-call loop before the loop stop existed) and
the first blind attempt at this level.

| parameter | kind | value | source |
| --- | --- | --- | --- |
| files | fixed | `prism-ml/Ternary-Bonsai-27B-mlx-2bit` | published command |
| serving | fixed | `mlx_lm.server --prompt-cache-size 2` | site row `bonsai-mlx-off` |
| thinking | fixed | off (pi level `off`) | this block |
| harness window | derived | `<planning>` the entry's value today; the MLX ceiling is 49K (memory) at 24000 | newest Bonsai MLX creep at this run's limit; ladder-before-serve applies to MLX as a creep, not a `-c` ladder |
| `maxTokens`, `reserveTokens` | derived | 8192 both | output budget rule, `docs/methodology/mendel.md` |

```bash
mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit \
  --prompt-cache-size 2 --port 8081 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench12/results/server-bonsai-mlx-off.log
```

Smoke first, then the two runs:

```bash
benchmarks/mendel-smoke.sh prism-ml/Ternary-Bonsai-27B-mlx-2bit off 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench12/results/mendel-smoke-bonsai-mlx-off.log
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh prism-ml/Ternary-Bonsai-27B-mlx-2bit pi guided off
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh prism-ml/Ternary-Bonsai-27B-mlx-2bit pi blind off
```

A `fail` on the smoke drops both rows. Config note: `mlx_lm.server,
--prompt-cache-size 2, thinking off, window <value> (<source>),
reserveTokens 8192, wired <value>`. Stop the server; wait for wired
recovery.

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
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh qwen3.8-27b pi blind medium
```

### Block 5/7 — Gemma-26B GGUF, blind, thinking high

| parameter | kind | value | source |
| --- | --- | --- | --- |
| files | fixed | `unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL`, `--no-mmproj` | published command |
| KV type, drafter | fixed | f16, MTP n-max 2 | site row |
| thinking | fixed | pi level for `high` | the first row |
| `-c` | derived | `<planning>` 212992 (run 9 ceiling; run 11 served it at 25000) | ladder at this run's limit |
| window | derived | `<planning>` 212992 | clean depth at the ladder's `-c` |

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh gemma-4-26b-a4b pi blind high
```

### Block 6/7 — Qwen3.6 GGUF, guided, thinking high

| parameter | kind | value | source |
| --- | --- | --- | --- |
| files | fixed | `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`, `--no-mmproj` | published command |
| KV type, drafter | fixed | q8_0, MTP n-max 3 | KV pick (f16 loads only at 40960) |
| thinking | fixed | pi level for `high` | the first row |
| `-c` | derived | `<planning>` 98304 at 25000 (run 11 block 1) | ladder at this run's limit |
| window | derived | `<planning>` 81920 (run 11, clean depth 81958) | clean depth at the ladder's `-c` |

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh qwen3.6-35b-a3b pi guided high
```

## Block 7/7 — windows up at the run's limit (conditional)

Runs only when the wired limit is 25000 and the owner wrote in
`state.md` at run start that 25000 held through run 11. For each
model with a Mendel row whose ladder in this run found a larger `-c`
than its site row: the slow creep at the new `-c` (the ladder already
ran before the model's block). Otherwise this block is empty; write
that in `state.md`.

## Order

1 to 7 in this file's order. Every block starts the moment the
previous one ends. Nothing in this run waits for the owner.

## Not in this run

- Qwen3.8 effort levels and quants: `hardware/m1-max-32gb/research/qwen38-configs.md`.
- The research items with a Mac procedure (`strip-modules.md`,
  `specialized-models.md`, `small-agent-models.md`): a research run.
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
