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
- `ista-nmax-deep`
- `ista-serving-pick` — **coordinator gate: stop, report, wait**
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
- **Branches, exactly.** You work on `run13` and only on `run13`. The
  coordinator works on `master`. When the coordinator says to pull,
  merge or take an update, it always means the same two commands from
  your `run13` worktree:

  ```bash
  git fetch origin
  git merge origin/master
  ```

  Then push `run13`. **Never check out `master`, never merge `run13`
  into `master`, and never push `master`.** The coordinator merges your
  branch into `master` at each report. A commit hash the coordinator
  gives you is a commit on `master`; verify you have it with `git log
  --oneline -1 origin/master` after the fetch.
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

## `ista-serving-pick` — a coordinator gate, not a block

**The runner does not run this and does not choose.** When
`ista-nmax-deep` is committed and pushed, report to the coordinator and
stop. The coordinator reads the two creeps and the deep sweep, writes
`ista_serving` and `ista_window` into `state.md`, and tells you to
continue. Everything below this line waits for those two values.

This gate sits here because the choice needs the run's history and the
project's goals, which a block does not carry
(`benchmarks/PLANNING.md`, "A runner measures, a coordinator decides").

## `ista-nmax-deep`

Step 4, and it runs **before** any pick, because the pick needs it.

**Fixed `-c 122880` for every cell**, so the cells differ only in the
drafter and nothing is confounded by allocation size. That value fits
the heaviest cell with margin: `n4` measured 22546 MB at load at
`-c 106496`, and 16384 more tokens of f16 KV adds about 1074 MB, which
leaves roughly 1.4 GB under the 25000 limit.

**Measure at depth 98338**, the first standard step above the 89386
peak the last agent run of this build reached. One measurement per
cell at that depth, not a full creep.

**Run every cell: `none`, `n1`, `n2`, `n3`, `n4`.** Do not drop cells on
the shallow table's ranking. The shallow numbers are measured where a
drafter does worst, and the agent task never runs there, so only the
deep numbers decide.

**Every cell serves a fresh server and a full prefill.** A cell whose
prompt is answered from a previous cell's cache is not comparable with
the others and is re-run, not reported. Check `prompt_n` in the server
log: it must be the full prompt, not a handful of tokens.

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
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<ista_window> ./run-worker.sh qwen3.8-27b-ista pi blind xhigh
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
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=<ista_window> ./run-worker.sh qwen3.8-27b-ista pi blind low
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

Calibration files moved on 2026-09-09: they are a measurement of this
machine, so they live at `hardware/m1-max-32gb/calibrations/` and no
longer beside the tool. `calibrate.py` now requires the directory:

```bash
CALIBRATION_DIR=hardware/m1-max-32gb/calibrations benchmarks/calibrate.py qwen38-ista-mtp-low qwen3.8-27b '{"chat_template_kwargs":{"reasoning_effort":"low"}}'
```

The extra-body argument is mandatory on the calibration and on the
full run. Without it the chat template resolves its own default, xhigh
for this build, and the file is mislabeled. Check that every row's
`resolved_reasoning_effort` reads `low` before you read the budget.

Calibrate first. **A calibration that does not converge is a stop and
ask**, not a value: two `length` stops there have preceded a run that
spent hours and returned empties. Then the full set, at effort low:

```bash
RESULTS_BASE=hardware/m1-max-32gb/benchmarks/bench13/results \
  EVALPLUS_MAX_NEW_TOKENS=<budget> \
  benchmarks/run-humaneval.sh ista-evalplus-low qwen3.8-27b '{"chat_template_kwargs":{"reasoning_effort":"low"}}'
```

Record base, plus, empty and wall in `results.md`, against this build's
own medium score of 0.976 / 0.945 / 100%, one empty.

## `ista-evalplus-xhigh`

The same, at **effort xhigh**. Last on purpose: xhigh is the level most
likely to need a large budget and to return empties, and its
calibration is where that shows.

```bash
CALIBRATION_DIR=hardware/m1-max-32gb/calibrations benchmarks/calibrate.py qwen38-ista-mtp-xhigh qwen3.8-27b '{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}'
RESULTS_BASE=hardware/m1-max-32gb/benchmarks/bench13/results \
  EVALPLUS_MAX_NEW_TOKENS=<budget> \
  benchmarks/run-humaneval.sh ista-evalplus-xhigh qwen3.8-27b '{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}'
```

Pass the extra body here too, even though xhigh is the template's own
default. A resolved level that was requested is a record; one that was
inherited is a guess.

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
