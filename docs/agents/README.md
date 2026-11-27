# Agent Docs

Internal guides for agents working in this repository. Nothing under `docs/` reaches the published website (`site/`).

Public scientific methodology lives in [site/method/](../../site/method/index.md); human setup and benchmark instructions live in [docs/repo/](../repo/README.md).

## Website (`site/` & `data/`)

- **Before editing `site/` prose or `data/` JSON:** [site-writer.md](./site-writer.md) — single-home boundaries, current-era rules, generated surfaces, and word caps.
- **After any batch of `site/` or `data/` edits:** [site-reviewer.md](./site-reviewer.md) — cross-page parity, caveat preservation, ledger checks, and verification gates.

## Benchmark Operations & Standing Rules

> **Scope note:** The operational SOPs below are Pass 1 lifts with updated v2 paths; full Pass 2 consolidation is planned after the website publishes.

- **Before touching run branches, worktrees, `benchmarks/`, `hardware/`, or `tools/`:** [standing-rules.md](./standing-rules.md) — owner-confirmed standing rules and repo tool index.
- **Before planning a bench/research run, writing `bench<N>/AGENT.md`, or editing `HANDOFF.md`:** [planning.md](./planning.md) — coordinator/runner split, fixed vs. derived parameters, and runbook structure.
- **Before starting or resuming any benchmark, sweep, or scoring run:** [checklist.md](./checklist.md) — preflight, server startup, memory watcher, 20-minute wakeup, and idle-GPU rule.
- **Before writing or running a measurement script or recording results:** [common-rules.md](./common-rules.md) — warmup, KV cache policy, drafter policy, and record-everywhere rules.
- **Before starting a server or when a run stalls/crashes:** [server-lore.md](./server-lore.md) — verified quirks and failure signatures for `llama-server`, `mlx_lm.server`, and LM Studio.
- **Before posting run progress, updating `state.md`, or drafting `results.md`:** [status-lines.md](./status-lines.md) — short/medium/large update templates and context-budget rules.
