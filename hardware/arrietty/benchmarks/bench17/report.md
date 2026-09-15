# Run 17 — report

The large form of the run's status line. See
`docs/methodology/status-lines.md`, "The site comparison, in full", for
the table rules. The first run on `arrietty`, a GeForce RTX 5060 Ti with
16 GB of VRAM, llama.cpp only. This setup had no published rows, so the
`old` row of each pair is the Mac's row of the same model on the
nearest configuration. No EvalPlus ran (owner, 2026-09-13). The runbook
list ran to its end.

Speed and context, the served arm of every row read:

| old/new | Config | Ctx | Cap | tok/s (shallow → deep) |
|---|---|--:|:--:|--:|
| old (Mac, run 16) | Gemma-4-12B GGUF UD-Q4_K_XL, f16 KV | 245k | mem | 25.0 → 9.2 |
| new | Gemma-4-12B GGUF **NVFP4**, f16 KV | **261k** | mem | **49.55 → 33.11** |
| new | Gemma-4-12B GGUF UD-Q4_K_XL, f16 KV | **261k** | mem | **47.39 → 32.18** |
| old (Mac, run 16) | Qwen3.8-27B ISTA IQ3_S-mtp, f16 KV, no drafter | 147k | speed | 14.1 → 8.1 |
| new | Qwen3.8-27B ISTA IQ3_S-mtp, **q8_0 KV**, no drafter | **65k** | **mem** | **29.43 → 21.13** |
| new | Qwen3.8-27B unsloth **UD-IQ3_S**, q8_0 KV, no drafter | 65k | mem | 29.36 → 20.92 |
| old (Mac, run 15) | Qwen3.6-35B-A3B GGUF UD-Q4_K_XL, q8_0 KV, n-max 3 | 82k | speed | 43.7 → 13.0 |
| new | same file, **n-max 2**, `--n-cpu-moe 21` | **97k** | **mem** | **61.16 → 45.42** |
| old (Mac, run 16) | Gemma-4-26B-A4B GGUF UD-Q4_K_XL, f16 KV, n-max 2 | 197k | mem | 60.1 → 19.1 |
| new | Gemma-4-26B-A4B GGUF **NVFP4Q8**, no drafter, `--n-cpu-moe 7` | **97k** | mem | **58.77 → 45.59** |

Draft-depth climbs, real text, the served arm in bold, `-c` in brackets
where the arm needed a smaller one:

| build | no drafter | n-max 1 | n-max 2 | n-max 3 |
|---|--:|--:|--:|--:|
| Qwen3.6-35B-A3B, 4K / 65K / 97K | 55.8 / 42.5 / 37.8 | 60.6 / 44.1 / 37.9 | **61.2 / 50.0 / 45.4** | 57.9 / 47.3 / 46.8 |
| Qwen3.8-27B ISTA, 4K / 24K / deep | **29.4 / 25.9 / 21.1 @64K** | 33.4 / 29.7 / 24.6 @56K (57344) | 45.9 / 31.9 / 26.2 @56K (57344) | 37.3 / 30.8 / 31.6 @48K (49152) |
| Qwen3.8-27B unsloth, 4K / 24K / deep | **29.4 / 25.8 / 20.9 @64K** | 37.2 / 34.3 / 26.3 @64K | 47.1 / 37.8 / 30.8 @64K | 41.4 / 37.6 / 28.6 @56K (57344) |

Mendel, every row new; the Mac's rows of the same models stay on its
pages:

| old/new | test | model | thinking | window | score | libraries |
|---|---|---|---|--:|--:|---|
| new | guided | Gemma-4-12B NVFP4 | off | 258048 | 0, model-failed | 0/8 |
| new | guided | Gemma-4-12B NVFP4 | high | 258048 | 0, model-failed | 0/8 |
| new | guided | Gemma-4-12B UD-Q4_K_XL | high | 258048 | 0, model-failed | 0/8 |
| new | guided | Qwen3.8-27B unsloth UD-IQ3_S | xhigh | 61440 | 79 | 7/8 |
| new | guided | Qwen3.8-27B ISTA IQ3_S-mtp, no drafter | xhigh | 61440 | **85** | **8/8** |
| new | blind | Qwen3.8-27B ISTA IQ3_S-mtp, no drafter | xhigh | 61440 | **91** | **8/8** |
| new | guided | Qwen3.6-35B-A3B UD-Q4_K_XL, n-max 2 | high | 94208 | 48.5 | 6/8 |
| new | guided | Gemma-4-26B-A4B NVFP4Q8 | high | 94208 | 37.5 | 3/8 |

Gates:

| gate | block | result | verdict |
|---|---|---|---|
| seven smokes | every build, ISTA twice | one commit, clean tree, thinking as asked | pass |
| Qwen3.6 NVFP4 file | `sweep-qwen36-nvfp4` | a tensor-count check failed at load | owner: the unsloth UD-Q4_K_XL file instead |
| Qwen3.6 served arm | `sweep-qwen36-q4kxl` | n-max 2 fastest at 4K and 65K | n-max 2, window 94208 |
| ISTA served arm | `sweep-qwen38-ista` | n-max 2 fastest at the shared depths | n-max 2, window 53248 |
| ISTA guided, three server deaths | `qwen38-ista-mendel-guided-xhigh` | GPU launch timeout at 440 MiB free, one with Xid 8 | serving fault, no penalty; served arm changed to no drafter, window 61440 |
| blind qualification | `mendel-blind-after-guided` | only the ISTA build finished 8 of 8 guided | one blind row |

## What the run established

- **The ISTA 3-bit Qwen3.8 is the build for this card.** It is the
  only build that finished the task, 85 guided and 91 blind, on a
  61440 window that is less than half the Mac's 147K. The unsloth file
  of the same model reads at the same speed and stopped at 7 of 8.
- **The card doubles the Mac's decode and cuts the dense window.** The
  3-bit Qwen3.8 reads 29.4 → 21.1 tok/s against the Mac's 14.1 → 8.1,
  but q8_0 KV at 65K is the most that fits; f16 KV serves only 53K.
- **The MTP drafter pays on this card on every build that has one**,
  the opposite of the dense Qwen3.8 on the Mac in run 16. The price is
  VRAM: the dense builds lose 8K to 16K of `-c` at n-max 3, and the
  Qwen3.6 MoE puts four more expert layers in host RAM at n-max 2.
- **A served arm needs headroom for the desktop.** The idle desktop
  holds 1170 MiB of the card. At about 440 MiB free the ISTA n-max 2
  server died three times; at 1.2 GB free the no-drafter arm ran two
  agent rows clean.
- **NVFP4 fits and reads fast, and the model still fails the task.**
  Gemma-4-12B NVFP4 serves the trained window at 49.6 → 33.1 tok/s,
  2 to 5 percent over the k-quant, and both builds end with zero
  commits at both thinking levels: the thinking loops on a planned
  step and never makes the tool call.
- **The MoE builds serve 97K near 45 tok/s from host RAM**, and score
  48.5 (Qwen3.6, a loop at the seventh library) and 37.5 (Gemma-26B, a
  loop at the fourth).

## What the run cost

Twenty-two blocks over about two days, three of them added mid-run by
the owner. Coordinator faults: the ISTA served arm was named on speed
alone, with no check of VRAM headroom, and cost three dead guided
attempts; the checklist and `run-watch.sh` named the session file as
the file to watch, which grows only at the end; the scoring step that
commits the session logs was missed on four rows and done later.
Runner and harness findings: a context compaction dropped the CUDA
library paths from the shell, and one server start loaded on the CPU
before the runner caught it; `score.mjs` counts only a literal
`--no-verify`, so a moved hook file passed unseen until the scorer read
the log. EvalPlus stays unmeasured on this machine.
