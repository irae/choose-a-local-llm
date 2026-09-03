# Proposal — completion must dominate the score (coordinator, 2026-09-03)

Owner motivation: "Completing with bugs is still completed, but not
completing is super bad — a run cannot score 60% when the task is not
even done."

Three alternatives, recomputed over every current row (blind v1.1,
guided v3.0). `done` = `libraries_done` (8 = complete).

## A — completion multiplier: `total × done/8`

Smooth and simple. bonsai-prism 60.5 → 7.6; Qwen3.8 low 67.5 → 8.4;
Bonsai mlx blind 55 → 20.6. Drawback: it also re-punishes runs whose
score already priced the incompletion (Haiku blind 6/8: 34 → 25.5),
and a 0/8 run scores exactly 0, which pre-empts the invalid-run
question.

## B — additive cap: `min(total, 10 + 5 × done)`

Keeps intra-partial ordering, gentler (~4x on the offenders).
Drawback: the 10-point floor for doing nothing is hard to defend, and
the constants are arbitrary.

## C — fraction cap: `min(total, 100 × done/8)`  ← RECOMMENDED

One sentence explains it: "a score cannot exceed the fraction of the
task that got done." No new constants. It does not touch any complete
run, and it does not double-punish near-complete runs whose score is
already below their cap (Sonnet 4.5 blind 6/8 stays 43.5, Haiku stays
34). Offenders land where the owner wants them:

- bonsai-prism blind (1/8): 60.5 → 12.5
- Qwen3.8 blind low (1/8): 67.5 → 12.5
- Bonsai mlx blind (3/8): 55 → 37.5
- Bonsai mlx guided (1/8): 59 → 12.5
- All 0/8 rows → 0 (but see `invalid-runs.md`; the Gemma rows should
  be invalid, not zero-scored)

Full C ranking (v1.1): kimi 93.5, grok 92.5, sol 92, opus 90.5,
ds-flash 84.5, luna 83.5, deepseek 79, glm 75, qwen3.6 63,
sonnet-4.5 43.5, bonsai-mlx 37.5, haiku 34, qwen3.8-low 12.5,
bonsai-prism 12.5, gemma 0. (v3.0): glm 98, ds-flash 97, luna 88.5,
sonnet 88, qwen3.6 83, haiku 76, bonsai-mlx 12.5, gemma rows 0.

## Implementation (after the owner picks)

- PLAN.md/RUBRIC.md: the cap is applied to `score_total` at scoring
  time; rows keep raw criterion scores plus a `score_raw` field so
  nothing is lost; report scoreboards show the capped total with the
  raw total faint beside it ("12.5 (raw 60.5)").
- No re-runs needed. The report matrix keeps raw criterion cells; the
  scoreboard and site tables use the capped total.
- Prose to update: comparison.md Mendel table, report summary lines.
- Cost-weighted views use the capped total.
