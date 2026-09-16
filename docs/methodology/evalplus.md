# EvalPlus (HumanEval+) — the quality gate

Tier 1 of the quality flow: cheap, execution-verified, sensitive to
quantization damage. A gate, not a ranking. Survivors go to
[Mendel](./mendel.md). Common rules and
the run loop apply ([common rules](./common-rules.md),
[checklist](./checklist.md)).

## Gate mechanics

- Temperature 0, pass@1, small prompt context (problems are tiny —
  prompt context does not affect scores).
- Serve through the config you will actually run.
- Which thinking modes and reasoning levels to score is a planning
  decision per model, from the vendor's documentation and the owner.
- Speculative decoding never changes outputs at temperature 0, so score
  without a drafter and serve with one freely.
- Timing of runs is a secondary signal; never chase precision. pass@1
  is what matters.

## Calibrate the output budget FIRST — it affects scores

`max_tokens` is a separate axis and it DOES affect scores. An
undersized budget lets reasoning exhaust the cap and empty completions
score as failures (up to 38% of scores lost before this was found).

1. Run `benchmarks/calibrate.py` (10 fixed problems, cap 30000). The
   sample includes HumanEval/39, the problem that ends empty most often
   across our runs (owner, 2026-09-15). The calibration saves every
   answer. Pass the file to the full run as `EVALPLUS_CALIBRATION`: an
   answer that ended on its own within the run's budget goes into the
   samples, and the run does not generate that problem again. Its
   calibration `wall_s` counts in the run's wall.
2. Budget = observed max completion × 1.5, floor 8192.
3. For models whose thinking sometimes never converges
   (`finish_reason: length` at any budget), the budget is a
   waste-limiter instead: set it just above the longest SUCCESSFUL
   completion. Expect and record a real empty rate; do not chase zero
   empties with ever-larger budgets.
4. Never reuse a thinking-on budget for a thinking-off pass, or across
   models.

What the cap does to a score, run by run:
[limits on local hardware](../benchmarks/evalplus.md#limits-on-local-hardware).

## Which serving config to score

**The fastest at shallow depth, always.** The problems are short and
nothing here reaches depth, so a larger window buys nothing and speed
is the whole cost of the gate. Where a model has a drafter, that is
normally the drafter on, at the `n-max` its shallow sweep picked
([context creep](./context-creep.md), "The order for a model with a
drafter"). An agent run picks differently, on depth; the two tests do
not have to serve the same config, and each row says which it used.

A non-converging calibration is this gate's early warning. It costs ten
problems to see, and a full run costs hours, so read it before starting
one: two `length` stops in a calibration have preceded a run that spent
its budget and returned empties.

## Steps

1. Calibrate (above). Calibration files live under the setup, at
   `hardware/<hardware-id>/calibrations/`, because a calibration is a
   measurement of one machine. `calibrate.py` takes the directory from
   `CALIBRATION_DIR`. **Pass the thinking mode or reasoning level
   explicitly on every call**, in the extra-body argument, for the
   calibration and for the full run alike. It is not optional: a call
   with no extra body gets the chat template's own default, which can be
   a different level from the one the file is named for. Every row
   records `requested_extra_body` and `resolved_reasoning_effort`; check
   that the resolved value matches the file name before you read the
   budget.
2. Start the config's server on port 8081, warm up, start the run
   watcher (`benchmarks/run-watch.sh`, [checklist](./checklist.md)
   step 6: the memory record and the crash signal, exit 42 on a dead
   server).
3. Run the scoring script (`RESULTS_BASE` chooses the run dir; the
   extra body carries `chat_template_kwargs` for thinking toggles):
   ```bash
   RESULTS_BASE=hardware/kamaji/benchmarks/benchN/results \
     EVALPLUS_MAX_NEW_TOKENS=BUDGET \
     benchmarks/run-humaneval.sh RUN_NAME MODEL_ID_AS_SERVED [extra-body-json]
   ```
4. The script resumes from an existing jsonl automatically (skips
   existing task_ids). Strip genuinely-empty lines first if they must
   regenerate.
5. Monitor per the checklist (output growth, not process liveness).
6. Evaluate runs automatically at the end. Record pass@1 base/plus AND
   the empty count, honestly, on every surface.
7. Keep `finish.jsonl` beside the samples: `run-humaneval.sh` writes one
   line per answered request, with the UTC time, the task id, the finish
   reason (`length` means the budget cut it), the completion and
   reasoning token counts, the reasoning and answer lengths, the last 200
   characters of the reasoning, the request wall and a hash of the
   prompt. It is the proof of why each empty is empty, and the token
   count per problem gives the score at any smaller budget without a
   re-run. Write the
   cause beside the score, in one of three words: `budget` when the
   answer was still coming as the output budget ran out
   (`finish_reason: length`), `model` when the model ended with no
   answer and budget was left (`finish_reason: stop`), and `† unproven`
   when the run recorded no finish reason. A model whose thinking never
   converges also ends at the budget, so `budget` at a large budget does
   not prove that more budget is enough.

## Unproven yet: a thinking budget instead of a larger output budget

Status: a run decision under test (owner, 2026-09-16), not a rule.
The discussion and its evidence are in
`hardware/arrietty/research/thinking-budget.md`. This section says
what the test is, so a runbook can point here.

The problem it addresses. The cause word `budget` records only the
finish reason. A model whose thinking never converges ends on `length`
at every budget, so every empty on every row reads `budget`, and the
word cannot separate a slow answer from a loop. Rows at the 30000 cap
still carry empties. A larger output budget costs hours and does not
remove them.

The test. A serving stack that takes a thinking budget closes the
thinking at N tokens, injects a fixed message, and the model answers
with what it has (`llama-server --reasoning-budget N
--reasoning-budget-message MSG`; the same request field exists in
other servers, and some accept it without enforcing it). The scored
run then has no empty from thinking: every problem gets an answer, and
the finish log's reasoning tail carries the message on every problem
where the budget fired. That count is the non-convergence count at
budget N, measured by the same rule on every row.

The two budgets come from the calibration, with
`benchmarks/thinking-budget.py derive`: the thinking budget from the
longest converged reasoning, the answer budget from the longest
converged answer, each times the margin (1.5) with a floor (2048), and
`max_tokens` is their sum. The calibration runs without the flag, so
it measures the model's natural convergence.

The proof. A forced answer can pass. A forced answer that fails has
three possible causes, and one natural re-run of those problems
separates them, at a generous budget and without the flag,
`benchmarks/thinking-budget.py prepare` before and `report` after:

- `forced-pass`: the budget fired and the answer passed. The budget was
  enough for that problem.
- `forced-fail-late`: the answer passed without the flag at N reasoning
  tokens. The budget was too small; the corrected budget is the largest
  such N times the margin. One pass gives N exactly, because temperature
  0 is deterministic on a fixed serving config. No bisect.
- `forced-fail-loop`: the answer hit the generous budget without the
  flag. Non-convergence. No budget helps.
- `forced-fail-wrong`: the answer failed both ways. The model's own
  limit.

What the test has to show before it becomes the method: the score
under the budget against the natural score of the same config, the
wall against the natural wall, and how many forced problems fall in
each cell. The trade-off rule, for example "the smallest budget that
keeps a fixed share of the natural score", is a project decision and
waits for the owner. The curve of score against budget is a property
of the build and its serving stack, not of the machine: the same build
has scored different empty counts on two machines with different KV
types. The wall is per machine. A stack that does not enforce the
budget keeps the output budget rule above and its `budget` word.

What this does not cover. An agent turn is short and there are hundreds
of them, so a thinking budget bites differently there; the agent proxy
(`mendel.md`) proves that side. A loop across turns, the same tool call
again and again, is not thinking and no thinking budget sees it; that
is the harness's job (`hardware/kamaji/research/unscheduled/pi-tool-loop-guard.md`).

## Crashes and wall time

A server crash does not restart the score. It costs time, and the wall
must not count that time.

1. The run watcher exits 42 the moment the server dies or leaves the
   GPU ([checklist](./checklist.md), step 6). Restart the server with
   the same config and resume at once: `run-humaneval.sh` skips every
   problem already in the samples file, so the run continues from the
   problem that crashed.
2. Write every part in `state.md` as it happens, in UTC: the start of
   each launch, and its end (crash, kill or finish). One line per part.
3. At run close, the wall is the sum of the parts. The gaps between a
   crash and the next launch do not count. The evaluate step counts
   when it runs in the last part.
4. Write the wall once, in minutes, beside the score in `results.md`,
   with the list of parts. The coordinator copies it to `evalplusWall`
   and to the run's `wall`; nobody recomputes it later.

## The smoke

A fast fixed subset, for two uses: the [KV cache pick](./kv-cache-pick.md)
confirms its candidate with it, and a research run tries a candidate
container with it. Neither runs this gate: that is bench work and
costs an hour or more per config. They run
`benchmarks/evalplus-smoke.py` instead — four fixed HumanEval+ problems,
the same output budget on both sides, once against the config we run
today and once against the candidate.

What it can say, and only this: the candidate is level, better or
worse on four problems. What it cannot say: a score. The smoke never
produces a pass@1 and never reaches the site. Four problems have no
resolution to separate two good configs a few tenths of a point apart;
they separate a broken config from a working one. A candidate that
survives the smoke still has to pass this gate before any number is
published.

The subset is fixed in the tool and is not a parameter. Three problems
are short and every scored config passes them, so a failure means
something changed. The fourth is the problem with the most empty
completions on our configs, so the smoke also sees the completion
failure mode, not only the wrong-answer one.

The budget is the current config's, on both sides, and the candidate is
never calibrated. A candidate that needs a bigger budget to pass is a
candidate that costs more.

```bash
SMOKE_CALIBRATION=hardware/<hardware-id>/calibrations/calibration-CURRENT_CONFIG.json \
  benchmarks/evalplus-smoke.py LABEL MODEL_ID_AS_SERVED [extra-body-json]
```

Run it once per side, one at a time, and compare the two `SMOKE` lines.
Level is the same `passed` and the same `empty`; better is a higher
`passed` with `empty` no higher; worse is a lower `passed`, or an equal
`passed` with a higher `empty`. Any other mix is not a verdict. A
difference of one problem is one problem out of four: never write it as
a percentage, and never write it beside a pass@1 number.

## Harness patches (do not rediscover these)

EvalPlus 0.3.1 needs local patches, all live in
`benchmarks/run_codegen_wrapper.py` + one venv file: token budget,
`extra_body` passthrough, None-content handling, no `signal.alarm` +
7200 s client timeout (EvalPlus's own 100 s alarm made long completions
retry forever), macOS rlimit in the venv. History in
`hardware/kamaji/benchmarks/bench1/state.md` and `hardware/kamaji/benchmarks/bench2/state.md`.
