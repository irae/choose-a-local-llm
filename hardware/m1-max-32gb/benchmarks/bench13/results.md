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
than draft length grows, so a longer draft costs more than it wins at
this shallow depth.

No cell had a separate warmup completion before its measured one; the
256-token request reported here was each cell's first request. Every
cell carries the same graph-setup cost, so the ranking across cells
still holds, but these tok/s numbers are not directly comparable with
a creep's rows, which warm up first.

This build's `n3` cell here reads 12.41 tok/s at depth 256, against
15.1 tok/s at `-c 4096` on 2026-09-08 and 15.09 tok/s at depth 4114 in
research run 3, same config otherwise. The gap points to allocation
size, not used depth, taxing decode on this model well below the 262K
mark where that effect first showed.

## `ista-nodrafter-creep`

Same build, f16 KV, no drafter, `--parallel 1`. Estimate: wired
difference between `none` and `n3` in the block above, 2229 MB, over
0.0671 GB per 1K tokens, is about 33K tokens, giving about `-c 164000`.

Probe at `-c 163840`: a real request at prompt depth 3752 tokens
served clean, wired 24412 MB, no swap growth (376 MB, at the start
value). No bisection against `-c 131072` was needed. `creep_tool_hash`
`e38c467`.

```
DEPTH_LIST="4096,8192,16384,24576,32768,40960,49152,65536,81920,98304,114688,131072,147456,163840" \
N_CONTEXTS=1 MODEL=qwen3.8-27b \
python3 ~/code/local-llm-eval-tools/slow-context-creep/creep.py llama
```

| depth_tokens | decode tok/s | wired_mb | free_mb | swap_delta_mb | compress_pages | decompress_pages |
| --- | --- | --- | --- | --- | --- | --- |
| 4114 | 14.14 | 24412 | 67 | 0 | 3274 | 769 |
| 8222 | 13.82 | 24408 | 65 | 0 | 3394 | 2549 |
| 16386 | 13.25 | 24407 | 80 | 0 | 612 | 663 |
| 24602 | 12.83 | 24408 | 92 | 0 | 3729 | 3625 |
| 32818 | 12.39 | 24403 | 68 | 0 | 0 | 772 |
| 40982 | 11.95 | 24421 | 67 | 0 | 0 | 709 |
| 49198 | 11.51 | 24380 | 114 | 0 | 17662 | 2223 |
| 65578 | 10.90 | 24266 | 67 | 0 | 25375 | 10029 |
| 81958 | 10.24 | 24406 | 60 | 0 | 4073 | 3581 |
| 98338 | 9.69 | 24380 | 79 | 0 | 172 | 1794 |
| 114718 | 9.19 | 24402 | 58 | 0 | 10920 | 1638 |
| 131098 | 8.72 | 24384 | 81 | 0 | 2929 | 1727 |
| 147478 | 8.30 | 24397 | 64 | 0 | 2864 | 1904 |
| 163858 | 7.94 | 24383 | 66 | 0 | 2283 | 1039 |

Verdict: **speed**. `STOP: below 8 tok/s at depth 163858`. Swap never
grew past its start value; the compaction spikes at 49198 and 65578
(above 5000 pages) each recovered on the following step and never held
for six steps, so neither is a stop condition on its own. The swept
range reached the planned bound, `-c 163840`, so this is a ceiling, not
a list end. Ceiling: **147478 tokens at 8.30 tok/s**.
