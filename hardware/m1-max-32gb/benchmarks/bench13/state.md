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

## Values this run sets

The runner writes each value here as it measures it, with the block
that produced it.

| name | value | block |
| --- | --- | --- |
| `creep_tool_hash` | `e38c467` | the session's first creep |
| `ista_nodrafter_c` | `163840`, ceiling 147478 @ 8.30 tok/s | `ista-nodrafter-creep` |
| `ista_serving` | no drafter (no `--spec-type`, no `--spec-draft-n-max`), `-c 163840` | coordinator gate |
| `ista_window` | `147456` | coordinator gate |
| `ista_evalplus_serving` | no drafter, `-c 32768` (coordinator's call, unmeasured on this build until confirmed) | coordinator gate |
| `ista_temperature` | | read from `~/.local/share/mendel-benchmark/` |
