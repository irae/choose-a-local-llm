# Research run 1 — state

Created 2026-09-03 by the coordinator. No sessions yet.

Start here: read `AGENT.md`. Log every session below with a
handing-over section at the end, like the `benchmarks/bench<N>`
convention.

## Session 1 — 2026-09-03, goal 0 start

Worktree `../choose-a-local-llm-research1`, branch `research1`.

- 13:25 owner asked one question first: can desktop widgets go off for
  a run and come back with the layout intact.
- 13:25 backed up the widget layout to
  `~/chronod-layout-backup-20260903-132554/` before any change.
- 13:26 first screenshot captured the wrong display and showed no
  widgets. Wrong conclusion, corrected by the owner's screenshot: 15
  widgets on the desktop. Screen recording permission then denied.
- 13:35-13:38 ran the hide/restore test with the owner's approval.
  Result in `results/memory-gate.md`: the toggle frees 0 MB. Restore
  verified, `StandardHideWidgets = 0`.
- Measured the always-on background cost: about 910 MB total.
- Read `benchmarks/bench7/state.md` H1-H4. H1 says the dagger-sweep
  OOM started at 60-220 MB free with a ~23 GB Metal server not yet
  reclaimed. Background apps cannot explain that.

### Dotfiles split, same day

The owner ruled that their machine's own state must not be versioned.
Moved out of the repo and into `~/.config/choose-a-local-llm/`: the BTM
dump, both `print-disabled` baselines, the machine's boot inventory, and
the two label lists `mac-quiet.sh` used to hardcode.

The repo now carries the method only. `tools/README-mac-quiet.md` says
how to decide what to disable. `tools/mac-quiet.sh` ships with no list
and reads the config directory. `results/boot-audit.md` keeps what the
audit taught, without naming apps.

Branch history was rewritten before any push, so no dump ever existed in
a commit. New standing rules in `AGENTS.md`: never version the owner's
machine, and readable scripts for anything that changes it.

### Handing over

Open decisions for the owner:

1. Test stopping `chronod` (`launchctl bootout gui/$UID/com.apple.chronod`)?
   It is the only remaining lever on the 219 MB. Widgets vanish while
   the daemon is out. Layout is backed up.
2. A `Bash` permission for the network filter vendor CLI. The classifier
   blocked `list-preferences`, so the exact filter off/on command is
   still unknown.
4. The owner plans a reboot. The first thing after it is one idle
   baseline, untouched.
3. Direction: the evidence says the gate should measure free memory
   and wait for recovery after a large server dies, not police login
   items. Confirm before the gate designs get written.

Not started: goals 1, 2, 3.


## Session 1 continued — after the reboot, goal 0

- 16:07 owner rebooted. Set `iogpu.wired_limit_mb=24000` by hand and
  noted it resets to 0 on every boot.
- 16:25-16:42 four idle samples. Free memory moved across a 1284 MB
  band with nobody touching the machine. A scheduled `XProtect` scan
  took 1084 MB of it. Recorded as finding 3.
- 16:51 wrote `tools/mem-probe.py`. It grows an MLX allocation to a cap
  and records what the system wired behind it.
- 16:52 first probe run. Same 29696 MB allocation wired 12489 MB from a
  dirty machine and 25285 MB after pressure. Finding 4.
- 16:56 control run from the clean state. Its first probe wired 24257
  MB, which rules out probe ordering. Finding 5, with a candidate gate
  formula.
- Checklist updated: quit the LM Studio app rather than only unloading
  the model, reset the wired limit after every reboot, and settle
  before trusting any memory reading.

### Handing over, second pass

The owner's instinct about wired memory was right and it changed the
goal. The gate should not compare free memory to an idle baseline. It
should ask whether the memory a run needs can be wired.

Open, in the order that matters:

1. Test the gate formula against the models already measured. Take a
   model with a known working footprint and a known OOM, compute
   `min(free + 3000, wired_limit + 1300)` before each, and see if it
   predicts which one fails. Four points on one machine is not a law.
2. Decide the pre-run reset. A balloon before every run costs about a
   minute and leaves the machine at about 25 GB free. A wired probe
   sized to the run is slower to build but tests the real precondition.
   Untested either way, and the owner picks.
3. Redo the widget test. It is now cheap: the reboot proved the toggle
   does not stop the extensions loading, so the only remaining question
   is what stopping `chronod` frees. Needs the owner's approval.
4. Goals 1, 2 and 3 are untouched.

Machine state left behind: desktop widgets off, `StandardHideWidgets =
1`. `iogpu.wired_limit_mb=24000`, which will reset on the next reboot.
Nothing else changed. `tools/mac-quiet.sh` has never been run.
