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
id under `docs/setups/`. Shared run tools sit in `benchmarks/`.
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
- **The Configs section is generated** between
  `<!-- gen:model-configs:... -->` markers: one `#N — config` block per
  visible row, with its exact startup command. Never hand-edit inside.
  Never write prose that tells the reader to change a parameter.
- **`docs:tables` fails if prose references a `#N` beyond the visible
  row count**, so a hidden or deleted row cannot leave dangling
  references silently. Renumbering is still yours to re-check.
- **Every stat box must be backed by the page's tables.** The number a
  box quotes appears in a table row on the same page, or that row marks
  it `pending`. A box never quotes a figure the tables do not carry.
- **Every serving config a page gives a command for gets its own table
  row**, incomplete cells allowed (`pending`). Scores are shared across
  rows when thinking mode, effort, and quant match, whatever the
  context size, slot count, tok/s, or what gates the config.

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

New benchmark-type pages (evalplus, mendel, polyglot) grow toward this
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
site. The generator sorts rows by EvalPlus score (pass@1 base,
descending), then by Max ctx (descending) for ties: highest scores at
the top, and within a tie the deepest context. `pending` scores sort to
the bottom.

- **Columns, in order**: # | Config | Max ctx | Gated by¹ |
  tok/s (shallow → deep) | Memory (at max ctx) | EvalPlus². The `#`
  column numbers the rows of that page, top to bottom; every page
  counts its own.
- **The homepage table holds one line per model** (the major name
  before the first comma), showing that model's best complete row.
- **The comparison table holds every config row but suppresses any row
  with a pending cell.** Pending work is visible on the model pages,
  not on the comparison.
- **Per-model tables keep the order the rows have in `models.json`**
  (no re-sort), so their `#` numbers are stable. All references to a
  config on that page use its `#` number. There is no "Suggested for"
  column; seat suggestions live only in the setup overview and in
  analysis/decision prose.
- **One row per config; a model shows every runtime that has sweep
  data** (MLX and GGUF rows side by side), grouped by model.
- **Config is a comma list: Model, Runtime, Details.** Model is the
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
- **Footnote ² lives on the EvalPlus header**: one score per model and
  thinking mode. Runtimes at standard quants share it. Aggressive
  quants (calibrated q4 KV and similar) gate separately and show
  "pending" until they pass. Scores never propagate across thinking
  modes.
- **Stale cells carry the † marker (superseded, re-run pending)**: a
  value measured under an earlier serving config or method (a retired
  wired limit, a fast sweep, a pre-calibration config) that the current
  method has not re-measured yet. It is derived data. Each row's
  `stale` array in `models.json` lists the affected field names, and
  the generator renders the marker and its legend on every table that
  shows one. When a new run lands, write the new value and remove the
  field from `stale`. Nothing else to touch; every table updates on the
  next `docs:tables` run.
- **Footnote ¹ always lives on the "Gated by" header**, not on any cell.
  It explains what the column measures: whichever limit hits first, the
  max memory a config fits in or the max context that stays usable
  (usable meaning at or above the 8 tok/s floor). It also covers what
  "tok/s (shallow → deep)" means, since the two are the same idea. Do
  not give tok/s its own separate explanation.
- **A row served by a custom binary or fork gets its own footnote**,
  attached directly to the Runtime abbreviation in Config (for example
  "MLX³"), not to any other cell. The same fork reuses its number across
  every row that uses it. Number them ³, ⁴, ... in the order they first
  appear in the table (¹ and ² are reserved for the header footnotes).
- **Each footnote is its own paragraph below the table**: a blank line
  between ¹, ², ³, and so on, not one run-on block.
- **Multi-agent configs** show the slot count in **Max ctx** as
  "Nx\<size\>", for example "2x48k", never in Config.
- **Max ctx** (the used-context point where a config first breaks): the
  cell must end with the number and its unit, never a trailing word like
  "per slot".
- **"tok/s (shallow → deep)" is two numbers only**, "X → Y", never a
  qualifier word like "solo" or "concurrent" in the cell. For a
  multi-slot config, the number is one slot decoding alone (see
  methodology). If the method needs explaining, that explanation goes in
  the methodology, not as a note on this table.
- **"Memory (at max ctx)" is one number only**: the max figure reached,
  nothing else. No "flat", no "grows to", no qualifier of any kind.
- **"tok/s (shallow → deep)"** and **"Memory (at max ctx)"** headers break
  onto two lines before the parenthesis (`<br>`), so the column stays
  narrow.

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
                               (decode-speed, evalplus, mendel,
                               polyglot). These are in the sidebar,
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

## How to add a model to an existing setup

1. Create `docs/setups/<setup>/benchmarks/<model>.md` and
   `docs/setups/<setup>/reports/<model>.md`. Follow the page shape above.
2. Add the model to the table in `docs/setups/<setup>/index.md`.
3. Add rows to `comparison.md`.
4. Add both pages to the sidebar in `docs/.vitepress/config.mjs`, under that
   setup's Reports and Benchmarks groups.

## How to add a setup

1. Create `docs/setups/<slug>/` with `index.md`, `comparison.md`,
   `reports/`, and `benchmarks/`. Copy the shape of `m1-max-32gb`.
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
