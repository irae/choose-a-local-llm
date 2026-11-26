# Round 1 Review — Locked Decisions

Decisions confirmed by the owner after reviewing Step 1 ([01-audit.md](./01-audit.md)) and Step 2 ([02-information-architecture.md](./02-information-architecture.md)). All open questions for Steps 1–2 are now closed.

## Locked Decisions

| # | Topic | Decision | Implementation notes |
| --- | --- | --- | --- |
| **D0** | **Cloneability / Reusability** *(Audit Defect 5 & IA §4 "Cloneability Check")* | **Best-effort now; park full reusability** | External tools (`issue-simulator`, `local-llm-eval-tools`) are still being extracted and have unreviewed/unpushed drift. Acknowledge upfront that full clone-and-run reusability is not ready yet; take cheap wins now (e.g., auto-discover setups/models in VitePress config, keep `site/method/` machine-agnostic) and revisit full reusability after external tooling stabilizes. |
| **D1** | **Collapse `setups/<id>/reports/<slug>.md` into `/models/<slug>`** | **Approved** | One canonical model page (`/models/<slug>`) + one merged setup page (`/setups/<hardware-slug>/`). Requires **two separate guides** in `docs/agents/` — a concise **writer guide** and a **stricter reviewer guide** that cross-checks `models/<slug>` against `setups/<slug>` (and prose against generated tables) so overlapping claims cannot drift. |
| **D2** | **Per-binary pages (`/files/<id>`)** | **Approved (auto-generated)** | Generate `/files/<id>` 100% from `binaries.json`, `models.json`, and Mendel JSONs — zero hand-written duplicate prose. |
| **D3** | **Directory split (`site/` vs `docs/`)** | **Approved (`site/`)** | Move VitePress `srcDir` to `site/` so `docs/agents/`, `docs/repo/`, and `docs/site-v2/` sit physically outside the website build tree. |
| **D4** | **Sidebar proof widget (`339h+ benchmarked`)** | **Approved (public site, full rigor)** | Auto-compute total hours, run counts, and model/machine counts at build time from JSON; render in the sidebar across all public pages, linking to `/benchmarks/`. |
| **D5** | **Public setup URLs -> hardware slugs** | **Approved + automated guard** | Use hardware slugs (`/setups/m1-max-32gb/`, `/setups/rtx-5060ti-16gb/`) on the public site while keeping hostnames (`kamaji`, `arrietty`) internal under `hardware/`. **Enforce via code (lint check in `npm run docs:check` / pre-commit hook), not agent docs**, so machine hostnames never leak back into `site/`. Keep git history as-is. |
| **D6** | **Split `docs/repo/` off the published site** | **Approved** | Keep cloner/operator documentation in GitHub Markdown under `docs/repo/`, linked from the website. The public site stays focused on findings, data, and scientific method. |

## Two-Pass Execution Strategy

1. **Pass 1 — Public Website Pristine (Top Priority · Full Rigor Now):**
   - Execute **Steps 3 → 4 → 5** with full rigor for **`site/`**: fact-check every headline number against raw artifacts, build the data-driven generator + auto-generated `/files/*` + sidebar `339h+` proof widget + code-enforced hostname-leak guard, rewrite all public pages concisely (with iterative review cycles), and redesign the layout around the new structure.
   - During Pass 1, keep **`docs/agents/`**, **`docs/repo/`**, and **Cloneability Check (IA §4)** at **low rigor / best effort** — just enough clean folder separation and a minimal working writer/reviewer split to execute Step 4 safely while keeping git history intact.
2. **Pass 2 — `docs/agents/` Full Rigor (Immediately After Website Approval & Publish):**
   - Start a dedicated follow-up thread right after the new website is approved and published.
   - Rebuild `docs/agents/` with full rigor (including the strict cross-page reviewer guide vs. writer guide, cleaned coordinator/runner procedures, and consolidated standing rules), and re-plan whether/how far to take `docs/repo/` and full cloneability once external tooling settles.
