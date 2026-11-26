# Site v2 — Handoff (Ready for Step 3)

Read this file and [03-decisions.md](./03-decisions.md) first when starting the Step 3 session. All Round 1 decisions are locked.

## Current State

- **Branch:** `site-v2` (branched from `master` at `be36dd59`).
- **Commit policy (strict):** Every commit on `site-v2` starts with `[site-v2]: ` and touches **only** files created under `docs/site-v2/` during planning/review phases (so `docs/site-v2/` can be rebased out cleanly later).
- **Completed:**
  - [README.md](./README.md) — Goals and phased roadmap.
  - [01-audit.md](./01-audit.md) — Step 1 evidence-based audit (verified compute hours, section word counts, 6 structural defects, prose-vs-data contradictions, Run 33 friction, cloneability leaks).
  - [02-information-architecture.md](./02-information-architecture.md) — Step 2 visual IA diagrams (ASCII + Mermaid) for As-Is vs. Proposed v2.
  - [03-decisions.md](./03-decisions.md) — Locked owner decisions (D0–D6) and Two-Pass execution strategy.
- **Untouched:** No existing repo or website files have been edited on `site-v2`. (Main `master` worktree still has intentional uncommitted `hardware/arrietty/benchmarks/bench33/AGENT.md` — never touch `master` worktree.)

## Locked Strategy & Architecture

### Pass 1 (Now — Full Rigor on Public Website `site/`)
- **Published site root:** `site/` (VitePress `srcDir: 'site'`), physically outside `docs/agents/`, `docs/repo/`, and `docs/site-v2/`.
- **Public IA:**
  - `/` — Home (winners per machine, best per model, headline laws).
  - `/setups/<hardware-slug>/` — Merged overview + leaderboard (+ `/archive`), using hardware slugs (`m1-max-32gb`, `rtx-5060ti-16gb`), never hostnames.
  - `/models/<slug>` — Single canonical page per model (collapses 13 per-machine report pages + 13 bench stubs).
  - `/files/<binary-id>` — 100% auto-generated from JSON (zero hand-written duplicate prose).
  - `/benchmarks/` — Compute ledger + Decode speed + EvalPlus + Mendel.
  - `/method/` — Concise public scientific method (4 pages, zero agent SOPs).
  - **Sidebar proof widget:** Build-time computed totals (`339h+ benchmarked`, runs, models, machines) on every page, linking to `/benchmarks/`.
- **Automated guard (code, not agent docs):** Lint check in `npm run docs:check` (and optional pre-commit hook) rejecting machine hostnames (`kamaji`, `arrietty`) inside `site/`. Leave git history untouched.
- **Low-rigor / best-effort in Pass 1:**
  - **Cloneability Check (IA §4):** Best effort only — take cheap wins (auto-discovered nav/sidebar, clean `site/method/`), acknowledge external tooling (`issue-simulator`, `local-llm-eval-tools`) is still moving, and park full reusability for later re-planning.
  - **`docs/agents/` & `docs/repo/`:** Clean folder split and minimal working writer vs. strict reviewer guides for Step 4; defer deep agent-doc overhaul to Pass 2.

### Pass 2 (Immediately After Website Approval & Publish)
- Dedicated thread with full rigor for **`docs/agents/`** (separate writer guide vs. strict cross-page reviewer guide comparing `models/<slug>` ↔ `setups/<slug>`, consolidated coordinator/runner/standing rules), plus re-plan `docs/repo/` and cloneability level of rigor.

## Verified Baseline Numbers (as of commit `be36dd59`)

- **Published site (`docs/`):** 85 `.md` files, 135,415 words (+ 22,949 words in root/repo governance docs).
- **Verified active local compute:** **338.6 hours** (`235.8h` across 56 EvalPlus runs + `102.8h` across 52 local Mendel runs), plus `17.5h` across 25 cloud Mendel runs, plus untracked wall time from 32 bench runs, 5 research runs, 44 decode curves, calibrations, and smokes.
- **Local Mendel telemetry:** 438.2M total tokens, 2.93M output tokens, 9,444 tool calls, 427 commits.
- **Catalog:** 8 models, 2 setups (`m1-max-32gb` / `kamaji`, `rtx-5060ti-16gb` / `arrietty`), 24 binaries, 47 rows (44 visible), 44 decode curves.

## Next Step: Step 3 (Fact-Check & Rewrite Plan)

1. **Fact-check every headline claim and number against raw artifacts:**
   - Cross-verify `docs/setups/*/models.json` against `hardware/*/benchmarks/bench*/results.md`, `benchmarks/mendel/results*.json`, and `docs/binaries.json`.
   - Produce a verified facts sheet resolving every contradiction flagged in [01-audit.md](./01-audit.md) (pre-fast-mode EvalPlus prose, Run 33 Arete/S5-nano/Bonsai-2 gaps, 4 dead `arrietty/benchmarks/*.md` stubs, `bonsai2-mlx-mac` unmatched binary warning, stale dates).
2. **Write `docs/site-v2/04-rewrite-plan.md`:**
   - Exact file-by-file migration map (`site/` full spec; lightweight Pass 1 placement for `docs/agents/` and `docs/repo/`).
   - Spec for the code-enforced hostname-leak check (`npm run docs:check` / pre-commit hook), the build-time sidebar hours aggregator, and auto-generated `/files/<id>` pages.
   - Minimal Pass 1 writer guide + stricter cross-page reviewer checklist (`models/<slug>` ↔ `setups/<slug>`) so Step 4 review cycles stay tight.
   - Concise page budgets (word caps, 1-line row notes, zero duplicated prose).
3. **Then execute Pass 1:** Step 4 (Content Rewrite + iterative review cycles) → Step 5 (Visual Redesign) → Owner approval & publish → Kick off Pass 2 thread for full-rigor `docs/agents/`.
