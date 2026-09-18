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

## `sweep-qwen38-oblit-q3km`

Config: q8_0 KV (the pick), `-c 65536`, no drafter, port 8081. Tool
`llama-benchy` `204acec`. Corpus `corpus-mendel-js.txt`. Depths 4096,
24576, `oblit_q3km_c` − 1024 = 64512.

| depth | tok/s | peak tok/s | prompt tok/s | VRAM used | MemAvailable |
|--:|--:|--:|--:|--:|--:|
| 4096 | 22.67 ± 0.13 | 23.00 | 797.16 ± 2.23 | 15689 MiB | ~19.4M kB |
| 24576 | 20.65 ± 0.01 | 21.00 | 756.72 ± 0.09 | 15689 MiB | ~19.4M kB |
| 64512 | 16.74 ± 0.71 | 17.50 | 618.36 ± 5.33 | 15691 MiB | 19423820 kB |

`oblit_q3km_clean` = the deepest depth at or above 8 tok/s = **64512**
(16.74 tok/s there, well above the floor; no depth fell under 8 tok/s
in this sweep). A table and no pick; the coordinator names what the
row serves.

Files: `results/benchy-qwen38-oblit-q3km-q8.md`,
`results/benchy-qwen38-oblit-q3km-q8-vm.log`,
`results/server-sweep-qwen38-oblit-q3km.log`.

## `qwen38-oblit-q3km-budget-medium`

Config: q8_0 KV, `-c 32768`, `--reasoning-budget 3986`,
`--reasoning-budget-message` set to `$BUDGET_MSG`, level medium (owner
overrule). `max_tokens` 6034.

| metric | value |
|---|--:|
| HumanEval base | 0.854 |
| HumanEval plus | 0.787 |
| empty (from samples) | 3/164 |
| forced (budget fired) | 5/164 |
| wall | 89 min (2 parts) |

Empty: `HumanEval/108`, `HumanEval/114`, `HumanEval/129`. All three
`finish_reason: stop`, no budget hit in the reasoning tail — cause
`model`, not `budget`.

Wall parts (UTC): part 1, 2026-09-18T00:06:54 to 2026-09-18T01:19:28
(≈1h13m, 132/164 problems, ends at the owner's pause); part 2,
2026-09-18T09:40:42 to 2026-09-18T09:56:27 (≈16m, the remaining
32/164 plus evaluate). The pause gap between the parts (≈8h21m) does
not count.

**The agent gate.** Base pass@1 0.854 is at or above the 0.800 floor.
Gate passes: `qwen38-oblit-q3km-smoke-medium` and the blind row run.

Files: `results/qwen38-oblit-q3km-budget-medium/humaneval/`,
`results/qwen38-oblit-q3km-budget-medium/finish.jsonl`,
`results/server-qwen38-oblit-q3km-budget-medium.log`.

## `qwen38-oblit-q3km-forced-rerun`

Same config, q8_0 KV, `-c 32768`, no reasoning flags,
`EVALPLUS_MAX_NEW_TOKENS=30000`. Prepare: 5 forced, 4 forced-failed.

| task_id | cell | forced_tokens | natural_finish | natural_tokens |
|---|---|--:|---|--:|
| HumanEval/32 | forced-fail-wrong | 5169 | stop | 5905 |
| HumanEval/73 | forced-fail-wrong | 4158 | stop | 6273 |
| HumanEval/94 | forced-pass | 4604 | — | — |
| HumanEval/116 | forced-fail-wrong | 5672 | stop | 4686 |
| HumanEval/130 | forced-fail-wrong | 5106 | stop | 4155 |

Summary: forced-pass 1, forced-fail-late 0, forced-fail-loop 0,
forced-fail-wrong 4. `corrected_think_budget`: unchanged, no late
answer. Every forced failure is the model's own limit, not a budget
artifact — a larger budget would not have helped any of these four.

Wall: ≈16 min (one part, no crash).

Files: `results/qwen38-oblit-q3km-forced-rerun/humaneval/`,
`results/qwen38-oblit-q3km-forced-rerun/finish.jsonl`,
`results/qwen38-oblit-q3km-forced-rerun/forced.json`,
`results/server-qwen38-oblit-q3km-forced-rerun.log`.
