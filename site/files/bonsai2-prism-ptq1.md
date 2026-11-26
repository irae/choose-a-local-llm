---
editLink: false
generated: true
---

# Ternary-Bonsai-2-27B PTQ1_0 (prism-ml, prism fork)

| Field | Value |
|---|---|
| Model | [Ternary-Bonsai-2-27B](/models/bonsai-2-27b) |
| Quant | `PTQ1_0` |
| Publisher | prism-ml |
| Server | `prism-llama` |
| Hugging Face Repo | [prism-ml/Ternary-Bonsai-2-27B-gguf](https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf) |
| File | `Ternary-Bonsai-2-27B-PTQ1_0.gguf` |
| Pinned Revision | `6ed5e12` |
| Tested On | [RTX 5060 Ti 16 GB](/setups/rtx-5060ti-16gb/), [M1 Max 32 GB](/setups/m1-max-32gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-ptq1" top /> | 135k | <TokCell shallow="42.1" deep="22.4" cap="mem" top-shallow top-deep /> | **15.0 GB** | <ScoreCell value="0.976/0.945" sub="100% completion" /> | <ScoreCell value="82" pill="mendel-blind" top /> | <span title="EvalPlus 2h05 · Mendel 1h28"><b>3h33</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-ptq1" top /> | 135k | <TokCell shallow="40.8" deep="22.0" cap="mem" top-shallow top-deep /> | **15.0 GB** | <ScoreCell value="0.976/0.945" sub="100% completion" /> | <ScoreCell value="75" pill="mendel-blind" top /> | <span title="EvalPlus 2h32 · Mendel 1h22"><b>3h54</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-ptq1" top /> | **240k** | <TokCell shallow="41.7" deep="12.8" cap="mem" top-shallow /> | **15.5 GB** | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | <ScoreCell value="73.5" pill="mendel-blind" /> | <span title="EvalPlus 2h20 · Mendel 2h03">4h23</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/bonsai2-prism-ptq1" /> | **160k** | <TokCell shallow="17.9" deep="9.1" cap="mem" /> | 25.5 GB | <ScoreCell value="0.988/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 4h49 · Mendel —">4h49†</span> |

## Serve presets

Best served preset (RTX 5060 Ti 16 GB, `prism-llama`, pi id `bonsai2-27b-ptq1-f16`):

```ini
[bonsai2-27b-ptq1-f16]
hf-repo = prism-ml/Ternary-Bonsai-2-27B-gguf
hf-file = Ternary-Bonsai-2-27B-PTQ1_0.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 139264
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### All presets for this file

#### `bonsai2-27b-ptq1-f16` (RTX 5060 Ti 16 GB)

```ini
[bonsai2-27b-ptq1-f16]
hf-repo = prism-ml/Ternary-Bonsai-2-27B-gguf
hf-file = Ternary-Bonsai-2-27B-PTQ1_0.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 139264
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

#### `bonsai2-27b-ptq1-f16-orca` (RTX 5060 Ti 16 GB)

```ini
[bonsai2-27b-ptq1-f16-orca]
hf-repo = prism-ml/Ternary-Bonsai-2-27B-gguf
hf-file = Ternary-Bonsai-2-27B-PTQ1_0.gguf
lora = ~/.local/share/choose-a-local-llm/OrcaBonsai-27B-Uncensored/gguf/bonsai-abliterate-lora.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 139264
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

#### `bonsai2-27b-ptq1-q8` (RTX 5060 Ti 16 GB)

```ini
[bonsai2-27b-ptq1-q8]
hf-repo = prism-ml/Ternary-Bonsai-2-27B-gguf
hf-file = Ternary-Bonsai-2-27B-PTQ1_0.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 245760
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### Direct serve commands

RTX 5060 Ti 16 GB (f16 KV):

```bash
llama-server -m "$(hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PTQ1_0.gguf)" \
  --alias bonsai2-27b-ptq1-f16 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 139264 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8888
```

RTX 5060 Ti 16 GB (f16 KV):

```bash
llama-server -m "$(hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PTQ1_0.gguf)" \
  --lora "$(D=~/.local/share/choose-a-local-llm/OrcaBonsai-27B-Uncensored; [ -d "$D" ] || git clone -q --depth 1 https://github.com/Continuum-AI-Corp/OrcaBonsai-27B-Uncensored.git "$D"; echo "$D/gguf/bonsai-abliterate-lora.gguf")" \
  --alias bonsai2-27b-ptq1-f16-orca --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 139264 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8888
```

RTX 5060 Ti 16 GB (q8_0 KV):

```bash
llama-server -m "$(hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PTQ1_0.gguf)" \
  --alias bonsai2-27b-ptq1-q8 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 245760 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8888
```

M1 Max 32 GB (f16 KV):

```bash
llama-server -m "$(hf download prism-ml/Ternary-Bonsai-2-27B-gguf Ternary-Bonsai-2-27B-PTQ1_0.gguf)" \
  --alias bonsai2-27b-ptq1-mac --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 262144 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/bonsai2-prism-ptq1" /> | 8192 | 16384 | <ScoreCell value="0.988/0.939" sub="100% completion" top /> | none | 10/164 | <TokCell shallow="17.9" deep="9.1" /> | 4h49 |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-ptq1" /> | 8192 | 16384 | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | none | 16/164 | <TokCell shallow="41.7" deep="12.8" /> | 2h20 |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-ptq1" /> | 8192 | 16384 | <ScoreCell value="0.976/0.945" sub="100% completion" /> | none | 12/164 | <TokCell shallow="42.1" deep="22.4" /> | 2h05 |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-ptq1" /> | 8192 | 16384 | <ScoreCell value="0.976/0.945" sub="100% completion" /> | none | 18/164 | <TokCell shallow="40.8" deep="22.0" /> | 2h32 |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/bonsai2-prism-ptq1" /> | 16056† | 18104 | <ScoreCell value="0.988/0.939" sub="100% completion" /> | none | 7/164 | <TokCell shallow="17.9" deep="9.1" /> | 5h37 |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-ptq1" /> | 30000† | 32048 | <ScoreCell value="0.982/0.945" sub="100% completion" /> | none | 9/164 | <TokCell shallow="41.7" deep="12.8" /> | 4h05 |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-ptq1" /> | 30000† | 32048 | <ScoreCell value="0.976/0.945" sub="100% completion" /> | none | 10/164 | <TokCell shallow="40.8" deep="22.0" /> | 4h34 |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-ptq1" /> | 30000† | 32048 | <ScoreCell value="0.970/0.939" sub="100% completion" /> | none | 6/164 | <TokCell shallow="42.1" deep="22.4" /> | 3h16 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.

## Mendel runs

Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-ptq1" model-page="/models/bonsai-2-27b" /> | blind-v1.1 | 128k | **82** | 8/8/done | 88.4 | 15,676k | 127k | 1 | 258 | 17 |  |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-ptq1" model-page="/models/bonsai-2-27b" /> | blind-v1.1 | 128k | **75** | 8/8/done | 82.0 | 17,259k | 127k | 1 | 269 | 15 |  |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/bonsai2-prism-ptq1" model-page="/models/bonsai-2-27b" /> | blind-v1.1 | 256k | **73.5** | 8/8/done | 123.1 | 25,992k | 225k | 0 | 254 | 17 |  |
