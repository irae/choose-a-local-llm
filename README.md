# Choosing a Local Coding LLM

Measured decode speed at depth, real-memory context limits, HumanEval+ coding quality, and end-to-end coding agent scores across consumer hardware.

**Live site:** <https://irae.github.io/choose-a-local-llm/>

## Repository Layout

- `site/` — Published VitePress website (findings, per-machine picks, canonical model pages, auto-generated `/files/*` catalog, benchmarks, and public scientific method).
- `data/` — Single source of truth (`data/binaries.json`, `data/setups/*/models.json`) feeding all generated tables, file pages, and build-time compute stats.
- `docs/repo/` — Operator documentation for running benchmarks on your own hardware ([start here](./docs/repo/README.md)).
- `docs/agents/` — Internal agent guides and standing rules ([index](./docs/agents/README.md)).
- `hardware/` & `benchmarks/` — Raw benchmark run logs, router presets, and measurement scripts.

## Develop the Website Locally

```bash
npm install
npm run docs:tables
npm run dev
```

Verify before committing:

```bash
npm run verify
npm run docs:check
```
