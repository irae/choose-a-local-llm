# Exact revisions of every model file on this machine

Run 2, session 1, 2026-09-04. Section A asks for pinned HF revisions,
because quant makers replace files silently and every published number
depends on the exact file that was measured.

These are the commits actually in the cache right now, read from
`~/.cache/huggingface/hub/models--*/refs/main`. Size is the blob store,
so it shows what is really downloaded rather than what the repo holds.

| Repo | Revision in the cache | Cached size |
| --- | --- | --- |
| `bartowski/Qwen3.8-27B-GGUF` | `f0eec4a4bb4975114a030d048952d83c0a53c034` | 18.7 GB |
| `lmstudio-community/gemma-4-12B-it-MLX-4bit` | `f45bda5639cf187cd5f127a5484813f5f1e3a6ad` | 0.6 GB |
| `mlx-community/Qwen3.6-35B-A3B-4bit` | `38740b847e4cb78f352aba30aa41c76e08e6eb46` | 20.4 GB |
| `mlx-community/Qwen3.8-27B-4bit` | `3e6447f082e89cc7f0bc6e5441afd38dfce760ff` | 16.1 GB |
| `mlx-community/Qwen3.8-27B-MTP-4bit` | `b643c01b6d3b094e325edb6ebd832e16c486c575` | 0.3 GB |
| `mlx-community/gemma-4-12B-it-4bit` | `73bcf09092aa277861d5a191b989b666f7f32e8f` | 6.8 GB |
| `mlx-community/gemma-4-12B-it-qat-OptiQ-4bit` | `63912b888c04ba2c555f198685d10b05f54cf564` | 0.0 GB |
| `mlx-community/gemma-4-26b-a4b-it-4bit` | `0d77464eeb233a2da68ebf9d7dc4edaac7db956d` | 15.4 GB |
| `prism-ml/Ternary-Bonsai-27B-gguf` | `abbae723028d71be674e71e1a71201a6f43fab22` | 31.2 GB |
| `prism-ml/Ternary-Bonsai-27B-mlx-2bit` | `70f75f3ad081ab840a42f3304c02c27e7f89bfb7` | 8.5 GB |
| `unsloth/Qwen3.6-35B-A3B-MTP-GGUF` | `5bc3e238d916f48a861bac2f8a1990a0e9b7e98d` | 23.0 GB |
| `unsloth/gemma-4-12b-it-GGUF` | `fc034cfff751157913579611efad8462ac1be606` | 8.0 GB |
| `unsloth/gemma-4-26b-a4b-it-GGUF` | `c099eb48e663fd284577b04978a94ffccb261841` | 17.5 GB |

## Two rows that need reading carefully

**`lmstudio-community/gemma-4-12B-it-MLX-4bit` at 0.6 GB.** The weights
are not in the HF cache. LM Studio keeps its own copy in
`~/.cache/lm-studio/models/lmstudio-community/gemma-4-12B-it-MLX-4bit/`,
about 6.3 GB, and that directory carries **no revision reference at
all**. Every Gemma-12B LM Studio measurement was made against a copy
whose upstream commit the machine does not record. The two templates in
that folder are documented in `container-audit.md`; hashing them is the
only identity it has.

**`mlx-community/gemma-4-12B-it-qat-OptiQ-4bit` at 0.0 GB.** Only
`config.json` was ever fetched. It is not a usable model here, and the
8-bit `embed_tokens` comparison in `container-audit.md` rests on that
config file alone.

## How to use this

Pin the revision in any command that fetches: `-hf repo:quant` accepts a
revision, and `mlx_lm` and `huggingface_hub` take `revision=`. When a
published row is re-measured, check the revision here first. If it
differs from the one in this table, the row was measured on a different
file and the comparison is not like for like.

This table is a snapshot of 2026-09-04. Regenerate it rather than trust
it after any download.
