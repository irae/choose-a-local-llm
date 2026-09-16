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
| old | Gemma-4-26B-A4B, GGUF UD-Q4_K_XL (unsloth), MTP f16 KV, thinking on (kamaji, Mac) | thinking on | drafter, n-max 2 | 30000 | 0.884 | 0.860 | 89% | 18/164 |
| new | Gemma-4-26B-A4B, GGUF NVFP4Q8 (catlilface), `--n-cpu-moe 7` | thinking on | none tried (single arm, no drafter option for this build) | 12500 | **0.909** | **0.878** | 100% | **0/164** |

Wall (new): 215.3 min, one part, no crash. A different quant/publisher
than the kamaji pair (NVFP4 vs Q4_K_XL); paired anyway per the "no
same-build score exists" rule since it is the nearest EvalPlus row for
this model.
| old | Gemma-4-12B, GGUF NVFP4 (FreedomAISVR), thinking off | thinking off | — (no EvalPlus ran on this build before, owner note 2026-09-13) | — | — | — | — | — |
| new | Gemma-4-12B, GGUF NVFP4 (FreedomAISVR), f16 KV | thinking off | no drafter | 8192 | 0.927 | 0.896 | 100% | 0/164 |

Wall (new): 51.1 min, one part, no crash. This build's first EvalPlus
score.
| old | Gemma-4-12B, GGUF NVFP4 (FreedomAISVR), thinking on | thinking on | — (no EvalPlus ran on this build before) | — | — | — | — | — |
| new | Gemma-4-12B, GGUF NVFP4 (FreedomAISVR), f16 KV | thinking on | no drafter, budget corrected mid-block (1700 → 8192, floor 8192 applies even non-converging) | 8192 | **0.659** | **0.640** | 100% | 0/164 |

Wall (new): 203.9 min, 2 parts (13.5 + 190.4), gaps excluded. Thinking
on scores far below thinking off on this build (0.659/0.640 vs
0.927/0.896) — a real finding: enabling thinking hurts this model on
HumanEval+, not a budget artifact (0/164 empty at the corrected
budget).
