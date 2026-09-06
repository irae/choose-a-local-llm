# Video: Run Qwen3.8-27B on ANY Mac (16GB to 48GB): Here's How

- Channel: RepoChad
- Upload date: 2026-09-06
- Length: 9:48 (588 seconds)
- URL: https://www.youtube.com/watch?v=dHK90xc9Q64
- Transcript source: yt-dlp auto-generated English captions (method 1 worked)

## Reasoning effort levels (low, medium, xhigh)

The video does not mention reasoning effort levels. The speaker never says the
words "low", "medium", or "xhigh" as effort settings. This section has no
claims to report.

## Claims about Qwen3.8-27B and its architecture

- "Quen 3.827b officially lists a native context window of 262,000 tokens." (00:00:00)
- The model is a 27 billion parameter vision language model. (00:00:08)
- "It runs 16 repeating blocks where each block contains three gated delta linear attention layers and one full attention layer." (00:00:44)
- This gives 48 DeltaNet layers and 16 full attention layers. (00:00:52)
- The 48 delta layers keep a fixed recurrent state. It does not grow with sequence length. (00:00:57)
- Only the 16 full attention layers use standard key-value cache. (00:01:03)
- "Upstream Llama CPP has an open tracking issue number 27756 where Quen 3.827B silently emits an end of sequence token past roughly 130,000 context on both CPU and CUDA backends." (00:08:52)
- The speaker says this bug comes from recurrent state handling in the hybrid attention layers. (00:09:12)
- The speaker advises using a validated MLX or oMLX environment instead of raw GGUF builds past 128,000 context. (00:09:16)
- The speaker advises keeping experimental Apple Neural Engine prefill disabled in oMLX. Recent reports show timeouts on Qwen hybrid models. (00:09:27)

## Every number given in the video

Attention math:
- Full attention layer cost: 16 layers x 4 KV heads x head dimension 256 x 2 (key and value) x 2 bytes (FP16) = 65,536 bytes per token (64 KB/token). (00:01:07)
- A dense model where all layers use full attention: about 256 KB per token. (00:01:29)
- At 32,000 tokens, unquantized cache: about 2 GB. (00:01:39)
- At 128,000 tokens, unquantized cache: about 8 GB. (00:01:44)
- At 128,000 tokens with a 4-bit cache: about 2 GB. (00:01:49)

16 GB tier (for example, base M4 Mac mini):
- Standard 4-bit quant: about 15 to 16 GB on disk. Does not fit. (00:02:23)
- 2-bit MLX, text-only build, on M4 with 10-core GPU: 1,000 to 4,000 context, about 11 tokens/second, peak memory 10.9 GB. (00:02:47)
- TurboQuant 3-bit build (Qwen3.8-27B TQ3 Mini G64): 11.55 GB on disk. On a physical 16 GB M4 mini, prompts up to 5,000 tokens, peak allocation about 13.6 GB, generation 3.7 tokens/second. Needs a 14 GB GPU wired limit and a 256-token prefill step. (00:03:08)
- Max context on 16 GB: 2-bit text-only build with 4-bit cache. 4,000 context proven; 8,000 a stretch target; 16,000 not expected to run cleanly. (00:03:43)

24 GB tier:
- Standard 4-bit MLX: comfortable at 4,000 to 8,000 context. (00:04:02)
- 4-bit with speculative decoding (Dlash2) on M4 Pro, 20 GPU cores: 22.5 tokens/second at 4,000 context, peak memory 18.8 GB. (00:04:14)
- 2-bit MLX with 4-bit cache on base M5, 10-core GPU: 16,000 context at 6.6 tokens/second, peak model memory 12.8 GB. 16,000 proven; 32,000 experimental. (00:04:44)

32 GB tier (sweet spot):
- 6-bit MLX file size: about 21 to 23 GB. (00:05:35)
- 8-bit at 4,000 context: about 30 GB process memory. (00:05:49)
- 8-bit at 32,000 context: over 34 GB process memory (forces swap on 32 GB). (00:05:56)
- 4-bit with Dlash2 (or MTPLX speed build) on M5: 8,000 context at 21 tokens/second. (00:06:10)
- 4-bit MLX on M2 Max, 30 GPU cores: full 32,000 context at 15.8 tokens/second, peak memory 19.2 GB. (00:06:38)
- 64,000 context called realistic with quantized cache; 128,000 called reachable with a lean build. (00:06:51)

48 GB tier:
- 8-bit MLX: comfortable quality up to 32,000 tokens. (00:07:26)
- 6-bit with 4-bit cache and Lightning MTP on M4 Pro, 20 GPU cores: 32,000 tokens at 16.3 tokens/second, peak memory 31.2 GB. (00:07:38)
- 4-bit MLX on M4 Pro, 20 GPU cores: 128,000 tokens. Prefill 84 tokens/second, decode 9.3 tokens/second, peak memory 27 GB. (00:07:52)
- Community test on M5 Pro, 20 GPU cores, 5 BPW build with spec prefill, 8-bit cache, Lightning MTP: 195,000 tokens at 21.2 tokens/second, peak memory 30 GB. (00:08:11)
- 262,000 (full native context): the speaker says the memory math fits inside 48 GB with 4-bit weights and a low-bit cache, but running it needs runtime validation. (00:08:35)

## Hardware and serving stack used

- Devices named: base M4 Mac mini, M4 Pro (20 GPU cores), M4 or M5 base chip (24 GB), base M5 (10-core GPU), M2 Max (30 GPU cores), M5 Pro (20 GPU cores).
- Runtimes named: MLX, oMLX (OMLX), llama.cpp, GGUF.
- Techniques named: TurboQuant 3-bit build, text-only (vision-stripped) conversion, quantized KV cache (4-bit and 8-bit), speculative decoding ("Dlash2" or "Dlash 2"), Lightning MTP, spec prefill, Apple Neural Engine prefill (in oMLX, advised off).
- Control mentioned: setting the GPU wired memory limit through `sysctl` (spoken as "CISL") and a 256-token prefill step size.

## What this means for our trial

The video gives no data on reasoning effort levels. It only covers quant
choice, context length, and memory on Apple Silicon. It cannot guide an
effort-level choice for agent work.

For our 32 GB tier, the video's own numbers matter more than the effort
question:
- 6-bit MLX fits our RAM only at short context (21 to 23 GB file, plus a
  small cache). Agent work needs long context, so 6-bit is a poor fit here.
- 4-bit MLX is the only path the video proves at full 32,000 context on 32 GB
  hardware (15.8 tokens/second, 19.2 GB peak). Agent loops need multi-turn
  context, so 4-bit is the safer starting point for our trial.
- The video's own maintainer testing found agentic loops failed completely on
  the 16 GB TQ3 3-bit build. This is a warning sign, not proof about our
  32 GB setup, but it flags that low-bit quants may not hold up under agent
  workloads in general.
- The llama.cpp end-of-sequence bug past about 130,000 context is a backend
  risk, not a quant risk. It does not block our 32,000-token trial, but rules
  out llama.cpp/GGUF if we ever push past 128,000 context on this model.
