# Bench 10 plan draft

Status: draft for the owner to filter when bench 9 closes. Bench items
only: hardware, no judgment; exact commands come when the kit is
written.
Filed: 2026-09-04; the smoke step set by the owner the same day.

## Fixed steps, in order

1. **Slow creep** for every model still without a current curve after
   bench 9, one config per container type (GGUF, MLX), at the KV type
   the short creep picks.
2. **EvalPlus smoke on every survivor of step 1**, one config per type,
   before any full EvalPlus. This is the first real use of
   `benchmarks/evalplus-smoke.py`. The runner fixes the tool if it does
   not work as written (imports, the padded evaluator, the budget rule)
   and records what it changed; the first pass also runs the same config
   twice (must not read "worse" than itself) and the two Bonsai configs
   with known differing scores.
3. **Full EvalPlus** only where the smoke passed, thinking off for the
   worker seat and thinking on where the model offers it.

## Candidates for the steps above

- Gemma-26B GGUF EvalPlus with thinking off, at the picked KV type.
- LM Studio `gemma-4-12b-it-mlx`: wired memory at its 131K ceiling. The
  row reads `pending` for memory and stays off the comparison table
  until measured; one sweep step with the runner's `wired_mb` column.
- Any † row bench 9 leaves unmeasured.

## Mendel rows waiting on decisions

- Qwen3.8 MLX blind effort-low re-run under the retry rule (harness
  error branch, no penalty), after the output budget decision.
- Bonsai on the PrismML fork, blind thinking-high retry from scratch,
  `reruns: 1`. Blocked on the KV bias corpus answer.
- Bonsai fork q8_0 KV arm without the bias file, against the fork's q4
  plus bias row. Blocked on the same answer.

## Housekeeping on the Mac, first session

- An orphan Bonsai MLX blind session (started 2026-09-02 22:44, 52
  tool calls) sits in the Mendel scratch runs with no branch, no result
  row, and no archive entry. It is not a row and not invalid; it is an
  abandoned attempt. Copy its log into `benchmark/runs/` and add a
  `SESSIONS.md` line "abandoned attempt; no branch, no result row", the
  way the aborted Qwen3.8 medium session is recorded. Then archive with
  `tools/archive-evidence.sh`.
