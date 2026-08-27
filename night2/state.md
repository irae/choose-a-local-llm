# Night 2 state

## Start checks (done)
- GPU free: no llama-server/mlx_lm process running.
- Dataset cached: `~/Library/Caches/evalplus/HumanEvalPlus-v0.1.10.jsonl` present.
- macOS venv patch (RLIMIT_AS/RLIMIT_DATA in evalplus/eval/utils.py) still
  applied. No reinstall happened since night 1, so no re-patch needed.
- Wired limit is 25000 (per README, already set from night 1; no sysctl
  change made tonight).

## Phase A — calibration
Status: in progress.

- qwen38-mlx-medium: done. See night2/calibration.md. No wrapper change
  needed (reasoning stays in a separate field, not inline).
- Incident: qwen36-think's server script reported "up" (health check passed)
  but the first calibration request got HTTP 503 "Loading model". The
  server script's health loop checks `/health`, which can return ok slightly
  before the model finishes internal init. Fix: wait a few seconds and
  retry; no script change made (one-off race, not worth adding retry logic
  for a five-config night). Retried and it worked.
- qwen38-mlx-medium, qwen36-think, bonsai-think calibration all done. See
  night2/calibration.md.
- Incident, gemma26-think calibration: decode speed collapsed mid-sample
  (HumanEval/0 fast at 23.8s/1109 tok; HumanEval/10 dropped to 693.3s for
  3517 tok, effectively ~5 tok/s; HumanEval/26 recovered to 19.6s/969 tok).
  Same signature as night 1's Bonsai thermal-throttling finding (sustained
  GPU load in a laptop chassis) — flag when reading gemma26's numbers.
  `calibrate.py`'s `openai.OpenAI` client used the library default timeout
  (600s), so the next request (HumanEval/32, running very long) hit
  `APITimeoutError` client-side and llama-server logged `cancel task` at
  13512 generated tokens. Root cause: my calibration script, not the model
  or the server — a slow/thinking-heavy model can legitimately need more
  than 600s for one completion even under a correct budget.
  Fix: raised the client timeout to 3600s, made the script write its JSON
  output after every row (was only written once at the end, so the crash
  lost the 3 completed rows from the log) and skip already-done task_ids on
  resume. Seeded night2/calibration-gemma26-think.json with the 3 rows
  recovered from the log before restarting. This fix applies to every later
  calibration or resume run, not just gemma26.
- gemma26-think and gemma12-think calibration both done. See
  night2/calibration.md. **Notable finding**: gemma12-think (the smaller
  model) hit the 30000-token cap with empty content on 4 of 10 sample
  problems, worse than gemma26-think's 2 of 10. Both use budget 30000 (the
  Phase A cap). This is a genuine model-behavior finding, not a bug — expect
  Phase C's gemma12-think run to show a meaningfully higher empty rate than
  gemma26-think even under the same cap.
- Repeated pattern across gemma26-think and gemma12-think calibration:
  decode speed drops sharply on long generations (from ~25-30 tok/s down to
  ~5-13 tok/s), matching night 1's thermal-throttling finding on this
  machine under sustained load. Flag when reading any timing data from
  tonight; pass@1 remains the trustworthy signal.

## Phase A — complete
All five configs calibrated. Budgets: qwen38-mlx-medium 8192,
qwen36-think 26624, bonsai-think 10240, gemma26-think 30000,
gemma12-think 30000. Server stopped, GPU idle. Moving to Phase B.
