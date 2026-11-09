# Arete-27B measurement record

[Model](https://huggingface.co/NousResearch/Arete-27B) · [GGUF](https://huggingface.co/bartowski/NousResearch_Arete-27B-GGUF)

## Configuration

Benchmark run 33 tests `NousResearch_Arete-27B-Q3_K_M.gguf` at revision `9762c8502a79bd2b8634735d75f426b9febe092c`. The file has 13,165,067,264 bytes. Its SHA-256 is `b3059ba64a9171cc6e3b8d18f3e1f71e1d9efe06cf0ef074bdbab2ee6947e4c6`.

The runtime is official llama.cpp stable v0.9.0, b12110, on CUDA. The baseline uses q8_0 KV without MTP or vision. The xhigh quality gate passed. Agent results and thinking-off quality are pending.

## Depth measurement

<ModelSpec base="Arete-27B" quant="Q3_K_M" publisher="bartowski" server="llama-server" repo="bartowski/NousResearch_Arete-27B-GGUF" kv="q8_0" effort="xhigh" />

Official llama.cpp stable v0.9.0, b12110, CUDA, one slot, full GPU offload requested and automatic fit disabled. No drafter or vision. The run served `-c 65536`. Linux llama-benchy 0.4.0 read each depth separately, with 512 prefill tokens, 256 decode tokens, two repetitions and a five-second pause. These readings are not slow-context-creep results.

| used depth | prefill tok/s | decode tok/s | total GPU use |
|---:|---:|---:|---:|
| 4096 | 886.13 | 27.60 | 15771 MiB |
| 24576 | 823.36 | 24.49 | 15771 MiB |
| 32768 | 795.26 | 23.40 | 15771 MiB |
| 64512 | 701.17 | 20.07 | 15771 MiB |

The deepest clean cell was 64,512 tokens. The harness window is 61,440 after rounding down to 4,096. Compaction keep is 8,192. The run stopped at its planned 64K cap. It did not find an OOM or the 8 tok/s floor. The table's memory cap label marks the end of the allocated context; it does not establish the card's absolute maximum.

Swap did not grow during any measured cell. A premeasurement increase remains a deviation. The 64,512-token cell began at 60,244 KiB swap used; the last sample was 60,240 KiB. Peak GPU use includes the desktop. The xhigh quality gate passed. Agent results and thinking-off quality are pending.

## Xhigh quality

The pinned Q3_K_M file ran on official llama.cpp stable v0.9.0, b12110,
q8_0 KV, xhigh, no drafter and `-c 65536`. Every request passed
`enable_thinking: true` and `reasoning_effort: xhigh` through
`chat_template_kwargs`. Fast mode used a thinking budget of 8192 and
an output budget of 16384, with temperature 0 and no calibration.

| base pass@1 | plus pass@1 | completion | empty | forced | active wall |
|---:|---:|---:|---:|---:|---:|
| 0.976 | 0.951 | 164/164 | 0/164 | 7/164 | 204.1 min |

The evaluator counted 160 base passes and 156 plus passes. The fixed
budget-message count command confirmed seven forced answers and zero
empty answers. Forced task IDs were HumanEval/10, 32, 47, 116, 132,
134 and 145. The base score passed the 0.800 quality threshold. Agent
results remain pending.
