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

gemma12-lmstudio thinking-on is blocked: LM Studio's REST API exposes no
working thinking toggle for this model, and mlx_lm.server cannot load it
(`gemma4_unified` unsupported, confirmed again 2026-08-29 — mlx-lm is
still at 0.31.3). Needs the owner's decision. Skipped to the next runbook
block.

## Block: gemma26-mlx, thinking-on (finished)

Fresh 164-problem run, `mlx-community/gemma-4-26b-a4b-it-4bit` on
mlx_lm.server, budget 30000, `chat_template_kwargs: {enable_thinking:
true}`.

Steps:
1. Started the server with `night3/10-server-gemma26-mlx.sh`
   (`--prompt-cache-size 2`, per the mlx memory-leak rule).
2. Ran `night3/run-humaneval.sh gemma26-mlx
   mlx-community/gemma-4-26b-a4b-it-4bit` with
   `EVALPLUS_MAX_NEW_TOKENS=30000` and
   `EVALPLUS_EXTRA_BODY='{"chat_template_kwargs": {"enable_thinking":
   true}}'`, `night2/mem-watch.sh` alongside.
3. Ran across two agent sessions: paused at 130/164 (server and process
   stopped between sessions), resumed with the identical command —
   evalplus's own codegen resume picked up from the existing jsonl with
   no gap or duplicate. Heartbeat-checked every ~20 minutes throughout.
   No crash signatures. Total codegen time 2h16m for the full 164 (most
   of it before the pause).
4. Evaluated the finished 164-line file.

Result: pass@1 base 0.713 / plus 0.701, 46/164 (~28%) empty. This is a
real model limit, not a harness artifact: the calibration for this model
already showed 2/10 sample problems never finishing reasoning at a 30K
cap, and the reports page documents Gemma's thinking-convergence problem.
Stopped `night2/mem-watch.sh` and the server.

## gemma12-lmstudio-off: confirmed genuinely thinking-off (2026-08-29)

The owner asked whether the archived `gemma12-lmstudio-off` row (block
above, `gemma-4-12b-it-mlx`, 0.909/0.872, 0/164 empty) might have
secretly had thinking on. Checked directly, not from archaeology alone
(evalplus's own code only ever reads `.content`, never
`.reasoning_content` — the archived `.raw.jsonl` cannot prove either way
by itself).

Test: ran problems HumanEval/0-15 through `google/gemma-4-12b` on LM
Studio (0.4.23, mlx-engine 1.10.1) with thinking confirmed active
(`reasoning_content` populated, budget 16384,
`tools/sweeps/lmstudio_evalplus_smoke.py`, results at
`/tmp/gemma12-lmstudio-thinking-smoke/c1_think-omit.jsonl` and
`.stats.jsonl`, not committed — exploration only). Compared against the
archived run's own per-problem results on the same 16 problems, from
`night3/results/gemma12-lmstudio-off/humaneval/gemma-4-12b-it-mlx_openai_temp_0.0_eval_results.json`.

| | archived (labeled thinking-off) | confirmed thinking-on (this session) |
|---|---|---|
| pass@1, same 16 problems | 15/16 (0.938) | 12/16 (0.75) |
| empty/truncated (`finish_reason: length`) | 0/16 | 4/16, all with `reasoning_tokens≈16381` |
| reasoning phase in server log | none | every problem, `"Start thinking... Done reasoning, ~26s+"` |

Scores differ (0.938 vs 0.75) and the confirmed-thinking-on run shows a
distinctive failure signature (budget exhausted by non-convergent
reasoning) that appears on 25% of this sample — matching the same rate
seen on Gemma-26B thinking-on tonight (46/164, 28%, see the block
above). The archived run shows zero instances of that signature across
its full 164 problems. If it had been secretly reasoning, that failure
mode would very likely show up at least some of the time — it does not.

**Conclusion: the archived `gemma12-lmstudio-off` score is genuinely
thinking-off.** The suspicion does not hold up. Not written to the site
— this is a note to explain the archived number, not a new measurement.

## gemma12-lmstudio depth sweeps, v2: watched and pinned (2026-08-29)

The first pass at these sweeps (single-context, then 2-context
alternating) ran without the memory watcher for roughly their first
half — a rule violation. Both were re-run clean, watcher running from
the first request, model reloaded with a pinned config
(`lms load google/gemma-4-12b -c 158464 --parallel 4 --gpu max -y`) for
reproducibility instead of trusting LM Studio's per-load auto-fit.

**Single-context v2** (`tools/sweeps/lmstudio_sweep.py`, watcher log
`/tmp/mem-watch-gemma12-single.log`, not committed): reached the full
pinned window, 158,072 tokens, at 22.77 tok/s, never crossed the 8 tok/s
floor. Full curve: 4071→35.07, 8084→35.29, 16101→34.14, 32074→32.34,
49087→30.53, 74108→28.27, 98089→25.19, 131066→23.03, 147091→23.36,
158072→22.77. This directly contradicts the first (unwatched) pass,
which crashed to 7.08 tok/s at the identical 98089-token depth and
stopped there — that crash does not reproduce under watched, pinned
conditions and looks like transient system noise (possibly related to
having two model instances loaded at once during the first pass), not a
real property of this config.

**2-context alternating v2** (`lmstudio_sweep_alt.py`, watcher log
`/tmp/mem-watch-gemma12-alt.log`, not committed): both contexts tracked
each other closely through 147,091 tokens (A: 23.14 tok/s, B: 23.20
tok/s). The 147K step hit LM Studio's disk-cache eviction
(`cached_tokens=0 uncached_tokens=152673`, step wall time inflated to
~1187-1219s by a forced recompute — the decode tok/s figure itself stays
valid, since it is measured from post-prefill streaming only, but the
timing is contaminated). The next step (~158K) failed cleanly with a
real server error, not a crash: `"The number of tokens to keep from the
initial prompt is greater than the context length"` — context A's real
token count exceeded the pinned 158,464 limit (the script's chars/4
token estimate undercounts). This is our own pinned window being hit,
not a memory or speed ceiling.

**Not written to the site.** Pinning to 158,464 copied whatever LM
Studio's auto-fit had picked earlier in the night — it is not the
model's trained max (262,144), so this run never actually searched for
the real ceiling. Writing "158k" over the existing site figure ("170k",
from LM Studio's auto-fit, already flagged there as a loader quirk
rather than a true measurement) would read as a regression when neither
number is really a found ceiling. The owner decided: do not update the
site for this pass. See HANDOFF.md and night4 for the follow-up (re-pin
to 262144, run the real ceiling search, decide what if anything
supersedes the 170k figure).

## Handed to night4

Everything left open at the end of night 3 moved to `night4/`:
bonsai-prism (resume from 72/164, this time with `night2/mem-watch.sh`
running throughout), bonsai-off, and the LM Studio gemma-12b real-ceiling
follow-up. See `night4/NIGHT-AGENT.md`.

Also per the owner's new rule in `AGENTS.md`: benchmark runs from now on
live on their own branch, not master. This run stayed on master because
it started before the rule existed; the next one should branch first.
