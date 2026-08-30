# Benchmark runs — findings index

One entry per run: the most interesting findings and conclusions, with
links to the full record. Newest first. Each `benchN/` folder holds that
run's runbook (`AGENT.md`), log (`state.md`), results (`results.md`,
`results/`). General tools shared by all runs live in this folder
(`run-humaneval.sh`, `run_codegen_wrapper.py`, `calibrate.py`,
`mem-watch.sh`, `calibration-*.json`).

## bench5 — planned

- Runbook: [bench5/AGENT.md](bench5/AGENT.md). Finish the Gemma-12B
  thinking-on EvalPlus, Qwen3.8-27B thinking low, bonsai-off, the
  Mendel benchmark (before polyglot), then Aider polyglot.

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
