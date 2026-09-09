# Run 12 — Gemma-12B two-slot window, Bonsai on the fork at f16, the two promoted Qwen3.8 3-bit builds (Mac)

**Part done, 2026-09-08. You are taking over mid-run.** Block values
marked `<planning>` are the planning-time snapshot and the run replaces
them.

**(2026-09-09: every Qwen3.8 block here says effort medium, and that
was a planning defect. Medium is banned for this model from this date.
The blocks already run keep their rows. `qwen38-atomicchat-mendel`, if
it has not started, does not run at medium: stop and ask. We do not
want parity with the medium rows and we will not compare medium against
medium. Not running medium matters more than parity. A model's first
run uses that model's own default, xhigh here. See
`benchmarks/PLANNING.md`, "The thinking level is chosen, never
inherited".)**

## Where this run stands

Three blocks are finished and their evidence is on the `run12` branch.
Do not run them again.

| block | result |
| --- | --- |
| `tool-check` | `local-llm-eval-tools` pinned at `2344f00` |
| `gemma12-gguf-2slot` | per-slot clean depth **81958**, creep-judged |
| `gemma12-gguf-1slot-131072` | clean depth **114718**, `-c` boundary at 131072, HTTP 400 and not an OOM |

**Start at `bonsai-fork-f16`.** Read `state.md` first: it carries the
two-slot redo in full, including why the first reading of 8222 was a
load ceiling and not a window.

**Before your first block, merge master into this branch.** The
coordinator says so, which the standing rule requires:

```bash
git merge origin/master
```

Master carries research run 3's results and three method rules written
after this run started. Two of them change what you do:

- `docs/methodology/mendel.md`, "Comparing two builds of one model".
  Every Mendel block of this run puts `peak_context` and `tool_calls`
  in the comparison table beside the score. Never match the windows of
  two builds.
- `docs/methodology/mendel.md`, the duplicate rule in the house rules.
  The three Qwen3.8 Mendel blocks below all run under the harness alias
  `qwen3.8-27b`, blind, at effort medium, which already has a row. They
  are **not** duplicates: two are different builds and one is the
  control re-run at the corrected reserve. Run all three.
- `docs/methodology/status-lines.md`, the creep line. A round-robin
  creep prefixes every step with its slot letter.

## Cleanup, alongside your first block

Start the first GPU block, then delete these three projector files
while it runs. Nothing this run serves needs them: every row passes
`--no-mmproj`.

| file | size |
| --- | --: |
| Qwen3.8 `mmproj-f16` | 928 MB |
| Gemma-26B `mmproj-BF16` | ~1195 MB |
| Qwen3.6 `mmproj-F16` | 899 MB |

Then inventory the model cache and report what it holds: files, sizes,
revisions, and which ones no served row references. Delete nothing else
this pass. Keep `unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL`; it is the
K-quant control for the i-quant speed question.

Record the deletion in `results.md`. A missing projector changes what a
later OOM means, and `--offline` skips an uncached side-file with no
error.

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
- **Wired limit: 25000** (owner, 2026-09-07). Two fresh-server single
  sweeps at 25000 were clean, with zero swap growth. The swap growth
  that argued for 24000 appeared only under several sweeps stacked
  back to back with no recovery gap, which is not what a scoring block
  does. Verify with `sysctl -n iogpu.wired_limit_mb` and preflight's
  `wired-limit` line `ok`. Any other value is stop and ask. Every
  config note carries `wired 25000`.
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
- **`retry-sweep` is the last block.** When every other block is done and no
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

## The order

**This list is the order.** Every block starts the moment the one
above it ends, and nothing in this run waits for the owner. Each name
below is the block's mnemonic; its section is lower in this file,
under that name, in whatever order the file keeps them.

- `tool-check` — **done**
- `gemma12-gguf-2slot` — **done**
- `gemma12-gguf-1slot-131072` — **done**
- `bonsai-fork-f16` — start here
- `qwen38-ista-evalplus`
- `qwen38-atomicchat-evalplus`
- `qwen38-gguf-blind-medium`
- `qwen38-ista-mendel`
- `qwen38-atomicchat-mendel`
- `retry-sweep`

Why this order. The two Gemma-12B blocks are the window measurements
the owner asked for, two agents in parallel on one server against one.
`bonsai-fork-f16` asks what the fork does with f16 KV, the one cache
type it never served, and then runs the agent task there.

Then the two builds research run 3 promoted. Both EvalPlus blocks run
before either Mendel block, because EvalPlus is cheap and decisive and
a Mendel run is a night. `qwen38-gguf-blind-medium` sits between them:
it is the control the two new rows are read against, and its 87 was
scored at pi's old 16384 reserve, so a new row scored against it needs
it re-run at 8192 first. A new row with no same-reserve control is an
unreadable number.

Research run 3 measured every Qwen3.8 3-bit candidate level with the
control on EvalPlus and clean on the Mendel smoke, so quality did not
separate them. Depth did. The two picks are the two deepest builds
that carry both smokes:

| build | clean depth | tok/s at depth | evidence |
| --- | --: | --: | --- |
| ista iq3s-mtp | 114718 | 9.67 | both smokes pass |
| atomicchat iq3s | 98338, no stop | 10.26 | both smokes pass |

The unsloth build with its drafter dropped is **not** in this run. Its
research creep reached 131098 with no stop, but that config had only a
creep, and the strip item that produced it was meant for the served
4-bit row, not for an untested 3-bit build. It is not a candidate and
it gets no scoring block (owner, 2026-09-08).

Two blocks are dropped at planning time, in the owner's own drop
order: `gemma26-gguf-blind-high` first, then `qwen36-gguf-guided-high`.
Both re-run a row that already has a score, so both lose to a build
that has none.

Every MLX item moved to `../unscheduled/`: those rows wait on the
in-turn margin rule, because that server cannot refuse a request it
cannot serve.

## `tool-check`

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

## `gemma12-gguf-2slot` — Gemma-12B GGUF, two slots: `-c` ladder and round-robin creep

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

## `gemma12-gguf-1slot-131072` — Gemma-12B GGUF, one slot: creep

Same files, KV type and drafter as `gemma12-gguf-2slot`. Fixed for this block:
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

Done: the creep table beside `gemma12-gguf-2slot`'s in `results.md`, one
comparison table (depth, tok/s one slot, tok/s per slot at two
slots). Stop the server; wait for wired recovery.

## `bonsai-fork-f16` — Bonsai on the PrismML fork, f16 KV: ladder, creep, then the agent task

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

## The two promoted builds

Research run 3 (`../../research/run3/results.md`) took three Qwen3.8
3-bit builds through a creep, an EvalPlus smoke and a Mendel smoke.
All three came back level with the control row and clean on the agent
loop. These two blocks pairs score the two deepest.

Both builds serve the same model family as the row we serve today, so
both use the existing `qwen3.8-27b` pi entry. **The site cannot yet
tell two builds of one model apart**, so no block here writes a site
row: each block records its build, its revision and its flags in
`results.md` and in the row's config note, and the coordinator settles
the identity when it publishes.

**Both builds serve with their MTP drafter, and each needs its own
`n-max` before its Mendel block.** The drafter never changes what the
model writes at temperature 0, so it costs neither build an EvalPlus
arm ([common rules](../../../../docs/methodology/common-rules.md),
rule 11). It does set decode speed, and Mendel ends a run at 300
minutes, so the wrong `n-max` turns a finished row into a partial.

The control row's sweep peaked at `n-max 3`, but that sweep belongs to
a different build. The head ships inside each build, so its acceptance
belongs to that build. Both research creeps already logged theirs:

| build | draft acceptance | mean len |
| --- | --: | --: |
| ista gsq-iq3s | 0.78 on the first long task, then 0.94 to 1.00 | 3.33 to 3.94 |
| atomicchat ad-iq3s | 0.78 on the first long task, then 1.00 | 3.33 to 4.00 |

Both sit near full acceptance at a mean length close to 4, so the only
useful direction is **upward**. Sweep two points above the creep's
value, take the fastest, and stop. Do not sweep downward: at this
acceptance a smaller `n-max` can only cost speed. Record the sweep and
the value chosen in `results.md`, and put the value in the row's config
note.

**Both builds serve above 120K, so llama.cpp issue 27756 applies**: a
silent end-of-sequence past about 130K looks exactly like a finished
turn. Before each Mendel block starts, run one long-prompt completion
check at the block's own window and record it. A check that returns
`tokens_predicted = 1` with empty content and `stop_type` "eos" means
the window is too deep: step the window down by 8192 and check again.

### `qwen38-ista-evalplus` — ISTA IQ3_S-mtp, full EvalPlus

| parameter | kind | value | source |
| --- | --- | --- | --- |
| files | fixed | `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, `--no-mmproj` | research run 3 |
| KV type | fixed | f16 | research run 3 |
| drafter | fixed | `--spec-type draft-mtp`, the head inside the `-mtp` file | research run 3 |
| `n-max` | derived | `<planning>` the value its creep ran, whose log shows mean draft length reaching 4.00 | its own sweep, below |
| thinking | fixed | effort `medium`, the control row's level | run 3, one level per candidate |
| `-c` | derived | `<planning>` 131072, the ladder cleared it | ladder at this run's limit |
| window | derived | `<planning>` 114688, clean depth 114718 | clean depth at the ladder's `-c` |

Read `docs/methodology/evalplus.md`. Calibrate first, then run the
full set against the control row's published score. Record base, plus,
empty and wall in `results.md`.

### `qwen38-atomicchat-evalplus` — AtomicChat AD-IQ3_S, full EvalPlus

| parameter | kind | value | source |
| --- | --- | --- | --- |
| files | fixed | `AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S`, `--no-mmproj` | research run 3 |
| KV type | fixed | f16 | research run 3 |
| drafter | fixed | `--spec-type draft-mtp`, the head inside the build | research run 3 |
| `n-max` | derived | `<planning>` the value its creep ran, whose log shows mean draft length reaching 4.00 | its own sweep, below |
| thinking | fixed | effort `medium`, the control row's level | run 3, one level per candidate |
| `-c` | derived | `<planning>` 106496, the ladder cleared it | ladder at this run's limit |
| window | derived | `<planning>` 98304, clean depth 98338 | clean depth at the ladder's `-c` |

Read `docs/methodology/evalplus.md`. Calibrate first, then run the
full set against the control row's published score. Record base, plus,
empty and wall in `results.md`.

Its creep never hit a stop condition, so 98338 is the end of the depth
list and not a measured ceiling. The ladder replaces both numbers.

### `qwen38-ista-mendel` — ISTA IQ3_S-mtp, blind, effort medium

Same server as `qwen38-ista-evalplus`, at that block's derived `-c`.
Run the long-prompt completion check first.

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<this block's window> ./run-worker.sh qwen3.8-27b pi blind medium
```

Score per `PLAN.md` "How to score a run". The config note carries the
build, the revision, `f16 KV`, the `-c`, the window and `wired 25000`,
and says the row is the ISTA build, not the row we serve today.

### `qwen38-atomicchat-mendel` — AtomicChat AD-IQ3_S, blind, effort medium

Same server as `qwen38-atomicchat-evalplus`, at that block's derived
`-c`. Run the long-prompt completion check first.

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<this block's window> ./run-worker.sh qwen3.8-27b pi blind medium
```

Score per `PLAN.md` "How to score a run". The config note carries the
build, the revision, `f16 KV`, the `-c`, the window and `wired 25000`,
and says the row is the AtomicChat build, not the row we serve today.

## The reserve re-run

One valid row of the three still runs here; the other two are dropped
at planning time, above. It compacted under pi's default 16384 reserve
before 2026-09-06, and runs again at reserve 8192, same test and level,
under the Mendel retry rule for a harness-caused re-run: no penalty,
the better row stands, the config note says "re-run at reserveTokens
8192; first row ran at 16384". Ladder-before-serve applies before its
block.

It is also the control for the two promoted builds, which is why it
keeps its place.

### `qwen38-gguf-blind-medium` — Qwen3.8 GGUF, blind, effort medium

| parameter | kind | value | source |
| --- | --- | --- | --- |
| files | fixed | `bartowski/Qwen3.8-27B-GGUF:Q4_K_M`, `--no-mmproj` | published command |
| KV type, drafter | fixed | f16, MTP n-max 3 | site row `qwen38-gguf-medium` |
| thinking | fixed | pi level `medium` | the first row |
| `-c` | derived | `<planning>` 49152, the load ceiling at 24000 (run 9) | ladder at this run's limit |
| window | derived | `<planning>` 49152 | clean depth at the ladder's `-c` |

Serve with the site row's command at the derived `-c`, then:

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<this block's window> ./run-worker.sh qwen3.8-27b pi blind medium
```

## Not in this run

- Qwen3.8 effort levels and quants, strip modules, the compaction
  experiment and the container trials: research run 3
  (`hardware/m1-max-32gb/research/run3/index.md`), which is finished.
- `unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL` with its drafter dropped. The
  strip item that produced it was meant for the served 4-bit row, so
  the config is not a candidate and gets no scoring block. Its creep
  stands as a measurement (owner, 2026-09-08).
- The drafter question itself, as a speed-against-depth trade on the
  served 4-bit rows. Creeps only, and a later research run owns it.
- `qwen36-gguf-guided-high` and `gemma26-gguf-blind-high`, the two
  reserve re-runs dropped at planning time.
- The Gemma-26B row with its MTP drafter dropped. Its research creep
  ran the whole extended depth list clean at 197k and never hit a stop,
  and it freed about 1.7 GB against the with-drafter row, but it showed
  no deeper clean ceiling, because neither side found one. It needs a
  longer depth list before it can be judged, not a bench block.
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
