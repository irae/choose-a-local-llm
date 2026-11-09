# Arete-27B Q3_K_M (bartowski)

File: [bartowski/NousResearch_Arete-27B-GGUF](https://huggingface.co/bartowski/NousResearch_Arete-27B-GGUF), `NousResearch_Arete-27B-Q3_K_M.gguf`, revision `9762c8502a79bd2b8634735d75f426b9febe092c`, 13.17 GB. Server: official llama-server on CUDA. This page holds the configurations and results of this file.

- This community quantization targets llama.cpp.
- The initial cache choice is q8_0.
- Full quality and agent results are pending.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Arete-27B" quant="Q3_K_M" server="llama-server" publisher="bartowski" repo="bartowski/NousResearch_Arete-27B-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/arete-bartowski-q3km" top /> | **64k** | <TokCell shallow="27.60" deep="20.07" cap="mem" top-shallow top-deep /> | **15.4 GiB** | <ScoreCell value="pending" /> | <ScoreCell value="pending" /> | — |
<!-- gen:binary-rows:end -->

<!-- gen:binary-best-preset:start -->
Best configuration on this page, as a section of `hardware/arrietty/models.ini` (RTX 5060 Ti 16 GB, llama-server, pi id `arete-27b-q3km`). Every preset of this page: [`arete-27b-q3km`](#preset-arete-27b-q3km).

```ini
[arete-27b-q3km]
hf-repo = bartowski/NousResearch_Arete-27B-GGUF
hf-file = NousResearch_Arete-27B-Q3_K_M.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 65536
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

<ModelSpec base="Arete-27B" quant="Q3_K_M" publisher="bartowski" server="llama-server" repo="bartowski/NousResearch_Arete-27B-GGUF" kv="q8_0" effort="xhigh" />

At `-c 65536`, decode was 27.60 tok/s at 4,096 used tokens and 20.07 at 64,512. The harness window is 61,440. The run reached its planned cap; it did not establish an absolute memory ceiling. Peak total GPU use was 15,771 MiB, with no swap growth during the timed cells. See the [full curve and conditions](../setups/arrietty/benchmarks/arete-27b.md#depth-measurement).

## Server presets

<!-- gen:binary-presets:start -->
### `arete-27b-q3km` {#preset-arete-27b-q3km}

RTX 5060 Ti 16 GB, a section of `hardware/arrietty/models.ini` (llama-server).

```ini
[arete-27b-q3km]
hf-repo = bartowski/NousResearch_Arete-27B-GGUF
hf-file = NousResearch_Arete-27B-Q3_K_M.gguf
no-mmproj = true
parallel = 1
n-gpu-layers = 999
fit = off
flash-attn = on
ctx-size = 65536
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```
<!-- gen:binary-presets:end -->

## Log

- 2026-11-08: pinned the community file for benchmark run 33.

- 2026-11-08: measured the 64K allocation and set the harness window to 61,440.
