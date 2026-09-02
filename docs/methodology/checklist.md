# The bench run checklist

Follow this loop for EVERY benchmark, sweep, or scoring run. Agents skip
steps when the procedure is prose; this page is the checklist. The "why"
lives in [common rules](./common-rules.md) and
[server lore](./server-lore.md) — do not re-derive it here.

## Before the run

1. Branch locally for the run (for example `run6`) in a fresh sibling
   worktree; the main worktree stays with the coordinator. Never push
   the run branch. When the owner asks to stop and merge, follow the
   stop-and-sync steps in `AGENTS.md`: merge to `master`, push
   `master`, delete the branch, remove the worktree.
2. Check the GPU is free: `pgrep -fl "llama-server|mlx_lm"` and
   `~/.cache/lm-studio/bin/lms ps`. Stop leftovers.
3. Check `sysctl iogpu.wired_limit_mb` is the documented limit (24000).
4. Close background apps.
5. Start the server for ONE config. Verify it serves (warmup request).
   LM Studio: load explicitly with `lms load`, verify with `lms ps` —
   never trust JIT ([server lore](./server-lore.md)).
6. Start the memory watcher, scoped to this run only:
   `MEMWATCH_LOG=/tmp/<run>-memwatch.log MEMWATCH_INTERVAL=20
   bash tools/sweeps/mem-watch-fast.sh &` (or `benchmarks/mem-watch.sh`
   for long scoring runs). A run without the watcher is invalid.

## During the run

7. **Set the idle/silent-crash monitor.** Schedule a wakeup ≤20 minutes
   after starting any block. At every wakeup verify REAL output growth
   (result-file line count, not process liveness) — servers can die or
   hang while the process lives and `/health` returns 200. If output
   stopped: read the server log for the death signatures before blaming
   the model, restart, resume. Every wakeup ends with a new wakeup or
   with the shutdown steps below. The GPU never sits idle between
   blocks.
8. Heartbeat format: "Block N (model): done X/Y, [num]h[num]min left."
9. Note deviations in the run's `state.md` AS THEY HAPPEN, not at the
   end. Smallest fix, fairness first, suspect the harness before the
   model.

## After the run

10. Stop the watcher immediately. Stop one-shot monitors as soon as
    they fire — never leave them running.
11. Record the result on EVERY surface in the same pass
    ([common rules](./common-rules.md), rule "record everywhere"):
    benchmarks page, report page (including its summary line),
    `comparison.md`, `models.json` + `node tools/gen-tables.mjs`,
    harness config. Update `benchmarks/bench<N>/results.md` and
    `state.md`.
12. Commit before moving to the next block.
13. Clean up: `pgrep -fl "llama-server|mlx_lm"`, `lms ps`, kill strays,
    no background task holding the GPU. End the session with the
    machine idle.
