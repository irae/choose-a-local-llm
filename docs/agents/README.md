# Agent Docs (Pass 1)

Internal documentation for agents working on this repository. Nothing under `docs/` is published to the website (`site/`).

> **Note:** Pass 1 provides a clean folder separation and the minimal writer/reviewer guides needed to maintain `site/`. A full-rigor overhaul of `docs/agents/` is scheduled for Pass 2.

## Website Maintenance

- [site-writer.md](./site-writer.md) — Concise rules for editing `site/` prose, data, and generated tables.
- [site-reviewer.md](./site-reviewer.md) — Strict cross-page reviewer checklist (`models/` ↔ `setups/` ↔ `index.md` ↔ `data/`).

## Benchmark Operations & Standing Rules

- [standing-rules.md](./standing-rules.md) — Owner-confirmed standing rules and repo index (lifted from root `AGENTS.md`).
- [planning.md](./planning.md) — Coordinator/runner split, parameter derivation, and runbook planning rules.
- [checklist.md](./checklist.md) — Pre-run and live benchmark checklist (preflight, memory watcher, crash detection).
- [common-rules.md](./common-rules.md) — Prompt-cache, KV policy, and record-everywhere measurement rules.
- [server-lore.md](./server-lore.md) — Server quirks, failure signatures, and recovery notes.
- [status-lines.md](./status-lines.md) — Progress update formats and context-budget rules.
