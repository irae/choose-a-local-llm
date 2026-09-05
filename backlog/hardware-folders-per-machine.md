# One folder per machine for runs and research

Status: filed 2026-09-05 by the owner during the methodology review.
Needs hardware: no.

## What it is about

The method pages under `docs/methodology/` are now hardware-agnostic:
every value that belongs to one machine lives in that machine's file,
`~/.config/choose-a-local-llm/machine.md`, and the published numbers
live on the setup page under `docs/setups/<id>/`. The run kits and the
research runs are not: `benchmarks/bench<N>/` and `research/run<N>/`
sit at the repo root and belong to one machine, the M1 Max, without
saying so. Their runbooks hardcode its apps, ports, limits and paths.

## The target layout

    hardware/<hardware-id>/
      benchmarks/bench<N>/     runbook, state, results of one run
      research/run<N>/         research runbooks and results
      ...                      whatever else belongs to that machine

`<hardware-id>` is the same id the site uses under `docs/setups/`
(today `m1-max-32gb`). Shared tools stay where they are
(`benchmarks/` root scripts and calibrations, `tools/`). The findings
index `benchmarks/INDEX.md` moves with the runs or splits per machine.

## What moves and what changes

- `benchmarks/bench1` to `bench9`, `research/run1` to `run3`: `git mv`
  into the new tree. Every path in `AGENTS.md`, `benchmarks/PLANNING.md`,
  `benchmarks/INDEX.md`, `EDITOR.md`, the method pages and the backlog
  follows.
- Runbooks written from now on read the machine file for apps, limits,
  ports and paths instead of stating them.
- Shared tools that hardcode a machine value (the port in the harness
  scripts, `lms` path in `tools/mac-services.sh`) read it from the
  machine file or take it as a parameter.
- `tools/sync-static.mjs` and any script that globs `benchmarks/`
  gets the new glob.

## Open for the owner

- Whether the shared calibrations (`benchmarks/calibration-*.json`)
  are per machine (they are per config, and a config is per machine)
  or stay shared.
- Whether `benchmarks/history/` stays at the root (decided reports,
  cross-machine) or moves too.
