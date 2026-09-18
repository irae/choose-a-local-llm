# Ternary Bonsai-2-27B on RTX 5060 Ti 16 GB — prism-llama benchmarks

Builds: prism-ml PQ2_0 and PTQ1_0. Backend: the PrismML llama.cpp fork
(`prism-llama`), release `prism-b10685-7dffb15`, commit `7dffb158d`,
CUDA 12.8. The stock llama.cpp binary does not serve these files.

The full data of every measurement of this model on this machine lands
here as the runs close. Raw evidence:
`hardware/arrietty/benchmarks/bench24/` in the repo. The report page:
[Ternary Bonsai-2-27B](../reports/bonsai-27b.md).

## KV pick, 2026-09-17 and 2026-09-18

The ladder starts at the trained context, 262144, because the weights
are small and the KV cache is the large allocation.

| file | q8_0 | f16 | note |
|---|--:|--:|---|
| PQ2_0 | **212992** | 122880 | 262144 fails to allocate at q8_0 |
| PTQ1_0 | **245760** | 139264 | f16 aborts on a live CUDA out-of-memory at 147456 |

## Decode speed against used context

Read with `llama-benchy`, two runs per depth, no drafter, q8_0 KV. The
deepest depth of each file is its `-c` minus 1024.

| file | 4096 | 24576 | 65536 | deep | deep depth | VRAM |
|---|--:|--:|--:|--:|--:|--:|
| PQ2_0 | 46.0 | 38.2 | 28.2 | 14.5 | 211968 | 15735 MiB |
| PTQ1_0 | 41.7 | 34.9 | 26.5 | 12.8 | 244736 | 15837 MiB |

Both sweeps end on a window verdict: no depth fell under the 8 tok/s
floor, so the sweep ran out of context to test before the card ran out
of room.
