# Quantized KV on this M1 Max: why it is so slow

Research run 3, desk work, 2026-09-05. No hardware used. The question: run 9 measured
q8_0 KV far slower than f16 at 32K (`../benchmarks/bench9/results.md`, block A1), much
worse than the literature suggests. Is the M1 missing hardware that later chips have,
or is its GPU already busy with the rest of decode? Neither.

## What our own numbers already say

Decode time per token is `base + slope × depth`: `base` is the weights and the rest of
the layer, `slope` is attention over the cached tokens. A least-squares fit of the run
9 block A1 rows separates them.

| model, KV type | base (ms/token) | slope (µs per cached token) |
| --- | --- | --- |
| Gemma-4-26B-A4B, q8_0 | 25.6 | 4.06 |
| Gemma-4-26B-A4B, f16 | 14.8 | 0.196 |
| Qwen3.8-27B, q8_0 | 53.6 | 2.70 |
| Qwen3.8-27B, f16 | 51.8 | 0.320 |

On Qwen3.8 the base is the same for both types, 53.6 against 51.8, a 4% difference.
**The whole penalty is in the depth term**, and there it is 8.4x; on Gemma-26B the
depth term is 20.7x. So the GPU is not busy with the rest of decode, which costs the
same either way.

Two older rows agree, and the second matters. Gemma-4-12B at shallow depth
(`run2/results/kv-speed.md`) loses only 14% to q8_0, 27.5 against 32.1 tok/s, because
a shallow depth term gives a small penalty. And Bonsai on the PrismML fork
(`../../../docs/setups/m1-max-32gb/benchmarks/bonsai-27b.md`) fits 2.01 µs per cached
token at q4 against 2.98 at q8: **q4_0 is faster than q8_0 here**, so the cost is not
"more bits to unpack". Across three models and two builds every quantized arm sits
between 2.0 and 4.1 µs per cached token and every f16 arm between 0.20 and 0.32.

## The roofline says it is not bandwidth

Qwen3.8-27B keeps KV on 16 full-attention layers, 4 KV heads, `head_dim` 256 (config
below), so f16 KV is 64 KiB per token and q8_0 is 32 KiB. The M1 Max has 400 GB/s
([Apple](https://www.apple.com/newsroom/2021/10/introducing-m1-pro-and-m1-max-the-most-powerful-chips-apple-has-ever-built/)).

| KV type | bytes per cached token | time at 400 GB/s | measured | share of peak |
| --- | --- | --- | --- | --- |
| f16 | 64 KiB | 0.164 µs | 0.320 µs | 51% |
| q8_0 | 32 KiB | 0.082 µs | 2.700 µs | 3% |

f16 attention runs at half of peak memory bandwidth, a healthy bandwidth-bound loop.
q8_0 halves the bytes and still takes 8x longer, at 3% of peak, so **the quantized path
is not bandwidth bound at all**.

## The M1 is not missing anything

Apple's [Metal Feature Set Tables](https://developer.apple.com/metal/Metal-Feature-Set-Tables.pdf)
list `SIMD-scoped matrix multiply operations` and `SIMD-scoped reduction
operations` from **Apple7**, and `MTLDataType.bfloat` from **Apple6**. M1-series is
Apple7, M2 is Apple8, M3 and M4 are Apple9. llama.cpp gates on exactly those, in
[`ggml-metal-device.m`](https://github.com/ggml-org/llama.cpp/blob/master/ggml/src/ggml-metal/ggml-metal-device.m):
`has_simdgroup_mm` and `has_simdgroup_reduction` come from
`supportsFamily:MTLGPUFamilyApple7`, `has_bfloat` from Apple6. There is no Apple8 or
Apple9 check anywhere in the Metal backend. The M1 fails only `has_tensor`, the Metal
4 tensor API of the M5 class, which a comment there calls off by default on older
chips anyway. Apple8 and Apple9 add mesh shaders, ray tracing and dynamic caching,
none of which touches attention. **The "missing instructions" hypothesis is dead**:
the M1 runs the same kernel code as an M4.

## The decode kernel is the slow path, on every Apple GPU

In [`ggml-metal-ops.cpp`](https://github.com/ggml-org/llama.cpp/blob/master/ggml/src/ggml-metal/ggml-metal-ops.cpp)
flash attention picks the `_vec` kernel when the batch is small (`ne01 < 20`), which
is every decode step. That kernel (`kernels/fa.metal`, `kernel_flash_attn_ext_vec`)
uses **no simdgroup matrix operations at all**: it is a `simd_sum` and
`simd_shuffle_down` reduction loop, and for q8_0 and q4_0 it calls
`dequantize_q8_0_t4` and `deq_k_t4` inline inside the KV loop. The full matrix
kernel, which does feed a dequantize function into simdgroup matrix registers, runs
only for prompt processing.
[PR #27390](https://github.com/ggml-org/llama.cpp/pull/27390) added a
dequantize-to-F16 prepass for quantized KV, and its guard
`ggml_metal_op_flash_attn_ext_use_kv_f16` returns false when `ne01 < 32`. **That
switches the prepass off at decode.** The PR comment says the tradeoff depends on the
compute-to-bandwidth ratio and is "TODO: tune per device". So at decode, quantized KV
always runs the inline dequantizing vector kernel, with no matrix hardware behind it,
unpacking the whole cache element by element for every token.

## The same effect, measured on the same chip

["Open-TQ-Metal: Fused Compressed-Domain Attention for Long-Context LLM Inference on
Apple Silicon"](https://arxiv.org/abs/2604.16957) (Vegasena, April 2026) runs every
experiment on an **Apple M1 Max, 64 GB, 32 GPU cores, macOS 15**. Table 2 gives
dequantize-then-attend attention latency on Llama 70B: 4.6 ms at 1K, 54.6 at 16K,
225.3 at 64K, 480.6 at 128K, which is **3.3 to 4.5 µs per cached token**, the same
band as our fitted 2.0 to 4.1. Its fused kernel, which dequantizes in GPU registers
and writes no temporary, reaches 9.9 ms at 128K, a 48x speed-up. Caveats: a preprint,
AI-assisted by its own account, and its baseline is MLX, not llama.cpp's vec kernel;
it corroborates the size of the effect, it does not measure our runtime. The community
report, [llama.cpp #8918](https://github.com/ggml-org/llama.cpp/issues/8918), has
Phi-3 3B on an A15 and an M1 at 9.95 tok/s f16 against 6.77 at q8_0 K, a 33% drop at
shallow depth.

## MLX pays almost nothing for the same idea

MLX has no fused kernel either, but it does the work differently.
[`mlx_lm/models/base.py`](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/models/base.py)
routes a `QuantizedKVCache` to `quantized_scaled_dot_product_attention`: two
`mx.quantized_matmul` calls with an explicit softmax between them (a fused quantized
SDPA is still unmerged, [mlx #3026](https://github.com/ml-explore/mlx/pull/3026)). The
cost is tiny. On an M4 Pro with Phi-3.5-mini
([mlx #3134](https://github.com/ml-explore/mlx/discussions/3134)): no quantization
71.4 tok/s, `--kv-bits 8` 67.9 (-4.9%), `--kv-bits 4` 72.2 (+1.1%). **About 5%,
against llama.cpp's 8x, on the same Metal.** That is the strongest single argument
that this is a llama.cpp decode-kernel problem, not an Apple GPU problem. Caveat: an
M4 Pro, not an M1 Max, and a user post. No M1 `--kv-bits` measurement exists in the
ml-explore repositories, and no thread anywhere puts quantized-KV decode on an M1 next
to a later chip.

One MLX limit matters for us: **`mlx_lm.server` does not support quantized KV at all**
([#1043](https://github.com/ml-explore/mlx-lm/issues/1043)), the flags exist only in
`mlx_lm.generate` and the Python API. So the KV pick rule is right that our MLX rows
hold f16, but the reason is the server, not MLX.

## Verdict

1. The M1 is not missing instructions or hardware. Apple gives Apple7 simdgroup
   matrix multiply and bfloat, llama.cpp gates on Apple7, so the M1 runs the same
   code as an M4.
2. The GPU is not maxed out by the rest of decode either. On Qwen3.8 the
   depth-independent part costs the same at q8_0 and at f16, 53.6 against 51.8 ms
   per token. Only attention over the cache changes.
3. The cause is the decode-time kernel. At batch 1 llama.cpp picks the
   flash-attention vector kernel, which uses no matrix hardware and unpacks each
   cached element inline, and it turns the dequantize-to-F16 prepass off at decode.
   That path reaches about 3% of peak bandwidth where f16 reaches 51%.
4. It is a software slow path, not a silicon limit: MLX runs a quantized cache on the
   same Metal for about 5%, and a published fused Metal kernel gets 48x on an M1 Max.
   It bites here because this chip is bandwidth rich against its compute, so f16
   attention was already nearly free and the quantized path buys nothing back (that
   clause infers from the PR #27390 comment; it is not measured).
5. `docs/methodology/kv-cache-pick.md` is right for the wrong reason. It should say:
   prefer f16 whenever it fits, because a quantized cache costs 2 to 4 µs per cached
   token here, whichever model and quant.

## Qwen3.8 on this chip

Verified from [the config](https://huggingface.co/Qwen/Qwen3.8-27B/raw/main/config.json)
and [the model card](https://huggingface.co/Qwen/Qwen3.8-27B):

- **Dense, not MoE.** 27B parameters, 64 layers, hidden 5120. `model_type` is
  `qwen3_5`, so search llama.cpp for **Qwen3.5**.
- **Hybrid attention, 3:1.** `layer_types` repeats `linear, linear, linear, full`
  sixteen times: **48 Gated DeltaNet layers with no growing KV** and **16
  full-attention layers** that keep one. The DeltaNet recurrent state is about
  150 MB and does not grow.
- **KV per token, f16: 16 × 2 × 4 heads × 256 × 2 bytes = 64 KiB**, which confirms
  the report's "about 0.8 GB per 16K tokens". The hybrid saves 4x against a dense
  64-layer model, but `head_dim` is 256, twice the usual, so 64 KiB per token is
  still not small: at the trained 262144 window f16 KV alone would be 16 GiB.
- **The "lookup tables" belong to a different model.** The 27B has plain dense BF16
  weights, no codebook, no vector quantization. The n-gram lookup table, a 51B
  embedding table selected by a hash of the last three tokens, is a
  **Qwen3.8-Flash-Next** feature
  ([vLLM #53908](https://github.com/vllm-project/vllm/issues/53908)).

What this means for run 3 goal 2. **The model is large for this machine and the
architecture does not rescue it.** The fitted base of 52 ms per token is a dense 27B
at 4 bits reading its weights every token. The hybrid makes the cache cheap and does
nothing for the weights; our f16 curve, flat at 16 to 20 tok/s from 4K to 32K, is
that base with a nearly free cache. Only fewer weight bytes move it, so a 3-bit
build is the lever left. **q4_0 KV would buy little and risk much**: f16 KV already
costs only 0.32 µs per cached token, so cutting it saves memory, not time, and it
moves attention onto the slow vec path. Everyone reporting q4_0 KV "ok" for this model
([overbring.com](https://overbring.com/blog/2026-08-17-qwen3-8-27b-wall-clock/),
[llama.cpp #23470](https://github.com/ggml-org/llama.cpp/discussions/23470)) runs an
NVIDIA GPU, compute rich and bandwidth poor; their quality claims transfer, their
speed claims do not. **And a warning for Gemma-4, not Qwen**: Open-TQ-Metal finds
int4 KV fails on Gemma 4 past about 950 tokens, because Gemma 4 uses `attn_scale =
1.0` where Llama-style models use `1/sqrt(d) = 0.0884`, damping the same error 25 to
100x. If q4_0 KV is tried here, try it on Qwen, never Gemma-4.

## What only a test can settle

The sources give the mechanism but measure none of it on our runtime, models, or chip.
These four would. Nothing about GPU families or bfloat needs a test: Apple's tables
and llama.cpp's own gates close that.

1. **Is the vec kernel the one running?** Serve at q8_0 KV under a Metal frame capture,
   or with `MTL_DEBUG_LAYER=1 MTL_SHADER_VALIDATION=1`, and record which
   `flash_attn_ext` variant dispatches at decode. Claim under test, confirmed nowhere
   for our build: `kernel_flash_attn_ext_vec_q8_0_*` runs at every decode step and the
   `kv_f16` prepass never does.
2. **Does the penalty scale as the fit predicts?** Qwen3.8 GGUF, short creep at 4K,
   16K and 32K, three arms: f16, q8_0, q4_0. Fit `base + slope × depth` for each.
   Predictions to falsify: the three bases agree within 5%; the f16 slope near
   0.32 µs; the q8_0 slope near 2.7 µs; the q4_0 slope **lower** than q8_0, as the
   Bonsai rows show. A q4_0 slope above q8_0 breaks this whole file.
3. **Does MLX pay the same tax on THIS chip?** The 5% M4 Pro figure is the pivot of the
   verdict and no M1 measurement of it exists. `mlx_lm.server` cannot do it, so run
   `mlx_lm.generate`: same model, same three depths, `--kv-bits 8` and `--kv-bits 4`
   against the default, `--quantized-kv-start 0`. If MLX stays within 10% at 8 bits
   here, this is a llama.cpp issue with our numbers in it.
4. **Is the prepass worth forcing?** The `ne01 < 32` guard is a constant with "TODO:
   tune per device" beside it. A local build with it removed, at q8_0 KV, decides in
   one creep whether this machine is a device it was never tuned for. The cheapest
   test, and the one that could go upstream.
