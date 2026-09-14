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

### sweep-gemma12-q4kxl

`unsloth/gemma-4-12b-it-GGUF` `gemma-4-12b-it-UD-Q4_K_XL.gguf` rev
`fc034cf`, llama.cpp `0.4.0-dev` (build 10809, sm120/cuda12.8), f16 KV,
no drafter, `--parallel 1`, `-c 262144` (planning value, passed on the
first load). Same depths and tokenizer as `sweep-gemma12-nvfp4`.

| arm | depth | tok/s | sd | prompt tok/s | VRAM used | MemAvailable |
|---|--:|--:|--:|--:|--:|--:|
| f16 | 4096 | 47.39 | 0.03 | 2001.98 | 13052 MiB | 22785 MB |
| f16 | 98304 | 40.26 | 0.02 | 1223.78 | 13052 MiB | 22846 MB |
| f16 | 261120 | 32.18 | 0.25 | 701.69 | 13000 MiB | 22635 MB |

Ladder: `-c 262144` passed at first load. `gemma12_q4kxl_c` = 262144.
VRAM flat (13.0-13.1 GB), no swap growth. Clean depth: 261120,
`gemma12_q4kxl_clean` = 261120.

A table and no pick. The coordinator names the served arm and the KV
type.

### sweep-qwen38-iq3s

`unsloth/Qwen3.8-27B-GGUF` `Qwen3.8-27B-UD-IQ3_S.gguf` rev `4ca7207`,
llama.cpp `0.4.0-dev` (build 10809, sm120/cuda12.8), no drafter,
`--parallel 1`. Two arms by KV type. Mac reference, the ISTA 3-bit at
f16 with no drafter: 14.1 tok/s at 4K, 8.1 tok/s at 147K.

**f16 arm.** Ladder: 65536 failed at load
(`cudaMalloc failed: out of memory`), 32768/49152/57344/61440 passed
at load (6 loads total, the cap), 63488 failed at load. 61440 then
died on a real request with `CUDA error: out of memory` at warmup, so
the load-pass check alone was not enough headroom; stepped `-c` down
8192 to 53248 per the retry rule and it served the deep cell clean.
`qwen38_iq3s_f16_c` = 53248.

| arm | depth | tok/s | sd | prompt tok/s | VRAM used | MemAvailable |
|---|--:|--:|--:|--:|--:|--:|
| f16 | 4096 | 29.96 | 0.30 | 894.65 | 15453 MiB | 23836 MB |
| f16 | 24576 | 27.21 | 0.00 | 836.43 | 15453 MiB | 23880 MB |
| f16 | 52224 | 24.34 | 0.01 | 746.79 | 15453 MiB | 23830 MB |

Clean depth: 52224, `qwen38_iq3s_f16_clean` = 52224. Swap held at
604-638 MB through the sweep, flat, no growth.

**q8_0 arm.** Ladder: `-c 65536` passed at load (14505 MiB, ~1.8 GB
headroom) and served the deep cell clean, no retry needed.
`qwen38_iq3s_q8_c` = 65536.

| arm | depth | tok/s | sd | prompt tok/s | VRAM used | MemAvailable |
|---|--:|--:|--:|--:|--:|--:|
| q8_0 | 4096 | 29.36 | 0.01 | 891.83 | 14527 MiB | 23950 MB |
| q8_0 | 24576 | 25.84 | 0.00 | 829.09 | 14527 MiB | 23900 MB |
| q8_0 | 64512 | 20.92 | 0.00 | 704.54 | 14527 MiB | 23890 MB |

Clean depth: 64512, `qwen38_iq3s_q8_clean` = 64512. Swap flat at 603
MB. The q8_0 arm reaches a wider window than f16 (65536 vs 53248) at a
slightly slower decode speed (20.92 vs 24.34 tok/s at their respective
deep cells).

A table and no pick. The coordinator names the served arm and the KV
type.

## Gates

## Mendel
