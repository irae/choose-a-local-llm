# Site v2 — Handoff (After Steps 1 & 2)

Read this file first when starting the Step 3 session.

## Current State

- **Branch:** `site-v2` (branched from `master` at `be36dd59`).
- **Commit policy (strict):** Every commit on `site-v2` starts with `[site-v2]: ` and touches **only** files created under `docs/site-v2/` during planning/review phases (so `docs/site-v2/` can be rebased out cleanly later if desired).
- **Completed:**
  - [README.md](./README.md) — Goals and 5-step roadmap.
  - [01-audit.md](./01-audit.md) — Step 1 evidence-based audit (verified compute hours, word counts by section, 6 structural defects with exact stale-prose examples, real agent session / `scratchpad/` publishing friction, cloneability leaks).
  - [02-information-architecture.md](./02-information-architecture.md) — Step 2 visual IA diagrams (ASCII + Mermaid) for As-Is vs. Proposed v2, `docs/agents/` and `docs/repo/` separation, cloneability check, and 6 open decisions for owner review.
- **Untouched:** No existing repo or website files have been edited on `site-v2`. (Note: main `master` worktree has an intentional uncommitted `hardware/arrietty/benchmarks/bench33/AGENT.md` from Run 33 — do not touch the `master` worktree.)

## Verified Baseline Numbers (as of commit `be36dd59`)

- **Published site (`docs/`):** 85 `.md` files, 135,415 words (plus 22,949 words in root/repo governance docs).
- **Verified active local compute:** **338.6 hours** (`235.8h` across 56 EvalPlus runs + `102.8h` across 52 local Mendel runs), plus `17.5h` across 25 cloud Mendel baseline runs, plus untracked wall time from 32 bench runs, 5 research runs, 44 decode curves, calibrations, and smokes.
- **Local Mendel telemetry:** 438.2M total tokens, 2.93M output tokens, 9,444 tool calls, 427 commits.
- **Catalog:** 8 models, 2 machines (`kamaji` = M1 Max 32 GB, `arrietty` = RTX 5060 Ti 16 GB), 24 binaries, 47 rows (44 visible), 44 decode curves.

## Next Step: Step 3 (Review, Fact-Check, and Rewrite Plan)

1. **Walk through the 6 open decisions** in [02-information-architecture.md](./02-information-architecture.md#5-open-decisions-for-step-3-review) with the owner and record their decisions in `docs/site-v2/03-feedback.md` (or inside `03-rewrite-plan.md`).
2. **Fact-check every finding and headline number against raw artifacts:**
   - Cross-verify `docs/setups/*/models.json` against `hardware/*/benchmarks/bench*/results.md`, `benchmarks/mendel/results*.json`, and `docs/binaries.json`.
   - Resolve all known prose-vs-data contradictions listed in `01-audit.md` (old pre-fast-mode EvalPlus numbers, Run 33 Arete/S5-nano/Bonsai-2 omissions, 4 dead `arrietty/benchmarks/*.md` stubs, `bonsai2-mlx-mac` unmatched binary warning, stale dates).
   - Decide whether to audit and include depth-sweep / smoke wall times from `hardware/*/benchmarks/bench*/` into the compute-hours ledger, or display `339h+ scored compute` cleanly from JSON.
3. **Write `docs/site-v2/03-rewrite-plan.md`:**
   - Exact file-by-file migration map (keep, merge, auto-generate, move to `docs/agents/`, move to `docs/repo/`, delete).
   - Data schema upgrades needed so `tools/` has zero hardcoded `kamaji`/`arrietty` IDs and `config.mjs` auto-discovers setups/models/hours.
   - Content caps per page type (e.g., max words per verdict, 1-line row notes, zero duplicated prose) ready for Step 4 rewrite cycles.
4. **Then proceed to:**
   - **Step 4:** Content rewrite + `docs/agents/` & `docs/repo/` split (iterative conciseness review cycles; layout breakage acceptable here).
   - **Step 5:** Visual redesign around the locked structure (sidebar proof widget, charts, clean responsive tables, copy-paste presets).
