# peak_context is verifiable after all: recompute it from per-turn usage

Status: draft, recommendation included; supersedes the caveat that
landed on 2026-09-04 (Mendel `bec00354`), which is too broad.
Filed: 2026-09-04, from the coordinator's check after the telemetry
follow-ups landed.
Needs hardware: no. All 16 committed session logs are in the Mendel
repo under `benchmark/runs/`.

## What was believed, and what is true

Research run 1's audit said `peak_context` cannot be recomputed because
the session log records that a compaction happened but not the context
size at each cycle. That is wrong. Every assistant message pi writes
carries a `usage` block: `input`, `cacheRead`, `cacheWrite`, `output`,
`totalTokens`. The context at every turn is in the log, for local and
API models alike, because all of them run through pi. The only rows
without it are the three from the retired claude harness (haiku, opus,
sonnet blind v1.0), whose logs carry no usage at all.

Nothing computes `peak_context` today. No script in `benchmark/` reads
it or writes it; the scoring sub-agent fills it by hand from pi's
session stats or from the log, which is why the rows disagree with
each other about what the number means.

## The evidence, row by row

Compared each row's `peak_context` with the maximum over assistant
messages of `usage.totalTokens` in its log:

- Equal in 20 of 33 pi rows (for example bonsai-prism 50199, grok blind
  259619, luna max 353875, both Qwen3.8 split runs, the Gemma-12B rows).
- Small differences of a few hundred tokens in 7 rows (kimi high 67077
  against 66500 by the prompt-only formula; the scorer used the total
  including output there). Same number, different formula.
- **Two rows with a compaction recorded the post-compaction value, the
  exact error the law forbids:** gpt-5.6-luna blind high says 99425
  where the log's maximum is 255645; qwen3.6 guided-v3 high says 77849
  where the maximum is 94259.
- Two rows differ for reasons to inspect: gemma-4-26b blind 141462
  against 157795 (the scored part is lines 1-236 only, so the maximum
  must be taken inside that range), deepseek-v4-pro blind 182058
  against 479135 (one outlier message; inspect it before trusting
  either number).

## Recommendation

1. Define the rule in Mendel's `PLAN.md` results shape and in
   `docs/methodology/mendel.md`: `peak_context` is the maximum over the
   assistant messages of the scored session(s) of
   `usage.input + usage.cacheRead + usage.cacheWrite + usage.output`,
   which is pi's `totalTokens`: the largest context any turn occupied,
   response included. State it as the largest single turn, across all
   compaction cycles.
2. Extend `benchmark/count-tool-calls.mjs` (it already walks the
   assistant messages and honours `--lines`) to print that maximum, so
   the number is mechanical from now on.
3. Recompute every pi row, correct the ones that differ, note the
   change in the row's `anomaly` only where it moved by more than the
   small-formula difference (the two compaction rows), regenerate both
   reports, refresh the mirror.
4. Narrow the caveat that landed on 2026-09-04: it applies to the three
   claude-harness rows only, not to every row scored before that date.
   Remove the † from the column header and put it on those three cells.
5. Update `benchmarks/PLANNING.md` step 3: the per-cycle logging it asks
   for is already there in pi's usage; the requirement becomes "verify
   `peak_context` with the counter before committing a row".
