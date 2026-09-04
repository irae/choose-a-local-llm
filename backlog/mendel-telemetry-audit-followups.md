# Mendel telemetry: the peak_context claim and the tool_calls gap

Status: DECIDED 2026-09-04: peak_context gets a caveat on the column
(option 1); tool_calls gets the counting rule documented in
`docs/methodology/mendel.md` (not in Mendel's PLAN.md) and a recount of
every row from its log with one script (option 1). Ready for an agent.
Filed: 2026-09-04, from research run 1's label audit
(`research/run1/results/label-audit.md`).
Needs hardware: no.

## peak_context

Every Mendel row carries `peak_context`, defined in the scoring law as
the maximum context across all compaction cycles. The session logs
record that a compaction happened but not the context size at each
one, so for every existing row the number can only be shown consistent
with a maximum, not proven. New runs log context per cycle
(`benchmarks/PLANNING.md`). For the existing rows, either:

1. add a caveat to the column ("not verifiable for rows before
   2026-09-04"), or
2. blank the column for those rows until a run re-measures them, or
3. leave it.

## tool_calls

Two rows disagree with their session logs: Qwen3.6 guided high says
251 calls, the log holds 285; Bonsai MLX blind high says 53, the log
holds 52. The harness's counting rule is not documented (the log may
hold calls the harness excludes on purpose). Either:

1. document the counting rule in `PLAN.md` and recount every row from
   its log with one script, or
2. leave the numbers and add "as counted by the runner" to the column.
