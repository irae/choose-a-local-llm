# S5-nano Q8_0 (Maritaca AI)

File: [maritaca-ai/S5-nano-GGUF](https://huggingface.co/maritaca-ai/S5-nano-GGUF), `S5-nano-Q8_0.gguf`, revision `5fd041274829d60aeeba1e2edc4aabb621a432e4`, 4.61 GB. Server: official llama-server on CUDA. This page holds the configurations and results of this file.

- The publisher supplies this file for llama.cpp.
- The initial cache choice is q8_0.
- The thinking quality gate passed. Instruct quality is also measured. The agent task was not run.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/s5-nano-maritaca-q8" top /> | **261k** | <TokCell shallow="77.37" deep="30.59" cap="mem" top-shallow top-deep /> | **10.9 GiB** | <ScoreCell value="0.811/0.726" sub="100% completion" top /> | <ScoreCell value="not run" /> | <span title="EvalPlus 1h56 · Mendel —">1h56†</span> |
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
ctx-size = 262144
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```
<!-- gen:binary-best-preset:end -->

## Quality

Think mode scored 0.811 base and 0.726 plus on all 164 problems. There were no empty answers and 26 forced answers, with an 8,192-token thinking budget and a 16,384-token output budget. Active wall was 116.3 minutes.

Instruct mode, with thinking disabled, scored 118 base passes and 104 plus passes out of 164, or 0.720 / 0.634. No answer was empty or forced. Active wall was 25.5 minutes at the same 16,384-token output budget, without a server reasoning budget. This is a separate quality result. The agent task was not run.

<!-- gen:binary-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/s5-nano-maritaca-q8" />](../setups/arrietty/benchmarks/s5-nano.md) | 8192 | 16384 | <ScoreCell value="0.811/0.726" sub="100% completion" top /> | none | 26/164 | <TokCell shallow="77.37" deep="30.59" /> | 1h56 |
| [<ModelSpec base="S5-nano" quant="Q8_0" server="llama-server" publisher="maritaca-ai" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="off" hardware="rtx-5060ti-16gb" page="/binaries/s5-nano-maritaca-q8" />](../setups/arrietty/benchmarks/s5-nano.md) | none | 16384 | <ScoreCell value="0.720/0.634" sub="100% completion" top /> | none | 0/164 | <TokCell shallow="77.37" deep="30.59" /> | 0h26 |
<!-- gen:binary-evalplus:end -->

## Agent task

<!-- gen:binary-mendel:start -->
No Mendel run yet.
<!-- gen:binary-mendel:end -->

## Speed and context

<ModelSpec base="S5-nano" quant="Q8_0" publisher="maritaca-ai" server="llama-server" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" />

At `-c 262144`, decode was 77.37 tok/s at 4,096 used tokens and 30.59 at 261,120. The harness window is 258,048. The run reached the planned model context cap; it did not establish an absolute memory ceiling. Peak total GPU use was 11,117 MiB, with no swap growth during the timed cells. See the [full curve and conditions](../setups/arrietty/benchmarks/s5-nano.md#depth-measurement).

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
ctx-size = 262144
cache-type-k = q8_0
cache-type-v = q8_0
jinja = true
reasoning-budget = 8192
reasoning-budget-message = Thinking budget reached. Give the final answer now.
```
<!-- gen:binary-presets:end -->

## Log

- 2026-11-08: pinned the publisher file for benchmark run 33.

- 2026-11-08: measured the full model context allocation and set the harness window to 258,048.

- 2026-11-09: thinking quality passed the base gate; 26 forced answers were verified from the finish log.

- 2026-11-09: recorded Instruct quality, 0.720 base and 0.634 plus, with no empty or forced answer.
