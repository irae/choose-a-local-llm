# Finding the best local coding model for your machine

A repeatable process to answer, for one specific computer: **which local
model, runtime, and configuration should I code with?**

**Results: <https://irae.github.io/choose-a-local-llm/>**, the site
built from `docs/`. Start at `docs/index.md` for the project intro, the
goals, and a summary of each measured setup.

## Read it locally

```bash
npm install
npm run docs:dev
```

Then open http://localhost:5173.

Working on this repo? Start at [AGENTS.md](./AGENTS.md), then
[CONVENTIONS.md](./CONVENTIONS.md) for how markdown and tooling are written.

## Map

- `docs/index.md`: project intro, goals, per-setup summaries.
- `docs/methodology.md`: the flow. Measurement rules, runtime policy,
  model-selection reasoning, the quality gate, bench-run rules. Read it
  before you run anything.
- `docs/setups/<setup>/`: one directory per measured machine. Setup
  overview, comparison, per-model reports, raw benchmark data.
- `benchmarks/bench<N>/`: unattended-run kits. Runbook (`AGENT.md`),
  state, results, scripts. Not part of the site.

## How to use this repo to run your benchmarks

The process stands on its own; only the measurements are ours. That
split is a rule: **method pages never name a model.** Everything under
`docs/methodology/` describes how to measure. The models, runtimes,
commands and numbers of one machine live under `docs/setups/<setup>/`.
A method page may say "one dense 12B model on the reference setup" and
link the setup's report. A model name in a method page is a bug.

1. Read `AGENTS.md` (the index and the standing rules), then
   `docs/methodology.md` and its per-task pages. The flow is binding.
2. Plan a run per [benchmarks/PLANNING.md](./benchmarks/PLANNING.md):
   a coordinator agent writes `benchmarks/bench<N>/AGENT.md`, a smaller
   runner agent executes it.
3. Keep your own `HANDOFF.md` at the repo root for coordinator state.
   It is gitignored; start yours empty. The writing rules are in
   `benchmarks/PLANNING.md`. Work that needs no hardware and no
   decision yet goes to `backlog/`, one file per item.
4. Record results the way `EDITOR.md` and the methodology's
   record-everywhere rule demand, and add each run's findings to
   `benchmarks/INDEX.md`.
