# Speed & Memory Method

A coding agent spends most of its session past `24K–100K` context tokens. Measuring decode speed only at a short `4K` prompt overstates real-world speed and misses both attention scaling collapse and out-of-memory cliffs.

## Depth Sweeps on Real Text

Every candidate configuration is swept across increasing prompt depths (`4K`, `24K`, `32K`, `64K`, `96K`, `128K`, up to the trained or memory limit):

- **Real code text, not synthetic filler:** Modern speculative heads and attention kernels behave differently on repetitive synthetic tokens than on real source code. Current measurements use `llama-benchy` on real code prompts at the server's own sampling settings; earlier sweeps using the context-creep tool are marked with `†` and never mixed silently with `llama-benchy` numbers.
- **No silent prompt-cache reuse:** Each depth step forces a real prefill and decode pass so throughput reflects actual KV bandwidth at that depth.
- **Usability floor (8 tok/s):** Below **8 tokens/second**, multi-turn agent sessions become too slow to iterate interactively and routinely hit turn caps during long reasoning phases. The last clean step at or above `8 tok/s` defines a speed-gated window.

## Memory Ceilings: Unified Memory vs Discrete VRAM

How a runtime fails at its memory ceiling depends on both hardware architecture and server implementation:

- **Preallocated servers (e.g., `llama.cpp`):** Context memory is allocated up front by `-c`. A context ladder finds the largest `-c` that both loads and completes a real request without OOM. Inside `-c`, decode degrades smoothly with depth and does not OOM unexpectedly. On discrete GPUs, always disable automatic layer fitting (`--fit off`) and leave ~1 GB of free VRAM if the card drives a desktop display.
- **Dynamic-allocation servers (e.g., MLX):** KV cache grows with each turn. Speed stays flat until memory pressure triggers swap growth or kills the generation thread with a GPU OOM (sometimes while the HTTP health endpoint keeps answering). Always bound the prompt cache (`--prompt-cache-size 2`) and subtract a **5% safety margin** when setting the harness context window.
- **Swap-growth stop criterion:** On unified-memory systems, the clean ceiling ends at the last depth step before swap usage or heavy memory compression grows.

## KV Cache Selection Policy

Quantizing the KV cache (`q8_0` or `q4_0` instead of `f16`) roughly halves cache memory, but its speed cost is hardware-dependent:

- **Measure both `f16` and `q8_0` on each hardware class** before committing to a long run.
- On GPUs where quantized KV dequantization is slow in attention kernels, `f16` KV wins decisively unless memory forces `q8_0` to fit a usable window.
- On GPUs with fast quantized-KV kernels, `q8_0` unlocks substantially larger windows at modest speed cost — though `f16` can still outperform `q8_0` on complex reasoning quality and should be tested directly when both fit a practical window.

## Partial Offload: Dense Layers vs MoE Experts

When a weight file exceeds GPU memory:

- **Dense layer offload (`-ngl <N>`):** Streaming dense layers across PCIe on every generated token collapses decode throughput well below the `8 tok/s` floor.
- **Sparse MoE expert offload (`--n-cpu-moe <N>`):** Keeping attention and shared layers on GPU while placing a measured number of inactive expert layers in host RAM preserves fast decode at deep context because only a small fraction of experts activate per token.

## Speculative Decoding (MTP Drafters)

Multi-token prediction (MTP) drafters never change greedy output quality, only speed and memory footprint. Test `n-max` values `1`, `2`, `3` against no drafter on real code text:

- Keep a drafter only when it wins at both shallow and deep context **and** preserves enough memory headroom to complete long agent runs without crashes.
- Never extrapolate drafter gains across architectures or hardware backends.
