# Research run 3 — state

Created 2026-09-07 by the coordinator. Not started.

Start here: read `AGENT.md`, then `index.md`, which is the order.
Log every session below, and close each one with a handing-over
section, the same way the bench runs do.

`unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL` is on disk (2026-09-07), so the
run can start at once. The other two builds and their MTP drafters
fetch in the background under `downloads-background`, two at a time.
An item whose file has not landed is passed over, not blocked.

## Values this run sets

The executor writes each value here as it measures it, with the item
that produced it.

| name | value | item |
| --- | --- | --- |
| `creep_tool_hash` | `2344f00` | `tool-check` |
| `qwen38_unsloth_q3kxl_clean` | 49198 | `qwen38-unsloth-q3kxl-creep` |
| `qwen38_atomicchat_iq3s_clean` | 98338 (list ceiling, no stop hit) | `qwen38-atomicchat-iq3s-creep` |
| `qwen38_ista_iq3s_mtp_clean` | 114718 | `qwen38-ista-iq3s-mtp-creep` |

## `compaction-qwen38`, handing-over note

Baseline peak (P) = 8360 (runs: 5738, 8360). Both far under the 20000
line where pi's compaction can fire at all. Per the ladder rule (stop
when `T` under 8192), the first rung (`0.8P` = 6688) is already under
the floor, so no rung ran. No compaction observed for this model on
`xtend-wide` at the default window. The task needs to grow (more
files, or a task that forces more re-reads) before this experiment can
say anything about Qwen3.8's compaction behavior.

## `compaction-gemma12`, handing-over note

P (larger baseline peak) = 40238. Ladder: rung 1 (W 39936) mixed, 1
pass 1 fail (fail ended on `length`, ran out of budget, 0 commits).
Rung 2 (W 31744) mixed, 1 pass (first real compaction observed,
`compactions=1`, still clean) 1 fail (hit the 2700s cap, 3
compactions, never converged, unclean). Rung 3 (W 23552) both pass,
clean, `compactions=0` both times — the task stayed small enough at
this window that compaction never had to fire.

`gemma12_contextWindow_floor` = **23552** (two runs at one rung pass).

## `compaction-bonsai-mlx`, skipped

Its smoke line passes (bench10: 14 calls, 1 commit, no loop, 115s), but
the item needs "the window from the newest MLX creep minus the in-turn
margin" from the MLX margin rule, and that rule is explicitly listed
under "Not in this run" in `AGENT.md` (moved to `unscheduled/`, not
measured). Bonsai has documented history of a 3-hour stuck run and a
17440-token single-turn blowup without that margin. Skipped rather
than guessing a window on a model with that history. Stop-and-ask for
the coordinator: run the MLX margin rule first, or accept a guessed
window for this one item.

## `compaction-gemma26`, handing-over note

P (larger baseline peak) = 35225. Rung 1 (W 35840) failed twice: both
runs end `stop` (the model believes it finished) but 0 commits,
unclean tree, `compactions=0` both times. Not a compaction failure —
compaction never fired — the model just stops early under the reduced
window on this task. Per the ladder's own rule (stop after two
failures at one rung), the ladder stops here. No `contextWindow` floor
found for Gemma-26B on `xtend-wide`.
