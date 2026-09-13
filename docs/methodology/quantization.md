# Quantization — MLX affine against GGUF k-quants and i-quants

Why a model can score lower on one runtime than on another at the same
nominal bit width, and how much of that gap is the weights. Read it
before you carry a score across runtimes
([methodology](../methodology.md), "Score the quant, once per model").

## What the two families do

**MLX affine.** MLX splits a tensor into groups of consecutive weights,
64 by default, and stores one scale and one bias per group. Every group
gets the same bit width, 4 by default. There is one level of scales, no
super-block, and no calibration data: the converter rounds to the
nearest grid point. It quantizes linear and embedding modules,
including the output head; norms stay in float. mlx-lm also ships mixed
recipes and learned quants (AWQ, DWQ, GPTQ) that raise selected tensors,
but the community 4-bit builds a Mac user downloads are the plain
affine ones.

**GGUF k-quants.** A super-block of 256 weights holds sub-blocks of 32,
each with its own scale and minimum, and those are quantized again
against one super-block scale. The bit width is mixed per tensor: a
4-bit k-quant raises the attention value and down projections on part of
the layers, so it spends about 4.9 bits per weight where MLX 4-bit
spends about 4.5.

**GGUF i-quants.** These add a codebook and reach below 4 bits. At the
same file size a 3-bit i-quant beats the matching 3-bit k-quant.

**Calibration.** llama.cpp can take an importance matrix: per-channel
activation statistics from a calibration corpus that tell the quantizer
which weights to protect. Some publishers go further and pick the quant
type per tensor per model, or solve for the grid with a GPTQ-style
method. MLX's plain converter has no equivalent step.

## What the literature says

- A 4-bit k-quant is cheap. On one 8B model it costs 0.24 perplexity
  and 0.32 points of benchmark average against FP16. A 3-bit k-quant
  costs 0.64 and 1.40 points, and the weakest 3-bit recipe costs 1.64
  and 3.98. So the recipe decides a 3-bit build, not the bit count.
- An importance matrix helps little at 4 bits and a lot below 3.
  llama.cpp advises one for anything under 6 bits.
- **Nobody has published a perplexity of MLX 4-bit against a 4-bit
  k-quant on the same model.** The figures that circulate infer the MLX
  number from llama.cpp's own legacy Q4_0 row. The direction is likely
  right, because MLX has neither mixed precision nor calibration and
  spends fewer bits. The size of the gap is not established.

## What this project measured

Three models on the reference setup carry a score for both families
([the comparison](../setups/m1-max-32gb/comparison.md)).

- One 26B MoE model, thinking on: the GGUF build scored 0.171 base
  above the MLX 4-bit build.
- One dense 12B model, thinking off: the GGUF build scored 0.067 base
  above the MLX 4-bit build.
- One dense 27B model: no deficit. Its MLX 4-bit build scored level
  with the best GGUF rows of the same model, at 100 percent completion.
  Its weak agent scores come from a small window and a Metal memory
  ceiling, not from the weights.

So the gap is real on two of three models and absent on the third.

## What is quant loss and what is the runtime

Two failures that look like quant loss are not.

- **Empty completions.** A reasoning model that never closes its
  thinking runs to the output cap and returns nothing. Both families
  showed this on the same model; the MLX build showed it more often.
  Count the empties before you read the score.
- **A tool call cut off mid-generation.** `mlx_lm.server` defaults
  `max_tokens` to 512 and stops silently with a length finish reason,
  where llama-server generates until the context ends. It also parses
  tool calls by matching the decoded text afterwards, with no grammar
  and no constrained decoding, and open reports show missed
  delimiters, empty content beside reasoning text, and truncation when
  a cached system prompt meets a new user prompt. Treat a tool-call
  failure as a runtime fault until a second runtime repeats it.

## The rule of thumb, and its uncertainty

At 4 bits, expect a calibrated GGUF build to score at or above a plain
MLX 4-bit build of the same model, and do not expect it to score below.
The rule sets an order. It does not give a number: this machine
measured 0.171, 0.067 and zero on three models, so no single figure
predicts the next one. A well calibrated 3-bit GGUF can beat an
uncalibrated 4-bit build of the same model, which the 3-bit rows on the
reference setup show. Every quant still passes the quality gate on its
own ([EvalPlus](./evalplus.md)).

## Sources

- [mlx.core.quantize](https://ml-explore.github.io/mlx/build/html/python/_autosummary/mlx.core.quantize.html)
- [mlx-lm convert.py](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/convert.py)
- [mlx-lm learned quants](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LEARNED_QUANTS.md)
- [mlx-lm SERVER.md](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/SERVER.md)
- [mlx-lm issue 984, multi-token tool delimiters](https://github.com/ml-explore/mlx-lm/issues/984)
- [mlx-lm issue 1125, Gemma 4 tool parser](https://github.com/ml-explore/mlx-lm/issues/1125)
- [mlx-lm issue 1262, tool tokens left as text](https://github.com/ml-explore/mlx-lm/issues/1262)
- [mlx-lm issue 1292, truncation on cache reuse](https://github.com/ml-explore/mlx-lm/issues/1292)
- [llama.cpp quantize README](https://github.com/ggml-org/llama.cpp/blob/master/tools/quantize/README.md)
- [llama.cpp PR 5676, IQ3_S](https://github.com/ggml-org/llama.cpp/pull/5676)
- [llama.cpp discussion 5063, k-quant and i-quant quality](https://github.com/ggml-org/llama.cpp/discussions/5063)
- [A unified evaluation of llama.cpp quantization](https://arxiv.org/html/2601.14277v1)
- [Unsloth dynamic GGUFs](https://unsloth.ai/blog/dynamic-v2)
- [GSQ, scalar quantization from IST Austria](https://github.com/IST-DASLab/GSQ)
- [MLX against GGUF, isolating variables](https://famstack.dev/guides/mlx-vs-gguf-part-2-isolating-variables/)
