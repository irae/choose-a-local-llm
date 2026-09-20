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
