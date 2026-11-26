# Step 4 — Execution Checklist (Pass 1)

Bookkeeping log updated by Round 1 (and reviewed in Rounds 2–3). Follow `04-rewrite-plan.md` in order.

## Step 4A — Data & Pipeline Scaffolding

- [x] **4A.1 Data migration & cleanup (`data/`)**
  - Move `docs/binaries.json` → `data/binaries.json` (+ add `bonsai2-prism-mlx-2bit` for `bonsai2-mlx-mac`, plus concise `statusNote` on zero-row entries).
  - Move `docs/setups/kamaji/models.json` → `data/setups/m1-max-32gb/models.json` (`hardwareId: "kamaji"`, `ownWall` on 3 spliced runs, `benchRuns` count, ≤30w `note` per row, drop stale `models.*.stats`/`kpis`).
  - Move `docs/setups/arrietty/models.json` → `data/setups/rtx-5060ti-16gb/models.json` (`hardwareId: "arrietty"`, `ownWall` on 6 spliced runs, `benchRuns` count, add `s5-nano-bf16-think` row + 6-point curve + link `evalplusRuns[29].row`, ≤30w `note` per row, drop stale `models.*.stats`/`kpis`).
- [x] **4A.2 VitePress & theme scaffolding (`site/.vitepress/`)**
  - Move `docs/.vitepress/` → `site/.vitepress/` and update `.gitignore` (`site/public/`, `site/.vitepress/dist/`, `site/.vitepress/cache/`).
  - Upgrade `site/.vitepress/config.mjs` to auto-discover setups & models from `data/setups/*/models.json` (zero hardcoded machines/models).
  - Add `ProofSidebar.vue` + thin `Layout.vue` wrapper reading `site/.vitepress/data/site-stats.json` into `sidebar-nav-before`.
- [x] **4A.3 Generator, guards & build tooling (`tools/`, `package.json`, CI)**
  - Refactor `tools/gen-tables.mjs` for `data/` + `site/`: streamlined markers, whole-file auto-generated `site/files/{index,<id>}.md` (25 binaries), `site/.vitepress/data/site-stats.json` aggregator (using `ownWall ?? wall` + per-setup Mendel wall), generated `curves[]` tables for `decode-speed.md`, `/files/<id>` links on `<ModelSpec>`, `/models/<slug>` links in Mendel tables, zero hostnames emitted into `site/`.
  - Add `tools/check-hostnames.mjs` + `.githooks/pre-commit`.
  - Update `tools/check-links.mjs` (default `site/.vitepress/dist`, exit 1 if 0 pages), `tools/sync-static.mjs` (`site/public/`), `tools/gen-pi-models.mjs` (dynamic `data/setups/*/models.json`), `package.json` scripts, and `.github/workflows/site.yml`.
- [x] **4A.4 Docs separation (`docs/agents/`, `docs/repo/`, root cleanup)**
  - Move agent SOPs to `docs/agents/` (`standing-rules.md`, `planning.md`, `checklist.md`, `common-rules.md`, `server-lore.md`, `status-lines.md`) + create Pass 1 `docs/agents/README.md`, `docs/agents/site-writer.md`, `docs/agents/site-reviewer.md`.
  - Create best-effort `docs/repo/` (`README.md`, `hardware-setup.md`, `running-benchmarks.md`).
  - Slim root `AGENTS.md` (pointer to `docs/agents/`) and update `README.md` (live site + `docs/repo/README.md`).
  - Remove old published `docs/` files (`docs/index.md`, `docs/models/`, `docs/binaries/`, `docs/benchmarks/`, `docs/setups/`, `docs/methodology*`, `docs/website-plan.md`, `docs/.vitepress/`).

## Step 4B — Public Site Content Rewrite (`site/`)

- [x] **4B.1 Core Findings**
  - `site/index.md` (≤350w prose, machine picks, best-per-model table, headline laws, daily-driver note, GitHub cloner CTA).
  - `site/setups/m1-max-32gb/index.md` (≤450w prose) + `archive.md` (≤600w prose).
  - `site/setups/rtx-5060ti-16gb/index.md` (≤450w prose, includes `qwen3.8-27b-ista` daily-driver note) + `archive.md` (≤600w prose).
- [ ] **4B.2 Canonical Model Pages**
  - `site/models/index.md` (≤120w prose).
  - All 8 `site/models/<slug>.md` pages (≤400w prose each): `qwen3.8-27b`, `qwen3.6-35b-a3b`, `gemma-4-26b-a4b`, `gemma-4-12b-it`, `bonsai-2-27b`, `bonsai-27b`, `arete-27b`, `s5-nano`.
- [ ] **4B.3 Benchmarks & Public Scientific Method**
  - `site/benchmarks/index.md` (≤250w prose + generated compute ledger).
  - `site/benchmarks/decode-speed.md`, `evalplus.md`, `mendel.md` (≤350w prose each).
  - `site/method/index.md`, `speed-and-memory.md`, `quality.md`, `agent-coding.md` (≤1,000w each, zero model names, zero hostnames, zero agent SOPs).
- [ ] **4B.4 Full Verification Gate**
  - `npm run docs:tables` clean.
  - `npm run verify` passes (>0 links checked, 0 dead).
  - `npm run docs:check` passes (0 table diffs, 0 hostname leaks, 0 dead links, 0 unmatched binaries).
  - `git status` clean with logical, medium-sized commits (no `[site-v2]:` prefix on writer commits).
