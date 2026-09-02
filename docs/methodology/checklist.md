# The bench run checklist

Follow this loop for EVERY benchmark, sweep, or scoring run. Agents skip
steps when the procedure is prose; this page is the checklist. The "why"
lives in [common rules](./common-rules.md) and
[server lore](./server-lore.md) — do not re-derive it here.

## Before the run

1. **Leave the main worktree BEFORE any other action.** Run these
   commands, in this repo and in `../mendel` when the run touches it:
   1. `git worktree add ../choose-a-local-llm-run<N> -b run<N>`
   2. `cd ../choose-a-local-llm-run<N>`
   3. Verify: `git worktree list` shows your new worktree, and `pwd`
      is inside it. Every later command of the run happens there.
   The main worktree stays with the coordinator. Never reuse an old
   worktree. Never push the run branch. When the owner asks to stop
   and merge, follow the stop-and-sync steps in `AGENTS.md`: merge to
   `master`, push `master`, delete the branch, remove the worktree.
2. Never run a bare `git stash`. The stash list is shared across all
   worktrees, so parallel agents clobber each other. Save work in
   progress as a WIP commit on your run branch instead. If a stash is
   unavoidable, name it (`git stash push -m "run<N>: <what>"`) and
   apply or pop it by that name only (`git stash pop
   'stash^{/run<N>}'`) — never `stash@{0}`.
3. Check the GPU is free: `pgrep -fl "llama-server|mlx_lm"` and
   `~/.cache/lm-studio/bin/lms ps`. Stop leftovers.
4. Check `sysctl iogpu.wired_limit_mb` is the documented limit (24000).
5. Close background apps.
6. Start the server for ONE config. Verify it serves (warmup request).
   LM Studio: load explicitly with `lms load`, verify with `lms ps` —
   never trust JIT ([server lore](./server-lore.md)).
7. Start the memory watcher, scoped to this run only:
   `MEMWATCH_LOG=/tmp/<run>-memwatch.log MEMWATCH_INTERVAL=20
   bash tools/sweeps/mem-watch-fast.sh &` (or `benchmarks/mem-watch.sh`
   for long scoring runs). A run without the watcher is invalid.

## During the run

8. **Set the idle/silent-crash monitor.** Schedule a wakeup ≤20 minutes
   after starting any block. At every wakeup verify REAL output growth
   (result-file line count, not process liveness) — servers can die or
   hang while the process lives and `/health` returns 200. If output
   stopped: read the server log for the death signatures before blaming
   the model, restart, resume. Every wakeup ends with a new wakeup or
   with the shutdown steps below. The GPU never sits idle between
   blocks.
9. Heartbeat format: "Block N (model): done X/Y, [num]h[num]min left."
10. Note deviations in the run's `state.md` AS THEY HAPPEN, not at the
   end. Smallest fix, fairness first, suspect the harness before the
   model.

## After the run

11. Stop the watcher immediately. Stop one-shot monitors as soon as
    they fire — never leave them running.
12. Record the result on EVERY surface in the same pass
    ([common rules](./common-rules.md), rule "record everywhere"):
    benchmarks page, report page (including its summary line),
    `comparison.md`, `models.json` + `node tools/gen-tables.mjs`,
    harness config. Update `benchmarks/bench<N>/results.md` and
    `state.md`.
13. Commit before moving to the next block.
14. Clean up: `pgrep -fl "llama-server|mlx_lm"`, `lms ps`, kill strays,
    no background task holding the GPU. End the session with the
    machine idle.
