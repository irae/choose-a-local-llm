# Extract the Mendel benchmark method into `local-llm-eval-tools/codebase-issue-simulator`

Status: pending owner review; the owner reads this first, then says
start. Nothing started.
Filed: 2026-09-04 at the owner's request; repo and project names set by
the owner the same day.
Needs hardware: no for the extraction and the refactor; a smoke run
against a served model at the end.

## The shape the owner decided

- **One new repository, `local-llm-eval-tools`, holding several
  projects.** Its README says these are the personal tools the owner
  develops to choose a local model for their own hardware and for the
  next hardware they buy, tells a little about this project
  (choose-a-local-llm: the measurements and the site) and cross-links
  it; this repository links back.
- **First project: `codebase-issue-simulator`**, extracted from the
  Mendel `benchmark` branch with its history. Description: have several
  models produce competing implementations for an issue on a GitHub
  repository, through the pi harness, and score the results.
- **Second project later: `slow-context-creep`**, the depth-sweep
  apparatus (`tools/sweeps/creep.py` and its backend files) once it is
  stable. Not part of this item; the repo layout must leave room for it
  (one folder per project, each with its own README, shared nothing at
  the top level but the repo README and a licence).

The extraction below therefore lands in `codebase-issue-simulator/`
inside the new repository, not at its root. `git filter-repo` supports
that with `--path-rename benchmark/:codebase-issue-simulator/`.

## What it is about

The Mendel repository's `benchmark` branch (checked out at
`../mendel-benchmark`, folder `benchmark/`) holds the whole agent
benchmark method this project uses: how a model is given a real
repository task through the pi harness, how the run is kept honest
(nudges, wall clock, tooling budget, evidence archiving), how a run is
scored from a verification battery plus a rubric, how plan-based API
cost is accounted, and how the report is generated (completion cap,
invalid rows, score-line categories). All of that is tied to one task
(Mendel issue 13, replace eight small dependencies) and lives inside
the Mendel repo, so nobody can reuse it on another codebase.

The goal: a new repository that carries that method as a formal
framework, agnostic of Mendel, tailored to do exactly what it does
today: benchmark any code repository task with pi, with the same rigour.
Its history must be the real history of the `benchmark/` folder, not a
fresh copy, so every rule keeps the commit that explains it.

## Step 1 — extract the folder with its history

Work in a fresh clone; never in `../mendel` or `../mendel-benchmark`.

1. `git clone --branch benchmark --single-branch <mendel remote> /tmp/mendel-extract`
2. Install `git filter-repo` (the maintained successor of
   `filter-branch`; `brew install git-filter-repo` or pip).
3. In the clone:
   `git filter-repo --path benchmark/ --path-rename benchmark/:codebase-issue-simulator/`
   This keeps only the commits that touched `benchmark/`, drops every
   Mendel source file from every commit, and moves the folder's
   contents under `codebase-issue-simulator/`. Commit messages, authors and
   dates survive. If some files that belong to the method live
   outside `benchmark/` (check `.gitignore`, `scratchpad/` rules,
   husky or commitlint config that the run scripts depend on), add
   them with more `--path` arguments before running, because the
   filter is one shot.
4. Check the result: `git log --oneline | wc -l` against
   `git -C ../mendel-benchmark log --oneline -- benchmark | wc -l`;
   `git ls-files` shows no Mendel source; the run scripts still
   reference only files that exist.
5. Push to `local-llm-eval-tools` once the owner creates it; the repo
   README and the project README come in the first commit after the
   extracted history. The Mendel
   `benchmark` branch stays as it is; results data (`results*.json`,
   `results*.csv`, `runs/`, the reports) stays in the extracted
   history but is Mendel's data, see step 2.

## Step 2 — separate the generic method from the Mendel task

Inventory of `benchmark/` as of 2026-09-04, sorted by what it is:

Generic (becomes the framework):

- `run-worker.sh` — worktree per run, branch naming with bench and
  thinking-level suffixes, abort on an existing branch, plan probes
  before and after, evidence under `scratchpad/`, per-run pi config
  directory, worker JSON record.
- `run-pi-rpc.mjs` — the pi RPC runner: nudge policy (model nudge on
  unchecked task items, tooling nudge), wall-clock and tooling
  budgets, telemetry (tokens, cache reads, compactions, tool calls
  and errors, peak context), session log.
- `score.mjs` — the evidence pack; `generate-report.mjs` and the two
  report templates — the completion cap, invalid and dimmed rows,
  score-line priority, null-cell gate; `probe-plan.mjs` and
  `estimate-plan-share.mjs` — plan accounting for subscription
  providers; `agents-global.md` v1.0 — the frozen agent rules.
- `PLAN.md` — the law: run procedure, scoring procedure, results
  shape, redaction, plan accounting, invalid-run criteria, best-of and
  re-run categories, credit exhaustion.

Mendel-specific (becomes the first task definition, kept as the
worked example):

- `issue-13.md`, `prompt-blind.txt`, `prompt-guided.txt` and their
  versions (v1.1 blind, v2.1 and v3.0 guided).
- `RUBRIC.md` criteria that name the eight libraries, the traps, the
  house commit style, the `pnpm` and `tap` commands.
- The moving base tags `benchmark-blind-base` and
  `benchmark-guided-base`, the `pnpm install` in the worker, the
  `Mendel Daemon` cleanup, `libraries_done` 0-8 as the completion
  unit.
- `results.json`, `results-guided.json`, the CSVs, `runs/`, the
  generated reports: Mendel's measurements. They belong with the
  Mendel task definition or with this project's `benchmarks/mendel/`
  mirror, not in the framework core.

## Step 3 — the framework shape (proposal, owner decides)

- A **task definition** is a folder: target repository and base ref,
  the issue text, one or more prompt variants with versions, the
  rubric, the verification battery command, the completion unit and
  its maximum (the "8" in `done/8`), cleanup hooks, and the traps a
  guided prompt may disclose.
- The **runner** takes a task, a model id, a harness (pi only at
  first), a thinking level and a variant, and produces the same
  artifacts as today: worker record, session log, runner log,
  telemetry, plan probes, archived evidence.
- The **scorer** produces the evidence pack from the battery, and a
  scoring guide that a strong model applies with the rubric; the
  results file shape stays the one `PLAN.md` documents, with
  `prompt_version`, `invalid`, `best_of`, `reruns`, the raw and
  capped totals.
- The **report** generator reads any task's results and applies the
  same policies. The site in this repository keeps reading
  `results.json` and `results.csv` by the same field names.
- The **rules** (`PLAN.md`, `agents-global.md`) split into the
  framework's law and the task's law. `agents-global.md` stays
  frozen at v1.0 for every existing row; a new version is a new
  results epoch.

## Step 4 — prove it on Mendel

The Mendel task, expressed in the new format, must reproduce one
existing row: same worker command shape, same telemetry fields, same
evidence pack, same report rendering, on an unscored replay of a
cheap model. Only then do new runs use the framework.

## How the agent starts

1. Read this file, then `../mendel-benchmark/benchmark/PLAN.md` end to
   end, then `run-worker.sh` and `run-pi-rpc.mjs`.
2. Read `docs/methodology/mendel.md` and `benchmarks/PLANNING.md` in
   this repository for the house rules the framework must keep
   (worktree-first, no bare stash, one run at a time, credit
   exhaustion is a pause, scoring on a strong model).
3. Do step 1 in a scratch clone and show the owner the commit count
   and file list before anything is pushed.
4. Write the framework plan as a document in the new repository,
   with the inventory above as its first section, and stop for the
   owner's review before refactoring.

## Open for the owner

- Whether Mendel's results data moves with the task definition or
  stays only in the Mendel branch and this project's mirror.
- Whether the first refactor keeps bash plus node, or moves the
  worker to node too.
- The licence of the new repository.
