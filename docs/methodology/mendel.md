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

Note added by the owner, run 10, 2026-09-06: a model can be scored
more than once at different thinking levels, and coverage can be
uneven — a model may have a thinking-on row and no thinking-off row
(or vice versa) even after EvalPlus clears the gate at that level.
Check every thinking level a model has an EvalPlus pass at before
assuming its Mendel coverage is complete;
`backlog/mendel-thinking-off-gaps.md` tracks confirmed gaps.

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
- `gh auth status` must pass right before every run, blind or guided.
  The task names a GitHub issue and the model reads it through `gh`;
  a dead token costs a run to a login loop (run 10, Bonsai guided).
  A failing status means no Mendel run until the owner logs in.
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
  cannot be that long. The Mendel worker and the smoke pin 8192 in
  their private pi config since 2026-09-06; rows before that date ran
  at pi's default 16384, and their config notes say so. For a new model, a ten-minute probe gives the
  first L: one prompt at 60 percent of the window for fit, one request
  for a complete 400-line file with thinking on and the cap at 16384,
  one failing edit followed by its retry. Any `length` stop in the
  probe is a failure sign, not a value. The first scored run then
  confirms the value from its output-limit counters, and corrects it
  if healthy output comes near the line. Evidence and the per-model
  values as of 2026-09-05:
  `/history/runner-alarms-output-limit-and-loop-stop.html`.
- **Live loop stop.** The runner ends a run on the same tool call five
  times in a row (three when that call already stalled a turn), on a
  message without a tool call whose lines repeat in shape (the
  `loop-check.py` measure over a 60-line window, under 0.10), or on a
  one-character flood of 2000 characters or more. The end reasons are
  `repetition_loop` and `degenerate_output`; the row is invalid. Every
  loop the project saw before the rule, with its timing, is in
  `hardware/m1-max-32gb/research/loop-signatures.md`. The rule is in
  the Mendel `PLAN.md`.
- **Repetition-loop flag.** At run close the Mendel worker runs
  `benchmarks/loop-check.py` on the session log, and the verdict, its
  worst ratio, and its kind land beside the row as
  `telemetry.loop_flag`, `loop_ratio` and `loop_kind`. It is a flag,
  never a stop, and it also catches a repeat that spans many turns.
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

## Window and budget

A Mendel row's harness parameters are measurements, set from the
newest data at run time ([common rules](./common-rules.md), rule 10),
never copied from a runbook or from the owner's daily-driver entry.

- **Serving `-c`**: the largest value that loads and serves one real
  completion under the current wired limit, from the newest ladder
  for the same files and KV type.
- **Clean depth**: from the newest slow creep at that `-c`: the
  deepest step at or above the 8 tok/s floor before the creep's STOP
  verdict, or the last step when no verdict came.
- **Harness window** (`contextWindow`): the largest of 32768, 49152,
  65536, 98304, 131072, 212992 that is at or under both `-c` and the
  clean depth. The task has needed about 46K on other models, so a
  window under that is a known partial condition, written in the
  config note, and never a reason to freeze a larger measurement out.
- **Output budget**: `maxTokens` and `reserveTokens` by the output
  budget rule above.
- **Compaction keep** (`keepRecentTokens`): pi's default 20000 unless
  the run's pinned config sets another value; the config note says
  which (`backlog/pi-compaction-efficiency.md` holds the open
  proposal for small windows).

These values live in the run's pinned pi config, which the smoke
already builds from `SMOKE_MENDEL_CONTEXT_WINDOW`,
`SMOKE_MENDEL_RESERVE_TOKENS` and `SMOKE_MENDEL_KEEP_RECENT_TOKENS`.
The Mendel worker copies the owner's entry as it is (state on
2026-09-06); until it takes the same overrides, a run whose measured
window differs from the owner's entry is stop and ask, and the ask
names the measured value. The config note of every row carries the
window, the `-c`, the budget and the source block of each.
