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

## Values this run sets

The runner writes each value here as it measures it, with the block
that produced it.

| name | value | block |
| --- | --- | --- |
| `creep_tool_hash` | `e38c467` | the session's first creep |
| `ista_nodrafter_c` | | `ista-nodrafter-creep` |
| `ista_serving` | | `ista-serving-pick` |
| `ista_window` | | `ista-serving-pick` |
| `ista_evalplus_serving` | | `ista-nmax-shallow` |
| `ista_temperature` | | read from `~/.local/share/mendel-benchmark/` |
