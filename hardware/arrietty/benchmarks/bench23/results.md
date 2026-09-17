# Run 23 — results

One section per block: the KV pick with both ladders and the gate
outcome, the speed table, the calibration with its derived budgets, the
budget block with score, empties, forced count and wall, the forced
re-run with the report table, and the blind row with its peak context
and tool-call count.

## `qwen38-oblit-q3km-kvpick`

`OBLITERATUS/Qwen3.8-27B-OBLITERATED-Q3_K_M.gguf` rev
`a58c3b53b3ce71551eafde2ed5ec8df48e0f4ff8`. `--no-mmproj --parallel 1
-ngl 999 --fit off -fa on --cache-ram 0`, port 8081, no drafter.

### Ladder, `--cache-type-k q8_0 --cache-type-v q8_0`

| `-c` | result | VRAM used | notes |
|--:|---|--:|---|
| 65536 | pass | 15689 / 16311 MiB | real request (500-token completion) served, `finish_reason` length |
| 73728 | fail | — | `cudaMalloc failed: out of memory` at context creation |

`oblit_q3km_c_q8` = **65536**. No 8192-granularity step exists between
65536 and 73728, so the ladder ends here. `MemAvailable` at the 65536
pass: 19987396 kB.

### Ladder, `--cache-type-k f16 --cache-type-v f16`

| `-c` | result | VRAM used | notes |
|--:|---|--:|---|
| 32768 | pass | 15315 / 16311 MiB | real request served, `finish_reason` stop |
| 40960 | fail | — | `cudaMalloc failed: out of memory` at context creation |

`oblit_q3km_c_f16` = **32768**. `MemAvailable` at the 32768 pass:
19915364 kB.

### The gate

`oblit_q3km_c` = the larger of the two = **65536** (q8_0). 65536 is at
or above the 32768 floor, so the gate **passes**. Pick: `q8_0`. The run
goes on to `sweep-qwen38-oblit-q3km`. The published pick still needs
the EvalPlus smoke of the method page; this run does not run that
smoke.

Deviation: the file's load log shows `blk.64.nextn.*` tensors
(`eh_proj`, `enorm`, `hnorm`, `shared_head_norm`), ignored as unused on
every load. This is evidence of an MTP/draft head present in the file.
Per the runbook, no drafter arm runs in this run regardless; recorded
here and in `state.md` as the runbook requires.
