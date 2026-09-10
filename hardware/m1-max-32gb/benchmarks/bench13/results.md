# Run 13 — results

One section per block, in run order. Every number with the exact
command that produced it and the file under `results/` that holds the
evidence.

A creep is a table, one row per step, with depth, decode speed, wired
memory, free memory and swap delta. The one-line arrow form is the chat
form and never belongs here (`docs/methodology/status-lines.md`).

A sweep that ends with no stop condition records its deepest step as a
list end, never as a ceiling.

## `ista-nmax-shallow`

Build `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, rev `d562806`,
`--no-mmproj`, f16 KV, `-c 106496`, `--parallel 1`. One 256-token
completion per cell, coding prompt (py), temperature 0. Logs:
`results/server-ista-nmax-<cell>.log`.

| cell | decode tok/s | draft proposed | draft accepted | acceptance | wired at load (MB) |
| --- | --- | --- | --- | --- | --- |
| `none` | 14.44 | — | — | — | 20168 |
| `n1` | 14.35 | 134 | 120 | 89.6% | 22090 |
| `n2` | 13.24 | 196 | 156 | 79.6% | 22241 |
| `n3` | 12.41 | 250 | 171 | 68.4% | 22397 |
| `n4` | 11.72 | 284 | 183 | 64.4% | 22546 |

Wired moved with `n-max`: about 1.9 GB at `n1`, then a further 150-160
MB per extra step. It is not flat here, against the drafter's
head-plus-draft-context cost model.

Decode speed falls with every step past `n1`: acceptance drops faster
than draft length grows, so a longer draft costs more than it wins at
this shallow depth.

No cell had a separate warmup completion before its measured one; the
256-token request reported here was each cell's first request. Every
cell carries the same graph-setup cost, so the ranking across cells
still holds, but these tok/s numbers are not directly comparable with
a creep's rows, which warm up first.

This build's `n3` cell here reads 12.41 tok/s at depth 256, against
15.1 tok/s at `-c 4096` on 2026-09-08 and 15.09 tok/s at depth 4114 in
research run 3, same config otherwise. The gap points to allocation
size, not used depth, taxing decode on this model well below the 262K
mark where that effect first showed.

## `ista-nodrafter-creep`

Same build, f16 KV, no drafter, `--parallel 1`. Estimate: wired
difference between `none` and `n3` in the block above, 2229 MB, over
0.0671 GB per 1K tokens, is about 33K tokens, giving about `-c 164000`.

Probe at `-c 163840`: a real request at prompt depth 3752 tokens
served clean, wired 24412 MB, no swap growth (376 MB, at the start
value). No bisection against `-c 131072` was needed. `creep_tool_hash`
`e38c467`.

```
DEPTH_LIST="4096,8192,16384,24576,32768,40960,49152,65536,81920,98304,114688,131072,147456,163840" \
N_CONTEXTS=1 MODEL=qwen3.8-27b \
python3 ~/code/local-llm-eval-tools/slow-context-creep/creep.py llama
```

| depth_tokens | decode tok/s | wired_mb | free_mb | swap_delta_mb | compress_pages | decompress_pages |
| --- | --- | --- | --- | --- | --- | --- |
| 4114 | 14.14 | 24412 | 67 | 0 | 3274 | 769 |
| 8222 | 13.82 | 24408 | 65 | 0 | 3394 | 2549 |
| 16386 | 13.25 | 24407 | 80 | 0 | 612 | 663 |
| 24602 | 12.83 | 24408 | 92 | 0 | 3729 | 3625 |
| 32818 | 12.39 | 24403 | 68 | 0 | 0 | 772 |
| 40982 | 11.95 | 24421 | 67 | 0 | 0 | 709 |
| 49198 | 11.51 | 24380 | 114 | 0 | 17662 | 2223 |
| 65578 | 10.90 | 24266 | 67 | 0 | 25375 | 10029 |
| 81958 | 10.24 | 24406 | 60 | 0 | 4073 | 3581 |
| 98338 | 9.69 | 24380 | 79 | 0 | 172 | 1794 |
| 114718 | 9.19 | 24402 | 58 | 0 | 10920 | 1638 |
| 131098 | 8.72 | 24384 | 81 | 0 | 2929 | 1727 |
| 147478 | 8.30 | 24397 | 64 | 0 | 2864 | 1904 |
| 163858 | 7.94 | 24383 | 66 | 0 | 2283 | 1039 |

Verdict: **speed**. `STOP: below 8 tok/s at depth 163858`. Swap never
grew past its start value; the compaction spikes at 49198 and 65578
(above 5000 pages) each recovered on the following step and never held
for six steps, so neither is a stop condition on its own. The swept
range reached the planned bound, `-c 163840`, so this is a ceiling, not
a list end. Ceiling: **147478 tokens at 8.30 tok/s**.

## `ista-serving-pick`

Flagged to the coordinator as a planning defect: this block asked the
runner to choose between configs. Held with the data on hand; no
values written by the runner. The coordinator later moved
`ista-nmax-deep` ahead of this block, since the pick needs that
block's numbers.

## `ista-nmax-deep`

Same build, f16 KV, `--parallel 1`, fixed `-c 122880` for every cell
(fits the heaviest cell, `n4`, with about 1.4 GB under the 25000
limit). One 256-token completion per cell at depth 98338 (filler text
plus "Write a Python function that parses ISO dates."), temperature 0.
Logs: `results/server-ista-nmax-deep-<cell>.log`.

| cell | decode tok/s | draft proposed | draft accepted | acceptance | wired (MB) |
| --- | --- | --- | --- | --- | --- |
| `none` | 9.50 | — | — | — | 21233 |
| `n1` | 9.03 | 137 | 118 | 86.1% | 22954 |
| `n2` | 8.32 | 198 | 156 | 78.8% | 23110 |
| `n3` | 7.89 | 245 | 173 | 70.6% | 23231 |
| `n4` | 7.00 | 293 | 181 | 61.8% | 23339 |

The first `none` attempt was served from cache (`prompt_n` 13, not
98601), because the filler text with no trailing instruction produced
an empty completion (EOS at `predicted_n` 1) on the first try, and the
re-send with the instruction appended hit that server's own cache.
`none` was re-run on a fresh server with the filler and the trailing
instruction in one request: `prompt_n` 98610, decode 9.496 tok/s, wired
21227 MB, matching the cache-served reading (9.50 tok/s, 21233 MB)
within rounding. The table above is unchanged; the re-run confirms the
`none` row rather than replacing it.

Acceptance at this depth: 86.1% (`n1`) down to 61.8% (`n4`), close to
the shallow block's 89.6% to 64.4% range. `docs/methodology/mendel.md`
now carries the sample-size trap this surfaced: an acceptance rate
from a short generation (tens of tokens) is not comparable with one
from a substantial generation. Decode speed falls past `none` at every
step here too, the same shape as the shallow block. No swap growth on
any cell.

## Coordinator's serving pick

`ista_serving`: no drafter, `-c 163840`. `ista_window`: 147456. No
drafter beats every drafter cell on both speed and window at every
setting tried, so there is no trade to weigh.

## `ista-smoke-xhigh`

Served `ista_serving` (no drafter, `-c 163840`, f16 KV). Pi model id
`qwen3.8-27b` for the smoke, since a smoke is unscored and produces no
row (the coordinator confirmed this stands after the id question
below). `benchmarks/mendel-smoke.sh qwen3.8-27b xhigh`, cap 1500s.

```
SMOKE-MENDEL model=qwen3.8-27b level=xhigh task=xtend window=default calls=10 distinct=10 longest_run=1 loop=ok:0.73 compactions=0 splits=0 peak=5536 commits=1 clean=yes end=stop wall_s=182 verdict=pass
```

Pass: one commit, clean tree, no loop, 182s inside the cap.

## `ista-mendel-xhigh`

Pi model id: `qwen3.8-27b-ista`, not the bare `qwen3.8-27b`. The
runbook named the bare id; flagged to the coordinator before starting
because `run-worker.sh` derives the branch name and the row's `model`
field from it, and the bare id would have made this row
indistinguishable from the 4-bit control's rows. The coordinator
corrected the runbook (`758e3cd`) and confirmed `qwen3.8-27b-ista`.
That entry's `contextWindow` (114688) is stale for this build; no
other field needed correcting, and `MENDEL_CONTEXT_WINDOW` overrides
`contextWindow` at run time, never the entry itself.

**Long-prompt completion check** (mandatory, `ista_window` above
120K): a real request at prompt depth 144510 tokens on `ista_serving`
returned real content (292 chars, `stop_type` "limit"), not a silent
empty completion. Safe to run Mendel at this window.

```
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=147456 ./run-worker.sh qwen3.8-27b-ista pi blind xhigh
```

Branch `qwen3.8-27b-ista-xhigh-issue-13`, no collision with run 12's
`qwen3.8-27b-ista-medium-issue-13` or
`qwen3.8-27b-ista2-medium-issue-13`. Worker confirmed `contextWindow
147456 pinned on provider llama`.

Worker ended clean: 17 commits, loop verdict ok, worst ratio 0.38 on a
tool call, wall time 109.4 min. Context never reached the window: peak
usage 117,940 tokens against 147,456, no compaction.

Config note: `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, rev
`d562806`, no drafter, f16 KV, `-c 163840`, window 147456, wired 25000,
temperature 1.0, top_p 0.95 (read from the run's own `meta.json`, since
`~/.local/share/mendel-benchmark/` does not exist on this machine).

Scored on `claude-opus-5` per `PLAN.md`, against `RUBRIC.md` unchanged,
citing `scratchpad/benchmark/runs/qwen3.8-27b-ista-xhigh-issue-13-evidence.json`:

| # | Criterion | Score | Evidence |
| --- | --- | --- | --- |
| 1 | Bugs remaining | 16/25 | trap A hit (critical, `.then()` on an AsyncIterator, `THREW: TypeError`), 25 − 3×3. Trap B is an incomplete migration, not a runtime bug (the model kept both the `require` and the declaration, nothing breaks); scored under criterion 2, not counted twice here. Trap C not hit |
| 2 | Task completion | 16/20 | all 8 libraries done; the model found trap B by its own grep and chose to leave it, calling `legacy-packages` out of scope |
| 3 | node_modules pruned | 8/8 | reinstalled before nearly every commit; lockfile shrank, no root devDeps left |
| 4 | Prettier & ESLint | 5/5 | both pass, the model ran both itself 20 times |
| 5 | Commit craft | 8/12 | 15 of 17 subjects `refactor(...)`, 2 `chore`; no multi-package commit, no `--no-verify`, no `git add -A`, no TASKS.md leak |
| 6 | Right the first time | 8/8 | 17 commits, no repair commit; the model's own JSON/prettier checks caught two broken edits before staging |
| 7 | Test discipline | 10/10 | per-package test after every commit, full suite at commits 5, 10, 15, the mandated cadence |
| 8 | House conventions | 5/5 | 40 files, +90/-192 (96 of the deletions the lockfile); no drive-by changes |
| 9 | Task list | 2/4 | sub-items came from a real grep sweep, but the whole tree was written upfront and ticks came in large batches, not per commit |
| 10 | Truncation | 2.5/3 | 52 of 77 noisy commands truncated (68%) |

**Total 80.5/100.**

Coordinator's ruling on criterion 1: count the critical only, 16/25,
total 80.5. Trap B is criterion 2's own named finding ("found the
`mendel-requirify` reference"); counting it again under criterion 1
double-charges one miss. The two prior rows the scorer cited are the
rubric applied correctly, not a drifting convention.

The model's claim that the recurring `mendel-full-example` karma
failure is a pre-existing environment issue was checked and confirmed:
the broken `node_modules/.bin/mendel` symlink is a worktree artifact
(`node_modules` symlinked from the main repo), no commit on this branch
touches `examples/full-example` or `node_modules`, and the model
diagnosed it itself in the session.

Full score line: `Qwen3.8-27B (ISTA IQ3_S-mtp, xhigh) — 80.5 | bugs 16,
completion 16, node_modules 8, lint 5, commits 8, first-time 8, tests
10, conventions 5, task list 2, truncation 2.5 | 8/8 libraries, 17
commits, 109.4 min, $0 (local)`.

## `ista-smoke-low`

Same as `ista-smoke-xhigh`, served `ista_serving`, pi model id
`qwen3.8-27b-ista`.

```
SMOKE-MENDEL model=qwen3.8-27b-ista level=low task=xtend window=default calls=9 distinct=9 longest_run=1 loop=ok:1.00 compactions=0 splits=0 peak=4577 commits=1 clean=yes end=stop wall_s=139 verdict=pass
```

Pass: one commit, clean tree, no loop, 139s inside the cap.

## `ista-mendel-low`

```
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=147456 ./run-worker.sh qwen3.8-27b-ista pi blind low
```

Server unchanged since the mandatory long-prompt check on
`ista-mendel-xhigh` (same `ista_serving`, same window); not repeated,
since the check is about the serving config, not the thinking level.

Branch `qwen3.8-27b-ista-low-issue-13`. Worker ended clean: 15 commits,
loop ok (0.30), wall 163.3 min. Peak context 130,154/147,456 (88.3%),
no compaction.

Scored on `claude-opus-5` per `PLAN.md`:

| # | Criterion | Score | Evidence |
| --- | --- | --- | --- |
| 1 | Bugs remaining | 10/25 | trap A hit (critical, same throw as the xhigh row); trap C also hit here (medium: an unrequested `process.on('exit')` + `fs.rmSync` in `validate-manifest.js` deletes the debug manifest the code prints one line earlier). 25 − 3×(3+2). Trap B left, scored under criterion 2 only |
| 2 | Task completion | 11/20 | 7 of 8 libraries: `shasum` never started (2 requires, 2 `package.json` entries remain), plus trap B left |
| 3 | node_modules pruned | 8/8 | lockfile −70 lines, repeated real reinstalls |
| 4 | Prettier & ESLint | 5/5 | both pass; prettier warns only on untracked `TASKS.md` |
| 5 | Commit craft | 5.5/12 | 13 of 15 subjects `refactor(...)`; 5 commits used `git add -A` |
| 6 | Right the first time | 7/8 | no repair commits; one lint error (implicit `node:` dependency) hit and fixed before the commit |
| 7 | Test discipline | 10/10 | full suite 3 times over 15 commits, per-package tests before each commit |
| 8 | House conventions | 4/5 | minimal diff, but the exit-hook regression in `validate-manifest.js` adds unrequested behavior and a narrating comment |
| 9 | Task list | 2.5/4 | one upfront write after the survey greps, then per-library ticks, not per commit |
| 10 | Truncation | 3/3 | 45 of 74 noisy commands truncated (61%) |

**Total 66/100.** Completion cap (7/8 libraries, 87.5%) not binding,
raw total is lower.

The `mendel-full-example` karma failure is the same pre-existing
environment issue as the xhigh row (broken `node_modules/.bin/mendel`
symlink from the worktree setup); confirmed again on this branch.

Full score line: `Qwen3.8-27B (ISTA IQ3_S-mtp, low) — 66 | bugs 10,
completion 11, node_modules 8, lint 5, commits 5.5, first-time 7, tests
10, conventions 4, task list 2.5, truncation 3 | 7/8 libraries, 15
commits, 163.3 min, $0 (local)`.

## Comparing low and xhigh

| | xhigh | low |
| --- | --- | --- |
| score | 80.5 | 66 |
| `peak_context` | 117,940 (80.0%) | 130,154 (88.3%) |
| commits | 17 | 15 |
| libraries done | 8/8 | 7/8 |
| wall time | 109.4 min | 163.3 min |

xhigh scores higher and spends less context doing it: more thinking
bought a cleaner migration (shasum done, one fewer regression) in less
wall time and less of the window. Low did not match on score while
spending less; it spent more of both and scored lower.
