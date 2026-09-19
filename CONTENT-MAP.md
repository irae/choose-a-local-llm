# Content map

Which source feeds which generated block, and which page that block
lands on. Read it before you add a model, a binary, a row, a score, a
simulator run or a decode curve, so the change reaches every page.
`tools/gen-tables.mjs` is the authority; this file describes it. When
the two disagree, the generator is right and this file is wrong. Run
`node tools/check-content-map.mjs` to find out (it is part of
`npm run docs:check`).

`EDITOR.md` holds the content rules and the page shapes. This file
holds the wiring only. The two must not disagree.

## Sources of truth

| Source | What it holds | Read by |
| --- | --- | --- |
| `docs/setups/<setup>/models.json`, top level | `setup` (the id, also the folder name), `hardwareSlug`, `hardwareName`, the machine facts | every block that names a machine; `hardwareSlug` becomes the `hardware` attribute of a config cell |
| `docs/setups/<setup>/models.json`, `rows[]` | one row per served configuration: `id`, `config`, `spec`, `command`, `note`, `maxCtx`, `gatedBy`, `tokShallow`, `tokDeep`, `memory`, `evalplus`, `evalplusWall`, `simulatorWall`, `mendel` (a state word only), `mendelDrafter`, `stale[]`, `added`, `hidden`, `abandoned`, `retired`, `pi` | every configuration table (`renderTable`), the Configs blocks, the decode summary, the tok/s and window cells of the EvalPlus and Mendel tables, `tools/gen-pi-models.mjs` |
| `docs/setups/<setup>/models.json`, `models.<slug>` | `rowMatch`, `kpis`, `stats`, `extraRows`, `compareWith`, `mendelUntrusted` | the report page of that slug, `docs/models/<slug>.md`, the decode summary |
| `docs/setups/<setup>/models.json`, `evalplusRuns[]` | one entry per scored EvalPlus run: `slug`, `model`, `row` or `spec`, `budget`, `base`, `plus`, `empty`, `emptyCause`, `wall`, `mode` | every EvalPlus table (`renderEvalplusTable`) |
| `docs/setups/<setup>/models.json`, `curves[]` | one entry per measured decode arm: `model`, `arm`, `method`, `points`, `served`, `run`, `c`, `cAt`, `wired` | the decode curve of `docs/models/<slug>.md` only |
| `docs/setups/<setup>/models.json`, `mendelWalls` | active minutes per Mendel branch | the Wall cell of every configuration table and of every Mendel table |
| `docs/binaries.json` | one entry per model file: `id`, `model`, `title`, `spec` (four fields), `repo`, `file`, `revision`, `setups`, `quantAliases` | the `page` link of every config cell on every table, the three blocks of `docs/binaries/<id>.md`, the Files list of `docs/models/<slug>.md` |
| `benchmarks/mendel/results.csv`, `results-guided.csv` | one line per Mendel run, blind and guided, local and cloud | the Coding cell of every row (`deriveMendel`), the report page Mendel block, the binary page Mendel block, the two cloud tables |
| `benchmarks/mendel/results.json`, `results-guided.json` | the same runs with defects, nudges and telemetry | the site-wide Mendel tables, the model page agent table, the stale table |
| `benchmarks/mendel/report.html`, `report-guided.html` | the static reports | served whole at `/mendel/` by `tools/sync-static.mjs`; `checkMendelImport` refuses to generate when the newest JSON run is not in them |
| `tools/gen-tables.mjs`, `MENDEL_SLUGS` | CSV `model` value to page slug | which report page and which model page show a run, and the link of the run's config cell |
| `tools/gen-tables.mjs`, `MENDEL_SPECS` | CSV `model` value to `base`, `quant`, `publisher`, `repo`, `drafter`, and for some `server`, `kv`, `effort`, `binary` | the config cell of every Mendel run, the match of a run to a row (Coding cell, window, speed, Wall) and to a binary page |
| `tools/gen-tables.mjs`, `MENDEL_SERVER` | CSV `serving` value to the server name a row uses | the `server` field of a run's spec when `MENDEL_SPECS` gives none |
| `docs/.vitepress/config.mjs` | nav and sidebar | hand-maintained; a new report page, archive page or model page gets its entry here (`EDITOR.md`, "Site chrome") |

Hand-written prose has no generator. These sections live only where
they are written, and a change to a number must reach them by hand:

| Page kind | Hand-written sections |
| --- | --- |
| `docs/setups/<setup>/reports/<slug>.md` | title, backends line, details line, Highlights, "Model details and findings", the prose under each generated block |
| `docs/setups/<setup>/benchmarks/<slug>.md` | the whole page: the raw archive, every run, every depth |
| `docs/setups/<setup>/comparison.md` | Highlights, the pick tables, footnotes, Legend, "Per-model reports", "Benchmarks" |
| `docs/setups/<setup>/index.md`, `historical.md`, the retired pages | the whole page |
| `docs/models/<slug>.md` | title line, "What the numbers say" and everything after the last marker |
| `docs/models/index.md` | "Choosing a quant or a provider", "Best per machine" |
| `docs/binaries/<id>.md` | title, file line, the three bullets, "Speed and context", "Log", the lines under each generated block |
| `docs/benchmarks/decode-speed.md` | the opening, the two curve matrices, "What this test caught", "Fast is a ticket" |
| `docs/benchmarks/evalplus.md`, `mendel.md` | everything outside the markers, the Legend included |
| `docs/index.md` | Legend, "Machines", "Method" |

## Generated blocks

One line per `writeBlock` or `applyBlock` call of the generator. The
"Generator call" column is the first identifier of the block argument
of that call, as it reads in the code; `tools/check-content-map.mjs`
compares this column with the source. "Reads" says which source and
which filter; `†` marks a filter the page does not state.

| Marker | Page | Generator call | Reads |
| --- | --- | --- | --- |
| `gen:models-evaluated` | `docs/setups/<setup>/comparison.md` | `table` (through `applyTable`; the value is `comparisonTable`, from `renderTable`) | `rows` of that setup, not hidden, not retired, not abandoned, complete; when fewer than two are complete, every visible row |
| `gen:models-evaluated-partial` | `docs/setups/<setup>/comparison.md` | `partial[2]` (the value is `partialTable`, from `renderTable`) | the visible rows the first table left out, at 40 percent completeness or more, or `added` less than 48 hours before the head commit |
| `gen:setup-evalplus` | `docs/setups/<setup>/comparison.md` | `renderEvalplusTable` | `evalplusRuns` of that setup |
| `gen:model-kpis` | `docs/setups/<setup>/reports/<slug>.md` | `renderKpis` | `models.<slug>.kpis` and `stats` |
| `gen:model-table` | `docs/setups/<setup>/reports/<slug>.md` | `renderModelTable` | `rows` whose `config` starts with `models.<slug>.rowMatch`, plus `extraRows`; complete first, then the rest; retired rows as one line each |
| `gen:model-configs` | `docs/setups/<setup>/reports/<slug>.md` | `renderModelConfigs` | the same rows: `spec`, `note`, `command` |
| `gen:model-mendel` (report page) | `docs/setups/<setup>/reports/<slug>.md` | `renderModelMendel` | the CSVs: local runs of that setup, every prompt version, invalid runs included†, runs on a retired build excluded, `MENDEL_SLUGS[model] === slug`; `models.<slug>.mendelUntrusted` for the dagger |
| `gen:model-evalplus` (report page) | `docs/setups/<setup>/reports/<slug>.md` | `renderEvalplusTable` | `evalplusRuns` of that setup with `slug` equal to the page's |
| `gen:models-evaluated:all` | `docs/index.md` | `renderTable` | the best complete row of every model across every setup, not abandoned |
| `gen:models-complete` | `docs/models/index.md` | `renderTable` | every complete row of every setup, not abandoned |
| `gen:models-incomplete` | `docs/models/index.md` | `renderTable` | every other visible row of every setup, not abandoned |
| `gen:model-all` | `docs/models/<slug>.md` | `renderTable` | every visible row of that slug on every setup, not abandoned |
| `gen:model-evalplus` (model page) | `docs/models/<slug>.md` | `renderEvalplusTable` | `evalplusRuns` of every setup with that `slug` |
| `gen:model-mendel` (model page) | `docs/models/<slug>.md` | `renderModelAgent` | the JSONs: local valid runs of every setup, current prompt version only†, runs on a retired build excluded, `MENDEL_SLUGS[model] === slug`. Not the same renderer as the report page: this is the site-wide table with one filter changed |
| `gen:model-curve` | `docs/models/<slug>.md` | `renderModelCurve` | `curves` of every setup with `model === slug` |
| `gen:model-compare` | `docs/models/<slug>.md` | `compare` (from `renderModelCompare`) | the rows of `models.<slug>.compareWith`; written only when a setup names a sibling, so a page with the markers and no sibling keeps its old content† |
| `gen:model-binaries` | `docs/models/<slug>.md` | `lines` | `docs/binaries.json` entries with `model === slug`; the machine names come from `hardwareSlug` of each id in `setups` |
| `gen:binary-rows` | `docs/binaries/<id>.md` | `parts` (from `renderTable`, then one line per retired row) | `rows` of every setup whose four spec fields match the entry (or one of its `quantAliases`); hidden and abandoned included, retired as a bare line |
| `gen:binary-evalplus` | `docs/binaries/<id>.md` | `evalplus` (from `renderEvalplusTable`) | `evalplusRuns` of every setup whose row or spec matches the four fields |
| `gen:binary-mendel` | `docs/binaries/<id>.md` | `mendel` (from `renderModelMendel`) | the CSVs: local valid runs of every setup, every prompt version, runs on retired builds included, spec matched on the four fields |
| `gen:evalplus-table` | `docs/benchmarks/evalplus.md` | `renderEvalplusTable` | `evalplusRuns` of every setup |
| `gen:decode-summary` | `docs/benchmarks/decode-speed.md` | `renderDecodeSummary` | per setup, per model, per backend (the second part of `config`): the best complete row, or the best row |
| `gen:mendel-local` | `docs/benchmarks/mendel.md` | `mendelTable` | `results.json`: local valid runs of every setup, current prompt version, runs on a retired build excluded |
| `gen:mendel-guided` | `docs/benchmarks/mendel.md` | `mendelTable` | `results-guided.json`, the same filter |
| `gen:mendel-cloud` | `docs/benchmarks/mendel.md` | `renderMendelCloud` | `results.csv`: the non-local runs of the current prompt version, as computed for the last setup the generator processed† |
| `gen:mendel-guided-cloud` | `docs/benchmarks/mendel.md` | `renderMendelGuidedCloud` | `results-guided.csv`, the same |
| `gen:mendel-stale` | `docs/benchmarks/mendel.md` | `renderMendelStale` | both JSONs: every run whose branch has no run in the current prompt version |

Calls the check script cannot resolve and lists by name:
`applyBlock(original, marks[0], marks[1], table, target)` is a dead
branch (`marks` is never set, so `applyTable` runs instead);
`applyBlock(updated, partial[0], partial[1], partial[2], target)` is
the partial table above; `applyBlock(original, start, end, block, target)`
is the body of `writeBlock`, whose own calls the table resolves.

Cross-cutting reads that touch every table:

- `specTag` sets `page` on a config cell when `docs/binaries.json`
  has an entry whose four spec fields match. Every table, generated or
  hand-written through `ModelSpec`, links a config to its binary page
  this way.
- `deriveMendel` fills the Coding cell of every row from the CSVs
  before any table is drawn. The `mendel` field of a row is only a
  state word for a row with no matching run.
- `siteRowFor` gives the Mendel tables their window and speed cells
  from the matching row. `mendelWallOf` gives them their Wall from
  `mendelWalls`, then from the run's `wall_clock_min`.
- `checkMendelImport` runs first and stops the generator when the CSV,
  the JSON and the report of one test disagree.
- The cell shape check at the end fails the build on a `TokCell` or
  `CurveCell` written by hand.

## Identity fields (join keys)

| Key | Joins | Where it is read |
| --- | --- | --- |
| row `spec.base`, `spec.quant`, `spec.publisher`, `spec.server` | a row to a binary page; an EvalPlus run to a binary page; a Mendel run to a binary page | `binaryKey`, `buildKey`, `binaryMatch`, `renderEvalplusTable` (`same`) |
| row `spec` (the four fields plus `drafter`, `kv`, `effort`, `adapter`) and the slot count of `command` | a row to its Mendel run: the Coding cell, the window and speed cells of the Mendel tables | `mendelKey`, `deriveMendel`, `siteRowFor`; `mendelDrafter` replaces `drafter` for the match |
| row `config` prefix | a row to `models.<slug>.rowMatch` | `modelRows`, `retiredRows` |
| row `id` | a row to `evalplusRuns[].row` | `renderEvalplusTable` (`rowOf`, `specOf`) |
| `evalplusRuns[].slug` | a run to a report page and a model page, and to the link `benchmarks/<slug>.md` | `renderEvalplusTable` |
| `curves[].model` | an arm to a model page | `renderModelCurve` |
| `models.<slug>` key | a model to `reports/<slug>.md`, `docs/models/<slug>.md`, `binaries.json` `model`, `MENDEL_SLUGS` values | the main loop, `writeBlock` calls, `renderModelCompare` |
| CSV `model` value | a Mendel run to `MENDEL_SLUGS` (its page) and `MENDEL_SPECS` (its spec) | `mendelSpec`, `mendelCell`, `renderModelMendel`, `renderModelAgent` |
| CSV `model` value suffix `, <setup>)` | a Mendel run to its machine; a run with no suffix is the Mac's | `hardwareOf` (the CSV has no `hardware` column) |
| CSV `branch` | a Mendel run to `mendelWalls`, to its thinking level (`-<level>-`) and to its slot count (`-<n>x`) | `mendelWallOf`, `thinkingLevel`, `runSlots` |
| `binaries.json` `setups[]` | an entry to the machines whose `hardwareSlug` labels its Files line | `writeBlock` of `gen:model-binaries` |
| `models.<slug>.kpis[]` | a box to `stats` | `renderKpis` |

## What breaks when a key is wrong

| Wrong key | What the reader sees |
| --- | --- |
| row `spec` four fields differ from every `binaries.json` entry | the config cell has no link on every table; the binary page says "No configuration row." or lacks the row. The build passes. |
| `binaries.json` entry with no `docs/binaries/<id>.md` | the generator prints `binary page missing` and goes on; every config cell of that file links to a page that does not exist, and `npm run verify` fails on the dead link |
| `models.<slug>.rowMatch` does not match a row's `config` | the row is missing from the report table, the Configs blocks, the model page and the decode summary; it still shows on the comparison and on the binary page |
| `evalplusRuns[].slug` wrong | the run is missing from the report page and the model page; it still shows on the comparison and on the HumanEval+ page, with a link to `benchmarks/<slug>.md` that `npm run verify` reports dead |
| `evalplusRuns[].row` names no row and the entry has no `spec` | the build fails: "names no row and no spec" |
| `evalplusRuns[].spec` differs from the row's | the tok/s cell shows `—`; the binary page lacks the run |
| `curves[].model` wrong | the arm is missing from the model page; the page says "No decode curve recorded yet." when it was the only arm |
| CSV `model` value not in `MENDEL_SPECS` | the build fails: "has no entry in MENDEL_SPECS" |
| CSV `model` value not in `MENDEL_SLUGS` | no error. The site-wide tables show the run with an unlinked config cell; the report page and the model page omit the run; the binary page still shows it |
| `MENDEL_SPECS` fields differ from the row's `spec` (drafter, kv or effort included) | the row's Coding cell stays at its state word on every table; the Mendel tables show `—` for window and speed; the binary page omits the run |
| CSV `model` value lacks `, <setup>)` for a run on a machine that is not the Mac | the run is credited to `kamaji`: it appears on the Mac's pages and not on its own machine's |
| CSV `branch` differs from the `mendelWalls` key | Wall falls back to the run's own `wall_clock_min`, pauses included |
| `models.<slug>.kpis` names a stat that does not exist | the build fails: "has no entry in stats" |
| a `gen:` marker missing on a page the generator writes | the build fails: "missing or malformed ... markers" |
| a `gen:` marker on a page the generator does not write | no error. The block keeps stale content forever. `tools/check-content-map.mjs` reports it |

## Findings

Checked on 2026-09-18 against the generator and the pages.

- `docs/setups/arrietty/models.json` row `qwen38-oblit-q4km-medium`
  (Q4_K_M, OBLITERATUS) matches no `docs/binaries.json` entry. Its
  config cell has no link on `docs/setups/arrietty/reports/qwen3.8-27b.md`
  and on `docs/models/qwen3.8-27b.md`, and no binary page holds it.
  `EDITOR.md` asks for one page per model file. The check script
  reports this as a warning.
- The two cloud tables of `docs/benchmarks/mendel.md` use the current
  prompt version of the last setup the generator processed (the last
  `docs/setups/*/models.json` in glob order). Today both setups carry
  the newest version, so the tables agree with the data.
- `gen:model-mendel` names two different tables: the report page reads
  the CSVs across every prompt version and the model page reads the
  JSONs at the current version. A reader who compares the two sees
  different row counts by design.
- `gen:model-compare` is written only when `compareWith` is set. Both
  pages that carry the markers have a sibling today.

## Re-index the tree

Run this after any change to `tools/gen-tables.mjs`, so the map stays
true. Every step is mechanical. No step needs judgment.

1. Run `node tools/check-content-map.mjs`. Exit 0 and one line
   `CONTENT-MAP.md matches tools/gen-tables.mjs: N block calls, M
   markers, M on pages` proves the map, the generator and the pages
   agree on markers and calls. Exit 1 prints one line per mismatch and
   what to fix. Fix the map, not the generator, unless the generator
   is the defect. A `warning:` line does not fail the check; report it.
2. List the calls yourself and compare with the "Generated blocks"
   table: `grep -n "writeBlock(\|applyBlock(" tools/gen-tables.mjs`.
   Every line except the definition `function applyBlock(` is one row
   of the table, or one call named under "Calls the check script
   cannot resolve". The count of lines equals the `N block calls` of
   step 1 plus one.
3. List the markers on the pages and compare with the "Page" column:
   `grep -rhoE "<!-- gen:[^ ]+:start -->" docs | sort | uniq -c`.
   Every marker name is one row of the table (two rows for
   `gen:model-mendel` and `gen:model-evalplus`, which two page kinds
   carry). The count of each marker equals the count of pages of that
   kind.
4. Compare the "Reads" column with the code: for each row, open the
   function the "Generator call" names and read its filters. When a
   filter changed, change the "Reads" cell and the "What breaks"
   table in the same commit. The script cannot check this column; a
   reviewer reads it.
5. Run `node tools/gen-tables.mjs` then `git status --short`. A clean
   status proves the pages match the data. Run `npm run docs:check`;
   exit 0 proves the tables, the map and the links pass.
6. Commit the generator and the map together. The commit message says
   what the generator now does differently.

## Update a model without missing a page

Each list names the files to touch in order, the command, the check,
and the pages to open. The content rules for each file are in
`EDITOR.md`; this file adds only the wiring. For every list, the check
is `node tools/gen-tables.mjs && npm run docs:check`, and `npm run
verify` before the commit. Never edit inside a `gen:` marker.

**Add a new model.** `EDITOR.md`, "How to add a model to an existing
setup", holds the content steps. The wiring:

1. `docs/setups/<setup>/models.json`: add `models.<slug>` with
   `rowMatch`, `kpis` and `stats`, then the rows (see the next list).
2. Create `docs/setups/<setup>/reports/<slug>.md` with the five marker
   pairs of the page shape (`model-kpis`, `model-table`,
   `model-configs`, `model-evalplus`, `model-mendel`), and
   `docs/setups/<setup>/benchmarks/<slug>.md` by hand.
3. Create `docs/models/<slug>.md` with its marker pairs (`model-all`,
   `model-binaries`, `model-curve`, `model-evalplus`, `model-mendel`,
   and `model-compare` only when a setup names `compareWith`).
4. `docs/.vitepress/config.mjs`: the sidebar entries, in sort order.
5. `docs/binaries.json` for each file the model was served from (next
   list).
6. Generate and check. Open: the report page, `docs/models/<slug>.md`,
   `docs/models/index.md` (the row lands in Complete or Incomplete),
   the setup's `comparison.md`, `docs/index.md` (only when the row is
   complete).

**Add a new binary of an existing model.**

1. `docs/binaries.json`: one entry; `spec` carries the four fields
   exactly as the rows write them (`quantAliases` for a second
   spelling), `model` is the page slug, `setups` lists the machine ids.
2. Create `docs/binaries/<id>.md` with the three marker pairs
   (`binary-rows`, `binary-evalplus`, `binary-mendel`) and the
   hand-written sections of `EDITOR.md`, "Binary pages".
3. Generate and check. The check warns when a row matches no entry;
   the generator prints `binary page missing` when an entry has no
   page. Open: `docs/binaries/<id>.md` (the rows table is not "No
   configuration row."), `docs/models/<slug>.md` (the Files list has
   the line, the config cells link), the report page (the config cell
   links).

**Add a configuration row to a setup.**

1. `docs/setups/<setup>/models.json`, `rows[]`: `id`, `config` (starts
   with the model's `rowMatch`), `spec` with every field, `command`,
   `note`, `added` with today's date, the measured cells, and
   `mendel` as a state word. `pi` when the harness serves it.
2. Generate and check. Open: the report page (table and Configs),
   `docs/models/<slug>.md`, the setup's `comparison.md` (the row is in
   the second table for 48 hours whatever its completeness), the
   binary page of its file, `docs/benchmarks/decode-speed.md` when the
   row is the best of its backend.
3. `npm run pi:models` when the row carries a `pi` block
   (`AGENTS.md`, "A missing harness entry").
4. The hand-written surfaces: the setup's `benchmarks/<slug>.md`
   archive and the report's Highlights (`EDITOR.md`, "How to record a
   new measurement").

**Land a new EvalPlus score.**

1. `docs/setups/<setup>/models.json`, `evalplusRuns[]`: one entry with
   `slug`, `row` (the row id; `spec` only for a run with no row),
   `budget`, `base`, `plus`, `empty`, `emptyCause`, `wall`.
2. The row's `evalplus` cell (`base/plus/completion%`) and
   `evalplusWall`; remove `evalplus` from `stale` when it was there.
   Every row that shares the score under the shared-score rule gets
   the same cell.
3. Generate and check. Open: the report page (Quality table and the
   HumanEval+ column), `docs/models/<slug>.md`, the setup's
   `comparison.md` (the Code quality table and the row's cell),
   `docs/benchmarks/evalplus.md`, the binary page, `docs/index.md`
   when the row is the model's best.
4. The archive page and the Highlights by hand.

**Land a new simulator(mendel) run.** `EDITOR.md`, "How to import a
simulator(mendel) run", holds the four artifacts and the mirror
command. The wiring:

1. The CSV `model` value: when it is new, add it to `MENDEL_SLUGS` and
   to `MENDEL_SPECS` in `tools/gen-tables.mjs`, with the same
   `base`, `quant`, `publisher`, `drafter`, and where the row sets them
   `server` and `kv`, as the row's `spec`. A run on a machine that is
   not the Mac carries `, <setup>)` at the end of the value.
2. `docs/setups/<setup>/models.json`, `mendelWalls`: the branch and its
   active minutes.
3. Generate and check. The check fails on a `model` value with no map
   entry. Open: `docs/benchmarks/mendel.md` (the run is in the local
   table, linked), the report page (the Mendel block, and the Coding
   cell of the row now shows the score), `docs/models/<slug>.md` (the
   agent table), the binary page, the setup's `comparison.md`,
   `docs/index.md` when the row is the model's best. A Coding cell
   still at `pending` means the spec match failed: compare the seven
   fields and the slot count.
4. `node tools/sync-static.mjs` and `npm run verify`, so the static
   report is served.

**Add a decode curve.**

1. `docs/setups/<setup>/models.json`, `curves[]`: `model` (the slug),
   `arm`, `method`, `points`, `served`, `run`, and `c` with `cAt` when
   the arm needed its own `-c`; `wired` for a `creep` reading.
2. The row's `tokShallow`, `tokDeep`, `maxCtx`, `gatedBy` when the
   curve is the served arm; remove those fields from `stale`.
3. Generate and check. Open: `docs/models/<slug>.md` (the curve table
   has the arm), the report page and `docs/benchmarks/decode-speed.md`
   when a row changed.
4. The archive page by hand, and the matrix of `decode-speed.md` when
   the arm is current-era.
