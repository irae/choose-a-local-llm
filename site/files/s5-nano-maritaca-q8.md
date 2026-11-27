---
editLink: false
generated: true
---

# S5-nano Q8_0 (Maritaca AI)

| Field | Value |
|---|---|
| Model | [S5-nano](/models/s5-nano) |
| Quant | `Q8_0` |
| Publisher | maritaca-ai |
| Server | `llama-server` |
| Hugging Face Repo | [maritaca-ai/S5-nano-GGUF](https://huggingface.co/maritaca-ai/S5-nano-GGUF) |
| File | `S5-nano-Q8_0.gguf` |
| Pinned Revision | `5fd041274829d60aeeba1e2edc4aabb621a432e4` |
| Tested On | [RTX 5060 Ti 16 GB](/setups/rtx-5060ti-16gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/files/s5-nano-maritaca-q8" /> | **261k** | <TokCell shallow="77.37" deep="30.59" cap="mem" top-shallow top-deep /> | **10.9 GiB** | <ScoreCell value="0.811/0.726" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="failed-smoke" /> | <span title="EvalPlus 1h56 · Mendel —">1h56†</span> |

## Serve presets

Best served preset (RTX 5060 Ti 16 GB, `llama-server`, pi id `s5-nano-q8`):

```ini
[s5-nano-q8]
hf-repo = maritaca-ai/S5-nano-GGUF
hf-file = S5-nano-Q8_0.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 262144
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### Direct serve commands

RTX 5060 Ti 16 GB (q8_0 KV):

```bash
llama-server -m "$(hf download maritaca-ai/S5-nano-GGUF S5-nano-Q8_0.gguf --revision 5fd041274829d60aeeba1e2edc4aabb621a432e4)" \
  --alias s5-nano-q8 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 262144 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8888
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/files/s5-nano-maritaca-q8" /> | 8192 | 16384 | <ScoreCell value="0.811/0.726" sub="100% completion" top /> | none | 26/164 | <TokCell shallow="77.37" deep="30.59" /> | 1h56 |
| <ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="off" hardware="rtx-5060ti-16gb" page="/files/s5-nano-maritaca-q8" /> | none | 16384 | <ScoreCell value="0.720/0.634" sub="100% completion" top /> | none | 0/164 | <TokCell shallow="77.37" deep="30.59" /> | 0h26 |

## Mendel runs

No Mendel run yet.
