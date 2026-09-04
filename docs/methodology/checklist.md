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
   1. **Set Little Snitch to "silently allow" BEFORE anything else.**
      Its network extension keeps filtering after the app is quit and
      cannot be unloaded by disabling the login item. With the Agent
      not running there is nothing to show an approval prompt, so an
      unapproved binary is denied in silence. `curl` keeps working on
      its existing rules while `node` fails with a bare
      `fetch failed`, which looks like a broken API key or a dead
      network and is neither. An absent tray icon means no Agent, not
      no filter.
   2. `tools/mac-services.sh turn-off` — disables the background login items
      listed in the owner's config. Needs the config in
      `~/.config/choose-a-local-llm/`; see `tools/README-mac-services.md`.
   3. **Reboot.** A disabled item that is already running keeps
      running, so nothing in step 1 takes effect without this.
      Once per SESSION, not once per model. When the machine is doing
      nothing but benchmarks, one reboot can cover several days.
   4. `sudo sysctl iogpu.wired_limit_mb=24000`. It resets to 0 on
      every reboot, and 0 means the system default, not "no limit".
      Every ceiling depends on it, so set it before reading any memory
      number.
   5. **Probe first, and only balloon if you need to.** Read free
      memory. **Above 25 GB free, skip the balloon** — the machine has
      already yielded and there is nothing to gain.
      Below that, balloon with **the model under test**, never a
      synthetic one. Load the real weights, then drive the context up
      SLOWLY towards the configured maximum. That one step applies the
      pressure, warms the model, proves the config instead of assuming
      it, produces the ceiling for this exact config, and surfaces a
      failure now rather than two hours in.
      Go slowly. Rate changes the answer — see the rate rule in
      [memory ceiling](./memory-ceiling.md). A fast walk drives the
      machine into swap and reports a ceiling no real session would
      hit.
   6. Record the starting numbers before you begin: `Pages wired down`
      from `vm_stat`, and `sysctl -n vm.swapusage`. Wired is the
      counter to trust — free and active move for reasons unrelated to
      the run, and the compressor can inflate an allocation total until
      it is meaningless.
      **Swap is judged by the delta, not by the level.** Leftover swap
      from an earlier run is pages a dead process already released; it
      costs disk, not memory, and it will not reclaim itself into this
      run. So a non-zero start is not a blocker. Write the starting
      value down and watch for an INCREASE, which is the real signal.
      What the increase means depends on what is being measured:
      * Measuring **tokens per second or a ceiling**: any swap growth
        invalidates the number. The run is timing the swap file. Treat
        the point where swap starts growing as the ceiling.
      * Measuring **model intelligence** (Mendel, polyglot, EvalPlus):
        swap growth does not invalidate the score, because the answer
        is judged, not timed. Record it as a deviation and carry on.
      Either way it should not be happening. Swap growth on a machine
      prepared by this sequence means something is wrong upstream.
   7. Only now start the real benchmark.
5. Do NOT download any model. All models are already in the cache, in
   the exact tested revision and quant. A missing model means STOP and
   ask the owner ([common rules](./common-rules.md)).
6. Start the server for ONE config. Verify it serves (warmup request).
   LM Studio: load explicitly with `lms load`, verify with `lms ps`,
   then check the SERVER is up with `lms server status` and start it
   with `lms server start` if it is not. `lms load` does not start it
   and `lms ps` does not reveal it. Never trust JIT
   ([server lore](./server-lore.md)).
7. **Start the memory watcher only where nothing else samples memory.**
   - **Scoring runs — required** (EvalPlus, Mendel, polyglot). The
     harness samples no memory and the run lasts hours, so this log is
     the only memory record. Scope it to this run:
     `MEMWATCH_LOG=/tmp/<run>-memwatch.log MEMWATCH_INTERVAL=20 bash
     benchmarks/mem-watch.sh &`. A scoring run without it is invalid.
   - **Depth sweeps — not needed.** The runner samples memory itself and
     writes wired, free, swap delta and the compressor page counts into
     every step row, and it stops the sweep on swap growth, material
     compaction, the floor, a silent halt and a dead server
     ([context creep](./context-creep.md)). Send the sweep's output to a
     file; that file is the whole record. Do not start a second monitor
     beside it.

## During the run

8. **Set the idle/silent-crash monitor.** Schedule a wakeup ≤20 minutes
   after starting any block. At every wakeup verify REAL output growth
   (result-file line count, not process liveness) — servers can die or
   hang while the process lives and `/health` returns 200. If output
   stopped: read the server log for the death signatures before blaming
   the model, restart, resume. Every wakeup ends with a new wakeup or
   with the shutdown steps below. The GPU never sits idle between
   blocks. A depth sweep carries this signal itself: it greps the server
   log for the death signature, probes a real completion when a step
   goes silent, and exits 42 on a dead server. There the wakeup only
   checks that the sweep's output file still grows.
9. Heartbeat format: "Block N (model): done X/Y, [num]h[num]min left."
10. Note deviations in the run's `state.md` AS THEY HAPPEN, not at the
   end. Smallest fix, fairness first, suspect the harness before the
   model.

## After the run

11. Stop the memory watcher immediately, where one ran. Stop one-shot
    monitors as soon as they fire — never leave them running.
12. Record the result on EVERY surface in the same pass
    ([common rules](./common-rules.md), rule "record everywhere"):
    benchmarks page, report page (including its summary line),
    `comparison.md`, `models.json` + `node tools/gen-tables.mjs`,
    harness config. Update `benchmarks/bench<N>/results.md` and
    `state.md`.
13. Commit before moving to the next block.
14. After stopping any server above ~15 GB RSS, wait for memory to
    RECOVER before loading the next model or starting a sweep: poll
    `Pages wired down` in `vm_stat` (or the memwatch log, or a sweep's
    `wired_mb` column) until wired
    memory returns to the value you recorded in step 4.6. Do NOT wait
    for free memory. The first load of a model keeps its weights in
    the page cache, so free memory stays lower by about the model's
    size for the rest of the session and never returns to the start
    value. Wired is the counter that answers "has the GPU let go"; it
    returned to baseline within five seconds of a kill when measured
    (`research/run1/results/backend-diagnosis.md`). Process death is
    not memory recovery — a sweep started ~3 min after killing a 23 GB
    server ran the whole window with 60-220 MB free and continuous
    swap-ins, and OOMed ([server lore](./server-lore.md)).
15. Clean up: `pgrep -fl "llama-server|mlx_lm"`, `lms ps`, kill strays,
    no background task holding the GPU. End the session with the
    machine idle.
