# Run 9 — results

One table per block, filled by the runner as results land. Every number
carries the exact command that produced it. The coordinator publishes
from here.

## Block A1 — short creeps, both KV types (one table per model)

| model | depth | q8_0 tok/s | f16 tok/s | wired q8 / f16 | acceptance q8 / f16 |
| --- | --- | --- | --- | --- | --- |

Prediction and pick per model:

| model | kv_per_token q8 / f16 (MB) | predicted wired at window q8 / f16 | pick | reason |
| --- | --- | --- | --- | --- |

## Block A1b — full creep on the pick

| model | KV | depth | tok/s | acceptance | wired | verdict |
| --- | --- | --- | --- | --- | --- | --- |

## Block A1 — short creeps, both KV types (one table per model)

| model | depth | q8_0 tok/s | f16 tok/s | wired q8 / f16 | acceptance q8 / f16 |
| --- | --- | --- | --- | --- | --- |

Prediction and pick per model:

| model | kv_per_token q8 / f16 (MB) | predicted wired at window q8 / f16 | pick | reason |
| --- | --- | --- | --- | --- |

## Block A1b — full creep on the pick

| model | KV | depth | tok/s | acceptance | wired | verdict |
| --- | --- | --- | --- | --- | --- | --- |

## Block A3 — Gemma-12B GGUF f16 to 262144

| depth | tok/s | acceptance | wired |
| --- | --- | --- | --- |

## Block B1 — Gemma-12B GGUF thinking off, EvalPlus

| budget | base | plus | empty | wall |
| --- | --- | --- | --- | --- |

## Blocks B3, C, E — Mendel rows

| block | model / entry | test | thinking | score | libraries | end reason |
| --- | --- | --- | --- | --- | --- | --- |

## Block A1 — Qwen3.6-35B-A3B GGUF (short creep, KV pick)

Command: published qwen3.6-gguf command, `-c 40960`, ports/log per AGENT.md.

### q8_0 arm

`creep-qwen36-gguf-short-q8.tsv`, `server-qwen36-gguf-short-q8.log`

| depth | decode tok/s | wired_mb | draft acceptance |
| --- | --- | --- | --- |
| 4114 | 36.63 | 25029 | 0.26 (task 0, warming) |
| 8222 | 43.91 | 25019 | 0.52 (task 12) |
| 16386 | 31.22 | 25008 | 1.00 (task 42) |
| 24602 | 24.16 | 24994 | 1.00 (task 63) |
| 32818 | 19.63 | 24973 | 1.00 (task 109) |

Verdict: **mem** — `STOP: 200 or more pages compressed or decompressed on 3
steps in a row, and speed did not come back, by depth 32818`.

Per the mem-verdict reporting rule ("the last clean row carries the
tok/s" — context-creep.md), the compacting streak is depths 16386,
24602, 32818 (each ≥200 pages moved, each below 0.85× the previous
step's speed). The last clean row is **8222, 43.91 tok/s** — that is
the number to publish for this arm, not the STOP-line row.

### f16 arm

`server-qwen36-gguf-short-f16.log`

Server logs `model loaded` and `listening`, but every request returns
`{"error":{"code":500,"message":"Compute error."}}`. The log shows
`Insufficient Memory (kIOGPUCommandBufferCallbackErrorOutOfMemory)`
starting at 0.02s, before any completion request — the KV buffer alone
does not fit at `-c 40960` under `iogpu.wired_limit_mb=24000`. No sweep
run; the server cannot serve a single token.

### Pick: q8_0

Rule 6 step 4: "q8_0 when f16 does not fit at a useful context." f16
fails to fit even at model load, so this is decisive without the
arithmetic in step 3. Research (AGENT.md) already says Qwen3.6 stays
near-lossless at q8_0, so quality is not a blocker.

## Block A1 — Qwen3.8-27B GGUF (short creep, KV pick)

Command: published qwen3.8-gguf command, `-c 40960`, ports/log per AGENT.md.

### q8_0 arm

`creep-qwen38-gguf-short-q8.tsv`, `server-qwen38-gguf-short-q8.log`

| depth | decode tok/s | wired_mb |
| --- | --- | --- |
| 4114 | 16.71 | 21578 |
| 8222 | 13.07 | 21576 |
| 16386 | 9.37 | 21706 |
| 24602 | 8.52 | 21728 |
| 32818 | 7.13 | 21691 |

Verdict: **speed** — `STOP: below 8 tok/s at depth 32818`.

### f16 arm

`creep-qwen38-gguf-short-f16.tsv`, `server-qwen38-gguf-short-f16.log`

| depth | decode tok/s | wired_mb | draft acceptance |
| --- | --- | --- | --- |
| 4114 | 20.02 | 22879 | 1.00 (task 9) |
| 8222 | 18.14 | 22878 | 0.94 (task 19) |
| 16386 | 16.04 | 22877 | 0.85 (task 41) |
| 24602 | 17.20 | 22874 | 1.00 (task 66) |
| 32818 | 16.38 | 22874 | 1.00 (task 89) |

Verdict: **window** — `no ceiling found up to 32768`.

### Pick: f16

Rule 6 step 4: f16 fits (wired steady ~22.9 GB, well under the 24000 MB
limit) and is faster at 32K (16.38 vs 7.13 tok/s, more than 2x). f16
wins outright, no arithmetic needed.

## Block A1 — Gemma-4-26B-A4B GGUF (short creep, KV pick)

Command: published gemma26-gguf command, `-c 40960`, ports/log per AGENT.md.

### q8_0 arm

`creep-gemma26-gguf-short-q8.tsv`, `server-gemma26-gguf-short-q8.log`

| depth | decode tok/s | wired_mb | draft acceptance |
| --- | --- | --- | --- |
| 4114 | 24.85 | 19964 | 0.78 (task 8) |
| 8222 | 17.14 | 19964 | 0.79 (task 38) |
| 16386 | 10.24 | 19961 | 0.74 (task 68) |
| 24602 | 8.08 | 19959 | 0.87 (task 101) |
| 32818 | 6.33 | 19957 | 0.87 (task 132) |

Verdict: **speed** — `STOP: below 8 tok/s at depth 32818`.

### f16 arm

`creep-gemma26-gguf-short-f16.tsv`, `server-gemma26-gguf-short-f16.log`

| depth | decode tok/s | wired_mb | draft acceptance |
| --- | --- | --- | --- |
| 4114 | 60.31 | 20398 | 0.73 (task 9) |
| 8222 | 64.19 | 20395 | 0.87 (task 40) |
| 16386 | 56.48 | 20393 | 0.85 (task 68) |
| 24602 | 52.22 | 20394 | 0.87 (task 99) |
| 32818 | 45.89 | 20396 | 0.83 (task 129) |

Verdict: **window** — `no ceiling found up to 32768`.

### Pick: f16

Rule 6 step 1: Gemma-26B loses quality at q8_0 (research already in
AGENT.md). AGENT.md pick rule, second bullet: f16 wins if it fits at
32K or more, regardless of speed. f16 fits (wired steady ~20.4 GB, no
mem/OOM stop through 32818) and is also faster (45.89 vs 6.33 tok/s at
32K) — both reasons agree.

Block A1 closed. Picks: Qwen3.6 GGUF = q8_0, Qwen3.8 GGUF = f16,
Gemma-26B GGUF = f16.

## Block A1b — Qwen3.6-35B-A3B GGUF full creep (pick: q8_0)

Published `-c` is 98304. It OOMs at model load (Metal
`Insufficient Memory`, before any request) — `server-qwen36-gguf-full-q8.log`.
`-c 65536` OOMs the same way — `server-qwen36-gguf-full-q8-c65536.log`.
`-c 49152` loads and serves — `server-qwen36-gguf-full-q8-c49152.log`.
The full creep ran at **`-c 49152`**, not the published 98304.

`creep-qwen36-gguf-full-q8.tsv`

| depth | decode tok/s | wired_mb | draft acceptance |
| --- | --- | --- | --- |
| 4114 | 36.35 | 25062 | 0.26 (task 0, warming) |
| 8222 | 43.80 | 25055 | 0.52 (task 9) |
| 16386 | 31.01 | 25051 | 1.00 (task 39) |
| 24602 | 24.04 | 25047 | 1.00 (task 60) |
| 32818 | 19.56 | 25047 | 1.00 (task 83) |

Verdict: **mem** — same STOP as the short creep, at depth 32818. The
compacting streak (≥200 pages moved, speed not recovering) starts at
16386. Last clean row: **8222, 43.80 tok/s**.

Published row: **q8_0 KV, `-c 49152` (not 98304 — published `-c` OOMs
at load), ceiling 8222 tokens at 43.80 tok/s.** This is far shallower
than the published context suggested; the daily-driver row needs a
`-c` correction independent of the KV-type question this run set out
to answer.

## Block A1b — Qwen3.8-27B GGUF full creep (pick: f16)

Published `-c 32768` loads and serves fine — no deviation needed.

`creep-qwen38-gguf-full-f16.tsv`, `server-qwen38-gguf-full-f16.log`

| depth | decode tok/s | wired_mb | draft acceptance |
| --- | --- | --- | --- |
| 4114 | 20.02 | 22242 | 1.00 (task 9) |
| 8222 | 18.14 | 22241 | 0.94 (task 19) |
| 16386 | 16.05 | 22226 | 0.85 (task 41) |
| 24602 | 17.21 | 22229 | 1.00 (task 66) |
| 32818 | 16.39 | 22226 | 1.00 (task 89) |

Verdict: **window** — `no ceiling found up to 32768`. No compacting
streak (only one row crosses 200 pages moved, not three in a row), so
no correction needed here.

Published row: **f16 KV, `-c 32768` (matches published), no ceiling
found to the window, 16.39 tok/s at 32818.**
