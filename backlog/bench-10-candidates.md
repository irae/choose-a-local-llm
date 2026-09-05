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
   before any full EvalPlus. Bench 9 block B0 ran the tool's self-check
   (same config twice read level) and two f16-versus-q8_0 pairs; the
   known-difference check on the two Bonsai configs is still owed and
   runs here.
3. **Full EvalPlus** only where the smoke passed, thinking off, and
   thinking on where the model offers it.
4. **Gemma-4-26B-A4B GGUF at f16 KV, full EvalPlus, thinking on.**
   Right after the top models' creeps and gates, before any candidate
   below. Bench 9 moved the model to f16 and its row changed from 23.5
   to 8 tok/s gated by speed at 24K to 61.3 to 17.3 tok/s gated by mem
   at 196K. The smoke read level with q8_0 but misses one problem, and
   the 0.713/0.701 score was measured at q8_0. Served at 128K on
   purpose, it is a candidate for a secondary model: the machine stays
   usable and simple tasks finish faster than on a smarter, slower
   model. Owner rule for the same run: base pass@1 at or above 0.800
   sends it straight to Mendel blind; below that it stops at EvalPlus,
   and the owner decides against the competing models.

## Candidates for the steps above

- Gemma-26B GGUF EvalPlus with thinking off, at f16 (the thinking-on
  re-score is step 4 above).
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
