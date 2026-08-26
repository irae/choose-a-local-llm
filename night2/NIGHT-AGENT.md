# Night 2 — fair EvalPlus scores for all five configs

You are the overnight executor. Your goal: produce EvalPlus HumanEval+ scores
that are NOT capped by the output token budget, for all five configs. Night 1
scored three configs under a known-flawed `max_tokens=3072`; you will fix those
three cheaply and score the two Gemma configs fresh.

Write all prose (state file, logs, commit messages, any sub-agent prompts) in
ASD-STE100 Simplified Technical English: short sentences, active voice, simple
words. Pass this rule to any sub-agent you dispatch.

## Read first, in this order

1. `night1/state.md` — every bug you may hit again is documented there, with
   its fix. The fixes live in `night1/run_codegen_wrapper.py`,
   `night1/run-humaneval.sh`, and one patched file inside the EvalPlus pipx
   venv (`evalplus/eval/utils.py`, macOS rlimit — if EvalPlus gets
   reinstalled, that patch is gone; re-apply it per state.md).
2. `night1/results.md` — the scores you will correct, and the empty-completion
   counts per block.
3. `README.md` "Gate mechanics" — the corrected methodology rules.

## Ground rules (unchanged from night 1)

- One model on the GPU at a time. Fresh server start per config. Port 8081.
- Wired limit is 25000 now (not 27000; README is updated). All night-2 servers
  run 32K contexts — they fit with room to spare. Do not change the sysctl.
- Maintain `night2/state.md`: current phase, incidents, decisions, one line per
  completed block. Update on every transition. It is the handoff if you die.
- Timing is a secondary signal. Note clean-run wall-clock if convenient. Do not
  spend effort on it. pass@1 is what matters.
- Do NOT update the HTML reports, comparison.html, or the pi config. The
  morning session does that with the user (four-surface rule).
- Commit to git when a phase completes (night2 files only; message in STE).

## Precondition: the GPU must be free

The user runs their own GPU tests during the day. Before you start any server:
`pgrep -fl "llama-server|mlx_lm"` must be empty AND the user's own workload
must be done. If a process you did not start holds the GPU, stop and wait —
do not kill it. Re-check every 20 minutes.

## Phase A — calibrate the output budget per model

The user may be present for this phase and can help. If a step needs the user
(a firewall prompt, an ambiguous result) and they do not respond, park that
config, note it in state.md, and continue with the next one.

For each of the five configs (server script → model id as served):

| config | server script | model id | extra body |
|---|---|---|---|
| qwen38-mlx-medium | `night1/10-server-qwen38-mlx-medium.sh` | `mlx-community/Qwen3.8-27B-4bit` | `{"chat_template_kwargs":{"reasoning_effort":"medium"}}` |
| qwen36-think | `night1/20-server-qwen36.sh` | `qwen3.6-35b-a3b` | none (thinking default on) |
| bonsai-think | `night1/30-server-bonsai.sh` | `prism-ml/Ternary-Bonsai-27B-mlx-2bit` | none (thinking default on) |
| gemma26-think | `night1/40-server-gemma26-think.sh` | `gemma-4-26b-a4b` | none (server sets `enable_thinking`) |
| gemma12-think | `night1/50-server-gemma12-think.sh` | `gemma-4-12b` | none (server sets `enable_thinking`) |

Steps per config:

1. Start the server with its script. Wait for health.
2. Send the same fixed sample of 10 HumanEval problems to `/v1/chat/completions`
   with `max_tokens=30000`, temperature 0. Use this fixed problem list for every
   model: HumanEval/0, 10, 26, 32, 38, 53, 76, 99, 124, 145. (124 is the known
   heavy one — Bonsai burned ~4,500 reasoning tokens on it.) Build the prompts
   the same way EvalPlus does; the simplest correct way is to read them from
   the cached dataset at `~/Library/Caches/evalplus/HumanEvalPlus-v0.1.10.jsonl`.
3. Record per request: `usage.completion_tokens`, `finish_reason`, whether
   `content` is non-empty, and where the reasoning lives (a separate
   `reasoning`/`reasoning_content` field vs. inline `<think>` tags in
   `content`). If any server inlines `<think>` in `content`, note it — Phase B
   must then add a strip-before-`</think>` step to the wrapper (EvalPlus issue
   #297 family), otherwise no wrapper change is needed.
4. Set the config's budget: the highest observed `completion_tokens` × 1.5,
   rounded up to the next multiple of 1024. Floor 8192, cap 30000.
5. Stop the server. Write the config's row into `night2/calibration.md`:
   observed max, chosen budget, response shape, anomalies.

Write the calibration requests as a small script in `night2/` (bash or the
EvalPlus venv's Python). Keep it single-purpose. Remember the zsh gotcha from
HANDOFF: in background scripts use bash, and spell out flags — do not rely on
word-splitting of unquoted variables.

## Phase B — correct the three night-1 scores (cheap re-run)

Key fact: at temperature 0, a completion that finished under the 3072 cap is
identical under a larger cap. So do not regenerate the good completions — only
the empty ones. Night 1 already proved this resume path works (see state.md,
the 16K experiment: 0 empty after the fix).

Per block (qwen38-mlx-medium, qwen36-think, bonsai-think):

1. Copy the block's `night1/results/<name>/` directory to
   `night2/results/<name>/` — never edit night-1 artifacts in place.
2. In the copy, remove every empty-content entry from BOTH the sanitized
   `.jsonl` and the `.raw.jsonl` (state.md describes the same operation done
   mid-run on night 1). Delete stale `eval_results.json` files and any
   `.tmp` leftovers.
3. Export `EVALPLUS_MAX_NEW_TOKENS=<calibrated budget for this model>` (and
   `EVALPLUS_EXTRA_BODY` for qwen38-mlx-medium, same value as night 1). Start
   the block's server. Resume codegen with `night1/run-humaneval.sh` pointed at
   the copied directory — EvalPlus's resume logic regenerates only the missing
   problems. (`run-humaneval.sh` hardcodes its results root under `night1/`;
   adapt — a small edit or a night2 variant of the script is fine. Note the
   deviation in state.md.)
4. Verify before trusting: 0 empty completions in the final sanitized file;
   `evalplus.evaluate` graded the sanitized file, not `.raw` (check the
   eval_results filename); score is plausible.
5. Record in `night2/state.md` and `night2/results.md` as "night 2 corrected"
   with the budget used and the number of regenerated problems.

Expected regeneration volume: ~3 (qwen38) + 62 (qwen36) + 49 (bonsai)
problems. Qwen3.6 and Bonsai are the slow ones; run them last if the user
still needs the machine.

## Phase C — score the two Gemma configs fresh

Run gemma26-think then gemma12-think, full 164 problems each, with their
calibrated budgets from Phase A (export `EVALPLUS_MAX_NEW_TOKENS`). Same
verification as Phase B step 4. Results in `night2/results/<name>/`.

## Expect the unexpected — you are allowed to be creative

Night 1's surprises were not in its runbook: a CLI flag that did not exist, a
firewall silently eating downloads, a macOS kernel limit, a wrong file graded.
Night 2 will have its own. You are explicitly allowed, and expected, to invent
fixes for problems this runbook did not foresee. The constraints on your
creativity:

- Protect score fairness first. Every model gets the same treatment except the
  per-model budget. If a fix would treat one model differently, stop and think
  whether it biases the score; if it does and there is no neutral variant,
  park the block and write up the problem instead.
- Prefer the smallest fix that works. Patch the wrapper, not the benchmark;
  patch one venv file only when a subprocess boundary forces it (state.md has
  the precedent).
- Record every deviation in `night2/state.md`: symptom, root cause, fix, and
  which blocks it affects. A wrong-but-documented night is recoverable; an
  undocumented one is not.
- Suspect the harness before the model. An empty or truncated answer is a
  budget/plumbing symptom until proven otherwise (check `finish_reason`, retry
  once with a higher cap against the live server).

Needs the user (park and continue if absent): firewall prompts for new
processes, anything requiring sudo, any decision that changes what a score
means, the GPU being held by a process you did not start.

## Shutdown

1. `night1/90-stop-servers.sh`; `pkill -f evalplus`; confirm
   `night1/progress.sh` shows nothing running. Leave the machine idle.
2. Finalize `night2/results.md`: one table — block, model, budget used, pass@1
   base and plus, empty count (must be 0), regenerated count, incidents.
3. Final `night2/state.md` entry: what finished, what failed and why, what you
   changed. Commit.
