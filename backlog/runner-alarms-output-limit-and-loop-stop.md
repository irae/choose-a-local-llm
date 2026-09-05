# Runner alarms: output-limit hits, one long call, and the loop verdict

Status: draft. The owner picks among the three pieces when reviewing
this item; recommendation is piece 1 first.
Filed: 2026-09-04, from research run 2.
Needs hardware: no for the runner change; one unscored replay to see it
fire.

## What it is about, in plain words

Every pi model entry has `maxTokens`, the most tokens one response may
have. pi sends it as `max_tokens`; the server stops generating at that
count and reports `finish_reason: length`. It is not a context size and
it does not cause compaction. Compaction is pi trimming history between
turns when the conversation nears `contextWindow`; it never stops a
response that is being generated.

Run 2 saw a model spend 70 minutes generating one tool call until it hit
`maxTokens`. pi discarded the truncated call, asked the model to re-issue
it, and the runner logged nothing special. The model recovered on its
own. So today the runner cannot see a whole turn's budget being spent on
discarded output, and it cannot see one call that runs for an hour.

`maxTokens` was never a loop detector and must not become one. A slow,
capable model that legitimately writes a long response would be cut
short by a low cap. The cap belongs to the model's window arithmetic
only (see `backlog/qwen38-mlx-output-budget-and-window.md`).

## What the runner could do, three independent pieces

1. **Count and log.** Every `finish_reason: length` and every pi
   "re-issue the tool call" message goes into telemetry as
   `output_limit_hits` and writes one alarm line in the runner log. No
   behaviour change, no measurement change. Cheap, safe, first.
2. **A per-turn wall-clock cap.** If one assistant response runs longer
   than N minutes (20 is the proposal), the runner ends the run with its
   own end reason, `turn_timeout`. A stop, not a rescue: the row records
   that the model could not produce a usable turn in that time. Needs
   one sentence in the scoring law.
3. **Two consecutive output-limit hits on tool calls end the run**, end
   reason `output_limit`. Two full budgets spent on discarded output is
   a failed run, not a retry. Same law sentence.

The loop verdict after the run stays separate: `benchmarks/loop-check.py`
reads the finished session log, turns every line into a shape (letters
to W, digits to N) and computes distinct shapes divided by lines inside
a sliding window; under 0.10 is a repetition loop. It runs after the
run, on the log, so it never changes what the model did; it only tells
the scorer that the run looped. Wiring it into the run close so the
verdict lands beside the row is part of this item.

## Where

`../mendel-benchmark/benchmark/run-pi-rpc.mjs` (the runner), `PLAN.md`
(the law), `run-worker.sh` (run close). Owner and coordinator can do
piece 1 without an agent.
