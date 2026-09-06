# Finding the wired limit — macOS only

`iogpu.wired_limit_mb` sets how much memory Metal may wire on Apple
Silicon. Too low and the model server OOMs early. Too high and the
machine locks up, glitches, or panics. This page finds the largest
value one machine serves at. Linux has no such sysctl and will get its
own page.

**This is a setup task, not a run task.** Do it once, then again only
when a condition below holds. A run reads the value from the machine
file; it never searches for one.

**The owner must be present.** Every rung needs `sudo`, a bad rung
needs a reboot, and this is never run unattended.

## What the sysctl does, and what it does not

- It caps the Metal/IOGPU share of wired memory, not total wired
  memory. Kernel pages sit on top, so `Pages wired down` in `vm_stat`
  reads about a gigabyte above the sysctl and the machine still serves.
  A reading above the limit is not a fault.
- Metal reports the value it took as `recommendedMaxWorkingSetSize`,
  which llama.cpp prints at init. Read it to confirm a rung took effect.
- `0` means the system default, reported as about two thirds of RAM on
  machines of 36 GB and below. The sources disagree and Apple documents
  none of it, so measure the default rather than assume it. `0` resets
  on every reboot, so `sudo sysctl iogpu.wired_limit_mb=0` and a reboot
  both undo a bad rung. macOS 13 and earlier name it
  `debug.iogpu.wired_limit`.
- Wired pages are the one class macOS cannot reclaim, so the memory
  killer never sees pressure and the GPU driver panics instead. A bad
  rung takes the whole machine, not one process.
- Above a machine-specific line the sysctl stops gating at all:
  physical RAM binds first, free memory runs to near zero, and the
  ceiling stops moving when you move the sysctl. That line is what this
  procedure looks for ([memory ceiling](./memory-ceiling.md), "Know
  which limit actually gates the OOM").

## Before the first rung

1. Prepare the machine the normal way: the cold-start sequence of
   [the bench run checklist](./checklist.md), steps 2 and 3.
2. Reboot. A rung that follows a lockup measures the lockup. Record the
   starting wired, free, and swap numbers.
3. Pick the balloon: the largest model in the cache, at its largest
   `-c` that loads. The setup page names it. Use the same model and
   the same `-c` on every rung, or the rungs do not compare.
4. Write the rung list down before you start. Start at the value above
   the standing one and climb in steps of 500 or 1000 MB.

## One rung, repeated for every value in the ladder

1. `sudo sysctl iogpu.wired_limit_mb=<rung>`.
2. Load the balloon model at the fixed `-c`.
3. Walk its context up with the slow creep, 25 s per step
   ([context creep](./context-creep.md)). Never a fast sweep and never
   a synthetic balloon; rate changes the ceiling.
4. Write down, per step: wired MB, free MB, the swap delta against the
   starting value, and the compressor page counts.
5. Watch the machine itself: a keyboard or pointer that stops answering
   for seconds, torn or blank areas on screen, a window server restart.
6. Stop the server. Wait for wired to return to the starting value.
7. Run the rung a second time before you accept it. One clean pass is
   not evidence: free memory moves on its own by over a gigabyte.

## The stop condition

Stop at the first rung that shows any of these:

- A kernel panic. After the reboot, read the report in
  `/Library/Logs/DiagnosticReports/` and keep its name. A rung that
  panics or locks up is failed. Do not retry it.
- A lockup or a visual glitch at any depth, or swap growth at a depth
  that was clean on the rung below.
- A measured ceiling equal to or lower than the rung below. This one is
  quiet and it is the important one: it means the sysctl stopped
  gating, so every higher rung buys nothing and only costs safety.

## Picking the published values

- **Unattended value.** The highest rung that passed twice clean, minus
  one rung as margin. Such runs may drive free memory to near zero.
- **In use value**, for when the owner works beside a run. The highest
  rung whose creep never drove free memory below 2000 MB and never
  showed material compaction. It costs context depth, and that cost is
  the point: the machine stays usable.
- Both values go on the setup page with the date and the balloon. Every
  ceiling measured under an old value is superseded and moves to the
  setup's historical page.

## When to redo this

Redo the whole ladder after a macOS update, major or minor; after a new
model size class enters the cache, because the balloon changes; and
after the services list changes, because the machine's resting memory
changes. Otherwise leave it alone. The ladder costs hours and a reboot.

## What goes into the machine file

Write the result into `~/.config/choose-a-local-llm/machine.md`
(`tools/README-mac-services.md` says how). In "Thresholds": the
`iogpu.wired_limit_mb` row, with both values in one cell, unattended
first. `tools/preflight.sh` reads this row and accepts either number.
In "Observed on this machine": the date of the ladder, the balloon
used, the rung that failed and how it failed, and any panic report
name. The machine file is the owner's, not the repo's. Never commit it.

## Sources

- [llama.cpp discussion 2182](https://github.com/ggml-org/llama.cpp/discussions/2182).
  The canonical thread: the `recommendedMaxWorkingSetSize` line, the
  reserve percentages, and "do not go to 100% of RAM".
- [mlx-lm issue 883](https://github.com/ml-explore/mlx-lm/issues/883).
  A kernel panic at `IOGPUMemory.cpp:550`, wired memory 8 GB above the
  GPU cap. The evidence that total wired exceeds the sysctl, and that
  the memory killer is blind to wired pages.
- [`mlx.core.set_wired_limit`](https://ml-explore.github.io/mlx/build/html/python/_autosummary/mlx.core.set_wired_limit.html)
  and the [mlx-lm README](https://github.com/ml-explore/mlx-lm): the
  value stays above the model size and strictly below total memory.
