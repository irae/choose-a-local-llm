# Run 13 — one build, one cache type: the ISTA 3-bit drafter question, then low against xhigh (Mac)

Ready to start, 2026-09-09. A short run. One model file, one KV type,
one question per block.

You are the runner, on the Mac. Read this file, then the pages each
block names at its start, and nothing else. Write all prose in
ASD-STE100 Simplified Technical English.

## What this run is for

Every Qwen3.8 row this project holds ran at effort medium, a setting
this model is no longer tested at, and no run has ever priced its
drafter. This run fixes both for one build: the deepest and
best-evidenced of the three, `ISTA-DASLab/…:IQ3_S-mtp`.

## The order

**This list is the order.**

- `ista-nmax-shallow`
- `ista-nodrafter-creep`
- `ista-serving-pick`
- `ista-nmax-deep`
- `ista-smoke-xhigh`
- `ista-mendel-xhigh`
- `ista-smoke-low`
- `ista-mendel-low`
- `ista-evalplus-low`
- `ista-evalplus-xhigh`

xhigh runs before low because it is this model's own default and the
more likely to blow the window. If it does, that changes the serving
pick for both, and we would rather learn it first.

If the run falls behind, drop from the tail: `ista-evalplus-xhigh`
first, then `ista-evalplus-low`. This build already has a quality
score, at medium; the agent rows are what it lacks.

## Essentials

- `bench13/state.md` holds what earlier sessions did. Resume where its
  handing-over section says.
- **FIRST ACTION:** `git worktree add ../choose-a-local-llm-run13 -b
  run13` (or `cd` into it if it exists), then `cd
  ../choose-a-local-llm-run13`. Verify with `pwd` and `git worktree
  list`. Every command of this run happens there.
- Then `docs/methodology/checklist.md`, whole, once per session.
  `tools/preflight.sh` first, every line `ok` before a block starts.
- **The machine file is the stale side.**
  `~/.config/choose-a-local-llm/machine.md` still says 24000. The live
  limit and this run are **25000**. Fix that file to 25000; it needs no
  sudo. Never act on preflight's `fix wired-limit` line while it
  disagrees with this run.
- **Effort medium is banned for this model** (owner rule, 2026-09-09).
  No block names it. A block that seems to need it is a planning
  defect: stop and ask.
- **Pull the sweep tool before this run's first creep**, record its
  short hash in `state.md` and beside every sweep result
  (`checklist.md` step 5b). Not a block, and no second pull inside one
  session.
- **This is the first run whose sampling survives.** The worker writes
  to `~/.local/share/mendel-benchmark/` and deletes nothing (Mendel
  `PLAN.md`). Read the temperature and top_p the run actually used out
  of that directory and **put them in every row's config note**. No
  earlier row has them.
- **Fixed on every block:**

| parameter | value |
| --- | --- |
| files | `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, rev `d562806`, `--no-mmproj` |
| KV type | **f16**, k and v, on every block. No q8_0 anywhere in this run. |
| slots | `--parallel 1` |
| wired | 25000 |

- **Already measured, do not re-run:** this build with the drafter at
  `n-max 3`, `-c 131072`, f16, wired 25000: clean depth **114718 at
  9.67 tok/s**, mem stop with swap +429 MB at depth 131098 (research
  run 3). That is step 2 of the drafter order already done.

## `ista-nmax-shallow`

Read `docs/methodology/context-creep.md`, "The order for a model with
a drafter". This is step 1 of that order.

Serve at a fixed `-c 106496` for every cell, so cells differ only in
the drafter. Per cell: start the server, record wired at load, send one
256-token completion at temperature 0 on a coding prompt, record decode
speed, draft acceptance and mean draft length.

| cell | drafter flags |
| --- | --- |
| `none` | no `--spec-type`, no `--spec-draft-n-max` |
| `n1` | `--spec-type draft-mtp --spec-draft-n-max 1` |
| `n2` | `--spec-type draft-mtp --spec-draft-n-max 2` |
| `n3` | `--spec-type draft-mtp --spec-draft-n-max 3` |
| `n4` | `--spec-type draft-mtp --spec-draft-n-max 4` |

```bash
llama-server -hf ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp \
  --alias qwen3.8-27b --no-mmproj \
  <this cell's drafter flags> --parallel 1 \
  -ngl 999 -fa on -c 106496 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 2>&1 | tee hardware/m1-max-32gb/benchmarks/bench13/results/server-ista-nmax-<cell>.log
```

Done: one table in `results.md`, a row per cell with wired at load,
decode tok/s, acceptance and mean draft length. Add one line saying
whether wired moved across the `n1` to `n4` cells. Scores nothing.

## `ista-nodrafter-creep`

Step 3 of the drafter order. Pull the sweep tool first if this is the
session's first creep.

**Estimate before you probe.** This model holds 65,536 bytes of KV per
token at f16, which is 0.0671 GB per 1K tokens. Take the wired
difference between the `none` cell and the `n3` cell from the block
above, divide by that, and add the result to 131072. The planning
estimate is about 2.0 GB freed, so about 30K more tokens, giving about
`-c 160900`.

**Probe once at `-c 163840`, then bisect against 131072**, which the
drafter arm already served. Two rungs is typical. Each rung is a real
4096-token completion, never a one-token probe. Do not climb past
163840: llama.cpp issue 27756 puts a usable ceiling near 128K to 130K
on this model, so memory above that buys nothing servable.

Then the full creep at the largest `-c` that served:

```bash
DEPTH_LIST="4096,8192,16384,24576,32768,40960,49152,65536,81920,98304,114688,131072,147456,163840" \
N_CONTEXTS=1 MODEL=qwen3.8-27b \
  python3 ~/code/local-llm-eval-tools/slow-context-creep/creep.py llama \
  | tee hardware/m1-max-32gb/benchmarks/bench13/results/creep-ista-nodrafter.tsv
```

Done: the ladder table, then the creep as a table with one row per
step: depth, tok/s, wired MB, free MB, swap delta. A sweep that ends
with no stop condition records `gatedBy: untested`, never `mem` or
`speed`, and its deepest step is a list end and not a ceiling.

## `ista-serving-pick`

A task, not a judgment. Read the two blocks above and the measured
drafter row in Essentials, and write `ista_serving` (drafter flags and
`-c`) and `ista_window` in `state.md`.

**The rule** (`context-creep.md`, "Picking the config a block will
serve"): take the faster config at the depth the task actually uses,
**unless the slower one removes a compaction**. The last agent run of
this build peaked at 89386 tokens, so a window above roughly 96K
removes no compaction and buys nothing. Break a tie on decode speed at
that depth.

Write the pick and the one-line reason. If the no-drafter arm is both
deeper and faster at depth, say so plainly: that would overturn the
planning expectation, which is that the drafter wins here.

## `ista-nmax-deep`

Step 4. Same shape as `ista-nmax-shallow`, but at the working depth of
the config `ista-serving-pick` chose, not at 4K. Cells `n1` to `n4`,
skipping `none` if the pick has no drafter.

**Run every cell: `none`, `n1`, `n2`, `n3`, `n4`.** Do not drop cells on
the shallow table's ranking. This build's own server log from research
run 3 shows draft acceptance reaching **1.000 at mean draft length
3.94** at depth, against 68.4% for `n3` at 4K. A cold short prompt is
the drafter's worst case; the agent task never runs there, so the deep
numbers are the only ones that decide.

**This block reports a table and no pick.** `ista-serving-pick` is
where the choice is made, by the coordinator.

## `ista-smoke-xhigh`

Read `docs/methodology/mendel.md`, "The smoke". **The thinking level is
part of the config, so this level needs its own smoke**; the smokes on
record are the 4-bit control's, not this build's.

`benchmarks/mendel-smoke.sh qwen3.8-27b xhigh`, on `ista_serving`,
25-minute cap, unscored. Pass is one commit, clean tree, no repetition
loop, inside the cap. **A fail means `ista-mendel-xhigh` does not run**;
write the smoke line and go to `ista-smoke-low`.

## `ista-mendel-xhigh`

Mendel blind at **effort xhigh**, this model's own published default.
The first row this project will hold of this model at the setting its
publisher ships. Serve `ista_serving`. Run the long-prompt completion
check first if `ista_window` is above 120K, and record it.

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<ista_window> ./run-worker.sh qwen3.8-27b pi blind xhigh
```

xhigh thinks more than medium, so expect a longer run and a higher peak
context. The 300-minute wall gives a partial, which is a row and not a
failure. **If `peak_context` reaches `ista_window`, say so in one
line**: that makes the window binding and changes the serving pick.

Score per `PLAN.md`. The config note carries build, revision, `f16 KV`,
`-c`, window, drafter flags, `wired 25000`, and the temperature and
top_p read from the run's evidence directory.

## `ista-smoke-low`

The same as `ista-smoke-xhigh`, at **effort low**.

## `ista-mendel-low`

The same as `ista-mendel-xhigh`, at **effort low**, only if its smoke
passed.

```bash
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<ista_window> ./run-worker.sh qwen3.8-27b pi blind low
```

Done, for the pair: one comparison table with **score, `peak_context`
and `tool_calls`** for low and xhigh side by side
(`mendel.md`, "Comparing two builds of one model"). A level that
matches on score while spending far more context has not matched.

## `ista-evalplus-low`

Read `docs/methodology/evalplus.md`, including "Which serving config to
score". **EvalPlus serves the fastest config at shallow depth**, from
`ista-nmax-shallow`, which need not be `ista_serving`. Say which it
used.

Calibrate first. **A calibration that does not converge is a stop and
ask**, not a value: two `length` stops there have preceded a run that
spent hours and returned empties. Then the full set, at effort low.

Record base, plus, empty and wall in `results.md`, against this build's
own medium score of 0.976 / 0.945 / 100%, one empty.

## `ista-evalplus-xhigh`

The same, at **effort xhigh**. Last on purpose: xhigh is the level most
likely to need a large budget and to return empties, and its
calibration is where that shows.

Both EvalPlus blocks run at temperature 0, that test's own convention
and not this run's serving temperature.

## Not in this run

- Every other model, and the other two Qwen3.8 builds. The AtomicChat
  build looped on its only agent row; the 4-bit control has no EvalPlus
  of its own and no row at its default. Both are the next run's work.
- q8_0 KV, on any block (owner, 2026-09-09).
- The drafter question on any other model.

## After the run

Update `state.md` with a handing-over section: what ran, what a gate
dropped and why, machine state left behind, evidence archived. The
coordinator adds the findings to
`hardware/m1-max-32gb/benchmarks/INDEX.md`, writes `report.md`, writes
the final derived values into `models.json` and the site, and
publishes.
