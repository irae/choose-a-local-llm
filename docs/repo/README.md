# Running This Repository on Your Own Hardware

This folder holds operator documentation for cloning the repository, preparing a machine, running local LLM benchmarks, and building the site.

> **Status (best-effort):** External benchmark tools (`local-llm-eval-tools` and the next-generation issue simulator) are still being extracted and stabilized. Full plug-and-play cloneability is parked until those tools settle; the guides here document the current working setup and repo conventions.

## Guides

- [hardware-setup.md](./hardware-setup.md) — Preparing macOS (services list, `iogpu.wired_limit_mb` ladder, `machine.md`) and Linux CUDA hosts.
- [running-benchmarks.md](./running-benchmarks.md) — Running depth sweeps, HumanEval+ fast mode, Mendel, archiving evidence, and building the website.

## Optional Pre-Commit Hostname Guard

To prevent internal machine hostnames from leaking into `site/` when committing locally, enable the repository's git hooks:

```bash
git config core.hooksPath .githooks
```

The hook runs `node tools/check-hostnames.mjs` whenever staged files touch `site/`.
