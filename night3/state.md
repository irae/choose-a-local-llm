# Night 3 state

## Start checks (done)
- GPU free: no llama-server/mlx_lm process running.
- Read night2/state.md, night1/state.md, night2/calibration.md, README
  "Gate mechanics" per the runbook.

## Block: qwen36-think correction (finished)

This block finished the parked correction from night 2. Night 2 left
`night2/results/qwen36-think/` with 102 lines banked, then a short resumed
session added 5 more (107 lines, per night2/state.md). At the start of
night 3 the file held 110 lines with 2 more genuinely empty
(HumanEval/4, HumanEval/23) and 54 problems still missing outright.

Steps taken:
1. Stripped the 2 empty entries (HumanEval/4, HumanEval/23) from both the
   sanitized and raw jsonl files, leaving 108 lines. This let
   `evalplus.codegen`'s own resume logic (skip by task_id) regenerate them
   along with the 54 missing ones, 56 total.
2. Started the qwen36-think server (`night1/20-server-qwen36.sh`, port
   8081) and `night2/mem-watch.sh`.
3. Ran `night2/run-humaneval.sh qwen36-think qwen3.6-35b-a3b` with
   `EVALPLUS_MAX_NEW_TOKENS=26624` (the night-2 calibrated budget for this
   model) against the patched `night1/run_codegen_wrapper.py` (no
   signal.alarm, 7200s client timeout).
4. Heartbeat-checked every ~20 minutes per the runbook. No crash
   signatures in the server log at any check. Real pace: the first
   handful of completions ran slow (~480s each, this subset is the harder
   previously-failed set), then sped up to ~215s each by the end. Total
   run time about 3h05m for all 56 regenerations.
5. Evaluated the finished 164-line sanitized file.

Result: pass@1 base 0.939 / plus 0.921. Night 2's flawed partial number
(102/164, uncorrected) is not comparable; night 1's original flawed-budget
score was 0.560/0.552 for reference.

5 completions came back genuinely empty even at the 26624 budget:
HumanEval/4, 23, 55, 107, 121. Confirmed empty in the raw file too, not a
sanitizer parsing issue — a real model limitation at this budget, matching
the same pattern seen on bonsai-think in night 2 (5/164 empty there too).

Stopped the qwen36-think server and `night2/mem-watch.sh` after the
evaluate step finished. GPU idle.

## Block: gemma12-lmstudio, thinking-off (finished)

Fresh 164-problem run on LM Studio, model `gemma-4-12b-it-mlx`
(`lmstudio-community/gemma-4-12B-it-MLX-4bit`). Thinking is off by
default for this model (no `enable_thinking` in the request body).

Setup notes, for the next agent:
- The `lms` CLI lives at `~/.cache/lm-studio/bin/lms`, not on `PATH` by
  default.
- `lms load` needs the short model key from `lms ls` (`gemma-4-12b-it-mlx`),
  not the full `lmstudio-community/...` HF-style path used to download it.
- Started the LM Studio server on port 8081, not the runbook's suggested
  1234, so it lines up with the port `night2/calibrate.py` and
  `night1/run_codegen_wrapper.py` already hardcode. Functionally the same
  outcome, fewer script edits.
- Added `night3/run-humaneval.sh`, a copy of `night2/run-humaneval.sh`
  that writes to `night3/results/<name>/` instead of `night2/results/`,
  since this is a fresh night-3 run, not a night-2 correction.

Steps:
1. Calibrated the thinking-off budget with `night2/calibrate.py` (10 fixed
   problems, cap 30000). All 10 finished cleanly, no cap hits. Max
   completion 4963 tokens, so budget = round(4963 * 1.5) = 7500.
2. Ran `night3/run-humaneval.sh gemma12-lmstudio-off gemma-4-12b-it-mlx`
   at budget 7500 with `night2/mem-watch.sh` running alongside.
3. Heartbeat-checked every ~20 minutes (then every 5 minutes near the
   end). No crash signatures, steady pace throughout (~19-32s/problem).
   Total run time about 1h33m for codegen, then evaluate.

Result: pass@1 base 0.909 / plus 0.872, 0/164 empty. Stopped
`night2/mem-watch.sh`; left the LM Studio server and model loaded, since
the next sub-step (thinking-on, budget 16384) reuses it.

## Next

Per the runbook, the next sub-step is gemma12-lmstudio thinking-on at
budget 16384, reusing the same loaded model. Waiting for the user's
go-ahead — blocks run one at a time.

Also per the owner's new rule in `AGENTS.md`: benchmark runs from now on
live on their own branch, not master. This run stayed on master because
it started before the rule existed; the next one should branch first.
