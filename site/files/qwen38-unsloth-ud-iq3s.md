---
editLink: false
generated: true
---

# Qwen3.8-27B UD-IQ3_S (unsloth)

| Field | Value |
|---|---|
| Model | [Qwen3.8-27B](/models/qwen3.8-27b) |
| Quant | `UD-IQ3_S` |
| Publisher | unsloth |
| Server | `llama-server` |
| Hugging Face Repo | [unsloth/Qwen3.8-27B-GGUF](https://huggingface.co/unsloth/Qwen3.8-27B-GGUF) |
| File | `Qwen3.8-27B-UD-IQ3_S.gguf` |
| Pinned Revision | `4ca7207` |
| Tested On | [M1 Max 32 GB](/setups/m1-max-32gb/), [RTX 5060 Ti 16 GB](/setups/rtx-5060ti-16gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/qwen38-unsloth-ud-iq3s" top /> | **147k** | <TokCell shallow="13.60" deep="7.97" cap="speed" top-shallow top-deep /> | **25.5 GB** | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | <ScoreCell value="90.5" pill="mendel-blind" top /> | <span title="EvalPlus 6h29 · Mendel 3h05"><b>9h34</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/qwen38-unsloth-ud-iq3s" top /> | **65k** | <TokCell shallow="29.36" deep="20.92" cap="mem" top-shallow top-deep /> | **14.2 GB** | <ScoreCell value="0.963/0.921" sub="100% completion" top /> | <ScoreCell value="79" note="88%" pill="mendel-guided" top /> | <span title="EvalPlus 3h08 · Mendel 4h46"><b>7h54</b></span> |

## Serve presets

Best served preset (M1 Max 32 GB, `llama-server`, pi id `qwen3.8-27b-iq3s-f16`):

```ini
[qwen3.8-27b-iq3s-f16]
hf = unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 188416
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### All presets for this file

#### `qwen3.8-27b-iq3s-f16` (M1 Max 32 GB)

```ini
[qwen3.8-27b-iq3s-f16]
hf = unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 188416
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

#### `qwen3.8-27b-iq3s-q8` (RTX 5060 Ti 16 GB)

```ini
[qwen3.8-27b-iq3s-q8]
hf-repo = unsloth/Qwen3.8-27B-GGUF
hf-file = Qwen3.8-27B-UD-IQ3_S.gguf
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

M1 Max 32 GB (f16 KV):

```bash
llama-server -hf unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S \
  --alias qwen3.8-27b-iq3s-f16 --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 188416 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

RTX 5060 Ti 16 GB (q8_0 KV):

```bash
llama-server -m "$(hf download unsloth/Qwen3.8-27B-GGUF Qwen3.8-27B-UD-IQ3_S.gguf)" \
  --alias qwen3.8-27b-iq3s-q8 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 65536 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8888
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/qwen38-unsloth-ud-iq3s" /> | 8192 | 16384 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | 17/164 | <TokCell shallow="13.60" deep="7.97" /> | 6h29 |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/qwen38-unsloth-ud-iq3s" /> | 8192 | 16384 | <ScoreCell value="0.963/0.921" sub="100% completion" top /> | none | 8/164 | <TokCell shallow="29.36" deep="20.92" /> | 3h08 |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/qwen38-unsloth-ud-iq3s" /> | —† | 19000 | <ScoreCell value="0.957/0.921" sub="98% completion" /> | † unproven | — | <TokCell shallow="29.36" deep="20.92" /> | 4h50 |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/qwen38-unsloth-ud-iq3s" /> | —† | 20000 | <ScoreCell value="0.945/0.927" sub="95% completion" /> | 8 budget | — | <TokCell shallow="13.60" deep="7.97" /> | 13h36 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.

## Mendel runs

Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/qwen38-unsloth-ud-iq3s" model-page="/models/qwen3.8-27b" /> | blind-v1.1 | 144k | **90.5** | 8/8/done | 185.4 | 15,060k | 143k | 1 | 240 | 19 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/qwen38-unsloth-ud-iq3s" model-page="/models/qwen3.8-27b" /> | guided-v3.0 | 64k | **79** | 7/8/partial | 285.9 | 11,327k | 58k | 35 | 332 | 7 |  |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/qwen38-unsloth-ud-iq3s" model-page="/models/qwen3.8-27b" /> | guided-v3.0 | 144k | **62.5** | 5/8/partial | 300.0 | 16,902k | 143k | 1 | 243 | 5 |  |
