# Running Benchmarks & Building the Site

## Adding a Setup

1. Create `data/setups/<hardware-slug>/models.json` matching the schema of existing setups (`hardwareId`, `hardwareSlug`, `hardwareName`, `hardware`, `benchRuns`, `rows`, `models`, `evalplusRuns`, `mendelWalls`, `curves`).
2. Add any new model weight entries to `data/binaries.json`.
3. Create `site/setups/<hardware-slug>/index.md` with the four setup markers (`gen:setup-complete`, `gen:setup-partial`, `gen:setup-evalplus`, `gen:setup-presets`). VitePress auto-discovers new setups and models from `data/setups/*/models.json`.
4. Keep internal raw run logs, scripts, and `models.ini` files under `hardware/<hardware-id>/` (never inside `site/`).

## Benchmark Tools

- **Preflight:** `tools/preflight.sh` checks machine readiness against `~/.config/choose-a-local-llm/machine.md`.
- **Depth sweeps:** Use `llama-benchy` on real code text (or `local-llm-eval-tools` for context-creep sweeps). Helpers for special runtimes live in `tools/sweeps/`.
- **HumanEval+ (fast mode):** `benchmarks/run-humaneval.sh` runs EvalPlus with `reasoning-budget=8192`, `max_tokens=16384`, temperature `0`, and `benchmarks/thinking-budget.py` audits forced/empty counts. Start `benchmarks/run-watch.sh` alongside scoring runs to log memory and catch silent server deaths.
- **Agent coding (Mendel):** Gate full runs with `benchmarks/mendel-smoke.sh` and `benchmarks/loop-check.py`. Full runs execute in the sibling `mendel` benchmark repo and mirror `results*.{csv,json}` and `report*.html` into `benchmarks/mendel/`.
- **Evidence archival:** Run `tools/archive-evidence.sh` before deleting a run worktree so session logs survive under `~/.local/share/choose-a-local-llm/evidence/`.
- **Harness sync:** `npm run pi:models` syncs `contextWindow` and compaction settings into `~/.pi/agent/` from `data/setups/*/models.json`.

## Building & Verifying the Website

```bash
npm install            # once
npm run docs:tables    # regenerate site tables, site-stats.json, and site/files/*
npm run dev            # preview locally at http://localhost:5173
npm run verify         # build site/ and check all internal links
npm run docs:check     # check table drift, hostname leaks in site/, and dead links
```

Run `tests/run.sh` after editing any shared script under `benchmarks/`.
