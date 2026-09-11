# Run 15 — results

One section per block, in run order. Every number with the exact
command that produced it and the file under `results/` that holds the
evidence. A simulator(mendel) row states its score, libraries done,
worst defect, wall clock, peak context, compaction count, and the
sampling read from `meta.json`. A vision table carries no verdict.
A table carries no pick.

## `qwen36-f16-ladder-creep`

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` rev `5bc3e23`,
`--no-mmproj`, f16 KV, no drafter, one slot, wired 25000. Tool
`e38c467`.

**Ladder.** Probed `-c 65536` once: loaded (wired 25027 MB) and served
a real 6001-token completion request cleanly. `-c 65536` is the top of
the block's own `DEPTH_LIST`, so no lower rung needed testing; served
`-c` = 65536.

**Creep**, `DEPTH_LIST="4096,8192,16384,24576,32768,40960,49152,57344,65536"`:

| depth | tok/s | wired MB | free MB | swap Δ | compress | decompress |
|--:|--:|--:|--:|--:|--:|--:|
| 4114 | 50.49 | 25027 | 79 | 0 | 107 | 90 |
| 8222 | 48.41 | 25025 | 63 | 0 | 293 | 286 |
| 16386 | 46.17 | 25010 | 71 | 0 | 0 | 925 |
| 24602 | 43.71 | 25010 | 64 | 0 | 3183 | 949 |
| 32818 | 41.50 | 25009 | 61 | 0 | 2010 | 391 |
| 40982 | 39.32 | 25008 | 78 | 0 | 74 | 462 |
| 49198 | 37.20 | 24967 | 63 | 0 | 11643 | 4751 |
| 57362 | 35.03 | 24921 | 155 | 0 | 375 | 248 |
| 65578 | 33.64 | 24921 | 129 | 0 | 0 | 1128 |

`no ceiling found up to 65536`, exit 0. No swap growth, no sustained
compression onset, speed never dropped under the 8 tok/s floor.
`gatedBy: untested` — the deepest step is the depth list's own end,
not a measured ceiling.

`qwen36_f16_c` = 65536 (served). `qwen36_f16_clean` = 65578 (deepest
clean depth).
Files: `results/creep-qwen36-f16-nodrafter.tsv`,
`results/server-qwen36-f16-c65536.log`.
Deviation: none.
