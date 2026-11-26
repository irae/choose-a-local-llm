---
editLink: false
generated: true
---

# Gemma-4-12B MLX 4-bit (lmstudio-community, LM Studio)

| Field | Value |
|---|---|
| Model | [Gemma-4-12B](/models/gemma-4-12b-it) |
| Quant | `4-bit` |
| Publisher | lmstudio-community |
| Server | `lms` |
| Hugging Face Repo | [lmstudio-community/gemma-4-12B-it-MLX-4bit](https://huggingface.co/lmstudio-community/gemma-4-12B-it-MLX-4bit) |
| File | `MLX 4-bit` |
| Pinned Revision | unpinned |
| Tested On | [M1 Max 32 GB](/setups/m1-max-32gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma12-lmstudio-mlx-4bit" /> 💀 | ***131k*** | ****34.19*** → ***23.23***, mem* | ***17.2 GB*** | <ScoreCell value="0.909/0.872" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="model-failed" /> | <span title="EvalPlus 1h33 · Mendel —">1h33†</span> |

💀 LM Studio is retired here: three agent runs, zero commits, a window that cannot be pinned. [Details](/setups/m1-max-32gb/archive#lm-studio).

Retired (M1 Max 32 GB): Gemma-4-12B, LM Studio entry google/gemma-4-12b — thinking-on repetition loop; entry gone from the model store ([archive](/setups/m1-max-32gb/archive#lm-studio)).

## Serve presets


### Direct serve commands

M1 Max 32 GB (f16 KV):

```bash
~/.cache/lm-studio/bin/lms server start --port 8081
~/.cache/lm-studio/bin/lms load gemma-4-12b-it-mlx --parallel 4 --gpu max -y
```

## HumanEval+ runs

| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="off" hardware="m1-max-32gb" page="/files/gemma12-lmstudio-mlx-4bit" /> | none | 30000 | <ScoreCell value="0.909/0.872" sub="100% completion" top /> | none | — | <TokCell shallow="34.19" deep="23.23" /> | 1h33 |

## Mendel runs

Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="high" hardware="m1-max-32gb" page="/files/gemma12-lmstudio-mlx-4bit" model-page="/models/gemma-4-12b-it" /> | blind-v1.1 | 144k | **0** (raw 30.5) | 0/8/model-failed | 49.5 | 218k | 28k | 0 | 15 | 0 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="high" hardware="m1-max-32gb" page="/files/gemma12-lmstudio-mlx-4bit" model-page="/models/gemma-4-12b-it" /> | guided-v3.0 | 160k | **0** (raw 30) | 0/8/model-failed | 46.0 | 306k | 30k | 0 | 21 | 0 |  |
| <ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="low" hardware="m1-max-32gb" page="/files/gemma12-lmstudio-mlx-4bit" model-page="/models/gemma-4-12b-it" /> | guided-v3.0 | 160k | **0** (raw 29.5) | 0/8/model-failed | 99.0 | 1,971k | 45k | 3 | 130 | 0 | tool call |
