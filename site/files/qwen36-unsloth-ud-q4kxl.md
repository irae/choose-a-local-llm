---
editLink: false
generated: true
---

# Qwen3.6-35B-A3B UD-Q4_K_XL (unsloth)

| Field | Value |
|---|---|
| Model | [Qwen3.6-35B-A3B](/models/qwen3.6-35b-a3b) |
| Quant | `UD-Q4_K_XL` |
| Publisher | unsloth |
| Server | `llama-server` |
| Hugging Face Repo | [unsloth/Qwen3.6-35B-A3B-MTP-GGUF](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF) |
| File | `Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf` |
| Pinned Revision | unpinned |
| Tested On | [M1 Max 32 GB](/setups/m1-max-32gb/), [RTX 5060 Ti 16 GB](/setups/rtx-5060ti-16gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/files/qwen36-unsloth-ud-q4kxl" top /> | **82k** | <TokCell shallow="43.7" deep="13.0" cap="speed" /> | **25.6 GB** | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="83" pill="mendel-guided" top /> | <span title="EvalPlus 2h27 · Mendel 1h32">3h59</span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/files/qwen36-unsloth-ud-q4kxl" top /> | **82k** | <TokCell shallow="43.7" deep="13.0" cap="speed" /> | **25.6 GB** | <ScoreCell value="0.951/0.915" sub="100% completion" top /> | <ScoreCell value="62.5" pill="mendel-guided" top /> | <span title="EvalPlus 0h15 · Mendel 1h29"><b>1h44</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/qwen36-unsloth-ud-q4kxl" top /> | 66k | <TokCell shallow="50.5" deep="33.6" cap="mem" stale /> | **25.0 GB** | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="50" pill="mendel-blind" /> | <span title="EvalPlus 2h27 · Mendel 0h33"><b>3h00</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" offload="n-cpu-moe 21" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/files/qwen36-unsloth-ud-q4kxl" top /> | **97k** | <TokCell shallow="61.16" deep="45.42" cap="mem" top-shallow top-deep /> | **14.7 GB** | <ScoreCell value="0.976/0.933" sub="100% completion" top /> | <ScoreCell value="48.5" note="75%" pill="mendel-guided" /> | <span title="EvalPlus 2h24 · Mendel 0h27"><b>2h51</b></span> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/qwen36-unsloth-ud-q4kxl" /> | 41k | <TokCell shallow="69.1" deep="52.6" cap="mem" stale top-shallow top-deep /> | **25.1 GB** | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 2h27 · Mendel —">2h27†</span> |

## Serve presets

Best served preset (M1 Max 32 GB, `llama-server`, pi id `qwen3.6-35b-a3b-q4kxl-q8-mtp3`):

```ini
[qwen3.6-35b-a3b-q4kxl-q8-mtp3]
hf = unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL
no-mmproj = true
spec-type = draft-mtp
spec-draft-n-max = 3
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 98304
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### All presets for this file

#### `qwen3.6-35b-a3b-q4kxl-q8-mtp3` (M1 Max 32 GB)

```ini
[qwen3.6-35b-a3b-q4kxl-q8-mtp3]
hf = unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL
no-mmproj = true
spec-type = draft-mtp
spec-draft-n-max = 3
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 98304
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

#### `qwen3.6-35b-a3b-q4kxl-f16` (M1 Max 32 GB)

```ini
[qwen3.6-35b-a3b-q4kxl-f16]
hf = unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 65536
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

#### `qwen3.6-35b-a3b-q4kxl-q8-mtp2` (RTX 5060 Ti 16 GB)

```ini
[qwen3.6-35b-a3b-q4kxl-q8-mtp2]
hf-repo = unsloth/Qwen3.6-35B-A3B-MTP-GGUF
hf-file = Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf
no-mmproj = true
parallel = 1
spec-type = draft-mtp
spec-draft-n-max = 2
n-gpu-layers = 999
fit = off
n-cpu-moe = 21
flash-attn = on
ctx-size = 98304
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### Direct serve commands

M1 Max 32 GB (q8_0 KV, mtp/3):

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b-q4kxl-q8-mtp3 --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 98304 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

M1 Max 32 GB (q8_0 KV, mtp/3):

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 98304 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

M1 Max 32 GB (f16 KV):

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b-q4kxl-f16 --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 65536 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

RTX 5060 Ti 16 GB (q8_0 KV, mtp/2):

```bash
llama-server -m "$(hf download unsloth/Qwen3.6-35B-A3B-MTP-GGUF Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf)" \
  --alias qwen3.6-35b-a3b-q4kxl-q8-mtp2 --no-mmproj --parallel 1 \
  --spec-type draft-mtp --spec-draft-n-max 2 \
  -ngl 999 --fit off --n-cpu-moe 21 -fa on -c 98304 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8888
```

M1 Max 32 GB (f16 KV, mtp/3):

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 40960 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/files/qwen36-unsloth-ud-q4kxl" /> | 8192 | 16384 | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | none | 17/164 | <TokCell shallow="43.7" deep="13.0" /> | 2h27 |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" offload="n-cpu-moe 21" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/files/qwen36-unsloth-ud-q4kxl" /> | 8192 | 16384 | <ScoreCell value="0.976/0.933" sub="100% completion" top /> | none | 12/164 | <TokCell shallow="61.16" deep="45.42" /> | 2h24 |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/files/qwen36-unsloth-ud-q4kxl" /> | none | 8192 | <ScoreCell value="0.951/0.915" sub="100% completion" top /> | none | — | <TokCell shallow="43.7" deep="13.0" /> | 0h15 |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/files/qwen36-unsloth-ud-q4kxl" /> | —† | 26624 | <ScoreCell value="0.957/0.939" sub="99% completion" /> | 2 budget | — | <TokCell shallow="43.7" deep="13.0" /> | 5h02 |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" offload="n-cpu-moe 21" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/files/qwen36-unsloth-ud-q4kxl" /> | —† | 24154 | <ScoreCell value="0.945/0.902" sub="96% completion" /> | † unproven | — | <TokCell shallow="61.16" deep="45.42" /> | 3h12 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.

## Mendel runs

Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" /> | blind-v1.1 | 96k | **63** | 8/8/done | 79.2 | 7,933k | 94k | 0 | 203 | 13 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" /> | blind-v1.1 | 80k | **50.5** | 8/8/done | 40.0 | 6,996k | 98k | 2 | 190 | 10 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" /> | blind-v1.1 | 64k | **50** | 8/8/done | 33.0 | 7,344k | 61k | 2 | 211 | 13 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" /> | blind-v1.0 | 96k | **41.5** | 8/8/done | 97.1 | 10,090k | 94k | 1 | 258 | 13 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" /> | guided-v3.0 | 112k | **83** | 8/8/done | 91.9 | 12,712k | 94k | 1 | 285 | 16 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" /> | guided-v2.1 | 96k | **65.5** | 8/8/done | 75.6 | 12,081k | 94k | 0 | 251 | 8 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" /> | guided-v3.0 | 80k | **62.5** | 8/8/done | 89.4 | 13,045k | 78k | 1 | 264 | 16 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" /> | guided-v3.0 | 96k | **48.5** | 6/8/partial | 27.2 | 10,958k | 86k | 1 | 266 | 6 |  |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/files/qwen36-unsloth-ud-q4kxl" model-page="/models/qwen3.6-35b-a3b" /> | guided-v3.0 | 48k | **46.5** | 8/8/done | 95.6 | 9,473k | 52k | 12 | 299 | 7 |  |
