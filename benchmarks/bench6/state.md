# Run 6 state

Prepared 2026-08-31 from what run 5 left open. Runbook: `AGENT.md`.
Note deviations here as they happen.

## Carried over from run 5

- Gemma-12B thinking-on EvalPlus paused at 98/164
  (`benchmarks/bench3/results/gemma12-lmstudio-thinking-on/`).
- Qwen3.8-27B effort low: no EvalPlus score yet.
- bonsai-off: not started.
- Qwen3.6-35B-A3B MTP drafter: broken on the brew build seen in run 5.

## Run log

### Block 1: Gemma-12B thinking-on EvalPlus resume — done

Consolidation before block 1: only `master` existed, no stray branches
or worktrees, GPU was idle. Created `run6` directly. Wired limit
confirmed at 24000.

Resumed from 98/164 with the identical command from `AGENT.md`. Reached
160/164 by 02:33, then task 161 ran an unusually long reasoning pass:
still generating at 02:49 (34+ min elapsed on one task, versus ~2-17 min
for prior tasks). Checked for a stall: `llmworker` process held steady
at 38-40% CPU across two 10s samples, no thermal warning
(`pmset -g therm`), swap at 230/1024 MB (not thrashing). Confirmed the
server itself was still responsive with a parallel small test request
(0.5s round trip). Treated as a genuinely slow reasoning trace near the
12000-token budget, not a crash, and kept waiting. Task 161 finished at
2675.80s of reasoning (~44.6 min); the run continued normally through
162-163. The last task, HumanEval/163, ran an equally long pass and
finished at 04:42:56. Both long passes were within the calibrated
budget and resolved on their own — no restart was needed.

Also noted: `benchmarks/mem-watch.sh` ignores `MEMWATCH_LOG` (always
writes `benchmarks/mem-watch.log`) and its logging cadence went
irregular (multi-minute gaps) during the heavy compute stretches,
consistent with system scheduling contention, not a watcher crash
(process stayed alive throughout).

Final result: 164/164 evaluated. pass@1 base 0.622, pass@1 plus 0.610,
61/164 empty completions (reasoning exhausted the 12000-token budget
without producing a completion) — a real, honestly-recorded empty
rate, not chased down further per the EvalPlus methodology page.
Recorded in `docs/setups/m1-max-32gb/models.json`
(`gemma12-lmstudio-think` row) and `results.md`; `npm run docs:tables`
run. LM Studio unloaded, mem-watch stopped.

### Block 2: Qwen3.8-27B, effort low, EvalPlus — in progress

**Deviation from `AGENT.md`'s literal serve command:** the installed
mlx-lm build (0.31.3) has no `--reasoning-effort` CLI flag. Used the
generic replacement instead:
```
mlx_lm.server --model mlx-community/Qwen3.8-27B-4bit \
  --chat-template-args '{"reasoning_effort":"low"}' \
  --prompt-cache-size 2 --port 8081
```
Also had to stop the LM Studio server (`lms server stop`) after block 1,
since it was still holding port 8081 even after unloading the model.

Verified low is real: on a fixed test prompt, low gave 656 completion
tokens / 987 reasoning chars vs medium's 930 / 1581 — clearly shorter.
Calibrated with `benchmarks/calibrate.py qwen38-mlx-low
mlx-community/Qwen3.8-27B-4bit
'{"chat_template_kwargs":{"reasoning_effort":"low"}}'`: max completion
2145 tokens across the 10 problems (one problem, HumanEval/10, took
619s wall time even at low effort). Budget = 2145 x 1.5 = 3217, below
the 8192 floor, so budget = 8192. Saved
`benchmarks/calibration-qwen38-mlx-low.json`.

Full run launched:
```
RESULTS_BASE=benchmarks/bench6/results EVALPLUS_MAX_NEW_TOKENS=8192 \
  benchmarks/run-humaneval.sh qwen38-mlx-low mlx-community/Qwen3.8-27B-4bit \
  '{"chat_template_kwargs":{"reasoning_effort":"low"}}'
```
Watcher: `benchmarks/mem-watch.sh` (writes to `benchmarks/mem-watch.log`
regardless of `MEMWATCH_LOG`). No swap or sustained compression the
whole run; one transient compression burst near the end, no swap.

Final result: 164/164 evaluated in ~1h (much faster than block 1 — low
effort keeps reasoning short). pass@1 base 0.976, pass@1 plus 0.927,
0/164 empty. Added `qwen38-mlx-low` row to
`docs/setups/m1-max-32gb/models.json` next to `qwen38-mlx-medium`,
speed/memory cells copied from the medium row and marked `stale` per
`AGENT.md` (no depth sweep this run — see the owner's planning note
above and in `benchmarks/INDEX.md`). `npm run docs:tables` run.

### Block 3: bonsai-off (Ternary Bonsai-27B MLX, thinking off) — in progress

Killed the block-2 `mlx_lm.server` (Qwen3.8-27B) and started:
```
mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit \
  --prompt-cache-size 2 --port 8081
```
Verified the `enable_thinking:false` toggle works: with thinking on,
500 completion tokens / 1964 reasoning chars on a test prompt; with
`{"chat_template_kwargs":{"enable_thinking":false}}`, 123 completion
tokens / 0 reasoning chars, no `<think>` tag in content. Toggle is
real. Calibrated with `benchmarks/calibrate.py bonsai-off
prism-ml/Ternary-Bonsai-27B-mlx-2bit
'{"chat_template_kwargs":{"enable_thinking":false}}'` (a fresh budget,
not reusing the 10240 thinking-on figure).

One calibration problem, HumanEval/76, hit the 30000-token cap without
converging (`finish_reason: length`, took 1372s) even with thinking
off — a genuine non-convergence case, not a harness artifact (server
stayed responsive throughout: sustained 37-46% CPU, live response to a
parallel test request). The other 9 problems all finished normally
(88-662 completion tokens, 4-30s each). Per the EvalPlus methodology's
non-convergence rule, used the longest *successful* completion (662,
HumanEval/124) rather than the capped one for the budget calc:
662 x 1.5 = 993, still below the 8192 floor, so budget = 8192. Expect
and record a real non-zero empty rate for this config; not chasing it
with a larger budget.

Full run finished fast (~46 min codegen + eval — much faster than
blocks 1-2, this model/config decodes quickly). No swap the whole run,
plenty of free memory throughout. Final result: 164/164 evaluated,
pass@1 base 0.927, pass@1 plus 0.902, 0/164 empty — HumanEval/76
(the one calibration problem that didn't converge at 30000 tokens)
converged fine within the 8192 budget on this pass, so the expected
non-zero empty rate did not materialize; recorded honestly either way.
Added `bonsai-mlx-off` row to `docs/setups/m1-max-32gb/models.json`
next to `bonsai-mlx`, speed/memory copied from that row and marked
`stale` (no depth sweep this run). `npm run docs:tables` run.

**Block 3 is the last EvalPlus block in this run's plan.** Once block 4
(the non-scoring MTP drafter re-check) is done, bench6 is complete.

**Owner's planning note (2026-09-01):** the owner considers it a
planning miss that bench6 scores EvalPlus for `qwen38-mlx-low` and
`bonsai-mlx-off` (block 3) without a tok/s depth sweep first, ahead of
the usual memory-ceiling -> depth-curve -> quality order. Keeping
bench6's plan as written (AGENT.md explicitly defers these two
sweeps and marks the copied speed/memory fields `stale`), but bench7
should do the sweep for both configs. Cross-referenced in
`benchmarks/INDEX.md` under bench6 for bench7 planning.
