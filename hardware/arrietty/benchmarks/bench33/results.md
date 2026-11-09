# Run 33 results

The run tests Arete Q3_K_M and S5-nano Q8_0 on arrietty with official
llama.cpp stable v0.9.0. Full quality and agent results are pending.

## Machine setup

The official mise runtime is v0.9.0, build b12110, commit
`cd959bae99ff4bed22bef2604f45241c09bbb8c8`. It reports CUDA0 and the
required reasoning-budget, Jinja and router flags. The idle official
router stopped before the run. The Linux start sample was 787 MiB VRAM
used, 25,997 MiB available RAM, and 0 MiB swap used. GitHub auth and
pi 1.5.0 pass. The corpus server returned HTTP 200.

| model | pinned file | bytes | sha256 | tokenizer revision |
|---|---|---:|---|---|
| Arete | `NousResearch_Arete-27B-Q3_K_M.gguf` | 13165067264 | `b3059ba64a9171cc6e3b8d18f3e1f71e1d9efe06cf0ef074bdbab2ee6947e4c6` | `108f0afbdcfaa1ceeda4a635004304dfff6d4da2` |
| S5-nano | `S5-nano-Q8_0.gguf` | 4610580032 | `f82c0edcb4fa74dc2db7246ef0532f23288943f9f88ec4066b77b1cba307354f` | `ae981dc208f3bba2939c4cf242fab3e9a83e4938` |

The S5-nano GGUF contains one `nextn` head. MTP remains disabled.
No direct cache-quality evidence was found for either fine-tune.

## S5-nano KV feedback

Both cache types loaded at `-c 34816` with full GPU offload arguments.
The resolved child arguments contain no CPU-MoE or tensor-placement
override. The server logs do not print a layer count. The coordinator
accepted the resolved arguments, successful completion and GPU
allocation as operational full-offload evidence. The q8_0 smoke and
speed run used the same pinned Q8_0 model file as the f16 run.

| KV cache | 4K prefill | 4K decode | 8K decode | 16K decode | 24K decode | 32K decode | GPU memory used at 4K / 32K | smoke |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| f16 | 6197.63 tok/s | 77.95 tok/s | 76.17 tok/s | 72.25 tok/s | 68.98 tok/s | 66.02 tok/s | 6641–6647 / 6617 MiB | 3/4, 0 empty |
| q8_0 | 6141.07 tok/s | 77.45 tok/s | 75.68 tok/s | 72.28 tok/s | 69.05 tok/s | 66.02 tok/s | 6227–6233 / 6233 MiB | 3/4, 0 empty |

The smoke results read LEVEL at the same 16,384-token budget. The
candidate is q8_0 because the speed curves are within 10% and both
types loaded at `-c 34816`. The coordinator selected q8_0.
Raw results, memory logs, server logs, resolved arguments, warmup
responses and smoke files are in `results/`.

The direct machine-start sample showed 0 MiB swap used. The first f16
cell began at 13,288 KiB, and every measured cell had the same value
before and after. The growth happened before the first speed cell. The
coordinator accepted the timed readings with this deviation. The
cells show zero observed swap growth. See the
[KV decision](results/s5-kv-decision.md).

Record KV comparisons and smoke verdicts first. Smokes are unscored
and stay in this run. Add the measured depth curves, full EvalPlus
results and simulator(mendel) artifacts as their blocks close.
