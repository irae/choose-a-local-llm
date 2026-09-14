# Run 17 — results

The large form of every block (`docs/methodology/status-lines.md`,
"The site comparison, in full"). This setup has no published rows
yet, so the `old` row of every pair is the Mac's row of the same
model, marked `(m1-max-32gb)`, and the note says so.

## Speed and context

### sweep-gemma12-nvfp4

`FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF` `gemma-4-12b-it-nvfp4.gguf`
rev `207974a`, llama.cpp `0.4.0-dev` (build 10809, sm120/cuda12.8), f16
KV, no drafter, `--parallel 1`, `-c 262144` (planning value, passed on
the first load, no ladder search needed). Mac reference, the k-quant at
f16: 25.0 tok/s at 4K, 9.2 tok/s at 245K.

| arm | depth | tok/s | sd | prompt tok/s | VRAM used | MemAvailable |
|---|--:|--:|--:|--:|--:|--:|
| f16 | 4096 | 49.55 | 0.00 | 3040.11 | 12355 MiB | 22711 MB |
| f16 | 98304 | 41.57 | 0.17 | 1542.60 | 12355 MiB | 22738 MB |
| f16 | 261120 | 33.11 | 0.01 | 797.04 | 12630 MiB | 22547 MB |

Ladder: `-c 262144` passed at first load and served the deep cell
clean. `gemma12_nvfp4_c` = 262144. VRAM flat across the sweep (12.3–
12.6 GB), no swap growth. Clean depth (deepest cell at or above 8
tok/s): 261120, `gemma12_nvfp4_clean` = 261120.

A table and no pick. The coordinator names the served arm and the KV
type.

## Gates

## Mendel
