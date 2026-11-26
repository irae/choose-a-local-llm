# Site v2 — Handoff (After Steps 1, 2 & Round 1 Decisions)

Read this file and [03-decisions.md](./03-decisions.md) first when starting the Step 3 session.

## Current State

- **Branch:** `site-v2` (branched from `master` at `be36dd59`).
- **Commit policy (strict):** Every commit on `site-v2` starts with `[site-v2]: ` and touches **only** files created under `docs/site-v2/` during planning/review phases (so `docs/site-v2/` can be rebased out cleanly later).
- **Completed:**
  - [README.md](./README.md) — Goals and 5-step roadmap.
  - [01-audit.md](./01-audit.md) — Step 1 evidence-based audit (verified compute hours, section word counts, 6 structural defects, prose-vs-data contradictions, Run 33 friction, cloneability leaks).
  - [02-information-architecture.md](./02-information-architecture.md) — Step 2 visual IA diagrams (ASCII + Mermaid) for As-Is vs. Proposed v2.
  - [03-decisions.md](./03-decisions.md) — Round 1 locked owner decisions (D0–D6) and priority calibration.
- **Untouched:** No existing repo or website files have been edited on `site-v2`. (Main `master` worktree still has intentional uncommitted `hardware/arrietty/benchmarks/bench33/AGENT.md` — never touch `master` worktree.)

## Locked Architecture Summary (for Step 3)

- **Published site root:** `site/` (VitePress `srcDir: 'site'`), cleanly separated from `docs/agents/` and `docs/repo/`.
- **Public URLs & structure:**
  - `/` — Home (winners per machine, best per model, headline laws).
  - `/setups/<hardware-slug>/` — Merged overview + leaderboard (+ `/archive`), using hardware slugs (`m1-max-32gb`, `rtx-5060ti-16gb`), not machine hostnames.
  - `/models/<slug>` — Single canonical page per model (replaces 13 per-machine report pages + 13 bench stubs).
  - `/files/<binary-id>` — 100% auto-generated from JSON (zero hand-written duplicate prose).
  - `/benchmarks/` — Compute ledger + Decode speed + EvalPlus + Mendel.
  - `/method/` — Concise public scientific method (4 pages, zero agent SOPs).
  - **Sidebar proof widget:** Build-time computed totals (`339h+ benchmarked`, runs, models, machines) on every page.
- **Automated guard (code, not agent docs):** Add a lint check in `npm run docs:check` (and optional pre-commit hook) rejecting machine hostnames (`kamaji`, `arrietty`) inside `site/`. Leave git history untouched.
- **Agent docs (`docs/agents/`):** Separate **writer guide** and **stricter reviewer guide** (reviewer explicitly cross-checks `models/<slug>` vs. `setups/<slug>` and prose vs. generated tables).
- **Scoped down / parked:**
  - Full cloneability/reusability is **parked** (superficial cleanup only) while `issue-simulator` and extracted tools stabilize; file a backlog item once the owner confirms.
  - Internal `docs/repo/` gets a best-effort pass so maximum rigor stays on the public website (`site/`).

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
   - Exact file-by-file migration map (`site/`, `docs/agents/`, `docs/repo/`, deleted/merged pages).
   - Spec for the two-guide split in `docs/agents/` (`writing.md` vs. stricter `reviewing.md` cross-checking `models/<slug>` ↔ `setups/<slug>`).
   - Spec for the code-enforced hostname-leak check (`npm run docs:check` / pre-commit hook) and the build-time sidebar hours aggregator.
   - Concise page budgets (word caps, 1-line row notes, zero duplicated prose) ready for Step 4 rewrite cycles.
   - Explicit list of superficial reusability wins vs. parked backlog items (awaiting `issue-simulator`).
3. **Then proceed to Step 4 (Content Rewrite + review cycles) and Step 5 (Visual Redesign).**
