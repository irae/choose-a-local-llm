# Run 14 — three honest curves, then two agent rows (Mac)

Ready to start, 2026-09-10. About six hours of machine time.

You are the runner, on the Mac. Read this file, then the pages each
block names at its start, and nothing else. Write all prose in
ASD-STE100 Simplified Technical English.

## What this run is for

Every drafter row on the site was measured with a creep whose text
lets the drafter accept every draft, so its deep tok/s is an upper
bound. Research run 4 validates `llama-benchy` as the reader of decode
speed at depth on the ISTA build. This run reads three more curves
with it, on real text at the server's own sampling, and then adds the
two agent rows the seats still lack: Qwen3.6 blind at thinking off,
and the 4-bit Qwen3.8 at its own default level.

## The order

**This list is the order.**

- `benchy-gate` — **waits on research run 4; read its `state.md`**
- `benchy-qwen36-f16-nodrafter`
- `benchy-qwen36-q8-drafter`
- `benchy-qwen38-bartowski-drafter`
- `qwen36-smoke-off`
- `qwen36-mendel-blind-off`
- `qwen38-bartowski-smoke-xhigh`
- `qwen38-bartowski-mendel-xhigh`
- `retry-sweep`

The two Mendel rows do not depend on the benchy blocks. If
`benchy-gate` is still waiting when this run starts, take the two
smokes and the two Mendel rows first and come back to the benchy
blocks when the gate opens.

## Essentials

- `bench14/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION:** `git worktree add ../choose-a-local-llm-run14 -b
  run14` (or `cd` into it if it exists), then `cd
  ../choose-a-local-llm-run14`. Verify with `pwd` and `git worktree
  list`. Every command of this run happens there.
- **Branches, exactly.** You work on `run14` and only on `run14`. The
  coordinator works on `master`. To take an update: `git fetch origin
  && git merge origin/master`, then push `run14`. Never check out
  `master`, never merge `run14` into `master`, never push `master`.
- Then `docs/methodology/checklist.md`, whole, once per session.
  `tools/preflight.sh` first, every line `ok` before a block starts.
  Never sudo, never reboot on your own.
- **Wired limit: 25000.** Verify with `sysctl -n iogpu.wired_limit_mb`.
  Any other value is stop and ask. Every note carries `wired 25000`.
- **Another agent runs research run 4 on this machine in its own
  worktree.** One model on the GPU at a time, port 8081. Before you
  start a server, `pgrep -fl llama-server` must be empty; if it is not,
  wait and check again every five minutes, and say so in `state.md`.
  Never kill a server you did not start. Quit the LM Studio app first
  and confirm with `pgrep -fl "LM Studio"`; its model cache is the
  owner's and is never touched.
- **No temperature and no sampling parameter is passed to any
  server**, on any block. The server's own default is the serving
  sampling. Read the values the run actually used from the run's
  `meta.json` and put them in every row's config note.
- **Effort medium is banned for Qwen3.8** (owner rule, 2026-09-09).
  No block names it.
- **Harness values are per run.** The worker builds its own pinned
  config; leave `~/.pi/agent/models.json` alone.
- **A ceiling test is a real request the size of the work.** The
  serving `-c` of every block is a value this project measured that
  way; the block names its source.
- `gh auth status` must pass before any Mendel smoke.
- Every scoring run starts `benchmarks/run-watch.sh` as the checklist
  says, with `RUNWATCH_SILENCE=2700` on the Qwen3.8 xhigh row, because
  one xhigh turn on this model runs past the 600 s default.
- Scoring in a subagent on the best available model, never a smaller
  one. A bug in a run tool goes to a subagent on the best model at
  once; the run does not wait for it.
- Commit on `run14` as results land. Push at every block close and
  message the coordinator session with the block, the config, the
  result line and the commit id. Never run a bare `git stash`.
- Every gate and every stop-and-ask goes to the coordinator session
  with the block, the condition and your candidate answer. Keep the
  GPU busy with the next block that does not depend on it.
- Status lines follow `docs/methodology/status-lines.md`. Archive
  evidence before a session closes:
  `tools/archive-evidence.sh hardware/m1-max-32gb/benchmarks/bench14/results run14`.
- Nothing of an interrupted run is cleaned up mid-run
  (`docs/methodology/mendel.md`, "No cleanup mid-run").

## The benchy command

Read `hardware/m1-max-32gb/research/run4/state.md` first: it holds
`benchy_version`, `benchy_tokenizer`, `benchy_corpus` and
`benchy_invocation`, the exact command line that passed there. Use
that line, with this run's alias, depths and file names. The shape:

```bash
llama-benchy --base-url http://127.0.0.1:8081/v1 --model <alias> \
  --tokenizer <benchy_tokenizer for this model's base> \
  --pp 512 --tg 256 --depth <block's depths> \
  --runs 2 --warmup-runs 1 \
  --post-run-cmd 'sleep 60; vm_stat | head -12 >> hardware/m1-max-32gb/benchmarks/bench14/results/benchy-<mnemonic>-vm.log' \
  --format md --save-result hardware/m1-max-32gb/benchmarks/bench14/results/benchy-<mnemonic>.md
```

No `--extra-body`. Keep the server log; for every cell, read the
`draft acceptance` line of the matching request and put it beside the
cell. A block whose tokenizer is not the ISTA one needs its own
`--tokenizer`, the base model repo the quant's card names; record it.

Done, per benchy block: one table in `results.md` with depth, benchy
tok/s and its standard deviation, the site's current tok/s at the
nearest depth, the difference in percent, and acceptance. **A table
and no pick.** The coordinator decides the serving row.

## `benchy-gate`

Read `hardware/m1-max-32gb/research/run4/state.md`. If `benchy_pass`
is `yes`, write the four benchy values into this run's `state.md` and
the three benchy blocks may run. If it is `no` or empty, the three
benchy blocks wait; take the smokes and the Mendel rows, and check the
file again after each block closes. Never run a benchy block on an
empty gate.

## `benchy-qwen36-f16-nodrafter`

The arm that has never been measured: Qwen3.6 at f16 KV with no
drafter. Fixed: `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`, rev
`5bc3e23`, `--no-mmproj`, f16 KV, `--parallel 1`, wired 25000.
Derived: `-c 40960`, the largest that serves a real request at f16
(bench 11, 2026-09-06, confirmed bench 12). Depths: 4096, 40960.

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 40960 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench14/results/server-benchy-qwen36-f16-nodrafter.log
```

Site numbers to read against: 69.1 at 4K, 52.6 at 41K, both with the
drafter and the artifact. Record wired at load beside the table: the
drafter's head is freed here, and the number says what that buys.

## `benchy-qwen36-q8-drafter`

The served row. Fixed: same files, q8_0 KV, drafter
`--spec-type draft-mtp --spec-draft-n-max 3`, `--parallel 1`, wired
25000. Derived: `-c 98304`, the largest that serves a real request at
q8_0 (bench 11, confirmed bench 12). Depths: 4096, 49152, 81920.

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 98304 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench14/results/server-benchy-qwen36-q8-drafter.log
```

Site numbers to read against: 36.5 at 4K, 14.3 at 49K, 9.24 at 82K.
The 82K cell decides whether the row's window still sits above the 8
tok/s floor on real text; write its acceptance in the same row.

## `benchy-qwen38-bartowski-drafter`

The served row of the 4-bit build. Fixed:
`bartowski/Qwen3.8-27B-GGUF:Q4_K_M`, rev `f0eec4a`, `--no-mmproj`, f16
KV, drafter `--spec-type draft-mtp --spec-draft-n-max 3`,
`--parallel 1`, wired 25000. Derived: `-c 73728`, the largest that
serves (bench 12, 2026-09-08). Depths: 4096, 65536.

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 73728 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench14/results/server-benchy-qwen38-bartowski-drafter.log
```

Site numbers to read against: 20.0 at 4K, 13.7 at 65.5K, both with the
artifact. The tokenizer is this build's base model's; the ISTA one is
the same base model, so `benchy_tokenizer` from research run 4 applies.

## `qwen36-smoke-off`

Read `docs/methodology/mendel.md`, "The smoke". Serve the
`benchy-qwen36-q8-drafter` server unchanged: q8_0 KV, drafter n-max 3,
`-c 98304`. The smoke on record for this config and level is bench
11's, on the same server; this one is cheap and confirms the machine
today.

```bash
benchmarks/mendel-smoke.sh qwen3.6-35b-a3b off 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench14/results/mendel-smoke-qwen36-off.log
```

Pass is one commit, clean tree, no repetition loop, inside the cap.
A fail means `qwen36-mendel-blind-off` does not run; write the smoke
line and go on.

## `qwen36-mendel-blind-off`

Mendel blind at **thinking off**, the level whose guided row scored
62.5 on this window, the pair that row lacks. Fixed: the
`benchy-qwen36-q8-drafter` server, prompt blind v1.1, base commit
`2652ed6`. Derived: window **81920**, the clean depth 81958 of the
q8_0 creep at 25000 (bench 12), the same window the guided 62.5 ran
on; if `benchy-qwen36-q8-drafter` read the 82K cell under 8 tok/s on
real text, stop and ask before starting, with that number.

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=81920 ./run-worker.sh qwen3.6-35b-a3b pi blind off
```

Branch `qwen3.6-35b-a3b-off-issue-13`; no branch of that name exists.
Score per `PLAN.md`. The config note carries the files, revision,
`q8_0 KV`, `-c 98304`, drafter n-max 3, window 81920, `wired 25000`,
and the temperature and top_p read from the run's `meta.json`. Verify
`peak_context` with the counter before the row commits.

## `qwen38-bartowski-smoke-xhigh`

Serve the `benchy-qwen38-bartowski-drafter` server unchanged: f16 KV,
drafter n-max 3, `-c 73728`. Research run 3 passed this build's smoke
at xhigh on `-c 49152`; the server has moved, so run it again.

```bash
benchmarks/mendel-smoke.sh qwen3.8-27b xhigh 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench14/results/mendel-smoke-qwen38-bartowski-xhigh.log
```

A fail means `qwen38-bartowski-mendel-xhigh` does not run.

## `qwen38-bartowski-mendel-xhigh`

Mendel blind at **effort xhigh**, this model's own published default,
on the 4-bit build: the like-for-like pair for the ISTA row's 80.5.
Fixed: the `benchy-qwen38-bartowski-drafter` server, prompt blind
v1.1, base commit `2652ed6`. Derived: window **65536**, the clean
depth 65578 of the bench 12 creep at 25000, the window the medium
re-run used.

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=65536 ./run-worker.sh qwen3.8-27b pi blind xhigh
```

Branch `qwen3.8-27b-xhigh-issue-13`; no branch of that name exists.
The watcher runs with `RUNWATCH_SILENCE=2700`. Score per `PLAN.md`.
The config note carries the files, revision, `f16 KV`, `-c 73728`,
drafter n-max 3, window 65536, harness reserve 8192, `wired 25000`,
and the temperature and top_p read from the run's `meta.json`. Verify
`peak_context` with the counter before the row commits. The 300-minute
wall gives a partial, which is a row and not a failure.

## `retry-sweep`

The run's killed or interrupted rows, oldest first, in fresh
worktrees, while the owner is away. A row that ended on the model's
own repetition loop is a valid partial and is not retried.

## Not in this run

- Gemma-26B, Gemma-12B and Bonsai, on any block.
- The no-drafter arm of Qwen3.6 q8_0 and of the bartowski build; the
  drafter arm of Qwen3.6 f16. Later runs, if the numbers here ask for
  them.
- Polyglot, parked by the owner.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
dropped and why, machine state left behind, evidence archived. The
coordinator adds the findings to
`hardware/m1-max-32gb/benchmarks/INDEX.md`, writes `report.md`, writes
the final derived values into `models.json` and the site, and
publishes.
