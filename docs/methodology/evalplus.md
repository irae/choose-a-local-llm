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

## Fast mode: one thinking budget for every model

The rule (owner, 2026-09-19). Every scored run serves with a thinking
budget of 8192 tokens and an output budget of 16384 tokens:

```
llama-server ... --reasoning-budget 8192 \
  --reasoning-budget-message "Thinking budget reached. Give the final answer now."
EVALPLUS_MAX_NEW_TOKENS=16384
```

The server closes the thinking at 8192 tokens, injects the message,
and the model answers with what it has. `max_tokens` counts the
thinking, the message and the answer together, so the answer keeps
8192 tokens of room; no converged answer has needed more than 1300.
Nothing is calibrated: the same two numbers apply to every model,
level and machine, and the score is what a model gets done inside the
same thinking. A row with no thinking (thinking off) serves without
the flag at the same `max_tokens`.

The run records two counts beside the score. `empty` comes from the
samples file (a problem with no code). `forced` comes from the finish
log: the problems whose reasoning tail carries the message. A forced
answer is an answer; it counts as passed or failed by its tests like
any other. The cause word of an empty is `forced` when the budget
fired and the answer was still no code, `model` when the model
stopped by itself with no code, `budget` when the output budget ran
out (`finish_reason: length`, which fast mode makes rare), and
`† unproven` when the run recorded no finish reason.
`benchmarks/thinking-budget.py count` prints both counts.

Why these numbers: twelve budgeted runs on nine configs showed that no
forced answer ever passed with more thinking (the failures loop or
are wrong at any budget), that a forced answer passes 85 percent of
the time, and that 8192 costs at most a few problems per run against
the 30000 cap while it halves the wall on the slow rows. The record is
`hardware/arrietty/research/thinking-budget.md`. The reasoning, the
before-and-after scores and the limits are on
[the thinking budget page](./reasoning-budget.md).

A run that wants to sit closer to the model's natural convergence is
not a scored row. Serve it with `--reasoning-budget 24576` and
`max_tokens` 32768, or with no flag and `max_tokens` up to the
server's `-c`; the site shows it as a note, never in a table.

MLX rows: `mlx_lm` accepts a thinking budget and does not enforce it.
An MLX row cannot run fast mode, and the site says so on the row.

## Reuse of an earlier run: the splice

Temperature 0 on a fixed serving config is deterministic, and the
thinking of a run at a larger budget begins with the same 8192 tokens
fast mode allows. So a run of the same config at a thinking budget of
8192 or more already holds the fast-mode answer of every problem whose
reasoning stayed inside 8192 and was not forced. `benchmarks/thinking-budget.py
splice <run-dir> <fast-dir> --message MSG` copies those samples and
finish lines into the fast run's directory and lists the rest; the
fast run then generates only the listed problems under the fast flags.
The spliced row records its source run in its note. A run with no
finish log cannot be spliced and runs in full.

## The optional proof run

A forced answer that fails a test has one of three causes, and one
natural re-run of those problems separates them, without the flag at
`max_tokens` 30000: `benchmarks/thinking-budget.py prepare` before and
`report` after.

- `forced-pass`: the budget fired and the answer passed.
- `forced-fail-late`: the answer passed without the flag at N reasoning
  tokens. The budget was too small for that problem.
- `forced-fail-loop`: the answer hit 30000 without the flag.
  Non-convergence. No budget helps.
- `forced-fail-wrong`: the answer failed both ways. The model's own
  limit.

The proof run is optional and never changes the fast score. It is
worth its hours when a model forces many answers or when the late
cell is suspected; across the twelve runs of the test the late cell
stayed at zero.

## Which serving config to score

**The fastest at shallow depth, always.** The problems are short and
nothing here reaches depth, so a larger window buys nothing and speed
is the whole cost of the gate. Where a model has a drafter, that is
normally the drafter on, at the `n-max` its shallow sweep picked
([context creep](./context-creep.md), "The order for a model with a
drafter"). An agent run picks differently, on depth; the two tests do
not have to serve the same config, and each row says which it used.

## Steps

1. Start the config's server on port 8081 with the fast-mode flags,
   warm up, start the run watcher (`benchmarks/run-watch.sh`,
   [checklist](./checklist.md) step 6: the memory record and the crash
   signal, exit 42 on a dead server). Verify with one real request
   that the reasoning field is present and that the level in
   `resolved_reasoning_effort` is the one the row names. **Pass the
   thinking mode or reasoning level explicitly on every call**, in the
   extra-body argument: a call with no extra body gets the chat
   template's own default, which can be a different level from the one
   the row is named for.
2. Splice an earlier run of the same config when one exists (above).
3. Run the scoring script (`RESULTS_BASE` chooses the run dir; the
   extra body carries `chat_template_kwargs` for thinking toggles):
   ```bash
   RESULTS_BASE=hardware/<hardware-id>/benchmarks/benchN/results \
     EVALPLUS_MAX_NEW_TOKENS=16384 \
     benchmarks/run-humaneval.sh RUN_NAME MODEL_ID_AS_SERVED [extra-body-json]
   ```
4. The script resumes from an existing jsonl automatically (skips
   existing task_ids). Strip genuinely-empty lines first if they must
   regenerate.
5. Monitor per the checklist (output growth, not process liveness).
6. Evaluate runs automatically at the end. Record pass@1 base/plus,
   the empty count and the forced count, on every surface, from the
   files: `benchmarks/thinking-budget.py count`. A log line is not a
   count; runners have reported `0/164` from one while the samples held
   53 empties.
7. Keep `finish.jsonl` beside the samples: `run-humaneval.sh` writes one
   line per answered request, with the UTC time, the task id, the finish
   reason, the completion and reasoning token counts, the reasoning and
   answer lengths, the last 200 characters of the reasoning (where the
   budget message lands), the request wall and a hash of the prompt. It
   is the proof of every forced and every empty answer, and it is what a
   later splice reads.

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

The budget is fast mode's on both sides (`max_tokens` 16384, the
server with `--reasoning-budget 8192`), and the candidate is never
calibrated. A candidate that needs a bigger budget to pass is a
candidate that costs more.

```bash
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
