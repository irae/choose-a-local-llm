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

## Gates

| old/new | gate | model | config | result | verdict |
|---|---|---|---|---|---|
| new | mendel smoke | gemma-4-12b-nvfp4 | f16 KV, `-c 262144`, window 258048, off | 26 calls, 1 commit, clean, no loop, 51s | pass |
| new | mendel smoke | qwen3.8-27b-iq3s | q8_0 KV, `-c 65536`, window 61440, xhigh | 10 calls, 1 commit, clean, no loop, 61s | pass |
| new | mendel smoke | gemma-4-26b-a4b-nvfp4 | f16 KV, `--n-cpu-moe 7`, `-c 98304`, window 94208, high | 10 calls, 1 commit, clean, no loop, 30s | pass |
| new | mendel smoke | gemma-4-12b-q4kxl | f16 KV, `-c 262144`, window 258048, off | 8 calls, 1 commit, clean, no loop, 15s | pass |

## Mendel

| old/new | test | model | harness | score |
|---|---|---|---|--:|
| new | guided | gemma-4-12b-nvfp4 (FreedomAISVR NVFP4, off, rtx-5060ti-16gb) | window 258048, reserve 8192 | 0 (model failed) |
| new | guided | qwen3.8-27b-iq3s (unsloth IQ3_S, xhigh, rtx-5060ti-16gb) | window 61440, reserve 8192 | 79 (partial 7/8) |

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
