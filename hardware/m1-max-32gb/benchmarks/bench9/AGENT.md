# Run 9 — KV cache type, daggered sweeps, thinking-off rows (Mac)

You are the runner, on the Mac, during the day with the owner nearby.
Read this file, then the pages it links, and nothing else. Write all
prose in ASD-STE100 Simplified Technical English.

## Why this run exists

Research run 2 found that the KV cache type set the ceiling of a
published llama-server row: Gemma-4-12B at q8_0 KV falls under the
8 tok/s floor by 16K used tokens, and at f16 KV it is still at 13 tok/s
at 131K. Every llama-server row on the site runs q8_0 and is "gated by
speed". This run measures the same question on every other local GGUF,
clears the daggered Qwen3.6 sweep, scores two thinking-off rows, and
re-runs one Mendel row that a harness config error invalidated.

## Read first

1. `benchmarks/bench9/state.md` — what earlier sessions of this run
   did. Resume where its handing-over section says.
2. `docs/methodology/checklist.md` — the run loop. Step 4 is the
   cold-start sequence; step 15 says wired memory is the recovery
   meter.
3. `docs/methodology/context-creep.md` — the depth-sweep method and
   the scripts.
4. `docs/methodology/evalplus.md` — calibrate the budget FIRST.
5. `docs/methodology/common-rules.md` — rule 6 (KV policy) is what
   block A tests.
6. `docs/methodology/server-lore.md` — open it FIRST when a run stalls.
7. `docs/methodology/mendel.md` and `../mendel-benchmark/benchmark/PLAN.md`
   — for the Mendel blocks (B3, C, E).

## Ground rules

- **FIRST ACTION, before anything else:**
  `git worktree add ../choose-a-local-llm-run9 -b run9` (or `cd` into
  it if it exists), then `cd ../choose-a-local-llm-run9`. Verify with
  `pwd` and `git worktree list`. Every command of this run happens
  there — never in `~/code/choose-a-local-llm`.
- Never run a bare `git stash`. Prefer a WIP commit on `run9`. If a
  stash is unavoidable: `git stash push -m "run9: <what>"`, pop by
  name only.
- Then the cold-start sequence, checklist step 4, once for the
  session. The owner is present: ask before the reboot, and skip it
  if they say the machine is already quiet. Set
  `sudo sysctl iogpu.wired_limit_mb=24000` in every case; it resets
  on reboot.
- One model on the GPU at a time. Quit the LM Studio app before any
  llama-server work (`osascript -e 'quit app "LM Studio"'`) and
  confirm with `pgrep -fl "LM Studio"`, never with `lms`.
- The memory watcher runs on scoring blocks only (checklist step 7:
  EvalPlus and Mendel). A depth sweep needs none: the creep runner
  writes wired, free, swap delta and compressor pages into every step
  row, and stops on a dead server by itself.
  Record `Pages wired down` from `vm_stat` before and at the peak of
  every block.
- Heartbeat in chat about every 20 minutes:
  "Block X (model): done a/b, [num]h[num]min left."
- Commit on `run9` as results land: `state.md`, `results.md`, and the
  files under `results/`. Never push a run branch. When the owner asks
  to stop, follow the stop-and-sync steps in `AGENTS.md`.
- Archive evidence before the session closes:
  `tools/archive-evidence.sh benchmarks/bench9/results run9`.
- No downloads. Every model file is in the cache. A missing file means
  STOP and ask the owner.
- Do not change published pages or `models.json`. Write every number
  into `results.md` with the exact command that produced it. The
  coordinator publishes.

## Block A1 — short creep, both KV types, every daggered GGUF

Rule 6 (common rules) decides the KV type per model: research, a short
creep of both types to 32K, the fit prediction, then the full creep on
the pick. The research step is done for these three and is in the
rule: Qwen 3.6 stays near-lossless at q8_0; Gemma-4 does not.

Three models, two short creeps each, published command changed only in
the cache types. Order: Qwen3.6, Qwen3.8, Gemma-26B. Run the q8_0 arm
first each time.

Servers (q8_0 arm shown; the f16 arm replaces both `q8_0` with `f16`).
Use `-c 40960` for the short creeps: enough for 32K plus the prompt,
no memory wasted on a window the creep will not reach.

```bash
# qwen36-gguf
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 40960 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081 --offline 2>&1 | tee benchmarks/bench9/results/server-qwen36-gguf-short-q8.log

# qwen38-gguf
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 40960 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081 --offline 2>&1 | tee benchmarks/bench9/results/server-qwen38-gguf-short-q8.log

# gemma26-gguf
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias gemma-4-26b-a4b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 2 --parallel 1 \
  -ngl 999 -fa on -c 40960 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081 --offline 2>&1 | tee benchmarks/bench9/results/server-gemma26-gguf-short-q8.log
```

Warm up with one short completion, then (MODEL is
the alias above; file names follow the server log's):

```bash
DEPTH_LIST="4096,8192,16384,24576,32768" MODEL=<alias> \
python3 tools/sweeps/creep_llama.py \
  | tee benchmarks/bench9/results/creep-<slug>-short-<kv>.tsv
```

After each arm: grep the server log for `draft acceptance`, read
`wired_mb` at the 4K and 32K rows of the sweep output, stop the
server, and wait until wired memory is back to the pre-load value.

Then apply rule 6 steps 3 and 4 for each model and write the
arithmetic into `results.md`: `kv_per_token`, the predicted wired at
the trained window and at the published context, and the pick. The
pick rule again, so nothing is left to judgment:

- f16 fits at a useful context AND is faster at 32K → **f16**.
- Rule 6 step 1 says q8_0 costs this model quality (Gemma-26B) → **f16**
  if it fits at any context of 32K or more.
- f16 does not fit at a useful context → **q8_0**.
- Curves within 10% at 32K and both fit → **q8_0**.
- Fit within 1500 MB of the limit, or curves crossing → **both** in
  block A1b.

Expected cost: about 20 minutes per arm, six arms.

## Block A1b — full creep on the pick

For each model, the published command (its published `-c`) with the
picked cache type, and the full depth list:

```bash
DEPTH_LIST="4096,8192,16384,24576,32768,49152,65536,81920,98304,114688,131072,147456,163840,180224,196608,212992,229376,245760,262144" \
MODEL=<alias> python3 tools/sweeps/creep_llama.py \
  | tee benchmarks/bench9/results/creep-<slug>-full-<kv>.tsv
```

The runner stops on its own at the floor, at OOM, or at the window;
never earlier. If the picked type fails to load at the published `-c`
(Metal OOM in the server log), lower `-c` to the largest value the
fit prediction allows and record it. Where block A1 said "both", run
the full creep on both types.

Qwen3.6 first: it is the daily driver and its row is daggered. Then
Qwen3.8 GGUF and Gemma-26B GGUF, both daggered too.

Done means, per model: the short-creep table (depth, q8 tok/s, f16
tok/s, wired q8 / f16, acceptance), the prediction arithmetic, the
pick with its reason, and the full curve with its verdict (speed, OOM,
window), all in `results.md`, committed.

Expected cost: 1 to 1.5 hours per full creep.

## Block B0 — EvalPlus smoke on the two f16 picks (day, before B1)

This block was added on 2026-09-05 after block A1b closed. Before you
start it: `git pull` on `run9` (this branch now carries master as of
2026-09-04), and `git pull` on `benchmark` in `~/code/mendel-benchmark`
(commit `fe6da234`, peak context recomputed; the scorer for blocks B3,
C and E reads it). New material that the rest of this run must follow:

- `benchmarks/evalplus-smoke.py` and the "The smoke" section of
  `docs/methodology/evalplus.md`: the tool this block uses.
- `docs/methodology/mendel.md`: how `tool_calls` and `peak_context`
  are counted, and `benchmark/count-tool-calls.mjs` in the Mendel repo
  that checks a row against its log before commit. Apply it to every
  Mendel row of blocks B3, C and E.
- `AGENTS.md` (root): the smoke tool is listed under the tools; the
  rules you already follow did not change.
- `benchmarks/bench9/results/b1-gemma12-gguf-off.log` and the B1
  calibration file are on this branch from the interrupted run; B1
  starts fresh, as the queue says.

Block A1b moved Qwen3.8 GGUF and Gemma-26B GGUF to f16 KV and to a new
`-c`. Their EvalPlus cells still carry numbers scored at q8_0 KV. The
full re-score is bench 10 work. This block is the gate before it: it
kills a broken f16 config now, or it shows the f16 config is level
with q8_0 on four problems, so the carried number stays honest until
bench 10. Read `docs/methodology/evalplus.md`, section "The smoke",
and the header of `benchmarks/evalplus-smoke.py` first. This is the
first real use of the tool. If it does not work as written, fix it,
keep the four-problem subset and the reading rule, and record every
change in `state.md`.

Rules for every smoke run in this block:

- One server at a time, port 8081, warm up with one real completion
  before the first smoke. Wait for wired memory recovery between
  servers (`vm_stat` `Pages wired down` at or under 112000).
- Same budget on both sides of a pair. Never calibrate the candidate.
- `SMOKE_OUT=benchmarks/bench9/results/smoke-<label>` for every run,
  so the samples land in evidence.
- Write every `SMOKE` line and the verdict (level, better, worse, no
  verdict) into `results.md` under a "Block B0" heading, with the
  exact command. A difference of one problem is one problem out of
  four; never a percentage.

### Qwen3.8-27B GGUF: f16 twice, then q8_0

The GGUF row has no EvalPlus of its own; the site carries the MLX
effort-medium number. The budget comes from that calibration,
`benchmarks/calibration-qwen38-mlx-medium.json` (same model, same
effort; it converged, max 2604 tokens, so the tool computes 8192).
Pass the same effort control the MLX full runs used, as the tool's
extra-body argument:
`'{"chat_template_kwargs":{"reasoning_effort":"medium"}}'`
(the low run in `benchmarks/bench6/results.md` shows the shape). Both
sides get the same extra body, so the pair is fair even if
llama-server ignores it. Note in `results.md` whether the completion
token counts show the effort control took.

1. Server: the qwen38-gguf command from block A1 with `f16` in both
   cache types and `-c 49152` (the corrected A1b ceiling). Run the
   smoke twice, labels `qwen38-gguf-f16-a` and `qwen38-gguf-f16-b`.
   This is the tool's self-check: the two lines must not read "worse"
   than each other. If they do, stop this block, write what differed,
   and go on to B1.
2. Server: the same command with `q8_0` in both cache types and the
   published `-c 32768`. One smoke, label `qwen38-gguf-q8`.
3. Verdict: f16 (either run) against q8_0.

### Gemma-4-26B-A4B GGUF: f16 against q8_0, thinking on

The published score (0.713/0.701) is thinking on, so this pair is
thinking on too. Its calibration
(`benchmarks/calibration-gemma26-think.json`) has two `length` stops,
so the tool refuses to compute a budget. Pass the full run's budget by
hand: `SMOKE_MAX_TOKENS=30000` on both sides. Problem 129 with
thinking on can run for many minutes per side; that is expected, let
it finish.

1. Server: the gemma26-gguf command from block A1 with `f16` in both
   cache types and `-c 212992` (the corrected A1b ceiling). One
   smoke, label `gemma26-gguf-f16`.
2. Server: the same command with `q8_0` and the published
   `-c 262144`. One smoke, label `gemma26-gguf-q8`.
3. Verdict: f16 against q8_0.

Done means: five `SMOKE` lines in `results.md`, three verdicts, the
tool fixes (if any) in `state.md`, everything committed on `run9`.
A "worse" verdict for an f16 side is a finding, not a stop: write it,
commit, and go on to B1. The coordinator decides the row.

Expected cost: about 40 minutes plus the Gemma thinking time on
problem 129.

## Block B1 — Gemma-12B GGUF thinking off, EvalPlus (first score of the GGUF quant)

The GGUF rows carry the MLX score by the shared-score rule, but MLX
4-bit and unsloth Q4_K_XL are different quantisation schemes. This
scores the GGUF quant for the first time. Server: the published
`gemma-4-12b` command with `f16` in both cache types and `-c 32768`.
Calibrate with `benchmarks/calibrate.py gemma12-gguf-off gemma-4-12b
'{"chat_template_kwargs":{"enable_thinking":false}}'`, budget = max ×
1.5, floor 8192. Then:

```bash
RESULTS_BASE=benchmarks/bench9/results \
EVALPLUS_MAX_NEW_TOKENS=<budget> \
benchmarks/run-humaneval.sh gemma12-gguf-off gemma-4-12b \
  '{"chat_template_kwargs":{"enable_thinking":false}}'
```

Record base, plus, empty, wall. Compare with 0.909/0.872: a difference
over 0.012 means the two quants do not share a score, and the
shared-score rule needs a quant condition.

Expected cost: about 1 hour plus calibration.

## Block B2 — dropped

Run 2's closing Mendel probe showed `gemma-4-12b-it-mlx` loops on the
thought channel in a multi-turn tool task even with thinking off (2679
lines, zero commits), while llama-server with f16 KV and thinking off
made 42 calls and committed working code
(`research/run2/results/mendel-probe-xtend.md`). The LM Studio entry is
an EvalPlus config, not an agent config. No Mendel run on it.

## Block B3 — Mendel guided on Gemma-12B GGUF, thinking off, f16 KV, no drafter

The llama-server path never got a scored agent row. Start the
published `gemma-4-12b` command with `f16` in both cache types (keep
`-c 262144` and the drafter at n-max 4), warm up, start the memory
watcher (this is a scoring run), then:

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh gemma-4-12b pi guided off
```

Score as in block C. The row's config note must say `f16 KV, no MTP`,
because the published row says q8 with the drafter.

Expected cost: up to 5 hours. Night run.

## Block C — Bonsai MLX, Mendel with thinking off

Owner decision of 2026-09-03: Bonsai Mendel runs use thinking OFF. It
is the published best row (0.927/0.902) and the only level besides
`high` the stack can reach. The `off` slugs do not exist yet, so the
worker will not abort.

Server: none to start by hand; the worker starts what its pi entry
needs. Check `~/.pi/agent/models.json` has the
`prism-ml/Ternary-Bonsai-27B-mlx-2bit` entry with `"off": "off"` in
`thinkingLevelMap` before you start.

```bash
cd ~/code/mendel-benchmark/benchmark
./run-worker.sh prism-ml/Ternary-Bonsai-27B-mlx-2bit pi guided off
```

Then the blind run, `pi blind off`. Score each in a subagent on the
Fable model (`claude-fable-5`) exactly per PLAN.md "How to score a
run", one new row per run, `generate-report.mjs` (`--guided` for the
guided one), commit and push the `benchmark` branch. Record the row
totals in `results.md`. After each run: `pkill -f "Mendel Daemon"`,
clean per PLAN.md "Cleanup", keep the branch.

Expected cost: up to 5 hours per run. Start only if the owner says
the machine is free for the night.

## Block E — Qwen3.8 MLX, the harness fix and the invalid guided row

Run 7's Qwen3.8 guided low row is invalid: three Metal OOM crashes,
zero commits. Research run 2 found the cause in the harness entry:
`maxTokens` 16384 plus `contextWindow` 26624 cannot both fit once a
prompt passes 10240 tokens (`research/run2/results/config-proposals.md`,
P1). The ceiling re-probe put the real limit between 26708 and 28672,
so the window stays.

1. Back up and edit the owner's harness config:
   ```bash
   cp ~/.pi/agent/models.json ~/.config/choose-a-local-llm/models.json.bak-$(date +%Y%m%d)
   ```
   In `~/.pi/agent/models.json`, provider `mlx`, entry
   `mlx-community/Qwen3.8-27B-4bit`: set `"maxTokens": 8192`. Leave
   `contextWindow` at 26624. Record the diff in `state.md`.
2. The invalid run's branch exists locally and blocks the worker. An
   invalid run does not occupy the slot (PLAN.md), so rename it, do
   not delete it:
   ```bash
   git -C ~/code/mendel branch -m \
     mlx-community-Qwen3.8-27B-4bit-low-guided-v3-issue-13 \
     mlx-community-Qwen3.8-27B-4bit-low-guided-v3-issue-13-attempt1
   ```
3. Run and score as in block C:
   ```bash
   ./run-worker.sh mlx-community/Qwen3.8-27B-4bit pi guided low
   ```
   The new row carries `anomaly: "maxTokens 8192 after the run 7
   config error"` so the change is visible on the report. The blind
   low row (67.5 raw, 1/8, valid) is NOT re-run here: a retry of a
   valid row needs the penalty rule the coordinator has not written.

Expected cost: up to 5 hours.

## Order

1. Block A, the creep runs: A1 the six short creeps, A1b the full
   creep on each pick (Qwen3.6 first). A1 plus the Qwen3.6 full creep
   fit one working day.
2. Block B0, the EvalPlus smoke on the two f16 picks (day, short).
3. Block B, the Gemma-12B items: B1 EvalPlus (day), then B3 (night).
   B2 is dropped.
4. Block C, Bonsai Mendel off (nights).
5. Block E, Qwen3.8 guided low (night), last.

Blocks depend on nothing but the GPU. If one is blocked, write why in
`state.md`, commit, and start the next. Mendel runs are one at a time
and never beside a sweep.

## Deferred to bench 10

- Gemma-26B GGUF EvalPlus with thinking off, at the one KV type the
  short creep picks for that model. One arm, not two: the KV pick is
  made in block A1 by the rule, and a quality A/B of the two types is a
  research question, not a bench item.

## After the run

Update `state.md` with a handing-over section: what ran, what did not
and why, machine state left behind (wired limit, widgets, LM Studio,
worktrees), evidence archived. The coordinator adds the findings to
`benchmarks/INDEX.md` and publishes the numbers.
