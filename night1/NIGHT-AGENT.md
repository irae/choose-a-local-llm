# Night-1 agent instructions — EvalPlus quality gate

You are running an unattended overnight benchmark session. Your job: get as many
HumanEval+ scores as possible from the run list below, in order, fixing problems
as they appear. The user is asleep — never wait for input; make the safe call and
record it. Write all prose in ASD-STE100 Simplified Technical English.

Read `../README.md` first — "The flow" section is the law. Key rules tonight:
one model on the GPU at a time; clean up leftovers after every block; record
results immediately; never delete data.

## Staying alive — ScheduleWakeup loop (mandatory)

Immediately after starting any long-running block (a codegen run), call
`ScheduleWakeup` with `delaySeconds: 1200` (20 minutes), `noop` as appropriate,
and a `reason` naming the block you are watching. On every wakeup:

1. Run `./progress.sh`.
2. If the sample count grew since last wakeup: all good — `ScheduleWakeup` again
   (1200s, noop: true) and stop.
3. If the sample count did NOT grow, or the server/evalplus process is gone:
   the block is dead. Kill remnants (`./90-stop-servers.sh`, `pkill -f evalplus`),
   restart the CURRENT block (server script + run script), note the incident in
   `state.md`, and `ScheduleWakeup` again (noop: false).
4. If the same block dies 3 times: mark it failed in `state.md`, move to the
   next block. Never burn the whole night on one model.

Keep the loop running until the run list is exhausted, then do the shutdown
checklist. Every wakeup MUST end with either a new `ScheduleWakeup` call or the
shutdown checklist — never leave the night without a scheduled next check.

## State file

Maintain `state.md` in this folder: current block, start time of the block,
incidents, and one line per completed block with its pass@1 score. Update it on
every transition and every incident. It is the handoff document if you die.

## Timing: secondary signal, don't chase precision

pass@1 is the score that matters. Timing is a rough, secondary signal — note
it if convenient (wall-clock of the final, successful attempt: server start
to evaluate finish, excluding earlier failed attempts and time spent
diagnosing/fixing them), but do not spend effort making it exact, and do not
let timing investigation block or delay work on scoring correctness.

## `max_tokens`: verify it's big enough, per model

Prompt context size does not affect these scores (problems are tiny). Output
token budget (`max_tokens`) does. Do not assume one number fits every model —
a compressed/quantized or heavily-reasoning model can burn thousands of
tokens on reasoning alone before answering, and a tight cap truncates it to
an empty or partial answer that scores as a hard failure despite the model
being capable. If a completed task's output is suspiciously short or empty,
suspect the token cap before suspecting the model — check with a one-off
higher-`max_tokens` request against the live server before writing off the
result.

## Setup (once)

1. `./00-env-check.sh` — if the wired limit is not 27000, note it in state.md and
   continue (big contexts are not needed tonight; 32K slots fit regardless).
2. `./01-install-evalplus.sh` if evalplus is missing.
3. If `run-humaneval.sh` fails on flags: check `evalplus.codegen --help` and
   adapt the script (EvalPlus CLI flags vary by version). Small fixes are your
   job; record what you changed in state.md.

## Run list (user-decided order — do not reorder)

Each block: start the server script, wait for "up", then
`./run-humaneval.sh <name> <model-id>`. On success, append the score to
state.md and `results.md`, run `./90-stop-servers.sh`, move on.

| # | name | server script | model-id for run-humaneval.sh |
|---|---|---|---|
| 1 | qwen38-mlx-medium | `10-server-qwen38-mlx-medium.sh` | `mlx-community/Qwen3.8-27B-4bit` |
| 2 | qwen36-think | `20-server-qwen36.sh` | `qwen3.6-35b-a3b` |
| 3 | bonsai-think | `30-server-bonsai.sh` | `prism-ml/Ternary-Bonsai-27B-mlx-2bit` |
| 4 | gemma26-think | `40-server-gemma26-think.sh` | `gemma-4-26b-a4b` |
| 5 | gemma12-think | `50-server-gemma12-think.sh` | `gemma-4-12b` |

### Block 1 special check (before the long run)

Qwen3.8 must run at `reasoning_effort=medium`. mlx_lm.server may not support
setting it. Verify: send one chat request to the server and inspect whether the
response length/think block looks like medium (short think) — better, check if
mlx_lm.server accepts a `chat_template_kwargs` body field (send one request with
`{"chat_template_kwargs": {"reasoning_effort": "medium"}}` and one without; if
outputs are identical, the field is ignored). If effort CANNOT be set on mlx:
switch block 1 to the fallback `11-server-qwen38-gguf-medium.sh` (llama-server
enforces medium server-side; model-id `qwen3.8-27b`) and note the substitution
in state.md. Scoring the GGUF quant at medium is more valuable than scoring MLX
at the wrong effort.

## Rules for problems

- Small fixes (a flag rename, a path, a timeout): fix, retry the block, record.
- A model that keeps crashing: 3 strikes, mark failed, move on.
- NEVER: download new models, delete anything, change quantizations, touch
  configs outside this folder (except reading), or run two models at once.
- Disk full / machine-level problems you cannot fix: stop servers, write
  state.md, keep the ScheduleWakeup loop alive with noop checks so the user
  finds a live, honest status in the morning.

## Shutdown checklist (when list exhausted or morning arrives)

1. `./90-stop-servers.sh` and `pkill -f evalplus`; confirm `./progress.sh` shows
   nothing running.
2. Finalize `results.md`: one table — block name, model, config, pass@1 (base
   and plus), samples completed, clean start/finish/duration (see "Timing"
   above), incidents.
3. Final state.md entry: what finished, what failed and why, what you changed.
4. Do NOT update the HTML reports, comparison.html, or pi config — the morning
   session does that with the user (four-surface rule applies then).
