# Run 16 — real-text speeds for the drafter rows, then the two MLX agent rows (Mac)

Ready to start, 2026-09-12. About twenty-two hours of machine time.

You are the runner, on the Mac. Read this file, then the pages each
block names at its start, and nothing else. Write all prose in
ASD-STE100 Simplified Technical English.

## What this run is for

The homepage table carries a dagger on six drafter rows: their tok/s
came from a creep whose text lets the drafter accept every draft, so
the numbers are an upper bound. Run 14 read three such curves with
`llama-benchy` on real text and the site took those cells; this run
reads the six that remain, one benchy block per row, and the daggers
come off. Then the two Coding cells the table still shows as pending:
Qwen3.6 on MLX at thinking on and Gemma-26B on MLX. Both get a smoke
first, because no smoke of either MLX build is on record, and then
one blind row each.

## The order

**This list is the order.**

- `benchy-qwen38-atomicchat-drafter`
- `benchy-gemma26-drafter`
- `benchy-gemma26-2slot-drafter`
- `benchy-gemma12-q8-drafter`
- `benchy-gemma12-4slot-drafter`
- `benchy-qwen36-f16-drafter`
- `drafter-arms-qwen38-atomicchat`
- `drafter-arms-gemma26`
- `drafter-arms-gemma26-2slot`
- `drafter-arms-gemma12-q8`
- `drafter-arms-gemma12-4slot`
- `drafter-arms-qwen36-f16`
- `qwen36-mlx-smoke-on`
- `qwen36-mlx-mendel-blind-on`
- `gemma26-mlx-smoke-high`
- `gemma26-mlx-mendel-blind-high`
- `retry-sweep`

The MLX blocks do not depend on the benchy blocks. If a benchy block
waits on anything, take the MLX smokes and rows and come back.

## Essentials

- `bench16/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION:** `git worktree add ../choose-a-local-llm-run16 -b
  run16` (or `cd` into it if it exists), then `cd
  ../choose-a-local-llm-run16`. Verify with `pwd` and `git worktree
  list`. Every command of this run happens there.
- **Branches, exactly.** You work on `run16` and only on `run16`. The
  coordinator works on `master`. To take an update: `git fetch origin
  && git merge origin/master`, then push `run16`. Never check out
  `master`, never merge `run16` into `master`, never push `master`.
- Then `docs/methodology/checklist.md`, whole, once per session.
  `tools/preflight.sh` first, every line `ok` before a block starts.
  Never sudo, never reboot on your own.
- **Wired limit: 25000.** Verify with `sysctl -n iogpu.wired_limit_mb`.
  Any other value is stop and ask. Every note carries `wired 25000`.
- One model on the GPU at a time, port 8081. Before you start a
  server, `pgrep -fl "llama-server|mlx_lm"` must be empty. Never kill
  a server you did not start. Quit the LM Studio app first and confirm
  with `pgrep -fl "LM Studio"`; its model cache is the owner's and is
  never touched.
- **No download in this run** except the two tokenizers named in "The
  benchy command". Every model file below is in the cache; a missing
  file is stop and ask.
- **No temperature and no sampling parameter is passed to any
  server.** The server's own default is the serving sampling. Read the
  values a simulator(mendel) run used from its `meta.json` and put
  them in the row's config note.
- **Effort medium is banned for Qwen3.8** (owner rule, 2026-09-09).
  The AtomicChat benchy block reads speed only and names no level.
- **Harness values are per run.** The worker builds its own pinned
  config. The pi entry for Gemma-26B MLX is new in the site data:
  after your first `git merge origin/master`, run `npm run pi:models`
  in the run worktree; it writes the entry and says which thinking
  map to copy by hand from the sibling entry of the same provider.
  Never edit `~/.pi/agent/models.json` in any other way.
- `gh auth status` must pass before any smoke.
- Every scoring run starts `benchmarks/run-watch.sh` as the checklist
  says.
- **Scoring and publishing are one task.** One subagent on the best
  available model, per row, on a scratch path of its own that no
  other subagent shares, does all of it: scores per `PLAN.md`, writes
  the `results.json` entry with its matrix cells, regenerates
  `results.csv` and `report.html`, commits to `~/code/mendel-benchmark`
  on branch `benchmark` and pushes. A bug in a run tool goes to a
  subagent on the best model at once; the run does not wait for it.
- Commit on `run16` as results land. Push at every block close and
  message the coordinator session "local-llm
  manager/coordinator/orchestrator" with the block, the config, the
  result line and the commit id. **No message between pushes**: no
  live progress, no status counts (owner rule, 2026-09-11). Never
  run a bare `git stash`.
- Every gate and every stop-and-ask goes to the coordinator session
  with the block, the condition and your candidate answer. Keep the
  GPU busy with the next block that does not depend on it.
- Status lines follow `docs/methodology/status-lines.md`. Archive
  evidence before a session closes:
  `tools/archive-evidence.sh hardware/m1-max-32gb/benchmarks/bench16/results run16`.
- Nothing of an interrupted run is cleaned up mid-run
  (`docs/methodology/mendel.md`, "No cleanup mid-run").

## The benchy command

Read `hardware/m1-max-32gb/research/run4/state.md` first: it holds
`benchy_version`, `benchy_tokenizer`, `benchy_corpus` and
`benchy_invocation`, the exact command line that passed there. Use
that line, with this run's alias, depths and file names. The shape:

```bash
llama-benchy --base-url http://127.0.0.1:8081/v1 --model <alias> \
  --tokenizer <tokenizer for this model's base> \
  --book-url http://127.0.0.1:8089/corpus-mendel-js.txt \
  --pp 512 --tg 256 --depth <block's depths, space separated> \
  --runs 2 \
  --post-run-cmd 'sleep 60; vm_stat | head -12 >> hardware/m1-max-32gb/benchmarks/bench16/results/benchy-<mnemonic>-vm.log; sysctl vm.swapusage >> hardware/m1-max-32gb/benchmarks/bench16/results/benchy-<mnemonic>-vm.log' \
  --format md --save-result hardware/m1-max-32gb/benchmarks/bench16/results/benchy-<mnemonic>.md
```

Tokenizers, each the base model repo the quant's card names:
Qwen3.8 builds use `Qwen/Qwen3.8-27B` (cached, research run 4);
Qwen3.6 uses `Qwen/Qwen3.6-35B-A3B` (cached, run 15); Gemma-26B uses
`google/gemma-4-26b-a4b-it` (cached, run 15); Gemma-12B uses
`google/gemma-4-12b-it`, a tokenizer download of a few MB, approved
for this run. Record the tokenizer beside every table.

The corpus is the code text research run 4 built:
`hardware/m1-max-32gb/research/run4/results/corpus-mendel-js.txt`
(sha256 in `benchy_corpus`). Benchy fetches `--book-url` over HTTP,
so serve that directory first with
`python3 -m http.server 8089 --bind 127.0.0.1` and stop it after the
last benchy block. Every benchy server command below carries
`--cache-ram 0` for the measurement only; the published serving
command does not. Depths are space separated. A benchy request adds
768 tokens over its depth, so the deepest depth of every block sits
at least 1024 under the serving `-c` (or under the slot size on a
multi-slot server).

No `--extra-body`. Keep the server log; for every cell, read the
`draft acceptance` line of the matching request and put it beside the
cell. On a multi-slot server benchy drives one slot; the other slots
stay loaded and idle, as the creep did. A benchy block costs about
three times a creep: benchy re-prefills the full depth on every
request.

Done, per benchy block: one table in `results.md` with depth, benchy
tok/s and its standard deviation, the site's current tok/s at the
nearest depth, the difference in percent, acceptance, and swap beside
every cell. **A table and no pick.** The coordinator decides the
serving row and takes the dagger off.

## `benchy-qwen38-atomicchat-drafter`

The served row of the AtomicChat 3-bit build. Fixed:
`AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S`, rev `ca10ebc`, `--no-mmproj`,
f16 KV, drafter `--spec-type draft-mtp --spec-draft-n-max 3`,
`--parallel 1`, wired 25000. Derived: `-c 106496`, the largest that
serves (bench 12, 2026-09-08). Depths: 4096, 98304.

```bash
llama-server -hf AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 106496 \
  --cache-type-k f16 --cache-type-v f16 --cache-ram 0 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench16/results/server-benchy-qwen38-atomicchat-drafter.log
```

Site numbers to read against: 15.8 at 4K, 10.3 at 98K, both with the
artifact.

## `benchy-gemma26-drafter`

The served one-slot row. Fixed:
`unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL`, `--no-mmproj`, f16 KV,
drafter `--spec-type draft-mtp --spec-draft-n-max 2`, `--parallel 1`,
wired 25000. Derived: `-c 212992`, the largest that loads (bench 10,
2026-09-05). Depths: 4096, 98304, 196608.

```bash
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias gemma-4-26b-a4b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 2 --parallel 1 \
  -ngl 999 -fa on -c 212992 \
  --cache-type-k f16 --cache-type-v f16 --cache-ram 0 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench16/results/server-benchy-gemma26-drafter.log
```

Site numbers to read against: 60.3 at 4K, 17.3 at 197K, both with the
artifact. Run 15 read this build with no drafter and the projector at
53.1 at 4K and 19.2 at 204K; put those beside the table too. The
197K cell says whether the row still sits above the 8 tok/s floor on
real text at its window.

## `benchy-gemma26-2slot-drafter`

The two-slot row. Fixed: same files, f16 KV, drafter n-max 2,
`--parallel 2`, wired 25000. Derived: `-c 202752`, the largest that
serves a real completion at two slots (bench 10, 2026-09-05), 101376
per slot. Depths: 4096, 49152, 81920.

```bash
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias gemma-4-26b-a4b-2x --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 2 --parallel 2 \
  -ngl 999 -fa on -c 202752 \
  --cache-type-k f16 --cache-type-v f16 --cache-ram 0 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench16/results/server-benchy-gemma26-2slot-drafter.log
```

Site numbers to read against: 66.6 at 4K, 33.6 at 82K, both with the
artifact.

## `benchy-gemma12-q8-drafter`

The q8_0 KV row with the drafter, thinking off, speed gated at 16K.
Fixed: `unsloth/gemma-4-12b-it-GGUF:Q4_K_XL`, `--no-mmproj`, q8_0 KV,
drafter `--spec-type draft-mtp --spec-draft-n-max 4`, `--parallel 1`,
wired 25000. Derived: `-c 262144`, the row's own `-c` (bench 8,
2026-09-03, wired 24000; no later ladder). Depths: 4096, 16384,
32768.

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 4 --parallel 1 \
  -ngl 999 -fa on -c 262144 \
  --cache-type-k q8_0 --cache-type-v q8_0 --cache-ram 0 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench16/results/server-benchy-gemma12-q8-drafter.log
```

Site numbers to read against: 13.8 at 4K, 6.5 at 16K, both with the
artifact. The 32K cell is one step past the row's speed gate, so the
table shows where the 8 tok/s floor falls on real text.

## `benchy-gemma12-4slot-drafter`

The four-slot row. Fixed: same files, f16 KV, drafter n-max 4,
`--parallel 4`, wired 25000. Derived: `-c 655360`, the largest that
serves a real completion at four slots (bench 10, 2026-09-05), 163840
per slot. Depths: 4096, 49152, 65536.

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b-4x --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 4 --parallel 4 \
  -ngl 999 -fa on -c 655360 \
  --cache-type-k f16 --cache-type-v f16 --cache-ram 0 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench16/results/server-benchy-gemma12-4slot-drafter.log
```

Site numbers to read against: 42.9 at 4K, 27.7 at 49K, both with the
artifact. The creep saw swap grow at 66K on a machine that started
with swap in use; the 65536 cell and its swap column say whether that
holds on a clean start.

## `benchy-qwen36-f16-drafter`

The f16 KV arm with its drafter, the row the site shows at 41K.
Fixed: `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`, rev `5bc3e23`,
`--no-mmproj`, f16 KV, drafter `--spec-type draft-mtp
--spec-draft-n-max 3`, `--parallel 1`, wired 25000. Derived:
`-c 40960`, the largest that serves at f16 with the drafter (bench 11,
2026-09-06, confirmed bench 12). Depths: 4096, 39936.

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 40960 \
  --cache-type-k f16 --cache-type-v f16 --cache-ram 0 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench16/results/server-benchy-qwen36-f16-drafter.log
```

Site numbers to read against: 69.1 at 4K, 52.6 at 41K, both with the
artifact. Run 14 read the same arm with no drafter at 49.8 at 4K and
38.3 at 41K; put those beside the table too.

## The drafter-arms blocks

Added 2026-09-12 on the owner's word, after
`benchy-qwen38-atomicchat-drafter` read 35 to 42 percent acceptance
at 4K. Each `drafter-arms-<row>` block takes the benchy block of the
same row and serves the same files, KV type, slots and `-c` three
more times, one arm per server, in this order: **no drafter** (drop
the two `--spec-*` flags), **n-max 1**, **n-max 2**. Each arm runs
the same benchy line at the row's two depths, into
`results/benchy-<row mnemonic>-nmax<0|1|2>.md` with its own vm log
and server log. Read acceptance on the two drafter arms. Nothing
above n-max 2 in this run; n-max 4 was slower than 3 on both Qwen3.8
3-bit builds (bench 12) and the owner rules it out here.

Done: one table per row with one line per arm and depth: arm, depth,
benchy tok/s, sd, acceptance, swap. Put the row's n-max 3 cells from
its benchy block on the first lines of the same table. **A table and
no pick.** The coordinator names the served arm at close-out.

| block | takes its server from |
|---|---|
| `drafter-arms-qwen38-atomicchat` | `benchy-qwen38-atomicchat-drafter` |
| `drafter-arms-gemma26` | `benchy-gemma26-drafter` |
| `drafter-arms-gemma26-2slot` | `benchy-gemma26-2slot-drafter` |
| `drafter-arms-gemma12-q8` | `benchy-gemma12-q8-drafter` |
| `drafter-arms-gemma12-4slot` | `benchy-gemma12-4slot-drafter` |
| `drafter-arms-qwen36-f16` | `benchy-qwen36-f16-drafter` |

The Qwen3.6 f16 no-drafter arm at `-c 40960` was read by run 14
(49.8 at 4K, 38.3 at 41K); read it again here so the four arms share
one machine day.

## `qwen36-mlx-smoke-on`

Read `docs/methodology/mendel.md`, "The smoke". The first time this
build meets the simulator on this machine. Fixed:
`mlx-community/Qwen3.6-35B-A3B-4bit`, `mlx_lm.server`,
`--prompt-cache-size 2`, thinking on, wired 25000.

```bash
mlx_lm.server --model mlx-community/Qwen3.6-35B-A3B-4bit \
  --prompt-cache-size 2 --port 8081 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench16/results/server-qwen36-mlx.log
```

The owner's word (2026-09-12): MLX is unstable near its ceiling, so
the harness window sits about 20 percent under the MLX ceiling. The
ceiling is the last stable depth of the newest sweep of this server
at wired 25000: planning value 40982 (2026-09-06; the generation
thread died on a Metal OOM at the next step). The window is the
largest multiple of 4096 at or under 80 percent of that ceiling:
planning value 32768. Write `qwen36_mlx_window` in `state.md` with
its source before the smoke.

```bash
SMOKE_MENDEL_CONTEXT_WINDOW=<qwen36_mlx_window> benchmarks/mendel-smoke.sh mlx-community/Qwen3.6-35B-A3B-4bit on 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench16/results/mendel-smoke-qwen36-mlx-on.log
```

Pass is one commit, clean tree, no repetition loop, inside the cap.
A fail means `qwen36-mlx-mendel-blind-on` does not run; write the
smoke line and go on. A server that dies during the smoke is a fail
of this config, not a retry.

## `qwen36-mlx-mendel-blind-on`

simulator(mendel) blind at **thinking on**, the level whose GGUF q8_0
row scored 63, the higher of that model's two levels; this build's
EvalPlus was scored at the same level. Fixed: the server of
`qwen36-mlx-smoke-on` unchanged, prompt blind v1.1, base commit
`2652ed6`. Derived: window `qwen36_mlx_window` from `state.md`. The
task needs about 46K of context; the window is smaller, so the
harness compacts, and that is the measurement. Keep budget 8192, the
rule for a window under 65536.

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<qwen36_mlx_window> ./run-worker.sh mlx-community/Qwen3.6-35B-A3B-4bit pi blind on
```

Branch `mlx-community-Qwen3.6-35B-A3B-4bit-on-issue-13` or the slug
the worker forms; no branch of that name exists. Row `model` value:
`Qwen3.6-35B-A3B (mlx 4-bit, on)`. The config note carries the files,
`mlx_lm.server`, `--prompt-cache-size 2`, the MLX ceiling and its
source, the window, the keep budget, the compaction count, `wired
25000`, and the temperature and top_p from the run's `meta.json`.
Verify `peak_context` with the counter before the row commits. A row
that ends on the model's own repetition loop is a valid partial. A
server that dies mid-run is a row at the state it reached, written
as such, and never a reason to lower the window on your own; the
step down by 8192 is the coordinator's call at the block-close
message. The 300-minute wall gives a partial, which is a row and not
a failure. Write `qwen36_mlx_on` in `state.md`.

## `gemma26-mlx-smoke-high`

Read `docs/methodology/mendel.md`, "The smoke". The first time this
build meets the simulator on this machine. Fixed:
`mlx-community/gemma-4-26b-a4b-it-4bit`, rev `0d77464`,
`mlx_lm.server`, `--prompt-cache-size 2`, thinking high, wired 25000.

```bash
mlx_lm.server --model mlx-community/gemma-4-26b-a4b-it-4bit \
  --prompt-cache-size 2 --port 8081 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench16/results/server-gemma26-mlx.log
```

Same window rule as `qwen36-mlx-smoke-on`. The ceiling is the last
stable depth of the newest sweep of this server at wired 25000:
planning value 70K, the site row's `maxCtx` (bench 3). The window is
the largest multiple of 4096 at or under 80 percent of that ceiling:
planning value 53248. Write `gemma26_mlx_window` in `state.md` with
its source before the smoke.

```bash
SMOKE_MENDEL_CONTEXT_WINDOW=<gemma26_mlx_window> benchmarks/mendel-smoke.sh mlx-community/gemma-4-26b-a4b-it-4bit high 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench16/results/mendel-smoke-gemma26-mlx-high.log
```

Pass and fail as in `qwen36-mlx-smoke-on`. A fail means
`gemma26-mlx-mendel-blind-high` does not run.

## `gemma26-mlx-mendel-blind-high`

simulator(mendel) blind at **thinking high**, the level the GGUF row
of this model scored 47.5 at, which is thinking on for this model in
the harness map; its published default is thinking on. Fixed: the
server of `gemma26-mlx-smoke-high` unchanged, prompt blind v1.1, base
commit `2652ed6`. Derived: window `gemma26_mlx_window` from
`state.md`. Keep budget 8192, the rule for a window under 65536.

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<gemma26_mlx_window> ./run-worker.sh mlx-community/gemma-4-26b-a4b-it-4bit pi blind high
```

Branch by the slug the worker forms; no branch of that name exists.
Row `model` value: `Gemma-4-26B-A4B (mlx 4-bit, high)`. The config
note, the counter check, the partial rules and the server-death rule
are those of `qwen36-mlx-mendel-blind-on`. Write `gemma26_mlx_high`
in `state.md`.

## `retry-sweep`

The run's killed or interrupted rows, oldest first, in fresh
worktrees, while the owner is away. A row that ended on the model's
own repetition loop is a valid partial and is not retried.

## Not in this run

- Any repeat of a scored row. EvalPlus on any block. Polyglot, parked
  by the owner.
- Gemma-12B agent rows, Bonsai on any block, any vision task.
- The ISTA Qwen3.8 build and the bartowski build, on any block.
- A creep or a ladder: every `-c` above is a measured value from a
  committed run, and benchy reads speed at the depths the site shows.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
dropped and why, machine state left behind, evidence archived. The
coordinator adds the findings to
`hardware/m1-max-32gb/benchmarks/INDEX.md`, writes `report.md`, takes
the daggers off the six rows in `models.json`, writes the final
derived values into `models.json` and the site, and publishes.
