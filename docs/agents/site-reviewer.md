# Site Cross-Page Reviewer Checklist (Pass 1)

Run this checklist in a dedicated review pass after every batch of `site/` edits. Never rely on memory from drafting.

## 1. Prose ↔ Generated Table Parity (Same Page)

- [ ] Every score, context ceiling, tok/s, forced count, compaction count, and date mentioned in prose matches the generated table on the exact same page (or is explicitly labeled historical/diagnostic with its source).
- [ ] No pre-fast-mode EvalPlus score or superseded context ceiling is stated as current fact.

## 2. Cross-Page Parity (`models/<slug>` ↔ `setups/<slug>` ↔ `index.md`)

- [ ] For every model highlighted on `site/index.md` and `site/setups/<slug>/index.md`, verify that its cited winner config, Ctx, tok/s, EvalPlus, and Mendel score match `site/models/<slug>.md`. Any mismatch is a **blocking defect**.
- [ ] Verify caveats are preserved wherever a row is featured:
  - `Qwen3.8-27B unsloth UD-IQ3_S` Mac blind `90.5`: merged `master` mid-run (not strictly base-comparable).
  - `Ternary-Bonsai-2-27B`: requires PrismML `llama.cpp` fork (`prism-b10685-7dffb15`); stock `llama-server` rejects `PQ2_0`/`PTQ1_0`.
  - `S5-nano`: failed Mendel tool smoke on both Q8_0 and BF16; full Mendel skipped.
  - `Arete-27B`: passed tool smoke and EvalPlus; full Mendel pending.
  - `Qwen3.8-27B ISTA` RTX: served without drafter (`mtp/2` crashed 3× under desktop VRAM contention).

## 3. Compute Ledger Consistency

- [ ] Sidebar widget (`site/.vitepress/data/site-stats.json`), `site/index.md`, and `site/benchmarks/index.md` cite the exact same net JSON hours (`325h+`), and clearly distinguish documented diagnostic runs (`339.5h` / `340h+` total) and cloud baselines (`17.5h`).

## 4. Automated Verification Gates

- [ ] `npm run docs:tables` produces zero git diff.
- [ ] `npm run verify` (`vitepress build site` + `tools/check-links.mjs` with `>0` links checked) exits `0`.
- [ ] `npm run docs:check` (`gen-tables.mjs --check` + `check-hostnames.mjs` + `check-links.mjs`) exits `0` with zero warnings, zero unmatched binaries, and zero hostname leaks in `site/`.

## 5. Word-Budget & Separation Audit

- [ ] Prose word counts (outside generated tables/code blocks) respect the caps in `site-writer.md`.
- [ ] Zero model names appear anywhere in `site/method/*.md`.
- [ ] Zero agent SOPs (`state.md`, `HANDOFF.md`, `run-watch.sh`, `preflight.sh`, branch/worktree rules) remain in `site/`.
