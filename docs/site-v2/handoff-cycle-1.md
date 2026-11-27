# Site v2 — Cycle 1 Handoff (Step 4 Complete · Ready for Step 5 Visual Redesign)

Read this file and [03-decisions.md](./03-decisions.md) when starting the next cycle (Step 5 Visual Redesign, then Pass 2 `docs/agents/` overhaul after website publish).

---

## 1. Current Repository State

- **Branch / Worktree:** `site-v2` at `/home/irae/code/.worktrees/choose-a-local-llm/site-v2-67a91c1844b5d5af` (branched from `master` at `be36dd59`).
- **Untouched boundaries:**
  - `master` worktree was never touched (preserves uncommitted `hardware/arrietty/benchmarks/bench33/AGENT.md`).
  - `hardware/` and `benchmarks/` have **zero diff** against `be36dd59`.
  - Nothing has been pushed (`git push` remains owner-only).
- **Working tree:** Clean after all commits.

### Commit Log (Step 3 → Cycle 1 End)

| Commit | Author / Phase | Scope |
| --- | --- | --- |
| `88622503` | Step 3 (`[site-v2]:`) | Raw-artifact fact-check & Pass 1 rewrite plan ([04-rewrite-plan.md](./04-rewrite-plan.md)) |
| `816dc495` | Pre-Round 1 (`[site-v2]:`) | Added `qwen3.8-27b-ista` daily-driver note + [step4-checklist.md](./step4-checklist.md) |
| `3d47bff2` | Round 1 (4A.1) | Migrated & cleaned dataset under `data/` (`binaries.json` ×25, `setups/{m1-max-32gb,rtx-5060ti-16gb}/models.json`, `ownWall` on 9 spliced EvalPlus runs, `s5-nano-bf16-think` row + linked EvalPlus, ≤30w row notes, removed stale `models.*.stats`/`kpis`) |
| `f34a3639` | Round 1 (4A.2–4A.3) | Moved & upgraded `site/.vitepress/` (auto-discovering `config.mjs`, `ProofSidebar.vue`, `Layout.vue`, updated `ModelSpec.vue` with `model-page` + `page`), refactored `tools/gen-tables.mjs`, added `tools/check-hostnames.mjs` + `.githooks/pre-commit`, updated `check-links.mjs` (fails on 0 pages), `sync-static.mjs`, `gen-pi-models.mjs`, `package.json`, `.github/workflows/site.yml`, `.gitignore` |
| `f5098db9` | Round 1 (4A.4) | Separated `docs/agents/` and `docs/repo/`, slimmed `AGENTS.md` and `README.md`, removed legacy published files under `docs/` |
| `8f559000` | Round 1 (4B.1) | Wrote `site/index.md` and `site/setups/{m1-max-32gb,rtx-5060ti-16gb}/{index,archive}.md` |
| `43826ee7` | Round 1 (4B.2) | Wrote `site/models/index.md` + all 8 canonical `site/models/<slug>.md` pages |
| `1f342475` | Round 1 (4B.3) | Wrote `site/benchmarks/{index,decode-speed,evalplus,mendel}.md` + 4 machine- & model-agnostic `site/method/*.md` pages |
| `5e1bab2e` | Round 1 (4B.4) | Generated `site/.vitepress/data/site-stats.json`, 26 auto-generated `site/files/{index,<id>}.md` pages, and all `<!-- gen:... -->` blocks |
| `87839b11` | Round 2B (`writing-for-agents`) | Polished `AGENTS.md`, `docs/agents/README.md`, `docs/agents/site-writer.md`, `docs/agents/site-reviewer.md` |
| `cc8fef71` | Round 2A (Site Review) | Fixed 6 cross-page factual/parity bugs (`Gemma-4-12B` M1 Max `37.5` guided vs `0/100` blind, `Gemma-4-26B` loop label, `Bonsai-27B` top partial scores, NVFP4 repo typo, PrismML fork caveat parity, window labels) and unslopped prose across 19 `site/` + `data/` files |
| `03aa5e5a` | Round 2B (SOP Paths) | Repaired legacy `docs/` path references & v2 boundary contradictions across lifted `docs/agents/*.md` |
| `8dbdd932` | Round 3 (Coordinator) | Extended `tools/check-hostnames.mjs` to scan `site/.vitepress/**/*` (58 files total, up from 48), fixed broken link in `tools/README-mac-services.md`, updated header path comments in `tools/gen-pi-models.mjs` |

---

## 2. Verified Final Metrics & Gate Status

- **Published site footprint:** **22** concise hand-written pages (all strictly under §4 word caps; down from 85 files / 135,415 words) + **26** 100%-auto-generated `site/files/*` pages = **53** built HTML routes (`npm run verify`).
- **Build & link verification (`npm run verify`):** VitePress build succeeds in ~3.9s; **`53 pages, 2,933 links checked, 0 dead`**.
- **Automated quality & privacy gates (`npm run docs:check`):**
  - `tools/gen-tables.mjs --check`: **0 diffs, 0 unmatched binaries, 0 orphan `/files/*` pages**.
  - `tools/check-hostnames.mjs`: **0 leaks across all tracked `site/` files including `site/.vitepress/`** (dynamically bans `arrietty`, `kamaji`).
  - `tools/check-links.mjs`: **0 dead links** (and now fails loudly if `dist/` has 0 HTML files).
- **Editorial & schema audits:**
  - All **22** hand-written `site/` pages under §4 prose word caps.
  - All **48** `data/setups/*/models.json` `rows[].note` entries ≤30 words.
  - **0** model names in `site/method/*.md`.
  - **0** broken relative markdown links in `README.md`, `AGENTS.md`, `docs/agents/*.md`, `docs/repo/*.md`.
- **Verified compute ledger (`site/.vitepress/data/site-stats.json`):**
  - **`325h+` (`325.0h`)** net non-overlapping local active compute from structured JSON (`219.6h` net EvalPlus across 56 runs via `ownWall`, `105.4h` local Mendel across 54 runs; `226.3h` M1 Max + `98.7h` RTX 5060 Ti).
  - **`339.5h`** total documented active local compute including 6 diagnostic thinking-budget Mendel runs (`bench22` + `bench30`).
  - **`17.5h`** cloud Mendel baselines (25 runs).
  - **`438.2M`** total tokens (`2.93M` output), **`9,444`** tool calls, **`427`** commits, **`8`** models, **`25`** binaries, **`43`** active configs, **`44`** decode curves, **`30`** executed bench runs.
- **Owner daily-driver fact included:** `qwen3.8-27b-ista` (with adjusted compaction trigger) noted concisely on `site/index.md`, `site/setups/rtx-5060ti-16gb/index.md`, and `site/models/qwen3.8-27b.md` (~6–12 h/month for personal finance automation).

---

## 3. Known Subtle Nuances & Intentionally Parked Items

1. **`hardware/` preset regeneration is opt-in:** `tools/gen-tables.mjs` gates `writePresetFile()` behind `--write-presets` so website runs (`npm run docs:tables` / `--check`) never mutate `hardware/*/models*.ini`.
2. **44 curves (not 45):** `data/setups/rtx-5060ti-16gb/models.json` already carried the 6-point `s5-nano` BF16 curve (`20` Mac + `24` RTX = `44` unique curves). Round 1 avoided duplicating it and added `cAt: 203776`.
3. **`s5-nano-q8-think` Mendel state:** Corrected from `"not run"` to `"failed-smoke"` alongside `s5-nano-bf16-think` per `bench33/results.md`.
4. **Legacy root governance files still parked for Pass 2:** Root `EDITOR.md`, `CONTENT-MAP.md`, `CONVENTIONS.md`, `tools/check-content-map.mjs`, and `benchmarks/PLANNING.md` (copied to `docs/agents/planning.md`) remain in place untouched so Pass 1 stayed focused on `site/`. Reconcile/retire them in Pass 2.
5. **External Mendel HTML reports (`site/public/mendel/*.html`):** Mirrored verbatim from `benchmarks/mendel/` (gitignored disposable `site/public/`) and intentionally outside `check-hostnames.mjs`.

---

## 4. Next Cycle: Step 5 — Visual Redesign (Pass 1 Final)

Content, IA, data pipeline, and verification gates are locked and passing. Step 5 focuses purely on visual design and UX polish under `site/.vitepress/theme/` (and light markup adjustments if needed):

1. **Sidebar Proof Widget (`ProofSidebar.vue`):** Elevate from plain unstyled link into a crisp, high-contrast proof card pinned above sidebar nav (`325h+ benchmarked` + subtle metric chips/metadata, clean hover state in both dark and light themes).
2. **Homepage (`site/index.md`) & Setup Pages (`site/setups/*/index.md`):**
   - Replace plain bullet winners with clean, scannable **machine winner cards** or structured callout blocks.
   - Make the 4 empirical laws scannable at a glance.
   - Ensure the hero/opening immediately communicates scale (`325h+`, 2 machines, 8 models) without bloat.
3. **Table Readability & Component Polish (`custom.css`, `ModelSpec.vue`, `TokCell.vue`, `ScoreCell.vue`, `CurveCell.vue`):**
   - Remove the perpetually pulsing `⇢` scroll-hint animation (`table-hint-pulse 1s linear infinite` on non-overflowing tables) flagged in `01-audit.md` Defect 6; show scroll affordance only on true horizontal overflow (e.g., subtle edge fade or conditional overflow hint).
   - Reduce pill clutter on `site/benchmarks/mendel.md` (tighter visual hierarchy between Score, Ctx/Speed, Bugs, and Stats so rows breathe without endless horizontal scrolling).
   - Consider adding a clean, build-time or lightweight SVG decode-speed-vs-depth visual chart component reading `curves[]` on `site/benchmarks/decode-speed.md` and `site/models/<slug>.md` (optional, high-impact visual upgrade).
4. **Browser QA (Desktop + Mobile + Light/Dark):**
   - Start `npm run dev` (or `npm run preview`) and inspect Home, both Setup pages, 2 Model pages, 1 `/files/*` page, Benchmarks/Mendel, and Method pages at desktop (`1280px+`) and mobile (`~390px`) widths in light and dark mode using `playwright-cli` (or T3 Browser if interactive review is requested).
   - Run `npm run docs:tables && npm run verify && npm run docs:check` after all visual edits.
5. **Owner approval & publish → Pass 2:**
   - Once Step 5 is approved and merged/published by the owner, kick off **Pass 2** in a fresh thread for full-rigor `docs/agents/` deduplication (retiring root `EDITOR.md`, `CONTENT-MAP.md`, `benchmarks/PLANNING.md`, `tools/check-content-map.mjs`; consolidating overlapping rules across `standing-rules.md`, `planning.md`, `checklist.md`, `common-rules.md`, `status-lines.md`; updating `CONVENTIONS.md`; revisiting `docs/repo/` & cloneability once external eval tools settle).
