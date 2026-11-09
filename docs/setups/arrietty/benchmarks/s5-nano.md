# S5-nano measurement record

[Model](https://huggingface.co/maritaca-ai/S5-nano) · [Publisher GGUF](https://huggingface.co/maritaca-ai/S5-nano-GGUF)

## Configuration

Benchmark run 33 tests `S5-nano-Q8_0.gguf` at revision `5fd041274829d60aeeba1e2edc4aabb621a432e4`. The file has 4,610,580,032 bytes. Its SHA-256 is `f82c0edcb4fa74dc2db7246ef0532f23288943f9f88ec4066b77b1cba307354f`.

The runtime is official llama.cpp stable v0.9.0, b12110, on CUDA. The baseline uses q8_0 KV without MTP or vision. Full quality and agent measurements are pending.

## Depth measurement

<ModelSpec base="S5-nano" quant="Q8_0" publisher="maritaca-ai" server="llama-server" repo="maritaca-ai/S5-nano-GGUF" kv="q8_0" effort="on" />

Official llama.cpp stable v0.9.0, b12110, CUDA, one slot, full GPU offload requested and automatic fit disabled. High Think mode, no drafter or vision. The run served `-c 262144`. Linux llama-benchy 0.4.0 read each depth separately, with 512 prefill tokens, 256 decode tokens, two repetitions and a five-second pause. These readings are not slow-context-creep results.

| used depth | prefill tok/s | decode tok/s | total GPU use |
|---:|---:|---:|---:|
| 4096 | 6124.64 | 77.37 | 11117 MiB |
| 24576 | 5363.69 | 69.00 | 11117 MiB |
| 32768 | 5042.75 | 66.01 | 11117 MiB |
| 65536 | 4062.74 | 56.76 | 11117 MiB |
| 131072 | 2919.71 | 44.29 | 11117 MiB |
| 196608 | 2276.98 | 36.16 | 11117 MiB |
| 245760 | 1952.74 | 31.76 | 11117 MiB |
| 261120 | 1870.13 | 30.59 | 11117 MiB |

The deepest clean cell was 261,120 tokens. The harness window is 258,048 after rounding down to 4,096. Compaction keep uses pi's default 20,000. The run reached the model's planned context cap. It did not find an OOM or the 8 tok/s floor. The table's memory cap label marks the end of the allocated context; it does not establish the card's absolute maximum.

Swap was already in use before load and did not grow during a timed cell. Before load, swap use was 63,380 KiB. The 245,760-token cell began at 61,272 KiB and ended at 61,252 KiB. Keep this premeasurement use as a deviation. Peak GPU use includes the desktop. Full quality and agent results are pending.
