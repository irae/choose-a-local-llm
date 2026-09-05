# Bench 10 plan draft

Status: draft for the owner to filter; run 9 closed 2026-09-05 and this
draft is de-duplicated against it. Bench items only: hardware, no
judgment; exact commands come when the kit is written.
Filed: 2026-09-04; the smoke step set by the owner the same day.

## Fixed steps, in order

1. **Slow creep** for every config still without a current curve, at
   the KV type the short creep picks, one config per container type.
   Run 9 covered the three GGUF single-slot configs. Still daggered or
   pending: Qwen3.8 MLX effort low, Bonsai MLX thinking off, Gemma-12B
   GGUF 4 slots, Gemma-26B GGUF 2 slots (needs re-planning at f16),
   LM Studio Gemma-12B wired memory at its ceiling.
2. **EvalPlus smoke on every survivor of step 1**, one config per type,
   before any full EvalPlus. The tool's self-check passed in run 9; the
   known-difference check on the two Bonsai configs is still owed and
   runs here.
3. **Qwen3.8-27B GGUF at f16 KV, full EvalPlus, effort medium.** Top
   model, and its GGUF row now reads 15 tok/s at 49K, the most usable
   Qwen3.8 config on this machine. Its EvalPlus cell carries the MLX
   score by the shared-score rule, and run 9 showed that rule fails for
   Gemma-12B's quants. This score decides whether the GGUF row is the
   daily-driver candidate.
4. **Gemma-4-26B-A4B GGUF at f16 KV, full EvalPlus, thinking on.**
   Right after step 3, before any candidate below. Run 9 moved the
   model to f16 and its row changed from 23.5 to 8 tok/s gated by speed
   at 24K to 60.3 to 17.3 tok/s at 197K. The smoke read level with q8_0
   but misses one problem, and the 0.713/0.701 score was measured at
   q8_0. Served at 128K on purpose, it is a candidate for a secondary
   model: the machine stays usable and simple tasks finish faster than
   on a smarter, slower model. Owner rule for the same run: base pass@1
   at or above 0.800 sends it straight to Mendel blind; below that it
   stops at EvalPlus, and the owner decides against the competing
   models.
5. **Full EvalPlus** where the smoke passed, thinking off, and thinking
   on where the model offers it, for the rest of the survivors.
6. **Bonsai MLX, Mendel guided and blind, thinking off.** Run 9's block
   C, deferred by the owner. The published best row and the only level
   besides high the stack reaches.

## Candidates for the steps above

- Gemma-26B GGUF EvalPlus with thinking off, at f16 (the thinking-on
  re-score is step 4 above).
- Qwen3.6 GGUF thinking off, EvalPlus (never scored).
- LM Studio `gemma-4-12b-it-mlx`: wired memory at its 131K ceiling. The
  row reads `pending` for memory and stays off the comparison table
  until measured; one sweep step with the runner's `wired_mb` column.

## Mendel rows waiting on decisions

- Qwen3.8 MLX guided effort low: invalid after three attempts in run 9.
  The budget fix works; the model still grows its context past the
  26624 window in agentic use and Metal OOMs. Needs an owner decision
  on a smaller `contextWindow` or an earlier compaction trigger before
  any retry; the blind low row waits on the same decision.
- Bonsai on the PrismML fork, blind thinking-high retry from scratch,
  `reruns: 1`. Blocked on the KV bias corpus answer.
- Bonsai fork q8_0 KV arm without the bias file, against the fork's q4
  plus bias row. Blocked on the same answer.

## Rows to hide until re-measured

The KV pick rule hides rows measured at the other type. After run 9
that is nobody: the three GGUF single-slot rows are re-measured, the
two-slot Gemma-26B row was never measured, and the MLX rows hold f16
by nature.

## Housekeeping on the Mac, first session

- An orphan Bonsai MLX blind session (started 2026-09-02 22:44, 52
  tool calls) sits in the Mendel scratch runs with no branch, no result
  row, and no archive entry. It is not a row and not invalid; it is an
  abandoned attempt. Copy its log into `benchmark/runs/` and add a
  `SESSIONS.md` line "abandoned attempt; no branch, no result row", the
  way the aborted Qwen3.8 medium session is recorded. Then archive with
  `tools/archive-evidence.sh`.
