---
editLink: false
generated: true
---

# Gemma-4-12B UD-Q4_K_XL (unsloth)

| Field | Value |
|---|---|
| Model | [Gemma-4-12B](/models/gemma-4-12b-it) |
| Quant | `UD-Q4_K_XL` |
| Publisher | unsloth |
| Server | `llama-server` |
| Hugging Face Repo | [unsloth/gemma-4-12b-it-GGUF](https://huggingface.co/unsloth/gemma-4-12b-it-GGUF) |
| File | `gemma-4-12b-it-UD-Q4_K_XL.gguf` |
| Pinned Revision | unpinned |
| Tested On | [M1 Max 32 GB](/setups/m1-max-32gb/), [RTX 5060 Ti 16 GB](/setups/rtx-5060ti-16gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma12-unsloth-ud-q4kxl" top /> | **245k** | <TokCell shallow="25.0" deep="9.2" cap="mem" /> | **13.9 GB** | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" top /> | <span title="EvalPlus 0h43 · Mendel 1h38"><b>2h21</b></span> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-unsloth-ud-q4kxl" /> | **261k** | <TokCell shallow="47.39" deep="32.18" cap="mem" top-shallow top-deep /> | **12.7 GB** | <ScoreCell value="0.988/0.963" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 3h18 · Mendel 0h05"><b>3h23</b></span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma12-unsloth-ud-q4kxl" top /> | 2x82k | <TokCell shallow="25.0" deep="15.7" cap="mem" stale /> | **13.8 GB** | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma12-unsloth-ud-q4kxl" top /> | 4x49k | <TokCell shallow="42.9" deep="27.7" cap="mem" stale top-shallow top-deep /> | 25.1 GB | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" drafter="mtp/4" kv="q8_0" effort="off" hardware="m1-max-32gb" page="/files/gemma12-unsloth-ud-q4kxl" top /> | 16k | <TokCell shallow="13.8" deep="6.5" cap="speed" stale /> | **10.5 GB** | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 0h43 · Mendel —">0h43†</span> |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/files/gemma12-unsloth-ud-q4kxl" top /> | **261k** | <TokCell shallow="47.39" deep="32.18" cap="mem" top-shallow top-deep /> | **12.7 GB** | <ScoreCell value="0.951/0.909" sub="100% completion" /> | <ScoreCell value="not run" /> | <span title="EvalPlus 0h26 · Mendel —">0h26†</span> |

## Serve presets

Best served preset (M1 Max 32 GB, `llama-server`, pi id `gemma-4-12b-q4kxl`):

```ini
[gemma-4-12b-q4kxl]
hf = unsloth/gemma-4-12b-it-GGUF:Q4_K_XL
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 262144
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### All presets for this file

#### `gemma-4-12b-q4kxl` (M1 Max 32 GB)

```ini
[gemma-4-12b-q4kxl]
hf = unsloth/gemma-4-12b-it-GGUF:Q4_K_XL
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 262144
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

#### `gemma-4-12b-q4kxl-2slot` (M1 Max 32 GB)

```ini
[gemma-4-12b-q4kxl-2slot]
hf = unsloth/gemma-4-12b-it-GGUF:Q4_K_XL
no-mmproj = true
parallel = 2
n-gpu-layers = 999
flash-attn = on
ctx-size = 196608
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### Direct serve commands

M1 Max 32 GB (f16 KV):

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b-q4kxl --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 262144 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

RTX 5060 Ti 16 GB (f16 KV):

```bash
llama-server -m "$(hf download unsloth/gemma-4-12b-it-GGUF gemma-4-12b-it-UD-Q4_K_XL.gguf)" \
  --alias gemma-4-12b-q4kxl --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 262144 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8888
```

M1 Max 32 GB (f16 KV):

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b-q4kxl-2slot --no-mmproj --parallel 2 \
  -ngl 999 -fa on -c 196608 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

M1 Max 32 GB (f16 KV, mtp/4):

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b-4x --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 4 --parallel 4 \
  -ngl 999 -fa on -c 655360 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

M1 Max 32 GB (q8_0 KV, mtp/4):

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 4 --parallel 1 \
  -ngl 999 -fa on -c 262144 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-unsloth-ud-q4kxl" /> | 8192 | 16384 | <ScoreCell value="0.988/0.963" sub="100% completion" top /> | none | 34/164 | <TokCell shallow="47.39" deep="32.18" /> | 3h18 |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma12-unsloth-ud-q4kxl" /> | none | 8192 | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | none | — | <TokCell shallow="25.0" deep="9.2" /> | 0h43 |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/files/gemma12-unsloth-ud-q4kxl" /> | none | 8192 | <ScoreCell value="0.951/0.909" sub="100% completion" /> | none | — | <TokCell shallow="47.39" deep="32.18" /> | 0h26 |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-unsloth-ud-q4kxl" /> | —† | 8192 | <ScoreCell value="0.793/0.780" sub="79% completion" /> | † unproven | — | <TokCell shallow="47.39" deep="32.18" /> | 4h19 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.

## Mendel runs

Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma12-unsloth-ud-q4kxl" model-page="/models/gemma-4-12b-it" /> | blind-v1.1 | 256k | **0** | 0/8/model-failed | 80.3 | 9,994k | 179k | 0 | 92 | 0 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma12-unsloth-ud-q4kxl" model-page="/models/gemma-4-12b-it" /> | guided-v3.0 | 256k | **37.5** (raw 58) | 3/8/partial | 97.6 | 6,453k | 125k | 0 | 132 | 3 | text |
| <ModelSpec base="Gemma-4-12B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/files/gemma12-unsloth-ud-q4kxl" model-page="/models/gemma-4-12b-it" /> | guided-v3.0 | 256k | **0** (raw 34) | 0/8/model-failed | 5.3 | 213k | 25k | 0 | 17 | 0 | thinking |
