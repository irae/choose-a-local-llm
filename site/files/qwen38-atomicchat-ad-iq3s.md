---
editLink: false
generated: true
---

# Qwen3.8-27B AD-IQ3_S (AtomicChat)

| Field | Value |
|---|---|
| Model | [Qwen3.8-27B](/models/qwen3.8-27b) |
| Quant | `AD-IQ3_S` |
| Publisher | AtomicChat |
| Server | `llama-server` |
| Hugging Face Repo | [AtomicChat/Qwen3.8-27B-GGUF](https://huggingface.co/AtomicChat/Qwen3.8-27B-GGUF) |
| File | `AD-IQ3_S` |
| Pinned Revision | unpinned |
| Tested On | [M1 Max 32 GB](/setups/m1-max-32gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" kv="f16" effort="medium" hardware="m1-max-32gb" page="/files/qwen38-atomicchat-ad-iq3s" top /> | **104k** | <TokCell shallow="14.3" deep="9.6" cap="mem" top-shallow top-deep /> | **24.1 GB** | <ScoreCell value="0.988/0.927†" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" top /> | <span title="EvalPlus 3h11 · Mendel 1h00"><b>4h10</b></span> |

## Serve presets

Best served preset (M1 Max 32 GB, `llama-server`, pi id `qwen3.8-27b-ad-iq3s`):

```ini
[qwen3.8-27b-ad-iq3s]
hf = AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 106496
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### Direct serve commands

M1 Max 32 GB (f16 KV):

```bash
llama-server -hf AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S \
  --alias qwen3.8-27b-ad-iq3s --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 106496 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/files/qwen38-atomicchat-ad-iq3s" /> | —† | 8886 | <ScoreCell value="0.988/0.927" sub="100% completion" /> | none | — | <TokCell shallow="14.3" deep="9.6" /> | 3h11 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.

## Mendel runs

Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/files/qwen38-atomicchat-ad-iq3s" model-page="/models/qwen3.8-27b" /> | blind-v1.1 | 96k | **37.5** | 3/8/partial | 59.8 | 7,025k | 70k | 0 | 189 | 7 |  |
