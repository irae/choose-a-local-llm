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
