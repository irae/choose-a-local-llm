# Faster crash detection while babysitting a live run

Status: filed 2026-09-05, from bench 9 (Qwen3.8 MLX, block E). Needs
hardware: no to design the approach; a live run to validate it.

## What happened, the evidence

During bench 9 block E, `mlx_lm.server`'s generation thread died from a
Metal OOM twice (`RuntimeError: [METAL] Command buffer execution
failed: Insufficient Memory`). The process stayed up and `/health` kept
returning 200 — the dead-thread trap `docs/methodology/server-lore.md`
already documents for this backend. The coordinating agent was polling
on a `ScheduleWakeup` cadence of 15-25 minutes. Neither crash was
caught by that loop; the owner separately noticed the GPU fans go idle
and asked for a check. Killing the crashed server and restarting it was
then done by hand.

Traced the harness's own recovery floor while investigating: the
runner's stall watchdog (`../mendel-benchmark/benchmark/run-pi-rpc.mjs`,
`serverBusy()`, lines 399-416) calls the server's `/slots` endpoint to
decide whether a silence is a real stall or a server still working.
`/slots` is `llama.cpp`-only. For `mlx_lm.server` the fetch always
fails, `serverBusy()` returns `false`, and every silence — this OOM, a
genuine slow prefill, a stuck tool call, anything — gets the same
treatment: wait `stallMs` (10 minutes by default, checked every 15s),
then abort the turn as a generic "stall." So `mlx_lm.server` runs have
a roughly 10-minute floor before the harness self-recovers on its own,
and it cannot tell an OOM from a slow-but-healthy prefill. This is a
harness-side fact, not something to redo — record it here so the next
agent does not have to re-derive it from the runner source again.

Separately, on the coordinator side: a background Bash task started
with `run_in_background: true` notifies the agent's context the
instant it exits; a `ScheduleWakeup`-only cadence is purely time-based
and carries no live signal between wakeups. This session used
`ScheduleWakeup` exclusively for the multi-hour Mendel-monitoring
stretch, so detection lag was bounded by the wakeup interval (15-25
minutes), not by anything faster — a live-tailing watcher was never
started.

## The ask

Watch a live run's logs at roughly 10-second granularity, or fully
live: a `tail -f`-style process that parses each line as it arrives
and reacts to a death signature immediately, not on the next
`ScheduleWakeup`. It needs a way to interrupt the coordinating agent —
the `Monitor` tool (available this session, not used) is built for
this: it streams a background process's stdout as notifications one
line at a time. The concrete shape: run something like
`tail -f <server-log> | grep -m1 -E "Insufficient Memory|Traceback|command buffer .* failed"`
under `Monitor`. `grep -m1` exits after the first match, which ends the
piped `tail` too and fires the notification — the agent hears about
the crash within the line's own flush interval, kills/restarts the
server, and re-arms the same watcher for the next stretch, rather than
carrying a 15-25 minute blind spot for the rest of the run.

## Where

Coordinator-side practice (`AGENTS.md` / `docs/methodology/checklist.md`,
the "During the run" guidance on watching a live block), not the
Mendel runner. Complements, does not replace, `run-pi-rpc.mjs`'s own
10-minute stall watchdog — that one is a harness-side floor for any
mlx-backed run regardless of who is watching; this item is about
giving the coordinating agent a much faster, human-competitive signal
on top of it. Related to but distinct from
`backlog/runner-alarms-output-limit-and-loop-stop.md`, which is about
the runner's own internal telemetry, not the coordinator's log-watching
method.
