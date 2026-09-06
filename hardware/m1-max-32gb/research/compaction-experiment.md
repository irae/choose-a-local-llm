# Compaction experiment: does a lowered window rescue agent work?

Research design, 2026-09-05. Not started. One model at a time, no
published number. Tool: `benchmarks/mendel-smoke.sh` (`--help`).
Method page: `docs/methodology/mendel.md`, "The smoke".

## The question

pi compacts between turns when `contextTokens > contextWindow -
reserveTokens` (`docs/compaction.md` in the pi package, 0.84.4). The
model under test writes the summary itself, with pi's fixed prompt
(Goal, Constraints, Progress, Key Decisions, Next Steps, Critical
Context, plus read and modified file lists). So a smaller
`contextWindow` trades context for summary quality, and the quality is
the model's own. Three things to learn per model:

1. Does compaction fire, and does the model still commit correct work
   after it (completeness)?
2. How good is the summary it wrote (task, files, next steps kept)?
3. What is the smallest window at which the model still finishes? That
   is a `contextWindow` floor for the model's pi entry. Run 10's open
   item (Qwen3.8 MLX OOM at 26624 in agentic use) needs exactly this.

## Why the two-file smoke cannot do it

pi cuts the history at `keepRecentTokens` (default 20000) and only
writes a compaction when something falls before the cut. A context
under about 20000 tokens is never cut, at any window: `prepareCompaction`
returns nothing and the turn goes on. The two-file smoke stays far
under that line (run 10 block B: 8 calls, 62 s; the system prompt and
tools alone are about 3000-4500 tokens, the fixture is 30 lines). Read
its real peak first, with the verification path on the run 10 smoke
log: `SMOKE_MENDEL_SESSION=<log> benchmarks/mendel-smoke.sh qwen3.8-27b medium`.
If `peak` is under 20000, as expected, the short task is out.

So the experiment uses `SMOKE_MENDEL_TASK=xtend-wide`: the same swap
across ten files of about 250 lines each (92 KB, about 23000 tokens of
reads under `lib/`, two files that must stay untouched, `xtend` and one
other dependency in `package.json`). Same pass rule. Expected peak at
the default window: 28000-40000 tokens for a tidy model, more for a
model that greps and re-reads. It fits the 49152 window with the 8192
reserve, so the baseline run should show `compactions=0`.

Two traps the counters handle. A run with one prompt gets its first
compaction as a split turn ("No prior history", never counted, shown
as `splits=`). And the pinned pi config never inherits the owner's
`reserveTokens` (pi default 16384), so the experiment pins 8192.

## Models

The two that passed the short smoke, then run 10's if they pass:

- Qwen3.8-27B GGUF Q4_K_M, llama-server, f16 KV, `-c 49152`, effort
  medium. pi id `qwen3.8-27b`, `contextWindow` 49152, `maxTokens` 8192.
- Gemma-4-12B, llama-server, f16 KV, thinking off, the run 2 probe arm
  (`hardware/m1-max-32gb/research/run2/results/mendel-probe-xtend.md`, 42 calls, one commit).
- Bonsai MLX thinking off and Gemma-26B GGUF f16, only after their run
  10 smoke line says `pass`.

## The window ladder, per model

1. Baseline: the model's normal window, twice. `P` = the larger `peak`.
   `R` = 8192. Cap 2700 s for the wide task (`SMOKE_MENDEL_CAP`).
2. Rungs: threshold `T = W - R` at 0.8 P, 0.6 P and 0.4 P.
   `W = R + T`, rounded down to a multiple of 1024. Example, P = 32000:
   W = 33792, 27648, 20480.
3. `keepRecentTokens`: pi cannot shrink the context below system prompt
   + summary + this value (about 4000 + 2000 + 20000). On a rung with
   T under 26000 it compacts on every turn instead. So set
   `SMOKE_MENDEL_KEEP_RECENT_TOKENS` to T / 2, rounded down to 1024,
   whenever T is under 26000. Record the value with the row.
4. Two repeats per rung: summaries differ between runs of one model.
   Stop the ladder when a rung fails twice, or when T is under 8192.

## Commands

```bash
export SMOKE_MENDEL_TASK=xtend-wide SMOKE_MENDEL_CAP=2700 SMOKE_MENDEL_RESERVE_TOKENS=8192
EVID=~/.local/share/choose-a-local-llm/evidence/run3-compaction
# baseline, twice
SMOKE_MENDEL_OUT=$EVID/qwen38-w49152-1 benchmarks/mendel-smoke.sh qwen3.8-27b medium 2>&1 | tee $EVID/qwen38-w49152-1.log
# one rung (P = 32000, 0.6 P)
SMOKE_MENDEL_OUT=$EVID/qwen38-w27648-1 SMOKE_MENDEL_CONTEXT_WINDOW=27648 \
  SMOKE_MENDEL_KEEP_RECENT_TOKENS=9216 benchmarks/mendel-smoke.sh qwen3.8-27b medium 2>&1 | tee $EVID/qwen38-w27648-1.log
```

The server keeps its full `-c`; only pi's window shrinks. Keep
`SMOKE_MENDEL_OUT` under the evidence directory, never `/tmp`: the
session log and `summaries.md` are the whole result.

## What to record per run

One row in `hardware/m1-max-32gb/research/compaction-experiment/results.md`:
model, level, `window`, `reserveTokens`, `keepRecentTokens`,
`compactions`, `splits`, `peak`, `calls`, `commits`, `clean`, `end`,
`wall_s`, `verdict`, the count of xtend files the diff fixed (out of
ten, from `git -C <out>/fixture diff HEAD~1 --stat`), and the summary
score below. Keep `<out>/summaries.md` beside the row.

## Scoring the summary

Best tier, one subagent, from `summaries.md` and the fixture's git
diff. Score the last real compaction of the run (a split turn scores
too, marked). Five points:

- Task kept (0-2): names the swap `xtend` to `Object.assign`, the
  no-mutation rule (new empty first argument), and the `package.json`
  removal. One item missing: 1. Two or more: 0.
- Files touched (0-2): the modified-files list and the Done items
  match the files the diff had changed at that point. All: 2. Some: 1.
  None or invented paths: 0.
- Remaining steps (0-1): Next Steps names the files still to do, or
  says commit when all are done.

Beside the score, the outcome after compaction: `finished` (verdict
pass), `partial` (commit but files missed), `lost` (no commit, loop,
or cap). A score of 5 with `lost` is the interesting cell: the
summary was fine and the model still could not resume.

## Cost

The wide task at the normal window: 5-10 minutes for the Qwen3.8 GGUF
pace (8 s per call in block B), 15-25 minutes for a model at the
Gemma-12B pace. Each compaction adds one summary call of 1000-2000
output tokens. Per model: 2 baseline runs + up to 3 rungs x 2 = 8 runs,
about 1.5-3 GPU hours. Four models: 6-12 GPU hours, night blocks.

## Decisions each outcome leads to

- Baseline `compactions=0` and pass, a rung with `compactions>=1` and
  pass twice: that `W` is the model's `contextWindow` floor. Write it
  in the model's pi entry note and the setup page config ("compaction
  verified at W").
- `compactions>=1` at every rung and never a pass after a compaction:
  compaction does not rescue this model. Note on the model's report:
  run it only with `contextWindow >= P + R`, and the run 10 MLX item
  closes as "no smaller window helps".
- `compactions` near the call count on a rung: a compaction storm. The
  rung is below pi's floor; the row is not a model verdict. Halve
  `keepRecentTokens` once, then stop the ladder.
- Baseline `compactions>=1`: the model's normal window is already too
  small for this task. The baseline is rung one; no ladder above it.
- A `splits=1 compactions=0` run that passed: pi wrote only the turn
  prefix summary. Count it as a compaction for the floor decision and
  mark the row.

Summary scores of 4-5 with passes say the model can carry its own
state; scores of 0-2 with `lost` say the summary is the failure, not
the window. Both go to the backlog as a per-model note, never to the
site.
