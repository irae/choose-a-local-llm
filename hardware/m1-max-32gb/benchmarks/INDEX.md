# Findings by benchmark run

One entry per run: the most interesting findings and conclusions, with
links to the full record. Newest first. Each `benchN/` folder holds that
run's runbook (`AGENT.md`), log (`state.md`), and results (`results.md`,
`results/`). General tools shared by all runs live in this folder
(`run-humaneval.sh`, `run_codegen_wrapper.py`, `calibrate.py`,
`mem-watch.sh`, `calibration-*.json`).

## bench12, 2026-09-07 to 2026-09-09 ([state](bench12/state.md), [results](bench12/results.md))

- Runbook: [bench12/AGENT.md](bench12/AGENT.md). The three Qwen3.8
  3-bit builds from research run 3 scored on the full gate, the 4-bit
  control re-measured at wired 25000, Gemma-12B on two slots, and the
  Bonsai fork at f16 KV. Every Qwen3.8 block ran at effort medium,
  inherited from the control row; medium is banned for this model from
  2026-09-09 and these rows keep their numbers with no re-run.
- **A `-c` that loads is not a window.** Two Gemma-12B slots load at
  `-c 770048` and serve a short completion, and that config's own creep
  stopped on swap at 16K. Judged by the creep, the per-slot ceiling is
  81958 at every `-c` from 221184 up; `-c 196608` runs that depth clean.
  The ladder rule in `benchmarks/PLANNING.md` still reads the other way.
- **The Bonsai fork's floor was the cache type.** At f16 KV with no
  drafter the fork ran clean to `-c 131072` at 9.67 tok/s, 18.3 GB
  flat, zero swap; at q4_0 KV it floors at 33K. Its guided agent row at
  f16 scored 12.5 capped, one library in 195 minutes.
- **Both 3-bit builds pass the gate with their own scores.** ISTA
  IQ3_S-mtp 0.976 / 0.945, one empty; AtomicChat AD-IQ3_S 0.988 / 0.927,
  none. The 4-bit control still carries the MLX score and has no full
  run of its own.
- **Three bits cost no measurable agent score, on one comparison.** The
  4-bit control re-run at the 8192 reserve on a 65536 window scored 76
  and failed trap A, below the published 87 at reserve 16384; the ISTA
  build scored 76.5 on a 114688 window and failed trap A the same way.
  AtomicChat ended on a repetition loop after three libraries, 37.5
  capped; the loop is the model's own, so the row is a valid partial.
- **The wired limit question closed at 25000.** Swap growth at 25000
  appeared only under back-to-back sweeps on one long-lived server;
  every single-sweep creep on a fresh server, at both KV types, came
  back clean. The 4-bit control serves `-c 73728` at 25000 and creeps
  clean to 65578.
- **Two tool gaps.** `score.mjs` reported trap A as passed while its
  own captured output said the repro threw; `loop-check.py`'s 60-line
  window diluted a five-call repetition to a clean ratio that pi's own
  live detector caught. Both are filed, neither fixed mid-run.
- **A run-time loop guard with an empty-output bug** voided one ISTA
  attempt in seconds; fixed and retried under a fresh alias, since the
  worker derives the branch and the row's model field from the pi id.

## research run 3, 2026-09-07 to 2026-09-08 ([index](../research/run3/index.md), [state](../research/run3/state.md), [results](../research/run3/results.md))

- The Qwen3.8 3-bit candidates, the drafter question, the compaction
  ladder and the projector strip pairs, all at wired 25000, GGUF only,
  research stopping at the two smokes.
- **The drafter is a trade against depth.** The unsloth UD-Q3_K_XL
  build mem-stopped at 49198 with its drafter and ran clean past
  131072, the list's end, without it, at 13.95 against 13.55 tok/s
  shallow and 8.58 against 9.14 deep, with wired 2 GB lower and the
  swap delta negative the whole way.
- **A list end is not a ceiling.** Three of five creeps never hit a stop
  condition; their depth is a floor under the true ceiling. The depth
  list had to grow before the next run.
- **All three 3-bit builds pass both smokes level with the control.**
  ISTA IQ3_S-mtp was the only measured ceiling of the three, 114718 at
  9.67 tok/s, a swap stop at 131098. Effort low and xhigh on the control
  row both pass the Mendel smoke clean, so the level is not a
  robustness lever on this task; only a scored run separates them.
- **The compaction ladder reads Gemma-12B only.** Its `contextWindow`
  floor on `xtend-wide` is 23552, the first rung with two clean passes.
  Gemma-26B found no floor: both runs at the first rung ended with the
  model believing the task done and no commit, with compaction never
  firing. Qwen3.8 is too token-efficient at that task to reach a rung.
  Bonsai MLX was skipped for want of the MLX margin rule's window.
- **The projector costs memory only, already taken.** Wired deltas of
  1175 MB on Qwen3.8 and 1196 MB on Qwen3.6, at or above the file size,
  with speed unchanged; the Qwen3.8 projector's Metal compute-buffer
  cost is 247 MB. Gemma-26B with its projector OOMs at the row's own
  `-c 212992` and loads one 8192 step below it. `--offline` on an
  uncached projector fails silent, not loud.
- **Gemma-26B without its drafter** ran clean to 196618, the list's end,
  at 18.57 tok/s and 23.9 GB, about 1.7 GB under the with-drafter row.

## bench11, 2026-09-06 to 2026-09-07 ([state](bench11/state.md), [results](bench11/results.md), [report](bench11/report.md))

- Runbook: [bench11/AGENT.md](bench11/AGENT.md). Every missing Mendel
  row at the trial wired limit 25000, opened by a Qwen3.6 depth creep
  that decided where its own Mendel pair ran.
- **The harness window decides the score.** Qwen3.6 GGUF guided at
  thinking off scored 46.5 on a 49152-token window with twelve
  compactions, and 62.5 on the 81920-token window its own creep
  supports. The runbook had frozen the smaller window; the rule that
  measured parameters come from the newest measurement
  (`docs/methodology/common-rules.md`, rule 10) came out of this.
- **Qwen3.6 GGUF is not an 8K model.** At 25000 it serves `-c 98304`
  and creeps to 81958 tokens at 9.24 tok/s. The ceiling is sharp:
  98304 serves a real completion, 100864 loads and fails the first
  one. Its f16 KV build now loads at `-c 40960`; it did not at 24000.
- **Gemma-26B fails at thinking off.** Both thinking-off rows ended on
  five identical edit calls, caught by the live loop stop in under
  half an hour each. Its thinking-on guided row completed 7 of 8 at 57.
- **Gemma-12B GGUF cannot drive the agent task**: 24 of 28 edit calls
  carried the same malformed tool shape, zero commits.
- **A background macOS service ended two runs.** The media analysis
  daemon drove free memory under 100 MB while the server held 25 GB
  wired; one killed attempt held 8 of 8 commits and its branch was
  deleted before scoring. The no-cleanup-mid-run rule came out of this.
- **The 300-minute wall clock cap was not a stop**: the abort never
  settled the turn and block 8 ran 469 minutes. The runner now kills pi
  five minutes after an ignored abort.
- **A missing pi entry cost two blocks.** Qwen3.6 MLX had no harness
  entry, so blocks 6 and 7 did not run. A missing entry is no longer a
  skip; the runner creates it from the block's parameter table.

## bench10, 2026-09-05 to 2026-09-06 ([state](bench10/state.md), [results](bench10/results.md))

- Runbook: [bench10/AGENT.md](bench10/AGENT.md). The three curves the
  site still read `pending` on, a first Mendel smoke against a real
  server, the f16 re-scores on Gemma-26B and Qwen3.6, and two Mendel
  blind rows on GGUF quants.
- **Every `pending` cell on the site now has a real number.** Gemma-12B
  4-slot and Gemma-26B 2-slot both moved from q8_0 to f16 like their
  single-slot siblings; the LM Studio Gemma-12B row's wired memory at
  its ceiling is 17249 MB. All three published `-c` values failed to
  load; each was binary-searched down and verified with a real
  4096-token completion, not a trivial warmup — a trivial warmup passed
  and then OOM'd on compute buffers on both Gemma-12B 4-slot and
  Gemma-26B 2-slot before this check went in.
- **Gemma-26B 2-slot hit a window verdict, not mem or speed.** The
  search-bound `-c` (202752, 101376/slot) ran out before speed or
  memory did; the reported ceiling, depth 81958 at 33.56 tok/s, is a
  hardware ceiling from the load search, not an early stop.
- **The GGUF f16 build beats the MLX build on Gemma-26B EvalPlus, both
  thinking modes.** Thinking on: 0.884/0.860/89% against the MLX
  build's 0.713/0.701/72%, the same non-convergence problem but fewer
  empties (18/164 against 46/164). Thinking off, never scored before:
  0.976/0.945/100%, 0 empty.
- **Qwen3.6 thinking off also beats its thinking-on sibling**:
  0.951/0.915/100%, 0 empty, against 0.939/0.921/97%.
- **Qwen3.8 GGUF at f16 clears the Mendel blind bar the MLX build never
  reached.** 87/100, all 8 libraries, no bug defect — the first local
  model to finish this agent task with a fully valid score, on
  llama-server where the MLX build only ever scored a partial run.
- **Gemma-26B GGUF blind (thinking high): 47.5/100, 8/8 libraries**,
  one critical trap hit, against the old q8_0 run's 38/100 partial.
- **Bonsai's guided config failed twice for two different reasons.**
  The first attempt was a harness fault (a dead `gh` token, an
  interactive login loop the prompt forbids); once the owner fixed
  `gh` auth, the no-penalty retry got stuck in an 85-call identical
  bash loop instead and was stopped by hand. Both rows are invalid; the
  owner is holding on a third attempt. The worktree
  (`../mendel-bench-guided-prism-ml-Ternary-Bonsai-27B-mlx-2bit-off`) is
  kept for inspection.
- **A coverage gap found mid-run: Gemma-26B had no Mendel row at
  thinking off.** The owner added a smoke (passed) and started the
  guided run, then moved the whole four-combination gap (on/off ×
  guided/blind) to run 11 for a clean pass. The same gap likely exists
  for Qwen3.6, flagged and not acted on: its real ceiling after the
  run 9 compaction correction is only 8222 tokens.
- **Qwen3.8 GGUF effort medium (block F3) deferred to run 11** at the
  owner's request.
- **The new run watcher did not fully match the sunset scripts.** One
  mismatch, on Block C's EvalPlus run (a false `SERVER DEAD` from the
  sunset liveness watcher on a probe queued behind a live turn); every
  Mendel run after that matched cleanly. The mismatch was the old
  script's false alarm, and the new watcher was right every time, so
  `sunset/` was deleted after the run; its logs are under
  `bench10/results/sunset-logs/`.

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

## research run 2, 2026-09-04 ([state](../research/run2/state.md), [results](../research/run2/results.md))

- The Gemma-12B loop, the Gemma-4 chat templates, the KV type and the
  drafter on llama.cpp, and the detectors the loop needed.
- **Two LM Studio entries were one model on the site.** The good
  Gemma-12B score came from an entry with thinking off that cannot be
  turned on; all three Mendel rows came from another entry, gone from
  the store. The owner ruled Gemma-12B on MLX or LM Studio out for
  thinking-on agent work; GGUF stays. Usable configuration: llama-server,
  f16 KV, no MTP, thinking off, to the trained window above the floor.
- **The fixed chat template does not prevent the thought loop.** Post-fix
  arms looped one of two; pre-fix arms looped three of three. Every
  local MLX container ships the template Google replaced on 2026-07-15.
- **DRY hides the repetition loop instead of stopping it**: 1133
  shape-identical lines inside one tool call, every path corrupted, read
  as clean by every exact-match detector. A near-duplicate detector that
  normalises letters and digits separates the arms.
- **The KV type is not the speed gap on Gemma-12B**, f16 beats q8_0 by
  the page's own estimate; the py gap against the published number is
  drafter acceptance, which no published row records.
- **The Qwen3.8 MLX window arithmetic cannot hold**: `maxTokens` 16384
  and `contextWindow` 26624 fail past a 10240-token prompt; 8192 was
  proposed and later adopted as the harness reserve.

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

## bench2, 2026-08-28 ([state](bench2/state.md), [results](bench2/results.md), [calibration](../../../benchmarks/calibration.md))

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
