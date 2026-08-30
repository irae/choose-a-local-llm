# EvalPlus (HumanEval+) — the quality gate

Tier 1 of the quality flow: cheap, execution-verified, sensitive to
quantization damage. A gate, not a ranking. Survivors go to
[Mendel](./mendel.md), then [polyglot](./polyglot.md). Common rules and
the run loop apply ([common rules](./common-rules.md),
[checklist](./checklist.md)).

## Gate mechanics

- Temperature 0, pass@1, small prompt context (problems are tiny —
  prompt context does not affect scores).
- Serve through the config you will actually run.
- Score thinking-on for comparability with published numbers; add
  thinking-off passes where sub-agent use is planned.
- Speculative decoding never changes outputs at temperature 0, so score
  without a drafter and serve with one freely.
- Timing of runs is a secondary signal; never chase precision. pass@1
  is what matters.

## Calibrate the output budget FIRST — it affects scores

`max_tokens` is a separate axis and it DOES affect scores. An
undersized budget lets reasoning exhaust the cap and empty completions
score as failures (up to 38% of scores lost before this was found).

1. Run `benchmarks/calibrate.py` (10 fixed problems, cap 30000).
2. Budget = observed max completion × 1.5, floor 8192.
3. For models whose thinking sometimes never converges
   (`finish_reason: length` at any budget), the budget is a
   waste-limiter instead: set it just above the longest SUCCESSFUL
   completion. Expect and record a real empty rate; do not chase zero
   empties with ever-larger budgets.
4. Never reuse a thinking-on budget for a thinking-off pass, or across
   models.

## Steps

1. Calibrate (above). Calibration files: `benchmarks/calibration-*.json`.
2. Start the config's server on port 8081, warm up, start the watcher
   (`benchmarks/mem-watch.sh` for a run this long).
3. Run the scoring script (`RESULTS_BASE` chooses the run dir; the
   extra body carries `chat_template_kwargs` for thinking toggles):
   ```bash
   RESULTS_BASE=benchmarks/benchN/results \
     EVALPLUS_MAX_NEW_TOKENS=BUDGET \
     benchmarks/run-humaneval.sh RUN_NAME MODEL_ID_AS_SERVED [extra-body-json]
   ```
4. The script resumes from an existing jsonl automatically (skips
   existing task_ids). Strip genuinely-empty lines first if they must
   regenerate.
5. Monitor per the checklist (output growth, not process liveness).
6. Evaluate runs automatically at the end. Record pass@1 base/plus AND
   the empty count, honestly, on every surface.

## Harness patches (do not rediscover these)

EvalPlus 0.3.1 needs local patches, all live in
`benchmarks/run_codegen_wrapper.py` + one venv file: token budget,
`extra_body` passthrough, None-content handling, no `signal.alarm` +
7200 s client timeout (EvalPlus's own 100 s alarm made long completions
retry forever), macOS rlimit in the venv. History in
`benchmarks/bench1/state.md` and `benchmarks/bench2/state.md`.
