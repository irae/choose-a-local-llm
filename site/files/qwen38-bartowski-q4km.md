---
editLink: false
generated: true
---

# Qwen3.8-27B Q4_K_M (bartowski)

| Field | Value |
|---|---|
| Model | [Qwen3.8-27B](/models/qwen3.8-27b) |
| Quant | `Q4_K_M` |
| Publisher | bartowski |
| Server | `llama-server` |
| Hugging Face Repo | [bartowski/Qwen3.8-27B-GGUF](https://huggingface.co/bartowski/Qwen3.8-27B-GGUF) |
| File | `Qwen3.8-27B-Q4_K_M.gguf` |
| Pinned Revision | unpinned |
| Tested On | [M1 Max 32 GB](/setups/m1-max-32gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/qwen38-bartowski-q4km" top /> | **72k** | <TokCell shallow="12.4" deep="9.7" cap="mem" top-shallow top-deep /> | **25.0 GB** | <ScoreCell value="0.982/0.951" sub="100% completion" top /> | <ScoreCell value="93" pill="mendel-blind" top /> | <span title="EvalPlus 5h04 · Mendel 3h33"><b>8h38</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="medium" hardware="m1-max-32gb" page="/files/qwen38-bartowski-q4km" top /> | **72k** | <TokCell shallow="12.4" deep="9.7" cap="mem" top-shallow top-deep /> | **25.0 GB** | <ScoreCell value="0.982/0.939†" sub="100% completion" top /> | <ScoreCell value="87" pill="mendel-blind" top /> | <span title="EvalPlus 3h32 · Mendel 2h09"><b>5h42</b></span> |

## Serve presets

Best served preset (M1 Max 32 GB, `llama-server`, pi id `qwen3.8-27b-q4km`):

```ini
[qwen3.8-27b-q4km]
hf = bartowski/Qwen3.8-27B-GGUF:Q4_K_M
no-mmproj = true
parallel = 1
n-gpu-layers = 999
flash-attn = on
ctx-size = 73728
cache-type-k = f16
cache-type-v = f16
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```

### Direct serve commands

M1 Max 32 GB (f16 KV):

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 73728 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

M1 Max 32 GB (f16 KV):

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b-q4km --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 73728 \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/qwen38-bartowski-q4km" /> | 8192 | 16384 | <ScoreCell value="0.982/0.951" sub="100% completion" top /> | none | 9/164 | <TokCell shallow="12.4" deep="9.7" /> | 5h04 |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/qwen38-bartowski-q4km" /> | 30000† | 32048 | <ScoreCell value="0.982/0.951" sub="100% completion" /> | none | 3/164 | <TokCell shallow="12.4" deep="9.7" /> | 7h29 |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/qwen38-bartowski-q4km" /> | —† | 30000 | <ScoreCell value="0.957/0.939" sub="96% completion" /> | 6 budget | — | <TokCell shallow="12.4" deep="9.7" /> | 8h30 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.

## Mendel runs

Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/files/qwen38-bartowski-q4km" model-page="/models/qwen3.8-27b" /> | blind-v1.1 | 64k | **93** | 8/8/done | 213.3 | 10,077k | 62k | 3 | 272 | 17 |  |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/files/qwen38-bartowski-q4km" model-page="/models/qwen3.8-27b" /> | blind-v1.1 | 48k | **87** | 8/8/done | 129.3 | 5,947k | 46k | 4 | 210 | 10 |  |
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/files/qwen38-bartowski-q4km" model-page="/models/qwen3.8-27b" /> | blind-v1.1 | 64k | **76** | 8/8/done | 97.8 | 5,008k | 60k | 1 | 173 | 12 |  |
