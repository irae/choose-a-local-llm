---
editLink: false
generated: true
---

# Gemma-4-12B NVFP4 (FreedomAISVR)

| Field | Value |
|---|---|
| Model | [Gemma-4-12B](/models/gemma-4-12b-it) |
| Quant | `NVFP4` |
| Publisher | FreedomAISVR |
| Server | `llama-server` |
| Hugging Face Repo | [FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF](https://huggingface.co/FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF) |
| File | `gemma-4-12b-it-nvfp4.gguf` |
| Pinned Revision | `207974a` |
| Tested On | [RTX 5060 Ti 16 GB](/setups/rtx-5060ti-16gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-freedomaisvr-nvfp4" /> | **261k** | <TokCell shallow="49.55" deep="33.11" cap="mem" top-shallow top-deep /> | **12.3 GB** | <ScoreCell value="0.976/0.951" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 3h31 · Mendel 0h06"><b>3h37</b></span> |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/files/gemma12-freedomaisvr-nvfp4" /> | **261k** | <TokCell shallow="49.55" deep="33.11" cap="mem" top-shallow top-deep /> | **12.3 GB** | <ScoreCell value="0.927/0.896" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h51 · Mendel 0h01"><b>0h52</b></span> |

## Serve presets

Best served preset (RTX 5060 Ti 16 GB, `llama-server`, pi id `gemma-4-12b-nvfp4`):

```ini
[gemma-4-12b-nvfp4]
hf-repo = FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF
hf-file = gemma-4-12b-it-nvfp4.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 262144
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### Direct serve commands

RTX 5060 Ti 16 GB (f16 KV):

```bash
llama-server -m "$(hf download FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF gemma-4-12b-it-nvfp4.gguf)" \
  --alias gemma-4-12b-nvfp4 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 262144 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8888
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-freedomaisvr-nvfp4" /> | 8192 | 16384 | <ScoreCell value="0.976/0.951" sub="100% completion" top /> | none | 44/164 | <TokCell shallow="49.55" deep="33.11" /> | 3h31 |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/files/gemma12-freedomaisvr-nvfp4" /> | none | 8192 | <ScoreCell value="0.927/0.896" sub="100% completion" top /> | none | — | <TokCell shallow="49.55" deep="33.11" /> | 0h51 |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-freedomaisvr-nvfp4" /> | 7350† | 9398 | <ScoreCell value="0.976/0.951" sub="100% completion" /> | none | 45/164 | <TokCell shallow="49.55" deep="33.11" /> | 3h15 |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-freedomaisvr-nvfp4" /> | —† | 8192 | <ScoreCell value="0.659/0.640" sub="68% completion" /> | † unproven | — | <TokCell shallow="49.55" deep="33.11" /> | 3h24 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.

## Mendel runs

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/files/gemma12-freedomaisvr-nvfp4" model-page="/models/gemma-4-12b-it" /> | guided-v3.0 | 256k | **0** (raw 34) | 0/8/model-failed | 1.0 | 296k | 13k | 0 | 30 | 0 |  |
| <ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-freedomaisvr-nvfp4" model-page="/models/gemma-4-12b-it" /> | guided-v3.0 | 256k | **0** (raw 34) | 0/8/model-failed | 5.5 | 496k | 39k | 0 | 24 | 0 | thinking |
