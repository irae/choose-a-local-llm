# A thinking budget for EvalPlus: the discussion and the test

Status: decided 2026-09-19. The rule is fast mode, `docs/methodology/evalplus.md`:
`--reasoning-budget 8192`, `max_tokens` 16384, no calibration, the
proof run optional. The data that decided it (twelve budgeted runs on
nine configs, the fixed-budget simulation from their finish logs) is
summarised at the end of this file. Filed 2026-09-16. Origin: the owner's question of
2026-09-16 about the empty EvalPlus answers and the cause word
`budget`. Needs hardware: yes, bench runs 21 (Linux) and 22 (Mac) take
it. The method text is `docs/methodology/evalplus.md`, "Unproven yet".

## What the owner wanted to know

Every re-run of run 20 proved its empties as `budget`, and no row
showed a `model` cause. The owner expected at least one model that
produces empties at any budget, and asked whether every model should
get a 30000 budget. The real goal was different: detect
non-convergence in thinking during EvalPlus, at the least budget and
in the least time, with the same fairness for every model, so the site
gives a user a useful number.

## What the data says

- `budget` records the finish reason only. A thinking loop also ends on
  `length`, so `budget` at a large budget proves nothing about a larger
  budget. Rows at the 30000 cap still carry empties, on both machines.
- `model` needs the model to stop by itself with zero code. A model that
  stops by itself nearly always writes some code, so `model` is rare by
  construction. The case the owner expected shows as `length` at every
  budget, not as `model`.
- The Mendel loop evidence and the EvalPlus empties agree on two
  models: the MoE 26B GGUF at thinking on and the ternary 27B MLX build
  loop in both benchmarks. The dense 27B builds do not loop in Mendel
  and still leave a few empties, with counts that differ by serving
  config on the two machines. The dense 12B at thinking on left 53 of
  164 empty at budget 8192 on the Linux card, as its calibration
  predicted with five of ten answers at the 30000 cap.
- Adding HumanEval/39 to the calibration sample did not reduce the
  empties; it moved one into the calibration and raised every run's
  budget. Longer runs, no upside. Proposed: drop it from the sample
  once the thinking budget is the instrument.

## What the literature says (2026-09-16)

- Non-convergence is bimodal, not a tail. A study of chain-of-thought
  models found generations that close their thinking and generations
  that never do at any budget; on a hard set 43 percent never closed,
  and a larger budget did not rescue them. Accuracy plateaus early.
  Token Budget Saturation and Early Detection of Non-Convergence,
  arXiv 2607.21433.
- Cheap output signals (n-gram repeats, entropy, length) detect a loop
  late: AUC near 0.6 in the first 300 tokens. But after a few thousand
  tokens an exact periodic repeat is unambiguous.
- Production servers cut the loop, not the budget. vLLM has a merged
  thinking token budget that forces the end-of-thinking tokens; a
  loop-breaker on three identical cycles is an open issue with an open
  pull request and no maintainer reply, so it is not adopted here.
  llama-server ships `--reasoning-budget N` and
  `--reasoning-budget-message MSG`, also per request. `mlx_lm` accepts
  `thinking_budget` and enforcement bugs are open in that ecosystem;
  LM Studio's MLX engine has an open issue where a MoE 26B thinks to
  `max_tokens` with empty content, which is our 46 empties.
- Loops are worse at temperature 0 and in 4-bit quants. We run both,
  because the user does.

## The decision under test

1. Serve llama-server rows with a thinking budget derived from the
   calibration: thinking budget and answer budget, each the longest
   converged value times 1.5 with a floor of 2048; `max_tokens` is the
   sum. `benchmarks/thinking-budget.py derive`.
2. Count the forced answers from the finish log's reasoning tail. That
   count is the non-convergence count at the budget.
3. Re-run the forced failures without the flag at a generous budget, so
   each falls in one of four cells: forced-pass, forced-fail-late,
   forced-fail-loop, forced-fail-wrong. The late cell corrects the
   budget in one pass; temperature 0 makes N exact. No bisect.
4. Compare score and wall with the natural run of the same config.
5. MLX rows keep the output budget rule and the `budget` word until the
   stack enforces a thinking budget. The site says the knob is missing.

The owner's concerns, recorded: the calibration may set the budget too
low, because its ten problems miss the hardest of the 164; the best
scores so far came from natural runs, so the budget may cost score;
the balance is "98 percent of the score in half the time is probably a
good trade-off", but the rule is the owner's to set after the data.
Per machine or per model: the curve is per build and serving stack,
the wall is per machine, the rule is project-wide.

## What decides it

Run 21 on the Linux card first, because the Mac is wanted for other
work: the dense 12B at thinking on (the loop case) and the dense 27B
3-bit at effort xhigh (the best-score case) under the budget, each with
the natural re-run of its forced failures. Run 22 on the Mac: the MoE
26B GGUF at thinking on, the dense 27B 4-bit at effort xhigh, and the
ternary 27B fork if its server takes the flag, with one guided agent
row under the budget for the fork. Run 22's gates read run 21's margin
when a coordinator message brings one, and never wait for it; parallel
waste is accepted (owner, 2026-09-16). Runners never talk to each
other; every result passes through the coordinator, who relays only
what a gate needs.

A research run with a best-tier agent is not planned: the decision is
empirical and the bench runs produce the data; the judgement at
close-out is the coordinator's.

## What decided it (2026-09-19)

Twelve budgeted runs on nine configs, both machines (runs 21 to 27),
every count re-derived from the finish logs and samples:

- No forced answer was late in any run. 131 forced answers; 39 failed
  a test and were re-run without the flag: 30 loop to the 30000 cap, 9
  converge and fail again, 0 pass with more thinking.
- Every budgeted run scored at or above its natural pair, with 0
  empties. 111 of 131 forced answers pass base.
- The calibrated budget was set by the loop-prone problems: in 10 of 12
  calibrations the longest converged problem was HumanEval/32, 145 or
  76 at 17000 to 27859 tokens, so the formula gave the 30000 cap in 7
  of 12 cases. The calibration measured the tail's luck, not the model.
- A fixed-budget simulation from the finish logs: at 8192, 762 of 2885
  minutes saved across the twelve runs (26 percent), with 0 to 6
  natural passes per run at risk of being forced; the one real 8192 run
  (the ISTA config, run 21) lost none of its 4 and scored the same as
  the 30000 cap, in 175 minutes against 273. At 16384, 352 minutes
  saved and at most 1 at risk per run.
- The loops are the same problems on every model: HumanEval/99, 32,
  145, then 137, 39, 64. HumanEval/39 set no budget anywhere.
- No Mendel row ran under a budget; the agent side is untested.

The owner chose 8192 for the small hardware, with 24576 and 32768 (or
no flag) as the closer-to-natural option that never becomes a row.
