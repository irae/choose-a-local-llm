---
editLink: false
generated: true
---

# Ternary-Bonsai-2-27B MLX 2-bit (prism-ml, custom wrapper)

| Field | Value |
|---|---|
| Model | [Ternary-Bonsai-2-27B](/models/bonsai-2-27b) |
| Quant | `MLX 2-bit` |
| Publisher | prism-ml |
| Server | `mlx` |
| Hugging Face Repo | [prism-ml/Ternary-Bonsai-2-27B-mlx-2bit](https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-mlx-2bit) |
| File | `MLX 2-bit` |
| Pinned Revision | `3f926b4` |
| Tested On | [M1 Max 32 GB](/setups/m1-max-32gb/) |

## Served configurations

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="MLX 2-bit" server="mlx" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-mlx-2bit" adapter="bonsai2-mlx-server.py" kv="f16" effort="on" hardware="m1-max-32gb" page="/files/bonsai2-prism-mlx-2bit" top /> | **28k** | <TokCell shallow="21.47" deep="10.45" cap="mem" top-shallow top-deep /> | **15.7 GB** | <ScoreCell value="not run" /> | <ScoreCell value="not run" /> | — |

## Serve presets


### Direct serve commands

M1 Max 32 GB (f16 KV):

```bash
BONSAI2_PACK=<pack dir> \
  BONSAI2_MANIFEST=<pack dir>/bonsai2-runtime.sha256 \
  <venv>/bin/python tools/sweeps/bonsai2-mlx-server.py
```

## HumanEval+ runs

No EvalPlus run yet.

## Mendel runs

No Mendel run yet.
