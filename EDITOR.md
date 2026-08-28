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

- Markdown only. Do not write new raw HTML pages.
- `docs/public/setups/<setup>/historical.html` is frozen. Leave it as HTML.
- Server commands go in fenced `bash` blocks, so they stay copy-paste ready.
  The `--alias` value equals the harness model id.
- Tables carry the numbers. Bold the winning row.
- No code comments unless the owner asks for them.

## Site chrome

- Footer: copyright Irae Carvalho, plus a link to https://github.com/irae.
- The owner's name and GitHub link belong on every page, through the theme
  footer. Do not repeat them in page content.

## Before you commit

- `npm run docs:build` — the build fails on a broken internal link.
- `npm run docs:check` — walks every href in the built output, including the
  frozen HTML page that the build does not check.
- Commit before you ask for review.
- Do not push, deploy, or enable Pages without the owner's explicit go.
