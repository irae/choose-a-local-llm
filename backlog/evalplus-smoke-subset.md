# EvalPlus smoke: a fixed fast subset for research trials

Status: draft, needs owner review; then a sub-agent picks it up.
Filed: 2026-09-04. Origin: research run 3 needs a quick quality check
that is not the full 164-problem EvalPlus gate; run 2 already used a
short smoke and `tools/sweeps/lmstudio_evalplus_smoke.py` exists from
an earlier LM Studio concurrency test.
Needs hardware: no to define it; a validation pass on the reference
setup to prove it discriminates.

## What it is about

Research runs try candidate containers (a better quant of a model we
run, a smaller model claimed to match a larger one). They must not run
the full EvalPlus gate: that is bench work and takes an hour or more
per config. They need a smoke: a handful of fixed problems, the same
budget on both sides, run against the candidate and against the config
we run today, and read as "level, better, worse".

## What to define

- **The subset.** Three to five HumanEval+ problems, fixed by task id
  and written into the tool: most of them fast (short answers that
  every current config passes, so a failure means something), and one
  that often goes empty or scores low on our configs (reasoning that
  runs long), so the smoke also sees the completion failure mode. Pick
  them from the raw result files under `benchmarks/bench*/results/`:
  the problems with the highest pass rate and the shortest completions
  across configs, plus the one with the most empties.
- **The budget rule.** Same `max_tokens` on both sides of a comparison,
  taken from the current config's calibration file
  (`benchmarks/calibration-*.json`), never re-calibrated for the
  candidate.
- **The tool.** One script, standard library where possible (the
  EvalPlus venv is allowed, as `run-humaneval.sh` uses it), one
  command, one output: per problem pass or fail, completion tokens,
  wall time, and whether the answer was empty. It follows
  `CONVENTIONS.md` (header not comments, env-var configuration,
  events one per line). Retire or fold `lmstudio_evalplus_smoke.py`.
- **The reading rule.** Level, better, worse: written in the tool's
  header so two agents read the same output the same way.
- **The method page.** A short section in `docs/methodology/evalplus.md`:
  what the smoke is for, what it cannot say (it is not a score, it
  never reaches the site), and the command.

## Validation before it is trusted

Run it once on the reference setup against two configs whose full
EvalPlus scores are known and differ (for example the two Bonsai rows,
0.927 and 0.915), and once against the same config twice. The smoke
must not call the same config "worse" than itself, and should separate
the two known scores or say honestly that it cannot at this size.
