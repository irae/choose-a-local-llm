# Night 1 state

## Setup
- Wired limit: 25000, not 27000 as the runbook expects. Per NIGHT-AGENT.md this is
  fine: big contexts are not needed tonight, 32K slots fit regardless. Continuing.
- EvalPlus was not installed. Installed via `01-install-evalplus.sh`
  (pipx, evalplus 0.3.1, Python 3.14.7).
- Flag mismatch found: installed EvalPlus 0.3.1's `evalplus.codegen` CLI has no
  `--max-new-tokens` flag. The OpenAI backend hardcodes `max_new_tokens=768`
  (`evalplus/provider/base.py`), and `run_codegen`/`make_model` never expose it.
  A 768-token cap would truncate thinking-model output mid-thought and falsely
  tank scores (README rule 3). Fix: added `run_codegen_wrapper.py`, which
  monkeypatches `make_model` to set `max_new_tokens=3072` after construction, then
  runs the same Fire CLI. Updated `run-humaneval.sh` to call the wrapper through
  the EvalPlus pipx venv's own Python, and to use `--base_url` (underscore; the
  actual flag name) instead of `--base-url`. `--model`/`--dataset`/`--greedy` and
  `evalplus.evaluate`'s `--dataset`/`--samples` flags matched the installed
  version already; no other changes needed. Smoke-tested the wrapper's `--help`
  output — flags resolve correctly.

## Run list status
Timing = clean-run only (final successful attempt's server-start to
evaluate-finish; restarts/bugfixing excluded — see results.md for the
methodology and per-block incident notes).

| # | name | status | pass@1 (base/plus) | clean start | clean finish | clean duration | notes |
|---|---|---|---|---|---|---|---|
| 1 | qwen38-mlx-medium | done | 0.970 / 0.939 | 01:47 | 04:34 | ~2h47m | mlx, reasoning_effort=medium |
| 2 | qwen36-think | done | 0.610 / 0.610 | 04:38 | 06:35 | ~1h57m | llama+MTP, thinking on |
| 3 | bonsai-think | done | 0.640 / 0.634 | 13:47 (final revert-resume) | 18:44 | see incidents — timing is not clean (2 restarts + 2 methodology changes) | mlx, thinking on; final resume under reverted max_tokens=3072, 49/164 empty (expected/accepted). NOTE: generation rate dropped sharply once around ~09:26 (windowed rate ~7.8 chars/s before, ~2.4-2.6 chars/s after) and stayed flat at the low rate through a ~90 min window when the user was NOT using the machine — ruling out user-activity contention. User confirmed via Activity Monitor: GPU pinned 98%+ throughout, memory ~40% used with no pressure/compaction/swap. GPU busy-but-slower plus no memory contention is the classic thermal-throttling signature (sustained load in a laptop chassis over 5+ hours) — now the leading explanation, not confirmed via temperature telemetry. Flag when comparing block 3's timing against blocks 1/2, which ran on an otherwise-idle, presumably-cooler machine overnight — and note timing for block 3 is not a clean single-attempt number regardless, given the max_tokens experiment/revert. Separately, useful qualitative finding: user reports Bonsai is noticeably less disruptive to work alongside than the other models tested tonight (moderate fan noise, not the loudest; the others "disturbed a lot" when multitasking) — a practical point in Bonsai's favor for background/all-day use given its score held up reasonably (0.634, between blocks 1 and 2). |
| 4 | gemma26-think | pending | | | | | |
| 5 | gemma12-think | pending | | | | | |

## Incidents
- Block 1 pre-check: verified mlx_lm.server DOES honor a `chat_template_kwargs`
  body field (NIGHT-AGENT.md step 1 test) — output differs with vs. without it.
  But EvalPlus's OpenAI decoder never sends extra body fields at all. Extended
  `run_codegen_wrapper.py` to read an `EVALPLUS_EXTRA_BODY` env var and merge it
  into every request via the OpenAI client's `extra_body` param. Confirmed by
  server log: distinct successful (200) completions after setting
  `reasoning_effort=medium`. No fallback to the GGUF path needed.
- A `--id_range` smoke-test attempt did not parse as a single-problem filter
  (Fire list-flag quoting); it started generating the full dataset instead. No
  harm — this proved the real path works, so went straight to the full run
  rather than perfecting a 1-problem smoke test.

- Block 1 died once: 21+ minutes at ~0% CPU, zero HumanEval+ requests reached
  the mlx server. EvalPlus's dataset downloader uses the `wget` Python package
  (`evalplus/data/utils.py: make_cache`), which hung silently fetching
  `HumanEvalPlus-v0.1.10.jsonl.gz` from GitHub, even though the same URL
  downloads via `curl` in under half a second. Worked around by pre-populating
  EvalPlus's real cache dir (`~/Library/Caches/evalplus/HumanEvalPlus-v0.1.10.jsonl`,
  from `appdirs.user_cache_dir("evalplus")` — not `~/.cache/evalplus`) via a
  curl download + gunzip myself, matching the exact path `make_cache` expects,
  so it finds the file cached and skips `wget` entirely.
  CORRECTION (07:11 local, after the user authorized GitHub on their
  firewall): the real root cause was the user's local firewall silently
  blocking the Python process's outbound connection to GitHub, not a `wget`
  package bug — `curl` worked because it's a separately-approved process.
  Confirmed by retrying the exact same `wget.download()` call after the user's
  authorization: it now succeeds in ~9s. The curl-based cache workaround
  above is still in place and harmless, but the earlier diagnosis blaming the
  `wget` package was wrong; a firewall prompt on a new process is the more
  general lesson for any future GitHub/network access from a freshly-invoked
  binary in this environment.

- Block 1 died a second time: codegen crashed at problem 39/164 (31 min in)
  with `AttributeError: 'NoneType' object has no attribute 'split'` inside
  EvalPlus's `sanitize()`. Cause: the chat response's `message.content` came
  back `None` for one problem (a cut-off or empty-answer turn), and EvalPlus
  passes that straight to `sanitize()` without a None check. This crashed
  `run_codegen_wrapper.py`, but `run-humaneval.sh` kept going anyway and ran
  `evalplus.evaluate` on the partial (39-problem) output, which then failed
  differently — see below. Fix #1 (masking): `run-humaneval.sh` had `set -e`
  but not `set -o pipefail`, so `evalplus.codegen | tee codegen.log`'s exit
  status was `tee`'s (always 0), silently hiding the crash. Added
  `set -o pipefail`. Fix #2 (root cause): extended `run_codegen_wrapper.py` to
  monkeypatch `OpenAIChatDecoder.codegen` so a `None` content is treated as an
  empty string — that one problem now just scores as failed instead of taking
  down the whole run. Applies to every later block, not just this one.
- Found while diagnosing the above: EvalPlus's `evaluate` step is broken on
  this Mac entirely, independent of the codegen crash. Its sandboxing helper
  `reliability_guard()` calls `resource.setrlimit(RLIMIT_AS, ...)` and
  `RLIMIT_DATA`, which raise `ValueError: current limit exceeds maximum limit`
  on macOS even when lowering from `RLIM_INFINITY` — reproduced with a bare
  Python script outside EvalPlus, so this is a real macOS/XNU kernel
  limitation, not a config problem. EvalPlus's own code already exempts
  Darwin from the same problem for `RLIMIT_STACK` a few lines below, but
  missed `RLIMIT_AS`/`RLIMIT_DATA`. Since `evaluate`'s workers are macOS
  `spawn`-started subprocesses that re-import the module fresh, a wrapper-side
  monkeypatch (like the codegen fixes above) cannot reach them — the fix had
  to go into the installed package file itself:
  `~/.local/pipx/venvs/evalplus/.../evalplus/eval/utils.py`, extending the
  existing Darwin check to cover all three `setrlimit` calls. Verified fixed
  with a standalone spawned-subprocess test. This would have blocked
  `evaluate` for every block tonight, not just block 1.

- Block 1's first completed run reported `pass@1: 0.000` for both base and
  plus — implausible for a 27B model. Root cause: `run-humaneval.sh` picked
  the samples file with `find "$DIR" -name "*.jsonl" | head -1`, and `find`'s
  order isn't guaranteed; it happened to return the `.raw.jsonl` file (still
  containing markdown fences and explanatory prose, not bare Python) instead
  of the sanitized `.jsonl` file. Confirmed via the eval_results.json name
  (`..._temp_0.0.raw_eval_results.json`) and its `base_status: fail` on
  literally unparseable code. Spot-checked the sanitized file directly — the
  164 codegen'd solutions look correct, so no need to redo codegen. Fix:
  changed the find filter to `-name "*.jsonl" ! -name "*.raw.jsonl"`, applies
  to every later block too. Re-ran only `evalplus.evaluate` against the
  correct sanitized file for block 1: pass@1 0.970 (base) / 0.939 (plus) — a
  plausible score, recorded above.

- Block 2 (qwen36-think) completed clean on the first attempt (no restarts) —
  the fixes from block 1 held. pass@1 0.610 base / 0.610 plus. Verified it
  graded the sanitized file (eval_results.json name has no `.raw` in it, and
  the sample 0 solution is bare Python) before trusting the score, since the
  earlier block-1 bug made an implausible score look real; base == plus is
  a little unusual but not implausible (no plus-only tests failed anything
  extra), unlike block 1's exact 0.000 which was a certain giveaway.

- **Major finding, block 3 (bonsai-think): `max_tokens=3072` was too low, and
  the project's own planning assumption behind that number was wrong.**
  `README.md`'s "Gate mechanics" said prompt context size doesn't affect
  scores (true — problems are tiny) and treated `max_tokens` as basically the
  same non-issue ("~3072 is generous") — false. Output token budget is a
  separate axis from prompt context and it does affect scores. Noticed 34/129
  of Bonsai's completions came back with empty content, worsening sharply
  over the run (12% empty in the first half of completed tasks, 42% in the
  second half, last 6 in a row all empty — same window as the earlier
  throughput slowdown). Diagnosed by sending HumanEval/124's exact prompt to
  the live server with `max_tokens=8000` instead of 3072: reasoning alone
  consumed ~4,500+ tokens before the model even started its answer, then
  produced a complete, correct-looking solution once given room. Under the
  real 3072 cap, that reasoning alone exhausts the budget, leaving nothing
  for the answer — a harness ceiling being scored as a model failure, not
  genuine incapacity. Corrected `README.md` (split prompt-context-doesn't-matter
  from max-tokens-does-matter, note this needs verifying per model) and
  `night1/NIGHT-AGENT.md` (added a "verify max_tokens per model" rule).
  Fix in progress: bump `run_codegen_wrapper.py`'s `MAX_NEW_TOKENS`, clear the
  34 empty-content lines from both jsonl files so EvalPlus's resume logic
  regenerates just those (plus the remaining un-attempted tasks) under the
  corrected budget, without redoing the ~95 good completions already banked.
- Per the user: timing is a secondary signal, not worth precision — stop
  investing effort there; pass@1 is what matters.

- max_tokens fix verified working at MAX_NEW_TOKENS=16000: every regenerated
  task (HumanEval/19 through the current point) came back non-empty — 0 empty
  entries across all 90 completed at that point, vs. the ~30-40% empty rate
  before the fix.
- **Fairness check, requested by the user: are blocks 1 and 2 affected by the
  same bug?** Yes, both, and block 2 far worse than Bonsai ever was:
  - Block 1 (qwen38-mlx-medium): 3/164 empty (~2%).
  - Block 2 (qwen36-think): **62/164 empty (~38%)** — worse than Bonsai's
    original rate. Its recorded 0.610/0.610 is very likely a significant
    underestimate of the model's real capability.
  So none of tonight's three recorded scores are clean measurements of the
  models — all were run under the same too-low 3072 cap.
- **Decision (user, after the fairness check): revert, don't partially fix.**
  Started a live sweep to find the true per-task token requirement (via
  fresh diagnostic requests recording real `completion_tokens` usage) with
  the intent of picking a smaller, better-calibrated `max_tokens` than 16000
  and fixing all three blocks with it. The user stopped this mid-flight:
  rather than give Bonsai a different (corrected) budget than blocks 1/2
  keep, revert Bonsai to the same 3072 cap so tonight's three blocks stay
  **internally apples-to-apples** (equally flawed, but consistently so),
  and hand a proper methodology redesign to a separate effort/agent rather
  than patch it live mid-run. Executed: killed the sweep, discarded the 4
  entries Bonsai had generated under 16000 (HumanEval/19, 20, 32, 36),
  restored `run_codegen_wrapper.py`'s `MAX_NEW_TOKENS` to 3072, resumed from
  the original 89 good entries. Bonsai is again generating under the same
  flawed-but-consistent budget as blocks 1 and 2.
- **Known limitation of tonight's results, carried forward for whoever
  redesigns the methodology**: all three blocks' pass@1 scores are deflated
  by empty completions from an undersized `max_tokens=3072` (block 1 ~2%,
  block 2 ~38%, block 3 ~30-40% before any per-task variance). Prompt
  context size is confirmed irrelevant (tiny, single-turn problems); output
  token budget is the axis that needs real calibration — probably per model,
  since verbosity/reasoning-efficiency varies a lot (see README's corrected
  "Gate mechanics" section). A live diagnostic (HumanEval/124 on Bonsai)
  showed ~4,500+ tokens of reasoning alone for one moderate-difficulty
  problem — 3072 was never going to be enough for a verbose/reasoning-heavy
  model. Do not reuse 3072 as a default for any future night without
  verifying it per model first.

- **Research (2026-08-26 13:52), for whoever redesigns the methodology —
  this is well-known, not an EvalPlus-specific or unusual problem.** A first
  research attempt (a forked subagent) failed: since a fork inherits the
  full parent conversation, it got confused about its own identity and
  roleplayed as the coordinator waiting on itself instead of doing the
  research — abandoned, redid the research directly instead.
  - **EvalPlus itself**: confirmed 0.3.1 (released Oct 2024) is still the
    latest release — no newer version exists. Its CLI docs
    (github.com/evalplus/evalplus/blob/master/docs/cli.md) do not mention
    `max_tokens`/output budget or reasoning-model handling at all — matches
    what we found in the source (`evalplus/provider/base.py` hardcodes
    `max_new_tokens=768`, no CLI flag). EvalPlus's OpenAI backend
    (`evalplus/provider/openai.py`) only ever reads `item.message.content`;
    it never looks at `finish_reason` or a `reasoning`/`reasoning_content`
    field, so it cannot itself detect "ran out of budget mid-thought" —
    that gap is real and unaddressed upstream.
  - **Closest related EvalPlus issue**: #297, "[BUG] some model in Thinking
    mode, code_extract fail" (github.com/evalplus/evalplus/issues/297) — a
    different but related failure: `<think>...</think>` tags left inline in
    `content` (not a separate field) pollute `sanitize()`'s code extraction.
    Proposed fix there is a preprocessing step to strip everything before
    `</think>`. Not our exact bug (ours is `content` itself coming back
    empty because reasoning lives in a *separate* API field and consumed
    the whole budget), but same root cause family: EvalPlus predates
    reasoning-model output conventions and doesn't handle them.
  - **This is a widely-reported, cross-project problem, not niche**: found
    matching bug reports against sglang, a picoclaw local-LLM client, and
    DeepSeek-V3's own repo, all describing the identical fingerprint —
    `finish_reason: "length"` + non-empty `reasoning`/`reasoning_content` +
    empty `content`. One Qwen3.6 case reported reasoning alone hitting
    ~1400 tokens even with an explicit 200-token thinking budget the model
    ignored. Consistent recommendations across sources: raise the token
    budget generously; treat `finish_reason: "length"` as a signal to
    reject/retry rather than trust the (likely truncated) result; validate
    `content` is non-empty before parsing it downstream.
  - **A concrete, reusable calibration method, found via research** (not
    something we invented): run the model under a deliberately generous cap
    (e.g. 32K tokens) on a sample of prompts first, observe the actual
    longest response length that occurs, then pick a per-benchmark
    `max_tokens` a bit above that observed maximum — exactly the "sweet
    spot" sweep the user asked about before pausing it. Worth reviving this
    approach (properly, per model, before the run rather than mid-run) for
    the next attempt at this benchmark.
  - Sources: github.com/evalplus/evalplus/blob/master/docs/cli.md;
    github.com/evalplus/evalplus/issues/297; pypi.org/project/evalplus/;
    github.com/sgl-project/sglang (thinking_budget not enforced for
    Qwen3.6, reasoning consumes all max_tokens); DeepSeek-V3 repo issue on
    empty response after reasoning; dev.to article "finish_reason=length
    Returned Empty Content — and the Error Message Lied to Me".

## Run finished — shutdown

All three planned blocks (1, 2, 3) are done. 4 and 5 (gemma26-think,
gemma12-think) were **not started** — the user paused the run after block 3
so they could review the max_tokens finding before deciding on more blocks.
Servers stopped, `./progress.sh` confirms nothing running. HTML reports,
comparison.html, and the pi config were left untouched (morning-session job
per NIGHT-AGENT.md's four-surface rule).

Final scores, all under the known-flawed but internally consistent
`max_tokens=3072`:

| block | model | pass@1 base | pass@1 plus | empty rate |
|---|---|---|---|---|
| 1 | qwen38-mlx-medium | 0.970 | 0.939 | 3/164 (~2%) |
| 2 | qwen36-think | 0.610 | 0.610 | 62/164 (~38%) |
| 3 | bonsai-think | 0.640 | 0.634 | 49/164 (~30%) |

None of these are clean measurements of the models — see the max_tokens
finding above for why, and the research notes for a real calibration method
to use next time. Treat tonight's numbers as directional only, especially
block 2 (worst-affected).
