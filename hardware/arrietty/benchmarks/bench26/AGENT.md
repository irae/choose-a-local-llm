# Run 26 — the ternary Bonsai 2 27B at f16 KV

Starts when the coordinator says the card is free. One model serves on
this card at a time. About half a day of machine time. The list below
is the order and the run ends when the list ends or the owner says
stop.

You are the runner, on the Linux machine. Read this file, then the
pages each block names at its start, and nothing else. Write all prose
in ASD-STE100 Simplified Technical English.

## Wakeup, every 20 minutes (mandatory)

**Before any other action, schedule `ScheduleWakeup` with 1200
seconds. At every wakeup, schedule the next one. Do this from the
first action to the end of the run, also while a background task, a
`Monitor` or `run-watch.sh` runs** (owner rule, 2026-09-15,
`docs/methodology/checklist.md`, step 7).

The majority of agents that thought a background task was enough were
wrong, and their runs stalled until a person came back. The wakeup is
also for human inspection: at every wakeup send the short status line
(`docs/methodology/status-lines.md`), so the owner can read the run at
any time. A wakeup with nothing new still sends its line and schedules
the next one.

## What this run is for

The owner's word (2026-09-18): the same file run 24 measured at q8_0,
served at **f16 KV**, to get its window, its speed curve and one blind
agent row.

Run 24 picked q8_0 because it held the larger window, 212992 against
122880, and every number that build carries was measured at q8_0. f16
is the other half of the pair: a smaller window at a cache the model
reads without quantization error. This run says what that trade buys on
the agent task.

**No EvalPlus and no smoke in this run** (owner, 2026-09-18). The
build already passed both at q8_0: the quality gate scored 0.982/0.939
and the smoke passed with one commit and no loop, on the same file, the
same fork binary and the same level. The KV type is a serving
parameter, not a different model, so the gates are not repeated. The
blind row runs on the strength of those.

**This run measures; it decides nothing.**

## The order

**This list is the order.**

- `machine-setup`
- `bonsai2-pq2-f16-kvpick`
- `sweep-bonsai2-pq2-f16`
- `bonsai2-pq2-mendel-blind-xhigh-f16`
- `retry-sweep`

## Essentials

- `bench26/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION after the wakeup:** `cd
  ../choose-a-local-llm-run26`, the worktree the coordinator prepared
  for you on branch `run26`. Verify with `pwd` and `git worktree
  list`. If it does not exist: `git fetch origin && git worktree add
  ../choose-a-local-llm-run26 -b run26 origin/master`. Every command of
  this run happens there.
- **Branches, exactly.** You work on `run26` and only on `run26`. To
  take an update: `git fetch origin && git merge origin/master`, then
  push `run26`. Never check out `master`, never merge `run26` into
  `master`, never push `master`.
- Then `docs/methodology/checklist.md` and
  `docs/methodology/status-lines.md`, whole, once per session.
- **This machine is Linux, not the Mac.** Read run 19's runbook,
  `hardware/arrietty/benchmarks/bench19/AGENT.md`, section
  "Essentials", from "This machine is Linux" to the end of the list,
  and do the same here.
- **Another run may be paused on this machine.** Never touch another
  run's worktree, branch or processes, and never kill a server you did
  not start.
- **The binary is the publisher's fork**, not the stock llama.cpp:
  release `prism-b10685-7dffb15`, commit `7dffb158d`, already installed
  under `~/.local/share/choose-a-local-llm/` by run 24. `$LLAMA_SERVER`
  in the commands below means that binary. Stock llama.cpp rejects this
  file's packing and makes garbage from a `Q2_0` file, because it has no
  Hadamard activation runtime. Verify the binary answers one real
  request before the first ladder load, and record its version in
  `state.md`. A different fork release is a different serving stack and
  is stop and ask.
- **Effort xhigh**, the model's published default and the level of
  every run 24 row. No other level runs here.
- **No temperature and no sampling parameter is passed to any server.**
  The server applies `min_p 0.05` although the model card publishes
  `0.0`; record what the server applies and carry it in the config
  note.
- Commit on `run26` as results land. Push `run26` at every block close
  and message the coordinator session with the block, the config, the
  result line and the commit id. **No message between pushes** (owner
  rule, 2026-09-11). Every gate and stop-and-ask goes to the
  coordinator with your candidate answer.
- **A recoverable failure is retried at once, inside its block.**
- Archive evidence before a session closes:
  `tools/archive-evidence.sh hardware/arrietty/benchmarks/bench26/results run26`.
- Everything a block writes goes under
  `hardware/arrietty/benchmarks/bench26/results/` or
  `~/.local/share/choose-a-local-llm/`. Nothing under `/tmp`.

## The file

Fixed identity, the same in every block. It is the file run 24 measured,
already in the cache.

| field | value |
|---|---|
| repo | `prism-ml/Ternary-Bonsai-2-27B-gguf` |
| file | `Ternary-Bonsai-2-27B-PQ2_0.gguf` |
| revision | `6ed5e12bf84b7a63069882c91dd9e9218647d17b` |
| size | 7,206,168,928 bytes |
| alias | `bonsai2-27b-pq2-f16` |
| level | xhigh |
| extra body | `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}` |
| KV type | **f16**, fixed: it is what this run is about |
| vision | off, always: `--no-mmproj` |
| drafter | none |

The alias differs from run 24's `bonsai2-27b-pq2` on purpose: the two
rows share a file and differ in the cache type, and the harness entry
carries a different window. Confirm the file is in the cache with `hf
cache ls`; if it is missing, fetch it (authorized, owner 2026-09-17)
and record the sha256.

## `machine-setup`

1. The read-only machine checks of run 19's Essentials. Record
   `vram_start_mb`, `MemAvailable` and `df -h ~`.
2. `$LLAMA_SERVER --version` and one real request against a small `-c`,
   recorded in `state.md`.
3. **The corpus server**: `cd hardware/kamaji/research/run4/results &&
   python3 -m http.server 8089 --bind 127.0.0.1` in the background;
   stop it after `sweep-bonsai2-pq2-f16`. The file is
   `corpus-mendel-js.txt`, sha256
   `f4cbe063ef231d753e736b60107b6601705a1acb448b05d9f8b8afbdfcec583c`.
   Check for a stale server on that port first, and never kill another
   run's process.
4. `mkdir -p hardware/arrietty/benchmarks/bench26/results`.

Done: versions and checks in `state.md`, committed. No result table.

## `bonsai2-pq2-f16-kvpick`

Read `docs/methodology/kv-cache-pick.md`.

Only the serving ceiling is open here; the type is fixed. Use run 17's
ladder, `hardware/arrietty/benchmarks/bench17/AGENT.md`, section "The
ladder", steps 1 to 4, with `$LLAMA_SERVER`.

Fixed: the file, `--cache-type-k f16 --cache-type-v f16`,
`--no-mmproj`, `--parallel 1`, `-ngl 999`, `--fit off`, `-fa on`,
`--cache-ram 0` for the measurement only, port 8081. Derived: `-c`.

Planning value for the first load: **122880**, run 24's f16 ceiling for
this file, where 131072 failed. It is a planning value, not a result;
the ladder may find another. A candidate `-c` counts only when one real
request of about that size serves, never a one-token probe.

Write `bonsai2_pq2_f16_c` and the ladder lines in `state.md`.

Done: the ladder and the value in `results.md` and `state.md`. Commit,
push, message the coordinator.

## `sweep-bonsai2-pq2-f16`

Read `docs/methodology/context-creep.md`, "Speed measurement rules".

The creep tool does not run on this machine. Speed comes from
`llama-benchy`, with run 17's command shape,
`hardware/arrietty/benchmarks/bench17/AGENT.md`, section "The benchy
command", `bench26` in every path and `<arm>` equal to `f16`.

Fixed: the file, f16 KV, no drafter. Derived: `-c` from
`bonsai2_pq2_f16_c`; depths 4096, 24576, 65536 and `-c` minus 1024.
Drop any depth above `-c` minus 1024. Tokenizer `unsloth/Qwen3.8-27B`,
as run 24 used.

Write `bonsai2_pq2_f16_clean` in `state.md`: the deepest depth at or
above 8 tok/s. **A table and no pick.**

Done: one table in `results.md`, one line per depth, with tok/s, sd,
prompt tok/s, VRAM used and `MemAvailable`. Commit, push, message the
coordinator. Stop the corpus server.

## `bonsai2-pq2-mendel-blind-xhigh-f16`

Read `docs/methodology/mendel.md`, whole, with "House rules for runs
from this project" and "Comparing two builds of one model".

simulator(mendel) blind, prompt v1.1, base tag `benchmark-blind-base`,
level xhigh. **No smoke precedes this row** (owner, 2026-09-18): the
same file passed its smoke at q8_0 in run 24, on the same binary and
the same level, and only the cache type changed.

Fixed: the serving config of the sweep, without `--cache-ram 0` and
with no reasoning flag. Derived: the window `bonsai2_pq2_f16_window`,
which is `bonsai2_pq2_f16_clean` rounded down to a multiple of 4096, at
or under `-c`, never smaller (owner rule, 2026-09-06); `maxTokens` and
`reserveTokens` 8192; keep budget 8192 under a window of 65536, pi's
default 20000 above it. Write the window and its source in `state.md`
before the row starts.

**Never match run 24's window.** Give this arm the window its own creep
measured (`docs/methodology/mendel.md`, "Comparing two builds of one
model"). A matched window would punish the arm that has less room and
turn a cache difference into a truncation event.

Create or update the pi entry for the alias in the run's pinned config
from these values; a missing harness entry never skips a block.

Before the run: `gh auth status` must pass, and `git stash clear` in
`~/code/mendel-benchmark` (owner rule, 2026-09-12).

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<bonsai2_pq2_f16_window> \
  ./run-worker.sh bonsai2-27b-pq2-f16 pi blind xhigh
```

Row `model` value: `bonsai2-27b-pq2-f16 (prism-ml PQ2_0, xhigh,
arrietty)`; `model_id` the repo and file at the revision; `hardware`
`arrietty`. The config note carries the file and its revision, **the
fork release and commit**, the `-c`, the cache type `f16`, the window,
the reserve, the keep budget, the compaction count, the source block of
each value, `vram 16311 MiB`, the sampling the server applied, the
temperature and top_p from the run's `meta.json`, and the line "no
smoke: the same file passed its smoke at q8_0 in run 24 (owner,
2026-09-18)".

Verify `peak_context` with `benchmark/count-tool-calls.mjs` before the
row commits, and put peak context and the tool-call count in
`results.md` beside the score. A row that ends on a repetition loop is
a valid partial. The 300-minute wall gives a partial, which is a row.
After the run, `pkill -f "Mendel Daemon"`.

Write `bonsai2_pq2_f16_blind` in `state.md` with the score, the
libraries done and the end reason.

**Scoring is not yours to do alone**: it is LLM judgment and runs in a
subagent on the best available model, from the evidence pack, the
session log and the worktree diff, never from the model's own claims.
Tell that subagent to read `CONVENTIONS.md` first and to write in
ASD-STE100 Simplified Technical English.

## `retry-sweep`

The blocks that waited on a human, oldest first.

## Not in this run

- EvalPlus, a calibration, a thinking budget, a smoke. The q8_0 rows of
  run 24 carry those.
- The PTQ1_0 file, the F16 file, the `-dev` repository, the mmproj, the
  MLX build.
- A q8_0 arm, a drafter, any other level, any other model, any weight in
  host RAM.
- Any measurement taken with the stock llama.cpp binary.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
changed and why, machine state left behind, evidence archived. Push and
message the coordinator. The coordinator writes `report.md`, adds the
findings to `hardware/arrietty/benchmarks/INDEX.md`, decides what
reaches the site, and publishes.
