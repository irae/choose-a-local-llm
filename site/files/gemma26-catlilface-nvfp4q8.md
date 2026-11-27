---
editLink: false
generated: true
---

# Gemma-4-26B-A4B NVFP4Q8 (catlilface)

| Field | Value |
|---|---|
| Model | [Gemma-4-26B-A4B](/models/gemma-4-26b-a4b) |
| Quant | `NVFP4Q8` |
| Publisher | catlilface |
| Server | `llama-server` |
| Hugging Face Repo | [catlilface/Gemma-4-26B-A4B-NVFP4-GGUF](https://huggingface.co/catlilface/Gemma-4-26B-A4B-NVFP4-GGUF) |
| File | `Gemma4-26b-NVFP4Q8.gguf` |
| Pinned Revision | unpinned |
| Tested On | [RTX 5060 Ti 16 GB](/setups/rtx-5060ti-16gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma26-catlilface-nvfp4q8" top /> | **97k** | <TokCell shallow="58.77" deep="45.59" cap="mem" top-shallow top-deep /> | **15.2 GB** | <ScoreCell value="0.988/0.951" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 2h34 · Mendel 0h23"><b>2h57</b></span> |

## Serve presets

Best served preset (RTX 5060 Ti 16 GB, `llama-server`, pi id `gemma-4-26b-a4b-nvfp4`):

```ini
[gemma-4-26b-a4b-nvfp4]
hf-repo = catlilface/Gemma-4-26B-A4B-NVFP4-GGUF
hf-file = Gemma4-26b-NVFP4Q8.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
n-cpu-moe = 7
flash-attn = on
ctx-size = 98304
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### Direct serve commands

RTX 5060 Ti 16 GB (f16 KV):

```bash
llama-server -m "$(hf download catlilface/Gemma-4-26B-A4B-NVFP4-GGUF Gemma4-26b-NVFP4Q8.gguf)" \
  --alias gemma-4-26b-a4b-nvfp4 --no-mmproj --parallel 1 \
  -ngl 999 --fit off --n-cpu-moe 7 -fa on -c 98304 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8888
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma26-catlilface-nvfp4q8" /> | 8192 | 16384 | <ScoreCell value="0.988/0.951" sub="100% completion" top /> | none | 19/164 | <TokCell shallow="58.77" deep="45.59" /> | 2h34 |
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma26-catlilface-nvfp4q8" /> | —† | 12500 | <ScoreCell value="0.909/0.878" sub="91% completion" /> | † unproven | — | <TokCell shallow="58.77" deep="45.59" /> | 3h35 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.

## Mendel runs

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma26-catlilface-nvfp4q8" model-page="/models/gemma-4-26b-a4b" /> | guided-v3.0 | 96k | **37.5** | 3/8/partial | 22.5 | 6,687k | 90k | 1 | 137 | 6 | thinking |
