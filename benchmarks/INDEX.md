# Benchmark runs — findings index

One entry per run: the most interesting findings and conclusions, with
links to the full record. Newest first. Each `benchN/` folder holds that
run's runbook (`AGENT.md`), log (`state.md`), results (`results.md`,
`results/`). General tools shared by all runs live in this folder
(`run-humaneval.sh`, `run_codegen_wrapper.py`, `calibrate.py`,
`mem-watch.sh`, `calibration-*.json`).

## bench8 — 2026-09-02 ([state](bench8/state.md))

- Runbook: [bench8/AGENT.md](bench8/AGENT.md). API-model Mendel re-runs
  on the Linux box, through pi (no GPU work). Blind v1.1 for the
  strong models, guided v3.0 plus blind for the cheap probe
  (deepseek-v4-flash-0731) and the strong reference (gpt-5.6-luna),
  plus two Anthropic models added mid-run once login/budget arrived
  (`claude-haiku-4-5`, `claude-sonnet-4-5`) and a new fireworks model
  (`glm-5p3-flash`). Up to two runs ran in parallel, never two on the
  same account.
- **Scores**: deepseek-v4-flash-0731 guided 97, blind 84.5; kimi-k3
  blind 93.5; deepseek-v4-pro-0813 blind 79; grok-4.6 blind 92.5;
  gpt-5.6-luna guided 88.5, blind 83.5; gpt-5.6-sol blind 92;
  glm-5p3-flash blind 75, guided 98; claude-haiku-4-5 guided 76, blind
  34; claude-sonnet-4-5 blind 43.5.
- **Anthropic models underperformed their reputation on this task**:
  claude-haiku-4-5 and claude-sonnet-4-5 both hit trap A (the
  `fs.promises.glob()` AsyncIterator trap) on their blind runs, and
  neither removed the root `rimraf`/`tmp` devDependencies at all —
  sonnet's blind row never ran `pnpm install` in any form. Both used
  `refactor`/`fix` commit types instead of the house `chore`
  convention. Haiku's guided run (76) showed the usual guided lift
  over its blind run (34), consistent with other weak/local models in
  this project's Mendel history.
- glm-5p3-flash's guided run (98) is the strongest score of this run,
  with all three traps handled correctly, including trap C avoided by
  design (the model's own TASKS.md reasoned through the issue's wrong
  claim about `tmp` and chose not to add a buggy exit hook).
- Site mirror (`benchmarks/mendel/`) refreshed to match; see
  `docs/methodology/mendel.md` for how the two Mendel tests differ.

## bench6 — 2026-09-01 ([state](bench6/state.md), [results](bench6/results.md))

- Runbook: [bench6/AGENT.md](bench6/AGENT.md). EvalPlus only: finished
  the Gemma-12B thinking-on run (0.622/0.610, resumed from 98/164),
  Qwen3.8-27B effort low (0.976/0.927), bonsai-off (0.927/0.902).
  **Block 4 (Qwen3.6-35B-A3B MTP drafter re-check) deferred to run 7**
  (owner's decision, 2026-09-01) — run 6 closes after block 3. Mendel
  and Aider polyglot also move to run 7.
- **Planning note for bench7 (owner's call, 2026-09-01):** bench6 scored
  EvalPlus for two new configs (Qwen3.8-27B effort low, bonsai-off)
  without a tok/s depth sweep first — the site rows carry stale
  speed/memory cells copied from a sibling config instead. The owner
  considers this a planning miss (the usual order is memory ceiling,
  then depth curve, then quality gate) but is keeping bench6's plan as
  is since it is still a valid EvalPlus-only run. For bench7: schedule
  the depth/tok-s sweep for both `qwen38-mlx-low` and `bonsai-mlx-off`
  before, or instead of, treating their `stale` speed/memory fields as
  settled.

## bench5 — 2026-08-30/31 ([state](bench5/state.md))

- **Bonsai fork depth sweeps** (`bonsai-fork-single`, `bonsai-fork-2x`):
  speed floor 33K used tokens at 7.9 / 7.8 tok/s, 9.6 / 10.9 GB RSS, no
  compression or swap. Daggers cleared.
- **Gemma-12B LM Studio shallow probe**: 35.4 tok/s (replaces the
  unverified 37), 8.1 GB RSS (replaces 8.8 GB).
- **Mendel blind rows**: Bonsai MLX 55/100 partial, Qwen3.8-27B medium
  79.5/100 partial. **Mendel guided rows** (prompt v2.1): Qwen3.6-35B-A3B
  67.5, Bonsai MLX 70 partial, Qwen3.8-27B low 84 partial. All rows were
  re-scored from branches and session logs on 2026-08-31; the report
  and the site mirror (`benchmarks/mendel/`) carry the current numbers.
- **`pi -p` retired for Mendel**: it exits on the first `length`/error
  stop. Runs now go through `run-pi-rpc.mjs` (`pi --mode rpc`) with a
  fixed nudge policy. Two `mlx_lm.server` failure classes recorded
  (tool-call parser crash on embedded quotes; truncated tool-call
  warning followed by a silent `pi` exit).
- **Qwen3.6-35B-A3B MTP drafter fails to allocate** on the current brew
  llama.cpp build and leaves the backend returning HTTP 500 while
  `/health` stays ready. The guided Mendel run used the no-drafter
  command. Re-check planned in bench6.
- Gemma-12B thinking-on EvalPlus paused at 98/164 — resumes in bench6.

## bench4 — 2026-08-29/30 ([state](bench4/state.md), [results](bench4/results.md))

- **LM Studio forensics** ([full report](bench4/lmstudio-forensics.md)):
  context length is NOT controllable for `google/gemma-4-12b` — every
  path ignored, auto-fit always 158,464 at wired limit 24000;
  `--parallel` works; thinking is always on (no toggle works);
  `--estimate-only` reports weights only and cannot be trusted.
- **New LM Studio ceiling criterion** (owner's decision): ceiling =
  onset of memory compression/swap in the watcher log; tok/s from the
  last clean step; context column keeps the auto-fit estimate. For
  Gemma-12B: onset between 65K and 74K, 29.29 tok/s at 65,094.
- **bonsai-prism 0.927/0.890** (4/164 empty) — the prism fork's q4 KV +
  calibration bias beats the plain MLX 2-bit score (0.915/0.884): the
  calibration does not cost quality.
- Gemma-12B thinking-on EvalPlus stopped at 54/164 (directional:
  0.741/0.722 among attempted, 13 empty) — resumes in bench5.

## bench3 — 2026-08-29 ([state](bench3/state.md), [results](bench3/results.md))

- **qwen36-think corrected: 0.939/0.921** (from the flawed 0.610) —
  the budget-calibration method fully recovers the bench1 damage.
- **gemma12-lmstudio thinking-off: 0.909/0.872, 0/164 empty** — and a
  16-problem A/B proved the run genuinely had thinking off.
- **gemma26-mlx thinking-on: 0.713/0.701 with 28% empty** — Gemma's
  thinking often fails to converge; the empty rate is a real model
  limit, not a harness artifact.
- LM Studio depth sweeps re-run watched: the earlier 7.08 tok/s crash
  at 98K did not reproduce; `/v1/completions` is broken on this build
  (chat endpoint only); the disk-backed prompt cache can force silent
  full recomputes at depth.

## bench2 — 2026-08-28 ([state](bench2/state.md), [results](bench2/results.md), [calibration](calibration.md))

- **The budget-calibration method** (10 fixed problems, 30K cap, budget
  = observed max × 1.5): qwen38-mlx-medium rose 0.970→**0.982** with 0
  empty; bonsai-think 0.640→**0.915/0.884** (5 genuinely empty — a true
  model ceiling).
- **Critical harness bug found and fixed**: EvalPlus hardcodes a 100 s
  `signal.alarm` + ~600 s client timeout, so long completions retried
  forever. Fixed in `run_codegen_wrapper.py` (plain retries, 7200 s).
- mlx_lm.server can crash one request on a Metal resource limit while
  staying "healthy" — the request hangs forever; restart and resume.

## bench1 — 2026-08-27 ([state](bench1/state.md), [results](bench1/results.md))

- **The max_tokens flaw discovered**: a fixed 3072 output budget lets
  reasoning exhaust the cap; empty completions score as failures (up to
  38% of scores lost). Every bench1 score is a lower bound; the
  calibration rule was born here.
- EvalPlus harness stood up, with the local patches that every later
  run reuses (`run_codegen_wrapper.py`: token budget, extra_body,
  None-content, no signal.alarm, macOS rlimit).
- The per-process firewall silently hangs fresh binaries' downloads —
  suspect it first for any new-process hang.
