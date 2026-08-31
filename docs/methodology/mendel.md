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
`benchmark/PLAN.md`. The **blind** test (terse prompt, base `182b07f`)
asks whether the model discovers the traps. The **guided** test
(structured step-by-step prompt with the traps disclosed, base
`4679b5a`, prompt frozen) measures instruction-following — it exists
because the blind run showed weaker and local models losing most of
their points to discoverable traps. **All new runs use the guided
test.** Never compare a score across the two tests.

## Where things live

- **The instructions live in the Mendel repo** (`benchmark` branch:
  `benchmark/PLAN.md` how to run and score, `benchmark/RUBRIC.md` the
  rubric). They are authoritative; this page does not duplicate them.
- Primary artifacts (results, reports) stay there. This repo mirrors
  the result CSVs and the two reports in `benchmarks/mendel/` — we host
  them because it is us who benchmarks the local models. The site's
  [Mendel page](../setups/m1-max-32gb/benchmarks/mendel.md) draws its
  tables from the mirrored CSVs, and the reports are served at
  [/mendel/report.html](../mendel/report.html) and
  [/mendel/report-guided.html](../mendel/report-guided.html).

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
