# Plan: publish the project as a website (GitHub Pages)

Status: plan only. Another agent executes it. Everything must work locally
first; pushing/publishing happens only when the user says so. Write all
prose in ASD-STE100 Simplified Technical English.

## Goal

Turn the repo into a small static website:

- The index presents the project and its goals (today's README) plus a
  summary of each measured setup — starting with the M1 Max — with links to
  that setup's comparison, reports, and benchmarks.
- `docs/methodology.md` becomes a linked page.
- The structure supports more setups later (the user will run the
  methodology on a PC with an NVIDIA GPU: Bonsai and lower quants).
- Future content updates happen in Markdown, not raw HTML.

## Framework: MkDocs with the Material theme

Chosen because it is the most popular Markdown-first docs generator, tables
are first-class (this project is tables), navigation and search come free,
`mkdocs serve` gives instant local preview, and non-Markdown files (our
existing HTML reports) pass through verbatim — so nothing breaks on day one
and pages convert to Markdown gradually. Alternative considered: Jekyll
(native GitHub Pages, no CI needed) — rejected for weaker table/nav
ergonomics and Ruby tooling.

Install (local): `pipx install mkdocs-material` (bundles mkdocs).
Preview: `mkdocs serve` (http://127.0.0.1:8000). Build: `mkdocs build`.

## Target layout

The site source is the existing `docs/` directory (MkDocs default
`docs_dir`). Setup-specific content moves under `docs/setups/<setup-slug>/`.

```
mkdocs.yml                      (new, repo root)
README.md                       (stays: short GitHub-facing intro + link to the site)
docs/
  index.md                      (new: README content + per-setup summaries)
  methodology.md                (exists)
  website-plan.md               (this file; exclude from nav)
  setups/
    m1-max-32gb/
      index.md                  (from docs/machine.md, git mv)
      comparison.html           (git mv from repo root)
      historical.html           (git mv from repo root)
      reports/*.html            (git mv from reports/)
      benchmarks/*.md           (git mv from benchmarks/)
.github/workflows/site.yml      (new, phase 3 only)
```

Notes:

- `night1/ night2/ night3/`, `HANDOFF.md`, and scripts stay outside `docs/`
  and off the site.
- The `benchmarks/*.md` files become real site pages for free.
- The `reports/*.html` and `comparison.html` files pass through unchanged in
  phase 1; MkDocs copies non-Markdown files verbatim.
- After the moves, update every cross-reference (the same link classes as
  commit 5b98507: report↔benchmark↔comparison↔historical links, plus
  `docs/methodology.md` rule 7 surface names and `README.md`'s map).

## Phase 1 — structure + passthrough (no visual change to existing pages)

1. Create `mkdocs.yml`. Guidance skeleton (adjust, do not treat as final):

   ```yaml
   site_name: Choosing a local coding LLM
   theme: { name: material }
   nav:
     - Home: index.md
     - Methodology: methodology.md
     - "M1 Max 32 GB":
       - Overview: setups/m1-max-32gb/index.md
       # comparison/reports linked from the pages, not nav (raw HTML)
   markdown_extensions: [tables, admonition, attr_list, md_in_html, toc]
   ```

2. `git mv` the files per the target layout; fix cross-references; verify
   with the same grep used in commit 5b98507.
3. Write `docs/index.md`:
   - Project intro + goals: copy from `README.md` (single source going
     forward: index.md owns the long form; README.md shrinks to a short
     pointer to the published site + local `mkdocs serve` instructions).
   - Section "Setups", one block per setup. For M1 Max: the
     current-picks-by-seat table (condensed from comparison.html), the
     headline law (MLX flat-but-OOMs vs llama creeps-but-survives), links:
     setup overview, comparison.html, each model report, each benchmark page.
     The summary lives ONLY on index.md, not in README.md (user decision).
4. Acceptance: `mkdocs build --strict` passes; `mkdocs serve` shows index,
   methodology, setup overview; comparison.html and reports open with their
   current styling; no dead links (click every link or use a link checker).
5. Commit. Do not deploy.

## Phase 2 — Markdown-ify the maintained pages (stop writing raw HTML)

Convert, one page per commit, verifying rendering in `mkdocs serve`:

1. `comparison.html` → `setups/m1-max-32gb/comparison.md`. The four cards
   become sections; tables become Markdown tables; the "capped by" and
   EvalPlus columns survive as plain columns. Keep `historical.html` as
   static HTML forever (frozen).
2. Each `reports/<model>.html` → `reports/<model>.md`. KPI boxes become a
   short bold line or a Material grid; command boxes become fenced `bash`
   blocks (copy-paste behavior preserved); tables become Markdown tables.
3. After each conversion: delete the HTML file, add a nav entry, fix
   inbound links.
4. Update `docs/methodology.md` rule 7 (the four-surface rule) to name the
   new surfaces: `benchmarks/*.md`, the report page, the comparison page,
   `~/.pi/agent/models.json`.

Result: all future edits are Markdown edits.

## Phase 3 — GitHub Pages deploy (only when the user says publish)

1. `.github/workflows/site.yml`: on push to `master`, run
   `pipx run --spec mkdocs-material mkdocs build` and publish `site/` with
   `actions/upload-pages-artifact` + `actions/deploy-pages` (the modern
   Pages flow; no gh-pages branch to maintain).
2. Repo settings: Pages → Source: GitHub Actions. The user flips this
   switch; do not assume permissions.
3. Set `site_url` in `mkdocs.yml` to the final URL
   (`https://<user>.github.io/<repo>/`) so canonical links resolve.
4. Acceptance: the published site equals the local `mkdocs serve` output.

## Phase 4 — second setup (when the PC exists)

1. `docs/setups/<pc-slug>/` (for example `pc-rtx-<gpu>-<ram>gb/`) with the
   same shape: `index.md` (machine doc), `comparison.md`, `reports/`,
   `benchmarks/`.
2. `docs/index.md` gains that setup's summary block.
3. `docs/methodology.md` stays setup-independent; anything machine-specific
   found there moves to the setup's `index.md`.
4. Candidate content for the PC per the user: Bonsai (the prism fork has
   CUDA builds with fused 2-bit GEMM), lower quants of the other models;
   Aider tier 2 can run there against either machine's servers.

## Constraints and gotchas for the executor

- The user's global rules apply: STE prose, no code comments, commit before
  review, no step-count language in commits.
- Do not publish anything (no push to remotes, no Pages enablement) without
  the user's explicit go — phases 1-2 are local-only and committable.
- The HTML reports carry per-model accent colors; when converting in phase
  2, do not try to reproduce them — Material's default styling is fine.
- `docs/machine.md` contains user-workflow facts (ports, sysctl, pi). Keep
  them in the setup page; they are content, not site chrome.
- The four-surface rule means benchmark data lands in these pages the same
  day it is measured — keep the structure boring so a benchmarking agent
  can edit one table without understanding the site.
