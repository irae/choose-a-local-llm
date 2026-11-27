# Site Cross-Page Reviewer Checklist

Run this audit in a dedicated review pass after every batch of `site/` or `data/` edits. Read every cited page and JSON source fresh—never verify from drafting memory.

Classify every finding as either a **blocking defect** (parity mismatch, dropped caveat, leaked hostname/model name, failed gate) or a **non-blocking note** (tightening/style).

## 1. Same-Page Parity (Prose ↔ Generated Table)

- [ ] Every score, context ceiling, tok/s, forced count, compaction count, wall time, and date in prose matches the generated table on that same page (or is explicitly marked `†` with its legacy era/source).
- [ ] No pre-fast-mode EvalPlus score, legacy context-creep ceiling, or superseded prompt result is stated as current fact.

## 2. Cross-Page Parity & Single-Home Check

- [ ] For every model featured on `site/index.md` or `site/setups/<hardware-slug>/index.md`, verify that its winner config, Ctx, tok/s, EvalPlus, and Mendel score match `site/models/<slug>.md` and `data/setups/*/models.json`. Any mismatch is a **blocking defect**.
- [ ] No editorial paragraph is duplicated across `site/index.md`, `site/setups/`, and `site/models/`; secondary pages link to the single home defined in [site-writer.md](./site-writer.md).
- [ ] Verify active model caveats stay attached wherever the row is featured (check `data/` first in case a pending run has landed):
  - `Qwen3.8-27B unsloth UD-IQ3_S` (M1 Max blind `90.5`): merged `master` mid-run (not strictly base-comparable).
  - `Ternary-Bonsai-2-27B`: requires PrismML `llama.cpp` fork (`prism-b10685-7dffb15`); stock `llama-server` rejects `PQ2_0`/`PTQ1_0`.
  - `S5-nano`: failed Mendel tool smoke on both `Q8_0` and `BF16`; full Mendel skipped.
  - `Arete-27B`: passed tool smoke and EvalPlus; full Mendel pending.
  - `Qwen3.8-27B ISTA` (RTX 5060 Ti): served without drafter (`mtp/2` crashed 3× under desktop VRAM contention).

## 3. Compute Ledger Consistency

- [ ] Read `site/.vitepress/data/site-stats.json` fresh and verify that the sidebar proof widget, `site/index.md`, and `site/benchmarks/index.md` report identical `displayHours` (`localActiveHours`), run counts, and machine/model counts, while clearly separating net local JSON hours, documented diagnostic totals, and cloud baseline hours.

## 4. Automated Verification Gates

- [ ] `npm run docs:tables` exits `0` and leaves zero git diff.
- [ ] `npm run verify` (`vitepress build site` + `tools/check-links.mjs` with `>0` links checked) exits `0`.
- [ ] `npm run docs:check` (`gen-tables.mjs --check` + `check-hostnames.mjs` + `check-links.mjs`) exits `0` with zero warnings, zero unmatched binaries, and zero hostname leaks in `site/`.

## 5. Word-Budget & Boundary Audit

- [ ] Prose word counts (outside generated blocks, tables, and fenced code) stay within the caps in [site-writer.md](./site-writer.md).
- [ ] Zero model names, vendor forks, or Hub repos appear in `site/method/*.md`.
- [ ] Zero machine hostnames or internal agent SOPs (`state.md`, `HANDOFF.md`, `run-watch.sh`, `preflight.sh`, worktree rules) appear anywhere in `site/`.

## Pass Criterion

Review passes only when every modified and cross-referenced page has been checked against sections 1–5, **zero blocking defects** remain, and all three automated verification gates pass cleanly.
