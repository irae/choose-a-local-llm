# Step 1 — Evidence-Based Project Audit

What is actually in this repository, what real workflows look like, and what is broken today. Every claim below comes from the repository files, benchmark JSONs, git history, and past coordinator/runner sessions.

---

## 1. The real asset we are burying

This project sits on an unusually serious, reproducible local-LLM dataset. Almost none of that scale is visible to a first-time visitor.

| Metric | Verified count | Source |
| --- | ---: | --- |
| **Verified active local benchmark compute** | **338.6 hours** | `models.json` (`evalplusRuns`, `mendelWalls`) + `benchmarks/mendel/results*.json` |
| — EvalPlus (HumanEval+) local compute | **235.8 hours** (56 runs) | 147.6h on M1 Max 32 GB (26 runs) + 88.2h on RTX 5060 Ti 16 GB (30 runs) |
| — Mendel coding-agent local compute | **102.8 hours** (52 local runs) | 29 blind (51.0h) + 25 guided (55.1h raw; 102.8h active across 52 unique local rows) |
| — Cloud Mendel baseline compute | **17.5 hours** (25 cloud runs) | 18 blind + 7 guided reference runs |
| — Unaggregated compute *(not yet summed in JSON)* | **32 bench runs + 5 research runs** | 44 decode-depth curves, memory ladders, KV picks, calibrations, EvalPlus & Mendel smokes |
| **Agent telemetry recorded (local Mendel)** | **438.2M tokens** | 2.93M output tokens, **9,444 tool calls**, **427 git commits** |
| **Models / setups / binaries tested** | **8 models · 2 machines · 24 files** | 47 rows (44 visible), 44 depth curves, 1,510 raw result files in `hardware/` |
| **Project history** | **1,698 commits** | 2026-08-25 to 2026-11-09 |

**The core irony:** 339+ hours of controlled, reproducible benchmarking is hidden behind 135,415 words of repetitive markdown tables and contradictory prose. A visitor landing on a random page has no idea whether this is a weekend blog post or a 340-hour empirical study.

---

## 2. Where the 135,415 words on the website actually go

Measured across all 85 markdown files in `docs/` (`docs/website-plan.md` excluded from build, included below for completeness):

| Site section | Files | Words | Share | Primary role today |
| --- | ---: | ---: | ---: | --- |
| `docs/binaries/` | 24 | 32,995 | 24.4% | Per-GGUF/MLX file archive + duplicated prose + INI presets |
| `docs/setups/*/reports/` | 13 | 29,111 | 21.5% | Per-model-per-machine report + 200–430 word config notes |
| `docs/methodology/` + `methodology.md` | 13 | 24,667 | 18.2% | Mix of public scientific method AND internal agent SOPs |
| `docs/models/` | 9 | 16,182 | 11.9% | Cross-machine view per model (repeats tables + prose) |
| `docs/setups/*/benchmarks/` | 13 | 11,770 | 8.7% | Raw archives on Mac (200–330 lines); 4 empty stubs on RTX |
| `docs/benchmarks/` | 3 | 8,111 | 6.0% | Cross-machine Decode Speed, HumanEval+, Mendel tables |
| `docs/setups/*/{historical,*-retired}.md` | 4 | 5,108 | 3.8% | Withdrawn measurements and retired engines/builds |
| `docs/setups/*/comparison.md` | 2 | 4,455 | 3.3% | Machine leaderboard + hand-written stale decode table |
| `docs/website-plan.md` *(excluded)* | 1 | 1,307 | 1.0% | Stale initial VitePress migration plan |
| `docs/setups/*/index.md` | 2 | 992 | 0.7% | Hardware facts, runtimes, model list |
| `docs/index.md` | 1 | 717 | 0.5% | Landing page |
| **Total (`docs/`)** | **85** | **135,415** | **100%** | |

Meanwhile, outside `docs/`, agent and repository governance adds another **22,949 words** across root and tooling docs:
- `EDITOR.md` (6,650 words), `AGENTS.md` (4,999 words), `CONTENT-MAP.md` (3,856 words), `benchmarks/PLANNING.md` (3,720 words), `tools/README-mac-services.md` (1,328 words), `backlog/index.md` (1,063 words), `CONVENTIONS.md` (968 words), `benchmarks/calibration.md` (707 words), `README.md` (616 words) — plus `HANDOFF.md` (16.7 KB, gitignored) and 7,737 words across both `hardware/*/benchmarks/INDEX.md` files.

---

## 3. Six structural defects (ranked by severity)

### Defect 1 — Eight overlapping page types slice the same 44 rows
The same measurement for one model configuration is repeated across up to **eight** different pages:
1. `docs/index.md` (best per model)
2. `docs/models/index.md` (all configs, all machines)
3. `docs/models/<slug>.md` (all configs of one model, all machines)
4. `docs/binaries/<id>.md` (all configs of one GGUF/MLX file — 24 pages, 33k words, NOT in the sidebar)
5. `docs/setups/<setup>/comparison.md` (all configs on one machine)
6. `docs/setups/<setup>/reports/<slug>.md` (all configs of one model on one machine — up to 5,640 words on a single page!)
7. `docs/setups/<setup>/benchmarks/<slug>.md` (raw archive per model per machine)
8. `docs/benchmarks/{decode-speed,evalplus,mendel}.md` (cross-machine benchmark tables)

**Consequences:**
- A reader trying to answer "what should I run on my 16 GB GPU?" or "how good is Qwen3.8?" bounces between 4+ pages that look almost identical and have different scopes (`gen:model-mendel` even renders **different row counts and different table schemas** on `reports/<slug>.md` vs. `models/<slug>.md`, as `CONTENT-MAP.md` explicitly admits!).
- `docs/setups/kamaji/reports/qwen3.8-27b.md` is **407 lines / 5,640 words**; `docs/setups/arrietty/reports/bonsai-2-27b.md` is **3,447 words**. Nobody reads 5,600 words to pick a local model.
- `EDITOR.md` says row `note` is "an optional one-line `note`." In reality, **43 of 47 rows** in `models.json` have >30-word essays in `note`, peaking at **431 words** on `arrietty` and **296 words** on `kamaji`. Every `Configs` section on every report page turns into a wall of chronological narrative.

### Defect 2 — Systematic prose-vs-data rot (contradictions on the SAME page)
Because conclusions, highlights, KPIs, and pick lists are hand-written in 5+ places while tables are regenerated from JSON, **updating a benchmark score automatically makes surrounding prose wrong.** Real examples live on `master` right now:

| Page | Stale hand-written prose | Actual generated table right beside it |
| --- | --- | --- |
| `docs/setups/kamaji/reports/qwen3.8-27b.md` | KPI box & Highlights say `0.957 / 0.939 (96% completion)` and `0.945 / 0.927` | Table says `0.982 / 0.951 (100%)` and `0.976 / 0.945 (100%)` |
| `docs/setups/kamaji/comparison.md` | Highlights say `0.957 / 0.939` & `0.945 / 0.927`; 17-row hand-written decode table shows `pending` EvalPlus; Per-model list omits Bonsai-2; orphan `¹`/`²` footnotes | Table says `0.982 / 0.951` & `0.976 / 0.945`; Bonsai-2 is in partial table |
| `docs/setups/arrietty/comparison.md` | Header says `measured 2026-09-13 to 2026-09-16`; Findings quote `0.659 / 0.640` and `0.793 / 0.780` ("Every thinking-on row left empties"); Per-model list omits Arete, S5-nano, Bonsai-2 | Fast-mode table directly above shows `0.976 / 0.951` and `0.988 / 0.963` with **zero empties**; Arete & S5-nano measured Nov 2026 |
| `docs/benchmarks/evalplus.md` | "Thinking off against thinking on" claims thinking-off beats thinking-on (`0.976` vs `0.896` on Gemma-26B; `0.927` vs `0.659` on Gemma-12B NVFP4) | Fast-mode table at top shows thinking-on beats thinking-off on **every single pair** (`0.988` vs `0.976`; `0.976` vs `0.927`) |
| `docs/models/index.md` & `qwen3.8-27b.md` | "Choosing a quant" quotes old `0.957` and `0.659`; `qwen3.8-27b.md` says thinking budget is "under test" | Fast-mode thinking budget has been standard since 2026-09-19 |
| `docs/setups/arrietty/benchmarks/{gemma-4-12b-it,gemma-4-26b-a4b,qwen3.6-35b-a3b,qwen3.8-27b}.md` | **4 dead 10-line stubs** saying *"The first run started 2026-09-13; nothing is measured yet."* | Every EvalPlus table on the site links directly to these dead stubs! |
| `docs/setups/arrietty/index.md` | Models table omits `Ternary Bonsai-2-27B` completely; "Tested" stops at 2026-09-16 | Bonsai-2 has 6 complete rows and an 82 blind Mendel score on RTX |
| `docs/.vitepress/config.mjs` | Sidebar `Models` lists only 6 models — omits `Arete-27B` and `S5-nano`; omits all 24 `Binaries` pages | Both models are live on `docs/index.md` and `docs/setups/arrietty/` |
| `docs/index.md` | Footnotes `¹` and `²` exist at bottom with no `¹`/`²` markers in the table | Table uses `ModelSpec` components without footnote markers |

*Why this happens:* Not carelessness — **architecture**. When one score requires hand-editing 5–6 markdown prose files in addition to JSON, prose rot is guaranteed.

### Defect 3 — Audience collision: public site vs. agent SOPs vs. repo ops
Three completely different audiences are tangled in the same directories:

1. **Human reader evaluating models** (wants answers in 30 seconds, plus clickable deep evidence).
2. **Human developer cloning the repo** (wants setup, hardware config, scripts, and how to publish their own machine).
3. **AI coordinator & runner agents** (needs strict operational rules, branch/worktree mechanics, runbook syntax, status formats, and publishing checklists).

**Concrete evidence of the collision:**
- `docs/methodology/status-lines.md` (**4,429 words** — the single longest page under `Methodology`!) is published on the public website. It specifies internal agent chat heartbeat formats, quotes a raw typo'd user chat message (*"statusline shoudl repeat model/want/etc... not reasable for me"*), leaks an internal session hash, names five models (violating the project's own "method pages never name a model" rule), and is even superseded by a later standing rule in `AGENTS.md` banning live progress messages!
- `docs/methodology/checklist.md` (2,667 words) and `docs/methodology/server-lore.md` (1,369 words) mix scientific method with internal runner ops ("One more time: the GPU does not sit idle", macOS login-item management, firewall alerts, runner crash watchers).
- `docs/methodology/common-rules.md` mixes genuine scientific rules (prompt-cache rule, KV policy) with internal site-maintenance rules (record-everywhere rule) and hardcodes `kamaji` / `arrietty`.
- Meanwhile, **agent rules are fragmented across 7+ files** (`AGENTS.md`, `EDITOR.md`, `CONTENT-MAP.md`, `CONVENTIONS.md`, `benchmarks/PLANNING.md`, `HANDOFF.md`, `docs/methodology/*`), totaling **~40,000+ words** when combined with `docs/methodology/`. Agents routinely miss rules because they are duplicated and contradictory across files (for example: 21 separate Claude feedback memories exist just to patch agent misreads of workflow/merge/publish rules).

### Defect 4 — Publishing friction observed in real agent sessions
Reviewing real Run 33 sessions and `scratchpad/` artifacts reveals what publishing actually costs today:
- To publish Run 33 (Arete-27B and S5-nano), the coordinator wrote **8 separate one-off Python scripts** in `scratchpad/` (`prepare-arete-entry.py`, `publish-arete-depth.py`, `publish-arete-quality.py`, `publish-s5-depth.py`, `publish-s5-quality.py`, `publish-s5-instruct.py`, `publish-s5-bf16-port.py`, `record-s5-agent-gate.py`).
- Inspecting `scratchpad/publish-s5-bf16-port.py` shows a single BF16 EvalPlus result forced edits to **6 separate files** (`models.json`, `binaries.json`, `reports/s5-nano.md`, `models/s5-nano.md`, `benchmarks/s5-nano.md`, `binaries/s5-nano-maritaca-bf16.md`), copy-pasting the **exact same two-paragraph quality block into three different markdown pages**, followed by `gen-tables.mjs` mutating 10+ files — and STILL missing `config.mjs` (sidebar) and `comparison.md` (per-model list)!
- `tools/gen-tables.mjs` has grown to **1,465 lines / 76 KB** and been modified in **93 commits** (the 3rd most-churned file in the repo). It uses fragile string-matching maps (`MENDEL_SLUGS`, `MENDEL_SPECS`, `MENDEL_SERVER`) and mutates markdown files in place between 27 `<!-- gen:... -->` marker pairs, requiring a second validator (`tools/check-content-map.mjs` + 319-line `CONTENT-MAP.md`) just to keep track of what writes where.
- Real sessions also hit **tool/config drift**: `tools/preflight.sh` exits 1 on Linux every single time because four checks assume macOS (`HANDOFF.md` line 292); `docs/setups/arrietty/benchmarks/*.md` never got populated after `bench17`; and `npm run docs:check` silently reports `0 links checked` if `docs/.vitepress/dist` hasn't been built first!

### Defect 5 — Broken cloneability / reusability
The project explicitly promises: *"The process stands on its own; only the measurements are ours."* In practice, cloning the repo and clearing our hardware breaks multiple subsystems:

| File / Subsystem | Hardcoded owner/machine coupling |
| --- | --- |
| `docs/.vitepress/config.mjs` | Hardcodes nav & sidebar links for `M1 Max 32 GB` (`/setups/kamaji/`), `RTX 5060 Ti 16 GB` (`/setups/arrietty/`), and 6 specific models |
| `tools/gen-tables.mjs` | Line 79 defaults unmatched Mendel rows to `'kamaji'`; lines 118–298 hardcode `MENDEL_SLUGS` and `MENDEL_SPECS` for Irae's specific `kamaji`/`arrietty` runs |
| `tools/gen-pi-models.mjs` | Line 194 literally hardcodes `['arrietty', 'kamaji']` |
| `docs/methodology/` (10 of 13 files) | Reference `kamaji`, `arrietty`, `irae`, and 5+ specific model names (`checklist.md`, `common-rules.md`, `context-creep.md`, `evalplus.md`, `memory-ceiling.md`, `mendel.md`, `quantization.md`, `reasoning-budget.md`, `server-lore.md`, `status-lines.md`) |
| `README.md` & `CONVENTIONS.md` | Hardcode `hardware/kamaji/benchmarks/bench<N>/AGENT.md` and `irae` |
| `tools/sweeps/*.sh` | Three sweep scripts hardcode `kamaji` / `irae` paths |

### Defect 6 — Navigation, discoverability, and visual overload
- **No proof of depth on landing or sidebar:** The homepage (`docs/index.md`) jumps straight into an 8-row dense component table with opaque abbreviations (`UD-Q4_K_XL`, `PTQ1_0`, `mtp/3`, `f16`, `xhigh`, `0.982/0.951`, `mendel-blind`), followed by a 21-line legend. There is no executive takeaway ("What wins on each machine?"), no visual chart, and no site-wide indicator of the **339+ hours** of testing behind those numbers.
- **Opaque table density:** `docs/benchmarks/mendel.md` packs 8 columns of nested colored HTML pills (`calls 272/23`, `commits 17`, `failed commits 1`, `turns 242`, `nudges 2t`, `trimmed 56%`, `394%`, `3 compactions`) into a markdown table that scrolls horizontally with a perpetually pulsing `⇢` arrow (`animation: table-hint-pulse 1s linear infinite` on EVERY table, even tables that don't overflow!).
- **Orphaned & unreachable pages:** 24 `docs/binaries/*.md` pages, 13 `docs/setups/*/benchmarks/*.md` pages, and 3 `*-retired.md` pages are absent from the sidebar. Meanwhile, the sidebar duplicates the model list **three times** (once under `Models`, once under `M1 Max 32 GB -> Models`, once under `RTX 5060 Ti 16 GB -> Models`).
- **Inconsistent naming between URLs and labels:** Machine folders use hostnames (`kamaji`, `arrietty`), pills use hardware slugs (`m1-max-32gb`, `rtx-5060ti-16gb`), and titles use display names (`M1 Max 32 GB`, `RTX 5060 Ti 16 GB`). Readers don't know what `kamaji` or `arrietty` mean when they see them in URLs or INI paths.

---

## 4. Summary verdict

The **data and scientific method are genuinely strong** — 339+ active hours of controlled EvalPlus, Mendel agent runs, and real-text depth curves that caught non-obvious truths (thinking budgets turning 0.659 into 0.976, MTP drafters losing on Mac dense models while winning on CUDA, ternary 27B hitting 240K on 16 GB VRAM, MLX flat-then-OOM vs. llama.cpp gradual creep).

The **presentation, information architecture, and doc layout are fighting that data**:
1. Too many overlapping page types force copy-pasted prose that rots immediately.
2. Public findings, human cloner guides, and internal AI agent runbooks are jammed into the same `docs/` tree.
3. The site reads like an internal lab notebook instead of a sharp, scannable reference backed by deep, verifiable evidence.
4. Machine-specific plumbing leaked into the generator, VitePress config, and methodology pages, undermining clone-and-run reuse.

Step 2 ([02-information-architecture.md](./02-information-architecture.md)) maps the current structure visually and proposes a clean v2 architecture that fixes all six defects.
