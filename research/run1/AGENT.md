# Research run 1 — scoring fairness and backend reliability (Mac)

You are a research agent, not a benchmark runner. Read this file, then
`state.md` (progress log — keep it current), then the linked pages.
Write all prose in ASD-STE100 Simplified Technical English. The ground
rules of `AGENTS.md` apply: worktree-first, no bare stash, no model
downloads, no pushes without owner request, scoring discussion on
Fable.

This run produces PROPOSALS and DIAGNOSES, not new benchmark rows. The
owner reviews every proposal before it changes the rubric or any
published score.

## Goal 1 — completion must dominate the score

Motivation (owner, 2026-09-03): "Completing with bugs is still
completed, but not completing is super bad — a run cannot score 60%
when the task is not even done." Current examples that offend:
bonsai-prism blind high 60.5/100 with 1 of 8 libraries; Bonsai mlx
rows near 55-59 as partials.

Task: propose a rubric/scoring change to
`../mendel-benchmark/benchmark/RUBRIC.md` + PLAN.md that makes
incompletion roughly 10x more painful. Alternatives to weigh (add your
own):

- Multiply the total by `libraries_done / 8` (a completion factor).
- A completion gate: fewer than 8/8 caps the total (for example at
  `10 + 5 × libraries_done`).
- Score only the completed fraction and renormalize nothing — missing
  libraries score 0 on every criterion they touch.
- Keep the rubric, add a separate always-visible "task done: N/8"
  column and sort the scoreboard by (done, score).

For each alternative: recompute every existing v1.1/v3.0 row under it
and show the new ranking. The proposal must keep cross-model
comparability inside a prompt version and must not need re-runs. Flag
which historical narratives (comparison.md prose, report matrix
cells) the change would invalidate.

## Goal 2 — when is a run invalid, not just partial

Motivation: the three Gemma-12B rows (30.5/30/29.5, zero commits, the
LM Studio newline-flood collapse) measure a serving failure, not the
model. Propose criteria for marking a run INVALID (for example: zero
commits, or a reproducible harness/serving collapse documented in the
session log) and what invalid means on every surface: row kept with an
`invalid` flag and excluded from scoreboards? Moved to historical?
Kept with a warning like today? Recommend one, with the site/report
changes it needs. Apply nothing.

## Goal 3 — backend failure deep-dive (diagnosis only)

You are ON the Mac, with the logs. Diagnose, do not fix:

1. The dagger-sweep OOM chain (see HANDOFF/bench7 state.md, hypotheses
   H1-H4): verify H4 — poll `vmmap --summary` vs `vm_stat` after
   stopping a big server; measure how long real recovery takes.
2. The Gemma-12B newline flood: read the three session logs, find the
   exact first divergence (failed edit → what token pattern), and
   check which stop/sampler settings the harness sent.
3. The mlx dead-thread Metal OOM and the Qwen3.8 26624 window: confirm
   current mlx-lm version, and whether an upgrade path exists (no
   installs without the owner).
4. The llama.cpp MTP drafter breakage (HTTP 500 after failed alloc):
   capture exact build/version and a minimal repro command line for an
   upstream issue.

Findings go into `state.md` and feed research run 2 (runtime
improvements), which plans the actual fixes.

## Deliverables

- `state.md`: running log + a final summary section.
- `results/`: one file per goal with the proposal/diagnosis.
- No rubric edits, no data edits, no site edits, no pushes.
