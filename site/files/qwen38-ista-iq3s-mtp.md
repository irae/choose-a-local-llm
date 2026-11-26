---
editLink: false
generated: true
---

# Qwen3.8-27B IQ3_S-mtp (ISTA-DASLab)

| Field | Value |
|---|---|
| Model | [Qwen3.8-27B](/models/qwen3.8-27b) |
| Quant | `IQ3_S-mtp` |
| Publisher | ISTA-DASLab |
| Server | `llama-server` |
| Hugging Face Repo | [ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF](https://huggingface.co/ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF) |
| File | `Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf` |
| Pinned Revision | `d562806` |
| Tested On | [M1 Max 32 GB](/setups/m1-max-32gb/), [RTX 5060 Ti 16 GB](/setups/rtx-5060ti-16gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/qwen38-ista-iq3s-mtp" top /> | 65k | <TokCell shallow="29.43" deep="21.13" cap="mem" top-shallow top-deep /> | **14.8 GB** | <ScoreCell value="0.976/0.933" sub="100% completion" top /> | <ScoreCell value="91" pill="mendel-blind" top /> | <span title="EvalPlus 2h55 · Mendel 1h15"><b>4h10</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/qwen38-ista-iq3s-mtp" top /> | **147k** | <TokCell shallow="14.1" deep="8.1" cap="speed" top-shallow top-deep /> | **24.4 GB** | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | <ScoreCell value="80.5" pill="mendel-blind" top /> | <span title="EvalPlus 5h32 · Mendel 1h49">7h21</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/files/qwen38-ista-iq3s-mtp" /> | **128k** | <TokCell shallow="15.1" deep="9.7" cap="mem" stale top-shallow top-deep /> | **24.2 GB** | <ScoreCell value="0.976/0.945†" sub="99% completion" top /> | <ScoreCell value="76.5" pill="mendel-blind" /> | <span title="EvalPlus 3h12 · Mendel 2h15"><b>5h27</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" hardware="m1-max-32gb" page="/files/qwen38-ista-iq3s-mtp" /> | **147k** | <TokCell shallow="14.1" deep="8.1" cap="speed" top-shallow top-deep /> | **24.4 GB** | <ScoreCell value="0.976/0.933†" sub="99% completion" top /> | <ScoreCell value="66" note="88%" pill="mendel-blind" /> | <span title="EvalPlus 2h27 · Mendel 2h43"><b>5h10</b></span> |

## Serve presets

Best served preset (RTX 5060 Ti 16 GB, `llama-server`, pi id `qwen3.8-27b-ista-q8`):

```ini
[qwen3.8-27b-ista-q8]
hf-repo = ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF
hf-file = Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf
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

### All presets for this file

#### `qwen3.8-27b-ista-q8` (RTX 5060 Ti 16 GB)

```ini
[qwen3.8-27b-ista-q8]
hf-repo = ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF
hf-file = Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf
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

#### `qwen3.8-27b-ista-f16` (M1 Max 32 GB)

```ini
[qwen3.8-27b-ista-f16]
hf = ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 163840
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

#### `qwen3.8-27b-ista-f16-mtp3` (M1 Max 32 GB)

```ini
[qwen3.8-27b-ista-f16-mtp3]
hf = ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp
no-mmproj = true
spec-type = draft-mtp
spec-draft-n-max = 3
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 131072
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### Direct serve commands

RTX 5060 Ti 16 GB (q8_0 KV):

```bash
llama-server -m "$(hf download ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf)" \
  --alias qwen3.8-27b-ista-q8 --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 65536 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8888
```

M1 Max 32 GB (f16 KV):

```bash
llama-server -hf ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp \
  --alias qwen3.8-27b-ista-f16 --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 163840 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

M1 Max 32 GB (f16 KV, mtp/3):

```bash
llama-server -hf ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp \
  --alias qwen3.8-27b-ista-f16-mtp3 --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 131072 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

M1 Max 32 GB (f16 KV):

```bash
llama-server -hf ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp \
  --alias qwen3.8-27b-ista --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 163840 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/qwen38-ista-iq3s-mtp" /> | 8192 | 16384 | <ScoreCell value="0.976/0.945" sub="100% completion" top /> | none | 13/164 | <TokCell shallow="14.1" deep="8.1" /> | 5h32 |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/qwen38-ista-iq3s-mtp" /> | 8192 | 10240 | <ScoreCell value="0.976/0.933" sub="100% completion" top /> | none | 11/164 | <TokCell shallow="29.43" deep="21.13" /> | 2h55 |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/files/qwen38-ista-iq3s-mtp" /> | —† | 8192 | <ScoreCell value="0.976/0.945" sub="99% completion" /> | 1 budget | — | <TokCell shallow="15.1" deep="9.7" /> | 3h12 |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" hardware="m1-max-32gb" page="/files/qwen38-ista-iq3s-mtp" /> | —† | 8192 | <ScoreCell value="0.976/0.933" sub="99% completion" /> | 1 budget | — | <TokCell shallow="14.1" deep="8.1" /> | 2h27 |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/qwen38-ista-iq3s-mtp" /> | 30000† | 32048 | <ScoreCell value="0.976/0.933" sub="100% completion" /> | none | 6/164 | <TokCell shallow="29.43" deep="21.13" /> | 4h33 |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/qwen38-ista-iq3s-mtp" /> | —† | 30000 | <ScoreCell value="0.945/0.921" sub="97% completion" /> | 5 budget | — | <TokCell shallow="14.1" deep="8.1" /> | 9h43 |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/qwen38-ista-iq3s-mtp" /> | —† | 20500 | <ScoreCell value="0.945/0.909" sub="96% completion" /> | † unproven | — | <TokCell shallow="29.43" deep="21.13" /> | 3h38 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.

## Mendel runs

Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/qwen38-ista-iq3s-mtp" model-page="/models/qwen3.8-27b" /> | blind-v1.1 | 64k | **91** | 8/8/done | 75.1 | 6,882k | 65k | 3 | 257 | 17 |  |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/qwen38-ista-iq3s-mtp" model-page="/models/qwen3.8-27b" /> | blind-v1.1 | 144k | **80.5** | 8/8/done | 109.4 | 10,819k | 118k | 0 | 193 | 17 |  |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/files/qwen38-ista-iq3s-mtp" model-page="/models/qwen3.8-27b" /> | blind-v1.1 | 112k | **76.5** | 8/8/done | 135.2 | 7,890k | 89k | 0 | 195 | 17 |  |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" hardware="m1-max-32gb" page="/files/qwen38-ista-iq3s-mtp" model-page="/models/qwen3.8-27b" /> | blind-v1.1 | 144k | **66** | 7/8/partial | 163.3 | 11,426k | 130k | 0 | 214 | 15 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/files/qwen38-ista-iq3s-mtp" model-page="/models/qwen3.8-27b" /> | guided-v3.0 | 64k | **85** | 8/8/done | 214.8 | 10,680k | 58k | 23 | 320 | 8 |  |
