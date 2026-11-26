# Step 3 — Fact-Check & Concrete Rewrite Plan (Pass 1)

This document completes **Step 3** under the locked Round 1 decisions ([03-decisions.md](./03-decisions.md), D0–D6) and the Two-Pass execution strategy. Every number below was verified directly against raw artifacts (`docs/setups/*/models.json`, `docs/binaries.json`, `benchmarks/mendel/results*.{json,csv}`, and `hardware/*/benchmarks/bench*/results.md` as of commit `be36dd59`).

**Scope:** Full rigor for the public website (`site/`), data pipeline, and build-time guards; lightweight, working separation for `docs/agents/` and `docs/repo/` (full overhaul deferred to Pass 2).

---

## 1. Verified Facts Sheet (Raw-Artifact Audit)

### 1.1 Exact Compute & Dataset Ledger

Cross-checking the raw JSONs and run logs caught **two accounting errors** in the Step 1 quick tally (`338.6h`):
1. **EvalPlus splice double-counting (−16.22h):** Nine fast-mode runs (`bench22`: 3 on M1 Max = `504.3 min`; `bench28`: 6 on RTX 5060 Ti = `469.0 min`) spliced 119–154 unchanged problems from earlier budgeted runs already present in `evalplusRuns[]`. Summing `wall` naively double-counts **973.3 min (16.22h)** of GPU time.
2. **Mendel branch-key collision undercount (+3.21h):** Two pairs of distinct physical runs share a `branch` string — `qwen3.8-27b-ista-xhigh-issue-13` ran on **both** M1 Max (`109.4m`, score `80.5`) and RTX 5060 Ti (`75.1m`, score `91`), and `prism-ml-Ternary-Bonsai-27B-mlx-2bit-off-guided-v3-issue-13` has two separate runs in `results-guided.json` (`83.5m` invalid gh-401 failure + `186.9m` retry2 loop). Deduplicating by `branch` alone dropped `192.9 min` of real compute.

The corrected, non-overlapping compute ledger:

| Category | M1 Max 32 GB (`m1-max-32gb`) | RTX 5060 Ti 16 GB (`rtx-5060ti-16gb`) | Total | Accounting rule |
| --- | ---: | ---: | ---: | --- |
| **EvalPlus — net active GPU time** *(56 runs)* | **139.19h** *(8,351.6m · 26 runs)* | **80.37h** *(4,822.0m · 30 runs)* | **219.56h** *(13,173.6m)* | Uses `ownWall` for the 9 spliced fast-mode runs (zero double-counting). |
| *— EvalPlus gross effective wall (incl. spliced)* | *147.60h (8,855.9m)* | *88.18h (5,291.0m)* | *235.78h (14,146.9m)* | Includes `504.3m` + `469.0m` = `973.3m` (`16.22h`) carried over from source runs. |
| **Mendel local — in `results*.json`** *(54 runs)* | **87.14h** *(5,228.6m · 41 runs)* | **18.30h** *(1,097.9m · 13 runs)* | **105.44h** *(6,326.5m)* | 29 blind (`50.39h`) + 25 guided (`55.05h`); active wall per `(setup, branch)`, retaining both distinct `bonsai-off` guided attempts (`83.5m` + `186.9m`). |
| **Verified JSON local subtotal (non-overlapping)** | **226.34h** | **98.67h** | **325.00h** | **Exact lower bound computable from structured JSON (`ownWall ?? wall`).** |
| **Additional documented local Mendel diagnostics** *(6 runs)* | **14.52h** *(871.2m · 6 runs)* | — | **14.52h** | `bench22` (`90.2m` bonsai-fork guided tb8192) + `bench30` (`781.0m` across 5 tb8192 runs); recorded in `results.md`, not in `results*.json`. |
| **Total documented active local compute (EvalPlus + Mendel)** | **240.86h** | **98.67h** | **339.52h** | Excludes untracked wall from 30 executed bench runs, 5 research runs, 44+ depth curves, calibrations, forced re-runs (`bench21`/`22`/`26`: `194m`), and smokes. |
| **Cloud Mendel baselines** *(25 runs)* | — | — | **17.49h** *(1,049.2m)* | 18 blind (`10.45h`) + 7 guided (`7.04h`). |

**Other verified dataset scale numbers (all checked directly):**
- **Local Mendel telemetry (54 JSON runs):** `438,153,354` total tokens (**438.2M**), `2,928,479` output tokens (**2.93M**), **9,444** tool calls, **427** commits.
- **Bench & research runs:** **30 executed bench runs** (`bench1`–`bench28`, `bench30`, `bench33`; `bench29` unused; `bench31` and `bench32` planned/unstarted) + **5 research runs** (`4` on M1 Max, `1` on RTX 5060 Ti).
- **Catalog:** **8 models**, **2 machines** (`m1-max-32gb`, `rtx-5060ti-16gb`), **24 binaries** in `binaries.json` (+ 1 missing entry for `bonsai2-mlx-mac` → **25 binaries** after fix), **47 rows** in `models.json` (`42` active/visible + `3` retired + `2` abandoned; plus `s5-nano-bf16-f16` measured in `bench33` → **48 rows** after fix), **44 curves** in `models.json` (+ `s5-nano` BF16/f16 curve from `bench33` → **45 curves**).

**Spliced EvalPlus `ownWall` table (to add as `ownWall` in `models.json` during Step 4):**

| Setup | `evalplusRuns` entry (`row`) | Effective `wall` (m) | Spliced carry-over (m) | True `ownWall` (m) | Raw source |
| --- | --- | ---: | ---: | ---: | --- |
| `m1-max-32gb` | `qwen38-gguf-xhigh` (fast) | `304.4` | `208.7` | **`95.7`** | `bench22/results.md` |
| `m1-max-32gb` | `gemma26-gguf` (fast) | `117.1` | `78.7` | **`38.4`** | `bench22/results.md` |
| `m1-max-32gb` | `bonsai2-ptq1-mac-xhigh` (fast) | `289.0` | `216.9` | **`72.1`** | `bench22/results.md` *(note: `bench22` prints `289.3 = 72.1 + 217.2`)* |
| `rtx-5060ti-16gb` | `bonsai2-ptq1-f16-xhigh` (fast) | `125.0` | `81.0` | **`44.0`** | `bench28/results.md` |
| `rtx-5060ti-16gb` | `bonsai2-pq2-f16-xhigh` (fast) | `121.0` | `77.0` | **`44.0`** | `bench28/results.md` |
| `rtx-5060ti-16gb` | `bonsai2-ptq1-xhigh` (fast) | `140.0` | `76.0` | **`64.0`** | `bench28/results.md` |
| `rtx-5060ti-16gb` | `bonsai2-pq2-xhigh` (fast) | `119.0` | `77.0` | **`42.0`** | `bench28/results.md` |
| `rtx-5060ti-16gb` | `bonsai2-ptq1-f16-orca-xhigh` (fast) | `152.0` | `82.0` | **`70.0`** | `bench28/results.md` |
| `rtx-5060ti-16gb` | `gemma12-nvfp4-on` (fast) | `211.0` | `76.0` | **`135.0`** | `bench28/results.md` |

> **Sidebar proof widget headline rule (D4):** Compute strictly from structured JSON using `ownWall ?? wall` so spliced runs are never double-counted. That yields **`325h+ benchmarked`** (exact JSON lower bound: `325.0h` across `110` scored local runs — `56` EvalPlus + `54` Mendel — plus `14.5h` documented diagnostic Mendel runs and unaggregated time across `30` executed bench runs / `45` depth curves). Link directly to `/benchmarks/` where the full breakdown table is transparent.

---

### 1.2 Verified Machine & Model Headline Facts

Every number below is the current ground truth from raw artifacts and overrides stale prose anywhere on `master`:

#### Machine Picks (`m1-max-32gb` — Apple M1 Max, 32 GB unified memory, macOS, wired limit 25000 MB)
- **Best overall coding agent:** **Qwen3.8-27B Q4_K_M** (`bartowski`, `llama-server`, f16 KV, no drafter, `xhigh`) — **93/100 blind** (8/8 libraries, 0 critical, 1 medium, 64k window, 3 compactions, 213m; also confirmed at **91/100** in `bench30` under 8192 thinking budget with 0 budget fires), **0.982 / 0.951** fast-mode EvalPlus (0 empty, 9/164 forced), `72k` ctx (`-c 73728`), `12.4 → 9.7 tok/s`.
- **Best long-context 27B agent:** **Qwen3.8-27B 3-bit (`unsloth UD-IQ3_S` / `ISTA IQ3_S-mtp`, f16 KV, no drafter, `xhigh`)** — `147k` ctx (speed-capped at ~8 tok/s), both **0.976 / 0.945** fast-mode EvalPlus (0 empty, 17/164 and 13/164 forced). Blind Mendel: ISTA **80.5/100** (and **87/100** in `bench30` tb8192, 0 budget fires); unsloth **90.5/100** *(anomaly: merged `master` mid-run, not strictly base-comparable; guided 62.5 partial at 300m cap)*.
- **Best fast MoE agent:** **Qwen3.6-35B-A3B UD-Q4_K_XL** (`unsloth`, `llama-server`, q8_0 KV, `mtp/3`, thinking on) — **83/100 guided** / **63/100 blind** (both 8/8), **0.976 / 0.939** fast-mode EvalPlus (0 empty, 17/164 forced), `82k` ctx (`-c 98304`), `43.7 → 13.0 tok/s`. *(Note: `bench30` found `llama-server` b10964 crashes on MTP n=3 + `--reasoning-budget`; no-drafter diagnostic completed cleanly at 79/100.)*
- **Longest usable context (with complete agent run):** **Gemma-4-26B-A4B UD-Q4_K_XL** (`unsloth`, `llama-server`, f16 KV, `mtp/2`, thinking on) — `197k` ctx (`-c 212992`), `60.1 → 19.1 tok/s`, **0.988 / 0.957** fast-mode EvalPlus (0 empty, 19/164 forced), **47.5/100 blind** (8/8) / **57/100 guided** (7/8; 56/100 in `bench30` tb8192).
- **Ternary Bonsai-2-27B on M1 Max:** **PTQ1_0 beats PQ2_0** at every depth (opposite of RTX 5060 Ti): `PTQ1_0` f16 KV reaches `160k` ctx (`17.9 → 9.1 tok/s`, **0.988 / 0.939** fast-mode EvalPlus, 10/164 forced; Mendel pending/cancelled). `PQ2_0` crosses 8 tok/s floor by `41k` (`17.05 → 9.50 tok/s`). Custom-wrapped MLX 2-bit (`bonsai2-mlx-server.py`, not stock MLX) is fastest at 4K (`21.47 tok/s`) but swap-caps at `28k` (`10.45 tok/s`).
- **Retired on M1 Max:** LM Studio (`lmstudio-retired.md`: 0 commits across 3 runs, unpinnable window) and Gemma-4-26B-A4B MLX (`gemma-4-26b-a4b-mlx-retired.md`: failed agent smoke on truncated tool call, 31/164 empty on EvalPlus).

#### Machine Picks (`rtx-5060ti-16gb` — GeForce RTX 5060 Ti 16 GB VRAM, 32 GB RAM, Linux, CUDA)
- **Best overall coding agent:** **Qwen3.8-27B IQ3_S-mtp** (`ISTA-DASLab`, `llama-server`, q8_0 KV, no drafter, `xhigh`) — **91/100 blind** and **85/100 guided** (both 8/8, window `61,440`, `29.43 → 21.13 tok/s`), **0.976 / 0.933** fast-mode EvalPlus (0 empty, 11/164 forced; `budget=10240`). *(MTP n=2 hits 45.9→26.2 tok/s but crashed 3× under desktop VRAM contention at ~440 MiB free; no-drafter keeps ~1.2 GB free and runs clean.)*
  - **In daily production use (owner note):** With an adjusted compaction trigger, `qwen3.8-27b-ista` has been the author's sole daily-driver local config—used ~6–12 hours/month for personal finance workflows (accessing email, gathering bills and statements, and building the software and scripts that automate it). Include this concisely on `site/index.md` or `site/setups/rtx-5060ti-16gb/index.md` and `site/models/qwen3.8-27b.md`.
- **Best long-context 27B agent:** **Ternary-Bonsai-2-27B** (`prism-ml` fork `prism-b10685-7dffb15`, `xhigh`) — **82/100 blind** on `PTQ1_0` f16 KV (`135k` ctx, `42.1 → 22.4 tok/s`, **0.976 / 0.945** fast-mode EvalPlus, 12/164 forced); **77/100 blind** on `PQ2_0` f16 KV (`119k` ctx, `46.3 → 25.1 tok/s`, **0.982 / 0.945**); **73.5/100 blind** on `PTQ1_0` q8_0 KV (`240k` ctx — deepest real agent peak measured at `225,161` tokens with 0 compactions, `41.7 → 12.8 tok/s`, **0.982 / 0.945**); **60.5/100 blind** on `PQ2_0` q8_0 KV (`208k` ctx, `46.0 → 14.5 tok/s`, **0.988 / 0.945**); **75/100 blind** on `PTQ1_0` f16 + refusal-ablation LoRA 1.0 (`135k` ctx, `40.8 → 22.0 tok/s`, **0.976 / 0.945**, 0 critical defects vs trap-A on unablated). *Requires PrismML fork — stock `llama-server` rejects `PQ2_0`/`PTQ1_0`.*
- **Fastest MoE rows (partial CPU-MoE offload):** **Qwen3.6-35B-A3B UD-Q4_K_XL** (`--n-cpu-moe 21`, `mtp/2`, q8_0 KV, `97k` ctx, `61.16 → 45.42 tok/s`, **0.976 / 0.933** fast-mode EvalPlus, 12/164 forced, **48.5/100 guided** 6/8); **Gemma-4-26B-A4B NVFP4Q8** (`--n-cpu-moe 7`, f16 KV, `97k` ctx, `58.77 → 45.59 tok/s`, **0.988 / 0.951** fast-mode EvalPlus, 19/164 forced, **37.5/100 guided** 3/8).
- **Highest single-turn score on site, zero agent success:** **Gemma-4-12B-it** — `UD-Q4_K_XL` f16 KV thinking on scores **0.988 / 0.963** fast-mode EvalPlus (highest `plus` score measured, 34/164 forced, `261k` ctx, `47.39 → 32.18 tok/s`); `NVFP4` thinking on scores **0.976 / 0.951** (44/164 forced, `49.55 → 33.11 tok/s`). Both builds scored **0/100 (model-failed, 0 commits)** on guided Mendel at both thinking on and off.
- **Run 33 additions (Nov 2026, `llama.cpp` v0.9.0 / b12110):**
  - **Arete-27B Q3_K_M** (`bartowski`, q8_0 KV, `xhigh`): `64k` clean depth (`-c 65536`, window `61,440`), `27.60 → 20.07 tok/s`, `15.4 GiB` VRAM, **0.976 / 0.951** fast-mode EvalPlus (0 empty, **7/164 forced** — lowest forced rate among 27B thinking models!), passed agent tool smoke (`14` calls, `1` commit, `122s`). Full Mendel deferred.
  - **S5-nano** (`maritaca-ai`, 4B-class): `Q8_0` / q8_0 KV reaches `261k` (`-c 262144`, `77.37 → 30.59 tok/s`, `10.9 GiB`), **0.811 / 0.726** fast-mode EvalPlus (26/164 forced; thinking-off **0.720 / 0.634**); `BF16` / f16 KV reaches `203,776` clean depth (`-c 204800`, window `200,704`, `45.68 → 26.41 tok/s`, `15.5 GiB`), **0.841 / 0.774** fast-mode EvalPlus (31/164 forced, at `-c 65536`). **Both Q8_0 and BF16 failed the Mendel tool smoke** (committed against outer repo / deleted fixture `.git`), so full Mendel was not run.
- **Retired on RTX 5060 Ti:** Qwen3.8-27B OBLITERATED (`Q3_K_M`: stripped chat template cannot tool-call, 0.854/0.787 medium EvalPlus; `Q4_K_M` `-ngl 45/64`: 5.13 → 2.31 tok/s, below 8 tok/s floor).

#### Verified Cross-Cutting Empirical Laws (Headline Claims for Home & Method)
1. **Unbounded thinking breaks single-turn benchmarks; an 8192 thinking budget fixes them without hurting agents.** On every single thinking-on vs thinking-off pair in fast mode (8192 think / 16384 output), thinking-on now **beats** thinking-off (e.g., Gemma-4-12B NVFP4 jumped `0.659 → 0.976`; UD-Q4_K_XL `0.793 → 0.988`; Gemma-4-26B NVFP4Q8 `0.909 → 0.988`; Qwen3.6 `0.945 → 0.976`). Across 12 natural re-runs of forced failures, **zero** forced answers ever passed with more thinking (every forced failure looped to 30K or failed wrong). On multi-turn Mendel runs (`bench22` + `bench30`, 6 runs), the 8192 budget fired **once** (capping an already-running thinking loop on Gemma-4-12B); normal agent turns peaked near ~1,400 thinking tokens.
2. **HumanEval+ is a gate, not a predictor of agent coding.** Gemma-4-12B UD-Q4_K_XL scores the highest HumanEval+ on the site (**0.988 / 0.963**) yet scores **0/100** on Mendel (zero commits). Qwen3.8-27B Q4_K_M scores **0.982 / 0.951** and leads local coding agents at **93/100 blind**, matching cloud frontier baselines (`kimi-k3` 93.5, `grok-4.6` 92.5, `gpt-5.6-sol` 92, `claude-opus-5` 90.5).
3. **Hardware flips optimal configs — never copy flags across machines:**
   - **KV cache type:** On M1 Max (Metal), quantized KV (`q8_0`) costs 2–4 µs/token vs `0.2–0.3` for `f16` (Gemma-4-26B at 32K: `6.3 tok/s` q8_0 vs `45.9` f16), so `f16` wins unless memory forces `q8_0`. On RTX 5060 Ti (CUDA), `q8_0` has minimal speed penalty and doubles usable context on 27B models (`65k` vs `53k` on Qwen3.8; `240k` vs `135k` on Bonsai-2 PTQ1_0), though `f16` led `q8_0` on Bonsai-2 blind Mendel on both packings (`82 vs 73.5`, `77 vs 60.5`, 1 run each).
   - **MTP speculative decoding:** Loses at every depth on M1 Max dense Qwen3.8 models on real text, wins on M1 Max MoEs (`Gemma-26B mtp/2`, `Qwen3.6 mtp/3`), and wins on speed for every RTX model that ships an MTP head — but costs VRAM/window on 16 GB cards (causing desktop-shared crashes on Qwen3.8 ISTA `mtp/2`), so dense RTX agent rows run without drafter.
   - **Ternary packing:** `PQ2_0` decodes faster on RTX 5060 Ti (`46.3 vs 42.1 tok/s`), whereas `PTQ1_0` is faster **and** 4× deeper on M1 Max (`160k` at `17.9→9.1` vs `41k` at `17.05→9.5`).
4. **Shallow decode speed hides deep-context collapse.** MLX curves stay flat until an abrupt Metal OOM (requiring a 5% harness margin and `--prompt-cache-size 2`); `llama-server` degrades gradually without OOMing inside `-c`. Partial dense-layer host-RAM offload (`-ngl 45/64`) collapses to `5.1 → 2.3 tok/s` (unusable), whereas partial MoE expert offload (`--n-cpu-moe 7` / `21`) holds `45+ tok/s` at `97k`.

---

### 1.3 Complete Contradiction & Data-Defect Resolution Table

Every contradiction identified in `01-audit.md` plus all new defects uncovered in Step 3, and how Pass 1 resolves each:

| # | Defect / Contradiction (on `master` `be36dd59`) | Raw-Artifact Truth | Pass 1 Resolution |
| --- | --- | --- | --- |
| **C1** | `docs/benchmarks/evalplus.md` "Thinking off against thinking on" claims thinking-off beats thinking-on (`0.976` vs `0.896`; `0.927` vs `0.659`). | Fast-mode table directly above proves thinking-on beats thinking-off on **every single pair** (`0.988 vs 0.976`, `0.976 vs 0.927`, `0.988 vs 0.951`, `0.976 vs 0.951`, `0.811 vs 0.720`). | Rewrite `site/benchmarks/evalplus.md` around fast-mode truth; move pre-fast-mode empty-cause table into a clearly labeled collapsed historical note. |
| **C2** | `docs/setups/kamaji/comparison.md` Highlights quote old `0.957/0.939` & `0.945/0.927`; 17-row hand-written decode table shows `pending` EvalPlus; Per-model list omits Bonsai-2; orphan `¹`/`²` footnotes. | Fast-mode scores are `0.982/0.951` and `0.976/0.945` (100%). Hand-written table superseded by `curves[]`. | Replace `index.md` + `comparison.md` with merged `site/setups/m1-max-32gb/index.md`. Delete hand-written decode matrix & orphan footnotes; auto-generate all tables. |
| **C3** | `docs/setups/arrietty/comparison.md` header says `measured 2026-09-13 to 2026-09-16`; Findings quote `0.659/0.640` & `0.793/0.780` ("Every thinking-on row left empties"); Per-model list omits Arete, S5-nano, Bonsai-2. | Fast-mode rows are `0.976/0.951` & `0.988/0.963` (0 empties); measurements span `2026-09-13` to `2026-11-09` (`bench33`). | Replace with merged `site/setups/rtx-5060ti-16gb/index.md` using verified Nov 2026 facts and auto-generated tables. |
| **C4** | `docs/setups/arrietty/index.md` omits `Ternary Bonsai-2-27B` completely; "Tested" stops at `2026-09-16` and says thinking budget is "Pending". | Bonsai-2 has 5 active rows + 82 blind Mendel; thinking budget became fast mode on `2026-09-19`; `bench33` ran Nov 2026. | Merged into `site/setups/rtx-5060ti-16gb/index.md`. |
| **C5** | **Stale `models.<slug>.stats` KPI objects inside BOTH `models.json` files** (10 of 13 model blocks still carry pre-fast-mode EvalPlus or pre-bench16 depth values; `s5-nano` mixes Q8_0 speed with BF16 EvalPlus in one strip). | All fast-mode EvalPlus scores and `bench16`/`bench26`/`bench33` curves are in `rows[]` / `evalplusRuns[]`. | Drop manual `models.<slug>.kpis` & `stats` completely (D1 removes report KPI boxes); derive model KPIs automatically from `rows[]` & `evalplusRuns[]`. |
| **C6** | **All 6 older `docs/models/*.md` pages** carry stale prose: `bonsai-2-27b.md` quotes pre-re-score `59.5` and weak-tier "critical" trap C while omitting `82`/`77`/`75`/`73.5` and all Mac rows; `qwen3.8-27b.md`, `gemma-4-12b-it.md`, `gemma-4-26b-a4b.md` say thinking budget is "under test"; `qwen3.6-35b-a3b.md` & `bonsai-27b.md` quote pre-fast-mode EvalPlus. | Verified facts in §1.2. | Rewrite all 8 canonical `site/models/<slug>.md` pages against §1.2; enforce Step 4 cross-page reviewer checklist. |
| **C7** | `docs/models/index.md` "Choosing a quant" quotes stale `0.957`, `0.659`, `0.909`, `0.896`; "Best per machine" omits Bonsai-2's `240K` window on RTX. | Fast-mode scores & Bonsai-2 `240K` PTQ1_0 q8_0. | Rewrite concise `site/models/index.md` (table-first, zero duplicated quant essays). |
| **C8** | **4 dead 10-line stubs** in `docs/setups/arrietty/benchmarks/{gemma-4-12b-it,gemma-4-26b-a4b,qwen3.6-35b-a3b,qwen3.8-27b}.md` saying *"nothing is measured yet"* — linked by every EvalPlus table! | All 4 models have full curves, EvalPlus, and Mendel measurements in `models.json` + `hardware/arrietty/benchmarks/`. | Eliminate `setups/*/benchmarks/*.md` entirely (D1/D2); link EvalPlus and decode tables to canonical `/models/<slug>` and auto-generated `/files/<binary-id>`. |
| **C9** | `docs/setups/kamaji/models.json` row `bonsai2-mlx-mac` matches NO entry in `docs/binaries.json` (`check-content-map.mjs` warning; unlinked config cell). | Pack is `prism-ml/Ternary-Bonsai-2-27B-mlx-2bit` at rev `3f926b4` (`bench26/results.md`). | Add `bonsai2-prism-mlx-2bit` entry to `data/binaries.json` (with `server: "mlx"`, `quant: "MLX 2-bit"`, `revision: "3f926b4"`). Zero unmatched-row warnings. |
| **C10** | `s5-nano-maritaca-bf16` has an entry in `binaries.json` and an orphan `evalplusRuns[]` entry (`0.841/0.774`, `row` omitted → `—` tok/s in EvalPlus table) with NO `rows[]` or `curves[]` entry despite `bench33/results.md` measuring its full depth curve (`203,776`, `45.68→26.41 tok/s`, `15.5 GiB`, failed tool smoke). | `bench33/results.md` lines 242–347. | Add `s5-nano-bf16-think` row (with `mendel: "failed-smoke"`) and its 6-point `benchy` curve to `data/setups/rtx-5060ti-16gb/models.json`, and link `evalplusRuns[29].row = "s5-nano-bf16-think"`. |
| **C11** | `docs/index.md` has orphan `¹` and `²` footnotes with no footnote markers in the table. | Table uses `<ModelSpec>` without `¹`/`²`. | Remove orphan footnotes; keep homepage crisp and self-explanatory. |
| **C12** | `docs/.vitepress/config.mjs` hardcodes 6 models (omitting `Arete-27B` & `S5-nano`), hardcodes `/setups/kamaji/` & `/setups/arrietty/`, omits `/binaries/`, and duplicates the model list 3× in the sidebar. | 8 models exist in `models.json`. | Auto-discover setups and models from `data/setups/*/models.json` inside `site/.vitepress/config.mjs` (D0/D5). |
| **C13** | 43 of 47 `models.json` rows have 30–431 word chronological essays in `note` (including contradictory lines like *"No EvalPlus row yet... The published score is..."* in `bonsai2-ptq1-xhigh`, and *"Thinking off is pending"* in `gemma12-q4kxl-on`). | Contradictory append-only notes inside `models.json`. | Trim every row `note` in `data/setups/*/models.json` to **≤30 words (1 concise factual line)**; keep detailed provenance in `hardware/*/benchmarks/` git history. |
| **C14** | `docs/methodology/` (13 files, 24,667w) leaks internal agent SOPs (`status-lines.md` 4,429w with raw typo'd chat quote & session hash, `checklist.md`, `server-lore.md`, `common-rules.md`), names 5+ models, and hardcodes `kamaji`/`arrietty`/`irae`. | Public method must be machine- and model-agnostic; agent SOPs belong in `docs/agents/`. | Replace with 4 concise, machine-agnostic public pages under `site/method/` (~3,500–4,500w total). Move agent SOPs to `docs/agents/` and cloner ops to `docs/repo/`. |
| **C15** | `docs/benchmarks/decode-speed.md` maintains a huge stale hand-written curve matrix beside `gen:decode-summary` (e.g., omits Bonsai-2 on both machines, omits Qwen3.8 unsloth on RTX, lists old creep speeds contradicting `benchy` rows). | `models.json` `curves[]` holds all 44 (+1 S5 BF16) curves. | Generate the full depth-curve tables directly from `curves[]` in `site/benchmarks/decode-speed.md`; zero hand-maintained curve matrices. |
| **C16** | `docs/benchmarks/mendel.md` links every local row to `../setups/<hostname>/reports/<slug>.md` (leaking hostnames and pointing to pages being deleted in D1). | Report pages collapse into `/models/<slug>` (D1). | Update Mendel table generator to link model names to `/models/<slug>` and binary pills to `/files/<binary-id>`. |
| **C17** | `npm run docs:check` silently passes with `0 links checked` when `dist/` is missing; `evalplusRuns[]` double-counts 16.22h of spliced compute if summed raw. | `tools/check-links.mjs` line 9 (`globSync` returns `[]` → exit 0); `bench22`/`bench28` splice walls. | Fix `tools/check-links.mjs` to exit 1 when `pages.length === 0`; add `ownWall` to the 9 spliced `evalplusRuns[]` entries and aggregate with `ownWall ?? wall`. |

---

## 2. Exact File-by-File Migration Map

### 2.1 Target Directory Layout (Decisions D3, D5, D6)

```text
choose-a-local-llm/
├── data/                                    # [DATA — OUTSIDE site/, holds internal hardwareId mapping]
│   ├── binaries.json                        # 25 entries (24 existing + bonsai2-prism-mlx-2bit)
│   └── setups/
│       ├── m1-max-32gb/models.json          # hardwareId: "kamaji", 1-line row notes, ownWall on spliced runs
│       └── rtx-5060ti-16gb/models.json      # hardwareId: "arrietty", + s5-nano-bf16-think row & curve
│
├── site/                                    # [PUBLISHED WEBSITE — VitePress srcDir = 'site']
│   │                                        # ZERO hostnames (kamaji/arrietty) allowed anywhere in tracked site/ files!
│   ├── .vitepress/
│   │   ├── config.mjs                       # Auto-discovers setups & models from data/
│   │   ├── data/site-stats.json             # Auto-generated compute ledger for sidebar widget & /benchmarks/
│   │   └── theme/                           # Vue components (ModelSpec, ScoreCell, TokCell, CurveCell, ProofSidebar)
│   ├── index.md                             # Home: hero proof strip, machine picks, best-per-model table, key laws
│   ├── setups/
│   │   ├── m1-max-32gb/
│   │   │   ├── index.md                     # Merged overview + full comparison + EvalPlus + serve presets
│   │   │   └── archive.md                   # Merged historical.md + lmstudio-retired.md + gemma-26b-mlx-retired.md
│   │   └── rtx-5060ti-16gb/
│   │       ├── index.md                     # Merged overview + full comparison + EvalPlus + serve presets
│   │       └── archive.md                   # Merged qwen38-obliterated-retired.md (+ any withdrawn RTX notes)
│   ├── models/
│   │   ├── index.md                         # All measured configs across all machines (Complete + In Progress)
│   │   └── <slug>.md  (×8)                  # Single canonical page per model (all machines, curves, EvalPlus, Mendel, files)
│   ├── files/                               # 100% AUTO-GENERATED (never hand-edited!)
│   │   ├── index.md                         # Auto-generated index of all 25 binaries grouped by model
│   │   └── <binary-id>.md  (×25)            # Auto-generated from data/binaries.json + models.json + mendel JSON
│   ├── benchmarks/
│   │   ├── index.md                         # Compute ledger (325h+ JSON / 340h+ documented) + benchmark overview
│   │   ├── decode-speed.md                  # 100% generated summary + full per-machine curve tables from curves[]
│   │   ├── evalplus.md                      # Fast-mode leaderboard + concise findings + collapsed pre-fast-mode archive
│   │   └── mendel.md                        # Local blind/guided + cloud baselines + link to hosted /mendel/ reports
│   └── method/                              # 4 crisp, machine- & model-agnostic public scientific method pages
│       ├── index.md                         # Gated testing funnel + what we do NOT measure + link to GitHub docs/repo/
│       ├── speed-and-memory.md              # Real-text depth sweeps, 8 tok/s floor, KV policy, memory ceilings
│       ├── quality.md                       # EvalPlus fast mode (8192/16384), forced vs empty, quant sharing
│       └── agent-coding.md                  # Mendel blind vs guided, rubric, loop detection, compaction
│
├── docs/                                    # [NON-PUBLISHED REPO & AGENT DOCS]
│   ├── agents/                              # Pass 1: clean placement + minimal Writer Guide & Strict Reviewer Checklist
│   │   │                                    # (Full-rigor overhaul scheduled in Pass 2)
│   │   ├── README.md                        # Minimal Pass 1 index (points to writer/reviewer guides + legacy run SOPs)
│   │   ├── site-writer.md                   # Concise Pass 1 writer rules for Step 4
│   │   ├── site-reviewer.md                 # Strict Pass 1 cross-page reviewer checklist (models ↔ setups ↔ JSON)
│   │   ├── standing-rules.md                # Moved from root AGENTS.md (Pass 1 lift-and-shift)
│   │   ├── planning.md                      # Moved from benchmarks/PLANNING.md (Pass 1 lift-and-shift)
│   │   ├── checklist.md                     # Moved from docs/methodology/checklist.md
│   │   ├── common-rules.md                  # Moved from docs/methodology/common-rules.md
│   │   ├── server-lore.md                   # Moved from docs/methodology/server-lore.md
│   │   └── status-lines.md                  # Moved from docs/methodology/status-lines.md
│   ├── repo/                                # Pass 1: best-effort human cloner & operator docs (D0/D6)
│   │   ├── README.md                        # How to use this repo on your own hardware (best-effort note on moving tools)
│   │   ├── hardware-setup.md                # Consolidated from wired-limit.md + tools/README-mac-services.md + Linux notes
│   │   └── running-benchmarks.md            # Links to scripts, external eval tools, archiving evidence, building site
│   └── site-v2/                             # Temporary planning workspace (rebased out when landing)
│
├── AGENTS.md                                # Slim pointer to docs/agents/ (keeps standing-rule discoverability intact)
├── README.md                                # Clean GitHub front door → live site + docs/repo/README.md
├── hardware/{kamaji,arrietty}/              # UNTOUCHED internal raw run kits & models.ini (hostnames live ONLY here + data/)
├── benchmarks/                              # UNTOUCHED benchmark scripts & Mendel mirrors
└── tools/                                   # Updated for data/ + site/ + new check-hostnames.mjs
```

> **Why `data/` sits outside `site/`:** Putting `models.json` and `binaries.json` under `data/` keeps `hardwareId` (`"kamaji"`, `"arrietty"`) available to internal tools (`tools/gen-pi-models.mjs`, `hardware/<id>/models.ini`, Mendel CSV legacy suffix matching) while guaranteeing that **`site/` contains literally zero machine hostnames in any tracked file** — no allowlists or exceptions required in the hostname linter!

### 2.2 Complete Disposition of Every Existing File in `docs/` (85 Files) & Governance Docs

| Old Path (on `master`) | Count | Action | New Path / Notes |
| --- | ---: | --- | --- |
| `docs/index.md` | 1 | **Rewrite** | `site/index.md` |
| `docs/binaries.json` | 1 | **Move + Fix** | `data/binaries.json` (+ add `bonsai2-prism-mlx-2bit`) |
| `docs/setups/kamaji/models.json` | 1 | **Move + Clean** | `data/setups/m1-max-32gb/models.json` (`hardwareId: "kamaji"`, 1-line notes, `ownWall`, drop stale `models.*.stats`) |
| `docs/setups/arrietty/models.json` | 1 | **Move + Clean** | `data/setups/rtx-5060ti-16gb/models.json` (`hardwareId: "arrietty"`, 1-line notes, `ownWall`, + `s5-nano-bf16-think` row & curve, drop stale `models.*.stats`) |
| `docs/setups/kamaji/{index,comparison}.md` | 2 | **Merge & Rewrite** | `site/setups/m1-max-32gb/index.md` |
| `docs/setups/arrietty/{index,comparison}.md` | 2 | **Merge & Rewrite** | `site/setups/rtx-5060ti-16gb/index.md` |
| `docs/setups/kamaji/{historical,lmstudio-retired,gemma-4-26b-a4b-mlx-retired}.md` | 3 | **Merge & Condense** | `site/setups/m1-max-32gb/archive.md` |
| `docs/setups/arrietty/qwen38-obliterated-retired.md` | 1 | **Move & Condense** | `site/setups/rtx-5060ti-16gb/archive.md` |
| `docs/setups/*/reports/*.md` | 13 | **Delete (collapsed)** | Collapsed into `site/models/<slug>.md` (D1). Unique non-redundant insights migrated to canonical model page. |
| `docs/setups/*/benchmarks/*.md` | 13 | **Delete (collapsed)** | 4 dead stubs + 9 raw archives replaced by `site/benchmarks/*`, `site/files/<id>.md`, and links to `hardware/` on GitHub. |
| `docs/models/index.md` | 1 | **Rewrite** | `site/models/index.md` |
| `docs/models/<slug>.md` | 8 | **Rewrite** | `site/models/<slug>.md` (canonical per-model page, all 8 models including `arete-27b` and `s5-nano`) |
| `docs/binaries/<id>.md` | 24 | **Replace w/ Auto-Gen** | `site/files/<id>.md` (×25) + `site/files/index.md`, 100% generated by `tools/gen-tables.mjs` (D2) |
| `docs/benchmarks/{decode-speed,evalplus,mendel}.md` | 3 | **Rewrite** | `site/benchmarks/{index,decode-speed,evalplus,mendel}.md` (adds `index.md` compute ledger) |
| `docs/methodology.md` + `docs/methodology/{context-creep,kv-cache-pick,memory-ceiling,quantization,evalplus,reasoning-budget,mendel}.md` | 8 | **Consolidate & Rewrite** | `site/method/{index,speed-and-memory,quality,agent-coding}.md` (4 crisp machine-agnostic pages) |
| `docs/methodology/{checklist,common-rules,server-lore,status-lines}.md` | 4 | **Move off site** | `docs/agents/{checklist,common-rules,server-lore,status-lines}.md` (Pass 1 lift-and-shift; Pass 2 refactors) |
| `docs/methodology/wired-limit.md` | 1 | **Move off site** | Merged into `docs/repo/hardware-setup.md` |
| `docs/website-plan.md` | 1 | **Delete** | Obsolete v1 migration plan (already excluded from VitePress build) |
| `docs/.vitepress/*` | 7 | **Move & Upgrade** | `site/.vitepress/*` (+ `ProofSidebar.vue`, auto-discovery `config.mjs`) |
| Root `AGENTS.md`, `EDITOR.md`, `CONTENT-MAP.md`, `CONVENTIONS.md`, `benchmarks/PLANNING.md` | 5 | **Pass 1 minimal split** | Keep `AGENTS.md` as short router → `docs/agents/`; move `PLANNING.md` to `docs/agents/planning.md`; replace `EDITOR.md`/`CONTENT-MAP.md` site sections with `docs/agents/site-writer.md` + `site-reviewer.md` (keep `CONVENTIONS.md` & `CONTENT-MAP.md` slim or archived until Pass 2 overhaul). |
| Root `README.md`, `tools/README-mac-services.md` | 2 | **Light update** | `README.md` points to live site + `docs/repo/README.md`; mac-services guide linked/merged into `docs/repo/hardware-setup.md`. |

**Net published site reduction:** From **85 markdown files / 135,415 words** (hand-maintained across 8 overlapping page types) → **21 hand-edited markdown pages (~12,000–15,000 words of crisp prose + generated tables)** + **26 100%-auto-generated `/files/*` pages**. Zero duplicated prose, zero dead stubs, zero leaked agent SOPs.

---

## 3. Technical Specifications for Pass 1 Tooling

### 3.1 Build & Deploy Path Updates

Every repo tool and CI workflow that hardcodes `docs/` must be updated atomically in Step 4A (before prose rewrite):

| File | Required Change |
| --- | --- |
| `package.json` | Update VitePress commands: `dev`: `vitepress dev site`, `build`: `vitepress build site`, `preview`: `vitepress preview site`. Update `docs:check` to: `node tools/gen-tables.mjs --check && node tools/check-hostnames.mjs && node tools/check-links.mjs`. *(Remove `check-content-map.mjs` dependency on old `docs/` markers or update it to validate `site/` markers.)* |
| `.github/workflows/site.yml` | Update `upload-pages-artifact` `path:` from `docs/.vitepress/dist` → `site/.vitepress/dist`. |
| `tools/sync-static.mjs` | Sync `benchmarks/mendel/*.html` → `site/public/mendel/` and `benchmarks/history/*.html` → `site/public/history/`. Update `.gitignore` for `site/public/` and `site/.vitepress/{dist,cache}/`. |
| `tools/check-links.mjs` | Default `dist` to `site/.vitepress/dist`, config to `site/.vitepress/config.mjs`. **Bug fix:** exit 1 with an error if `pages.length === 0` (fixes silent `0 links checked` pass when unbuilt). |
| `tools/gen-pi-models.mjs` | Read `data/setups/*/models.json` dynamically (removes hardcoded `['arrietty', 'kamaji']` on line 194 — cheap D0 win!), matching `--setup <hostname>` against `data.hardwareId` OR `data.hardwareSlug`. |

### 3.2 Code-Enforced Hostname-Leak Guard (`tools/check-hostnames.mjs`) — Decision D5

- **Purpose:** Guarantee machine hostnames never leak back into the published website (`site/`), enforced in CI and `npm run docs:check` (code, not agent docs).
- **Dynamic ban list:** Reads every `hardwareId` from `data/setups/*/models.json` AND every directory name under `hardware/*/` (currently `['kamaji', 'arrietty']`) so it scales automatically if a third machine is added.
- **Scan scope:** All files under `site/` **excluding** build/disposable outputs (`site/.vitepress/dist/**`, `site/.vitepress/cache/**`, `site/public/**`).
- **Match rule:** Case-insensitive word-boundary regex (`new RegExp('\\b(' + ids.join('|') + ')\\b', 'gi')`) checked against both **file paths** and **file contents**.
- **Failure output:** Prints `HOSTNAME LEAK  <file>:<line>  matched "<token>"` for every hit and exits `1`.
- **Optional local pre-commit hook:** Add `.githooks/pre-commit` running `node tools/check-hostnames.mjs` when staged files touch `site/` (documented in `docs/repo/README.md` via `git config core.hooksPath .githooks`; never mutates user's `.git/hooks/` silently).
- **Known external boundary:** `benchmarks/mendel/report*.html` synced into gitignored `site/public/mendel/` comes verbatim from the external Mendel repo and is outside `site/` source tracking.

### 3.3 Build-Time Sidebar Proof Aggregator (`site/.vitepress/data/site-stats.json`) — Decision D4

Generated automatically by `tools/gen-tables.mjs` (and checked by `--check`) from `data/setups/*/models.json`, `data/binaries.json`, and `benchmarks/mendel/results*.json`:

```json
{
  "generatedFrom": "data + benchmarks/mendel",
  "localActiveHours": 325.0,
  "displayHours": "325h+",
  "breakdown": {
    "evalplusNetHours": 219.6,
    "evalplusGrossHours": 235.8,
    "evalplusRuns": 56,
    "mendelLocalHours": 105.4,
    "mendelLocalRuns": 54,
    "mendelCloudHours": 17.5,
    "mendelCloudRuns": 25
  },
  "telemetry": {
    "totalTokens": 438153354,
    "outputTokens": 2928479,
    "toolCalls": 9444,
    "commits": 427
  },
  "counts": {
    "machines": 2,
    "models": 8,
    "binaries": 25,
    "activeConfigs": 43,
    "curves": 45,
    "executedBenchRuns": 30
  },
  "byMachine": {
    "m1-max-32gb": { "name": "M1 Max 32 GB", "evalplusNetHours": 139.2, "evalplusRuns": 26, "mendelHours": 87.1, "mendelRuns": 41, "totalHours": 226.3 },
    "rtx-5060ti-16gb": { "name": "RTX 5060 Ti 16 GB", "evalplusNetHours": 80.4, "evalplusRuns": 30, "mendelHours": 18.3, "mendelRuns": 13, "totalHours": 98.7 }
  }
}
```

- **Aggregation rules (non-negotiable):**
  1. EvalPlus hours sum `Number(r.ownWall ?? r.wall)` — never double-counts spliced runs.
  2. Local Mendel hours iterate every `r.local === true` entry in `results.json` and `results-guided.json`, resolve active wall by `(hardwareId, branch)` (keeping distinct `invalid` attempts at their own `telemetry.wall_clock_min` when a retry shares the branch).
  3. `executedBenchRuns` counts `hardware/*/benchmarks/bench*/state.md` files that do not start unstarted (or is read from an explicit metadata field in `data/setups/*/models.json` `benchRuns` so `site/` has zero runtime coupling to `hardware/`). Using `benchRuns` count in `models.json` keeps the generator 100% cloneable!
- **UI wiring:** `ProofSidebar.vue` imports `../data/site-stats.json` and renders inside VitePress's `sidebar-nav-before` layout slot (via a thin `Layout.vue` wrapper in `site/.vitepress/theme/index.js`). Shows **`325h+ benchmarked`** + compact 2-line proof (`110 scored runs · 8 models · 2 machines · 9.4k agent tool calls`), clickable to `/benchmarks/`. *(Exact visual styling belongs to Step 5; Step 4 wires the live data and functional component.)*

### 3.4 Auto-Generated `/files/<binary-id>.md` Pages — Decision D2

- **Zero hand-written prose.** `tools/gen-tables.mjs` generates `site/files/index.md` and every `site/files/<id>.md` directly from `data/binaries.json`, `data/setups/*/models.json`, and `benchmarks/mendel/results*.json`.
- **Clean-slate check:** In `--check` mode, verify that every generated file matches disk **and** that no orphan `.md` file exists under `site/files/` without a matching `binaries.json` entry.
- **Generated template per `site/files/<id>.md`:**
  1. Frontmatter: `editLink: false`, `generated: true`.
  2. `# <title>` + compact metadata table: Model (`/models/<slug>`), Quant, Publisher, Server, Hugging Face Repo (clickable link), File, Pinned Revision, Tested On (`hardwareName` links to `/setups/<hardware-slug>/`).
  3. `## Served configurations` — all matching `rows[]` across setups (using `renderTable`; retired rows listed in a compact line below; zero-row entries like `qwen38-unsloth-ud-q3kxl` / `qwen36-michaelw9999-nvfp4` render a 1-line `statusNote` field from `binaries.json`, e.g., *"Failed to load on CUDA (tensor-count defect); not served"*).
  4. `## Serve presets` — best preset + all `pi` INI sections (reusing `renderBinaryBestPreset` / `renderBinaryPresets`), plus copy-paste `llama-server` / `mlx_lm.server` command from the row.
  5. `## HumanEval+ runs` — all matching `evalplusRuns[]` (both fast-mode and historical, clearly tagged).
  6. `## Mendel runs` — all matching local Mendel runs from JSON/CSV across prompt versions.
- **Every `<ModelSpec>` link across the site** updates `page="/binaries/<id>"` → `page="/files/<id>"`.

### 3.5 Auto-Discovered VitePress Navigation & Refactored `tools/gen-tables.mjs`

- **Dynamic `site/.vitepress/config.mjs` (D0 cheap win):** At config load time, read `data/setups/*/models.json` via `fs.globSync`:
  - `nav`: Home (`/`), Setups dropdown (auto-built from `hardwareName` → `/setups/<hardwareSlug>/`), Models (`/models/`), Benchmarks (`/benchmarks/`), Method (`/method/`).
  - `sidebar`:
    1. `Setups`: auto-built per setup (`<hardwareName>` → `/setups/<slug>/`, plus `Archive` if `archive.md` exists).
    2. `Models`: `All models` + auto-built list of all distinct model slugs sorted cleanly (automatically includes `Arete-27B` and `S5-nano`!).
    3. `Benchmarks`: `Overview & Compute Ledger` (`/benchmarks/`), `Decode Speed` (`/benchmarks/decode-speed`), `HumanEval+` (`/benchmarks/evalplus`), `Mendel` (`/benchmarks/mendel`), `Model Files (25)` (`/files/`).
    4. `Method`: the 4 public method pages.
- **Streamlined `gen:` markers (cutting 27 fragile markers down to 13 clean ones):**
  - `site/index.md`: `gen:home-best-per-model`, `gen:home-machine-picks` *(optional, or table)*
  - `site/setups/<slug>/index.md`: `gen:setup-complete`, `gen:setup-partial`, `gen:setup-evalplus`, `gen:setup-presets`
  - `site/models/index.md`: `gen:models-complete`, `gen:models-incomplete`
  - `site/models/<slug>.md`: `gen:model-configs`, `gen:model-curves`, `gen:model-evalplus`, `gen:model-mendel`, `gen:model-files`
  - `site/benchmarks/index.md`: `gen:compute-ledger`
  - `site/benchmarks/decode-speed.md`: `gen:decode-summary`, `gen:decode-curves` (replaces hand-written matrices!)
  - `site/benchmarks/evalplus.md`: `gen:evalplus-fast`
  - `site/benchmarks/mendel.md`: `gen:mendel-local`, `gen:mendel-cloud`, `gen:mendel-guided`, `gen:mendel-guided-cloud`, `gen:mendel-stale`
  - `site/files/*`: whole-file auto-generated (zero inline markers needed!).
- **Fix `gen:model-mendel` dual-schema trap:** With `setups/*/reports/` deleted, `gen:model-mendel` now has **one** schema and **one** renderer (`renderModelAgent` on current prompt version, with a compact footnote linking to `/benchmarks/mendel#older-prompt-versions` for stale versions).
- **Decouple `hardwareOf()` default:** Never default unmatched Mendel rows silently to `'kamaji'`; match explicit `r.hardware`, then `, <hardwareId>)` suffix, then configured `defaultHardwareId` (or fail loudly on unknown local hardware). Strip hostnames before rendering any `site/` output.

---

## 4. Concise Page Budgets & Content Rules (Pass 1)

Every hand-written page under `site/` obeys strict word caps (prose outside generated tables/code blocks) and the **One-Home-Per-Claim** rule:

| Page Type | Count | Hand-Written Prose Budget | Allowed Prose Sections | Forbidden Content |
| --- | ---: | --- | --- | --- |
| `site/index.md` | 1 | **≤ 350 words** | Hero summary, 1-line winner per machine, 4–5 headline empirical laws, GitHub cloner CTA | Full legends, raw run logs, model essays, duplicate tables |
| `site/setups/<slug>/index.md` | 2 | **≤ 450 words** | Hardware facts (5–7 bullets), Top Picks (3–4 bullets), key machine quirks (KV/drafter/VRAM), link to `/archive` | Per-model essays, hand-written decode matrices, agent checklists, hostnames |
| `site/setups/<slug>/archive.md` | 2 | **≤ 600 words** | Concise summary of retired engines/builds & withdrawn eras + pointer to GitHub raw logs | Full chronological play-by-play logs |
| `site/models/index.md` | 1 | **≤ 120 words** | 2-sentence intro + 6-bullet compact legend | Repeated per-model takeaways (those live on `/models/<slug>`) |
| `site/models/<slug>.md` | 8 | **≤ 400 words** | 3–5 bullet Verdict (covering all tested machines), key serve gotchas, optional 1-paragraph sibling comparison (`Bonsai-1` vs `Bonsai-2`) | Repeating raw table rows in prose, unbudgeted pre-fast-mode numbers presented as current, chronological run diaries |
| `site/files/<id>.md` | 25 | **0 words** *(100% auto-generated)* | Auto-generated metadata, tables, INI presets | Any hand-written edits |
| `site/benchmarks/index.md` | 1 | **≤ 250 words** | Compute ledger explanation (net vs gross spliced hours, telemetry scope, unaggregated compute note), links to 3 benchmarks | Model rankings |
| `site/benchmarks/{decode-speed,evalplus,mendel}.md` | 3 | **≤ 350 words each** | 1-paragraph test definition, compact legend, 3–4 headline takeaways matching the generated table | Hand-written curve matrices, pre-fast-mode prose contradicting fast-mode tables |
| `site/method/*.md` | 4 | **≤ 1,000 words each** *(~3,500w total)* | Public scientific method only: funnel, depth floor, KV pick, fast-mode EvalPlus, Mendel rubric | Machine hostnames, specific model names, agent SOPs, chat formats, `sudo`/firewall ops |
| `models.json` `rows[].note` | 48 | **≤ 30 words / row** | 1 concise factual caveat (e.g., *"Requires PrismML fork; blind run peaked at 225K with 0 compactions."* or *"Failed agent smoke: stripped chat template."*) | Multi-paragraph chronological run histories |

---

## 5. Pass 1 Minimal Writer & Strict Cross-Page Reviewer Guides

Per Decision **D1** and the Two-Pass strategy, Step 4 uses two separate lightweight guides created in `docs/agents/` (full-rigor `docs/agents/` overhaul happens in Pass 2):

### 5.1 Pass 1 Writer Guide (`docs/agents/site-writer.md` — Spec)
1. **Numbers come from JSON, never memory.** Before writing any prose number, read the generated table right beside it or `data/setups/*/models.json` + `benchmarks/mendel/results*.json`.
2. **One home per editorial claim.**
   - Machine-level trade-offs & picks live ONLY on `site/setups/<slug>/index.md`.
   - Model-level behavior across machines lives ONLY on `site/models/<slug>.md`.
   - Cross-cutting benchmark laws live ONLY on `site/index.md` and `site/benchmarks/*.md`.
   - Never copy-paste a paragraph across two pages.
3. **Current era first.** Quote fast-mode EvalPlus (`think=8192`, `budget=16384`, `0 empty`) and real-text `benchy` speeds as the headline numbers. Mention pre-fast-mode or creep numbers only when explicitly contrasting the method shift or when no fast-mode/benchy measurement exists (marked with `†`).
4. **Stay under word caps (§4).** Short, plain sentences. Active voice. No filler, no session diaries, no chronological "first we tried X, then on date Y we tried Z."
5. **Zero hostnames in `site/`, zero model names in `site/method/`.** Always use hardware display names (`M1 Max 32 GB`, `RTX 5060 Ti 16 GB`) or hardware slugs (`m1-max-32gb`, `rtx-5060ti-16gb`).
6. **Never hand-edit `site/files/*` or any `<!-- gen:... -->` block.** Fix the data or generator instead.

### 5.2 Pass 1 Strict Cross-Page Reviewer Checklist (`docs/agents/site-reviewer.md` — Spec)

Run by a dedicated reviewer pass (separate review turn or subagent) after **each** Step 4 batch — never by the same pass that drafted the prose without a fresh verification sweep:

1. **Prose ↔ Generated Table Parity (Same Page):** Every score, context ceiling, tok/s, forced count, compaction count, and date mentioned in prose on a page MUST match the generated table on that exact page (or be explicitly marked historical/diagnostic with exact source).
2. **Cross-Page Parity (`models/<slug>` ↔ `setups/<slug>` ↔ `index.md`):**
   - Pick every model featured on `site/index.md` and `site/setups/<slug>/index.md`.
   - Compare its cited winner config, Ctx, tok/s, EvalPlus, and Mendel score against `site/models/<slug>.md`. Any discrepancy is a **blocking defect**.
   - Check anomalies and caveats: if a row has a known caveat (e.g., `unsloth UD-IQ3_S` Mac `90.5` merged `master`; `Bonsai-2` requires PrismML fork; `S5-nano` failed tool smoke; `Arete-27B` Mendel is pending), verify neither `models/<slug>` nor `setups/<slug>` overclaims it.
3. **Compute Ledger Consistency:** Verify the sidebar widget (`site-stats.json`), `site/index.md`, and `site/benchmarks/index.md` cite the exact same net JSON hours (`325h+`) and clearly distinguish documented diagnostic runs (`340h+` total) and cloud baselines (`17.5h`).
4. **Automated Gate Cleanliness:**
   - `npm run docs:tables` produces zero diff after generation.
   - `npm run verify` (`vitepress build site` + `check-links.mjs` with >0 links checked) exits `0`.
   - `npm run docs:check` (tables `--check` + `check-hostnames.mjs` + `check-links.mjs`) exits `0` with **zero warnings** (including zero unmatched binaries and zero hostnames in `site/`).
5. **Word-Budget & Separation Audit:**
   - Check prose word count of every edited page against §4 budgets.
   - Confirm zero model names in `site/method/*.md`.
   - Confirm zero agent SOPs (`state.md`, `HANDOFF.md`, `run-watch.sh`, `preflight.sh`, git branch/worktree rules) remain in `site/`.

---

## 6. Step 4 & Step 5 Execution Sequence (Pass 1)

Execute Pass 1 in tight, verifiable increments on branch `site-v2` (once Step 3 is approved by the owner, the planning-only commit restriction lifts for Step 4/5 implementation commits, still prefixed `[site-v2]: `):

### Step 4A — Data & Pipeline Scaffolding
1. Move `docs/binaries.json` → `data/binaries.json` (+ add `bonsai2-prism-mlx-2bit`) and `docs/setups/*/models.json` → `data/setups/<hardware-slug>/models.json` (add `hardwareId`, `ownWall` on 9 spliced runs, `s5-nano-bf16-think` row & curve, trim all 48 row `note` fields to ≤30 words, remove stale `models.*.stats`).
2. Scaffold `site/` (move `.vitepress/`, upgrade `config.mjs` to auto-discover setups & models, add `ProofSidebar.vue` + `Layout.vue` wired to `site-stats.json`).
3. Refactor `tools/gen-tables.mjs` (13 markers, whole-file `site/files/*` generator, `site-stats.json` aggregator, `curves[]` matrix generator, zero hardcoded hostnames in `site/` outputs).
4. Add `tools/check-hostnames.mjs` + `.githooks/pre-commit`; update `package.json`, `.github/workflows/site.yml`, `tools/sync-static.mjs`, `tools/check-links.mjs`, `tools/gen-pi-models.mjs`.
5. Move agent SOPs to `docs/agents/` (including Pass 1 `site-writer.md` and `site-reviewer.md`), create best-effort `docs/repo/`, slim root `AGENTS.md` and `README.md`, remove old `docs/` published files (`docs/index.md`, `docs/models/`, `docs/binaries/`, `docs/benchmarks/`, `docs/setups/`, `docs/methodology*`, `docs/website-plan.md`).

### Step 4B — Content Rewrite & Iterative Review Cycles
1. **Batch 1 (Core Findings):** Write `site/index.md`, `site/setups/m1-max-32gb/{index,archive}.md`, `site/setups/rtx-5060ti-16gb/{index,archive}.md`. Run generator + **Reviewer Cycle 1**.
2. **Batch 2 (Canonical Models):** Write `site/models/index.md` + all 8 `site/models/<slug>.md` pages. Run generator + **Reviewer Cycle 2** (strict cross-page audit `models/<slug>` ↔ `setups/<slug>` ↔ `index.md`).
3. **Batch 3 (Benchmarks & Method):** Write `site/benchmarks/{index,decode-speed,evalplus,mendel}.md` + 4 `site/method/*.md` pages. Run generator + **Reviewer Cycle 3** (full-site verification: `npm run verify && npm run docs:check`).

### Step 5 — Visual Redesign (Pass 1 Final)
- Redesign VitePress theme, typography, sidebar `ProofSidebar.vue` styling, homepage hero & machine-winner cards, clean decode-speed charts/visuals, and scannable Mendel/EvalPlus tables (eliminating the perpetually pulsing `⇢` arrow and 8-column pill overload) around the verified v2 structure.
- Preview locally (`npm run dev`), inspect desktop + mobile views, get owner approval & publish, then open the dedicated **Pass 2** thread for full-rigor `docs/agents/`.
