# Run 26 — Ternary Bonsai 2 27B on the M1 Max 32 GB

Ready to start on the owner's word, 2026-09-18. About one day of
machine time. The list below is the order and the run ends when the
list ends or the owner says stop.

You are the runner, on the Mac. Read this file, then the pages each
block names at its start, and nothing else. Write all prose in
ASD-STE100 Simplified Technical English.

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
any time.

## What this run is for

The owner's word (2026-09-18): the ternary 27B model released on
2026-09-17, on the reference setup, so the site can read it across both
machines. The card measured it first
(`hardware/arrietty/benchmarks/bench24/`).

**This machine is the slow one with the large memory, so the run is
short by design.** It does not repeat the card's matrix. One serving
config per file, chosen for the best speed at depth that still leaves
enough context for the agent task, then the quality gate and the agent
rows on the better of the two.

**The cache is f16 on this machine, always** (owner, 2026-09-18). A
quantized KV cache costs this Mac more speed than it returns, so no
q8_0 arm runs here and no KV pick block exists. The card's q8_0 rows
answer that question for the card, not for this machine.

**This run measures; it decides nothing.**

## The order

**This list is the order.**

- `machine-setup`
- `bonsai2-pq2-ladder-mac`
- `sweep-bonsai2-pq2-mac`
- `bonsai2-ptq1-ladder-mac`
- `sweep-bonsai2-ptq1-mac`
- `bonsai2-calibrate-think-mac`
- `bonsai2-budget-xhigh-mac`
- `bonsai2-forced-rerun-mac`
- `bonsai2-smoke-xhigh-mac`
- `bonsai2-mendel-blind-xhigh-mac`
- `bonsai2-mlx-probe-mac`
- `sweep-bonsai2-mlx-mac`
- `retry-sweep`

The four speed blocks run first, because every speed block runs before
the next agent row (owner rule, 2026-09-14) and because the coordinator
names the file that the last five blocks serve from their tables.

## Essentials

- `bench26/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION after the wakeup:** `git fetch origin && git worktree
  add ../choose-a-local-llm-run26 -b run26 origin/master` (or `cd` into
  it if it exists), then `cd ../choose-a-local-llm-run26`. Verify with
  `pwd` and `git worktree list`. Every command of this run happens
  there.
- **Branches, exactly.** You work on `run26` and only on `run26`. To
  take an update: `git fetch origin && git merge origin/master`, then
  push `run26`. Never check out `master`, never merge `run26` into
  `master`, never push `master`.
- Then `docs/methodology/checklist.md` and
  `docs/methodology/status-lines.md`, whole, once per session.
  `tools/preflight.sh` first, every line `ok` before a block starts.
  Never sudo, never reboot on your own.
- **Wired limit: 25000.** Verify with `sysctl -n iogpu.wired_limit_mb`.
  Any other value is stop and ask.
- One model on the GPU at a time, port 8081. Before you start a server,
  `pgrep -fl "llama-server|mlx_lm"` must be empty. Never kill a server
  you did not start. Quit the LM Studio app first.
- **The downloads of this run are approved** (owner, 2026-09-18), for
  the two files this runbook names and for the fork binary. No other
  download is approved; anything else is stop and ask.
- **The budget message is fixed for the whole run**, in every serve
  command that carries a thinking budget:

  ```bash
  export BUDGET_MSG="Thinking budget reached. Give the final answer now."
  ```

- **No temperature and no sampling parameter is passed to any server.**
  EvalPlus sends temperature 0 itself. Read what the server applies from
  the load log and write it in `state.md`; the card's server applied
  `min_p 0.05` where the model card publishes `0.0`, and every config
  note carries the measured value.
- **Effort xhigh** is the level of every block here. It is the model's
  published default and the level of every card row. The card says `low`
  is not supported.
- **The margin.** `THINKING_BUDGET_MARGIN` is 1.5, the planning value.
- **Count empties from the samples, never from a log line**, and count
  forced answers from `finish.jsonl`. Both commands are in
  `hardware/arrietty/benchmarks/bench24/AGENT.md`, Essentials, with
  `bench26` in place of `bench24`.
- Every scoring run starts `benchmarks/run-watch.sh` as the checklist
  says.
- **Crashes and wall:** `docs/methodology/evalplus.md`, "Crashes and
  wall time". Write every part in `state.md` in UTC.
- Commit on `run26` as results land. Push `run26` at every block close
  and message the coordinator session with the block, the config, the
  result line and the commit id. **No message between pushes** (owner
  rule, 2026-09-11). Every gate and stop-and-ask goes to the coordinator
  with your candidate answer.
- **A recoverable failure is retried at once, inside its block.**
- Archive evidence before a session closes:
  `tools/archive-evidence.sh hardware/kamaji/benchmarks/bench26/results run26`.
- Everything a block writes goes under
  `hardware/kamaji/benchmarks/bench26/results/`,
  `hardware/kamaji/calibrations/` or
  `~/.local/share/choose-a-local-llm/`. Nothing under `/tmp`.

## The files and the server

Repo `prism-ml/Ternary-Bonsai-2-27B-gguf` at revision
`6ed5e12bf84b7a63069882c91dd9e9218647d17b`, Apache 2.0, architecture
`qwen35`, trained context 262144.

| id | file | size | alias |
|---|---|--:|---|
| larger pack | `Ternary-Bonsai-2-27B-PQ2_0.gguf` | 7,206,168,928 B | `bonsai2-27b-pq2-mac` |
| dense pack | `Ternary-Bonsai-2-27B-PTQ1_0.gguf` | 5,946,648,928 B | `bonsai2-27b-ptq1-mac` |

The two files hold the same ternary weights and differ only in how they
store a trit: 2.13 bits per weight against 1.75. The publisher reports
no quality difference and picks between them by hardware, and names
`PQ2_0` as "the pack measured on Apple Silicon".

**This model does not run on the llama.cpp this Mac uses.** Stock
llama.cpp rejects both packings and makes garbage from a `Q2_0` file,
because it has no Hadamard activation runtime. The build comes from
`PrismML-Eng/llama.cpp`, the same fork the card used, at a **Metal**
build for this machine; the card's CUDA asset does not run here.

**Prove the binary before any measurement**: serve the larger pack at a
small `-c`, send one chat completion with `curl`, thinking on at xhigh,
and record the answer. Garbage text, an empty answer, an `unknown type`
line, or a refusal to load is **stop and ask**, and no block starts.
Record the fork's release and commit in `state.md`; they belong in the
config note of every row this run makes.

**Check the thinking-budget flags**: `$LLAMA_SERVER --help | grep -A1
reasoning-budget`. Both flags present: the run is as written. Either
missing: `bonsai2-budget-xhigh-mac` becomes a natural run at
`EVALPLUS_MAX_NEW_TOKENS=30000` with no reasoning flag,
`bonsai2-forced-rerun-mac` does not run, and you write the deviation
and tell the coordinator at the block close.

## `machine-setup`

Read `docs/methodology/evalplus.md`, whole, with "Unproven yet".

1. `tools/preflight.sh`, every line `ok`. Record the wired limit.
2. `git log --oneline -1 -- benchmarks/thinking-budget.py
   benchmarks/calibrate.py benchmarks/run_codegen_wrapper.py`; all
   three present, `calibrate.py` writes `reasoning_len`.
3. `export EVALPLUS_PYTHON=...`; `evalplus.codegen --help | head -2`.
4. Fetch the two files and the fork binary, then do "The files and the
   server" checks. Record each sha256 and each size, and compare the
   sizes with the table.
5. **The corpus server**: `cd hardware/kamaji/research/run4/results &&
   python3 -m http.server 8089 --bind 127.0.0.1` in the background;
   stop it after `sweep-bonsai2-ptq1-mac`. The file is
   `corpus-mendel-js.txt`, sha256
   `f4cbe063ef231d753e736b60107b6601705a1acb448b05d9f8b8afbdfcec583c`.
6. `mkdir -p hardware/kamaji/benchmarks/bench26/results`.

Done: every version, hash, the fork's commit and the probe answer in
`state.md`, committed. No result table.

## The ladder blocks

`bonsai2-pq2-ladder-mac` and `bonsai2-ptq1-ladder-mac`, one per file.

Read `docs/methodology/memory-ceiling.md` and
`docs/methodology/context-creep.md`, "Steps", item 1.

Fixed: the file, `--cache-type-k f16 --cache-type-v f16`,
`--no-mmproj`, `--parallel 1`, no drafter, `-fa on`, port 8081,
`--cache-ram 0` for the measurement only. Derived: `-c`.

Find the largest `-c` that loads **and serves one real request of about
that size**, under the wired limit, by the method of the memory-ceiling
page. A one-token probe proves nothing. On this machine a server that
passes a small probe can still die on the first deep request, so the
deep cell of the matching sweep is the proof.

Planning note, not a result: the card holds `-c 212992` on the larger
pack and 245760 on the dense pack at q8_0, and 122880 and 139264 at
f16. This Mac has more memory and a lower bandwidth, so the ceiling
here is a memory question and the speed at depth is the real limit.
Start at `-c 262144`, the trained context, and step down.

Write `<alias>_c` and the ladder lines in `state.md`.

Done: the ladder in `results.md` and `state.md`. Commit, push, message
the coordinator.

## The sweep blocks

`sweep-bonsai2-pq2-mac` and `sweep-bonsai2-ptq1-mac`.

Read `docs/methodology/context-creep.md`, "Speed measurement rules" and
"How a sweep runs". On this machine the creep tool runs, unlike on the
card; use it, and keep its whole output.

Fixed: the file, f16 KV, no drafter, the `-c` of its ladder. Depths:
4096, 24576, 65536, 98304, then every 32768 to `-c` minus 1024.

The usability floor is 8 tok/s. **Record where the curve crosses it**,
not only the endpoints: that crossing is what this run is for, because
the agent task needs about 46K and the site's window rule takes the
deepest clean depth.

Write `<alias>_clean` in `state.md`: the deepest depth at or above the
floor. **A table and no pick.** The coordinator names the file the
last five blocks serve.

Done: one table per file in `results.md`, with tok/s, wired MB, swap
delta and compression pages per step. Commit, push, message the
coordinator. Stop the corpus server after the second sweep.

## The quality and agent blocks

They serve **one file**: the one the coordinator names at the close of
the second sweep, with its own `-c` and its own window. Do not start
them before that name arrives; if it has not arrived when the sweeps
close, take the file with the deeper clean depth, write that reason in
`state.md`, and go on.

- `bonsai2-calibrate-think-mac`: calibration name
  `bonsai2-<pack>-mac-xhigh-think`, extra body
  `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}`, served at
  `-c 32768` with no budget flag. Then `thinking-budget.py derive`.
  Write the three budgets in `state.md`. A converged row with an empty
  answer is not converged; the tool drops it, and you write its task id,
  its reasoning length and its wall time in `state.md`.
- `bonsai2-budget-xhigh-mac`: the full 164 at the derived budget, at
  `-c 32768`, with the watcher running. The card scored 0.982/0.939 at
  a 25209 budget with 7 forced answers, for reading against.
- `bonsai2-forced-rerun-mac`: the natural re-run of the forced failures
  at `EVALPLUS_MAX_NEW_TOKENS=30000`, by run 21's block shape
  (`hardware/arrietty/benchmarks/bench21/AGENT.md`, "The forced re-run
  blocks"), with `bench26` paths.
- `bonsai2-smoke-xhigh-mac`: `docs/methodology/mendel.md`, "The smoke".
  The window is `<alias>_clean` rounded down to a multiple of 4096, at
  or under `-c`, never smaller (owner rule, 2026-09-06). A fail means
  the blind row does not run.
- `bonsai2-mendel-blind-xhigh-mac`: simulator(mendel) blind, prompt
  v1.1, base tag `benchmark-blind-base`, level xhigh, gated on the
  EvalPlus base pass@1 at 0.800. `gh auth status` must pass and `git
  stash clear` in `~/code/mendel-benchmark` first. Row `model` value:
  `bonsai2-27b-<pack>-mac (prism-ml <PACK>, xhigh, kamaji)`. The config
  note carries the file and revision, **the fork release and commit**,
  the `-c`, `f16` KV, the window, the reserve, the keep budget, the
  compaction count, the wired limit and the sampling the server applied.
  Verify `peak_context` with `benchmark/count-tool-calls.mjs`, and score
  it in a subagent on the best available model, from the evidence pack,
  the session log and the worktree diff, never from the model's own
  claims.

## The MLX blocks (owner, 2026-09-19)

Speed only, to compare the MLX pack with the two GGUF packs on this
machine. No EvalPlus, no smoke, no agent row on it.

| item | value |
|---|---|
| repo | `prism-ml/Ternary-Bonsai-2-27B-mlx-2bit` |
| revision | `3f926b415992eaa2ae9dd7b573706494d6bbf787` |
| `model.safetensors` | 8595477990 bytes |
| server | stock `mlx_lm.server`, no fork |
| packages | the pins of the pack's `runtime/requirements.txt`: `mlx==0.32.0`, `mlx-lm==0.31.3` |
| cache | f16, the only choice: the pack has one weight format |
| alias | `bonsai2-27b-mlx` |

Install the two pins in a new venv, not in the EvalPlus venv. Record
`pip freeze` of that venv in `state.md`.

**The publisher's warning.** The pack stores rotated weights and
declares `model_type: prism_hadamard_qwen35`. The publisher says a
stock MLX loader skips the activation transform and gives wrong output
with no error, and its demo refuses to serve this pack. The owner chose
the stock server anyway. The probe below decides whether the speed
cells mean anything.

Server command, always with a bounded prompt cache (a pooled cache
gave a false OOM on the earlier generation of this model):

```bash
<venv>/bin/python -m mlx_lm.server --model <pack dir> \
  --prompt-cache-size 2 --port 8081 > results/server-mlx.log 2>&1
```

### `bonsai2-mlx-probe-mac`

1. Download the pack at the revision above. Check the byte count.
2. Start the server. Read `docs/methodology/memory-ceiling.md` for the
   MLX memory reading.
3. Send three prompts at temperature 0, `max_tokens` 256: "What is
   17*23? Answer with the number only.", "Write a Python function that
   reverses a string.", and "Name the capital of France."
4. Record each answer verbatim in `results.md`.

**Gate.** All three answers coherent and correct: go on to the sweep.
Any answer garbage, empty, a loop or wrong: stop this block and the
next one, stop the server, write a stop-and-ask in `state.md` with the
answers and message the coordinator. Do not sweep a model that gives
wrong output, because its speed is not the model's speed. A load error
on `prism_hadamard_qwen35` is the same stop.

### `sweep-bonsai2-mlx-mac`

Read `docs/methodology/context-creep.md`, "How a sweep runs", and the
`mlx` backend. Run `creep.py mlx` with `SERVER_LOG` set, pause 60 s,
the same depths as the GGUF sweeps: 4096, 24576, 65536, 98304, then
every 32768. `mlx_lm.server` has no `-c`, so run until the first of:
decode under 8 tok/s, swap growth, a server death, or 262144.

The ceiling is the deepest clean depth. Write `bonsai2_mlx_mac_clean`
and the window `bonsai2_mlx_mac_window` in `state.md`: the clean depth
minus 5 percent, rounded down to a multiple of 4096 (owner,
2026-09-19). No agent row uses the window; it is recorded for the
comparison.

Done: one table in `results.md` with tok/s, wired MB, swap delta and
compression pages per step, beside the two GGUF sweeps at the same
depths. Stop the server. Commit, push, message the coordinator.

## `retry-sweep`

The blocks that waited on a human, oldest first.

## Not in this run

- Any q8_0 or other quantized KV arm. f16 is the cache of this machine.
- A second serving config per file beyond its ladder and its sweep.
- A drafter, the F16 file, the `-dev` repository, the mmproj, LM
  Studio.
- EvalPlus, a smoke or an agent row on the MLX pack. It is measured
  for speed only (owner, 2026-09-19).
- A guided agent row (owner, 2026-09-18). Every agent row of this
  project on this model is blind.
- Any measurement taken with a stock llama.cpp binary.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
changed and why, machine state left behind, evidence archived. Push and
message the coordinator. The coordinator writes `report.md`, adds the
findings to `hardware/kamaji/benchmarks/INDEX.md`, decides what reaches
the site, and publishes.
