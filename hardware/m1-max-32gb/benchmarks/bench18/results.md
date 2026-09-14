# Run 18 — results

The large form of every block (`docs/methodology/status-lines.md`,
"The site comparison, in full"). This build has no published row on
this machine yet, so the `old` row of every pair is the ISTA 3-bit
build of the same model at the same level on this Mac, and the note
says so.

## ladder-qwen38-unsloth

`unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S` rev `4ca7207`, one slot, f16 KV, wired limit 25000.

| rung | result | wired MB |
|--:|---|--:|
| 163840 | pass | 24251 |
| 180224 | pass | 25344 |
| 196608 | fail (Metal OOM) | — |
| 188416 | pass | 25911 |

Ceiling: 188416, wired 25911 MB at load.
