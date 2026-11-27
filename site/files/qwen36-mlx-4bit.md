---
editLink: false
generated: true
---

# Qwen3.6-35B-A3B MLX 4-bit (mlx-community)

| Field | Value |
|---|---|
| Model | [Qwen3.6-35B-A3B](/models/qwen3.6-35b-a3b) |
| Quant | `4-bit` |
| Publisher | mlx-community |
| Server | `mlx_lm.server` |
| Hugging Face Repo | [mlx-community/Qwen3.6-35B-A3B-4bit](https://huggingface.co/mlx-community/Qwen3.6-35B-A3B-4bit) |
| File | `MLX 4-bit` |
| Pinned Revision | unpinned |
| Tested On | [M1 Max 32 GB](/setups/m1-max-32gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/qwen36-mlx-4bit" top /> | **37k** | <TokCell shallow="54.5" deep="39.1" cap="mem" top-shallow top-deep /> | **24.6 GB** | <ScoreCell value="0.957/0.939" sub="99% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" top /> | <span title="EvalPlus 5h02 · Mendel 0h19"><b>5h20</b></span> |

## Serve presets


### Direct serve commands

M1 Max 32 GB (f16 KV):

```bash
mlx_lm.server --model mlx-community/Qwen3.6-35B-A3B-4bit \
  --prompt-cache-size 2 --port 8081
```

## HumanEval+ runs

No EvalPlus run yet.

## Mendel runs

Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/qwen36-mlx-4bit" model-page="/models/qwen3.6-35b-a3b" /> | blind-v1.1 | 32k | **37.5** | 3/8/partial | 18.5 | 1,318k | 31k | 1 | 63 | 3 |  |
