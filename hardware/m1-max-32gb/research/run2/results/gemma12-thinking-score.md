# The 0.622 thinking-on score is a completion failure, not a quality drop

Run 2, 2026-09-04. No GPU used — this reads the stored EvalPlus output
of an existing run. The owner proposed the reading; this measures it.

## The claim under test

`docs/setups/m1-max-32gb` publishes two Gemma-12B EvalPlus rows on the
LM Studio MLX path:

| Config | base | plus |
| --- | --- | --- |
| MLX, thinking on | 0.622 | 0.610 |
| MLX, thinking off | 0.909 | 0.872 |

Read naively, thinking costs the model 0.287 base — as if reasoning made
it worse at code. The owner's reading was that it never finished, and an
unfinished task scores zero.

## Measured, from `benchmarks/bench3/results/`

| | thinking off | thinking on |
| --- | --- | --- |
| problems | 164 | 164 |
| **empty solutions** | **0** | **61 (37%)** |
| passed | 149 | 102 |
| base score | 149/164 = **0.909** | 102/164 = **0.622** |
| **pass rate on answers it gave** | 149/164 = **90.9%** | **102/103 = 99.0%** |

The owner's reading is right, and it goes further than stated.

**With thinking on, Gemma-12B answered 103 of 164 problems and got 102
of them correct — 99.0%.** With thinking off it answered all 164 and got
90.9% right.

So thinking does not make this model worse at code. It makes it
**markedly better** at code — and unable to finish 37% of the time.
0.622 is a completion-rate failure wearing a quality number's clothes.

## What this changes

1. **The 0.622 row should not be read as a quality measurement.** Whatever
   it measures, it is not "how good is Gemma-12B at HumanEval with
   thinking on". A caveat, or a second column for completion rate, would
   stop the next reader drawing the wrong conclusion.
2. **It sharpens the ruling rather than softening it.** Gemma-12B on MLX
   with thinking on is still ruled out — but for the right reason. The
   model is not weak there; it cannot deliver. That is a serving problem,
   which is exactly what this run is about.
3. **It raises the value of the GGUF thinking-on path.** If the
   non-delivery is the MLX path and not the weights, a backend that lets
   it finish would expose a model answering at 99% on what it attempts.
   Nothing here proves that, and it is worth stating as a question rather
   than a hope.

## What is NOT established

**Why the 61 were empty.** The stored file keeps only `task_id` and
`solution`, and the empty ones are genuinely empty — 43 bytes of JSON
wrapper, no preserved raw response. So the repetition-loop explanation is
consistent with the count but is not proved by it. Truncation on the
output budget would look identical in this file.

Two things would settle it, neither run here: keep raw responses in
future EvalPlus runs, and check `codegen.log` for stop reasons.

**Note on run provenance.** These numbers come from the completed
`gemma12-lmstudio-thinking-on` run of bench 3. A later thinking-on
attempt exists in `gemma12-lmstudio-on` with only 7 of 164 rows; it is
unfinished and was not used.
