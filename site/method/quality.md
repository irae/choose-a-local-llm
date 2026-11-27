# Coding Quality Method

Single-turn coding benchmarks measure whether a model and quantization retain strong code synthesis and reasoning accuracy before investing hours in multi-turn agent runs.

## Benchmark & Gate

- **Suite:** EvalPlus **HumanEval+** (164 Python programming problems evaluated against both `base` tests and stricter `plus` edge-case tests).
- **Sampling:** Greedy decoding (`temperature = 0`) for reproducibility.
- **Quality gate:** **0.800 base pass@1** with thinking enabled. Models below `0.800` do not advance to full agent runs.
- **Gate, not predictor:** A high HumanEval+ score proves single-turn syntax and algorithmic competence, not multi-turn tool use, planning discipline, or loop resistance. Models scoring above `0.98` on HumanEval+ can still score `0/100` on real agent tasks.

## Fast Mode (`8192` Thinking Budget / `16384` Output Cap)

Reasoning models evaluated with a fixed `max_tokens` cap and no server-side thinking budget fail badly on single-turn benchmarks: when a model loops in its thinking block until `max_tokens` expires, the final answer is empty and scores zero.

To eliminate empty-answer distortion without hiding real reasoning failures, all comparable scores use **fast mode**:

- **Server reasoning budget:** `8,192` tokens (`--reasoning-budget 8192`). When a completion reaches `8,192` reasoning tokens without closing its thought block, the server injects a fixed stop message and forces the model to emit its final code answer.
- **Total output cap:** `16,384` tokens (`max_tokens = 16384`), leaving room for the forced answer after thinking closes.
- **No calibration pass needed:** Every model and quant runs under the same `8192 / 16384` envelope, making scores directly comparable across machines and cutting run time.
- **Empirical validation:** Re-running forced-answer failures without a thinking budget (up to `30,000` tokens) showed that forced failures do not recover with more thinking — they either loop to the `30,000` cap or converge to the same wrong solution.

## Tracking Empties vs Forced Answers

Every EvalPlus row reports three integrity signals alongside `base / plus` pass@1:

- **Completion rate & empties (`0/164`):** Any non-zero empty count is classified by cause (`budget` vs `model` vs `† unproven` for older logs without finish reasons). Fast-mode runs produce `0/164` empties.
- **Forced count (`N/164`):** How many problems hit the `8,192` thinking cap and were forced to answer. Lower forced counts indicate cleaner reasoning convergence at equal pass@1.
- **Active wall time:** Incremental GPU time spent generating problems. When a fast-mode run splices unchanged problems from an earlier identical-config run (same weights, KV, and prompt where thinking already ended under `8,192`), only regenerated problems count toward net active compute.

## Runtime & Quant Sharing Rule

- **Same weights, same KV precision, same thinking mode** share one quality score across different slot counts or drafter settings (at `temperature = 0`, speculative decoding is mathematically lossless).
- **Different quantizations, different KV cache precisions, or different server backends** (e.g., GGUF vs MLX) are scored independently because weight packing, chat templates, and runtime kernels can alter convergence.
- Runtimes that ignore server-side reasoning budgets cannot produce fast-mode comparable scores and are flagged `†`.
