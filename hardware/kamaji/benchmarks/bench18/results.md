# Run 18 — results

The large form of every block (`docs/methodology/status-lines.md`,
"The site comparison, in full"). This build has no published row on
this machine yet, so the `old` row of every pair is the ISTA 3-bit
build of the same model at the same level on this Mac, and the note
says so.

## ladder-qwen38-unsloth

`unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S` rev `4ca7207`, one slot, f16 KV, wired limit 25000.

| rung | result | wired MB |
|--:|---|--:|
| 163840 | pass | 24251 |
| 180224 | pass | 25344 |
| 196608 | fail (Metal OOM) | — |
| 188416 | pass | 25911 |

Ceiling: 188416, wired 25911 MB at load.

## creep-qwen38-unsloth-nodrafter

`unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S` rev `4ca7207`, no drafter, `-c 188416`, f16 KV, wired 25000.

| depth | tok/s | wired MB | swap Δ | compress | decompress |
|--:|--:|--:|--:|--:|--:|
| 4k | 13.70 | 26309 | 0 | 5401 | 1364 |
| 8k | 13.36 | 26299 | 0 | 5421 | 5892 |
| 16k | 12.89 | 26298 | 0 | 381 | 975 |
| 25k | 12.45 | 26299 | 0 | 8786 | 3645 |
| 33k | 12.03 | 26312 | 0 | 858 | 1258 |
| 49k | 11.30 | 26298 | 0 | 9561 | 7148 |
| 66k | 10.60 | 26308 | 0 | 15641 | 6644 |
| 82k | 10.02 | 26298 | 0 | 46015 | 9001 |
| 98k | 9.48 | 26297 | 0 | 28856 | 5471 |
| 115k | 9.00 | 26287 | 0 | 45649 | 19796 |
| 131k | 8.56 | 26257 | 0 | 78511 | 53715 |
| 147k | 8.17 | 26134 | 0 | 140002 | 96024 |
| 164k | 7.81 | 26265 | 0 | 62924 | 43192 |

**speed**, ceiling 147k @ 8.17 tok/s. Floor reached at 164k (7.81 tok/s).
Against the ISTA build (old, same Mac, same level): 14.1 at 4K, 8.3 at 147478, speed gated. This run: 13.70 at 4K, 8.17 at 147478 — close, slightly slower.

## sweep-qwen38-unsloth

`unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S` rev `4ca7207`, f16 KV, wired 25000, one slot, `--cache-ram 0`.

| arm | `-c` | depth | tok/s | peak tok/s |
|---|--:|--:|--:|--:|
| nmax0 (no drafter) | 188416 | 4096 | 13.60 | 14.00 |
| nmax0 (no drafter) | 188416 | 138240 | 8.19 | 9.00 |
| nmax0 (no drafter) | 188416 | 147478 | 7.97 | 8.00 |
| nmax1 | 139264 | 4096 | 12.23 | 13.00 |
| nmax1 | 139264 | 138240 | 7.34 | 8.00 |

Climb stopped after nmax1: slower than nmax0 at both shared depths. nmax2 and nmax3 not run. Beside it, the ISTA file's cells from run 16 on this Mac: 14.1 at 4K, 8.1 at 147K, no drafter. A table and no pick; `qwen38-unsloth-serving` applies the rule.

## Gates

| old/new | gate | model | config | result | verdict |
|---|---|---|---|---|---|
| new | mendel smoke | qwen3.8-27b-iq3s-m1 | unsloth UD-IQ3_S, xhigh | 13 calls, 1 commit, no loop, 206s | pass |
| new | evalplus smoke | qwen3.8-27b-iq3s (unsloth) vs qwen3.8-27b-ista | both xhigh, budget 30000 | 4/4 passed both sides, 0 empty both sides | level |
