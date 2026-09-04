# Mendel — the agentic benchmark

Tier 2 of the quality flow, before [polyglot](./polyglot.md): a
real-repo agentic task from the open-source
[Mendel](https://github.com/irae/mendel) project. One identical task
(replace eight npm dependencies with native Node equivalents, with known
traps), one identical prompt, one identical starting commit, a 100-point
rubric. It measures what EvalPlus cannot: multi-file work, commit craft,
test discipline, staying inside scope.

## Two tests

Mendel is two tests on the same task, documented in the Mendel repo's
`benchmark/PLAN.md`. The **blind** test (terse prompt, base: tag
`benchmark-blind-base`) asks whether the model discovers the traps.
The **guided** test (structured step-by-step prompt with the traps
disclosed, base: tag `benchmark-guided-base`, prompt frozen) measures
instruction-following — it exists because the blind run showed weaker
and local models losing most of their points to discoverable traps.
Which test a model runs is set by `PLAN.md` ("Which models run which
test"): strong API models run blind only; local and weak models run
both, so each pair shows the lift. Never compare a score across the
two tests.

## Where things live

- **The instructions live in the Mendel repo** (`benchmark` branch:
  `benchmark/PLAN.md` how to run and score, `benchmark/RUBRIC.md` the
  rubric). They are authoritative; this page does not duplicate them.
- Primary artifacts (results, reports) stay there. This repo mirrors
  the result CSVs and the two reports in `benchmarks/mendel/` — we host
  them because it is us who benchmarks the local models. The site's
  [Mendel page](../setups/m1-max-32gb/benchmarks/mendel.md) draws its
  tables from the mirrored CSVs, and the reports are served at
  <a href="../mendel/report.html" target="_blank" rel="noreferrer">/mendel/report.html</a> and
  <a href="../mendel/report-guided.html" target="_blank" rel="noreferrer">/mendel/report-guided.html</a>.

## House rules for runs from this project

- One model at a time — one GPU. The Mendel tooling supports parallel
  workers; do not use that here.
- Start the model's server with the exact serving config from its
  report page, then run the harness per Mendel's `PLAN.md` (local
  models: pi harness; provider `llama` is llama-server, `lmstudio` is
  LM Studio).
- Do not re-run models that already have a result row there.
- After each run finishes, the agent running the benchmark (never the
  model under test) kills stray `Mendel Daemon` processes — exact name,
  capital D: `pkill -f "Mendel Daemon"`.
- Never trust the benchmarked model's own claims; score only from the
  verification battery.
- A valid but partial run can run again. If the model caused the
  failure, the retry replaces the row and loses a fixed number of
  points for each earlier valid attempt. If our harness caused it (a
  window or output budget that could not fit, a flag the serving stack
  ignored), the corrected re-run keeps the best row with no penalty.
  Mendel's `PLAN.md` holds the formula.
- `tool_calls` counts one `toolCall` block inside one assistant
  message of the run's session log. A call counts even when no result
  came back. Tool results, user messages, and any session the row does
  not score (a false start, a killed first attempt, or a tail after
  mid-run human help) do not count. `benchmark/count-tool-calls.mjs`
  in the Mendel repo prints the count for a log. Checked 2026-09-04:
  all 17 local rows agree with their logs.
- `peak_context` is not verifiable for a row scored before 2026-09-04.
  The session log of such a row shows that a compaction happened, but
  not the context size at each cycle, so the figure agrees with a
  maximum and no log proves it. Runs from that date record the context
  at every cycle. The two mirrored reports carry the same caveat on
  the column.
