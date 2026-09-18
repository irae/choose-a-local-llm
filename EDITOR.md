# Editor guide

The content rules for this site. Not published: the site build ignores
this file because it sits outside `docs/`. Read it before you write or
change any page. It records the owner's choices so they survive across
sessions and agents.

## Sharp conclusions, not stories

We state conclusions. We do not tell stories.

- A current page states what is true now, and the pick it implies. It does
  not narrate how we got there.
- History earns its place only when it justifies a current decision (for
  example: why a number moved, why a config was dropped). Cut everything
  else.
- Do not number or name benchmark runs in prose (no "run 3", "night 3",
  "benchmark run 2"). A run number is an internal detail, not a fact the
  reader needs.
- State progress as one of two words: **tested** or **pending**. Nothing
  in between, no run-count language.
- If a fact needs a source, use a date or a link to the setup's
  `benchmarks/<model>.md` page, not a run number.
- This applies everywhere, including `benchmarks/*.md`. Those pages keep
  the full archive (see "Historical figures" below), but tell rows apart
  by date, not by run number.

## Page shape (model report pages)

Every report page uses this order. Do not reorder it.

1. **Title.** "model on hardware".
2. **Backends line.** The backends used and a Hugging Face model link.
   No dates.
3. **Stat boxes.** The generated `kpis` row (see the generated-blocks
   section below).
4. **Details line.** One or two lines of prose: benchmark dates, builds,
   whatever the numbers need. Never longer; it is metadata, not a
   summary.
5. **Highlights.** 2 to 4 bullet points. Short lines. No paragraph
   blobs.
6. **All configs — this model.** The generated per-model table.
7. **Configs.** One block per config with its startup command. Label
   configs descriptively. Do not crown a "best option": the pick, when
   one exists, lives in a "Which to pick" table, not in prose.
8. **Model details and findings.** The prose: configs compared with
   each other; brief historical pointers allowed.
9. **Everything else.** The measured data tables, then the method
   footer.

The rule behind the order: a reader must get the answer from the boxes,
the bullets, and a table. Nobody should have to read a paragraph to
learn which config is fastest.

Do not open a page with a prose summary. The only prose above the
Highlights is the two-line details line.

## Words

- Say **"benchmark run"** if a run must be named at all, never "night run",
  "night agent", or "overnight". Prefer not naming it; see "Sharp
  conclusions, not stories" above.
- Do not tell apart work run by hand from work run unattended. The reader
  does not care who was awake. A measurement is a measurement.
- Write all prose in ASD-STE100 Simplified Technical English: short
  sentences, active voice, one idea per sentence, one word for one meaning.

Run kits live in `hardware/<hardware-id>/benchmarks/bench<N>/` (runbook
`AGENT.md`, log `state.md`, results), research kits in
`hardware/<hardware-id>/research/run<N>/`. `<hardware-id>` is the setup
id under `docs/setups/`, the machine's hostname (`AGENTS.md`). Page
titles, sidebar labels and link text name the hardware, because that
is what a reader looks for; the path under them is the id. Shared run
tools sit in `benchmarks/`.
`hardware/<hardware-id>/benchmarks/INDEX.md` is the per-run findings
index; add each run's most interesting findings there when the run
closes. None of it is site content.

## Format

- Markdown only. There are no raw HTML pages left, and there should be none.
  A Markdown page gets the nav, the sidebar, search, dark mode, and the
  footer.
- Server commands go in fenced `bash` blocks, so they stay copy-paste ready.
  The `--alias` value equals the harness model id.
- Tables carry the numbers. Bold the winning row.
- **A decode-speed table has one row per configuration**, depth
  buckets as columns, and a last column that says what capped the
  curve. The comparison page's "Decode speed vs used context" is the
  model; every report page's section copies its shape and links to it.
  Never put depth in the rows: with one column per config a reader
  cannot compare two runtimes without reading down two columns, and a
  config that was measured at other depths leaves a hole that looks
  like a missing measurement. Values deeper than the last column go in
  the "capped by" cell.
- **Every configuration named in a table says its KV cache type.**
  The type sets the depth curve on this hardware, so a row without it
  is not a configuration, it is a guess. Write it as `f16 KV`,
  `q8_0 KV`, `q4_0 KV`, never as a bare `f16` or `q8` that a reader
  can confuse with the weight quant or the drafter. A server with no
  KV option still says the type it runs. The one exception: when every
  row of a table uses the same type, the sentence above the table says
  which, and the labels leave it out. Historical pages are archive and
  keep their original labels.
- No code comments unless the owner asks for them.

## Generated blocks and limits on model report pages

These rules bind every `reports/<model>.md` page:

- **Highlights hold 2 to 4 bullets. Never more.** Merge or cut; the
  detail lives in the tables and in History and reasoning.
- **Every report page opens with the stat boxes** (the `kpis` row,
  directly under the title line) **and carries an "All configs — this
  model" table** (the first table section). `npm run docs:tables`
  generates both, between `<!-- gen:model-kpis:... -->` and
  `<!-- gen:model-table:... -->` markers. Never hand-edit inside the
  markers, never remove them. `npm run docs:check` fails on drift.
- **A stat box qualifies its number; it does not explain it** (owner,
  2026-09-12). The value is at most 22 characters, the label at most
  44, and an optional `sub` line at most 44; no semicolons, no
  dashes, no second clause. An EvalPlus box shows `base / plus` as
  the number and the completion on the `sub` line. The generator
  fails the build on a longer or clause-shaped text.
- **Stats are centralized** in `models.json` under
  `models.<page-slug>.stats`. Keep an excess of stats there (every
  number worth quoting: speeds, ceilings, scores, footprints), each as
  `{value, label}`. The page shows only the 2-4 names listed in
  `models.<page-slug>.kpis`. Picking them is an editorial choice made
  here or by the owner, not by adding markup to the page.
- **The per-model table repeats the comparison table filtered to this
  model and all its variants.** Rows come from the shared `rows` list
  (matched by `models.<page-slug>.rowMatch`). Old or abandoned variants
  may be added as `models.<page-slug>.extraRows` and may be incomplete.
- **Every report page carries an "Agentic quality — Mendel" section**
  with one row per Mendel run of that model, every prompt version,
  in two tables: blind first, then guided, never mixed. `npm run docs:tables` generates it from
  `benchmarks/mendel/results.csv` and
  `benchmarks/mendel/results-guided.csv`, between
  `<!-- gen:model-mendel:... -->` markers. A model with no run gets a
  one-line block. Add the model to `MENDEL_SLUGS` in
  `tools/gen-tables.mjs` when a run uses a new `model` value. A run on
  a configuration the project no longer trusts gets a † on its config
  cell and one legend line with the reason; the list is
  `models.<page-slug>.mendelUntrusted` in `models.json`, one entry per
  config with `serving` (and an optional `branch` regex) and `reason`.
- **Every EvalPlus table on a setup page is generated** (2026-09-16):
  the comparison page's "Code quality" table sits between
  `<!-- gen:setup-evalplus:... -->` markers and holds every
  `evalplusRuns` entry of that setup; each report page's "Quality"
  table sits between `<!-- gen:model-evalplus:... -->` markers and
  holds the entries whose `slug` is the page's. Both come from
  `models.json`, so a new score reaches every page on the next
  `docs:tables` run. Never hand-write an EvalPlus table on those pages
  again; the prose under the markers stays hand-written.
- **Config numbers go at the end of table lines as `#1`, `#2`**, never
  as a `1:`/`2:` prefix.
- **Every row in `models.json` carries a mnemonic `id`, a `hidden`
  flag, and its `command`**, plus an optional one-line `note`. A note
  is never a param-change instruction; a different set of params is a
  different row. `hidden: true` removes the row from every table and
  its config block on the next `docs:tables` run. Use it instead of
  deleting.
  A `retired` block (`date`, `reason`, `details`) hides the row the same
  way and also strips it to a bare record. Use `hidden` when a config
  keeps its numbers and waits for a re-measurement. Use `retired` when
  the config itself is withdrawn and its numbers must leave the data;
  the model's report page then carries one "Retired entries" line under
  its table, pointing at the evidence.
- **Every retired backend and every retired model or build has its own
  page** (owner, 2026-09-14), for example `lmstudio-retired.md`. A
  table that shows a retired row links that page in the note that
  follows the table; the row's `abandoned.page` or `retired.details`
  names it. The Mendel runs of a retired build leave every generated
  table and show only on that page, as evidence.
- **The Configs section is generated** between
  `<!-- gen:model-configs:... -->` markers: one block per visible row,
  its spec line first, then the note, then its exact startup command.
  Never hand-edit inside. Never write prose that tells the reader to
  change a parameter.
- **Rows have no numbers.** Prose names a row by the words of its
  spec line ("the fork at f16 KV", "the MLX 2-bit row at thinking
  on"), never by a position in a table.
- **Every stat box must be backed by the page's tables.** The number a
  box quotes appears in a table row on the same page, or that row marks
  it `pending`. A box never quotes a figure the tables do not carry.
- **Every serving config a page gives a command for gets its own table
  row**, incomplete cells allowed (`pending`). Scores are shared across
  rows when thinking mode, effort, and quant match, whatever the
  context size, slot count, tok/s, or what gates the config.
- **The `evalplus` field holds three values: `base/plus/completion%`**,
  for example `0.976/0.945/100%`. Completion is (164 minus the empty
  completion count) over 164, rounded to the nearest whole percent. A
  row that carries its score from another row under the shared-score
  rule also carries that row's completion. Write `base/plus/—` only
  when no empty count exists anywhere for the score.

## Binary pages (`docs/binaries/<id>.md`)

One page per model file, across every machine (owner, 2026-09-16). It
aggregates every run of that file on every machine: every
configuration row, hidden and abandoned ones included, retired rows as
a bare line; every EvalPlus run; every valid Mendel run of every
prompt version, runs on retired builds included. A run a harness or
serving defect voided is not shown. The list of binaries is
`docs/binaries.json`: `id`, `model`, `title`, `spec` with base, quant,
publisher and server, `repo`, `file`, optional `revision`, `setups`
(the machines that served the file) and optional `quantAliases`. A row
belongs to a page when the four spec fields match. The pages get no
sidebar entries; each model page under `docs/models/` carries a
generated "Files" list that links them.

Page shape, in this order:

1. Title: the binary title. No machine name in it.
2. File line: the Hub link, the file name, the revision when known,
   the size, the server. One sentence that says the page holds every
   run of the file on every machine, retired rows included, voided
   runs excluded.
3. Three bullets: why the file is here, what it settled, where it
   stands. The owner's decisions in the owner's words where they
   exist. When more than one machine served the file, the bullets
   compare the machines and give both numbers.
4. **Configurations**: the generated block between
   `<!-- gen:binary-rows:... -->` markers.
5. **Quality — EvalPlus HumanEval+**: the generated block between
   `<!-- gen:binary-evalplus:... -->` markers, then one or two lines
   on the cause of the empties.
6. **Agent task — Mendel, every prompt version**: the generated block
   between `<!-- gen:binary-mendel:... -->` markers, then one or two
   lines that say how the rows ended.
7. **Speed and context**: a hand-written table, one row per
   measurement, with date, config and result, and a `ModelSpec` line
   under the heading. When more than one machine served the file, the
   table has a machine column. Full curves stay on the archive page;
   link it.
8. **Log**: chronological bullets, oldest first, one per event: the
   date, what happened in one to three sentences, and the pointer to
   the run kit folder (`hardware/<id>/benchmarks/bench<N>/`) or the
   research kit. When more than one machine served the file, each
   bullet names the machine. A run number appears only inside that
   path. The last bullet may say what is pending.

Links resolve from `docs/binaries/`: archive pages are
`../setups/<setup>/benchmarks/<model>.md`, reports are
`../setups/<setup>/reports/<model>.md`, method pages are
`../methodology/...`, retired pages are `../setups/kamaji/<name>.md`.

Never hand-edit inside the markers. `npm run docs:tables` fills the
three blocks and warns when a listed binary has no page.

Every generated config cell links its model name to the binary page
of that file: the generator sets the `page` attribute of `ModelSpec`
when a `docs/binaries.json` entry matches the four spec fields. A
hand-written `ModelSpec` line carries no link unless it names `page`.

## The decode-speed page (`benchmarks/decode-speed.md`)

This page is a written story, not a data dump. Keep its shape when you
update it:

1. **The opening stays the hook.** The 1.7 tok/s origin observation,
   why the test runs first, the two reading rules (the 8 tok/s floor;
   used vs allocated), and the one-sentence gate warning (EvalPlus and
   Mendel drop slow-but-low scorers anyway). Do not grow it past two
   paragraphs plus the two bullets.
2. **The summary table is generated** (`gen:decode-summary` markers):
   one row per model/backend pair, from `models.json`. Never hand-edit
   inside the markers; it updates itself when rows change.
3. **The two curve matrices are hand-maintained and current-era only.**
   One matrix per measured rule (MLX side: flat then OOM; llama side:
   decay, never OOM). A new config becomes a column in the matrix its
   behaviour matches. A third matrix needs a new measured rule, not a
   new model. Endpoints are marked inline in the cell (**last
   stable**, *OOM*, *floor*, *window end*, *compression onset*).
   Superseded readings leave the matrix; they live in `historical.md`
   and the per-model archives. Mark old-era series with the † marker
   in the column header (or cell), consistent with the `stale` arrays.
4. **"What this test caught" stays selective.** Only findings that
   changed a rule or retired a number, 3-5 bullets, each one short
   line pair. It is not a changelog.
5. **"Fast is a ticket, not a win" stays**, with a live example of a
   fast config dropped on quality. Update the example if a better one
   appears; never delete the section.
6. **Full curves never move here.** They stay on the per-model archive
   pages, linked only in the footer.

New benchmark-type pages (evalplus, mendel) grow toward this
same shape: story first, generated summary, selective findings,
archives at the bottom.

## The "Models evaluated" table

This table (in `docs/index.md` and each setup's `comparison.md`) has its
own rules, on top of the ones above.

**The table is generated, never hand-edited.** Its source of truth is
`docs/setups/<setup>/models.json`: one row per config, holding only the
current, measured value for each field, no history array. Edit the JSON,
then run `npm run docs:tables` to write both copies. Do not touch the
markdown between the `<!-- gen:models-evaluated:start -->` /
`<!-- gen:models-evaluated:end -->` markers; the next `docs:tables` run
overwrites it. `npm run docs:check` fails the build if either copy has
drifted from the JSON, so a forgotten regeneration cannot reach the
site. The generator sorts rows by the average of the two quality
scores, the EvalPlus base pass@1 times 100 and the simulator(mendel)
score the Coding cell shows, descending. A pending score counts as 0
in that average (owner, 2026-09-15), so a row with one score sorts
under the rows with both of the same level; EvalPlus, then Ctx
(descending), break ties. Nothing else moves a row up: speed, window, memory and
completeness are read from the row, not ranked.

**Completeness is a score, not a flag** (owner, 2026-09-11). Three
measurements count, one point each: tok/s, EvalPlus, and
simulator(mendel). A `pending` tok/s cell, a `pending` EvalPlus
cell, or a simulator(mendel) cell that is not a number (`pending`,
`not run`, `invalid`) loses its point. A `(partial)` score is a
number and counts, and so does a `model-failed` or `failed-smoke`
cell, a score of 0. A row at 3 of 3 is complete.

The published pages keep the word Mendel for now; the rules and the
runbooks say simulator(mendel), the name of the runner that replaces
it.

- **Columns, in order**: Model / Config | Ctx | Cap | tok/s | Memory
  (at max ctx) | HumanEval+ | Coding | Wall. No superscript on a header: the
  columns are explained in a "Legend" section under the table.
- **HumanEval+ in headers, EvalPlus inside** (owner, 2026-09-15). EvalPlus
  is our name for the tool and the test, and prose, notes, data fields and
  the method page keep it. Column headers, the global benchmark page and its
  sidebar entry say HumanEval+, the name readers know.
- **Wall is the active time of the scored EvalPlus run and of the scored
  Mendel run**, shown as their sum, with both parts in the cell's hover
  title and a `†` when one part has no time; pauses removed and split runs added (owner, 2026-09-15). `evalplusWall` and `simulatorWall` in
  `models.json`, in minutes. `mendelWalls` in the same file holds the
  active minutes of every local Mendel run of that setup, by branch, kept
  even for runs no table shows; the Mendel side reads it, then the run's
  `wall_clock_min`, unless a row's `simulatorWall` overrides both. Smokes,
  calibrations, creeps and sweeps never count. Speed and creep tables
  carry no Wall column. Wall does not move the sort.
- **The tok/s cell is the `TokCell` component**: shallow, a muted
  arrow with no space around it, deep, each number rounded to one
  decimal and padded with leading spaces to four characters, in a
  fixed-width run so the decimal points and the arrows line up down
  the column, at a slightly smaller size. The stale dagger sits once,
  in the text font, before the run. The data keeps its own precision;
  only the cell rounds.
  **The Config cell is the leftmost column of every table that has
  one**, generated or hand-written.
- **The Config cell is the `ModelSpec` component** (owner,
  2026-09-11), two lines, the same on every table: line one is the
  base model and the weight quant; line two, smaller, is the
  publisher and the server, then an optional drafter pill (`mtp/3`,
  `dspark`; no drafter, no pill), the KV type (`f16`, `q8_0`,
  `q4_0`; "unquantized" is `f16`) and a coloured effort pill (`off`
  grey, `low` blue, `medium` green, `on` and `high` yellow, `xhigh`
  and `max` red). The effort is the model's own value: a
  binary-thinking model says `on` or `off`, a graded model says its
  level. The publisher is plain underlined text that links to the
  Hugging Face model card, never a pill; the card comes
  from the row's command or `spec.repo`. The data is the row's `spec`
  object in `models.json`; a Mendel row's spec comes from
  `MENDEL_SPECS` in `tools/gen-tables.mjs`. A missing or invalid field
  fails the build.
- **Every EvalPlus table has a `config` column rendered by
  `ModelSpec` and a `budget` column**; the budget never sits inside
  the config text. The generated table on the EvalPlus page reads
  each run's spec from `evalplusRuns[].row` (a row id) or an explicit
  `spec`, and its `budget` field.
- **The EvalPlus cell is two lines**: `base/plus` over the completion
  percentage. **The Coding cell is two lines**: the score, with a
  partial's libraries-done percentage muted before it (`38% / 37.5`),
  over the test pill.
- **Bold marks the best two of every numeric column**, and any further
  row within 15 percent of the column's span (best minus worst) of
  the second-best value; memory reads lower as better. The Config cell goes bold for the best two composites.
- **Memory (at max ctx) shows on model pages only**; the homepage and
  the comparison drop the column.
- **Cap is `mem` or `speed`, nothing else.** A row that ended at
  its `-c` or at its depth list's end is `mem`: the allocation is a
  memory choice, and the note says how it was found.
  **Detail tables** (decode curves, drafter sweeps, KV comparisons)
  keep their own columns and put one `<ModelSpec … />` line directly
  under the heading with every field the rows share; `hide` lists
  the fields the rows vary, comma separated (`hide="kv,effort"`), and
  those are neither required nor shown. What the line says leaves
  the heading and the row labels: no "f16 KV" in a title, no "llama"
  at the start of every row, once the spec line carries them.
- **The Coding cell is the `ScoreCell` component with a `pill`**: the
  score on line one, with a partial's completion percentage muted
  before it and a slash; the test pill alone on line two, `mendel-blind` in
  yellow or `mendel-guided` in green.
- **The Coding cell comes from the Mendel CSVs, never from
  `models.json`** (owner rule, 2026-09-12). The generator takes every
  valid run of the current prompt version, blind and guided, whose
  spec matches the row (build, server, drafter, KV type, thinking
  level, slot count), and shows the run with the most libraries done,
  then the higher capped score. A row whose served drafter changed
  after its run names the run's drafter in `mendelDrafter`, since the
  drafter changes speed and not output; the note says so. It shows
  the run with the most libraries done,
  then the higher capped score. A guided run can therefore stand on
  the comparison and the homepage. The `mendel` field in
  `models.json` holds only a state word for a row with no such run:
  `pending` when one is planned; `not run` when none is planned, with
  the reason in the row's note; `invalid` when every attempt failed
  on the harness or the server; `model-failed` when the model's own
  failure left zero commits; `failed-smoke` when the config failed its
  agent smoke. `model-failed` and `failed-smoke` render as `0% / 0`
  over a pill with that name and count as a score of 0. A picked run
  with zero commits renders the same `model-failed` cell (owner,
  2026-09-14). A number in that field fails the build.
- **The homepage table holds one line per build** (the first two
  parts of the config: model, then runtime and quant with its
  publisher), showing that build's best complete row by the same sort.
  A model with three builds gets three lines.
- **The comparison page holds two tables.** The first, inside the
  `gen:models-evaluated` markers, holds every complete row. After the
  footnotes and legends comes the second, inside the
  `gen:models-evaluated-partial` markers: every row at 40 percent
  completeness or more that is not complete, in the same sort. A row
  under 40 percent stays on its model page only.
- **A table with fewer than two rows shows every row it can hold**
  (owner, 2026-09-14). The generator applies the filters above; when a
  filter leaves a table with fewer than two rows, that table shows
  every row it could hold, and a note under it says so. The first
  table can hold every visible row; the second can hold every visible
  row the first did not show. The rule is code in
  `tools/gen-tables.mjs`, the same path for every setup; it exists so
  a new setup under test shows its partial rows.
- **A new row shows for 48 hours whatever its completeness** (owner,
  2026-09-14). A row carries `"added": "<YYYY-MM-DD>"` when it enters
  `models.json`; while that date is less than 48 hours before the newest
  commit, the second comparison table shows the row even under 40
  percent. The clock is the commit time, so a commit always generates
  the same tables.
- **Per-model tables use the same sort as every other table.** The
  page shows every visible row of the model in two tables inside one
  marker pair: the complete rows first, then one note line, then
  every other row; the Configs blocks follow the same order. There
  is no "Suggested for" column; seat suggestions live only in the
  setup overview and in analysis/decision prose.
- **One row per config; a model shows every runtime that has sweep
  data** (MLX and GGUF rows side by side), grouped by model.
- **The `config` string in `models.json` stays as the row's name for
  matching and sorting; the page renders `spec`.** Config is a comma
  list: Model, Runtime, Details. Model is the
  HuggingFace repo name. A MoE model carries its active-parameter spec
  in the name (Qwen3.6-35B-A3B, Gemma-4-26B-A4B); a dense model is a
  plain size (Qwen3.8-27B), and the missing A-suffix marks it dense.
  Runtime is the model's download/weight format only, `MLX` or `GGUF`,
  never a specific server, tool, or fork name (no "LM Studio", "prism
  fork", "lms CLI", "mlx_lm.server", "llama"). Details is optional
  (quant, MTP, thinking mode, and similar) and can be dropped if there
  is nothing to add. A scored row states its thinking mode ("thinking
  on/off", or "effort medium" for graded-effort models). No invented
  shorthand: write "compaction ~26k", not "compact". Do not mention
  slot count here; see multi-agent rows below.
- **The EvalPlus legend entry says**: one score per model and
  thinking mode. Runtimes at standard quants share it. Aggressive
  quants (calibrated q4 KV and similar) gate separately and show
  "pending" until they pass. Scores never propagate across thinking
  modes. It names the calibrated output budget and its 30000-token
  cap, and that a problem at the cap counts as failed. The cause of an
  empty count is one of three words: `budget` (the answer was still
  coming when the output budget ran out), `model` (the model ended with
  no answer and budget was left) and `† unproven` (the run recorded no
  finish reason). `emptyCause` in `models.json` carries it as `none`,
  `N budget`, `N model` or `† unproven`, and the HumanEval+ page
  explains the three words under its limits table.
- **Stale cells carry the † marker (superseded, re-run pending)**: a
  value measured under an earlier serving config or method (a retired
  wired limit, a fast sweep, a pre-calibration config) that the current
  method has not re-measured yet. It is derived data. Each row's
  `stale` array in `models.json` lists the affected field names, and
  the generator renders the marker and its legend on every table that
  shows one. When a new run lands, write the new value and remove the
  field from `stale`. Nothing else to touch; every table updates on the
  next `docs:tables` run.
- **The Legend section follows the table's footnotes**, one bullet
  per column in table order: Ctx (the usable context and the harness
  window it sets), Cap (what memory holds, the 8 tok/s floor, `mem`
  and `speed`), tok/s (shallow then deep, why depth matters, the
  drafter read on real text), EvalPlus, Coding (the simulated pull
  request, nudges, blind against guided, the pick rule, the sort).
  The homepage and the comparison carry the same legend; the
  comparison adds its page-specific facts.
- **A row served by a custom binary or fork gets its own footnote**,
  attached directly to the Runtime abbreviation in Config (for example
  "MLX¹"), not to any other cell. The same fork reuses its number across
  every row that uses it. Number them ¹, ², ... in the order they first
  appear in the table.
- **Each footnote is its own paragraph below the table**, before the
  Legend: a blank line between ¹, ², and so on, not one run-on block.
  The † legend line stays inside the generated block, first.
- **Multi-agent configs** show the slot count in **Ctx** as
  "Nx\<size\>", for example "2x48k", never in Config.
- **Ctx** (the used-context point where a config first breaks): the
  cell must end with the number and its unit, never a trailing word like
  "per slot". An `mlx_lm.server` row shows its harness window, the
  row's `pi.contextWindow`, 5 percent under the measured ceiling
  (`docs/methodology/mendel.md`, "Window and budget"), never the
  ceiling; the note keeps the ceiling.
- **tok/s is two numbers only**, shallow then deep, never a
  qualifier word like "solo" or "concurrent" in the cell. For a
  multi-slot config, the number is one slot decoding alone (see
  methodology). If the method needs explaining, that explanation goes in
  the methodology, not as a note on this table.
- **"Memory (at max ctx)" is one number only**: the max figure reached,
  nothing else. No "flat", no "grows to", no qualifier of any kind. Its
  header breaks onto two lines before the parenthesis (`<br>`), so the
  column stays narrow.

## Stable values only

A ceiling sweep finds a last stable depth and, past it, a death point.
The site renders the stable value only: the deepest depth that still
served correctly, with its tok/s. The death point and the unstable
bracket ("OOM at X-YK") never appear on a page; they stay in the run
logs. This holds for "Max ctx" cells, "capped by" cells, and prose.

## Historical figures

**No superseded number appears on a current page.** Not in a table, not in
prose. This is the owner's rule, and the methodology's record-everywhere rule says the same.

- A current page states the current number and, if the story needs it, says
  a correction happened, without repeating the old figure.
- The old figure moves to the setup's `historical.md`, with a line that
  says what makes it wrong: the retired 27000 wired limit, an uncalibrated
  output budget, or an axis the depth sweeps replaced.
- Link to the historical page from wherever the old number used to be, and
  say plainly that those numbers are not to be used.
- The `benchmarks/*.md` pages are the exception. They keep the full archive,
  because that is their job. Every section there states the wired limit
  and the date it was measured, not a run number.
- `historical.md` orders sections newest-first: the newest supersession
  goes at the top, directly under the summary. The summary block always
  stays at the top so a reader knows what the page is before any table.
- The red warning block at the top of `historical.md` must stay. It is the
  first thing a reader sees on that page.

## Site chrome

- The models in the sidebar are listed by their best row's sort key,
  the same average of EvalPlus base and Coding the comparison uses,
  best first; a model with no complete row goes last. The list is
  hand-maintained in `docs/.vitepress/config.mjs`; re-order it in the
  same commit that moves a model's best row.

- Footer: copyright Irae Carvalho, plus a link to https://github.com/irae.
- The owner's name and GitHub link belong on every page, through the theme
  footer. Do not repeat them in page content.
- Layout widths live in `docs/.vitepress/theme/custom.css`. The content
  column is capped at 1280px and the layout at 1920px, both as `max-width`
  so they still shrink on small screens. The content rule needs
  `!important`: the theme's own 688px cap is scoped CSS with a
  build-generated hash that changes between VitePress versions.

## How to run the site

```bash
npm install                      # once
npm run dev                      # write and preview, http://localhost:5173
npm run verify                   # build + link check
npm run deploy -- "what changed" # build, verify, commit. Stops before pushing.
```

If another agent already serves on 5173: `npm run dev -- --port 5174`.

`npm run dev` costs much more memory than `npm run preview`. When a model
server holds the GPU and the machine is swapping, use `npm run verify` then
`npm run preview`.

You never set the base path, the sitemap, the workflow, or the Pages source.
They are wired already.

## Where things live

```
docs/
  .vitepress/config.mjs        nav, sidebar, search, footer
  .vitepress/theme/custom.css  layout widths, footer visibility
  index.md                     home: what the project measures, per-setup summary
  methodology.md               the flow. The rules for every test cycle.
  website-plan.md              site architecture and phases. Excluded from the site.
  setups/<setup>/
    index.md                   the machine, its models, current state
    comparison.md              cross-model tables for that setup
    reports/<model>.md         one page per model
    benchmarks/<type>.md       cross-model page per benchmark type
                               (decode-speed, evalplus, mendel).
                               These are in the sidebar,
                               ordered as the tests usually run
    benchmarks/<model>.md      full raw data per model, current and
                               historical. Linked from the model page
                               and the type pages, NOT in the sidebar;
                               keep updating them
    historical.md              superseded measurements, with a danger warning
```

Anything outside `docs/` never reaches the site. That is where
`benchmarks/`, `HANDOFF.md`, this file, and `AGENTS.md` live.

## How to record a new measurement

The methodology's record-everywhere rule binds you: a result is not
recorded until every surface agrees. Change all of these in the same pass.

1. `docs/setups/<setup>/benchmarks/<model>.md`: the full data, including
   the runs that did not win.
2. `docs/setups/<setup>/reports/<model>.md`: the tables, and the
   Highlights bullets at the top. The bullets go stale first; they are the
   part a reader reads.
3. `docs/setups/<setup>/comparison.md`: the depth table, the quality table,
   and the seat table if the pick changed.
4. `docs/index.md`: only if a seat changed or a "best X" bullet changed.
5. `~/.pi/agent/models.json`: the harness config. Not in this repo.

If a new wired limit supersedes a number, move the old one into the
setup's `historical.md`; do not delete it.

## Decode curves on a model page

Each model page ends with one table: every arm that was measured for
that model, on every machine, at every depth that was read. The data is
the `curves` array of each setup's `models.json`, and
`tools/gen-tables.mjs` renders it between the
`<!-- gen:model-curve:... -->` markers. A row of `models.json` holds
only a shallow and a deep cell, and an arm that was measured and never
served has no row at all, so the curve needs its own list.

One entry per arm: `model` (the page slug), `arm` (the quant, the cache
type, the drafter arm, any offload flag), `method`, `points` (depth in
tokens to tok/s), `served`, `run`, and `c` with `cAt` where the arm
needed its own `-c`. The machine is not a heading and not a column: one
table mixes machines, so it is the first part of the arm label.

**A legacy reading belongs on the page** (owner, 2026-09-18). The
project measured decode with its context-creep tool before it measured
it with `llama-benchy` on real text, and many of those readings were
taken under an older wired limit. They are not comparable with a benchy
reading, and they are still the only curve many arms have. So they are
published with `"method": "creep"` and their `wired` limit, and the
generator marks them with a dagger and a note that says which tool read
them. This is the one place where "No superseded number on a current
page" does not apply: a re-run replaces a daggered reading when there
is time for one, and until then an approximation beats an empty table.
The comparison and pick tables stay benchy-only.

## How to import a simulator(mendel) run

A run is not imported until **four** artifacts carry it. Three of them
feed different pages, so writing one and not the others puts the row on
some pages and not others. This failed once, on 2026-09-18: only the
CSVs were mirrored, so the row reached the model, binary and setup
pages and was missing from the site-wide agent page and from the static
report.

In `../mendel-benchmark/benchmark/`, the source of truth:

1. `results.csv` (or `results-guided.csv`): one line per run.
2. `results.json` (or `results-guided.json`): the same run with the
   defect list, the nudge counts, the `cost` block and `matrix_cells`,
   one cell per data row of `matrix_rows`. **The site's local tables read
   the JSON, never the CSV**, because the CSV has no defects and no
   nudges. `score_total` must equal the sum of `scores`, and each scored
   `matrix_cells` entry must carry the same number in `<b>`; the report
   generator refuses the file otherwise, so never round a score here.
3. `node generate-report.mjs` (add `--guided` for the guided run), which
   rewrites `report.html` from the JSON.

Then mirror into this repo, all four files together:

4. Copy `results.csv`, `results-guided.csv`, `results.json`,
   `results-guided.json`, `report.html` and `report-guided.html` into
   `benchmarks/mendel/`, rename `rtx-5060ti-16gb` to `arrietty` and
   `m1-max-32gb` to `kamaji` in the copies, then `node
   tools/gen-tables.mjs`, `node tools/sync-static.mjs` and `npm run
   verify`.

`npm run docs:tables` counts the runs in the mirrored CSV and the
mirrored JSON, and checks that the newest run of each JSON appears in
the matching `report.html`. It fails when they disagree, with the words
**simulator import was partial**. It does not compare file times: a
clone gives every file the same checkout time, so a time test passes
here and fails in CI. That check is the guard;
the list above is how to satisfy it.

## How to add a model to an existing setup

1. Create `docs/setups/<setup>/benchmarks/<model>.md` and
   `docs/setups/<setup>/reports/<model>.md`. Follow the page shape above.
2. Add the model to the table in `docs/setups/<setup>/index.md`.
3. Add rows to `comparison.md`.
4. Add both pages to the sidebar in `docs/.vitepress/config.mjs`, under that
   setup's Reports and Benchmarks groups.

## How to add a setup

1. Create `docs/setups/<slug>/` with `index.md`, `comparison.md`,
   `reports/`, and `benchmarks/`. Copy the shape of `kamaji`.
2. Add a section to `docs/index.md` under "Setups": the bullets, the seat
   table, then the per-model table.
3. Add a sidebar group in `docs/.vitepress/config.mjs`.
4. `docs/methodology.md` stays setup-independent. Anything
   machine-specific belongs in the setup's `index.md`.

## Linking rules

- Link pages with a relative path and the `.md` extension: `./comparison.md`,
  `../benchmarks/bonsai-27b.md`, `../historical.md`. The build resolves them
  and fails on a broken one, which is why the `.md` form is required.
- `cleanUrls` is on, so the built pages have no `.html` suffix. Never write a
  link that ends in `.html`.

## Before you commit

- `npm run verify` builds, then walks every href in the built output. The
  build fails on a broken Markdown link; the checker catches the rest,
  including links that are missing the site base path.
- Commit before you ask for review. Use `npm run deploy -- "what changed"`,
  which verifies and commits in one step.
- **Never push.** `npm run deploy` stops before pushing on purpose and prints
  the command for the owner. Publishing is the owner's step.
