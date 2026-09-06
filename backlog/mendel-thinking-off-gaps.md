# Mendel: score thinking-off configs that only have thinking-high rows

Status: not reviewed. Filed 2026-09-06, from run 10 — the owner spotted
this mid-run while EvalPlus was scoring the "survivor" configs.

## What it is about

Some local models have an EvalPlus pass at thinking `off` (this run
added `gemma26-gguf-off` and `qwen36-gguf-off` as block F survivors)
but their Mendel rows — blind, guided, or both — only exist at
thinking `high` (or `xhigh`). EvalPlus is cheap and thinking-off is a
real, cheaper-to-run configuration; if it clears the quality gate, it
is worth the same Mendel coverage the thinking-on row got, since a
model that does the agentic task well without paying for thinking is
strictly more useful to publish.

Confirmed gaps as of run 10:

- `gemma-4-26b-a4b`: blind rows at `high` only (two attempts,
  `gemma-4-26b-a4b-issue-13` and the run-10 rescore
  `gemma-4-26b-a4b-high-issue-13`, 47.5/100). No guided row at any
  level. **Run 10 added the `off` smoke, guided, and blind for this
  model** (see its `AGENT.md`, "Added mid-run by the owner").
- `qwen3.6-35b-a3b`: blind rows at `high` and `xhigh` only. Guided row
  at `high` only. No `off` row of either kind, despite
  `qwen36-gguf-off` passing EvalPlus at 0.951/0.915 in run 10. Not
  acted on this run.

## What to do

Check every local model with more than one EvalPlus thinking mode
scored (`docs/setups/m1-max-32gb/models.json`'s `evalplusRuns` list, or
grep `benchmark/results.json` / `results-guided.json` for a model
appearing with only one `thinking` value) and queue the missing
mode's smoke + guided (+ blind if the guided score justifies it) in
whichever run picks this up.

## Where

A future run's `AGENT.md` block, following the pattern run 10 used for
`gemma-4-26b-a4b` off (smoke, then guided, then blind, same server as
its existing thinking-on block).
