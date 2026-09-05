# One folder per machine for runs and research

Status: landed 2026-09-05 on branch `hardware-folders`.
Filed 2026-09-05 by the owner during the methodology review.
Needs hardware: no.

## What it is about

The method pages under `docs/methodology/` are hardware-agnostic:
every value that belongs to one machine lives in that machine's file,
`~/.config/choose-a-local-llm/machine.md`, and the published numbers
live on the setup page under `docs/setups/<id>/`. The run kits and the
research runs were not: `benchmarks/bench<N>/` and `research/run<N>/`
sat at the repo root and belonged to one machine, the M1 Max, without
saying so.

## The layout

    hardware/<hardware-id>/
      benchmarks/INDEX.md      the findings index of that machine
      benchmarks/bench<N>/     runbook, state, results of one run
      research/run<N>/         research runbooks and results

`<hardware-id>` is the same id the site uses under `docs/setups/`
(today `m1-max-32gb`).

## What moved

- `benchmarks/bench1` to `bench10` and `benchmarks/INDEX.md` into
  `hardware/m1-max-32gb/benchmarks/`.
- `research/run1` to `run3` into `hardware/m1-max-32gb/research/`.
  The `research/` directory at the root is gone.
- The tracked stray log `benchmarks/mem-watch.log` left the repo.

## What stayed at `benchmarks/`

The shared scripts (`run-humaneval.sh`, `run_codegen_wrapper.py`,
`calibrate.py`, `run-watch.sh`, `evalplus-smoke.py`, `mendel-smoke.sh`,
`loop-check.py`), `PLANNING.md`, `mendel/`, `history/`, and the
calibrations.

## The two open questions, answered

- The shared calibrations (`benchmarks/calibration-*.json` and
  `calibration.md`) stay shared under `benchmarks/` for now. One
  machine measures them today, so a split would add a level and no
  information. Split them when a second machine calibrates.
- `benchmarks/history/` stays at `benchmarks/`. The reports it holds
  are decisions about the method, not measurements of one machine.

## Still open

- Runbooks written from now on read the machine file for apps, limits,
  ports and paths instead of stating them.
- Shared tools that hardcode a machine value (the port in the harness
  scripts, the `lms` path in `tools/mac-services.sh`) read it from the
  machine file or take it as a parameter.
