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

## The smoke

One handed task before the full run: replace one dependency that spans
two files (`xtend` with `Object.assign`, the task research run 1 built
and run 2 used, `hardware/m1-max-32gb/research/run2/results/mendel-probe-xtend.md`), same
base commit, thinking as the config will run, a 25-minute cap, unscored.
The tool is `benchmarks/mendel-smoke.sh <pi-model-id> <thinking-level>`.
It answers one question: can this config do agent work at all. Pass is
one commit with a clean working tree, no repetition loop, inside the
cap. A fail means no full run for that config; the smoke line goes in
the results and the config is dropped or sent back to research.

It gates lists the way the EvalPlus smoke does: several candidates get
the smoke in one session, and only the passes go on to a full run of
several hours each. It never produces a score and never reaches the
site.

The same tool also runs the compaction experiment. The harness
compacts between turns when the context passes `contextWindow -
reserveTokens`, and the model under test writes its own summary. With
`SMOKE_MENDEL_CONTEXT_WINDOW` the tool pins a smaller window into its
own copy of the harness config, and `SMOKE_MENDEL_TASK=xtend-wide`
hands a longer task of the same shape, because the two-file swap never
grows past the harness's 20000-token keep budget. The line then carries
`compactions`, `splits` and `peak`, and the summaries land in the
output directory. The pass rule does not change. The design, the
window ladder and the summary rubric live in
`hardware/m1-max-32gb/research/compaction-experiment.md`.

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
- Start the model's server by hand with the exact serving config from
  its report page, then run the harness per Mendel's `PLAN.md` (local
  models: pi harness; provider `llama` is llama-server, `lmstudio` is
  LM Studio, `mlx` is mlx_lm.server). The worker never starts a server
  for any provider; a run launched without one fails its first turn.
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
- **Output budget.** `maxTokens` in a pi entry caps one response. It
  is not a context size and it is not a loop detector. Set it with
  `min(max(8192, pow2ceil(2 x L)), contextWindow / 4)`, where L is the
  longest healthy output the model has produced (a turn that ended on
  `toolUse` or `stop`). Set pi `reserveTokens` to the same value, or
  compaction keeps 16384 tokens of window free for an answer that
  cannot be that long. For a new model, a ten-minute probe gives the
  first L: one prompt at 60 percent of the window for fit, one request
  for a complete 400-line file with thinking on and the cap at 16384,
  one failing edit followed by its retry. Any `length` stop in the
  probe is a failure sign, not a value. The first scored run then
  confirms the value from its output-limit counters, and corrects it
  if healthy output comes near the line. Evidence and the per-model
  values as of 2026-09-05:
  `/history/runner-alarms-output-limit-and-loop-stop.html`.
- **Repetition-loop flag.** At run close the Mendel worker runs
  `benchmarks/loop-check.py` on the session log, and the verdict, its
  worst ratio, and its kind land beside the row as
  `telemetry.loop_flag`, `loop_ratio` and `loop_kind`. It is a flag,
  never a stop.
- `tool_calls` counts one `toolCall` block inside one assistant
  message of the run's session log. A call counts even when no result
  came back. Tool results, user messages, and any session the row does
  not score (a false start, a killed first attempt, or a tail after
  mid-run human help) do not count. `benchmark/count-tool-calls.mjs`
  in the Mendel repo prints the count for a log. Checked 2026-09-04:
  all 17 local rows agree with their logs.
- `peak_context` is the maximum, over the assistant messages of the
  scored session or sessions, of `usage.input + usage.cacheRead +
  usage.cacheWrite + usage.output`, which the harness reports as
  `usage.totalTokens`. It is the largest context one turn occupied,
  the response of that turn included, across all compaction cycles. It
  is never the value after a compaction.
  `benchmark/count-tool-calls.mjs` in the Mendel repo prints it, so a
  row is checked against its log before it is committed. Checked
  2026-09-04: every row with a committed log agrees with its log. One
  retired harness writes its log in another record shape that the
  counter does not read. Those rows keep an older reading, which
  counts the prompt of the largest turn without the response of that
  turn; the two mirrored reports mark those cells with a dagger.
