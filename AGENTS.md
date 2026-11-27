# Agent Guide

This repository answers one question per machine: **which local model, runtime, and configuration should I code with?**

## Layout

- `site/` — Published VitePress website (`srcDir = 'site'`). Use hardware display names or hardware slugs (`m1-max-32gb`, `rtx-5060ti-16gb`); keep machine hostnames internal to `hardware/` (enforced by `tools/check-hostnames.mjs`).
- `data/` — Structured dataset (`data/binaries.json`, `data/setups/<hardware-slug>/models.json`) feeding generated tables, `site/.vitepress/data/site-stats.json`, `site/.vitepress/data/decode-curves.json`, and `site/files/*`.
- `hardware/<hardware-id>/` and `benchmarks/` — Internal raw runs, router presets (`models.ini`), and shared runner scripts (unpublished).
- `docs/agents/` and `docs/repo/` — Internal agent guides and human operator docs (unpublished).

## Standing Guardrails

- **Push only on explicit owner request.** `npm run deploy` builds, verifies, and commits locally; it never pushes.
- **Avoid bare `git stash`.** Stashes are shared across worktrees; save WIP as a branch commit or a named stash (`git stash push -m "<context>"`).
- **Verify before committing:** run `npm run docs:tables && npm run verify && npm run docs:check` after `site/` or `data/` edits, and `tests/run.sh` after editing `benchmarks/`.

## Commands

```bash
npm run docs:tables              # regenerate site tables, site-stats.json, and site/files/*
npm run verify                   # build site/ and check internal links
npm run docs:check               # check table drift, hostname leaks, and dead links
npm run dev                      # preview at http://localhost:5173
npm run deploy -- "what changed" # build, verify, commit locally (never pushes)
```

## Read When

- **Editing `site/` or `data/`:** [docs/agents/site-writer.md](./docs/agents/site-writer.md) — single-home rules, current-era framing, and prose word caps.
- **Reviewing `site/` or `data/` edits:** [docs/agents/site-reviewer.md](./docs/agents/site-reviewer.md) — cross-page parity audit and blocking-defect gates.
- **Planning a run, writing `bench<N>/AGENT.md`, or updating `HANDOFF.md`:** [docs/agents/planning.md](./docs/agents/planning.md) — coordinator/runner split, parameter derivation, and runbook format.
- **Working with run branches/worktrees, or touching `benchmarks/`, `hardware/`, or `tools/`:** [docs/agents/standing-rules.md](./docs/agents/standing-rules.md) — owner standing rules and repo tool index.
- **Executing a benchmark run or diagnosing a server:** [docs/agents/README.md](./docs/agents/README.md) — index of runner SOPs (`checklist`, `common-rules`, `server-lore`, `status-lines`).
- **Adding or editing scripts under `tools/` or `benchmarks/`, or filing a `backlog/` item:** [CONVENTIONS.md](./CONVENTIONS.md) — script headers, tooling shape, and markdown rules.
