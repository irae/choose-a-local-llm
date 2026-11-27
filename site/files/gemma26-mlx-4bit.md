---
editLink: false
generated: true
---

# Gemma-4-26B-A4B MLX 4-bit (mlx-community)

| Field | Value |
|---|---|
| Model | [Gemma-4-26B-A4B](/models/gemma-4-26b-a4b) |
| Quant | `4-bit` |
| Publisher | mlx-community |
| Server | `mlx_lm.server` |
| Hugging Face Repo | [mlx-community/gemma-4-26b-a4b-it-4bit](https://huggingface.co/mlx-community/gemma-4-26b-a4b-it-4bit) |
| File | `MLX 4-bit` |
| Pinned Revision | unpinned |
| Tested On | [M1 Max 32 GB](/setups/m1-max-32gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/gemma-4-26b-a4b-it-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-mlx-4bit" /> 💀 | ***66k*** | ****49.3*** → ***23.4***, mem* | ***20.0 GB*** | <ScoreCell value="0.793/0.768" sub="81% completion" top /> | <ScoreCell value="0" note="0%" pill="failed-smoke" /> | <span title="EvalPlus 9h06 · Mendel —">9h06†</span> |

💀 This MLX build is retired here: it failed the agent smoke on a truncated tool call, while the GGUF build of the same model completes the task. [Details](/setups/m1-max-32gb/archive#gemma-4-26b-a4b-mlx).

## Serve presets


### Direct serve commands

M1 Max 32 GB (f16 KV):

```bash
mlx_lm.server --model mlx-community/gemma-4-26b-a4b-it-4bit \
  --prompt-cache-size 2 --port 8081
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-26B-A4B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/gemma-4-26b-a4b-it-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/gemma26-mlx-4bit" /> | —† | 30000 | <ScoreCell value="0.793/0.768" sub="81% completion" /> | 31 budget | — | <TokCell shallow="49.3" deep="23.4" /> | 9h06 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.

## Mendel runs

No Mendel run yet.
