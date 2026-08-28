# Finding the best local coding model for your machine

A repeatable process to answer, for one specific computer: **which local
model, runtime, and configuration should I code with?**

The content lives on the site built from `docs/`. Start at `docs/index.md`
for the project intro, the goals, and a summary of each measured setup.

## Read it locally

```bash
npm install
npm run docs:dev
```

Then open http://localhost:5173.

## Map

- `docs/index.md` — project intro, goals, per-setup summaries.
- `docs/methodology.md` — the flow: measurement rules, runtime policy,
  model-selection reasoning, the quality gate, night-run rules. The flow is
  the law; read it before running anything.
- `docs/setups/<setup>/` — one directory per measured machine: setup
  overview, comparison, per-model reports, raw benchmark data.
- `night<N>/` — unattended-run kits: runbook (`NIGHT-AGENT.md`), state,
  results, scripts. Not part of the site.
