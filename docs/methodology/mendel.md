# Mendel — the agentic benchmark

Tier 2 of the quality flow, before [polyglot](./polyglot.md): a
real-repo agentic task from the open-source
[Mendel](https://github.com/irae/mendel) project. One identical task
(replace eight npm dependencies with native Node equivalents, with known
traps), one identical prompt, one identical starting commit, a 100-point
rubric. It measures what EvalPlus cannot: multi-file work, commit craft,
test discipline, staying inside scope.

## Where things live

- **The instructions live in the Mendel repo** (`benchmark` branch:
  `benchmark/PLAN.md` how to run and score, `benchmark/RUBRIC.md` the
  rubric). They are authoritative; this page does not duplicate them.
- Artifacts (results, report) stay there. Result rows are imported into
  this setup's comparison tables.

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
