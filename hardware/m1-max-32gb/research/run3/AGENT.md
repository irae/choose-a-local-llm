# Research run 3 (Mac)

You are the executor, on the Mac. Read this file and `index.md`, then
the item file each item names at its own start. Write all prose in
ASD-STE100 Simplified Technical English.

**`index.md` is the order.** Take its items top to bottom and check
each one off there as it ends. Every item names the file that holds
its method; read that file when the item starts, not before.

## Essentials

- `state.md` holds what earlier sessions of this run did. Resume where
  its handing-over section says.
- **FIRST ACTION:** `git worktree add ../choose-a-local-llm-research3
  -b research3` (or `cd` into it if it exists), then `cd` there.
  Verify with `pwd` and `git worktree list`. Every command of this run
  happens there.
- Then `docs/methodology/checklist.md`, whole, once per session.
  `tools/preflight.sh` runs first and every line must read `ok` before
  an item starts. Never sudo, never reboot on your own.
- **Wired limit: 25000.** Verify with `sysctl -n iogpu.wired_limit_mb`.
  Any other value is stop and ask. Every note carries `wired 25000`.
- **Research publishes no number.** No full EvalPlus run, no scored
  Mendel run, no site edit, no `models.json` edit. An item that passes
  its smokes becomes a bench item; the coordinator writes it.
- **KV is f16 everywhere.** This machine is slow at a quantized KV
  cache. q8_0 only where a build cannot reach a needed depth at f16,
  and then the row says so.
- **One effort or thinking level per candidate**, the level its
  control row uses. A second level is its own item or it does not run.
- **A ceiling test is a real request the size of the work.** A
  one-token probe passes where the first real step OOMs.
- **Measured parameters come from the newest measurement, never from a
  number in this file** (`docs/methodology/common-rules.md`, rule 10).
  Every `-c` and every window here is a planning snapshot; the run's
  own ladder and creep replace it. Write the value it used and the
  source of that value in `state.md` before an item serves a model.
- **Harness values are per run, and the owner's files are never
  edited.** Both smokes build their own pinned copy; leave
  `~/.pi/agent/models.json` alone.
- **A smoke that ends on a repetition loop or degenerate output is a
  fail**, not a retry. Put the repeated unit and the count in
  `results.md` and move to the next item.
- **Ladder before creep.** From the item's starting `-c`, step 8192
  until a real 4096-token completion fails; the largest value that
  served is the creep's `-c`. Record every candidate in `results.md`.
- Serve the exact files each item names. **No item of this run may
  download anything.** A missing file is stop and ask.
- One model on the GPU at a time, port 8081. Quit the LM Studio app
  first and confirm with `pgrep -fl "LM Studio"`.
- A creep runs its own monitor and starts no watcher. Every smoke that
  scores starts `benchmarks/run-watch.sh` as the checklist says.
- `gh auth status` must pass before any Mendel smoke.
- Commit on `research3` as results land. Push at every item close and
  message the coordinator session with the item, the config, the
  result line and the commit id. Never run a bare `git stash`.
- **Every gate and every stop-and-ask goes to the coordinator
  session**, with the item, the condition and your candidate answer.
  Keep the GPU busy with the next item that does not depend on it
  while you wait.
- A bug found in a run tool goes to a subagent on the best available
  model at once; the run does not wait for it.
- Status lines follow `docs/methodology/status-lines.md`. Archive
  evidence before a session closes:
  `tools/archive-evidence.sh hardware/m1-max-32gb/research/run3/results research3`.

## The three commands

The item sections below give only what differs from these.

**Serve.** The Qwen3.8 row's published command, with the build's own
`-hf` and the ladder's `-c`:

```bash
llama-server -hf <repo>:<quant> \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c <ladder value> \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/research/run3/results/server-<mnemonic>.log
```

**Creep.** `docs/methodology/context-creep.md`, "Install", first: pull
the tool and use the hash `tool-check` pinned.

```bash
DEPTH_LIST="4096,8192,16384,24576,32768,40960,49152,65536,81920,98304,114688,131072" \
N_CONTEXTS=1 MODEL=<alias> \
  python3 ~/code/local-llm-eval-tools/slow-context-creep/creep.py llama \
  | tee hardware/m1-max-32gb/research/run3/results/creep-<mnemonic>.tsv
```

Cut the list at the ladder's `-c`. A build served above 120K adds one
real completion at its deepest depth, because llama.cpp issue 27756
makes a silent end-of-sequence look like a finished turn.

**The two smokes.** Both need the server up. Run each candidate
against the same smoke on the row we serve today, so the pair is
comparable.

```bash
SMOKE_CALIBRATION=benchmarks/calibration-qwen38-gguf-medium.json \
  benchmarks/evalplus-smoke.py <candidate|current> qwen3.8-27b
benchmarks/mendel-smoke.sh qwen3.8-27b medium
```

Read the Mendel smoke's verdict line and nothing else. A pass is a
permit, not a quality signal.

## `tool-check`

Clone or pull `git@github.com:irae/local-llm-eval-tools.git` at
`~/code/local-llm-eval-tools`, write `git rev-parse --short HEAD` in
`state.md`, and run `creep.py llama --help`. That hash is pinned for
the whole run: no second pull in the middle of it. Done when the hash
is in `state.md` and the help text printed.

## The three Qwen3.8 3-bit builds

Read `../qwen38-configs.md`, "The trial, as the owner approved it".
The builds, their aliases and their pinned revisions are in the model
pins the machine wrote when it downloaded them. Each build takes a
ladder, then a creep, and nothing else until its gate.

| item | `-hf` | starting `-c` |
| --- | --- | --- |
| `qwen38-unsloth-q3kxl-creep` | `unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL` | 114688 |
| `qwen38-atomicchat-iq3s-creep` | `AtomicChat/Qwen3.8-27B-GGUF`, `--hf-file Qwen3.8-27B-AD-IQ3_S.gguf` | 106496 |
| `qwen38-ista-iq3s-mtp-creep` | `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF`, `--hf-file Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf` | 131072 |

The starting values are projections from one measured row, not
measurements. The ladder replaces them. Done per build: the ladder
table and the creep table with its verdict in `results.md`, and the
clean depth in `state.md` as `<mnemonic>_clean`. Stop the server; wait
for the wired recovery.

## `qwen38-creep-gate`

Runs after the last of the three creeps, never as one of them ends.
Read all three creep files together. Write one line per build in
`results.md`: the build, its clean depth, the reference, the ratio,
and `evalplus: run` or `evalplus: skipped, context too small`.

The reference is the deepest clean depth this machine has measured for
Qwen3.8 at f16: **49152**. The rule: a clean depth more than 20
percent under it, so **under 39322 tokens**, skips that build's
EvalPlus smoke and every step after it. Log every build, the ones that
pass as well as the ones that stop, so the run records which creep
invalidated which smoke.

## The three EvalPlus smokes

One per build that the gate marked `run`, on the window its creep
supports. Same budget on both sides: the calibration file above is the
budget for the candidate and for the control. Done: the two lines in
`results.md`, side by side, with the empty-completion count.

## `qwen38-evalplus-gate`

Runs after the last EvalPlus smoke. One line per build in
`results.md`: the build, its pass count, and `mendel: run` or `mendel:
skipped, EvalPlus returned nothing`. A build the creep gate stopped is
logged here as `mendel: skipped, no EvalPlus smoke ran`. The rule: a
build whose EvalPlus smoke returned an empty result on every task
skips its Mendel smoke.

## The three Mendel smokes

One per build that the gate marked `run`, at effort medium, on the
window its creep supports. Done: the verdict line per build in
`results.md`, beside the same smoke on the row we serve today.

## `qwen38-effort-low-smoke`, `qwen38-effort-xhigh-smoke`

The row we serve today, `bartowski/Qwen3.8-27B-GGUF:Q4_K_M`, f16,
`-c 49152`, unchanged. Only the effort level moves, server-wide with
`--reasoning-effort`. Read `../qwen38-configs.md`, "Reasoning effort",
first: the public evidence runs against the report that medium is
worst, and the pair is what settles it here. Done: the two verdict
lines in `results.md`, against the medium row's 87.

## The four compaction ladders

Read `../compaction-experiment.md`, whole, before the first one. It
owns the ladder, the rungs, the repeats and the pass rule. One model
at a time:

| item | config |
| --- | --- |
| `compaction-qwen38` | Qwen3.8 GGUF Q4_K_M, f16, `-c 49152`, effort medium |
| `compaction-gemma12` | Gemma-4-12B, llama-server, f16, thinking off |
| `compaction-bonsai-mlx` | Bonsai MLX, thinking off. Only if its smoke line says `pass` |
| `compaction-gemma26` | Gemma-26B GGUF, f16. Only if its smoke line says `pass` |

Done per model: the ladder table, and the `contextWindow` floor in
`state.md` when two runs at one rung pass.

## The three strip pairs

Read `../strip-modules.md`, "The pair", whole. It owns the steps, the
wired reading and the pass rule. The Qwen3.8 pair runs first; the
other two are optional and stop when the run runs short.

| item | row | `-c` |
| --- | --- | --- |
| `strip-qwen38-pair` | `bartowski/Qwen3.8-27B-GGUF:Q4_K_M` | 49152 |
| `strip-gemma26-pair` | `unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL` | 212992 |
| `strip-qwen36-pair` | `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`, drafter off both sides | 49152 |

The Gemma-26B "with" side is expected to fail at load; that failure is
the result, and step 8 of the item says what to record.

## The two drafter creeps

`strip-qwen38-nodrafter-creep` and `strip-gemma26-nodrafter-creep`:
the row's published command with `--spec-type draft-mtp` and
`--spec-draft-n-max` removed, everything else unchanged, then a ladder
and a creep. These two items exist because the projector pairs measure
a saving the served rows already take, so they change no pick, while
the drafter is worth 200 to 300 MB on Qwen3.8 and a separate 462 MB
file on Gemma-26B, and a drafter costs depth. The question: does the
freed memory buy a deeper window than the drafter's shallow speed is
worth? Done: the ladder and creep tables beside the row's own, and one
line naming the deeper of the two clean depths.

## Not in this run

- The container trials: `../unscheduled/container-trials.md`, moved
  there by the owner on 2026-09-07.
- Every MLX window item, the small agent models, the specialized
  models, the wired-limit ladder: `../unscheduled/`.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
stopped and why, machine state left behind, evidence archived. The
coordinator reads it, decides which candidates become bench items, and
writes the findings up.
