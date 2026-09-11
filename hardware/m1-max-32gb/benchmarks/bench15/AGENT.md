# Run 15 — two repeats on the local leaders, then the f16 arm (Mac)

Ready to start, 2026-09-11. About eight hours of machine time.

You are the runner, on the Mac. Read this file, then the pages each
block names at its start, and nothing else. Write all prose in
ASD-STE100 Simplified Technical English.

## What this run is for

The two best local agent rows each rest on one Mendel run: the 4-bit
Qwen3.8 at effort xhigh scored 93, the ISTA 3-bit build at xhigh
scored 80.5. One run of this task moves by ten points between draws,
so one reading does not order them. This run draws each once more on
the same server and the same window, so the homepage can rank them
on two readings each. Then it scores the Qwen3.6 f16 arm without its
drafter, the only Qwen3.6 GGUF row with no agent score, on the window
that arm serves.

## The order

**This list is the order.**

- `bartowski-smoke-xhigh-r2`
- `bartowski-mendel-xhigh-r2`
- `ista-smoke-xhigh-r2`
- `ista-mendel-xhigh-r2`
- `qwen36-f16-smoke-on`
- `qwen36-f16-mendel-on`
- `retry-sweep`

If the run falls behind, drop from the tail: `qwen36-f16-mendel-on`
first. The two repeats are what the run is for.

## Essentials

- `bench15/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION:** `git worktree add ../choose-a-local-llm-run15 -b
  run15` (or `cd` into it if it exists), then `cd
  ../choose-a-local-llm-run15`. Verify with `pwd` and `git worktree
  list`. Every command of this run happens there.
- **Branches, exactly.** You work on `run15` and only on `run15`. The
  coordinator works on `master`. To take an update: `git fetch origin
  && git merge origin/master`, then push `run15`. Never check out
  `master`, never merge `run15` into `master`, never push `master`.
- Then `docs/methodology/checklist.md`, whole, once per session.
  `tools/preflight.sh` first, every line `ok` before a block starts.
  Never sudo, never reboot on your own.
- **Wired limit: 25000.** Verify with `sysctl -n iogpu.wired_limit_mb`.
  Any other value is stop and ask. Every note carries `wired 25000`.
- One model on the GPU at a time, port 8081. Before you start a
  server, `pgrep -fl llama-server` must be empty. Never kill a server
  you did not start. Quit the LM Studio app first and confirm with
  `pgrep -fl "LM Studio"`; its model cache is the owner's and is never
  touched.
- **No temperature and no sampling parameter is passed to any
  server**, on any block. The server's own default is the serving
  sampling. Read the values the run actually used from the run's
  `meta.json` and put them in every row's config note.
- **Effort medium is banned for Qwen3.8** (owner rule, 2026-09-09).
  No block names it.
- **A repeat runs under a fresh alias.** The worker derives the branch
  and the row's model field from the pi id, and refuses a branch that
  exists. Each block below names its alias; the server's `--alias`
  and the pi entry carry that exact value. The three aliases of this
  run are in the site data already: after the first
  `git merge origin/master`, run `npm run pi:models` in the run
  worktree; it writes every entry from `docs/setups/*/models.json`
  and says which thinking map to copy by hand from the sibling entry
  of the same provider. Never edit `~/.pi/agent/models.json` in any
  other way.
- **Harness values are per run.** The worker builds its own pinned
  config.
- `gh auth status` must pass before any Mendel smoke.
- Every scoring run starts `benchmarks/run-watch.sh` as the checklist
  says, with `RUNWATCH_SILENCE=2700` on every Qwen3.8 xhigh row.
- **Scoring and publishing are one task.** One subagent on the best
  available model, per row, on a scratch path of its own that no
  other subagent shares, does all of it: scores per `PLAN.md`,
  writes the `results.json` entry with its matrix cells, regenerates
  `results.csv` and `report.html`, commits to `~/code/mendel-benchmark`
  on branch `benchmark` and pushes. The row's `model` value is the
  alias plus the build and level in parentheses, the shape of the run
  14 rows. A bug in a run tool goes to a subagent on the best model at
  once; the run does not wait for it.
- Commit on `run15` as results land. Push at every block close and
  message the coordinator session "local-llm
  manager/coordinator/orchestrator" with the block, the config, the
  result line and the commit id. Never run a bare `git stash`.
- Every gate and every stop-and-ask goes to the coordinator session
  with the block, the condition and your candidate answer. Keep the
  GPU busy with the next block that does not depend on it.
- Status lines follow `docs/methodology/status-lines.md`. Archive
  evidence before a session closes:
  `tools/archive-evidence.sh hardware/m1-max-32gb/benchmarks/bench15/results run15`.
- Nothing of an interrupted run is cleaned up mid-run
  (`docs/methodology/mendel.md`, "No cleanup mid-run").

## `bartowski-smoke-xhigh-r2`

Read `docs/methodology/mendel.md`, "The smoke". Serve the 4-bit build
exactly as run 14 did, under the new alias. Fixed:
`bartowski/Qwen3.8-27B-GGUF:Q4_K_M` rev `f0eec4a`, `--no-mmproj`, f16
KV, drafter `--spec-type draft-mtp --spec-draft-n-max 3`, `--parallel
1`, `-c 73728`, wired 25000.

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b-r2 --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 73728 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench15/results/server-bartowski-r2.log
```

pi entry `qwen3.8-27b-r2`: provider `llama`, `contextWindow` 65536,
`maxTokens` 8192, the same table as `qwen3.8-27b`.

```bash
benchmarks/mendel-smoke.sh qwen3.8-27b-r2 xhigh 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench15/results/mendel-smoke-bartowski-r2.log
```

Pass is one commit, clean tree, no repetition loop, inside the cap.
A fail means `bartowski-mendel-xhigh-r2` does not run; write the
smoke line and go on.

## `bartowski-mendel-xhigh-r2`

The second draw of the 93. Mendel blind at **effort xhigh**, the
model's own published default. Fixed: the `bartowski-smoke-xhigh-r2`
server, prompt blind v1.1, base commit `2652ed6`. Derived: window
**65536**, the same window as the first draw (run 14).

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=65536 ./run-worker.sh qwen3.8-27b-r2 pi blind xhigh
```

Branch `qwen3.8-27b-r2-xhigh-issue-13`; no branch of that name
exists. The watcher runs with `RUNWATCH_SILENCE=2700`. Row `model`
value: `qwen3.8-27b-r2 (bartowski Q4_K_M, xhigh, second draw)`. The
config note carries the files, revision, `f16 KV`, `-c 73728`, drafter
n-max 3, window 65536, harness reserve 8192, `wired 25000`, and the
temperature and top_p read from the run's `meta.json`. Verify
`peak_context` with the counter before the row commits. The
300-minute wall gives a partial, which is a row and not a failure.

## `ista-smoke-xhigh-r2`

Serve the ISTA build exactly as run 13 did, under the new alias.
Fixed: `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp` rev
`d562806`, `--no-mmproj`, f16 KV, no drafter, `--parallel 1`,
`-c 163840`, wired 25000.

```bash
llama-server -hf ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp \
  --alias qwen3.8-27b-ista-r2 --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 163840 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench15/results/server-ista-r2.log
```

pi entry `qwen3.8-27b-ista-r2`: provider `llama`, `contextWindow`
147456, `maxTokens` 8192, the same table as `qwen3.8-27b-ista`.

```bash
benchmarks/mendel-smoke.sh qwen3.8-27b-ista-r2 xhigh 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench15/results/mendel-smoke-ista-r2.log
```

A fail means `ista-mendel-xhigh-r2` does not run.

## `ista-mendel-xhigh-r2`

The second draw of the 80.5. Mendel blind at **effort xhigh**.
Fixed: the `ista-smoke-xhigh-r2` server, prompt blind v1.1, base
commit `2652ed6`. Derived: window **147456**, the same window as the
first draw (run 13). The long-prompt completion check at 144510
tokens passed on this server in run 13; it does not repeat.

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=147456 ./run-worker.sh qwen3.8-27b-ista-r2 pi blind xhigh
```

Branch `qwen3.8-27b-ista-r2-xhigh-issue-13`; no branch of that name
exists. The watcher runs with `RUNWATCH_SILENCE=2700`. Row `model`
value: `qwen3.8-27b-ista-r2 (ISTA IQ3_S-mtp, xhigh, second draw)`.
The config note carries the files, revision, `f16 KV`, `-c 163840`,
no drafter, window 147456, `wired 25000`, and the temperature and
top_p from the run's `meta.json`. Verify `peak_context` with the
counter before the row commits.

## `qwen36-f16-smoke-on`

Serve the Qwen3.6 f16 arm without its drafter, the server run 14 read
at 49.8 tok/s at 4K and 38.3 at 40K. Fixed:
`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` rev `5bc3e23`,
`--no-mmproj`, f16 KV, no drafter, `--parallel 1`, `-c 40960`, wired
25000.

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b-f16 --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 40960 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench15/results/server-qwen36-f16.log
```

pi entry `qwen3.6-35b-a3b-f16`: provider `llama`, `contextWindow`
32768, `maxTokens` 8192. The window is `-c 40960` minus the 8192
reserve; this task needs about 46K of context, so the harness will
compact. That is the measurement: what this arm's window buys on
the agent task.

```bash
benchmarks/mendel-smoke.sh qwen3.6-35b-a3b-f16 on 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench15/results/mendel-smoke-qwen36-f16.log
```

A fail means `qwen36-f16-mendel-on` does not run.

## `qwen36-f16-mendel-on`

Mendel blind at **thinking on**, the level whose q8_0 row scored 63,
the higher of that row's two levels. Fixed: the `qwen36-f16-smoke-on`
server, prompt blind v1.1, base commit `2652ed6`. Derived: window
**32768**.

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=32768 ./run-worker.sh qwen3.6-35b-a3b-f16 pi blind on
```

Branch `qwen3.6-35b-a3b-f16-on-issue-13`; no branch of that name
exists. Row `model` value: `qwen3.6-35b-a3b-f16 (unsloth UD-Q4_K_XL,
no drafter, on)`. The config note carries the files, revision, `f16
KV`, `-c 40960`, no drafter, window 32768, `wired 25000`, the
compaction count, and the temperature and top_p from the run's
`meta.json`. Verify `peak_context` with the counter before the row
commits. A row that ends on the model's own repetition loop is a valid
partial.

## `retry-sweep`

The run's killed or interrupted rows, oldest first, in fresh
worktrees under a further fresh alias (`-r3`), while the owner is
away. A row that ended on the model's own repetition loop is a valid
partial and is not retried.

## Not in this run

- EvalPlus, on any row. Polyglot, parked by the owner.
- Gemma-26B, Gemma-12B and Bonsai, on any block.
- Any benchy reading; run 14 closed those.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
dropped and why, machine state left behind, evidence archived. The
coordinator adds the findings to
`hardware/m1-max-32gb/benchmarks/INDEX.md`, writes `report.md`, writes
the final derived values into `models.json` and the site, and
publishes.
