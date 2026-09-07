# macOS media indexing competed for memory during a run, near-OOM

Observed in run 11, block 5 (Gemma-26B, thinking high, guided,
`-c 212992`, f16 KV, wired 25000).

## What happened

The Claude Code harness killed the block's server, worker, and
watcher processes at ~23:30Z, citing low system memory. This was not
a GPU OOM: no Metal error appeared in the `llama-server` log. The
run's own memory-watch log
(`hardware/m1-max-32gb/benchmarks/bench11/results/mem-watch-block5.log`)
shows free RAM collapsing from about 1565 MB to 62 MB in one
20-second sample (20:27:20), with sustained heavy page compression
(144115 pages compressed in that one interval) for over three
minutes before the kill.

At the time, `mediaanalysisd-access`
(`/System/Library/PrivateFrameworks/MediaAnalysisAccess.framework`,
part of Photos/Spotlight media indexing) was running at roughly 70%
CPU. This process is not in
`~/.config/choose-a-local-llm/machine.md`'s app list or the
`tools/mac-services.sh` login-items disable list, so preflight never
sees it and never turns it off.

The run lost real, uncommitted work (`TASKS.md` and two
`mendel-development` source files were modified but not committed
when the kill happened), even though 8/8 libraries already had
committed work — the run was still going, not near a natural stop.

## Why this is a run risk, not a one-off

At `iogpu.wired_limit_mb=25000`, free RAM headroom during a run is
thin (the methodology docs' own "near physical RAM" regime, see
`docs/methodology/memory-ceiling.md`, "Know which limit actually
gates the OOM"). A background macOS service that spikes CPU/memory
usage — media indexing, Spotlight, Time Machine, or similar — can tip
an otherwise-healthy run into a real system-wide OOM that no amount of
GPU-side wired-limit tuning prevents, because it competes for the
non-wired remainder, not the GPU allocation.

## Ask

- Should `mediaanalysisd`/`mediaanalysisd-access` (and similar
  Photos/Spotlight indexing services) be added to the machine file's
  app list and the login-items disable set, so preflight can catch and
  quiet it before a run?
- Is there a system-wide free-RAM floor preflight should check
  (independent of the wired-limit check), so a run does not start (or
  pauses) when non-wired free memory is already thin, since that is
  the resource this incident actually exhausted?
- Worth a note in `docs/methodology/memory-ceiling.md` or
  `server-lore.md` about this specific failure shape (sudden free-RAM
  collapse from an unrelated system process, not a GPU allocation
  failure) so a future runner recognizes it faster.

Evidence: this conversation, run 11, block 5, 2026-09-06, incident at
approximately 20:27Z-23:30Z (crash spike to kill).
