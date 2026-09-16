# Run 19 — results

The large form of every block (`docs/methodology/status-lines.md`,
"The site comparison, in full"). The `old` row of each pair is the
Mac's EvalPlus row of the same model and level, when one exists.

## EvalPlus

| old/new | model | level | served arm | budget | base | plus | completion | empty |
|---|---|---|---|--:|--:|--:|--:|--:|
| old | Qwen3.8-27B, GGUF IQ3_S-mtp (ISTA GSQ-RCO), q8_0/f16 KV | xhigh | no drafter (kamaji, Mac) | 30000 | 0.945 | 0.921 | 97% | 5/164 |
| new | Qwen3.8-27B, GGUF IQ3_S-mtp (ISTA GSQ-RCO), q8_0 KV | xhigh | drafter (parts 1,2,4) / no drafter (part 3) — owner decision 2026-09-15; a drafter does not change the score at temperature 0 | 20500 | **0.945** | 0.909 | 100% | **0/164** |

Wall (new): 217.6 min, sum of parts 1-4b, gaps excluded
(`state.md`, "Parts"). Two Xid 8 driver-watchdog crashes on the
drafter arm (parts 1-2) triggered a fallback to no-drafter (part 3,
66/164 solved there); owner word put it back on the drafter for part 4,
which finished clean. Every problem counts once regardless of which
arm solved it.
| old | Qwen3.8-27B, GGUF UD-IQ3_S (unsloth) | xhigh | — (no EvalPlus score exists on any machine for this build/level; the Mac's row is "pending") | — | — | — | — | — |
| new | Qwen3.8-27B, GGUF UD-IQ3_S (unsloth), q8_0 KV | xhigh | no drafter — owner decision 2026-09-15; a drafter does not change the score at temperature 0 | 19000 | 0.957 | 0.921 | 100% | 0/164 |

Wall (new): 289.6 min, one part, no crash.
| old | Qwen3.6-35B-A3B, GGUF, MTP, q8_0 KV, thinking on (kamaji, Mac) | thinking on | drafter, n-max unrecorded | — | 0.939 | 0.921 | 97% | ~5/164 |
| new | Qwen3.6-35B-A3B, GGUF UD-Q4_K_XL, MTP q8_0 KV, `--n-cpu-moe 21` | thinking on | drafter, n-max 2 | 24154 | 0.945 | **0.902** | 100% | **0/164** |

Wall (new): 192.0 min, one part, no crash, swap flat throughout.
