# Mendel benchmark artifacts (mirrored)

Source of truth: the `benchmark` branch of the open-source
[Mendel](https://github.com/irae/mendel/tree/benchmark) repo
(`../mendel` on this machine). This folder mirrors the four artifacts
the site needs. We host them here because it is us who benchmarks the
local models.

- `results.csv` — the blind test (terse prompt, base `182b07f`).
- `results-guided.csv` — the guided test (structured prompt with the
  traps disclosed, base `4679b5a`). All new runs use this test.
- `report.html` / `report-guided.html` — the self-contained reports.
  Served verbatim at `/mendel/report.html` and
  `/mendel/report-guided.html` (`tools/sync-static.mjs` copies them to
  `docs/public/` on dev and build; `docs/public/` is gitignored).

`tools/gen-tables.mjs` reads the two CSV files and draws the tables on
the site's Mendel page. Do not edit these files here.

## Refresh procedure

After a run is scored and committed on the Mendel `benchmark` branch:

```bash
cp ../mendel/benchmark/{report.html,report-guided.html,results.csv,results-guided.csv} benchmarks/mendel/
npm run docs:tables
```

Commit the mirror and the regenerated tables together.
