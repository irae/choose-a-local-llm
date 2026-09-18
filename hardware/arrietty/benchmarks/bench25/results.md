# Run 25 — results

One section per block: the offload ladder with its VRAM readings, the
speed table at 64K, the calibration with its derived budgets, the
budget block with score, empties, forced count and wall, the forced
re-run with the report table, and the blind row with its peak context
and tool-call count.

It runs after run 23, whatever run 23 did (owner, 2026-09-17). Run 23
passed its context gate (65536 ≥ 32768, pick q8_0) and finished its
list; its Mendel smoke failed on the binary's tool-calling format, not
on context or budget. This run is the second point of the pair: the
larger quantization at the fixed 65536 window the card alone cannot
hold.

## `qwen38-oblit-q4km-offload-ladder`

Config: the file, `-c 65536` fixed, q8_0 KV, `--no-mmproj --parallel 1
--fit off -fa on --cache-ram 0`, port 8081, no drafter. VRAM cap 13811
MiB. `n_layer` = 64 (the file's `blk.64.*` tensors are the ignored MTP
head, one past the real layers, same pattern as the Q3_K_M build).

| `-ngl` | result | VRAM at load | VRAM under deep request | notes |
|--:|---|--:|--:|---|
| 43 | pass | 12945 MiB | 12989 MiB | real ~64K request (63840 tokens) served, `finish_reason` length |
| 51 | fail | 14963 MiB | — | over the 13811 cap already at load |
| 47 | fail | 13965 MiB | — | over the 13811 cap already at load |
| 45 | pass | 13397 MiB | 13426 MiB | real ~64K request (63840 tokens) served, `finish_reason` length |

`oblit_q4km_ngl` = **45**. 45 and 47 are 2 apart, the ladder's minimum
step, so the bisection ends there. `MemAvailable` at the 45 pass:
19397304 kB. 4 loads total, under the 8-load cap.

Files: `results/server-offload-ladder-ngl43.log`,
`results/server-offload-ladder-ngl51.log`,
`results/server-offload-ladder-ngl47.log`,
`results/server-offload-ladder-ngl45.log`,
`results/verify-ngl45.log`.

## `sweep-qwen38-oblit-q4km`

Config: the file, `-c 65536`, q8_0 KV, `oblit_q4km_ngl` = 45, no
drafter. Tool `llama-benchy`. Corpus `corpus-mendel-js.txt`. Depths
4096, 24576, 49152, 64512 (`-c` minus 1024).

| depth | tok/s | peak tok/s | prompt tok/s | VRAM used | MemAvailable |
|--:|--:|--:|--:|--:|--:|
| 4096 | 5.13 ± 0.02 | 6.00 | 441.91 ± 0.11 | 13422 MiB | ~18.6M kB |
| 24576 | 3.49 ± 0.03 | 4.00 | 429.92 ± 0.15 | 13422 MiB | ~18.5M kB |
| 49152 | 2.67 ± 0.01 | 3.00 | 406.20 ± 0.61 | 13424 MiB | ~18.3M kB |
| 64512 | 2.31 ± 0.01 | 3.00 | 391.07 ± 0.42 | 13424 MiB | ~18.3M kB |

`oblit_q4km_clean`: **no depth reaches the 8 tok/s floor**, not even
the shallowest tested (4096, 5.13 tok/s). VRAM stayed at 13422-13424
MiB across the whole sweep, well under the 13811 cap; the offload to
host RAM is the cost, not a memory problem.

**The speed gate.** The deep cell (64512) reads 2.31 tok/s, under the
8 tok/s floor — and so does every shallower depth tested. Candidate
answer: this build, at this `-ngl` and this window, is too slow for a
full EvalPlus run to be worth its wall time; a 164-problem run under a
6000+ token thinking budget at ~5 tok/s or less would run for many
hours per problem batch. The `calibrate-think` block waits for the
coordinator's answer before it starts.

Files: `results/benchy-qwen38-oblit-q4km-ngl45.md`,
`results/benchy-qwen38-oblit-q4km-ngl45-vm.log`,
`results/server-sweep-qwen38-oblit-q4km.log`.
