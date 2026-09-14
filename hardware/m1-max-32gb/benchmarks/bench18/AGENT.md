# Run 18 — the unsloth 3-bit Qwen3.8 build, the full flow (Mac)

Ready to start, 2026-09-14. One model file, one KV type. About two
days of machine time; the list below is the order and the run ends
when the list ends or the owner says stop.

You are the runner, on the Mac. Read this file, then the pages each
block names at its start, and nothing else. Write all prose in
ASD-STE100 Simplified Technical English.

## What this run is for

The owner's word (2026-09-14): the Linux box runs
`unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S` in run 17, and this Mac already
holds the ISTA 3-bit build of the same model. Both builds are two
providers' trade-offs of one model for the same 12 GB budget. This run
puts the unsloth build through the Mac's full default flow, so the
pair reads across providers on this machine and across machines for
the unsloth build. EvalPlus, smoke and full, runs last (owner,
2026-09-14). Every serving parameter of a later block comes from an
earlier block of this run, by the assignments each block writes into
`state.md`.

## The order

**This list is the order.**

- `machine-setup`
- `ladder-qwen38-unsloth`
- `creep-qwen38-unsloth-nodrafter`
- `sweep-qwen38-unsloth`
- `qwen38-unsloth-serving`
- `qwen38-unsloth-smoke-xhigh`
- `qwen38-unsloth-mendel-blind-xhigh`
- `qwen38-unsloth-mendel-guided-xhigh`
- `qwen38-unsloth-evalplus-smoke-xhigh`
- `qwen38-unsloth-evalplus-xhigh`
- `retry-sweep`

## Essentials

- `bench18/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION:** `git fetch origin && git worktree add
  ../choose-a-local-llm-run18 -b run18 origin/master` (or `cd` into it
  if it exists), then `cd ../choose-a-local-llm-run18`. Verify with
  `pwd` and `git worktree list`. Every command of this run happens
  there.
- **Branches, exactly.** You work on `run18` and only on `run18`. To
  take an update: `git fetch origin && git merge origin/master`, then
  push `run18`. Never check out `master`, never merge `run18` into
  `master`, never push `master`.
- Then `docs/methodology/checklist.md` and
  `docs/methodology/status-lines.md`, whole, once per session.
  `tools/preflight.sh` first, every line `ok` before a block starts.
  Never sudo, never reboot on your own.
- **Wired limit: 25000.** Verify with `sysctl -n iogpu.wired_limit_mb`.
  Any other value is stop and ask. Every note carries `wired 25000`.
- One model on the GPU at a time, port 8081. Before you start a
  server, `pgrep -fl "llama-server|mlx_lm"` must be empty. Never kill
  a server you did not start. Quit the LM Studio app first and confirm
  with `pgrep -fl "LM Studio"`.
- **Downloads.** On the Mac a download needs the owner's approval.
  Approved for this run (owner, 2026-09-14): the one model file named
  in `machine-setup`. Every other model file below is already in the
  cache; a missing one is stop and ask.
- **Fixed on every block:**

| parameter | value |
| --- | --- |
| files | `unsloth/Qwen3.8-27B-GGUF`, `Qwen3.8-27B-UD-IQ3_S.gguf`, revision `4ca720788d1e01f1bff70c033e0d0028fd02e502`, `--no-mmproj` |
| KV type | **f16**, k and v (owner, 2026-09-14: the Mac's pick; the KV pick of 2026-09-04 put Qwen3.8 at f16 here) |
| slots | `--parallel 1` |
| wired | 25000 |
| alias | `qwen3.8-27b-iq3s` |
| agent and EvalPlus level | **xhigh**, the model's published default (owner rule, 2026-09-09) |

- **Effort medium is banned for Qwen3.8** (owner rule, 2026-09-09). A
  speed block reads decode only and names no level.
- **No temperature and no sampling parameter is passed to any
  server.** The server reads its defaults from the file. Read the
  values a simulator(mendel) run used from its `meta.json` and put
  them in the row's config note. This file sets no `min_p`, so the
  server applies its own default; the ISTA file sets `min_p 0.0`. Name
  `min_p` in every config note.
- **The KV bytes per token of this model at f16 are 65,536** (0.0671 GB
  per 1K tokens, run 13). The file is 12.04 GB, 79 MB under the ISTA
  file this Mac serves.
- `gh auth status` must pass before any smoke or agent row.
- **`git stash clear` in `~/code/mendel-benchmark` right before every
  smoke and every agent row** (owner rule, 2026-09-12). Record the
  `git stash list` output before the clear in `state.md`.
- Every scoring run starts `benchmarks/run-watch.sh` as the checklist
  says.
- **Scoring and publishing are one task.** One subagent on the best
  available model, per row, on a scratch path of its own that no other
  subagent shares, does all of it: scores per `PLAN.md`, writes the
  `results.json` or `results-guided.json` entry with its matrix cells,
  regenerates the CSV and the HTML report, commits to
  `~/code/mendel-benchmark` on branch `benchmark` and pushes. **Every
  row of this run carries `"hardware": "m1-max-32gb"` beside
  `serving`, and its `model` value names the machine**:
  `qwen3.8-27b-iq3s (unsloth UD-IQ3_S, xhigh, m1-max-32gb)`. Run 17
  scores the same alias on the Linux box. A zero-commit row the model
  caused is `model-failed` (Mendel `PLAN.md`, "Completion cap, invalid
  runs, and the score line"). A bug in a run tool goes to a subagent on
  the best model at once; the run does not wait for it.
- **Reporting.** Commit on `run18` as results land. Push `run18` at
  every block close and give the owner one line: the block, the
  config, the result line and the commit id. Every gate and every
  stop-and-ask goes to the owner with the block, the condition and
  your candidate answer; the owner relays it to the coordinator. **No
  message between pushes**: no live progress, no status counts (owner
  rule, 2026-09-11). Keep the GPU busy with the next block that does
  not depend on an answer. Never run a bare `git stash`.
- **A recoverable failure is retried at once, inside its block**: a
  dead benchy cell, a server that died under a request, a row the
  machine killed. `retry-sweep` holds only what needed a human.
- Status lines follow `docs/methodology/status-lines.md`. Archive
  evidence before a session closes:
  `tools/archive-evidence.sh hardware/m1-max-32gb/benchmarks/bench18/results run18`.
- Nothing of an interrupted run is cleaned up mid-run
  (`docs/methodology/mendel.md`, "No cleanup mid-run").
- Every file a block writes goes under
  `hardware/m1-max-32gb/benchmarks/bench18/results/` or under
  `~/.local/share/`. Nothing under `/tmp`.

## `machine-setup`

Read `docs/methodology/checklist.md`, "Before the run".

1. **The model file** (download approved, owner, 2026-09-14). Load it
   once through llama-server, which fetches it into its cache:

   ```bash
   llama-server -hf unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S --no-mmproj \
     --alias qwen3.8-27b-iq3s -ngl 999 -fa on -c 4096 --port 8081 2>&1 \
     | tee hardware/m1-max-32gb/benchmarks/bench18/results/server-download.log
   ```

   Stop the server when it has loaded. Find the file
   (`find ~/Library/Caches/llama.cpp ~/.cache/huggingface -name 'Qwen3.8-27B-UD-IQ3_S.gguf'`)
   and record its path as `qwen38_unsloth_path`, the snapshot revision
   the path or the log names as `qwen38_unsloth_rev`, and `shasum -a
   256` of the file as `qwen38_unsloth_sha256` in `state.md`. The Linux
   box holds the same file at revision `4ca7207` with sha256
   `d847e2c1e4aa276e4b7b8e9ad7628050e61e165d49ab995407bc36677a6f3864`.
   A different hash is stop and ask: it is a different file. Every
   later block serves the file with `-m <qwen38_unsloth_path>`.
2. **The sweep tool.** `git -C ~/code/local-llm-eval-tools pull
   --ff-only`, then record `git -C ~/code/local-llm-eval-tools
   rev-parse --short HEAD` as `creep_tool_rev` in `state.md`.
3. **The benchy tool, tokenizer and corpus**: as run 16 recorded them
   in `hardware/m1-max-32gb/research/run4/state.md`
   (`benchy_version`, `benchy_invocation`, `benchy_corpus`). Tokenizer
   `Qwen/Qwen3.8-27B`, already cached. Serve the corpus directory for
   every speed block and stop it after the last one:
   `cd hardware/m1-max-32gb/research/run4/results && python3 -m
   http.server 8089 --bind 127.0.0.1`.
4. **The pi entry and the thinking maps.** Read
   `benchmarks/PLANNING.md`, "A pi thinking map maps down" (owner rule,
   2026-09-14). In `~/.pi/agent/models.json`, provider `llama`, with a
   short python that loads the file, changes only these keys and dumps
   it with `indent=2`:
   - Add an entry with `id` `qwen3.8-27b-iq3s` and `name`
     `Qwen3.8 27B UD-IQ3_S (llama-server)`. Copy every other key from
     the existing `qwen3.8-27b-ista` entry; `contextWindow` is a
     placeholder that the smoke and the worker overwrite in their
     pinned copies.
   - Set the `thinkingLevelMap` of every Qwen3.8 entry, the new one
     included, to `{ "off": null, "minimal": null, "low": "low",
     "medium": "medium", "high": "medium", "xhigh": "xhigh", "max":
     "xhigh" }`. In every other entry of provider `llama`, map each
     level the model does not accept down by the same rule, and change
     nothing else.
   Record every map before and after in `state.md`. Verify with `pi
   --list-models | grep qwen3.8`.
5. `git -C ~/code/mendel-benchmark fetch origin && git -C
   ~/code/mendel-benchmark checkout benchmark && git -C
   ~/code/mendel-benchmark merge --ff-only origin/benchmark`, then
   `gh auth status`.

Done: every path, revision, hash, tool version and map in `state.md`,
committed. No result table.

## `ladder-qwen38-unsloth`

Read `docs/methodology/context-creep.md`, "Steps", step 1, and
`docs/methodology/memory-ceiling.md`. The largest `-c` that loads and
serves a real request, no drafter.

Planning value: 163840, the ceiling of the ISTA file at f16 and wired
25000 (run 13), a file 79 MB larger than this one. The trained window
is 262144.

1. Load at 163840. The load passes when the server answers one real
   4096-token completion with no error in its log (`Insufficient
   Memory`, a Metal OOM, a 500). A load that reports "loaded" and
   fails the request is a fail.
2. On a pass, go up in steps of 16384 toward 262144; on a fail, step
   down by 8192. Then bisect between the last pass and the last fail
   in multiples of 8192. At most six loads in all.
3. Record wired at load for every rung.

```bash
llama-server -m <qwen38_unsloth_path> \
  --alias qwen3.8-27b-iq3s --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c <the rung> \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench18/results/server-ladder-<the rung>.log
```

Write `qwen38_unsloth_c` (the largest passing rung) and
`qwen38_unsloth_wired_load` (its wired at load) in `state.md`. Done:
the ladder table in `results.md`.

## `creep-qwen38-unsloth-nodrafter`

Read `docs/methodology/context-creep.md`, "How a sweep runs". The full
slow creep at `-c <qwen38_unsloth_c>`, no drafter, to a real stop
condition. Serve the ladder command at `qwen38_unsloth_c` with its log
`server-creep-nodrafter.log`, warm it up with one small request, then:

```bash
DEPTH_LIST=<4096,8192,16384,24576,32768, then every 16384 up to qwen38_unsloth_c minus 1024> \
N_CONTEXTS=1 MODEL=qwen3.8-27b-iq3s SWEEP_BASE=http://127.0.0.1:8081 \
  python3 ~/code/local-llm-eval-tools/slow-context-creep/creep.py llama \
  | tee hardware/m1-max-32gb/benchmarks/bench18/results/creep-qwen38-unsloth-nodrafter.tsv
```

A `STOP: generation thread died` or `STOP: server dead` line is a dead
server, not a ceiling: restart the server and continue the creep from
the last verified depth, as step 3 of "Steps" says, inside this block.

Write in `state.md`:

- `qwen38_unsloth_clean`: the deepest step at or above 8 tok/s before
  the STOP verdict, or the last step when no verdict came.
- `qwen38_unsloth_gated`: `speed` for a floor stop, `mem` for any
  memory stop or the trained window, `untested` when the list ended
  with no stop.

Done: the creep as a table in `results.md`, one row per step: depth,
tok/s, wired MB, swap delta, compressed pages. Mac numbers to read
against, the ISTA file at the same settings: 14.1 at 4K, 8.3 at
147478, speed gated.

## `sweep-qwen38-unsloth`

Read `docs/methodology/context-creep.md`, "Speed measurement rules"
and "The order for a model with a drafter", and the benchy command
shape of run 16 (`hardware/m1-max-32gb/benchmarks/bench16/AGENT.md`,
"The benchy command"). Real-text speed for every arm, and the drafter
climb. The file carries the MTP head. On this Mac the drafter lost on
every dense Qwen3.8 build (run 16), and it paid on other models; this
block measures it for this file.

**The drafter arm's `-c` first.** The drafter costs memory, so its
`-c` is smaller. Serve n-max 3, the heaviest arm, at `-c 4096`, and
record wired at load. The estimate is `qwen38_unsloth_c` minus (wired
at load of n-max 3 minus `qwen38_unsloth_wired_load`) divided by
0.0671 GB per 1K tokens, rounded down to a multiple of 8192. Probe the
estimate with one real 4096-token completion, then bisect against
`qwen38_unsloth_c` in multiples of 8192, at most four loads. Write
`qwen38_unsloth_mtp_c`.

**The arms.** Each arm is a fresh server with `--cache-ram 0`:

- `nmax0`, no drafter, at `-c <qwen38_unsloth_c>`, depths 4096,
  `qwen38_unsloth_mtp_c` minus 1024, and `qwen38_unsloth_clean` capped
  at `qwen38_unsloth_c` minus 1024. Read the deepest depth in its own
  benchy call.
- `nmax1`, `nmax2`, `nmax3`: `--spec-type draft-mtp
  --spec-draft-n-max <n>`, at `-c <qwen38_unsloth_mtp_c>`, depths 4096
  and `qwen38_unsloth_mtp_c` minus 1024.

Climb from `nmax1` by "The sweep rule" in run 16's runbook: stop when
an arm reads slower than the arm before it at both shared depths;
after a mixed arm take one more and apply the same test. Compare
`nmax1` against `nmax0` at the two shared depths.

```bash
llama-server -m <qwen38_unsloth_path> \
  --alias qwen3.8-27b-iq3s --no-mmproj --parallel 1 \
  <arm flags> \
  -ngl 999 -fa on -c <qwen38_unsloth_c or qwen38_unsloth_mtp_c> \
  --cache-type-k f16 --cache-type-v f16 --cache-ram 0 \
  --jinja --port 8081 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench18/results/server-sweep-<arm>.log
```

Done: one table in `results.md`, one line per arm and depth: arm,
`-c`, depth, benchy tok/s, sd, acceptance (read the `draft acceptance`
line of the matching request), wired, swap delta. Beside it the ISTA
file's cells from run 16 (14.1 at 4K, 8.1 at 147K, no drafter). **A
table and no pick**; `qwen38-unsloth-serving` applies the rule.

## `qwen38-unsloth-serving`

Not a measurement. This block applies the serving rule decided at
planning time (coordinator, 2026-09-14, from
`docs/methodology/context-creep.md`, "Picking the config a block will
serve", and `docs/methodology/mendel.md`, "Window and budget") to the
tables above, and writes the values every later block reads. Apply it
exactly; it has no judgment in it.

1. **The agent arm.** For each arm the sweep read, take its tok/s at
   depth `qwen38_unsloth_mtp_c` minus 1024. The arm with the highest
   value is the candidate. Its window is:
   - for `nmax0`: `qwen38_unsloth_clean` rounded down to a multiple of
     4096, at or under `qwen38_unsloth_c`;
   - for a drafter arm: `qwen38_unsloth_mtp_c` minus 1024 rounded down
     to a multiple of 4096, when that cell read 8 tok/s or more.
2. **The compaction check.** The ISTA build's blind row at xhigh on
   this Mac peaked at 117,940 tokens. When the candidate's window is
   under 122880 and the `nmax0` window is 122880 or more, the agent arm
   is `nmax0`, because the larger window removes a compaction.
   Otherwise the agent arm is the candidate.
3. **The EvalPlus arm.** The arm with the highest tok/s at depth 4096,
   served at `-c 32768`.

Write `qwen38_unsloth_agent_arm`, `qwen38_unsloth_agent_c` (the `-c`
of that arm), `qwen38_unsloth_window`, `qwen38_unsloth_keep` (8192
when the window is under 65536, else pi's default) and
`qwen38_unsloth_eval_arm` in `state.md`, each with the cells it came
from. Push, and give the owner the values in the block-close line.
Do not wait for an answer.

## `qwen38-unsloth-smoke-xhigh`

Read `docs/methodology/mendel.md`, "The smoke". The first time this
build meets the simulator on this machine. Serve the agent arm:

```bash
llama-server -m <qwen38_unsloth_path> \
  --alias qwen3.8-27b-iq3s --no-mmproj --parallel 1 \
  <qwen38_unsloth_agent_arm flags> \
  -ngl 999 -fa on -c <qwen38_unsloth_agent_c> \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench18/results/server-agent.log
```

```bash
SMOKE_MENDEL_CONTEXT_WINDOW=<qwen38_unsloth_window> benchmarks/mendel-smoke.sh qwen3.8-27b-iq3s xhigh 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench18/results/mendel-smoke-qwen38-unsloth-xhigh.log
```

Pass is one commit, clean tree, no repetition loop, inside the cap.
After the smoke, read its session log for a thinking block on most
turns; none means the level did not reach the server, and that is
stop and ask. **A fail means the two Mendel blocks do not run**: write
the smoke line in `results.md` and go to
`qwen38-unsloth-evalplus-smoke-xhigh`. A server that dies during the
smoke at the window steps `qwen38_unsloth_window` down by 8192, written
in `state.md`, and the smoke runs again inside this block. Write
`qwen38_unsloth_smoke`.

## `qwen38-unsloth-mendel-blind-xhigh`

Read Mendel `PLAN.md` (`~/code/mendel-benchmark/benchmark/PLAN.md`)
and `docs/methodology/mendel.md`. simulator(mendel) blind, prompt
v1.1, base tag `benchmark-blind-base`, on the server of the smoke,
unchanged. Blind first: the Mac's rows of the other Qwen3.8 builds at
xhigh are blind rows (ISTA 80.5, bartowski 93).

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<qwen38_unsloth_window> MENDEL_KEEP_RECENT_TOKENS=<qwen38_unsloth_keep when 8192, else unset> ./run-worker.sh qwen3.8-27b-iq3s pi blind xhigh
```

Branch by the slug the worker forms; no branch of that name exists on
this machine. `model_id` is the repo, the file and the revision. The
config note carries the file, `qwen38_unsloth_rev`, `f16 KV`, the `-c`,
the drafter arm, the window, the reserve 8192, the keep budget, the
compaction count, the source block of each value, `wired 25000`, the
temperature, top_p and `min_p` from the run's `meta.json`, and the line
"EvalPlus runs after the agent rows in this run (owner, 2026-09-14)".
Verify `peak_context` with `benchmark/count-tool-calls.mjs` before the
row commits. A row that ends on the model's own repetition loop is a
valid partial; one with zero commits is model-failed. A server that
dies mid-run is restarted with the same command and the run goes on
in the same session when pi recovers; a row the machine killed is
retried at once in a fresh worktree. The 300-minute wall gives a
partial, which is a row. **If `peak_context` reaches the window, say
so in one line.** Write `qwen38_unsloth_blind` in `state.md` with the
score, the libraries done, the end reason and `peak_context`.

## `qwen38-unsloth-mendel-guided-xhigh`

The same as `qwen38-unsloth-mendel-blind-xhigh`, guided: prompt v3.0,
base tag `benchmark-guided-base`, same server, same window.

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<qwen38_unsloth_window> MENDEL_KEEP_RECENT_TOKENS=<qwen38_unsloth_keep when 8192, else unset> ./run-worker.sh qwen3.8-27b-iq3s pi guided xhigh
```

Write `qwen38_unsloth_guided` in `state.md`.

## `qwen38-unsloth-evalplus-smoke-xhigh`

Read `docs/methodology/evalplus.md`, "The smoke". The candidate is this
build; the config the Mac runs today at this level is the ISTA build
at xhigh, and its budget is the one both sides use:
`hardware/m1-max-32gb/calibrations/calibration-qwen38-ista-mtp-xhigh.json`.
Both sides serve no drafter at `-c 32768`, one side at a time.

```bash
llama-server -hf ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp \
  --alias qwen3.8-27b-ista --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 32768 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline 2>&1 \
  | tee hardware/m1-max-32gb/benchmarks/bench18/results/server-evalplus-smoke-ista.log
SMOKE_CALIBRATION=hardware/m1-max-32gb/calibrations/calibration-qwen38-ista-mtp-xhigh.json \
  benchmarks/evalplus-smoke.py qwen38-ista-xhigh qwen3.8-27b-ista '{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}'
```

Then stop that server, serve this build the same way (`-m
<qwen38_unsloth_path>`, alias `qwen3.8-27b-iq3s`, log
`server-evalplus-smoke-unsloth.log`) and run:

```bash
SMOKE_CALIBRATION=hardware/m1-max-32gb/calibrations/calibration-qwen38-ista-mtp-xhigh.json \
  benchmarks/evalplus-smoke.py qwen38-unsloth-xhigh qwen3.8-27b-iq3s '{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}'
```

Write both `SMOKE` lines and the verdict word from the page (level,
better, worse, or no verdict) in `results.md` and as
`qwen38_unsloth_evalplus_smoke` in `state.md`. The verdict does not
cancel the full run: the full run is the score.

## `qwen38-unsloth-evalplus-xhigh`

Read `docs/methodology/evalplus.md`, whole. Serve
`qwen38_unsloth_eval_arm` at `-c 32768` (log
`server-evalplus-unsloth.log`), then calibrate. The extra body is
mandatory on the calibration and the full run.

```bash
CALIBRATION_DIR=hardware/m1-max-32gb/calibrations benchmarks/calibrate.py qwen38-unsloth-iq3s-xhigh qwen3.8-27b-iq3s '{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}'
```

Check that every row's `resolved_reasoning_effort` reads `xhigh`. The
budget is the observed maximum times 1.5, floor 8192, cap 30000. When
the calibration has `length` stops, the budget is just above the
longest successful completion, and the expected empty rate is written
beside it (the page, step 3). Write `qwen38_unsloth_eval_budget` in
`state.md` with its source. Then:

```bash
RESULTS_BASE=hardware/m1-max-32gb/benchmarks/bench18/results \
  EVALPLUS_MAX_NEW_TOKENS=<qwen38_unsloth_eval_budget> \
  benchmarks/run-humaneval.sh qwen38-unsloth-evalplus-xhigh qwen3.8-27b-iq3s '{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}'
```

Record base, plus, empty and active wall time in `results.md`, beside
the ISTA build's xhigh score on this Mac: 0.945 / 0.921 / 97%, five
empty, budget 30000. Write `qwen38_unsloth_evalplus`. The ISTA run
took about 9h43; the owner may be away when it ends.

## `retry-sweep`

The run's rows that waited on a human, oldest first, in fresh
worktrees. A row that ended on the model's own repetition loop is a
valid partial and is not retried; a model-failed row is not retried.

## Not in this run

- q8_0 KV, any other level than xhigh, effort medium, any other
  model, any vision task.
- A creep of a drafter arm: its speed comes from benchy, because a
  creep's drafter speeds read high (run 13).

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
dropped and why, machine state left behind, evidence archived. The
coordinator adds the findings to
`hardware/m1-max-32gb/benchmarks/INDEX.md`, writes `report.md`, adds
the row to `docs/setups/m1-max-32gb/models.json` with its `pi` block,
writes the final derived values into the owner's harness file, and
publishes.
