---
editLink: false
generated: true
---

# Arete-27B Q3_K_M (bartowski)

| Field | Value |
|---|---|
| Model | [Arete-27B](/models/arete-27b) |
| Quant | `Q3_K_M` |
| Publisher | bartowski |
| Server | `llama-server` |
| Hugging Face Repo | [bartowski/NousResearch_Arete-27B-GGUF](https://huggingface.co/bartowski/NousResearch_Arete-27B-GGUF) |
| File | `NousResearch_Arete-27B-Q3_K_M.gguf` |
| Pinned Revision | `9762c8502a79bd2b8634735d75f426b9febe092c` |
| Tested On | [RTX 5060 Ti 16 GB](/setups/rtx-5060ti-16gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Arete-27B" quant="Q3_K_M" server="llama-server" publisher="bartowski" repo="bartowski/NousResearch_Arete-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/arete-bartowski-q3km" top /> | **64k** | <TokCell shallow="27.60" deep="20.07" cap="mem" top-shallow top-deep /> | **15.4 GiB** | <ScoreCell value="0.976/0.951" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 3h24 · Mendel —">3h24†</span> |

## Serve presets

Best served preset (RTX 5060 Ti 16 GB, `llama-server`, pi id `arete-27b-q3km`):

```ini
[arete-27b-q3km]
hf-repo = bartowski/NousResearch_Arete-27B-GGUF
hf-file = NousResearch_Arete-27B-Q3_K_M.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 65536
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### Direct serve commands

RTX 5060 Ti 16 GB (q8_0 KV):

```bash
llama-server -m "$(hf download bartowski/NousResearch_Arete-27B-GGUF NousResearch_Arete-27B-Q3_K_M.gguf --revision 9762c8502a79bd2b8634735d75f426b9febe092c)"   --alias arete-27b-q3km --no-mmproj --parallel 1   -ngl 999 --fit off -fa on -c 65536   --cache-type-k q8_0 --cache-type-v q8_0   --jinja --port 8888
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Arete-27B" quant="Q3_K_M" server="llama-server" publisher="bartowski" repo="bartowski/NousResearch_Arete-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/arete-bartowski-q3km" /> | 8192 | 16384 | <ScoreCell value="0.976/0.951" sub="100% completion" top /> | none | 7/164 | <TokCell shallow="27.60" deep="20.07" /> | 3h24 |

## Mendel runs

No Mendel run yet.
