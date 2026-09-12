# Run 16 — real-text speed for every row, then the two MLX agent rows (Mac)

Ready to start, 2026-09-12. About thirty hours of machine time.

You are the runner, on the Mac. Read this file, then the pages each
block names at its start, and nothing else. Write all prose in
ASD-STE100 Simplified Technical English.

## What this run is for

The owner's word (2026-09-12): an honest tok/s on real text is what
decides how the owner starts and uses a model, so it comes before
the pending agent rows. Every row of the homepage table whose speed
did not come from `llama-benchy` now carries a dagger. This run reads
each of those rows with benchy at two well-placed depths, and on
every drafter row climbs the draft depth from no drafter up, stopping
as soon as the climb stops paying. Then the two Coding cells the
table shows as pending: Qwen3.6 on MLX at thinking on and Gemma-26B
on MLX, each with a smoke first because no smoke of either MLX build
is on record.

## The order

**This list is the order.**

- `benchy-qwen38-atomicchat-drafter`
- `benchy-gemma26-drafter`
- `sweep-qwen36-mlx`
- `sweep-gemma26-mlx`
- `qwen36-mlx-smoke-on`
- `qwen36-mlx-mendel-blind-on`
- `gemma26-mlx-smoke-high`
- `gemma26-mlx-mendel-blind-high`
- `arms-qwen38-atomicchat`
- `arms-gemma26`
- `sweep-qwen38-ista-nodrafter`
- `sweep-gemma12-f16`
- `sweep-bonsai-mlx`
- `sweep-qwen38-mlx`
- `sweep-bonsai-fork-single`
- `sweep-qwen38-bartowski`
- `sweep-qwen36-q8`
- `sweep-qwen38-ista-drafter`
- `sweep-qwen36-f16-drafter`
- `sweep-qwen36-f16-nodrafter`
- `sweep-gemma26-2slot`
- `sweep-gemma12-q8`
- `sweep-gemma12-2slot`
- `sweep-gemma12-4slot`
- `sweep-bonsai-fork-2slot`
- `sweep-bonsai-fork-f16`
- `retry-sweep`

The owner set this order (2026-09-12): first the speed readings the
agent rows need, then the agent rows the homepage lacks, then the
speed readings the homepage lacks, then every other speed reading.
The first two blocks are the run's first shape and stay as they are:
one closed, one running when this order was written. Every other
speed block follows "The sweep rule" below.

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
- **No download in this run** except the tokenizer named in "The
  benchy command". Every model file below is in the cache; a missing
  file is stop and ask.
- **No temperature and no sampling parameter is passed to any
  server.** The server's own default is the serving sampling. Read the
  values a simulator(mendel) run used from its `meta.json` and put
  them in the row's config note.
- **Effort medium is banned for Qwen3.8** (owner rule, 2026-09-09).
  A speed block reads decode only and names no level.
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
llama-benchy --base-url http://127.0.0.1:8081/v1 --model <the id the server answers to> \
  --tokenizer <tokenizer for this model's base> \
  --book-url http://127.0.0.1:8089/corpus-mendel-js.txt \
  --pp 512 --tg 256 --depth <block's depths, space separated> \
  --runs 2 \
  --post-run-cmd 'sleep 60; vm_stat | head -12 >> hardware/m1-max-32gb/benchmarks/bench16/results/benchy-<mnemonic>-<arm>-vm.log; sysctl vm.swapusage >> hardware/m1-max-32gb/benchmarks/bench16/results/benchy-<mnemonic>-<arm>-vm.log' \
  --format md --save-result hardware/m1-max-32gb/benchmarks/bench16/results/benchy-<mnemonic>-<arm>.md
```

`<arm>` is `nmax0` for no drafter, `nmax1` and so on; a row with no
drafter arm uses `nmax0` only.

Tokenizers, each the base model repo the quant's card names, all
cached: Qwen3.8 builds `Qwen/Qwen3.8-27B` (research run 4); Qwen3.6
`Qwen/Qwen3.6-35B-A3B` (run 15); Gemma-26B `google/gemma-4-26b-a4b-it`
(run 15); Bonsai `prism-ml/Ternary-Bonsai-27B-mlx-2bit`, the MLX
repo that carries the model's own tokenizer. Gemma-12B uses
`google/gemma-4-12b-it`, a tokenizer download of a few MB, approved
for this run. Record the tokenizer beside every table.

The corpus is the code text research run 4 built:
`hardware/m1-max-32gb/research/run4/results/corpus-mendel-js.txt`
(sha256 in `benchy_corpus`). Benchy fetches `--book-url` over HTTP,
so serve that directory first with
`python3 -m http.server 8089 --bind 127.0.0.1` and stop it after the
last speed block. Every llama-server command in a speed block carries
`--cache-ram 0` for the measurement only; the published serving
command does not. Depths are space separated. A benchy request adds
768 tokens over its depth, so the deepest depth of every block sits
at least 1024 under the serving `-c` (or under the slot size on a
multi-slot server). On a multi-slot server benchy drives one slot;
the other slots stay loaded and idle, as the creep did.

No `--extra-body`. Keep the server log; on a drafter arm read the
`draft acceptance` line of the matching request and put it beside the
cell. `mlx_lm.server` writes no per-request timings; benchy's own
client-side tok/s is the number there. A benchy block costs about
three times a creep step: benchy re-prefills the full depth on every
request.

## The sweep rule

The owner's word (2026-09-12), now in `docs/methodology/context-creep.md`:
a few well-placed, fast benchy readings over more draft depths beat a
full ladder. Every `sweep-*` and `arms-*` block applies it:

1. Serve the row's own files, KV type, slots and `-c` from its site
   entry, with `--cache-ram 0` added. Each arm is a fresh server.
2. Read every arm at the block's two (or three) depths in one benchy
   call.
3. On a drafter row, climb: no drafter first, then `--spec-type
   draft-mtp --spec-draft-n-max 1`, then 2, then 3. The row's own
   served n-max is always read, even when the climb stops under it.
   Nothing above 3, except Gemma-12B whose served value is 4.
4. **Stop the climb** when an arm reads slower than the arm before it
   at every depth. When it reads slower at one depth and faster at
   another, take one more arm, then stop. Write the arm you stopped
   at and why in `results.md`.
5. Done: one table per block, one line per arm and depth: arm, depth,
   benchy tok/s, sd, the site's tok/s at that depth, the difference
   in percent, acceptance, swap. Put any cell an earlier run already
   read with benchy on the same table, marked with its run. **A
   table and no pick.** The coordinator names the served arm and
   takes the dagger off.

## `benchy-qwen38-atomicchat-drafter`

The served row of the AtomicChat 3-bit build, n-max 3 only. Fixed:
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

Site numbers to read against: 15.8 at 4K, 10.3 at 98K.

## `benchy-gemma26-drafter`

The served one-slot row, n-max 2 only. Fixed:
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

Site numbers to read against: 60.3 at 4K, 17.3 at 197K. Run 15 read
this build with no drafter and the projector at 53.1 at 4K and 19.2
at 204K; put those beside the table too.

## `arms-qwen38-atomicchat`

The climb for `benchy-qwen38-atomicchat-drafter`: same server, arms
no drafter, 1, 2, by "The sweep rule"; n-max 3 is already on the
table from that block. Depths: 4096, 98304.

## `arms-gemma26`

The climb for `benchy-gemma26-drafter`: same server, arms no drafter,
1, then 3 if the rule still climbs past the served 2, which that
block already read. Depths: 4096, 98304, 196608.

## `sweep-qwen38-bartowski`

The best local row. Fixed: `bartowski/Qwen3.8-27B-GGUF:Q4_K_M`, rev
`f0eec4a`, `--no-mmproj`, f16 KV, `--parallel 1`, wired 25000.
Derived: `-c 73728` (bench 12, 2026-09-08). Arms: no drafter, 1, 2;
n-max 3 is on the site from run 14 (11.8 at 4K, 8.6 at 65.5K).
Depths: 4096, 65536. Alias `qwen3.8-27b`.

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj --parallel 1 \
  <arm flags> \
  -ngl 999 -fa on -c 73728 \
  --cache-type-k f16 --cache-type-v f16 --cache-ram 0 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench16/results/server-sweep-qwen38-bartowski-<arm>.log
```

`<arm flags>` is empty for no drafter and `--spec-type draft-mtp
--spec-draft-n-max <n>` otherwise, in every block below.

## `sweep-qwen38-ista-nodrafter`

The two ISTA no-drafter rows share one curve. Fixed:
`ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, rev `d562806`,
`--no-mmproj`, f16 KV, `--parallel 1`, wired 25000. Derived:
`-c 163840` (bench 13). One arm, no drafter. Depths: 4096, 146432.
Alias `qwen3.8-27b-ista`. Site: 14.1 at 4K, 8.3 at 147K; research run
4 read this arm with benchy at 13.94 at 4K and 9.47 at 98K.

## `sweep-qwen38-ista-drafter`

The ISTA drafter row. Same files, f16 KV, `--parallel 1`. Derived:
`-c 131072` (bench 12). Arms: 1, 2, 3 (no drafter is the block
above). Depths: 4096, 114688. Alias `qwen3.8-27b`. Site: 15.1 at 4K,
9.7 at 115K.

## `sweep-qwen36-q8`

The served Qwen3.6 row. Fixed:
`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`, rev `5bc3e23`,
`--no-mmproj`, q8_0 KV, `--parallel 1`, wired 25000. Derived:
`-c 98304` (bench 11, confirmed bench 12). Arms: no drafter, 1, 2;
n-max 3 is on the site from run 14 (43.7 at 4K, 13.0 at 82K).
Depths: 4096, 81920. Alias `qwen3.6-35b-a3b`.

## `sweep-qwen36-f16-drafter`

The f16 KV arm with its drafter, the row the site shows at 41K. Same
files, f16 KV, `--parallel 1`. Derived: `-c 40960` (bench 11,
confirmed bench 12). Arms: no drafter, 1, 2, 3. Depths: 4096, 39936.
Alias `qwen3.6-35b-a3b`. Site: 69.1 at 4K, 52.6 at 41K; run 14 read
the no-drafter arm at this `-c` at 49.8 and 38.3.

## `sweep-qwen36-f16-nodrafter`

The f16 no-drafter row at its own window. Same files, f16 KV,
`--parallel 1`. Derived: `-c 65536` (run 15). One arm, no drafter.
Depths: 4096, 64512. Alias `qwen3.6-35b-a3b-f16`. Site: 50.5 at 4K,
33.6 at 66K (creep); run 15 read it with the projector loaded at 48.8
and 33.1.

## `sweep-gemma26-2slot`

The two-slot Gemma-26B row. Fixed:
`unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL`, `--no-mmproj`, f16 KV,
`--parallel 2`, wired 25000. Derived: `-c 202752` (bench 10), 101376
per slot. Arms: no drafter, 1, 2, 3; served is 2. Depths: 4096,
81920. Alias `gemma-4-26b-a4b-2x`. Site: 66.6 at 4K, 33.6 at 82K.

## `sweep-gemma12-q8`

The q8_0 KV row with the drafter, speed gated at 16K. Fixed:
`unsloth/gemma-4-12b-it-GGUF:Q4_K_XL`, `--no-mmproj`, q8_0 KV,
`--parallel 1`, wired 25000. Derived: `-c 262144` (bench 8, wired
24000; no later ladder). Arms: no drafter, 1, 2, 3, 4; served is 4.
Depths: 4096, 16384, 32768. Alias `gemma-4-12b`. Site: 13.8 at 4K,
6.5 at 16K. The 32K cell shows where the 8 tok/s floor falls on real
text.

## `sweep-gemma12-f16`

The f16 no-drafter row at 245K. Same files, f16 KV, `--parallel 1`.
Derived: `-c 262144` (bench 10). One arm, no drafter. Depths: 4096,
245760. Alias `gemma-4-12b`. Site: 24.64 at 4K, 8.86 at 245K.

## `sweep-gemma12-2slot`

Same files, f16 KV, `--parallel 2`. Derived: `-c 196608` (bench 10),
98304 per slot. One arm, no drafter. Depths: 4096, 81920. Alias
`gemma-4-12b-2x`. Site: 25.0 at 4K, 15.7 at 82K.

## `sweep-gemma12-4slot`

Same files, f16 KV, `--parallel 4`. Derived: `-c 655360` (bench 10),
163840 per slot. Arms: no drafter, 1, 2, 3, 4; served is 4. Depths:
4096, 49152. Alias `gemma-4-12b-4x`. Site: 42.9 at 4K, 27.7 at 49K.
The creep saw swap grow at 66K on a machine that started with swap in
use; the swap column says whether 49K is clean on a clean start.

## The MLX sweeps

`mlx_lm.server` rows have no drafter: one arm each. Serve the row's
own command from the site entry unchanged; benchy's `--model` is the
repo id the server answers to. Deep depth sits under the row's
measured MLX ceiling. The generation thread of this server can die on
a Metal OOM near its ceiling while the models endpoint keeps
answering (`docs/methodology/server-lore.md`): a dead deep cell is
recorded as such, and the block is done.

- `sweep-qwen38-mlx`: `mlx-community/Qwen3.8-27B-4bit`,
  `--prompt-cache-size 2`. Depths: 4096, 24576. Site: 17 at 4K, 15.3
  at 28K.
- `sweep-qwen36-mlx`: `mlx-community/Qwen3.6-35B-A3B-4bit`,
  `--prompt-cache-size 2`. Depths: 4096, 39936. Site: 55.1, 37.4.
- `sweep-gemma26-mlx`: `mlx-community/gemma-4-26b-a4b-it-4bit`, rev
  `0d77464`, `--prompt-cache-size 2`. Depths: 4096, 65536. Site: 51,
  12.8.
- `sweep-bonsai-mlx`: `prism-ml/Ternary-Bonsai-27B-mlx-2bit`,
  `--prompt-cache-size 2`. Depths: 4096, 56320. Site: 24.5, 17.3.

## The prism fork sweeps

The PrismML llama.cpp fork rows, no drafter, one arm each. Serve the
row's own command from the site entry with `--cache-ram 0` added; the
`<rev>` in the model path is the cached snapshot, and the KV bias file
must exist before the q4_0 servers start (`docs/setups/m1-max-32gb/`
holds how it was made; a missing bias file is stop and ask, never a
rebuild on your own). Tokenizer `prism-ml/Ternary-Bonsai-27B-mlx-2bit`.

- `sweep-bonsai-fork-single`: q4_0 KV with bias, `-c 65536`,
  `--parallel 1`, alias `bonsai-prism`. Depths: 4096, 32768. Site:
  14.8 at 4K, 7.9 at 33K, speed gated.
- `sweep-bonsai-fork-2slot`: q4_0 KV with bias, `-c 98304`,
  `--parallel 2`, alias `bonsai-prism-2x`. Depths: 4096, 49152. Site:
  14.9, 7.8.
- `sweep-bonsai-fork-f16`: f16 KV, `-c 131072`, `--parallel 1`, alias
  `bonsai-prism-f16`. Depths: 4096, 130048. Site: 15.0, 9.7.

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

The owner's rule (2026-09-12, `docs/methodology/mendel.md`, "Window
and budget"): MLX often triggers macOS memory compression near its
ceiling, so the harness window sits 5 percent under the MLX ceiling.
The ceiling is the last stable depth of the newest sweep of this
server at wired 25000: planning value 40982 (2026-09-06; the
generation thread died on a Metal OOM at the next step). The window
is the largest multiple of 4096 at or under 95 percent of that
ceiling: planning value 36864. A dead deep cell in `sweep-qwen36-mlx`
does not move it: that request was larger than the window. Only a
server death at the window itself, in the smoke or the agent row,
steps it down by 8192, written in `state.md` and the config note.
Write `qwen36_mlx_window` in `state.md` with its source before the
smoke.

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

Branch by the slug the worker forms; no branch of that name exists.
Row `model` value: `Qwen3.6-35B-A3B (mlx 4-bit, on)`. The config note
carries the files, `mlx_lm.server`, `--prompt-cache-size 2`, the MLX
ceiling and its source, the window, the keep budget, the compaction
count, `wired 25000`, and the temperature and top_p from the run's
`meta.json`. Verify `peak_context` with the counter before the row
commits. A row that ends on the model's own repetition loop is a
valid partial. A server that dies mid-run is a row at the state it
reached, written as such, and never a reason to lower the window on
your own; the step down by 8192 is the coordinator's call at the
block-close message. The 300-minute wall gives a partial, which is a
row and not a failure. Write `qwen36_mlx_on` in `state.md`.

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
planning value 70K, the measured ceiling in the site row's note
(bench 3). The window is the largest multiple of 4096 at or under 95
percent of the ceiling: planning value 65536. A dead deep cell in
`sweep-gemma26-mlx` does not move it; only a server death at the
window itself, in the smoke or the agent row, steps it down by 8192,
written in `state.md` and the config note. Write
`gemma26_mlx_window` in `state.md` with its source before the smoke.

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
  by the owner. LM Studio, retired.
- Gemma-12B agent rows, Bonsai agent rows, any vision task.
- A creep or a ladder: every `-c` above is a measured value from a
  committed run, and benchy reads speed at the depths the site shows.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
dropped and why, machine state left behind, evidence archived. The
coordinator adds the findings to
`hardware/m1-max-32gb/benchmarks/INDEX.md`, writes `report.md`, names
the served arm of every drafter row, takes the daggers off in
`models.json`, writes the final derived values into `models.json` and
the site, and publishes.
