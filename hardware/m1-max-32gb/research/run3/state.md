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
