# Bench 10 candidates

Status: list for the owner to filter when bench 9 closes. Each line is a
bench item: hardware, no judgment, exact commands written when the kit
is planned.
Filed: 2026-09-04.

- Gemma-26B GGUF EvalPlus with thinking off, at the KV type bench 9's
  short creep picks for it. One arm.
- LM Studio `gemma-4-12b-it-mlx`: wired memory at its 131K ceiling.
  The row reads `pending` for memory and stays off the comparison
  table until this is measured. One short sweep step with the runner's
  `wired_mb` column.
- Qwen3.8 MLX blind effort-low re-run under the retry rule (a valid
  partial row; harness-error branch, no penalty), after the output
  budget decision.
- Bonsai on the PrismML fork, blind thinking-high retry from scratch,
  with `reruns: 1` (model failure branch, 10 points off). Blocked on
  the KV bias corpus answer.
- Bonsai fork q8_0 KV arm without the bias file, against the fork's q4
  plus bias row. Blocked on the same answer.
- Any † row bench 9 leaves unmeasured.
- EvalPlus smoke validation on the reference setup: one live run to
  prove the imports and the padded evaluator, the same config twice
  (must not read "worse" than itself), and the two Bonsai configs with
  known differing scores. Steps 1 to 5 in the `benchmarks/evalplus-smoke.py`
  landing note (backlog index changelog, 2026-09-04).
