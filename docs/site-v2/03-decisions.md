# Round 1 Review — Locked Decisions

Decisions confirmed by the owner after reviewing Step 1 ([01-audit.md](./01-audit.md)) and Step 2 ([02-information-architecture.md](./02-information-architecture.md)).

## Locked Decisions

| # | Topic | Decision | Implementation notes for Steps 3–5 |
| --- | --- | --- | --- |
| **D0** | **Defect 5 — Cloneability / Reusability** | **Acknowledge not ready; light cleanup only; park full reusability** | External tools (`issue-simulator`, `local-llm-eval-tools`) are still being extracted and have unreviewed/unpushed drift. Do cheap structural wins now (e.g., auto-discover setups/models in VitePress config, keep `site/method/` machine-agnostic), explicitly note current limits, and park full clone-and-run reusability in the backlog until tooling stabilizes. |
| **D1** | **Collapse `setups/<id>/reports/<slug>.md` into `/models/<slug>`** | **Approved** | One canonical model page (`/models/<slug>`) + one merged setup page (`/setups/<hardware-slug>/`). **Mandatory companion:** create **two separate guides** in `docs/agents/` — a concise **writer guide** and a **stricter reviewer guide** that cross-checks `models/<slug>` against `setups/<slug>` (and prose against generated tables) so overlapping claims cannot drift. |
| **D2** | **Per-binary pages (`/files/<id>`)** | **Approved (auto-generated)** | Generate `/files/<id>` 100% from `binaries.json`, `models.json`, and Mendel JSONs — zero hand-written duplicate prose. |
| **D3** | **Directory split (`site/` vs `docs/`)** | **Approved (`site/`)** | Move VitePress `srcDir` to `site/` so `docs/agents/`, `docs/repo/`, and `docs/site-v2/` sit physically outside the website build tree. |
| **D4** | **Sidebar proof widget (`339h+ benchmarked`)** | **Approved** | Auto-compute total hours, run counts, and model/machine counts at build time from JSON; render in the sidebar across all public pages, linking to `/benchmarks/`. |
| **D5** | **Public setup URLs -> hardware slugs** | **Approved + automated guard** | Use hardware slugs (`/setups/m1-max-32gb/`, `/setups/rtx-5060ti-16gb/`) on the public site while keeping hostnames (`kamaji`, `arrietty`) internal under `hardware/`. **Enforce via code (lint check in `npm run docs:check` / pre-commit hook), not agent docs**, so private hostnames never leak back into `site/`. Do **not** rewrite git history; historical occurrences are fine. |
| **D6** | **Split `docs/repo/` off the published site** | **Approved** | Keep cloner/operator documentation in GitHub Markdown under `docs/repo/`, linked from the website. The public site stays focused on findings, data, and scientific method. |

## Priority & Scope Calibration

- **Top priority (full rigor):** Public website (`site/`), automated data pipeline & hostname-leak guard, and the writer/reviewer guides in `docs/agents/` needed to execute Step 4 cleanly.
- **Best effort / parked for later re-planning:** Full cloneability/reusability (D0) and heavy polish on internal repo docs (`docs/repo/`) — revisit after `site/` lands and external benchmark tooling (`issue-simulator`) converges.

## Pending Confirmation Before Step 3 Handoff

1. **Clarify "item 4 … this is internal, correct?":** Confirm whether this referred to **End Goal #4 (`docs/repo/` split)** (internal/GitHub-only — best-effort for now) rather than **Decision 4 (sidebar hours widget)** (public website — top priority, cheap to auto-compute from JSON).
2. **Scope of `docs/agents/` in this pass:** Confirm whether `docs/agents/` gets full rigor alongside `site/` (including the new writer guide + stricter cross-page reviewer guide from D1) while `docs/repo/` stays best-effort.
