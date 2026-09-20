# Run 28 — results

One section per block: the fast-mode score with its empty and forced counts, the wall with its parts, the splice source, and the row's score before fast mode beside it.

## `fast-qwen38-iq3s-xhigh`

Qwen3.8-27B UD-IQ3_S, q8_0 KV, no drafter, effort xhigh, `-c 32768`, fast mode (thinking 8192, `max_tokens` 16384). Splice source: none, all 164 generated.

| | base | plus | completion | empty | forced | wall |
|---|--:|--:|--|--|--|--:|
| fast mode (run 28) | 0.963 | 0.921 | 164/164 | 0/164 | 8/164 | 188 min (one part, 02:48Z–05:56Z on 2026-09-20; request walls sum to 177.1 min) |
| before fast mode (budget 19000, run 19) | 0.957 | 0.921 | 161/164 | 3/164, cause unproven | not counted | 289.6 min |

- Forced ids: HumanEval/10, /32, /39, /99, /116, /129, /137, /145.
- Empty ids: none.
- `budget` (ended on `length` at 16384): none.

## `fast-bonsai2-ptq1-f16-xhigh`

Ternary-Bonsai-2-27B PTQ1_0, f16 KV, no drafter, effort xhigh, fork `prism-b10685-7dffb15`, `-c 32768`, fast mode (thinking 8192, `max_tokens` 16384). Splice source: `bench24/results/bonsai2-ptq1-f16-evalplus-budget-xhigh`, 152 kept, 12 generated.

| | base | plus | completion | empty | forced | wall |
|---|--:|--:|--|--|--|--:|
| fast mode (run 28) | 0.976 | 0.945 | 164/164 | 0/164 | 12/164 | 125 min = 44 own (06:01Z–06:45Z, 2026-09-20; requests 40.4) + 81 for the kept problems in the source |
| before fast mode (run 24) | 0.970 | 0.939 | 164/164 | see models.json | see run 24 | 195.5 min |

- Forced ids: HumanEval/10, /32, /39, /47, /76, /80, /95, /99, /116, /132, /137, /145.
- Empty ids: none.
- `budget` (ended on `length` at 16384): none.

## `fast-bonsai2-pq2-f16-xhigh`

Ternary-Bonsai-2-27B PQ2_0, f16 KV, no drafter, effort xhigh, fork `prism-b10685-7dffb15`, `-c 32768`, fast mode (thinking 8192, `max_tokens` 16384). Splice source: `bench24/results/bonsai2-pq2-f16-evalplus-budget-xhigh`, 152 kept, 12 generated.

| | base | plus | completion | empty | forced | wall |
|---|--:|--:|--|--|--|--:|
| fast mode (run 28) | 0.982 | 0.945 | 164/164 | 0/164 | 12/164 | 121 min = 44 own (06:48Z–07:33Z, 2026-09-20; requests 39.6) + 77 for the kept problems in the source |
| before fast mode (run 24) | 0.982 | 0.945 | 164/164 | see models.json | see run 24 | 182.7 min |

- Forced ids: HumanEval/10, /32, /39, /64, /76, /91, /99, /116, /124, /132, /137, /145.
- Empty ids: none.
- `budget` (ended on `length` at 16384): HumanEval/64. The budget fired on a `yY` loop, then the answer also ran to 16384. It holds code, so it is not empty.
