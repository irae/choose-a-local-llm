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
