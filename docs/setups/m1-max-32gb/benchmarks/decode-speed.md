# Decode speed vs context depth — M1 Max 32 GB

The first test every config runs: how fast the model decodes as the
*used* context grows, down to the 8 tok/s usability floor. The community
measures the same thing as llama.cpp's `llama-bench` token-generation
("tg") rate at depth; our method adds the slow-creep rule and the memory
watcher — see [the method](../../../methodology/context-creep).

| model | best curve | shallow → deep | gated by |
|---|---|--:|---|
| [Qwen3.6-35B-A3B](./qwen3.6-35b-a3b.md) | GGUF, MTP q8 | 44† → 8.1† at 90K | speed |
| [Gemma-4-12B](./gemma-4-12b-it.md) | MLX (LM Studio) | 37† → 29.29 at 65K | mem (compression onset) |
| [Gemma-4-26B-A4B](./gemma-4-26b-a4b.md) | MLX | 51 → 12.8 at 70K | mem |
| [Ternary-Bonsai-27B](./bonsai-27b.md) | MLX | 24.5 → 17.27 at 58K | mem |
| [Qwen3.8-27B](./qwen3.8-27b.md) | MLX | 17 → 15.3 at 28K | mem |

† from an earlier serving config or method; re-run pending.

Full per-model curves, every config and every depth step, live on the
per-model data pages linked in the first column (also linked from each
model page). Current per-config verdicts are on
[the comparison page](../comparison.md).
