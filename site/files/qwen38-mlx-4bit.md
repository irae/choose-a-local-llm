---
editLink: false
generated: true
---

# Qwen3.8-27B MLX 4-bit (mlx-community)

| Field | Value |
|---|---|
| Model | [Qwen3.8-27B](/models/qwen3.8-27b) |
| Quant | `4-bit` |
| Publisher | mlx-community |
| Server | `mlx_lm.server` |
| Hugging Face Repo | [mlx-community/Qwen3.8-27B-4bit](https://huggingface.co/mlx-community/Qwen3.8-27B-4bit) |
| File | `MLX 4-bit` |
| Pinned Revision | unpinned |
| Tested On | [M1 Max 32 GB](/setups/m1-max-32gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" hardware="m1-max-32gb" page="/files/qwen38-mlx-4bit" top /> | **25k** | <TokCell shallow="17.3" deep="14.8" cap="mem" top-shallow top-deep /> | **22.0 GB** | <ScoreCell value="0.976/0.927" sub="100% completion" top /> | <ScoreCell value="12.5†" note="13%" pill="mendel-blind" top /> | <span title="EvalPlus 2h09 · Mendel 1h25"><b>3h34</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" hardware="m1-max-32gb" page="/files/qwen38-mlx-4bit" top /> | **25k** | <TokCell shallow="17.3" deep="14.8" cap="mem" top-shallow top-deep /> | **22.0 GB** | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 3h32 · Mendel —">3h32†</span> |

## Serve presets


### Direct serve commands

M1 Max 32 GB (f16 KV):

```bash
mlx_lm.server --model mlx-community/Qwen3.8-27B-4bit \
  --chat-template-args '{"reasoning_effort":"low"}' --prompt-cache-size 2 --port 8081
```

M1 Max 32 GB (f16 KV):

```bash
mlx_lm.server --model mlx-community/Qwen3.8-27B-4bit \
  --reasoning-effort medium --port 8081
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" hardware="m1-max-32gb" page="/files/qwen38-mlx-4bit" /> | —† | 8192 | <ScoreCell value="0.982/0.939" sub="100% completion" /> | none | — | <TokCell shallow="17.3" deep="14.8" /> | 3h32 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.

## Mendel runs

Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" hardware="m1-max-32gb" page="/files/qwen38-mlx-4bit" model-page="/models/qwen3.8-27b" /> | blind-v1.0 | 26k | **37.5** (raw 80) | 3/8/partial | 253.5 | 1,777k | 24k | 0 | 135 | 6 |  |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" hardware="m1-max-32gb" page="/files/qwen38-mlx-4bit" model-page="/models/qwen3.8-27b" /> | blind-v1.1 | 26k | **12.5** (raw 67.5) | 1/8/partial | 85.2 | 610k | 24k | 0 | 29 | 1 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" hardware="m1-max-32gb" page="/files/qwen38-mlx-4bit" model-page="/models/qwen3.8-27b" /> | guided-v2.1 | 26k | **75** (raw 84) | 6/8/partial | 153.8 | 1,123k | 23k | 0 | 95 | 6 |  |
