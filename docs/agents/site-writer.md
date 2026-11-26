# Site Writer Guide (Pass 1)

Rules for writing and updating pages under `site/` and structured data under `data/`.

1. **Numbers come from JSON, never memory.** Before citing any score, speed, context depth, or wall time in prose, read the generated table right beside it or `data/setups/*/models.json` and `benchmarks/mendel/results*.json`.
2. **One home per editorial claim.**
   - Machine-level trade-offs and picks live ONLY on `site/setups/<hardware-slug>/index.md`.
   - Model-level behavior across machines lives ONLY on `site/models/<slug>.md`.
   - Cross-cutting empirical laws live ONLY on `site/index.md` and `site/benchmarks/*.md`.
   - Never copy-paste a paragraph across two pages.
3. **Current era first.** Quote fast-mode EvalPlus (`think=8192`, `budget=16384`, `0 empty`) and real-text `llama-benchy` speeds as headline numbers. Mention pre-fast-mode or context-creep figures only when contrasting the method shift or when no newer measurement exists (marked with `†`).
4. **Stay under prose word caps.**
   - `site/index.md`: ≤ 350 words
   - `site/setups/<slug>/index.md`: ≤ 450 words
   - `site/setups/<slug>/archive.md`: ≤ 600 words
   - `site/models/index.md`: ≤ 120 words
   - `site/models/<slug>.md`: ≤ 400 words
   - `site/benchmarks/index.md`: ≤ 250 words
   - `site/benchmarks/{decode-speed,evalplus,mendel}.md`: ≤ 350 words each
   - `site/method/*.md`: ≤ 1,000 words each
   - `data/setups/*/models.json` `rows[].note`: ≤ 30 words per row
   Use short, plain sentences in active voice. No chronological run diaries.
5. **Zero hostnames in `site/`, zero model names in `site/method/`.** Always use hardware display names (`M1 Max 32 GB`, `RTX 5060 Ti 16 GB`) or hardware slugs (`m1-max-32gb`, `rtx-5060ti-16gb`) in `site/`. Enforced by `tools/check-hostnames.mjs`.
6. **Never hand-edit `site/files/*` or any `<!-- gen:... -->` block.** Fix `data/` or `tools/gen-tables.mjs` and run `npm run docs:tables`.
