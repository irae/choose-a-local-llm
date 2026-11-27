# Site Writer Guide

Rules for writing and updating pages under `site/` and structured data under `data/`.

## 1. Source JSON First

Read the generated table beside your prose—or its source JSON (`data/setups/<hardware-slug>/models.json`, `data/binaries.json`, `site/.vitepress/data/site-stats.json`, `benchmarks/mendel/results*.json`)—before citing any score, speed, context ceiling, count, or wall time. Quote exact values from files, never from memory.

## 2. Single Home per Claim

Give every editorial claim one canonical page and link to it elsewhere instead of duplicating paragraphs:

- **Machine picks, local trade-offs, and serving presets:** `site/setups/<hardware-slug>/index.md` (retired/superseded builds go in `site/setups/<hardware-slug>/archive.md`).
- **Model behavior and quant/runtime comparison across machines:** `site/models/<slug>.md`.
- **Cross-cutting empirical laws and benchmark leaderboards:** `site/index.md` and `site/benchmarks/*.md`.
- **Hardware- and model-agnostic measurement protocol:** `site/method/*.md` (zero model names, vendor forks, or Hub repos).

## 3. Current Era First

Quote **fast-mode** EvalPlus (`think=8192`, `budget=16384`, `0 empty`), real-text `llama-benchy` decode speeds, and current-prompt Mendel runs as headline numbers. Cite pre-fast-mode, context-creep, or older-prompt figures only to contrast a method shift or when no newer run exists—always marked with `†` and its era.

## 4. Public Naming & Generated Surfaces

- **Hardware slugs in `site/`, hostnames in `hardware/`.** Use hardware display names (`M1 Max 32 GB`, `RTX 5060 Ti 16 GB`) or hardware slugs (`m1-max-32gb`, `rtx-5060ti-16gb`) throughout `site/`. `tools/check-hostnames.mjs` fails the check on any machine hostname leak.
- **Edit sources, regenerate outputs.** Update `data/` or `tools/gen-tables.mjs` and run `npm run docs:tables` to refresh `site/files/*`, `site/.vitepress/data/site-stats.json`, and every `<!-- gen:... -->` block. Leave generated blocks and `site/files/*` untouched by hand.

## 5. Style & Prose Word Caps

Write short, plain sentences in active voice (ASD-STE100), leading with conclusions. Keep chronological run diaries out of `site/`.

Word caps apply to prose outside generated blocks, tables, and fenced code:

| Path | Max prose words |
|---|--:|
| `site/index.md` | 350 |
| `site/setups/<slug>/index.md` | 450 |
| `site/setups/<slug>/archive.md` | 600 |
| `site/models/index.md` | 120 |
| `site/models/<slug>.md` | 400 |
| `site/benchmarks/index.md` | 250 |
| `site/benchmarks/{decode-speed,evalplus,mendel}.md` | 350 each |
| `site/method/*.md` | 1,000 each |
| `data/setups/*/models.json` (`rows[].note`) | 30 per row |

## Done Criteria

1. `npm run docs:tables` produces zero unexpected diff.
2. `npm run verify && npm run docs:check` exit `0`.
3. Hand the modified pages to a fresh review pass using [site-reviewer.md](./site-reviewer.md).
