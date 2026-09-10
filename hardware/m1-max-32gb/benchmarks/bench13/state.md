# Run 13 — state

Created 2026-09-09 by the coordinator. Started 2026-09-09.

Start here: read `AGENT.md`. The list at the top of that file is the
order. Log every session below, and close each one with a
handing-over section.

## Session 1, 2026-09-09

- Worktree: `../choose-a-local-llm-run13`, branch `run13`.
- Machine file already had `wired_limit_mb` 25000; the "stale 24000"
  note in `AGENT.md` no longer matched the file, so no fix was needed.
- `tools/preflight.sh`: every line `ok`. Balloon needed. Start
  numbers: wired 1526 MB, free 24688 MB, swap used 384 MB.
- Sweep tool: `local-llm-eval-tools` was on a stale branch
  (`creep-ab-verdict`) whose remote ref had been deleted after merge.
  Switched to `master`, pulled. `creep_tool_hash`: `e38c467`.
- `ista-nmax-shallow` done: table in `results.md`. Coordinator
  corrected the block's own output (no pick, table only) and set
  `ista-nmax-deep` back to all five cells.
- `ista-nodrafter-creep` done: `-c 163840` served the probe clean, no
  bisection needed. Ceiling 147478 tokens at 8.30 tok/s, verdict
  speed. Full table in `results.md`.
- `ista-serving-pick` blocked: this block asks the runner to choose
  between configs, which now belongs to the coordinator (a block
  reports a measurement, not a choice). Flagged to the coordinator
  with the data on hand. Every later block depends on `ista_serving`
  and `ista_window`, so the run is gated here until the coordinator
  answers.
- Merged `origin/master` twice more while waiting: `6645657` (moved
  `ista-nmax-deep` ahead of the pick, fixed `-c 122880`, one
  measurement per cell at depth 98338) and `e1711c7` (named the
  branch rule in `AGENT.md`'s Essentials).
- `ista-nmax-deep` done, all five cells at `-c 122880`, depth 98338:
  table in `results.md`. Acceptance at depth is close to the shallow
  block's numbers.
- Merged `origin/master` again: `67f3e36`. The coordinator's
  research-run-3 read was wrong: those 1.000-acceptance lines were
  47-token steps, and the real figure on a substantial generation is
  0.778, in line with this run's numbers. Re-ran `none` on a fresh
  server with the filler and instruction in one request, `prompt_n`
  98610: 9.496 tok/s, wired 21227 MB, confirms the original row.
- Coordinator's gate released: no drafter wins on both speed and
  window, no trade to weigh. `ista_serving`, `ista_window` and
  `ista_evalplus_serving` set below. `ista_evalplus_serving`'s `-c
  32768` is the coordinator's own call, flagged as unmeasured on this
  build; the first `ista-evalplus-low` request confirms it works
  before the full set.
- `ista-smoke-xhigh` done: pass, 182s, one commit, clean tree, no
  loop. Full line in `results.md`.
- Long-prompt completion check done (mandatory, `ista_window` above
  120K): real content at depth 144510, not a silent EOS. Safe to run.
- Flagged the pi model id before `ista-mendel-xhigh`: `AGENT.md` named
  the bare `qwen3.8-27b`, which is a different, non-ISTA build in
  `~/.pi/agent/models.json` and would have made the row
  indistinguishable from the 4-bit control's. Coordinator corrected
  the runbook (`758e3cd`) to `qwen3.8-27b-ista`. Merged.
- `ista-mendel-xhigh` done: branch `qwen3.8-27b-ista-xhigh-issue-13`,
  17 commits, loop ok (0.38), 109.4 min, peak context 117,940/147,456,
  no compaction. Scored on `claude-opus-5`: 80.5/100 (coordinator's
  ruling on criterion 1 — count the critical only, since trap B is
  criterion 2's own named finding). Full matrix in `results.md`.
- `ista-smoke-low` done: pass, 139s, one commit, clean tree, no loop.
  Full line in `results.md`. Next: `ista-mendel-low`.
- `ista_temperature` read from the run's own `meta.json`
  (`server_context.props.default_generation_settings.params`):
  temperature 1.0, top_p 0.95. `AGENT.md`'s
  `~/.local/share/mendel-benchmark/` path does not exist on this
  machine; the sampling values are recorded in `<slug>-meta.json`
  instead (`PLAN.md`, "Pinned thinking level and sampling").
- Coordinator confirmed this is the first Mendel row this project
  publishes with sampling recorded, and traced it to llama-server
  reading `general.sampling.*` from the model file. Confirmed
  `~/code/mendel-benchmark` was on the old worker (`134b1d6`); pulled
  to `154b9af` after `ista-mendel-low` closed, before writing rows
  (coordinator's ordering, to avoid a conflict with two upstream
  commits that also touch `results.json`/`results.csv`).
- `ista-mendel-low` done: branch `qwen3.8-27b-ista-low-issue-13`, 15
  commits, loop ok (0.30), 163.3 min, peak context 130,154/147,456, no
  compaction. Scored on `claude-opus-5`: 66/100 (trap A and trap C both
  hit, trap B excluded per the settled convention). Comparison table
  in `results.md`: xhigh wins on score and spends less context doing
  it.
- Correction on `ista-mendel-low`: its `meta.json` reads `end_reason
  turn_timeout`, not the clean stop the worker log's "done" line
  implied. Marked `partial: true` in the published row. Caught by the
  subagent that wrote the row, not by this session's own read.
- Both rows written to `mendel-benchmark` on `154b9af`, `generate-report.mjs`
  run, `results.csv` appended by hand (the generator does not write
  it), pushed `benchmark` at `f14a235`.
- `ista-evalplus-low`: server at `ista_evalplus_serving` (no drafter,
  `-c 32768`) confirmed serving with a real completion. Calibration
  done: 1/10 length stops (`HumanEval/99`), below the two-stop
  non-convergence threshold; three other problems ran 22K-27K
  reasoning tokens before stopping naturally, a long tail flagged in
  `benchmarks/calibration.md`. Budget 30000. Launched the full set.
- Coordinator held the full run: 10 problems at ~13.9 min average
  projects to ~35h for 164, against medium's 3h07 at budget 8192.
  Asked for the raw wall_s and token counts from both calibrations.
- **Bug found while pulling those numbers**: the "low" calibration ran
  `calibrate.py` with no extra-body argument, so no `reasoning_effort`
  was sent. The chat template defaults to `xhigh` when unset (read
  from `meta.json`'s `server_context.props.model_info.chat_template`).
  So the calibration I reported as "low" ran at xhigh. Stopped the
  xhigh calibration I had just started to keep the machine busy (it
  would have duplicated this by accident), renamed the mislabeled file
  to `calibration-qwen38-ista-mtp-low-MISLABELED-actually-xhigh.json`,
  and re-ran the low calibration with the `reasoning_effort` argument
  passed explicitly this time. The full EvalPlus run's own
  `run-humaneval.sh` call did carry the argument correctly (verified:
  `EVALPLUS_EXTRA_BODY` was set from the third CLI argument, which I
  did pass); only the standalone `calibrate.py` invocation was wrong.
  Mendel's smoke/mendel-low runs are unaffected: pi's harness sets the
  thinking level through its own CLI flag and `thinkingLevelMap`, a
  different code path from `calibrate.py`'s `extra_body`.

## Values this run sets

The runner writes each value here as it measures it, with the block
that produced it.

| name | value | block |
| --- | --- | --- |
| `creep_tool_hash` | `e38c467` | the session's first creep |
| `ista_nodrafter_c` | `163840`, ceiling 147478 @ 8.30 tok/s | `ista-nodrafter-creep` |
| `ista_serving` | no drafter (no `--spec-type`, no `--spec-draft-n-max`), `-c 163840` | coordinator gate |
| `ista_window` | `147456` | coordinator gate |
| `ista_evalplus_serving` | no drafter, `-c 32768`; confirmed serving, calibrated, budget 30000 | `ista-evalplus-low` |
| `ista_temperature` | temperature 1.0, top_p 0.95 (from `<slug>-meta.json`, not the AGENT.md path, which does not exist) | `ista-mendel-xhigh` |
