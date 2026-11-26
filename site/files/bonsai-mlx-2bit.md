---
editLink: false
generated: true
---

# Ternary-Bonsai-27B MLX 2-bit (prism-ml)

| Field | Value |
|---|---|
| Model | [Ternary-Bonsai-27B](/models/bonsai-27b) |
| Quant | `2-bit` |
| Publisher | prism-ml |
| Server | `mlx_lm.server` |
| Hugging Face Repo | [prism-ml/Ternary-Bonsai-27B-mlx-2bit](https://huggingface.co/prism-ml/Ternary-Bonsai-27B-mlx-2bit) |
| File | `MLX 2-bit` |
| Pinned Revision | unpinned |
| Tested On | [M1 Max 32 GB](/setups/m1-max-32gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/bonsai-mlx-2bit" top /> | **40k** | <TokCell shallow="24.5" deep="17.3" cap="mem" stale top-shallow top-deep /> | **22.5 GB** | <ScoreCell value="0.933/0.902" sub="99% completion" top /> | <ScoreCell value="37.5†" note="38%" pill="mendel-blind" top /> | <span title="EvalPlus 19h24 · Mendel 5h00"><b>24h24</b></span> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/bonsai-mlx-2bit" /> | **40k** | <TokCell shallow="24.5" deep="17.3" cap="mem" stale top-shallow top-deep /> | **22.5 GB** | <ScoreCell value="0.927/0.902" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 0h46 · Mendel 3h07"><b>3h53</b></span> |

## Serve presets


### Direct serve commands

M1 Max 32 GB (f16 KV):

```bash
mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit \
  --prompt-cache-size 2 --port 8081
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/bonsai-mlx-2bit" /> | —† | 10240 | <ScoreCell value="0.933/0.902" sub="99% completion" /> | 2 budget | — | <TokCell shallow="24.5" deep="17.3" /> | 19h24 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.

## Mendel runs

Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/bonsai-mlx-2bit" model-page="/models/bonsai-27b" /> | blind-v1.0 | 56k | **37.5** (raw 58) | 3/8/partial | 101.8 | 887k | 28k | 0 | 53 | 3 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/bonsai-mlx-2bit" model-page="/models/bonsai-27b" /> | blind-v1.1 | 56k | **37.5** (raw 55) | 3/8/partial | 300.0 | 3,555k | 52k | 0 | 135 | 4 | thinking |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/bonsai-mlx-2bit" model-page="/models/bonsai-27b" /> | guided-v2.1 | 56k | **37.5** (raw 69) | 3/8/partial | 230.3 | 2,142k | 51k | 0 | 94 | 3 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/bonsai-mlx-2bit" model-page="/models/bonsai-27b" /> | guided-v3.0 | 56k | **12.5** (raw 59) | 1/8/partial | 300.0 | 3,619k | 46k | 0 | 122 | 1 |  |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/bonsai-mlx-2bit" model-page="/models/bonsai-27b" /> | guided-v3.0 | 56k | **0** (raw 25) | 0/8/model-failed | 186.9 | 1,969k | 27k | 0 | 105 | 0 | tool call |
