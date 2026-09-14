# This machine — RTX 5060 Ti, 16 GB

## Highlights

- **16 GB of VRAM decides everything.** A build serves with every
  layer on the card, or a MoE build keeps part of its experts in
  host RAM. The ceiling is the largest `-c` that loads, with no
  memory compression and no swap in the way: a `-c` that does not
  fit fails at load.
- **The card runs NVFP4 natively.** llama.cpp has native NVFP4
  kernels for this GPU family, so NVFP4 builds are first-class
  candidates here, and two of the five builds under test are NVFP4.
- **One runtime, llama-server on CUDA.** No MLX, no LM Studio, no
  fork.
- **Speed and context are measured for four builds.** The first run
  on this machine is under way. The Qwen3.6 build and every agent
  cell are still pending.

## Setup

- GeForce RTX 5060 Ti, 16311 MiB, compute capability 12.0. Twelve
  CPU threads, 32 GB of RAM, Linux.
- llama.cpp: a prebuilt CUDA binary from the
  [llamaup](https://github.com/keypaa/llamaup) releases, the `sm120`
  `cuda12.8` archive, installed under
  `~/.local/share/choose-a-local-llm/llama.cpp/`. The exact build is
  recorded beside every measurement.
- Servers listen on port 8081. Harness: pi
  (`~/.pi/agent/models.json`, provider `llama`). Pick a server by
  copy-pasting the command block from its report page. Aliases equal
  the pi model ids.
- No wired limit exists on this machine. Every measurement records
  the GPU memory in use from `nvidia-smi` and the host's
  `MemAvailable` instead.
- Model files live under `~/.cache/llama.cpp/hf/<owner>/<repo>/` and
  are served with `-m`. Every row names the file and the repository
  revision it was measured at.
- `--fit off` on every command: llama.cpp would otherwise shrink the
  context or move layers off the card on its own, and a row measured
  that way is not the row the command says.

## Runtimes on this machine

- **llama-server** (llama.cpp, CUDA), the only runtime.

## Models under test

| model | files | reports |
|---|---|---|
| Gemma-4-12B-it | `FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF`; `unsloth/gemma-4-12b-it-GGUF:UD-Q4_K_XL` | [report](./reports/gemma-4-12b-it.md), [benchmarks](./benchmarks/gemma-4-12b-it.md) |
| Qwen3.8-27B | `unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S`; `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF`, IQ3_S-mtp file | [report](./reports/qwen3.8-27b.md), [benchmarks](./benchmarks/qwen3.8-27b.md) |
| Qwen3.6-35B-A3B (MoE) | `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` | [report](./reports/qwen3.6-35b-a3b.md), [benchmarks](./benchmarks/qwen3.6-35b-a3b.md) |
| Gemma-4-26B-A4B (MoE) | `catlilface/Gemma-4-26B-A4B-NVFP4-GGUF`, NVFP4Q8 file | [report](./reports/gemma-4-26b-a4b.md), [benchmarks](./benchmarks/gemma-4-26b-a4b.md) |

The NVFP4 builds are community repacks. unsloth publishes NVFP4 as
safetensors for vLLM, not as GGUF, so no unsloth NVFP4 file exists
for llama.cpp; the rows name their publisher.

Thinking controls differ by family. Gemma 4 uses a binary
`enable_thinking`, default off. Qwen3.6 is binary and defaults on.
Qwen3.8 uses graded effort: `low`, `medium`, `xhigh`; medium is never
run here.

## Current state

As of 2026-09-13, the first run is under way: every build read with
`llama-benchy` on real code text up to its deep context, then the
agent smoke, the guided agent task, and the blind task for the builds
that finish it. No EvalPlus score exists on this machine yet; the
first run skips that gate on the owner's word and the rows say so.
Raw evidence: `hardware/arrietty/benchmarks/bench17/` in the
repo.
