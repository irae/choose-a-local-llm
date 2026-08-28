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

## Next

Per user instruction, no other block starts before this session's docs are
updated. Next block per `night3/NIGHT-AGENT.md`: gemma12-lmstudio
(thinking-off first, calibrate its budget, then thinking-on at 16384).
Waiting for the user's go-ahead to start it — blocks run one at a time.
