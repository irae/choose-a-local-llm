# EvalPlus (HumanEval+) — M1 Max 32 GB

The quality gate: pass@1 at temperature 0, output budget calibrated per
model — see [the method](../../../methodology/evalplus). Scores are shared
across serving configs when thinking mode, effort, and quant match.

<!-- gen:evalplus-table:start -->
| model | mode | pass@1 base | pass@1 plus | empty | completion |
|---|---|--:|--:|--:|--:|
| [Qwen3.8-27B](./qwen3.8-27b.md) | effort medium | 0.982 | 0.939 | 0/164 | 100.0% |
| [Qwen3.6-35B-A3B](./qwen3.6-35b-a3b.md) | thinking on | 0.939 | 0.921 | 5/164 | 97.0% |
| [Ternary-Bonsai-27B (fork q4+bias)](./bonsai-27b.md) | thinking on | 0.927 | 0.890 | 4/164 | 97.6% |
| [Ternary-Bonsai-27B (MLX 2-bit)](./bonsai-27b.md) | thinking on | 0.915 | 0.884 | 5/164 | 97.0% |
| [Gemma-4-12B](./gemma-4-12b-it.md) | thinking off | 0.909 | 0.872 | 0/164 | 100.0% |
| [Gemma-4-12B](./gemma-4-12b-it.md) | thinking on (LM Studio `google/gemma-4-12b` entry) | 0.622 | 0.610 | 61/164 | 62.8% |
| [Gemma-4-26B-A4B](./gemma-4-26b-a4b.md) | thinking on | 0.713 | 0.701 | 46/164 | 72.0% |
<!-- gen:evalplus-table:end -->

An empty completion is reasoning that exhausted the output budget; a
high empty rate is a real model limit, not a harness bug. Completion
is the share of the 164 problems that got an answer at all. Read the
two columns together: Gemma-4-12B thinking on scores 0.622 because 37%
of its answers are missing, and 99% of the answers it did give pass. Raw runs and
per-problem results live in the repo's `benchmarks/` run kits; each
model's data page (first column) carries its scoring notes.
