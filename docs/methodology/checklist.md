# The bench run checklist

Follow this loop for EVERY benchmark, sweep, or scoring run. Agents skip
steps when the procedure is prose; this page is the checklist. The "why"
lives in [common rules](./common-rules.md) and
[server lore](./server-lore.md) — do not re-derive it here. **The goal
of this whole loop is a GPU that never sits idle while there is
runnable work queued** — every step below exists to get back to that
state safely and quickly, not to slow it down.

**Rule 1, above every numbered step below: the GPU does not sit idle.**
Finish one block, start the next in the same wakeup — do not stop and
ask the owner whether to proceed. Ask only when the block's own text
carries an explicit stop-and-ask condition, or the owner has directly
asked to pause, wait, or hold. **The only idle scenario is one the
owner asked for.** A blocked block gets skipped, with the reason
written to `state.md`, and the next one starts — never leave the GPU
idle with runnable queued work because one item is stuck or ambiguous.

## Before the run

1. **Leave the main worktree BEFORE any other action**, in this repo
   and in `../mendel` when the run touches it:
   `git worktree add ../choose-a-local-llm-run<N> -b run<N>`, then
   `cd` into it and verify with `git worktree list` and `pwd`. Every
   later command of the run happens there. Never push the run branch.
   Never run a bare `git stash`. The reasons and the stop-and-sync
   steps are `AGENTS.md`, standing rules.
2. Check the GPU is free: `pgrep -fl "llama-server|mlx_lm"` and
   `lms ps` (the machine file says where `lms` lives). Stop leftovers.
   **Unloading the model is not enough.** Quit the LM Studio app too
   (`osascript -e 'quit app "LM Studio"'`), and confirm the menu bar
   item is gone. The app keeps its MLX runtime host alive after `lms
   unload`, so a leftover app puts an MLX process on the GPU during a
   run you believe is pure llama.cpp.
3. **Run the cold-start sequence, in this order.** It aims at the SAME
   machine every time, not a clean one. Every "why" is in
   [memory ceiling](./memory-ceiling.md). The machine's own values
   (apps, thresholds, ports, paths) are in its machine file,
   `~/.config/choose-a-local-llm/machine.md`
   (`tools/README-mac-services.md` says how to write one). Method
   pages never carry them.
   1. Handle the apps listed in the machine file, in its order. Some
      must be set before anything else (a firewall that denies new
      binaries in silence), some must be quit and confirmed gone.
   2. `tools/mac-services.sh turn-off` (lists beside the machine file).
   3. Reboot when any of these holds; otherwise skip it:
      - step 2 disabled an item that is still running (a disabled item
        keeps running until the next boot);
      - swap is in use at the start and the run measures speed or a
        ceiling;
      - the previous run left wired memory above its start value, or
        the machine panicked or locked up.
   4. `sudo sysctl iogpu.wired_limit_mb=<the machine file's value>`.
      It resets to 0 on every reboot, and 0 means the system default.
   5. Probe free memory. Above the machine file's balloon threshold,
      skip the balloon. Below it, load the model under test and drive
      its context up SLOWLY towards the configured maximum. Never a
      synthetic balloon.
   6. Record the starting numbers: `Pages wired down` from `vm_stat`,
      and `sysctl -n vm.swapusage`. Swap is judged by the delta, never
      by the level: watch for an INCREASE during the run. Growth
      invalidates a speed or ceiling number and is a recorded
      deviation on a judged score.
   7. Only now start the real benchmark.
4. Serve the exact files the runbook names. A missing file is STOP and
   ask, unless the runbook says this run may download it.
5. Start the server for ONE config. Verify it serves (warmup request).
   LM Studio: load explicitly with `lms load`, verify with `lms ps`,
   then check the SERVER is up with `lms server status` and start it
   with `lms server start` if it is not. `lms load` does not start it
   and `lms ps` does not reveal it. Never trust JIT
   ([server lore](./server-lore.md)).
6. **Start the run watcher before the block, read exit 42, stop it
   after.** A sweep watches itself; a scoring run has exactly one
   watcher. For every scoring run (EvalPlus, Mendel, polyglot) start
   `benchmarks/run-watch.sh` as a background task (`run_in_background`,
   or under `Monitor`) right after the warmup request:
   `RUNWATCH_SERVER_LOG=<server log> RUNWATCH_OUTPUT=<result file>
   RUNWATCH_BASE_URL=<base url> RUNWATCH_MODEL=<model id>
   RUNWATCH_MEM_LOG=/tmp/<run>-mem.log bash benchmarks/run-watch.sh`.
   It writes the run's only memory record (one line per
   `RUNWATCH_MEM_INTERVAL` seconds, default 20), tails the server log
   for the death signatures, and after `RUNWATCH_SILENCE` seconds
   (default 600) without output growth probes one real completion,
   never `/health`. One failed probe is a suspicion, because a probe
   queued behind a long turn on a one-slot server fails the same way.
   It exits 42 on a death signature, or when two probes fail, each
   after a full silence window with no growth; its last stdout line
   says why, and the background-task notification carries that line.
   Read exit 42 as: kill the server, restart it, resume the block,
   start a new watcher. Any other exit is not a verdict. It restarts
   nothing. A scoring run without it is invalid. Stop it when the
   block ends; never leave it running.
   **Depth sweeps start no watcher.** The runner samples memory into
   every step row, greps the server log for the death signature,
   probes a real completion when a step goes silent, and exits 42 on
   a dead server ([context creep](./context-creep.md)). Send the
   sweep's output to a file; that file is the whole record.

## During the run

7. **Keep the idle monitor.** Schedule a wakeup ≤20 minutes after
   starting any block. At every wakeup verify REAL output growth
   (result-file line count, not process liveness), because a server
   can die or hang while the process lives and `/health` returns 200.
   If output stopped: read the server log for the death signatures
   before blaming the model, restart, resume. Every wakeup ends with a
   new wakeup or with the shutdown steps below. The GPU never sits
   idle between blocks.
8. **Reinforcing rule 1: this covers QUEUED blocks, not only mid-block.**
   When one block finishes, start the next queued block in the same
   wakeup. A block simply being scored, long, or run at night is not a
   stop-and-ask condition on its own — only the block's own text saying
   so, or the owner asking to pause, is.
9. Heartbeat format: "Block N (model): done X/Y, [num]h[num]min left."
10. Note deviations in the run's `state.md` AS THEY HAPPEN, not at the
   end. Smallest fix, fairness first, suspect the harness before the
   model.

## After the run

11. Record the result on EVERY surface in the same pass
    ([common rules](./common-rules.md), the record-everywhere rule):
    benchmarks page, report page (including its summary line),
    `comparison.md`, `models.json` + `node tools/gen-tables.mjs`,
    harness config. Update `benchmarks/bench<N>/results.md` and
    `state.md`.
12. Commit before moving to the next block.
13. After stopping any large server (the machine file names the
    size), wait for memory to
    RECOVER before loading the next model or starting a sweep: poll
    `Pages wired down` in `vm_stat` (or the run watcher's memory log, or a sweep's
    `wired_mb` column) until wired
    memory returns to the value you recorded in step 3.6. Do NOT wait
    for free memory. The first load of a model keeps its weights in
    the page cache, so free memory stays lower by about the model's
    size for the rest of the session and never returns to the start
    value. Wired is the counter that answers "has the GPU let go"; it
    returned to baseline within five seconds of a kill when measured
    (research run 1). Process death is
    not memory recovery — a sweep started ~3 min after killing a 23 GB
    server ran the whole window with 60-220 MB free and continuous
    swap-ins, and OOMed ([server lore](./server-lore.md)).
14. Clean up: `pgrep -fl "llama-server|mlx_lm"`, `lms ps`, kill strays,
    no background task holding the GPU. End the session with the
    machine idle.

## One more time: the GPU does not sit idle

Rule 1 again, because it is the rule agents drift from most: while
this checklist runs, the GPU does not sit idle with runnable work
still queued. Finishing a block is not a stopping point — starting the
next one is part of finishing it. The only idle scenario is one the
owner asked for: a direct request to pause, wait, or hold. "This is a
scoring run," "this is a long block," and "this runs at night" are not
that request.
