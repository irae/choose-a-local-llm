# Run 6 — report

The large form of the run's status line. See
`docs/methodology/status-lines.md`, "The site comparison, in full", for
the table rules. This run scored EvalPlus only; no depth sweep and no
Mendel row landed, so the Speed and context, Mendel, and Gates tables
have no rows and are left out.

Quality:

| old/new | # | Config | Max ctx | Gated by | tok/s (shallow → deep) | Memory | EvalPlus |
|---|--:|---|--:|:--:|--:|--:|--:|
| old | 8 | Gemma-4-12B, MLX³ | 158k* | mem | 35.4 → 29.29 | 8.1 GB | pending |
| new | — | Gemma-4-12B, MLX³ | 158k* | mem | 35.4 → 29.29 | 8.1 GB | **0.622/0.610/63%** |
| new | — | Qwen3.8-27B, MLX, effort low | 28k (qwen38-mlx-medium copy) | mem | 17 → 15.3 (qwen38-mlx-medium copy) | 22.0 GB (qwen38-mlx-medium copy) | 0.976/0.927/100% |
| new | — | Ternary-Bonsai-27B, MLX, bounded cache, thinking off | 58k (bonsai-mlx copy) | mem | 24.5 → 17.3 (bonsai-mlx copy) | 22.5 GB (bonsai-mlx copy) | 0.927/0.902/100% |

- **Gemma-12B thinking-on finished, resumed from 98/164.** 61 of 164
  completions are empty — reasoning ran out the 12000-token budget
  without producing an answer. Two tasks took 44 and 45 minutes of
  reasoning each and finished on their own; nothing was restarted.
  This is recorded as a real, honest empty rate, not chased with a
  larger budget.
- **Two new configs scored quality without a matching speed sweep.**
  Qwen3.8-27B at low reasoning effort and Bonsai at thinking off both
  ran their first EvalPlus pass here, and both carry their max
  context, gated-by, tok/s, and memory cells copied from a sibling
  config (medium effort for Qwen3.8, thinking-on for Bonsai) — no new
  depth sweep ran this run. The owner marked this a planning miss: the
  usual order is memory ceiling, then depth curve, then quality gate.
  The plan stands as written; run 7 picks up the missing sweeps.
  Bonsai thinking-off's expected non-zero empty rate did not
  materialize (0/164) — the one calibration problem that failed to
  converge at 30000 tokens converged fine within the real 8192 budget.
- **Block 4 (Qwen3.6-35B-A3B MTP drafter re-check) deferred to run 7**,
  by the owner's decision. This closes run 6 after block 3.
