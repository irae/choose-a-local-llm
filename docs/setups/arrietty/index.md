# RTX 5060 Ti 16 GB

## Machine

- GeForce RTX 5060 Ti, 16311 MiB of VRAM, compute capability 12.0.
  12 CPU threads, 32 GB of RAM, Linux.
- The desktop shares the card: about 1.2 GB of VRAM at idle.
- Runtime: llama-server on CUDA, the `sm120` `cuda12.8` prebuilt from
  [llamaup](https://github.com/keypaa/llamaup), under
  `~/.local/share/choose-a-local-llm/llama.cpp/`.
- Port 8081. Harness: pi, provider `llama`. Aliases equal the pi model
  ids.
- Model files: `~/.cache/llama.cpp/hf/<owner>/<repo>/`, served with
  `-m`.
- `--fit off` on every command. Without it, llama.cpp shrinks the
  context or moves layers off the card.
- No wired limit. Rows record VRAM from `nvidia-smi` and the host's
  `MemAvailable`.

## Models

| model | files | reports |
|---|---|---|
| Qwen3.8-27B | `unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S`; `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF`, IQ3_S-mtp file | [report](./reports/qwen3.8-27b.md), [benchmarks](./benchmarks/qwen3.8-27b.md) |
| Qwen3.6-35B-A3B (MoE) | `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` | [report](./reports/qwen3.6-35b-a3b.md), [benchmarks](./benchmarks/qwen3.6-35b-a3b.md) |
| Gemma-4-26B-A4B (MoE) | `catlilface/Gemma-4-26B-A4B-NVFP4-GGUF`, NVFP4Q8 file | [report](./reports/gemma-4-26b-a4b.md), [benchmarks](./benchmarks/gemma-4-26b-a4b.md) |
| Gemma-4-12B-it | `FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF`; `unsloth/gemma-4-12b-it-GGUF:UD-Q4_K_XL` | [report](./reports/gemma-4-12b-it.md), [benchmarks](./benchmarks/gemma-4-12b-it.md) |

- The NVFP4 files are community repacks.
- Thinking: Gemma 4, `enable_thinking`, default off. Qwen3.6, binary,
  default on. Qwen3.8, effort `low`, `medium` or `xhigh`; medium is
  not run.

## Runs

- Run 17, 2026-09-13 to 2026-09-15: speed, drafter arms, agent task.
  `hardware/arrietty/benchmarks/bench17/` in the repo.
- Run 19, from 2026-09-15: EvalPlus on every row.
  `hardware/arrietty/benchmarks/bench19/` in the repo.
