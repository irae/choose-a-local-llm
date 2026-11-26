---
editLink: false
generated: true
---

# Ternary-Bonsai-2-27B PQ2_0 (prism-ml, prism fork)

| Field | Value |
|---|---|
| Model | [Ternary-Bonsai-2-27B](/models/bonsai-2-27b) |
| Quant | `PQ2_0` |
| Publisher | prism-ml |
| Server | `prism-llama` |
| Hugging Face Repo | [prism-ml/Ternary-Bonsai-2-27B-gguf](https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf) |
| File | `Ternary-Bonsai-2-27B-PQ2_0.gguf` |
| Pinned Revision | `6ed5e12` |
| Tested On | [RTX 5060 Ti 16 GB](/setups/rtx-5060ti-16gb/), [M1 Max 32 GB](/setups/m1-max-32gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-pq2" top /> | **119k** | <TokCell shallow="46.3" deep="25.1" cap="mem" top-shallow top-deep /> | **15.1 GB** | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | <ScoreCell value="77" pill="mendel-blind" top /> | <span title="EvalPlus 2h01 · Mendel 1h15"><b>3h16</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-pq2" top /> | **208k** | <TokCell shallow="46.0" deep="14.5" cap="mem" top-shallow top-deep /> | **15.4 GB** | <ScoreCell value="0.988/0.945" sub="100% completion" top /> | <ScoreCell value="60.5" pill="mendel-blind" top /> | <span title="EvalPlus 1h59 · Mendel 1h32"><b>3h31</b></span> |

## Serve presets

Best served preset (RTX 5060 Ti 16 GB, `prism-llama`, pi id `bonsai2-27b-pq2-f16`):

```ini
[bonsai2-27b-pq2-f16]
hf-repo = prism-ml/Ternary-Bonsai-2-27B-gguf
hf-file = Ternary-Bonsai-2-27B-PQ2_0.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 122880
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### All presets for this file

#### `bonsai2-27b-pq2-f16` (RTX 5060 Ti 16 GB)

```ini
[bonsai2-27b-pq2-f16]
hf-repo = prism-ml/Ternary-Bonsai-2-27B-gguf
hf-file = Ternary-Bonsai-2-27B-PQ2_0.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 122880
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

#### `bonsai2-27b-pq2-q8` (RTX 5060 Ti 16 GB)

```ini
[bonsai2-27b-pq2-q8]
hf-repo = prism-ml/Ternary-Bonsai-2-27B-gguf
hf-file = Ternary-Bonsai-2-27B-PQ2_0.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 212992
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### Direct serve commands

RTX 5060 Ti 16 GB (f16 KV):

```bash
llama-server -m "$(hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PQ2_0.gguf)" \
  --alias bonsai2-27b-pq2-f16 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 122880 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8888
```

RTX 5060 Ti 16 GB (q8_0 KV):

```bash
llama-server -m "$(hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PQ2_0.gguf)" \
  --alias bonsai2-27b-pq2-q8 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 212992 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8888
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-pq2" /> | 8192 | 16384 | <ScoreCell value="0.988/0.945" sub="100% completion" top /> | none | 12/164 | <TokCell shallow="46.0" deep="14.5" /> | 1h59 |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-pq2" /> | 8192 | 16384 | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | none | 12/164 | <TokCell shallow="46.3" deep="25.1" /> | 2h01 |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-pq2" /> | 30000† | 32048 | <ScoreCell value="0.982/0.945" sub="100% completion" /> | none | 6/164 | <TokCell shallow="46.3" deep="25.1" /> | 3h03 |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-pq2" /> | 25209† | 27257 | <ScoreCell value="0.982/0.939" sub="100% completion" /> | none | 7/164 | <TokCell shallow="46.0" deep="14.5" /> | 2h56 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.

## Mendel runs

Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-pq2" model-page="/models/bonsai-2-27b" /> | blind-v1.1 | 112k | **77** | 8/8/done | 74.7 | 14,833k | 110k | 1 | 230 | 13 |  |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-pq2" model-page="/models/bonsai-2-27b" /> | blind-v1.1 | 208k | **60.5** | 8/8/done | 92.4 | 19,572k | 193k | 0 | 245 | 16 |  |
