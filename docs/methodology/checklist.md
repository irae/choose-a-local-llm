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
4. **Run the cold-start sequence, in this order.** This is the whole
   of run preparation. It does not aim at a clean machine, which does
   not exist — it aims at the SAME machine every time. Read
   [memory ceiling](./memory-ceiling.md) for why each step is here.
   1. `tools/mac-quiet.sh off` — disables the background login items
      listed in the owner's config. Needs the config in
      `~/.config/choose-a-local-llm/`; see `tools/README-mac-quiet.md`.
   2. **Reboot.** A disabled item that is already running keeps
      running, so nothing in step 1 takes effect without this. The
      reboot is also what clears leftover swap.
   3. `sudo sysctl iogpu.wired_limit_mb=24000`. It resets to 0 on
      every reboot, and 0 means the system default, not "no limit".
      Every ceiling depends on it, so set it before reading any memory
      number.
   4. **Load the model under test and use it as the balloon.** Do not
      use a synthetic one. Load the real weights, then drive the
      context up SLOWLY towards the configured maximum. This single
      step does five jobs: it applies the memory pressure that makes
      the machine yield, it warms the model, it proves the config
      loads instead of assuming it, it produces the ceiling for this
      exact config, and it surfaces a failure now rather than two
      hours into a run.
      Go slowly. Rate changes the answer — see the rate rule in
      [memory ceiling](./memory-ceiling.md). A fast walk drives the
      machine into swap and reports a ceiling no real session would
      hit.
   5. Verify with a memory probe before starting: `vm_stat` for
      `Pages wired down`, and `sysctl -n vm.swapusage`. **Swap must be
      0.** Any swap means the balloon overshot; recover before
      continuing. Wired is the counter to trust — free and active move
      for reasons unrelated to the run, and the compressor can inflate
      an allocation total until it is meaningless.
   6. Only now start the real benchmark.
5. Do NOT download any model. All models are already in the cache, in
   the exact tested revision and quant. A missing model means STOP and
   ask the owner ([common rules](./common-rules.md)).
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
14. After stopping any server above ~15 GB RSS, wait for memory to
    RECOVER before loading the next model or starting a sweep: poll
    `vm_stat` (or the memwatch log) until free memory returns to the
    idle baseline. Process death is not memory recovery — a sweep
    started ~3 min after killing a 23 GB server ran the whole window
    with 60-220 MB free and continuous swap-ins, and OOMed
    ([server lore](./server-lore.md)).
15. Clean up: `pgrep -fl "llama-server|mlx_lm"`, `lms ps`, kill strays,
    no background task holding the GPU. End the session with the
    machine idle.
