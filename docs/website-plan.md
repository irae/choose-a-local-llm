# Plan: publish the project as a website (GitHub Pages)

Status: phases 1, 2, and 3 are built and committed on the `site` branch.
Nothing is pushed: the first push is the owner’s. Phase 4 waits for the PC.
Write all prose in ASD-STE100 Simplified
Technical English.

## Goal

Turn the repo into a small static website:

- The index presents the project and its goals (today's README) plus a
  summary of each measured setup — starting with the M1 Max — with links to
  that setup's comparison, reports, and benchmarks.
- `docs/methodology.md` becomes a linked page.
- The structure supports more setups later (the user will run the
  methodology on a PC with an NVIDIA GPU: Bonsai and lower quants).
- Future content updates happen in Markdown, not raw HTML.

## Framework: VitePress

The toolchain must be Node, not Python (user decision). VitePress is the
Node equivalent of the MkDocs Material shape this plan first assumed: one
config file, Markdown-first, first-class tables (this project is tables),
navigation and local search built in, and instant preview. Alternatives
considered: Docusaurus (MDX parses plain Markdown differently — a risk for
the existing benchmark files) and Astro Starlight (also good; VitePress
wins on fewer moving parts).

Install (local): `npm install`.
Preview: `npm run docs:dev` (http://localhost:5173).
Build: `npm run docs:build`.

One difference from MkDocs that shapes the layout: VitePress does not copy
arbitrary non-Markdown files out of the source tree. Only `docs/public/`
passes through verbatim. So the raw HTML pages live under
`docs/public/setups/<setup-slug>/` and keep their public URLs; the Markdown
pages live under `docs/setups/<setup-slug>/`. Each page converted in phase 2
moves from the first tree to the second.

The plan first said `historical.html` would stay raw HTML forever, because it
was frozen. That turned out to be wrong. The page was edited — a warning
block, and tables moved in from the reports — so it was never frozen, and as
raw HTML it was the only page with no nav, no sidebar, no search, no dark
mode, and no footer. It is Markdown now, and `docs/public/` is empty.

## Target layout

The site source is the existing `docs/` directory (VitePress default
`srcDir`). Setup-specific content moves under `docs/setups/<setup-slug>/`.

```
package.json                    (new, repo root)
README.md                       (stays: short GitHub-facing intro + link to the site)
docs/
  .vitepress/config.mjs         (new: title, nav, sidebar, local search)
  index.md                      (new: README content + per-setup summaries)
  methodology.md                (exists)
  website-plan.md               (this file; srcExclude)
  setups/
    m1-max-32gb/
      index.md                  (from docs/machine.md, git mv)
      benchmarks/*.md           (git mv from benchmarks/)
  public/
    setups/
      m1-max-32gb/
        comparison.html         (git mv from repo root; phase 2 converts it)
        historical.html         (git mv from repo root; phase 2 converts it)
        reports/*.html          (git mv from reports/; phase 2 converts them)
.github/workflows/site.yml      (new, phase 3 only)
```

The `public/` tree and the Markdown tree share one URL space, so a page keeps
its URL when it converts — except that `cleanUrls` drops the `.html` suffix
from converted pages.

Notes:

- `benchmarks/bench1/ benchmarks/bench2/ benchmarks/bench3/`, `HANDOFF.md`, and scripts stay outside `docs/`
  and off the site.
- The `benchmarks/*.md` files become real site pages for free.
- The `reports/*.html` and `comparison.html` files pass through unchanged in
  phase 1; VitePress copies `docs/public/` verbatim.
- After the moves, update every cross-reference (the same link classes as
  commit 5b98507: report↔benchmark↔comparison↔historical links, plus
  the methodology's record-everywhere rule surface names and `README.md`'s map).

## Phase 1 — structure + passthrough (no visual change to existing pages)

1. Create `package.json` (scripts `docs:dev`, `docs:build`, `docs:preview`)
   and `docs/.vitepress/config.mjs`. The config sets the site title,
   `cleanUrls`, `srcExclude` for this file, the local search provider, and
   nav plus sidebar entries for Home, Methodology, and the M1 Max setup
   (overview, comparison, each report, each benchmark, historical). Raw HTML
   pages get sidebar entries with their `.html` suffix; Markdown pages get
   extensionless links.
2. `git mv` the files per the target layout; fix cross-references; verify
   with the same grep used in commit 5b98507.
3. Write `docs/index.md`:
   - Project intro + goals: copy from `README.md` (single source going
     forward: index.md owns the long form; README.md shrinks to a short
     pointer to the published site + local `npm run docs:dev` instructions).
   - Section "Setups", one block per setup. For M1 Max: the
     current-picks-by-seat table (condensed from comparison.html), the
     headline law (MLX flat-but-OOMs vs llama creeps-but-survives), links:
     setup overview, comparison.html, each model report, each benchmark page.
     The summary lives ONLY on index.md, not in README.md (user decision).
4. Acceptance: `npm run docs:build` passes (VitePress fails the build on a
   broken internal Markdown link); `npm run docs:check` reports zero dead
   links — it walks every `href` in the built output, so it also covers the
   raw HTML pages that VitePress does not check; `npm run docs:dev` shows
   index, methodology, and the setup overview, and comparison.html and the
   reports open with their current styling.
5. Commit. Do not deploy.

## Phase 2 — Markdown-ify the maintained pages (stop writing raw HTML)

Convert, one page per commit, verifying rendering in `npm run docs:dev`:

1. `docs/public/setups/m1-max-32gb/comparison.html` →
   `docs/setups/m1-max-32gb/comparison.md`. The cards become sections;
   tables become Markdown tables; the "capped by" and EvalPlus columns
   survive as plain columns.
2. Each `docs/public/setups/m1-max-32gb/reports/<model>.html` →
   `docs/setups/m1-max-32gb/reports/<model>.md`. KPI boxes become a short
   bold line; command boxes become fenced `bash` blocks (copy-paste behavior
   preserved); tables become Markdown tables.
3. After each conversion: delete the HTML file from `public/`, update the
   sidebar entry to the extensionless link, and fix inbound links.
4. Update the methodology's record-everywhere rule to name the
   new surfaces: `benchmarks/*.md`, the report page, the comparison page,
   `~/.pi/agent/models.json`.

Result: all future edits are Markdown edits.

## Phase 3 — GitHub Pages deploy

Built. Not yet published: the first push is the owner's.

1. `.github/workflows/site.yml` runs on a push to `master` and on manual
   dispatch. It checks out with full history (so `lastUpdated` has git
   timestamps), runs `npm ci`, `npm run build`, and `npm run docs:check`,
   then publishes `docs/.vitepress/dist` with `actions/upload-pages-artifact`
   and `actions/deploy-pages`. No gh-pages branch to maintain.
2. `base: '/choose-a-local-llm/'` and `sitemap.hostname` are set in
   `docs/.vitepress/config.mjs`. Every internal Markdown link is relative and
   ends in `.md`, so the base applies automatically; `tools/check-links.mjs`
   reads the base from the config and fails on any absolute link that is
   missing it.
3. `scripts/publish.sh` (`npm run deploy`) builds, verifies, and commits,
   then **stops**. It reports whether the Pages source is set to GitHub
   Actions and prints the enable command if not. It never pushes.
4. Remaining, and owner-only:
   - Set Pages → Source: GitHub Actions, once:
     `gh api -X POST repos/irae/choose-a-local-llm/pages -f build_type=workflow`
   - `git push origin site:master` — or merge `site` into master from the
     worktree that has master checked out, then push.
5. Acceptance: the published site equals `npm run preview` output at
   `/choose-a-local-llm/`.
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
  2, do not try to reproduce them — the default theme styling is fine.
- `docs/machine.md` contains user-workflow facts (ports, sysctl, pi). Keep
  them in the setup page; they are content, not site chrome.
- The four-surface rule means benchmark data lands in these pages the same
  day it is measured — keep the structure boring so a benchmarking agent
  can edit one table without understanding the site.
