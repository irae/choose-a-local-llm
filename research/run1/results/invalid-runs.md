# Proposal — invalid runs (coordinator, 2026-09-03)

Motivation: the three Gemma-12B rows (30.5 / 30 / 29.5, zero commits)
measure the LM Studio + pi serving collapse, not the model. A score
implies the model was tested; these runs never really started.

## Criteria (a run is INVALID when either holds)

1. **Zero commits** — the run produced no scoreable work at all.
2. **A documented serving/harness collapse** in the session log
   (crash signature, template error, degeneration loop) that a Fable
   scorer judges to have ended the model's real participation.

A partial run with commits stays a scored partial. A wrong config
(for example the unhonored thinking flag) is a relabel, not an
invalidation.

## What invalid means on each surface ← RECOMMENDED

- The row STAYS in results.json/CSV with `invalid: true` and an
  `invalid_reason` — the data is evidence, never deleted.
- Reports: excluded from the scoreboard ranking, the matrix, and the
  cost tables; listed in a small "Invalid runs" section at the bottom
  of the version group with model, reason, and a session-log pointer.
- Site tables (gen-tables): excluded, with a one-line footnote
  ("N runs invalid — serving failures; see the report").
- Cost-weighted views: excluded.
- An invalid run does not occupy the model's one-row-per-version
  slot: a later valid run replaces nothing and needs no penalty
  (the failure was not the model's).

## Apply to today

The three Gemma-12B rows (blind high, guided high, guided low) meet
both criteria → invalid, reason "LM Studio MLX serving collapse
(newline flood); zero commits". The Qwen3.8 guided v3.0 row (0/8,
zero commits, three Metal OOM crashes) is a judgment call: the same
criteria mark it invalid too — recommended, same reasoning.

## Implementation (after the owner confirms)

generate-report.mjs: filter `invalid` rows from scoreboard/matrix/
cost tables, render the "Invalid runs" list; the null-cell gate
skips invalid rows' missing telemetry. gen-tables.mjs: same filter +
footnote. PLAN.md: add the criteria; RUBRIC.md untouched.


## Evidence from run 1 (2026-09-03)

The three Gemma-12B rows look like a ceiling WE set, not the model.

- LM Studio ignores the requested context. `lms load --context-length
  8192` was overridden; `lms ps` reported 158464, the same context as
  the failing runs.
- On a quiet machine, gemma-4-12b did not loop on any serving line:
  llama-server with MTP, llama-server without MTP, and LM Studio at that
  same 158464. Longest identical run was 2, against 72 in the failing
  row.
- The failing configuration was chosen by us, and its context was
  chosen by LM Studio's auto-fit rather than by anyone.

**Not proven.** The loop has never been reproduced. The probe above used
a 150-character synthetic prompt; the real one is 3909 characters of
structured workflow. An instrument that has never produced the failure
cannot rule it out, so these results are uncalibrated.

Calibration is cheap if wanted: the recorded prompt replays, and the
repetition appears by tool call 9 of the original session.

For the planner: this is the acceptance question, not a scoring one.
