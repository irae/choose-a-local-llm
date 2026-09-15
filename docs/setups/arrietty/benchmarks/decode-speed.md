# Decode speed vs context depth — RTX 5060 Ti 16 GB

Every benchmark here answers one question: **how fast does the model
decode when the context is actually full?** A near-empty prompt says
one number; a real coding session at depth says another. The test
runs first in the stack because everything else depends on its
answer: the harness compaction threshold, the "gated by" verdict, the
published max context. On this machine every reading comes from
`llama-benchy` on real code text at the server's own sampling, at two
or three depths per row; the `-c` ceiling is the largest value that
loads with every layer on the card.

Two rules to read the tables by:

- **The floor is 8 tok/s**: below it, a config is unusable for
  interactive work, whatever its window says.
- **Used tokens, not allocated.** Allocation is storage.

## Latest per model and backend

<!-- gen:decode-summary:start -->
| best curve | tok/s (shallow → deep) | at | gated by |
|---|--:|--:|---|
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" />](./gemma-4-12b-it.md) | 49.55 → 33.11 | 261k | mem |
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" />](./qwen3.8-27b.md) | 29.36 → 20.92 | 65k | mem |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" />](./qwen3.6-35b-a3b.md) | 61.16 → 45.42 | 97k | mem |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" kv="f16" effort="on" />](./gemma-4-26b-a4b.md) | 58.77 → 45.59 | 97k | mem |
<!-- gen:decode-summary:end -->

## Curves

Run 17, `llama-benchy` on real code text, tok/s. The served arm of each
row is in bold; `-c` is in brackets where an arm needed a smaller one.

| config | 4K | 24K | 65K | 97K | 261K |
|---|--:|--:|--:|--:|--:|
| Gemma-4-12B NVFP4, f16 KV | **49.55** | | | **41.57** (98K) | **33.11** |
| Gemma-4-12B UD-Q4_K_XL, f16 KV | **47.39** | | | **40.26** (98K) | **32.18** |
| Gemma-4-26B-A4B NVFP4Q8, f16 KV, `--n-cpu-moe 7` | **58.77** | | **49.56** | **45.59** | |
| Qwen3.6-35B-A3B UD-Q4_K_XL, q8_0 KV, no drafter, `--n-cpu-moe 17` | 55.81 | | 42.52 | 37.80 | |
| same, n-max 1, `--n-cpu-moe 19` | 60.60 | | 44.12 | 37.92 | |
| same, n-max 2, `--n-cpu-moe 21` | **61.16** | | **50.04** | **45.42** | |
| same, n-max 3, `--n-cpu-moe 21` | 57.85 | | 47.25 | 46.76 | |
| Qwen3.8-27B ISTA IQ3_S-mtp, q8_0 KV, no drafter | **29.43** | **25.89** | **21.13** | | |
| same, n-max 1 (57344) | 33.40 | 29.68 | 24.64 (56K) | | |
| same, n-max 2 (57344) | 45.88 | 31.89 | 26.19 (56K) | | |
| same, n-max 3 (49152) | 37.33 | 30.80 | 31.58 (48K) | | |
| Qwen3.8-27B UD-IQ3_S, q8_0 KV, no drafter | **29.36** | **25.84** | **20.92** | | |
| same, f16 KV (53248) | 29.96 | 27.21 | 24.34 (52K) | | |
| same, q8_0, n-max 1 | 37.16 | 34.34 | 26.28 | | |
| same, q8_0, n-max 2 | 47.05 | 37.84 | 30.82 | | |
| same, q8_0, n-max 3 (57344) | 41.42 | 37.61 | 28.57 (56K) | | |

Every drafter arm reads faster than no drafter at the shared depths.
The dense Qwen3.8 builds serve their agent rows with no drafter: the
ISTA n-max 2 arm left about 440 MiB of the card free and crashed three
times with the desktop on the same card. Raw evidence:
`hardware/arrietty/benchmarks/bench17/` in the repo.

## Method, in one breath

[The measurement rules](../../../methodology/context-creep.md): fixed
real-text corpus, the server's own sampling, two runs per cell,
acceptance beside every drafter cell, GPU memory and host
`MemAvailable` recorded after every cell.
