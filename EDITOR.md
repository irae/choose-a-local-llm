# Editor guide — content rules for this site

Not published. The site build ignores this file: it sits outside `docs/`.
Read it before you write or change any page. It records the owner's choices
so they survive across sessions and agents.

## Page shape

Every content page uses this order. Do not reorder it.

1. **Highlights** — bullet points. What the model or the page is good at.
   Short lines. No paragraph blobs.
2. **Best option** — the pick, and the command to run it.
3. **Tables** — the measured data.
4. **History and reasoning** — the prose. This is where the long
   explanations go, at the bottom, for the reader who wants them.

The rule behind the order: a reader must get the answer from bullets and a
table. Blobs of text are tedious to read. Nobody should have to read a
paragraph to learn which model is fastest.

Do not open a page with a prose summary. Open it with bullets.

## Words

- Say **"benchmark run"**, never "night run", "night agent", or "overnight".
- Do **not** tell apart work run by hand from work run unattended. The reader
  does not care who was awake. A measurement is a measurement.
- Number the runs: "benchmark run 3" on first use, "run 3" after that.
- Write all prose in ASD-STE100 Simplified Technical English: short
  sentences, active voice, one idea per sentence, one word for one meaning.

Known mismatch: the working directories are still named `night1/`, `night2/`,
`night3/`, and the prose points at paths inside them. Paths keep their real
names. Only prose changes.

## Format

- Markdown only. There are no raw HTML pages left, and there should be none.
  Every page gets the nav, the sidebar, search, dark mode, and the footer by
  being Markdown.
- Server commands go in fenced `bash` blocks, so they stay copy-paste ready.
  The `--alias` value equals the harness model id.
- Tables carry the numbers. Bold the winning row.
- No code comments unless the owner asks for them.

## Historical figures

**No superseded number appears on a current page.** Not in a table, not in
prose. This is the owner's rule and methodology rule 7 says the same.

- A current page states the current number and, if the story needs it, says
  a correction happened — without repeating the old figure.
- The old figure moves to the setup's `historical.md`, with a line saying
  what makes it wrong: the retired 27000 wired limit, an uncalibrated output
  budget, or an axis the depth sweeps replaced.
- Link to the historical page from wherever the old number used to be, and
  say plainly that those numbers are not to be used.
- The `benchmarks/*.md` pages are the exception. They keep the full archive,
  because that is their job — but every section there states the wired limit
  and the run it came from.
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
npm install
npm run docs:dev       # live reload, http://localhost:5173
npm run docs:build     # writes docs/.vitepress/dist
npm run docs:preview   # serves the built site, http://localhost:4173
npm run docs:check     # link checker over the built output
```

Add `-- --host 0.0.0.0` to `docs:dev` or `docs:preview` to reach it from
another machine.

`docs:dev` costs much more memory than `docs:preview`. When a model server
holds the GPU and the machine is swapping, prefer `docs:build` plus
`docs:preview`.

## Where things live

```
docs/
  .vitepress/config.mjs        nav, sidebar, search, footer
  .vitepress/theme/custom.css  layout widths, footer visibility
  index.md                     home: what the project measures, per-setup summary
  methodology.md               the flow. The law for every test cycle.
  website-plan.md              site architecture and phases. Excluded from the site.
  setups/<setup>/
    index.md                   the machine, its models, current state
    comparison.md              cross-model tables for that setup
    reports/<model>.md         one page per model
    benchmarks/<model>.md      full raw data, current and historical
    historical.md              superseded measurements, with a danger warning
```

Anything outside `docs/` never reaches the site. That is where `night*/`,
`HANDOFF.md`, this file, and `AGENTS.md` live.

## How to record a new measurement

Methodology rule 7 binds you: a result is not recorded until every surface
agrees. Change all of these in the same pass.

1. `docs/setups/<setup>/benchmarks/<model>.md` — the full data, including
   the runs that did not win.
2. `docs/setups/<setup>/reports/<model>.md` — the tables, **and** the
   Highlights bullets at the top. The bullets go stale first; they are the
   part a reader actually reads.
3. `docs/setups/<setup>/comparison.md` — the depth table, the quality table,
   and the seat table if the pick changed.
4. `docs/index.md` — only if a seat changed or a "best X" bullet changed.
5. `~/.pi/agent/models.json` — the harness config. Not in this repo.

If a number is superseded by a new wired limit, move the old one into the
setup's `historical.md` rather than deleting it.

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

- `npm run docs:build` — the build fails on a broken internal link.
- `npm run docs:check` — walks every href in the built output, catching
  anything the build's Markdown link resolution does not cover.
- Commit before you ask for review.
- Do not push, deploy, or enable Pages without the owner's explicit go.
  Phase 3 in `docs/website-plan.md` describes the deploy that is not set up
  yet.
