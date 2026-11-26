---
editLink: false
generated: true
---

# Ternary-Bonsai-27B Q2_g64 (prism-ml, prism fork)

| Field | Value |
|---|---|
| Model | [Ternary-Bonsai-27B](/models/bonsai-27b) |
| Quant | `Q2_g64` |
| Publisher | prism-ml |
| Server | `prism-llama` |
| Hugging Face Repo | [prism-ml/Ternary-Bonsai-27B-gguf](https://huggingface.co/prism-ml/Ternary-Bonsai-27B-gguf) |
| File | `Ternary-Bonsai-27B-Q2_g64.gguf` |
| Pinned Revision | unpinned |
| Tested On | [M1 Max 32 GB](/setups/m1-max-32gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/files/bonsai-prism-q2g64" top /> | 33k | <TokCell shallow="14.7" deep="7.8" cap="speed" top-deep /> | **9.6 GB** | <ScoreCell value="0.951/0.915" sub="100% completion" top /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 9h11 · Mendel 5h00"><b>14h11</b></span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/files/bonsai-prism-q2g64" top /> | **2x48k** | <TokCell shallow="14.9" deep="7.8" cap="speed" stale top-shallow top-deep /> | **10.9 GB** | <ScoreCell value="0.951/0.915" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 9h11 · Mendel —">9h11†</span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/bonsai-prism-q2g64" /> | **131k** | <TokCell shallow="15.0" deep="9.7" cap="mem" stale top-shallow top-deep /> | 18.6 GB | <ScoreCell value="pending" /> | <ScoreCell value="12.5" note="13%" pill="mendel-guided" top /> | <span title="EvalPlus — · Mendel 3h15">3h15†</span> |

## Serve presets

Best served preset (M1 Max 32 GB, `prism-llama`, pi id `bonsai-27b-q2g64-q4bias`):

```ini
[bonsai-27b-q2g64-q4bias]
n-gpu-layers = 999
flash-attn = on
ctx-size = 65536
parallel = 1
cache-type-k = q4_0
cache-type-v = q4_0
kv-mean-center = ~/.local/share/choose-a-local-llm/Ternary-Bonsai-27B-kv-bias.gguf
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### All presets for this file

#### `bonsai-27b-q2g64-q4bias` (M1 Max 32 GB)

```ini
[bonsai-27b-q2g64-q4bias]
n-gpu-layers = 999
flash-attn = on
ctx-size = 65536
parallel = 1
cache-type-k = q4_0
cache-type-v = q4_0
kv-mean-center = ~/.local/share/choose-a-local-llm/Ternary-Bonsai-27B-kv-bias.gguf
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

#### `bonsai-27b-q2g64-f16` (M1 Max 32 GB)

```ini
[bonsai-27b-q2g64-f16]
n-gpu-layers = 999
flash-attn = on
ctx-size = 131072
parallel = 1
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### Direct serve commands

M1 Max 32 GB (q4_0+bias KV):

```bash
LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server \
  -m ~/.cache/huggingface/hub/models--prism-ml--Ternary-Bonsai-27B-gguf/snapshots/<rev>/Ternary-Bonsai-27B-Q2_g64.gguf \
  --alias bonsai-27b-q2g64-q4bias \
  -ngl 999 -fa on -c 65536 --parallel 1 \
  --cache-type-k q4_0 --cache-type-v q4_0 \
  --kv-mean-center ~/.local/share/choose-a-local-llm/Ternary-Bonsai-27B-kv-bias.gguf \
  --jinja --port 8081
```

M1 Max 32 GB (q4_0+bias KV):

```bash
LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server \
  -m ~/.cache/huggingface/hub/models--prism-ml--Ternary-Bonsai-27B-gguf/snapshots/<rev>/Ternary-Bonsai-27B-Q2_g64.gguf \
  --alias bonsai-prism-2x \
  -ngl 999 -fa on -c 98304 --parallel 2 \
  --cache-type-k q4_0 --cache-type-v q4_0 \
  --kv-mean-center ~/.local/share/choose-a-local-llm/Ternary-Bonsai-27B-kv-bias.gguf \
  --jinja --port 8081
```

M1 Max 32 GB (f16 KV):

```bash
LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server \
  -m ~/.cache/huggingface/hub/models--prism-ml--Ternary-Bonsai-27B-gguf/snapshots/<rev>/Ternary-Bonsai-27B-Q2_g64.gguf \
  --alias bonsai-27b-q2g64-f16 \
  -ngl 999 -fa on -c 131072 --parallel 1 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/files/bonsai-prism-q2g64" /> | 8192 | 16384 | <ScoreCell value="0.951/0.915" sub="100% completion" top /> | none | 4/164 | <TokCell shallow="14.7" deep="7.8" /> | 9h11 |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/files/bonsai-prism-q2g64" /> | —† | 10240 | <ScoreCell value="0.927/0.890" sub="98% completion" /> | 4 budget | — | <TokCell shallow="14.7" deep="7.8" /> | 9h55 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.

## Mendel runs

Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/files/bonsai-prism-q2g64" model-page="/models/bonsai-27b" /> | blind-v1.1 | 64k | **12.5** (raw 60.5) | 1/8/done | 43.1 | 1,718k | 51k | 0 | 76 | 2 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/files/bonsai-prism-q2g64" model-page="/models/bonsai-27b" /> | guided-v3.0 | 64k | **31.5** | 3/8/partial | 300.0 | 0k | 63k | 10 | 343 | 3 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/bonsai-prism-q2g64" model-page="/models/bonsai-27b" /> | guided-v3.0 | 128k | **12.5** | 1/8/partial | 194.7 | 21,049k | 127k | 1 | 376 | 2 |  |
