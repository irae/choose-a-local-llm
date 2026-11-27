---
editLink: false
generated: true
---

# S5-nano BF16 (Maritaca AI)

| Field | Value |
|---|---|
| Model | [S5-nano](/models/s5-nano) |
| Quant | `BF16` |
| Publisher | maritaca-ai |
| Server | `llama-server` |
| Hugging Face Repo | [maritaca-ai/S5-nano-GGUF](https://huggingface.co/maritaca-ai/S5-nano-GGUF) |
| File | `S5-nano-BF16.gguf` |
| Pinned Revision | `5fd041274829d60aeeba1e2edc4aabb621a432e4` |
| Tested On | [RTX 5060 Ti 16 GB](/setups/rtx-5060ti-16gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="S5-nano" quant="BF16" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/s5-nano-maritaca-bf16" /> | **204k** | <TokCell shallow="45.68" deep="26.41" cap="mem" top-shallow top-deep /> | **15.5 GiB** | <ScoreCell value="0.841/0.774" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="failed-smoke" /> | <span title="EvalPlus 3h42 · Mendel —">3h42†</span> |

## Serve presets


### Direct serve commands

RTX 5060 Ti 16 GB (f16 KV):

```bash
llama-server -m "$(hf download maritaca-ai/S5-nano-GGUF S5-nano-BF16.gguf --revision 5fd041274829d60aeeba1e2edc4aabb621a432e4)" \
  --alias s5-nano-bf16-f16 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 204800 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8888
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="S5-nano" quant="BF16" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/s5-nano-maritaca-bf16" /> | 8192 | 16384 | <ScoreCell value="0.841/0.774" sub="100% completion" top /> | none | 31/164 | <TokCell shallow="45.68" deep="26.41" /> | 3h42 |

## Mendel runs

No Mendel run yet.
