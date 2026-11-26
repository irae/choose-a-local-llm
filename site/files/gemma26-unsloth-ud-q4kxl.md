---
editLink: false
generated: true
---

# Gemma-4-26B-A4B UD-Q4_K_XL (unsloth)

| Field | Value |
|---|---|
| Model | [Gemma-4-26B-A4B](/models/gemma-4-26b-a4b) |
| Quant | `UD-Q4_K_XL` |
| Publisher | unsloth |
| Server | `llama-server` |
| Hugging Face Repo | [unsloth/gemma-4-26b-a4b-it-GGUF](https://huggingface.co/unsloth/gemma-4-26b-a4b-it-GGUF) |
| File | `gemma-4-26b-a4b-it-UD-Q4_K_XL.gguf` |
| Pinned Revision | unpinned |
| Tested On | [M1 Max 32 GB](/setups/m1-max-32gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" top /> | **197k** | <TokCell shallow="60.1" deep="19.1" cap="mem" top-shallow top-deep /> | **25.6 GB** | <ScoreCell value="0.988/0.957" sub="100% completion" top /> | <ScoreCell value="47.5" pill="mendel-blind" top /> | <span title="EvalPlus 1h57 · Mendel 1h21"><b>3h18</b></span> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" top /> | **2x82k** | <TokCell shallow="66.6" deep="33.6" cap="mem" stale top-shallow top-deep /> | **25.3 GB** | <ScoreCell value="0.988/0.957" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 1h57 · Mendel —">1h57†</span> |

## Serve presets

Best served preset (M1 Max 32 GB, `llama-server`, pi id `gemma-4-26b-a4b-q4kxl-mtp2`):

```ini
[gemma-4-26b-a4b-q4kxl-mtp2]
hf = unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL
no-mmproj = true
spec-type = draft-mtp
spec-draft-n-max = 2
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 212992
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### Direct serve commands

M1 Max 32 GB (f16 KV, mtp/2):

```bash
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias gemma-4-26b-a4b-q4kxl-mtp2 --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 2 --parallel 1 \
  -ngl 999 -fa on -c 212992 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

M1 Max 32 GB (f16 KV, mtp/2):

```bash
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias gemma-4-26b-a4b-2x --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 2 --parallel 2 \
  -ngl 999 -fa on -c 202752 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" /> | 8192 | 16384 | <ScoreCell value="0.988/0.957" sub="100% completion" top /> | none | 19/164 | <TokCell shallow="60.1" deep="19.1" /> | 1h57 |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" /> | none | 8192 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | — | <TokCell shallow="60.1" deep="19.1" /> | 0h20 |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" /> | 19491† | 21539 | <ScoreCell value="0.988/0.957" sub="100% completion" /> | none | 16/164 | <TokCell shallow="60.1" deep="19.1" /> | 2h46 |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" /> | —† | 30000 | <ScoreCell value="0.896/0.872" sub="90% completion" /> | 16 budget | — | <TokCell shallow="60.1" deep="19.1" /> | 5h47 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.

## Mendel runs

Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" model-page="/models/gemma-4-26b-a4b" /> | blind-v1.1 | 208k | **47.5** | 8/8/done | 80.8 | 23,832k | 209k | 1 | 246 | 21 |  |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" model-page="/models/gemma-4-26b-a4b" /> | blind-v1.0 | 256k | **38** | 8/8/partial | 104.0 | 8,150k | 142k | 0 | 115 | 9 |  |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" model-page="/models/gemma-4-26b-a4b" /> | blind-v1.1 | 208k | **12.5** | 1/8/partial | 28.0 | 8,053k | 136k | 0 | 120 | 7 | tool call |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" model-page="/models/gemma-4-26b-a4b" /> | guided-v3.0 | 208k | **57** | 7/8/partial | 115.1 | 24,803k | 209k | 2 | 269 | 13 |  |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma26-unsloth-ud-q4kxl" model-page="/models/gemma-4-26b-a4b" /> | guided-v3.0 | 208k | **25** | 2/8/partial | 20.4 | 2,605k | 73k | 0 | 91 | 3 | tool call |
