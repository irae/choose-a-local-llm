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

## Quality

| old/new | # | Config | Max ctx | Gated by | tok/s (shallow → deep) | Memory | EvalPlus |
|---|--:|---|--:|:--:|--:|--:|--:|
| old | — | Qwen3.8-27B, ISTA GSQ-RCO IQ3_S-mtp, GGUF f16, xhigh | 147456 | speed | 14.1 → 8.3 | wired 25000 | 0.945/0.921/97% (5/164 empty), budget 30000 |
| new | — | Qwen3.8-27B, unsloth UD-IQ3_S, GGUF f16, xhigh | 188416 | speed | 13.70 → 8.17 | wired 25911 | **0.945/0.927**/100% (8/164 empty), budget 20000 |

## Mendel

| old/new | test | model | serving | score | worst defect |
|---|---|---|---|--:|---|
| old | blind | Qwen3.8-27B, ISTA GSQ-RCO IQ3_S-mtp, xhigh | llama-server | 80.5/100, 8/8 | critical |
| new | blind | qwen3.8-27b-iq3s-m1, unsloth UD-IQ3_S, xhigh | llama-server | **90.5/100**, 8/8 | not scored — anomaly (model self-merged master mid-run; row not strictly base-comparable) |
| new | guided | qwen3.8-27b-iq3s-m1, unsloth UD-IQ3_S, xhigh | llama-server | 62.5/100 (76 raw), partial 5/8 | stopped on wall_clock |

Notes:
- **Quality.** Same base pass@1 as the ISTA build on this Mac, a higher `plus` score, at a smaller output budget (20000 vs 30000) and a deeper window (188416 vs 147456, no drafter beats the ISTA build's own drafter comparison too — see the speed table above).
- **Blind.** No earlier blind row on the unsloth build exists on this Mac; the pair is the ISTA build's blind row at the same level, the nearest same-model comparison. The unsloth row carries an anomaly: the model merged `master` into its own branch mid-run on its own reasoning, importing infrastructure the blind base deliberately hides. Coordinator decision (2026-09-14): keep the score as published, mark the row not-base-comparable rather than pairing it cleanly against other blind rows.
- **Guided.** No earlier guided row on this build or the ISTA build exists on this Mac to pair against; reported alone. A valid wall-clock partial (5/8 libraries), not a failure — the model was still productive at the cap.
