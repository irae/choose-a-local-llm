# Benchmarks & Compute Ledger

Every headline number on this site is computed directly from structured JSON under `data/` and `benchmarks/mendel/`. The sidebar proof badge (`325h+ benchmarked`) is the exact non-overlapping lower bound computed from structured JSON at build time.

## Compute Ledger

<!-- gen:compute-ledger:start -->
| Category | M1 Max 32 GB | RTX 5060 Ti 16 GB | Total |
|---|--:|--:|--:|
| **EvalPlus — net active GPU time** (56 runs) | 139.2h (26) | 80.4h (30) | **219.6h** |
| *EvalPlus — gross effective wall (incl. spliced carry-over)* | — | — | *235.8h* |
| **Mendel local — structured JSON** (54 runs) | 87.1h (41) | 18.3h (13) | **105.4h** |
| **Verified JSON local subtotal (non-overlapping)** | **226.3h** | **98.7h** | **325.0h** |
| Cloud Mendel baselines (25 runs) | — | — | 17.5h |

Local Mendel telemetry across 54 JSON runs: **438.2M** total tokens (**2.93M** output), **9,444** tool calls, **427** commits. Dataset catalog: **8** models, **25** model files, **43** active configs, **44** decode curves, **30** executed benchmark runs.
<!-- gen:compute-ledger:end -->

## Accounting Rules

- **Zero splice double-counting:** Nine fast-mode HumanEval+ runs carried over 119–154 unchanged problems from earlier budgeted runs (`16.2h` of carry-over wall). The ledger sums each run's incremental `ownWall` (`219.6h` net) instead of gross effective wall (`235.8h`).
- **Additional documented compute (`+14.5h` → `339.5h` total):** Six local diagnostic Mendel runs (testing an `8192` thinking budget across 5 models on M1 Max) are documented in run logs outside `results*.json`, bringing documented active local compute to **339.5h**.
- **Unaggregated compute excluded:** Depth curves, context-ceiling ladders, tool-calling smokes, calibrations, forced-answer re-runs (`3.2h`), and 5 exploratory research runs are not included in the `325h+` lower bound.

## Explore the Benchmarks

- [Decode Speed vs Context Depth](/benchmarks/decode-speed) — Real-text decode curves and usable context limits per machine.
- [HumanEval+ (Fast Mode)](/benchmarks/evalplus) — Single-turn coding quality gate under an `8192` thinking budget.
- [Mendel (Agent Coding)](/benchmarks/mendel) — End-to-end multi-file repository task scored against local configs and cloud baselines.
- [Model Files](/files/) — Auto-generated catalog of all 25 tested model files, pinned revisions, and serve presets.
