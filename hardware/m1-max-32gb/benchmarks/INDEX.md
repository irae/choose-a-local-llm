# Findings by benchmark run

One entry per run: the most interesting findings and conclusions, with
links to the full record. Newest first. Each `benchN/` folder holds that
run's runbook (`AGENT.md`), log (`state.md`), and results (`results.md`,
`results/`). General tools shared by all runs live in this folder
(`run-humaneval.sh`, `run_codegen_wrapper.py`, `calibrate.py`,
`mem-watch.sh`, `calibration-*.json`).

## bench9, 2026-09-04 to 2026-09-05 ([state](bench9/state.md), [results](bench9/results.md))

- Runbook: [bench9/AGENT.md](bench9/AGENT.md). The KV cache type per
  GGUF model, the slow creep at the pick, the first EvalPlus smoke as a
  gate, the GGUF Gemma-12B scored, one Mendel row, one invalid block.
- **The KV pick moved two models to f16 and left one at q8_0.** Qwen3.8
  GGUF: q8_0 read 7.1 tok/s at 32K, f16 16.4, same memory. Gemma-26B
  GGUF: q8_0 6.3, f16 45.9. Qwen3.6 GGUF: f16 does not load at 40960,
  q8_0 stays.
- **Every published `-c` OOMs at load under the 24000 limit.** The
  largest `-c` that loads is a hardware ceiling and is recorded as one:
  Qwen3.8 49152 (f16), Gemma-26B 212992 (f16), Qwen3.6 49152 (q8_0).
  A server can report "loaded" and answer every request with a 500;
  every `-c` candidate is verified with one real completion.
- **A window verdict at an undersized `-c` is not a finding.** Two creeps
  were redone toward the trained context with the prefill jump from a
  control point; the control points landed within 0.2% and 0.5% of the
  slow readings.
- **Gemma-26B GGUF at f16 holds 17.3 tok/s at 197K**, from 8 tok/s at
  24K before. Back in the running as a secondary model; the EvalPlus
  re-score at f16 is a run 10 item.
- **Qwen3.6 GGUF's deep-context claim did not survive the slow creep.**
  At `-c 49152` wired sits at 25 GB and compaction starts by 16K; the
  last clean row is 8K at 43.8 tok/s. The 90K figure was the fast sweep.
- **The smoke passed its self-check and read LEVEL on both f16 picks.**
  Gemma-26B fails the same hard problem at both types.
- **Quants do not always share a score.** Gemma-12B GGUF Q4_K_XL thinking
  off scored 0.976/0.939, 0 empty, against the LM Studio MLX 4-bit's
  0.909/0.872. The shared-score rule now carries that exception.
- **Gemma-12B GGUF f16, no drafter, Mendel guided thinking off:** 3 of 8
  libraries, 37.5 capped, model budget exhausted after three nudges,
  the same signature as the LM Studio entry's high run.
- **Qwen3.8 MLX guided low is invalid after three attempts.** The
  `maxTokens` fix works, but the context grows past the 26624 window
  in agentic use and Metal OOMs the generation thread while `/health`
  stays 200. Open problem: a smaller window or an earlier compaction.
- **Bonsai Mendel thinking off (block C) was deferred to run 10.**

## research run 1, 2026-09-03 ([state](../research/run1/state.md), [results](../research/run1/results/))

Research, not a benchmark: no scored rows produced. Runbook:
[research/run1/AGENT.md](../research/run1/AGENT.md).

- **There is no idle memory baseline.** The same idle Mac, same apps not
  running, measured 12415 MB and 25219 MB free. A scheduled XProtect
  scan took 1 GB of it unprompted. So a pre-run gate cannot compare
  against a remembered number; it has to measure current state. Goal 0
  closed with a cold-start sequence instead of a threshold.
- **Wired is the only counter that cannot lie.** Free and active move
  for reasons unrelated to a run, and the compressor can inflate an
  allocation total until it is fiction: an early probe filled blocks
  with a repeated value and "allocated" 35840 MB on a 32 GB machine.
- **macOS degrades instead of failing.** Asked for memory too fast, it
  compresses, then swaps, then keeps going: 27 GB compressor and 8 GB
  swap with no error. A sweep can therefore keep running and report
  throughput that measures the swap file.
- **A kernel panic that was not an OOM.** `IOGPUMemory.cpp:492`,
  `IOGPUFamily`, panicking task `node`, with the panic log's own
  accounting showing memory fine. Check
  `/Library/Logs/DiagnosticReports/*.panic` before you call any lost
  run an OOM.
- **The build does not break the MTP drafter.** Same brew build and
  the vetted gemma command at 8192 context: the drafter allocates, 51%
  draft acceptance. The failure is conditional on context and
  pressure, which fits `-ngl 999` disabling llama.cpp's memory fitting.
- **The Gemma-12B newline flood is a broken control token.** Two of the
  three floods contain only newlines and `<|channel>`, a malformed
  marker. Not a repetition loop. Lengths land within 1.6% across three
  runs, so something caps the block.
- **The Qwen3.8 26624 window is ours.** `mlx_lm.server` has no context
  cap at all; the number lives in pi's model entry. Its `maxTokens`
  16384 cannot coexist with it past a ~10K prompt, which explains three
  premature length stops.
- **LM Studio cannot serve without Electron, and any `lms` command
  revives the whole stack**, so a status check can put a second process
  on the GPU during someone else's run.
- **Two compaction counts were wrong** and are fixed in the mendel repo:
  pi writes a `compaction` record for a split turn too.
- **Nine of seventeen local Mendel rows have no session log.** They were
  gitignored and went with their worktrees. Evidence now goes to
  `~/.local/share/choose-a-local-llm/evidence/`.

## bench8, 2026-09-02 ([state](bench8/state.md))

- Runbook: [bench8/AGENT.md](bench8/AGENT.md). API-model Mendel re-runs
  on the Linux box, through pi (no GPU work). Blind v1.1 for the
  strong models, guided v3.0 plus blind for the cheap probe
  (deepseek-v4-flash-0731) and the strong reference (gpt-5.6-luna),
  plus two Anthropic models added mid-run once login/budget arrived
  (`claude-haiku-4-5`, `claude-sonnet-4-5`) and a new fireworks model
  (`glm-5p3-flash`). Up to two runs ran in parallel, never two on the
  same account.
- Scores: deepseek-v4-flash-0731 guided 97, blind 84.5; kimi-k3
  blind 93.5; deepseek-v4-pro-0813 blind 79; grok-4.6 blind 92.5;
  gpt-5.6-luna guided 88.5, blind 83.5; gpt-5.6-sol blind 92;
  glm-5p3-flash blind 75, guided 98; claude-haiku-4-5 guided 76, blind
  34; claude-sonnet-4-5 blind 43.5.
- **Anthropic models scored below their reputation on this task.**
  claude-haiku-4-5 and claude-sonnet-4-5 both hit trap A (the
  `fs.promises.glob()` AsyncIterator trap) on their blind runs, and
  neither removed the root `rimraf`/`tmp` devDependencies at all;
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

## bench6, 2026-09-01 ([state](bench6/state.md), [results](bench6/results.md))

- Runbook: [bench6/AGENT.md](bench6/AGENT.md). EvalPlus only: finished
  the Gemma-12B thinking-on run (0.622/0.610, resumed from 98/164),
  Qwen3.8-27B effort low (0.976/0.927), bonsai-off (0.927/0.902).
  **Block 4 (Qwen3.6-35B-A3B MTP drafter re-check) deferred to run 7**
  (owner's decision, 2026-09-01); run 6 closes after block 3. Mendel
  and Aider polyglot also move to run 7.
- **Planning note for bench7 (owner's call, 2026-09-01).** bench6
  scored EvalPlus for two new configs (Qwen3.8-27B effort low,
  bonsai-off) without a tok/s depth sweep first; the site rows carry
  stale speed/memory cells copied from a sibling config instead. The
  owner considers this a planning miss (the usual order is memory
  ceiling, then depth curve, then quality gate) but keeps bench6's plan
  as is, since it is still a valid EvalPlus-only run. For bench7:
  schedule the depth/tok-s sweep for both `qwen38-mlx-low` and
  `bonsai-mlx-off` before, or instead of, treating their `stale`
  speed/memory fields as settled.

## bench5, 2026-08-30/31 ([state](bench5/state.md))

- **Bonsai fork depth sweeps** (`bonsai-fork-single`, `bonsai-fork-2x`):
  speed floor 33K used tokens at 7.9 / 7.8 tok/s, 9.6 / 10.9 GB RSS, no
  compression or swap. † markers cleared.
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
- Gemma-12B thinking-on EvalPlus paused at 98/164; resumes in bench6.

## bench4, 2026-08-29/30 ([state](bench4/state.md), [results](bench4/results.md))

- **LM Studio forensics** ([full report](bench4/lmstudio-forensics.md)):
  context length is not controllable for `google/gemma-4-12b`. Every
  path ignored, auto-fit always 158,464 at wired limit 24000;
  `--parallel` works; thinking is always on (no toggle works);
  `--estimate-only` reports weights only and cannot be trusted.
- **New LM Studio ceiling criterion** (owner's decision): ceiling =
  onset of memory compression/swap in the watcher log; tok/s from the
  last clean step; context column keeps the auto-fit estimate. For
  Gemma-12B: onset between 65K and 74K, 29.29 tok/s at 65,094.
- **bonsai-prism 0.927/0.890** (4/164 empty): the prism fork's q4 KV +
  calibration bias beats the plain MLX 2-bit score (0.915/0.884). The
  calibration does not cost quality.
- Gemma-12B thinking-on EvalPlus stopped at 54/164 (directional:
  0.741/0.722 among attempted, 13 empty); resumes in bench5.

## bench3, 2026-08-29 ([state](bench3/state.md), [results](bench3/results.md))

- **qwen36-think corrected: 0.939/0.921** (from the flawed 0.610). The
  budget-calibration method fully recovers the bench1 damage.
- **gemma12-lmstudio thinking-off: 0.909/0.872, 0/164 empty**, and a
  16-problem A/B proved the run had thinking off.
- **gemma26-mlx thinking-on: 0.713/0.701 with 28% empty.** Gemma's
  thinking often fails to converge; the empty rate is a real model
  limit, not a harness artifact.
- LM Studio depth sweeps re-run watched: the earlier 7.08 tok/s crash
  at 98K did not reproduce; `/v1/completions` is broken on this build
  (chat endpoint only); the disk-backed prompt cache can force silent
  full recomputes at depth.

## bench2, 2026-08-28 ([state](bench2/state.md), [results](bench2/results.md), [calibration](calibration.md))

- **The budget-calibration method** (10 fixed problems, 30K cap, budget
  = observed max × 1.5): qwen38-mlx-medium rose 0.970→**0.982** with 0
  empty; bonsai-think 0.640→**0.915/0.884** (5 empty, a true model
  ceiling).
- **Harness bug found and fixed**: EvalPlus hardcodes a 100 s
  `signal.alarm` + ~600 s client timeout, so long completions retried
  forever. Fixed in `run_codegen_wrapper.py` (plain retries, 7200 s).
- mlx_lm.server can crash one request on a Metal resource limit while
  it stays "healthy"; the request hangs forever. Restart and resume.

## bench1, 2026-08-27 ([state](bench1/state.md), [results](bench1/results.md))

- **The max_tokens flaw discovered**: a fixed 3072 output budget lets
  reasoning exhaust the cap; empty completions score as failures (up to
  38% of scores lost). Every bench1 score is a lower bound; the
  calibration rule was born here.
- EvalPlus harness stood up, with the local patches that every later
  run reuses (`run_codegen_wrapper.py`: token budget, extra_body,
  None-content, no signal.alarm, macOS rlimit).
- The per-process firewall silently hangs fresh binaries' downloads;
  suspect it first for any new-process hang.
