# Mendel runner: stop a live repeated-identical-tool-call loop

Status: not reviewed. Filed 2026-09-06, from run 10, block D's Bonsai
guided retry.

## What happened

`prism-ml/Ternary-Bonsai-27B-mlx-2bit`, guided test, thinking off,
retried after the first attempt's `gh` auth failure was fixed. The
retry ran for about 3 hours with zero commits and zero file edits. Its
last 20+ tool calls (and likely more, not counted past that point)
were the exact same bash command, byte for byte:
`ls -la .../.taprc 2>/dev/null; cat .../.taprc 2>/dev/null` against a
file that does not exist, both halves silenced so every call returns
empty. The operator found this by reading `tool_execution_start`
events by hand and killed the run's processes directly; nothing in
the runner or the checklist would have caught it.

## Why the existing alarms miss this

`backlog/runner-alarms-output-limit-and-loop-stop.md` (decided
2026-09-05) covers three failure shapes: a turn that runs too long
(`turn_timeout`), two consecutive output-limit hits
(`output_limit`), and `benchmarks/loop-check.py`'s shape-repetition
verdict — but that verdict runs AFTER the session log is complete, as
part of scoring a finished run. This run never finished on its own: it
would have run to the wall-clock cap (`SMOKE_MENDEL_CAP` has no
equivalent ceiling for a full `run-worker.sh` run) or forever, had
nobody watched it. Each turn here was fast and ordinary in length, so
`turn_timeout` never fired, and no single call hit an output limit, so
`output_limit` never fired either. The failure shape is identical
*inputs*, not slow or truncated *outputs*.

## What the runner could do

Run `loop-check.py`'s shape logic (or an equivalent) as a live check
inside `run-pi-rpc.mjs`, over the last N tool calls, on every new tool
call, not only at run close. A window where the same exact command
(or the same shape) repeats past a small count (5? 10?) with no file
edit or commit in between ends the run with its own reason, e.g.
`repetition_loop`, the same way `output_limit` ends one today. The
row's `notes` records the repeated command and the count, same as a
human would.

## Where

`../mendel-benchmark/benchmark/run-pi-rpc.mjs` (the runner, add the
live check next to the existing per-turn counters),
`benchmarks/loop-check.py` (reuse its shape function rather than
duplicate it), `PLAN.md` (a law sentence for the new end reason, next
to `output_limit`'s).
