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

## `fast-bonsai2-ptq1-xhigh`

Ternary-Bonsai-2-27B PTQ1_0, q8_0 KV, no drafter, effort xhigh, fork `prism-b10685-7dffb15`, `-c 32768`, fast mode (thinking 8192, `max_tokens` 16384). Splice source: `bench24/results/bonsai2-ptq1-evalplus-budget-xhigh`, 148 kept, 16 generated.

| | base | plus | completion | empty | forced | wall |
|---|--:|--:|--|--|--|--:|
| fast mode (run 28) | 0.982 | 0.945 | 164/164 | 0/164 | 16/164 | 140 min = 64 own (07:34Z–08:38Z, 2026-09-20; requests 58.1) + 76 for the kept problems in the source |
| before fast mode (run 24) | 0.982 | 0.945 | 164/164 | see models.json | see run 24 | 244.9 min |

- Forced ids: HumanEval/10, /32, /36, /39, /59, /64, /76, /91, /94, /99, /102, /116, /129, /134, /137, /145.
- Empty ids: none.
- `budget` (ended on `length` at 16384): HumanEval/64, after a forced answer. It holds code, so it is not empty.

## `fast-bonsai2-pq2-xhigh`

Ternary-Bonsai-2-27B PQ2_0, q8_0 KV, no drafter, effort xhigh, fork `prism-b10685-7dffb15`, `-c 32768`, fast mode (thinking 8192, `max_tokens` 16384). Splice source: `bench24/results/bonsai2-pq2-budget-xhigh`, 152 kept, 12 generated.

| | base | plus | completion | empty | forced | wall |
|---|--:|--:|--|--|--|--:|
| fast mode (run 28) | 0.988 | 0.945 | 164/164 | 0/164 | 12/164 | 119 min = 42 own (13:36Z–14:18Z, 2026-09-20; requests 40.3) + 77 for the kept problems in the source |
| before fast mode (run 24) | 0.982 | 0.939 | 164/164 | see models.json | see run 24 | 176.1 min |

- Forced ids: HumanEval/10, /32, /47, /64, /76, /80, /91, /99, /116, /129, /137, /145.
- Empty ids: none.
- `budget` (ended on `length` at 16384): HumanEval/64, after a forced answer. It holds code, so it is not empty.

## `fast-bonsai2-ptq1-f16-orca-xhigh`

Ternary-Bonsai-2-27B PTQ1_0 with the OrcaBonsai abliterate LoRA (scale 1.0, clone `947a80c`), f16 KV, no drafter, effort xhigh, fork `prism-b10685-7dffb15`, `-c 32768`, fast mode (thinking 8192, `max_tokens` 16384). Splice source: `bench27/results/orca-ptq1-f16-budget-xhigh`, 146 kept, 18 generated.

| | base | plus | completion | empty | forced | wall |
|---|--:|--:|--|--|--|--:|
| fast mode (run 28) | 0.976 | 0.945 | 164/164 | 0/164 | 18/164 | 152 min = 70 own (14:23Z–15:33Z, 2026-09-20; requests 66.1) + 82 for the kept problems in the source |
| before fast mode (run 27) | 0.976 | 0.945 | 164/164 | see models.json | see run 27 | 274 min |

- Forced ids: HumanEval/32, /39, /47, /64, /76, /91, /92, /99, /102, /116, /129, /132, /137, /145, /146, /157, /158, /160.
- Empty ids: none.
- `budget` (ended on `length` at 16384): HumanEval/64, after a forced answer. It holds code, so it is not empty.
- The row command's adapter download by `hf` fails; the adapter file is the clone at `/home/irae/code/OrcaBonsai-27B-Uncensored`.

## `fast-gemma26-nvfp4-on`

Gemma-4-26B-A4B NVFP4 (Q8 file), f16 KV, `--n-cpu-moe 7`, no drafter, thinking on, run 19's binary, `-c 32768`, fast mode (thinking 8192, `max_tokens` 16384). Splice source: none, all 164 generated.

| | base | plus | completion | empty | forced | wall |
|---|--:|--:|--|--|--|--:|
| fast mode (run 28) | 0.988 | 0.951 | 164/164 | 0/164 | 19/164 | 154 min (one part, 15:50Z–18:25Z, 2026-09-20; requests 153.6) |
| before fast mode | 0.909 | 0.878 | 150/164 (91%) | see models.json | see models.json | 215.3 min |

- Forced ids: HumanEval/32, /37, /51, /86, /99, /103, /108, /109, /113, /116, /117, /124, /127, /129, /130, /132, /143, /145, /147.
- Empty ids: none.
- `budget` (ended on `length` at 16384): none.
- The score comes from a manual `evalplus.evaluate` run; see `state.md`.

## `fast-gemma12-nvfp4-on`

Gemma-4-12B NVFP4, f16 KV, no drafter, thinking on, run 19's binary, `-c 32768`, fast mode (thinking 8192, `max_tokens` 16384). Splice source: `bench21/results/gemma12-nvfp4-budget-on`, 119 kept, 45 generated.

| | base | plus | completion | empty | forced | wall |
|---|--:|--:|--|--|--|--:|
| fast mode (run 28) | 0.976 | 0.951 | 164/164 | 0/164 | 44/164 | 211 min = 135 own (18:39Z–20:55Z, 2026-09-20; requests 133.3) + 76 for the kept problems in the source |
| before fast mode | 0.659 | 0.640 | 111/164 (68%) | see models.json | see models.json | 203.9 min |

- Forced ids: the 44 ids in `thinking-budget.py count` output: HumanEval/4, /18, /32, /39, /41, /47, /64, /65, /75, /76, /81, /83, /84, /91, /93, /94, /95, /99, /100, /102, /103, /105, /109, /110, /113, /115, /116, /118, /119, /124, /125, /129, /130, /132, /134, /140, /141, /145, /147, /154, /156, /158, /160, /163.
- Empty ids: none.
- `budget` (ended on `length` at 16384): HumanEval/145, after a forced answer. It holds code, so it is not empty.

## `fast-gemma12-q4kxl-on`

Gemma-4-12B UD-Q4_K_XL, f16 KV, no drafter, thinking on, run 19's binary, `-c 32768`, fast mode (thinking 8192, `max_tokens` 16384). Splice source: none, all 164 generated.

| | base | plus | completion | empty | forced | wall |
|---|--:|--:|--|--|--|--:|
| fast mode (run 28) | 0.988 | 0.963 | 164/164 | 0/164 | 34/164 | 198 min (one part, 21:06Z 2026-09-20 to 00:25Z 2026-09-21; requests 197.3) |
| before fast mode | 0.793 | 0.780 | 130/164 (79%) | see models.json | see models.json | 259 min |

- Forced ids: HumanEval/1, /32, /38, /41, /47, /65, /76, /81, /83, /91, /93, /94, /95, /103, /109, /110, /113, /115, /116, /118, /120, /122, /125, /127, /128, /129, /130, /132, /134, /140, /145, /147, /153, /163.
- Empty ids: none.
- `budget` (ended on `length` at 16384): none.
- The score comes from a manual `evalplus.evaluate` run; see `state.md`.
