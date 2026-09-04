# T2.3 part 1 — what the servers actually expose, and what is on

Run 2, session 1, 2026-09-04. Section I. Read from the running server,
not from documentation.

## llama-server 0.3.0, read from `GET /props` on this machine

| Parameter | Default | State |
| --- | --- | --- |
| `dry_multiplier` | 0.0 | **off** |
| `dry_base` | 1.75 | — |
| `dry_allowed_length` | 2 | — |
| `dry_penalty_last_n` | 64 | — |
| `xtc_probability` | 0.0 | **off** |
| `xtc_threshold` | 0.1 | — |
| `repeat_penalty` | 1.0 | **off** |
| `repeat_last_n` | 64 | — |
| `frequency_penalty` | 0.0 | **off** |
| `presence_penalty` | 0.0 | **off** |

So DRY and XTC are present in the build we run, as the upstream check
said. Every repetition defence is off.

## `mlx_lm.server` 0.31.3, read from `server.py`

`repetition_penalty`, `presence_penalty` and `frequency_penalty` are
read per request, each with its own `*_context_size`. All three default
to 0.0, which is off. `repetition_context_size` defaults to 20 tokens.
There is no DRY. Confirmed by run 1 and unchanged.

## The finding that matters, and it is not the on/off state

**The default windows are too short to see a repeated tool call.**

`repeat_last_n` and `dry_penalty_last_n` are 64 tokens on llama-server.
`repetition_context_size` is 20 tokens on `mlx_lm.server`. One `bash`
tool call in these runs is longer than either window. The looping call
from the original failure, `ls -F_r` inside a JSON tool-call envelope,
plus the error text pi returns, is well over 64 tokens per cycle.

So a penalty at its default window cannot reach back to the previous
copy of the call. It would penalise tokens inside the current call
instead, which is the wrong target: it makes the model word the same
broken call differently rather than stop repeating it.

This explains the known negative result cleanly. Section D records
`repeat_penalty` failing against Gemma-4's collapse. That test says
nothing about whether repetition penalties can work here, because at a
64-token window the penalty never saw the repetition it was aimed at.

**The testable claim:** any sampler arm against a tool-call loop must
set the window to several complete calls — 2048 tokens or more, not 64
— and must be reported with the window it used. An arm that reports
`repeat_penalty 1.1` without its `repeat_last_n` is not a measurement.

## What is still untested

Whether DRY, with a window that spans several calls, actually stops a
tool-call loop. That needs a backend that loops. If the llama-server
replay arm does not loop, DRY has nothing to act on there, and the only
looping backend on this machine is the LM Studio MLX path, which has no
DRY. Recorded as a dependency, not a plan.
