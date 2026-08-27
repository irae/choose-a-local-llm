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
- **Correction/addition (05:57, user-reported), re: the slowdown pattern
  above.** The user had Brave and other apps open in the background all
  night (left running when they went to sleep); memory pressure was
  visibly "orange/yellow" in Activity Monitor before they closed those
  apps just now. `vm_stat` before/after showed free pages jump once they
  closed things, and qwen36-think's decode speed on a fresh shallow task
  immediately after was back to near-baseline (~58-60 tok/s, matching the
  README's documented ~62-68 tok/s near-empty). This means background-app
  memory pressure competing with the 25GB wired GPU allocation is a
  plausible **additional or alternative** explanation for tonight's (and
  possibly night 1's) slowdowns, not confirmed to be thermal alone — no
  temperature telemetry was ever available to distinguish the two. Actionable
  lesson for future nights: close background apps before a long unattended
  run, not just assume heat. Left as an open question, not resolved either
  way; do not overwrite the "thermal" language elsewhere without more
  evidence, just add this as a competing hypothesis.
- Wrote `night2/mem-watch.sh` (5-min-interval free-RAM + swap/compression
  delta logger, output in `night2/mem-watch.log`) to help settle the
  thermal-vs-memory-pressure question on a future run. Started it at
  06:02. It caught a real event: at 06:27:25 the 5-min window showed
  `d_swapout=29104 d_compress=1435367` — genuine active swapping and heavy
  compression, not just steady-state low free RAM. This is real evidence
  for the memory-pressure hypothesis, at least for this session; still not
  proof it, rather than heat, explains every slowdown seen tonight (the
  two can co-occur). Keep `mem-watch.log` for whoever picks this up next.

## Stopped by user request (06:2x) — machine needed
qwen36-think's Phase B correction was mid-flight (regenerating
HumanEval/4 when killed) and made **no additional progress** this
session: still 102/164 lines in the sanitized file (the 62 empties removed
earlier, 0 regenerated and saved before the kill — the in-flight
generation for HumanEval/4 was not saved). `night2/results.md` was not
updated for qwen36-think; it still only reflects the finished
qwen38-mlx-medium correction.
All processes killed cleanly: `night2/mem-watch.sh`,
`night2/run-humaneval.sh`/`run_codegen_wrapper.py`/`evalplus.evaluate`,
and the llama-server. `night1/90-stop-servers.sh` confirms nothing
running. Machine left idle.

**Remaining work for the next session, in order:**
1. qwen36-think: resume `night2/run-humaneval.sh qwen36-think
   qwen3.6-35b-a3b` (with `EVALPLUS_MAX_NEW_TOKENS=26624` and the qwen36
   server up) — still needs all 62 previously-empty problems regenerated,
   none banked yet.
2. bonsai-think: not started. Copy `night1/results/bonsai-think/` to
   `night2/results/bonsai-think/`, strip the 49 empty entries from both
   jsonl files, resume at budget 10240.
3. Phase C: gemma26-think and gemma12-think, full fresh 164-problem runs
   at budget 30000 each. Expect long, possibly multi-hour runs per config
   given calibration behavior (repeated cap hits, slow decode) — see
   night2/calibration.md.
4. Finalize `night2/results.md` and do the Phase A/B/C shutdown checklist
   in NIGHT-AGENT.md once all blocks are done.

## Phase B — in progress

- Incident, qwen38-mlx-medium resume: `mlx_lm.server` crashed one request
  thread mid-generation with `RuntimeError: [metal::malloc] Resource limit
  (499000) exceeded` (Metal buffer-count limit, not an OOM). The server
  process stayed alive and `/health` kept returning 200, but that specific
  request never got a response. EvalPlus's own request loop
  (`evalplus/gen/util/openai_request.py`) retries forever on any exception
  with a 100s SIGALRM timeout per attempt, so the codegen process looked
  "stuck" on HumanEval/132 for 40+ minutes — actually silently retrying the
  same doomed request against a half-dead server. Confirmed via the server
  log traceback, not by guessing.
  Fix: killed the codegen process, restarted the server fresh
  (`night1/10-server-qwen38-mlx-medium.sh`), reran
  `night2/run-humaneval.sh` — resume logic picked up cleanly (HumanEval/39
  had already regenerated successfully before the crash; only 132 and 145
  remained missing). Lesson for later blocks: if a codegen run stalls on
  one task_id for far longer than its calibrated budget should allow,
  check the *server's* log for a crash traceback before assuming the model
  itself is just slow — `/health` returning 200 does not mean every
  request path is alive.
- qwen38-mlx-medium: night 2 corrected. Regenerated 3 empty completions
  (HumanEval/39, 132, 145) at budget 8192. 0 empty in final sanitized file,
  sanitized (not raw) file graded. pass@1 base 0.982 / plus 0.939 (night 1:
  0.970 / 0.939 under the flawed 3072 cap). Server stopped.

## Phase A — complete
All five configs calibrated. Budgets: qwen38-mlx-medium 8192,
qwen36-think 26624, bonsai-think 10240, gemma26-think 30000,
gemma12-think 30000. Server stopped, GPU idle. Moving to Phase B.
