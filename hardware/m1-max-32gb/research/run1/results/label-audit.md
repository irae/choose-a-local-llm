# Goal 2 — audit of run labels against the session logs

Status: complete for the rows that can be audited. Two corrections
found. Nine of seventeen local rows have no session log on disk and
cannot be checked at all.

Sources: `../mendel-benchmark/benchmark/results.json` and
`results-guided.json` for the rows,
`../mendel-benchmark/scratchpad/benchmark/runs/*-session.jsonl` for the
logs.

## Coverage first, because it bounds everything else

There are 17 local rows across the two result files. There are 8
session logs. So **9 rows cannot be audited**, including two that claim
a compaction:

* qwen3.6-35b-a3b, blind, xhigh — claims 1 compaction
* qwen3.6-35b-a3b, guided, high — claims 1 compaction

`scratchpad/` is gitignored, so these logs are local to the benchmark
machine and were never committed. Some runs predate the current logging,
and some worktrees were removed with their evidence.

This is worth fixing before the next run: a row whose log is gone cannot
be defended, corrected, or reproduced.

## Error 1 — thinking level: no new cases found

Checked every `thinking_level_change` event against the row's
`thinking` field, for all 8 logs.

The known case is confirmed and already corrected.
`prism-ml/Ternary-Bonsai-27B-mlx-2bit`, low, guided: the worker was
invoked with `--thinking low`, the log's only level event reads `high`,
and the row correctly records `high`. That matches the deviation note in
`benchmarks/bench7/state.md`. No action.

Every other audited row agrees with its log. No new mislabels among the
8. The 9 rows without logs are unknown.

## Error 2 — compactions: two rows are wrong

pi writes a `compaction` record for a split turn as well as for a real
compaction. A split turn carries a summary beginning `No prior history`
and containing `**Turn Context (split turn):**`. It is not a compaction
and must not be counted.

Counted per log:

| Run | compaction records | real | split-turn | row says | verdict |
| --- | --- | --- | --- | --- | --- |
| bonsai-prism high blind | 1 | 0 | 1 | 1 | **WRONG, should be 0** |
| gemma-4-12b low guided | 4 | 3 | 1 | 4 | **WRONG, should be 3** |
| qwen3.6-35b high blind | 1 | 0 | 1 | 0 | correct |
| qwen3.6-35b high guided | 1 | 0 | 1 | 0 | correct |
| gemma-4-12b high blind | 0 | 0 | 0 | 0 | correct |
| gemma-4-12b high guided | 0 | 0 | 0 | 0 | correct |
| Ternary-Bonsai-mlx high blind | 0 | 0 | 0 | 0 | correct |
| Ternary-Bonsai-mlx low guided | 0 | 0 | 0 | 0 | correct |

The two qwen3.6 rows show the fix already applied: each has a
split-turn marker in its log and correctly records 0. The two rows above
did not get the same treatment.

### Corrections to apply

* `results.json`, `bonsai-prism`, blind, high:
  `telemetry.compactions` 1 to **0**.
* `results-guided.json`, `google/gemma-4-12b`, guided, low:
  `telemetry.compactions` 4 to **3**.

Neither changes a score. `compactions` is reported, not scored.

## Error 2b — peak_context: consistent, but not provable from these logs

The check asked whether `peak_context` is the maximum across ALL
compaction cycles rather than the post-compaction value.

Only one audited row has real compactions: gemma-4-12b, low, guided,
with 3 real compactions and `peak_context` 45159 at 28% of window. A
post-compaction value would be small; 45159 is not. So it is consistent
with being a maximum.

That is the strongest statement the evidence supports. The session log
records compaction events but not a per-cycle context measurement, so
the maximum cannot be recomputed from it. Proving this needs the harness
to log context at each cycle. Recommended for the next run kit.

## Not part of goal 2, found while auditing

**`tool_calls` disagrees with the log in two rows.** qwen3.6-35b-a3b
guided high: 285 `toolCall` records in the log, row says 251, a gap of
34. `prism-ml/Ternary-Bonsai-27B-mlx-2bit` blind high: 52 in the log,
row says 53. The qwen gap is large enough to want an explanation before
`tool_calls` is quoted anywhere. Not corrected here, because the
counting rule the harness intends is not documented and the log may
legitimately contain calls the harness excludes.

**`tool_errors` was not audited.** A first attempt to recount errors by
scanning tool results for error-like text produced numbers far from the
recorded ones in both directions, which says the heuristic is wrong, not
the rows. Recounting properly needs the harness's own definition of a
failed tool result. Left alone rather than reported as a discrepancy.
