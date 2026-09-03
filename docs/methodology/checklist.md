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
   Bash and `cd` are correct here. A benchmark run is long and
   unattended, so nothing needs to watch it. Research and planning
   work is the opposite case and uses the `EnterWorktree` tool
   instead — see `AGENTS.md`, standing rules.
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
   **Unloading the model is not enough.** Quit the LM Studio app too
   (`osascript -e 'quit app "LM Studio"'`), and confirm the menu bar
   item is gone. The app keeps its MLX runtime host alive after `lms
   unload`, so a leftover app puts an MLX process on the GPU during a
   run you believe is pure llama.cpp.
4. Check `sysctl iogpu.wired_limit_mb` is the documented limit (24000).
   **It resets to 0 on every reboot**, and 0 means the system default,
   not "no limit". Set it before you read any memory number, because
   the ceiling you measure depends on it:
   `sudo sysctl iogpu.wired_limit_mb=24000`.
5. Close background apps, then check the machine has settled. Do not
   trust one reading of free memory — it moves by more than a gigabyte
   on an idle machine while scheduled work runs. Sample it more than
   once and require the samples to agree. Read `Pages wired down` as
   well: wired memory is never compressed and never swapped, so it is
   the counter that tracks a GPU allocation honestly, while free and
   active move for reasons that have nothing to do with the run.
   Background work that can start on its own timetable and spike a run:
   Time Machine (`backupd`), Spotlight (`mds_stores`), Photos analysis
   (`photoanalysisd`, `mediaanalysisd`), iCloud sync (`bird`, `cloudd`),
   the malware scan (`XProtect`), Mail (`maild`, `icloudmailagent` —
   these stay resident after the app quits), and any backup agent.
6. Do NOT download any model. All models are already in the cache, in
   the exact tested revision and quant. A missing model means STOP and
   ask the owner ([common rules](./common-rules.md)).
7. Start the server for ONE config. Verify it serves (warmup request).
   LM Studio: load explicitly with `lms load`, verify with `lms ps` —
   never trust JIT ([server lore](./server-lore.md)).
8. Start the memory watcher, scoped to this run only:
   `MEMWATCH_LOG=/tmp/<run>-memwatch.log MEMWATCH_INTERVAL=20
   bash tools/sweeps/mem-watch-fast.sh &` (or `benchmarks/mem-watch.sh`
   for long scoring runs). A run without the watcher is invalid.

## During the run

9. **Set the idle/silent-crash monitor.** Schedule a wakeup ≤20 minutes
   after starting any block. At every wakeup verify REAL output growth
   (result-file line count, not process liveness) — servers can die or
   hang while the process lives and `/health` returns 200. If output
   stopped: read the server log for the death signatures before blaming
   the model, restart, resume. Every wakeup ends with a new wakeup or
   with the shutdown steps below. The GPU never sits idle between
   blocks.
10. Heartbeat format: "Block N (model): done X/Y, [num]h[num]min left."
11. Note deviations in the run's `state.md` AS THEY HAPPEN, not at the
   end. Smallest fix, fairness first, suspect the harness before the
   model.

## After the run

12. Stop the watcher immediately. Stop one-shot monitors as soon as
    they fire — never leave them running.
13. Record the result on EVERY surface in the same pass
    ([common rules](./common-rules.md), rule "record everywhere"):
    benchmarks page, report page (including its summary line),
    `comparison.md`, `models.json` + `node tools/gen-tables.mjs`,
    harness config. Update `benchmarks/bench<N>/results.md` and
    `state.md`.
14. Commit before moving to the next block.
15. After stopping any server above ~15 GB RSS, wait for memory to
    RECOVER before loading the next model or starting a sweep: poll
    `vm_stat` (or the memwatch log) until free memory returns to the
    idle baseline. Process death is not memory recovery — a sweep
    started ~3 min after killing a 23 GB server ran the whole window
    with 60-220 MB free and continuous swap-ins, and OOMed
    ([server lore](./server-lore.md)).
16. Clean up: `pgrep -fl "llama-server|mlx_lm"`, `lms ps`, kill strays,
    no background task holding the GPU. End the session with the
    machine idle.
