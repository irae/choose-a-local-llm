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


## CORRECTION 2026-09-04 — the loop reproduces on a quiet machine

The evidence above pointed at a ceiling we set. A full-length replay
says otherwise, and this correction supersedes it.

Replayed the exact 3909-character prompt from the failing
`google-gemma-4-12b-low-guided` run, same model, same LM Studio backend,
same 158464 context, on the failing run's own base commit, on a machine
freshly rebooted and quiet with zero swap.

| | original | replay |
| --- | --- | --- |
| tool calls | 130 | 71 |
| distinct calls | 30 | 30 |
| longest identical run | 72 | 37 |
| most repeated call | 88 | 40 |

**It looped.** Thirty distinct calls in both runs, and a 37-call
identical repeat where the original had 72. The quiet machine did not
prevent it.

The repeated call is `bash {"command": 4}` — the `command` argument is
the integer 4 where a string belongs. A malformed tool call, emitted and
then repeated. The original looped on `ls -F_r`, an invalid flag. Same
family as the `<|channel>` flood: the model produces a broken call and
cannot recover from it.

### What this changes

- **The earlier evidence in this file is superseded.** It rested on
  short synthetic probes that never produced a loop, from an instrument
  whose sensitivity was unknown. The instrument is now calibrated: with
  the real prompt it reproduces the failure.
- **The machine-state hypothesis is not supported.** Quiet, rebooted, no
  swap, no thermal warnings recorded — and it looped anyway.
- **The nine-run serving sweep still says only what it said**: a short
  synthetic prompt does not loop on any backend. It does not say the
  models are fine, because that prompt cannot produce the failure.

### What it does not settle

Whether the loop is the model, the LM Studio MLX path, or the template.
The replay changed one variable and held the backend fixed, so it
separates machine state from everything else and nothing more. Running
the same replay against a different vetted gemma-12b backend would
separate model from backend — that is a combination question and belongs
with run 2 section D.

**For the acceptance decision:** on this evidence the three Gemma-12B
rows record a real failure, not a ceiling we set.
