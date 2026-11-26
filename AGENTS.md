# Agent Guide

This repository answers one question per machine: **which local model, runtime, and configuration should I code with?**

- Published website source: `site/` (VitePress `srcDir = 'site'`). **Zero machine hostnames** allowed in `site/` (enforced by `tools/check-hostnames.mjs`).
- Structured dataset: `data/binaries.json` and `data/setups/<hardware-slug>/models.json`.
- Internal raw benchmark runs & router presets: `hardware/<hardware-id>/` and `benchmarks/`.
- Agent docs & standing rules: `docs/agents/` (not published).
- Human operator / cloner docs: `docs/repo/` (not published).

## Commands

```bash
npm install                      # once
npm run docs:tables              # regenerate site tables, site-stats.json, and site/files/*
npm run dev                      # preview site at http://localhost:5173
npm run verify                   # build site + link check
npm run docs:check               # check table drift, hostname leaks, and dead links
npm run deploy -- "what changed" # build, verify, commit (never pushes)
```

## Read Next

- [docs/agents/README.md](./docs/agents/README.md) — Index of all agent guides.
- [docs/agents/site-writer.md](./docs/agents/site-writer.md) — Rules and word caps for editing `site/`.
- [docs/agents/site-reviewer.md](./docs/agents/site-reviewer.md) — Strict cross-page review checklist.
- [docs/agents/standing-rules.md](./docs/agents/standing-rules.md) — Full standing rules and benchmark repo index.
- [docs/agents/planning.md](./docs/agents/planning.md) — Coordinator/runner split and runbook planning.
- [CONVENTIONS.md](./CONVENTIONS.md) — Script headers and repository conventions.
