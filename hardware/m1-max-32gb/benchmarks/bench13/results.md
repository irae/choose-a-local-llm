# Run 13 — results

One section per block, in run order. Every number with the exact
command that produced it and the file under `results/` that holds the
evidence.

A creep is a table, one row per step, with depth, decode speed, wired
memory, free memory and swap delta. The one-line arrow form is the chat
form and never belongs here (`docs/methodology/status-lines.md`).

A sweep that ends with no stop condition records its deepest step as a
list end, never as a ceiling.

## `ista-nmax-shallow`

Build `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, rev `d562806`,
`--no-mmproj`, f16 KV, `-c 106496`, `--parallel 1`. One 256-token
completion per cell, coding prompt (py), temperature 0. Logs:
`results/server-ista-nmax-<cell>.log`.

| cell | decode tok/s | draft proposed | draft accepted | acceptance | wired at load (MB) |
| --- | --- | --- | --- | --- | --- |
| `none` | 14.44 | — | — | — | 20168 |
| `n1` | 14.35 | 134 | 120 | 89.6% | 22090 |
| `n2` | 13.24 | 196 | 156 | 79.6% | 22241 |
| `n3` | 12.41 | 250 | 171 | 68.4% | 22397 |
| `n4` | 11.72 | 284 | 183 | 64.4% | 22546 |

Wired moved with `n-max`: about 1.9 GB at `n1`, then a further 150-160
MB per extra step. It is not flat here, against the drafter's
head-plus-draft-context cost model.

Decode speed falls with every step past `n1`: acceptance drops faster
than draft length grows, so a longer draft costs more than it wins.
`n1` matches `none` within noise (14.35 vs 14.44 tok/s) and beats every
deeper cell. Pick: `n1`.
