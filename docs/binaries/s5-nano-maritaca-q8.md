# S5-nano Q8_0 (Maritaca AI)

File: [maritaca-ai/S5-nano-GGUF](https://huggingface.co/maritaca-ai/S5-nano-GGUF), `S5-nano-Q8_0.gguf`, revision `5fd041274829d60aeeba1e2edc4aabb621a432e4`, 4.61 GB. Server: official llama-server on CUDA. This page holds the configurations and results of this file.

- The publisher supplies this file for llama.cpp.
- The initial cache choice is q8_0.
- Full quality and agent results are pending.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/s5-nano-maritaca-q8" top /> | **pending** | <TokCell shallow="pending" deep="pending" cap="pending" /> | pending | <ScoreCell value="pending" /> | <ScoreCell value="pending" /> | — |
<!-- gen:binary-rows:end -->

<!-- gen:binary-best-preset:start -->
Best configuration on this page, as a section of `hardware/arrietty/models.ini` (RTX 5060 Ti 16 GB, llama-server, pi id `s5-nano-q8`). Every preset of this page: [`s5-nano-q8`](#preset-s5-nano-q8).

```ini
[s5-nano-q8]
hf-repo = maritaca-ai/S5-nano-GGUF
hf-file = S5-nano-Q8_0.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 34816
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```
<!-- gen:binary-best-preset:end -->

## Quality

<!-- gen:binary-evalplus:start -->
No EvalPlus run yet.
<!-- gen:binary-evalplus:end -->

## Agent task

<!-- gen:binary-mendel:start -->
No Mendel run yet.
<!-- gen:binary-mendel:end -->

## Speed and context

Full depth testing is pending. See the [measurement record](../setups/arrietty/benchmarks/s5-nano.md).

## Server presets

<!-- gen:binary-presets:start -->
### `s5-nano-q8` {#preset-s5-nano-q8}

RTX 5060 Ti 16 GB, a section of `hardware/arrietty/models.ini` (llama-server).

```ini
[s5-nano-q8]
hf-repo = maritaca-ai/S5-nano-GGUF
hf-file = S5-nano-Q8_0.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 34816
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```
<!-- gen:binary-presets:end -->

## Log

- 2026-11-08: pinned the publisher file for benchmark run 33.
