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

## Block D — Gemma-26B GGUF thinking off, EvalPlus

| arm | budget | base | plus | empty | wall |
| --- | --- | --- | --- | --- | --- |
