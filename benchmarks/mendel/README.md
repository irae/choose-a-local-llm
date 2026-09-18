# Mendel benchmark artifacts (mirrored)

Source of truth: the `benchmark` branch of the open-source
[Mendel](https://github.com/irae/mendel/tree/benchmark) repo
(`../mendel` on this machine). This folder mirrors the six artifacts
the site needs. We host them here because we benchmark the local
models.

- `results.csv`: the blind test (terse prompt, base: tag
  `benchmark-blind-base`).
- `results-guided.csv`: the guided test (structured prompt with the
  traps disclosed, base: tag `benchmark-guided-base`). The Mendel
  `PLAN.md` sets which test a model runs.
- `results.json` / `results-guided.json`: the same runs with the
  defect list, the nudge counts and the telemetry. The site-wide
  tables read these, because the CSV has no defects and no nudges.
- `report.html` / `report-guided.html`: the self-contained reports.
  Served verbatim at `/mendel/report.html` and
  `/mendel/report-guided.html` (`tools/sync-static.mjs` copies them to
  `docs/public/` on dev and build; `docs/public/` is gitignored).

`tools/gen-tables.mjs` reads the CSV and the JSON files and draws the
tables on every page that shows a run (`CONTENT-MAP.md`). Do not edit
these files here.

## Refresh procedure

After a run is scored and committed on the Mendel `benchmark` branch:

Follow `EDITOR.md`, "How to import a simulator(mendel) run": all six
files together, the machine ids renamed, then `npm run docs:tables`,
which refuses a partial mirror. Commit the mirror and the regenerated
tables together.
