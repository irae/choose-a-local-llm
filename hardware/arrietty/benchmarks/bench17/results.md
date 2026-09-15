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

### sweep-qwen38-iq3s-mtp

The drafter climb on the unsloth file, at the q8_0 arm's `-c 65536`
(`qwen38_iq3s_q8_c`), so the two providers of this model read at the
same arms. The no-drafter cells above are the base arm.

**n-max 1 arm.** `-c 65536` loaded clean (15550 MiB) and served the
deep-cell probe (64512) clean, no retry needed.

| arm | depth | tok/s | sd | prompt tok/s | acceptance |
|---|--:|--:|--:|--:|--:|
| n-max1 | 4096 | 37.16 | 0.81 | 858.83 | ~0.57-0.93 |
| n-max1 | 24576 | 34.34 | 2.53 | 800.81 | ~0.57-0.93 |
| n-max1 | 64512 | 26.28 | 0.41 | 677.31 | ~0.57-0.93 |

Faster than the no-drafter q8_0 arm at every depth (37.16 vs 29.36 at
4K, 34.34 vs 25.84 at 24K, 26.28 vs 20.92 at 64.5K). Draft acceptance
0.57-0.93, mean draft length ~1.57-1.93. Per the sweep rule, the climb
continues to n-max 2.

**n-max 2 arm.** Same `-c 65536`. Deep-cell probe passed clean first
(28.48 tok/s at depth 64512), then the full sweep.

| arm | depth | tok/s | sd | prompt tok/s | acceptance |
|---|--:|--:|--:|--:|--:|
| n-max2 | 4096 | 47.05 | 1.28 | 858.39 | ~0.41-0.94 |
| n-max2 | 24576 | 37.84 | 5.08 | 800.63 | ~0.41-0.94 |
| n-max2 | 64512 | 30.82 | 5.67 | 677.44 | ~0.41-0.94 |

Faster than n-max1 at every depth (47.05 vs 37.16 at 4K, 37.84 vs
34.34 at 24K, 30.82 vs 26.28 at 64.5K). Draft acceptance 0.41-0.94,
mean draft length ~1.83-2.89, wider spread than n-max1. Per the sweep
rule, the climb continues to n-max 3, the last arm of this block.

**n-max 3 arm.** `-c 65536` (n-max1/n-max2's value) loaded clean but
crashed on the deep-cell request (`CUDA error: out of memory`) — the
same pattern as `sweep-qwen38-ista`'s n-max3 retry. Stepped `-c` down
8192 to 57344 per the retry rule, confirmed clean on the deep-cell
probe. `qwen38_iq3s_mtp_nmax3_c` = 57344.

| arm | depth | tok/s | sd | prompt tok/s | acceptance |
|---|--:|--:|--:|--:|--:|
| n-max3 | 4096 | 41.42 | 1.36 | 858.15 | ~0.28-0.83 |
| n-max3 | 24576 | 37.61 | 2.09 | 799.28 | ~0.28-0.83 |
| n-max3 | 56320 | 28.57 | 0.46 | 698.67 | ~0.28-0.83 |

Slower than n-max2 at both comparable depths (41.42 vs 47.05 at 4K,
37.61 vs 37.84 at 24K; the deep cells are not comparable, 56320 vs
64512, n-max3's own being shallower). Draft acceptance 0.28-0.83, mean
draft length ~1.85-3.50. n-max3 is the last defined arm of this block,
so the climb ends here regardless of the read.

**Climb close.** At the shared 4K and 24K depths, n-max2 is the
fastest arm throughout (47.05 @ 4K, 37.84 @ 24K); n-max1 and n-max3
trail it, n-max3 also serving the smallest window (57344 against
n-max1/n-max2's 65536). Same shape as `sweep-qwen38-ista`'s climb on
the ISTA file: the middle arm (n-max2) wins, the outer arms (n-max1,
n-max3) both trail and n-max3 pays a narrower window for its larger
draft.

A table and no pick. The coordinator names the served arm. Speed only:
the guided row of this build runs with no drafter.

### sweep-gemma26-nvfp4

`catlilface/Gemma-4-26B-A4B-NVFP4-GGUF` `Gemma4-26b-NVFP4Q8.gguf` rev
`dc98839`, llama.cpp `0.4.0-dev` (build 10809, sm120/cuda12.8), f16
KV, one arm, no drafter (`--parallel 1`). This build carries no MTP
layers (`--spec-type draft-mtp` fails at load with "model doesn't
contain MTP layers"), confirming the runbook's own "one arm, no
drafter" shape for this block. `-c 98304` fixed, search target
`--n-cpu-moe`. Mac reference, the k-quant at f16 with n-max 2: 60.1
tok/s at 4K, 28.2 tok/s at 98K.

`--n-cpu-moe` ladder: 12 passed at load (13495 MiB), 6 failed
(`cudaMalloc failed: out of memory`), 9 passed (14719 MiB), 7 passed
at load (15535 MiB) and confirmed on a real request the size of the
deep cell (97280) before committing to it, learning from the
`sweep-qwen38-iq3s` crash earlier in this run.
`gemma26_nvfp4_n_cpu_moe` = 7.

| arm | depth | tok/s | sd | prompt tok/s | VRAM used | MemAvailable |
|---|--:|--:|--:|--:|--:|--:|
| f16 | 4096 | 58.77 | 0.05 | 1365.15 | 15585 MiB | 24242 MB |
| f16 | 65536 | 49.56 | 0.31 | 1177.71 | 15585 MiB | 24267 MB |
| f16 | 97280 | 45.59 | 0.43 | 1078.03 | 15585 MiB | 24232 MB |

Clean depth: 97280, `gemma26_nvfp4_clean` = 97280. VRAM flat, swap flat
at ~1.6 GB. Well above the Mac's 28.2 tok/s at 98K.

A table and no pick. The coordinator names the served arm and the KV
type.

### sweep-qwen36-q4kxl

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF` `Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf`
rev `5bc3e238d916f48a861bac2f8a1990a0e9b7e98d`, llama.cpp `0.4.0-dev`
(build 10809, sm120/cuda12.8), q8_0 KV, `-c 98304`. Mac reference, the
k-quant at q8_0 with n-max 3: 43.7 tok/s at 4K, 13.0 tok/s at 82K.

`--n-cpu-moe` ladder: 20 passed at load (14374 MiB), 14 failed
(`failed to allocate buffer for kv cache`), 17 passed at load (15786
MiB, ~525 MiB headroom) and confirmed on a real deep-cell (97280)
request before committing. `qwen36_q4kxl_n_cpu_moe` = 17.

**No-drafter arm.**

| arm | depth | tok/s | sd | prompt tok/s | VRAM used | MemAvailable |
|---|--:|--:|--:|--:|--:|--:|
| nodraft | 4096 | 55.81 | 0.03 | 540.96 | 15786 MiB | 23411 MB |
| nodraft | 65536 | 42.52 | 0.04 | 506.12 | 15786 MiB | 23304 MB |
| nodraft | 97280 | 37.80 | 0.00 | 491.84 | 15786 MiB | 23226 MB |

Clean depth: 97280, well above the Mac's 13.0 tok/s at 82K. VRAM flat,
swap flat around 4.5-4.7 GB (expected: `--n-cpu-moe 17` spills a large
share of experts to host RAM), no growth trend.

**n-max 1 arm.** The drafter's extra compute buffer needs more
headroom than the no-drafter arm: `--n-cpu-moe 17` OOM'd on the
compute buffer (`cudaMalloc failed`, 512 MiB short), `--n-cpu-moe 19`
passed at load (15750 MiB) and confirmed on a real deep-cell request.
`qwen36_q4kxl_n_cpu_moe_drafter` = 19.

| arm | depth | tok/s | sd | prompt tok/s | acceptance | VRAM used |
|---|--:|--:|--:|--:|--:|--:|
| n-max1 | 4096 | 60.60 | 1.24 | 502.92 | ~0.83-1.00 | 15813 MiB |
| n-max1 | 65536 | 44.12 | 0.07 | 464.00 | ~0.78-0.84 | 15813 MiB |
| n-max1 | 97280 | 37.92 | 0.18 | 450.04 | ~0.76-0.82 | 15813 MiB |

Faster than the no-drafter arm at every depth (60.60 vs 55.81, 44.12
vs 42.52, 37.92 vs 37.80). Draft acceptance mostly 0.78-0.84 mid-run,
mean draft length ~1.8. Per the sweep rule, the climb continues to
n-max 2. VRAM flat, swap flat around 3.7-3.8 GB.

**n-max 2 arm.** `--n-cpu-moe 19` OOM'd on the compute buffer again
(a bigger draft window needs more headroom); `--n-cpu-moe 21` passed
at load (14891 MiB) and confirmed on a real deep-cell request.
`qwen36_q4kxl_n_cpu_moe_nmax2` = 21.

| arm | depth | tok/s | sd | prompt tok/s | acceptance | VRAM used |
|---|--:|--:|--:|--:|--:|--:|
| n-max2 | 4096 | 61.16 | 3.07 | 459.20 | ~0.63-0.92 | 15015 MiB |
| n-max2 | 65536 | 50.04 | 0.61 | 428.46 | ~0.63-0.92 | 15015 MiB |
| n-max2 | 97280 | 45.42 | 3.74 | 420.01 | ~0.63-0.92 | 15015 MiB |

Faster than n-max1 at every depth (61.16 vs 60.60, 50.04 vs 44.12,
45.42 vs 37.92). Draft acceptance 0.63-0.92 mid-run, mean draft length
2.3-2.8 (longer than n-max1's ~1.8, as expected with a larger draft
window). Per the sweep rule, the climb continues to n-max 3. VRAM
flat, swap flat around 4.5 GB.

**n-max 3 arm**, `--n-cpu-moe 21` (same as n-max2, no OOM this time).

| arm | depth | tok/s | sd | prompt tok/s | acceptance | VRAM used |
|---|--:|--:|--:|--:|--:|--:|
| n-max3 | 4096 | 57.85 | 0.39 | 462.94 | ~0.54-0.77 | 14894 MiB |
| n-max3 | 65536 | 47.25 | 2.58 | 423.56 | ~0.54-0.77 | 14894 MiB |
| n-max3 | 97280 | 46.76 | 4.91 | 416.49 | ~0.54-0.77 | 14894 MiB |

Mixed against n-max2: slower at 4K and 65K (57.85 vs 61.16, 47.25 vs
50.04), slightly faster at 97K (46.76 vs 45.42). Draft acceptance
0.54-0.77, mean draft length 2.6-3.3 (highest of the three drafter
arms, as expected with the largest draft window). n-max3 is the last
arm in the climb regardless of this result. VRAM flat, swap flat
around 5.3-5.4 GB.

**sweep-qwen36-q4kxl closes.** Summary across all four arms at 97K
(the deepest, most representative cell): no-drafter 37.80, n-max1
37.92, n-max2 45.42, n-max3 46.76 tok/s. n-max2 and n-max3 read close;
n-max2 needs less VRAM headroom (`--n-cpu-moe` 21 either way here) and
a smaller draft window. A table and no pick — the coordinator names
the served arm.

### sweep-qwen38-ista

`ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF` `Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf`
rev `d562806dbafae37109975e970aae91b43e73b440`, llama.cpp `0.4.0-dev`
(build 10809, sm120/cuda12.8), q8_0 KV, `-c 65536` (planning value from
`qwen38_iq3s_q8_c`, passed on the first load despite the file being 79
MB larger). No sampling flags passed; this file sets its own `min_p
0.0` default (the unsloth file applies `0.05`). Mac reference, this
file at f16 on Metal, no drafter: 14.1 tok/s at 4K, 8.1 tok/s at 147K.

**No-drafter arm.**

| arm | depth | tok/s | sd | prompt tok/s | VRAM used | MemAvailable |
|---|--:|--:|--:|--:|--:|--:|
| nodraft | 4096 | 29.43 | 0.01 | 898.20 | 15111 MiB | 21358 MB |
| nodraft | 24576 | 25.89 | 0.00 | 835.73 | 15111 MiB | - |
| nodraft | 64512 | 21.13 | 0.17 | 709.92 | 15111 MiB | 21387 MB |

Clean depth: 64512, well above the Mac's 8.1 tok/s at 147K (a much
shallower window here, much faster per token). VRAM flat, swap flat
around 5.3 GB. `qwen38_ista_c` = 65536, `qwen38_ista_clean` = 64512.

**n-max 1 arm.** `-c 65536` (the no-drafter arm's value) loaded clean
but crashed on the deep-cell request (`CUDA error: out of memory`) —
the drafter's extra compute buffer needs more headroom than the
no-drafter arm's `-c`, the same pattern as `sweep-qwen36-q4kxl`'s
`--n-cpu-moe`. Stepped `-c` down 8192 to 57344 per the retry rule,
confirmed clean on the deep-cell request. `qwen38_ista_nmax1_c` =
57344.

| arm | depth | tok/s | sd | prompt tok/s | acceptance |
|---|--:|--:|--:|--:|--:|
| n-max1 | 4096 | 33.40 | 0.71 | 821.62 | ~0.61-0.78 |
| n-max1 | 24576 | 29.68 | 0.45 | 796.44 | ~0.61-0.78 |
| n-max1 | 56320 | 24.64 | 0.72 | 686.13 | ~0.61-0.78 |

Faster than the no-drafter arm at every comparable depth (33.40 vs
29.43 at 4K, 29.68 vs 25.89 at 24K; deep cells not directly comparable,
56320 vs 64512). Draft acceptance 0.61-0.78, mean draft length ~1.6-1.8.
Per the sweep rule, the climb continues to n-max 2.

**n-max 2 arm.** Same `-c 57344`. Deep-cell probe passed clean first
(25.12 tok/s at depth 56320), then the full sweep.

| arm | depth | tok/s | sd | prompt tok/s | acceptance |
|---|--:|--:|--:|--:|--:|
| n-max2 | 4096 | 45.88 | 2.22 | 844.43 | ~0.33-0.78 |
| n-max2 | 24576 | 31.89 | 4.38 | 796.11 | ~0.33-0.78 |
| n-max2 | 56320 | 26.19 | 1.60 | 703.26 | ~0.33-0.78 |

Faster than n-max1 at every depth (45.88 vs 33.40 at 4K, 31.89 vs
29.68 at 24K, 26.19 vs 24.64 at 56K). Draft acceptance 0.33-0.78, mean
draft length ~1.66-2.55, wider spread than n-max1. Per the sweep rule,
the climb continues to n-max 3, the last arm of this block.

**n-max 3 arm.** `-c 57344` (n-max2's value) loaded clean but crashed
on the deep-cell request (`CUDA error: out of memory`) — the larger
draft window's compute buffer did not fit, the same pattern as
n-max1's retry. Stepped `-c` down 8192 to 49152 per the retry rule,
confirmed clean on the deep-cell probe. `qwen38_ista_nmax3_c` = 49152.

| arm | depth | tok/s | sd | prompt tok/s | acceptance |
|---|--:|--:|--:|--:|--:|
| n-max3 | 4096 | 37.33 | 0.94 | 860.00 | ~0.32-0.76 |
| n-max3 | 24576 | 30.80 | 0.71 | 804.17 | ~0.32-0.76 |
| n-max3 | 48128 | 31.58 | 1.96 | 726.99 | ~0.32-0.76 |

Slower than n-max2 at both comparable depths (37.33 vs 45.88 at 4K,
30.80 vs 31.89 at 24K; the deep cells are not comparable, 48128 vs
56320, n-max3's own being shallower). Draft acceptance 0.32-0.76, mean
draft length ~1.95-3.27. n-max3 is the last defined arm of this block,
so the climb ends here regardless of the read.

**Climb close.** Deep-cell tok/s by arm (each arm's own deepest cell,
not a matched depth): no-drafter 21.13 @ 64512, n-max1 24.64 @ 56320,
n-max2 26.19 @ 56320, n-max3 31.58 @ 48128 (a shallower window, so not
directly against the other three). At the shared 4K and 24K depths,
n-max2 is the fastest arm throughout (45.88 @ 4K, 31.89 @ 24K); n-max1
and n-max3 trail it, n-max3 also serving the smallest window (49152
against n-max1/n-max2's 57344).

A table and no pick. The coordinator names the served arm.

## Gates

| old/new | gate | model | config | result | verdict |
|---|---|---|---|---|---|
| new | mendel smoke | gemma-4-12b-nvfp4 | f16 KV, `-c 262144`, window 258048, off | 26 calls, 1 commit, clean, no loop, 51s | pass |
| new | mendel smoke | qwen3.8-27b-iq3s | q8_0 KV, `-c 65536`, window 61440, xhigh | 10 calls, 1 commit, clean, no loop, 61s | pass |
| new | mendel smoke | gemma-4-26b-a4b-nvfp4 | f16 KV, `--n-cpu-moe 7`, `-c 98304`, window 94208, high | 10 calls, 1 commit, clean, no loop, 30s | pass |
| new | mendel smoke | gemma-4-12b-q4kxl | f16 KV, `-c 262144`, window 258048, off | 8 calls, 1 commit, clean, no loop, 15s | pass |
| new | mendel smoke | qwen3.6-35b-a3b-q4kxl | q8_0 KV, n-max2, `--n-cpu-moe 21`, `-c 98304`, window 94208, high | 7 calls, 1 commit, clean, no loop, 41s | pass |
| new | mendel smoke | qwen3.8-27b-ista | q8_0 KV, n-max2, `-c 57344`, window 53248, xhigh | 14 calls, 1 commit, clean, no loop, 42s | pass |
| new | mendel guided (interrupted x3) | qwen3.8-27b-ista | q8_0 KV, n-max2, `-c 57344`, window 53248, xhigh | 3 attempts, 3 server deaths (`CUDA error: launch timed out`, one with Xid 8), n_tokens 28213/44064/14686, zero completions | harness fault, no penalty |

## Mendel

| old/new | test | model | harness | score |
|---|---|---|---|--:|
| new | guided | gemma-4-12b-nvfp4 (FreedomAISVR NVFP4, off, rtx-5060ti-16gb) | window 258048, reserve 8192 | 0 (model failed) |
| new | guided | qwen3.8-27b-iq3s (unsloth IQ3_S, xhigh, rtx-5060ti-16gb) | window 61440, reserve 8192 | 79 (partial 7/8) |
| new | guided | gemma-4-26b-a4b-nvfp4 (catlilface NVFP4Q8, high, rtx-5060ti-16gb) | window 94208, reserve 8192 | 37.5 (partial 3/8) |
| new | guided | qwen3.6-35b-a3b-q4kxl (unsloth UD-Q4_K_XL, n-max2, high, rtx-5060ti-16gb) | window 94208, reserve 8192 | 48.5 (partial 6/8) |
| new | guided | gemma-4-12b-q4kxl (unsloth UD-Q4_K_XL, high, rtx-5060ti-16gb) | window 258048, reserve 8192 | 0 (model failed) |
| new | guided | gemma-4-12b-nvfp4 (FreedomAISVR NVFP4, high, rtx-5060ti-16gb) | window 258048, reserve 8192 | 0 (model failed) |
| new | guided | qwen3.8-27b-ista (ISTA-DASLab IQ3_S-mtp, xhigh, rtx-5060ti-16gb) | window 61440, reserve 8192 | **85 (8/8)** |

**gemma12-nvfp4-mendel-guided-off**, model-failed. The model looped on
the same tool call (`bash pnpm remove --filter examples/planout-example
uuid`) five times in a row and the run ended 59 seconds after start
with zero commits, before the first library was even removed. Per
the 2026-09-14 `PLAN.md` update (`invalid` now means only a serving or
harness collapse), a zero-commit run the model caused is `model_failed`
(`invalid: false`, `partial: true`, score 0), never retried on its
own — the label was corrected from the original "invalid" call after
the rule changed. 30 tool calls, peak context 12524/258048 (4.9%).
Scored and published to `~/code/mendel-benchmark` branch `benchmark`,
commit `31214ec9` (relabel commit `7fcb5888`). Row dimmed, dash rank,
excluded from site tables.

**qwen38-ista-mendel-guided-xhigh, three interrupted attempts.** All
three crashed on the same server death signature (`CUDA error: the
launch timed out and was terminated`), never a model action: attempt 1
at `n_tokens` 28213 (no Xid), attempt 2 at 44064 (Xid 8, GPU RC
watchdog, in `journalctl -k`), attempt 3 at 14686 (no Xid). A harness
or hardware collapse, not a model failure, so none of the three carries
a penalty and none is a scored row. Each attempt's worktree, branch and
RUNS evidence is kept, moved aside as `-interrupted1`/`2`/`3`
(`mendel-bench-guided-qwen3.8-27b-ista-xhigh-interrupted{1,2,3}`,
matching branches, and
`~/.local/share/mendel-benchmark/runs/interrupted/qwen3.8-27b-ista-xhigh-guided-attempt{2,3}-*`,
attempt 1 unsuffixed since it was first). The coordinator's read: the
idle desktop holds 1170 MiB on a 16311 MiB card, n-max2 peaks at 15873
MiB (~440 MiB free), a VRAM squeeze that fits three crashes; the
no-drafter arm peaks at 15111 MiB, closer to the completed
`qwen38-iq3s` guided row's 14723 MiB. Served arm changed to no-drafter,
`-c 65536`, window 61440 (`qwen38_ista_clean` 64512 rounded down). The
smoke reruns on the new arm before the guided row retries.

**qwen38-iq3s-mendel-guided-xhigh**, 79/100 raw and capped (the
87.5-point completion cap for 7/8 did not bind), partial. Ran to
`tooling_budget_exhausted` (repeated "premature length stop" nudges,
loop verdict `ok` — not a repetition loop), 7 of 8 libraries done
(uuid, xtend, urlsafe-base64, rimraf, glob, chalk, tmp; `shasum` never
started). Two medium defects: chalk kept the old v2.1
`enableColor`-forced contract instead of v3.0's plain
`util.styleText` behavior, and the rimraf commit missed the
`legacy-packages/mendel-requirify` reference. Full unit suite green
(285/285), lint clean, real `pnpm remove` used throughout. Two prior
attempts (machine-killed by a session-harness false-positive, 1 commit
and 0 commits respectively) are unscored evidence, no penalty; a
mid-run NVIDIA driver GPU-watchdog crash (Xid 8) was caught and
recovered in place with no lost commits, named in the config note
alongside the owner's shared-desktop-VRAM-squeeze addendum. Scored and
published to `~/code/mendel-benchmark` branch `benchmark`, commit
`0ab06c66`.

**gemma26-nvfp4-mendel-guided-high**, 37.5/100 capped (raw 65, the
37.5-point completion cap for 3/8 binds), partial. Ended on a genuine
475x text-repetition loop ("I'll try to `git add` them and then `git
status`."), scored as a valid partial per Mendel's live-loop-stop
rule. 3 of 8 libraries committed (uuid, xtend, urlsafe-base64), but
two of those three carry medium defects found from evidence: xtend's
`.js` requires were removed but its `package.json` entry was never
cleaned (`xtend` still physically in `node_modules`); rimraf's two
target files were fixed but missed the
`legacy-packages/mendel-requirify` reference (trap B). The
uncommitted glob edit reproduces trap A exactly
(`glob(...).then is not a function`) even though `TASKS.md` marks it
done. Only 1 of 6 commits ran the full unit suite first, against
v3.0's rule of one before every commit. Scored and published to
`~/code/mendel-benchmark` branch `benchmark`, commit `48a90699`.

**qwen36-q4kxl-mendel-guided-high**, 48.5/100 raw (the 75-point
completion cap for 6/8 does not bind), partial. Ended on a
repetition loop (5 identical edits on the 7th dependency), 6 of 8
libraries committed (uuid, xtend, urlsafe-base64, rimraf, glob,
chalk). Two shipped critical bugs: `apply-extra-options.js` keeps a
naive `.then()` on `fs.promises.glob()`, an AsyncIterator, throws
`TypeError`; a matching bug in 3 `mendel-deps` test files
(`fs.globSync` called with no `fs` import), 3/3 tests fail. Trap B
(the undisclosed `mendel-requirify` rimraf reference) found and fixed
correctly. Notable: 3 of 6 commits moved `.husky/pre-commit` aside and
back around `git commit`, a functional `--no-verify` bypass the
literal-flag check misses; the bypassed commits (glob, chalk) are
exactly the ones that shipped the two bugs. Scored and published to
`~/code/mendel-benchmark` branch `benchmark`, commit `eb847d6`.

**gemma12-q4kxl-mendel-guided-high**, model-failed, 0/100 (raw 34).
Zero commits. Right after reading `package.json` to locate the `uuid`
dependency, the model's thinking channel cycled "Wait, I'll run the
removal command. / Actually, I'll do it." 818 times, filled the
8192-token output budget in 181s, closed on `repetition_loop` about
5m19s after start. peak_context 24884/258048 (9.6%), 17 tool calls.
Scored and published to `~/code/mendel-benchmark` branch `benchmark`,
commit `8e9a15b6`. Row dimmed, dash rank, excluded from site tables.

**gemma12-nvfp4-mendel-guided-high**, scoring in progress. Same shape
as the q4kxl row above: zero commits, `repetition_loop`, this time on
"I'll replace `xtend(this._result, {` with `Object.assign({}, this._result, {`."
repeated 520 times. Third Gemma-12B guided row this run to end without
a single commit (with `gemma12-nvfp4-mendel-guided-off` and
`gemma12-q4kxl-mendel-guided-high`), each a repetition loop right
after locating a dependency, before the matching edit — worth flagging
as a possible build-level pattern at this harness, not three
independent flukes.

**qwen38-ista-mendel-guided-xhigh**, the retry on the no-drafter served
arm (after three harness crashes on the original n-max2 pick, see
above), scored **85/100** raw (8/8 libraries, completion cap does not
bind) — this run's only 8/8 guided row, qualifying it for
`mendel-blind-after-guided`. All 8 libraries correctly swapped
(uuid, xtend, urlsafe-base64, rimraf, glob, chalk, tmp, shasum). One
critical defect: `apply-extra-options.js` calls `fs.glob(i).then(...)`,
misusing Node's callback-based `fs.glob` as a Promise, throws
immediately, no test covers the file — the same class of bug (wrong
glob variant) `qwen3.6-35b-a3b-q4kxl` shipped above. Trap B found by
the model's own grep near the end, then dismissed as out of scope,
ships unfixed. Otherwise clean: full suite chained before every
commit, no hook bypasses. peak_context 57581/61440 (93.7%), 320 tool
calls, 23 compactions, wall clock 214.8 min. Scored and published to
`~/code/mendel-benchmark` branch `benchmark`, commit `ad51241b`.
