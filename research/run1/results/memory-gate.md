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
