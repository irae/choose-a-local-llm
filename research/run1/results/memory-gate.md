# Goal 0 — clean-memory research

Status: in progress. This file holds measured results only.
Machine: M1 Max, 32 GB, macOS 15.7.7 (24G720).

## Finding 1 — INVALID, must be redone

The first hide/restore test is void. The owner had already turned off
iPhone widgets and desktop widgets by hand before the run started, so
the T0 baseline was not the state it claimed to be. The restore step
then turned desktop widgets back ON, which was not the owner's state.
The RSS numbers below describe an unknown starting condition. Do not
cite them.

The missing widget was an iPhone widget, not a Mac one. The owner
turned it off. chronod did not prune an orphan, and the test did not
remove it. `hasRemoteWidgets = 1` in `com.apple.chronod` matches.

Redo needs a start state the owner confirms, and a reboot between
arms — a widget process that already runs keeps running.

## Finding 1a — what stays true

The layout store and the toggle mechanism hold regardless.

All 15 widget instances live in one
NSKeyedArchiver blob: `chrono.sql`, table `HostConfigs`, single row,
host `NotificationCenter`. Each instance carries `location`, `page`,
`family`, `metrics` and `intent2`. Path:

    ~/Library/Group Containers/group.com.apple.chronod/chronod/chrono.sql

The Apple toggle is `StandardHideWidgets` in `com.apple.WindowManager`
(System Settings > Desktop & Dock > Widgets). It never writes to
`chrono.sql`. Off and on are symmetric:

    defaults write com.apple.WindowManager StandardHideWidgets -bool true  && killall WindowManager
    defaults write com.apple.WindowManager StandardHideWidgets -bool false && killall WindowManager

Measurements from the void run, 2026-09-03 13:35-13:38, kept only to
show the shape of the redo:

| Snapshot | widget stack RSS | free |
| --- | --- | --- |
| T0 shown | 377.6 MB | 8353 MB |
| T1 hidden +20s | 383.3 MB | 9023 MB |
| T2 hidden +60s | 383.4 MB | 9028 MB |
| T3 hidden +120s | 383.7 MB | 9011 MB |
| T4 restored +30s | 382.8 MB | 9031 MB |

Every widget extension stayed resident at identical RSS through two
minutes hidden. macOS never reaped them. `StandardHideWidgets` stops
drawing only. The 670 MB that appears at T1 is the desktop redraw
releasing cached surfaces; it survives the restore, so it is not a
widget saving.

The remaining lever is to stop `chronod` itself
(`launchctl bootout gui/$UID/com.apple.chronod`). Untested — it needs
the owner's approval, because widgets vanish while the daemon is out.

Layout backup for the pre-test state:
`~/chronod-layout-backup-20260903-132554/`.

## Finding 2 — the always-on background cost

Measured idle, 2026-09-03.

Read with the same caution: the owner had stopped apps by hand, so
this is a lower bound on a fresh boot. The per-app breakdown names the
owner's apps, so it lives in
`~/.config/choose-a-local-llm/boot-inventory.md`, not here.

The totals, which are what the gate needs:

* whole background set, idle: about 910 MB
* largest single vendor, a network filter: about 390 MB, and the system
  extension part of it cannot be unloaded
* widget stack: about 219 MB, and the supported toggle frees none of it
* two network system extensions together: about 270 MB, unloadable only
  by their parent apps

## What this means for the gate

910 MB is not the OOM cause. The dagger-sweep failure in
`benchmarks/bench7/state.md` (H1) started with `free_mb` pinned at
60-220 MB and swapping on every sample, before the model loaded — a
previous ~23 GB Metal server had not released its wired GPU memory
three minutes after the kill. That is a 23 GB effect. Background apps
are two orders of magnitude smaller.

A gate built on a login-item denylist would therefore have let the
failing run through. The gate has to measure free memory against an
idle baseline and wait for recovery. Design options are still open.

## Next

- `boot-audit.md` holds what the login-item audit taught.
  `tools/README-mac-quiet.md` holds the method. The machine's own list
  is in `~/.config/choose-a-local-llm/`.
- The widget test must be redone from a confirmed start state, with a
  reboot between arms.

## Finding 3 — the post-reboot idle baseline is a band, not a number

Measured 2026-09-03 after a clean reboot, four samples over 34 minutes.
No user activity between samples. Mail was opened once to sign in, then
quit before the first sample.

| Sample | uptime | free | active | load 1-min |
| --- | --- | --- | --- | --- |
| 1 | 18 min | 13070 MB | 8508 MB | 17.13 |
| 2 | 20 min | 13699 MB | 8159 MB | 3.24 |
| 3 | 26 min | 13499 MB | 8267 MB | 2.71 |
| 4 | 34 min | 12415 MB | 8814 MB | 2.55 |

Swap stayed at 0. Compressor stayed at 0 the whole time.

Free memory moved across a 1284 MB band with the machine idle. The
gate cannot compare against a single idle number, because the machine
does not have one.

Sample 4 shows why. Free memory fell 1084 MB from sample 3 while
nothing was asked of the machine. `XProtectRemediatorSheepSwap` had
started, holding 116 MB and pulling more into active. This is a
scheduled malware scan. It fires on its own timetable.

Spotlight had stopped shrinking by sample 4 (`mds_stores` 345 MB,
steady from 344), so the reindex storm was over. The 1 GB swing is a
second, separate event.

### What this means for the gate

A threshold on free memory alone will fail intermittently. It will
pass a run that starts between scans and fail the same run a minute
later, and neither result says anything about the run.

The gate needs a settle criterion, not only a level: sample free
memory more than once, and require the samples to agree within a
margin before starting. A single reading is not evidence.

### Background daemons that can spike mid-run

All present on this machine at idle: `backupd` (Time Machine),
`photoanalysisd` and `mediaanalysisd` (Photos analysis), `bird` and
`cloudd` (iCloud sync), `mds_stores` (Spotlight), `suggestd` (Siri
suggestions), `maild` and `icloudmailagent` (Mail, which stay resident
after the app quits), `XProtect` (malware scan), `bzserv` (backup).

macOS software update is already set to no automatic download and no
automatic install, so it is not a spike source here.

These matter for variance during a run, not for the memory they hold
at rest. Killing them to save 89 MB is not worth it. Preventing a
scan from starting in the middle of a two-hour run is.


## Finding 4 — the same allocation gets half the wired memory on a dirty machine

Measured 2026-09-03 16:52 with `tools/mem-probe.py`, step 512 MB, cap
30000 MB, `iogpu.wired_limit_mb=24000`. Two identical probes back to
back. Each grows an MLX allocation, records the peak, frees everything.

| Probe | free before | allocated | WIRED at peak | free after |
| --- | --- | --- | --- | --- |
| 1, from current state | 9634 MB | 29696 MB | 12489 MB | 22110 MB |
| 2, after pressure | 22129 MB | 29696 MB | 25285 MB | 25263 MB |

Swap stayed at 0 throughout. Both probes reached the 30000 MB cap, so
the allocation ceiling was never found. That number is not the finding.

**The finding is the wired column. The same 29696 MB allocation got
12489 MB wired the first time and 25285 MB the second — twice as much.**

### Why this matters more than free memory

macOS satisfies a large allocation whether or not it can wire the
pages. Probe 1 succeeded. It looked like it worked. But only 12.5 GB
of it was wired, and the rest was ordinary pageable memory that the
system can compress or take back at any moment.

A GPU workload needs wired memory. Wired pages are never compressed
and never swapped. So an allocation that reports success while sitting
mostly on pageable memory is a run waiting to fail.

Probe 2 reached 25285 MB wired, which is the configured 24000 MB limit
plus about 1.3 GB of kernel base. That is the real ceiling. Probe 1
stopped at half of it, not because the limit was lower, but because
the machine could not free app memory fast enough to wire it.

### This explains the dagger-sweep OOM

`benchmarks/bench7/state.md` H1 describes a sweep that started about
three minutes after a 23 GB server was killed, with free memory pinned
at 60-220 MB. The loader proceeded, then Metal failed with
`kIOGPUCommandBufferCallbackErrorOutOfMemory`.

That is this effect. The allocation was accepted. The wiring was not
available. H1 called it "memory had not recovered", which is right,
but the mechanism is sharper than that: recovery means wirable pages,
not free pages.

### What the pressure actually did

Active memory fell 9724 to 3682 to 1994 MB across the two probes. The
compressor went from 0 to about 920 MB and stayed there after both
releases. Idle app pages were compressed and did not come back.

So the balloon works. Free memory after the second release was 25263
MB, on a 32 GB machine, with the owner's normal working set still
logged in. This matches the owner's memory of once seeing about 24 GB
free.

### What to do with it

Two options, both untested as a pre-run step:

* Run a balloon before a benchmark to force the compression up front,
  then release it and start the model on a machine that has already
  yielded. Costs about a minute.
* Skip the balloon and instead gate on a wired probe: ask for the
  memory the run needs, check it wires, release, then start. Slower to
  design, but it tests the actual precondition instead of a proxy.

The second is better if the numbers hold, because it answers "will
this run fit" rather than "does this machine look clean". Neither is
adopted. The owner decides.

### Caveat, since resolved

One run, two probes, one ordering. Probe 2 always follows probe 1, so
the ordering was not controlled. Finding 5 is the control run that
resolves it: ordering is ruled out.


## Finding 5 — control run: it is the state, not the ordering

Finding 4 left one hole. Probe 2 always followed probe 1, so "pressure
helps" and "the second probe always wins" were not separated.

Re-ran the same script at 16:56, immediately after the first run, with
the machine still in the post-pressure state. If ordering were the
cause, this run's probe 1 should again reach only about half. It did
not.

Every probe run so far, ordered by how much free memory it started
with:

| Run and probe | free before | WIRED at peak |
| --- | --- | --- |
| run 1, probe 1 | 9634 MB | 12489 MB |
| run 1, probe 2 | 22129 MB | 25285 MB |
| run 2, probe 1 | 23151 MB | 24257 MB |
| run 2, probe 2 | 25027 MB | 25295 MB |

Run 2's probe 1 is a first probe and it wired 24257 MB. The ordering
hypothesis is dead. Starting state is what decides how much of an
allocation gets wired.

### A usable rule falls out of this

Wired at peak tracks free memory before, plus about 3 GB, until it
saturates at the configured limit:

* 9634 free gave 12489 wired, about 2.9 GB more than free
* 22129 free gave 25285 wired, about 3.2 GB more, at the ceiling
* 23151 free gave 24257 wired, at the ceiling
* 25027 free gave 25295 wired, at the ceiling

The extra 3 GB is what macOS will evict and compress on demand. Above
that it cannot keep up with the allocation.

So a pre-run gate can be arithmetic instead of a guess:

    wirable ≈ min(free + 3000 MB, iogpu.wired_limit_mb + 1300 MB)

A run needing more wired memory than that will be accepted by the
loader and then fail inside Metal. This is testable against the models
already measured, and it should be tested before it is trusted — four
data points on one machine is not a law.

### Two consequences for the checklist

The 3 GB headroom is small. Free memory on this machine moves by more
than 1 GB on its own (finding 3), which is a third of the entire
eviction allowance. A run started at the wrong moment loses a third of
its margin to a malware scan.

The compressor held about 900 MB across every probe and never released
it. Nothing ever swapped. The compressed pages are idle app memory that
the owner is not using, and they stay compressed, so the balloon effect
persists rather than decaying.
