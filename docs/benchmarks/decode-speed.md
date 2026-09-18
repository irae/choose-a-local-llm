# Decode speed vs context depth

Decode speed at used context, per config. The floor is 8 tok/s. Used
tokens count, not allocated ones. Method:
[context creep](../methodology/context-creep.md).

## Latest per model and backend

<!-- gen:decode-summary:start -->
| best curve | tok/s (shallow → deep) | at |
|---|--:|--:|
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" offload="n-cpu-moe 21" kv="q8_0" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/arrietty/benchmarks/qwen3.6-35b-a3b.md) | <TokCell shallow="61.16" deep="45.42" cap="mem" top-shallow top-deep /> | 97k |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/gemma26-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/gemma-4-26b-a4b.md) | <TokCell shallow="60.1" deep="19.1" cap="mem" top-shallow /> | 197k |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="NVFP4Q8" server="llama-server" publisher="catlilface" repo="catlilface/Gemma-4-26B-A4B-NVFP4-GGUF" offload="n-cpu-moe 7" kv="f16" effort="on" hardware="rtx-5060ti-16gb" page="/binaries/gemma26-catlilface-nvfp4q8" />](../setups/arrietty/benchmarks/gemma-4-26b-a4b.md) | <TokCell shallow="58.77" deep="45.59" cap="mem" top-shallow top-deep /> | 97k |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-mlx-4bit" />](../setups/kamaji/benchmarks/qwen3.6-35b-a3b.md) | <TokCell shallow="54.5" deep="39.1" cap="mem" top-shallow /> | 37k |
| [<ModelSpec base="Gemma-4-12B" quant="NVFP4" server="llama-server" publisher="FreedomAISVR" repo="FreedomAISVR/Gemma-4-12B-it-NVFP4-GGUF" kv="f16" effort="off" hardware="rtx-5060ti-16gb" page="/binaries/gemma12-freedomaisvr-nvfp4" />](../setups/arrietty/benchmarks/gemma-4-12b-it.md) | <TokCell shallow="49.55" deep="33.11" cap="mem" /> | **261k** |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" />](../setups/arrietty/benchmarks/bonsai-27b.md) | <TokCell shallow="46.0" deep="14.5" cap="mem" /> | 208k |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" hardware="m1-max-32gb" page="/binaries/qwen36-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/qwen3.6-35b-a3b.md) | <TokCell shallow="43.7" deep="13.0" cap="speed" /> | 82k |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-ista-iq3s-mtp" />](../setups/arrietty/benchmarks/qwen3.8-27b.md) | <TokCell shallow="29.43" deep="21.13" cap="mem" /> | 65k |
| [<ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" hardware="m1-max-32gb" page="/binaries/gemma12-unsloth-ud-q4kxl" />](../setups/kamaji/benchmarks/gemma-4-12b-it.md) | <TokCell shallow="25.0" deep="9.2" cap="mem" /> | **245k** |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-mlx-2bit" />](../setups/kamaji/benchmarks/bonsai-27b.md) | <TokCell shallow="24.5" deep="17.3" cap="mem" stale /> | 40k |
| [<ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" hardware="m1-max-32gb" page="/binaries/qwen38-mlx-4bit" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | <TokCell shallow="17.3" deep="14.8" cap="mem" /> | 25k |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" hardware="m1-max-32gb" page="/binaries/bonsai-prism-q2g64" />](../setups/kamaji/benchmarks/bonsai-27b.md) | <TokCell shallow="14.7" deep="7.8" cap="speed" /> | 33k |
| [<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-bartowski-q4km" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | <TokCell shallow="12.4" deep="9.7" cap="mem" /> | 72k |

† from an earlier serving config or method; re-run pending.
<!-- gen:decode-summary:end -->

## M1 Max 32 GB, slow creeps

### MLX: flat curves, then a Metal OOM

f16 KV on every row.

| used tokens | Qwen3.6 MLX | Gemma-26B MLX | Gemma-12B LM Studio | Bonsai MLX | Qwen3.8 MLX |
|--:|--:|--:|--:|--:|--:|
| 4K | 53.3 | 51.1 | 34.2 | 24.5 | — |
| 8K | — | — | — | 24.2 | 17.1 |
| 16K | 49.6 | 43.5 | 32.1 | 22.9 | 16.4 |
| 24-25K | — | 39.6 | — | 22.0 | 14.8 |
| 28K | — | — | — | — | **15.3 — last stable** |
| 32-33K | 42.2 | 35.6 | 30.6 | 20.5 | *OOM ~30K* |
| 37K | **42.0 — last stable** | — | — | — | |
| 41-42K | *OOM ~41K* | — | — | 18.7 | |
| 49K | | 28.8 | — | 18.4 | |
| 57-58K | | — | — | **17.3 — last stable** | |
| 65K | | — | 27.1 | *OOM ~60K* | |
| 70K | | **12.8 — last stable** | — | | |
| 74K | | *OOM ~72K* | — | | |
| 98K | | | 24.5 | | |
| 131K | | | **23.2 — last stable** | | |

- Gemma-12B on LM Studio does not end in an OOM: its ceiling is where
  swap starts. LM Studio is retired.

### llama-server and the prism fork (GGUF)

| used tokens | Qwen3.6 +MTP, f16 KV | Qwen3.6 f16 KV, no drafter | Qwen3.6 +MTP, q8_0 KV | Gemma-26B +MTP, f16 KV | Qwen3.8 4-bit +MTP, f16 KV | Qwen3.8 ISTA 3-bit, f16 KV, no drafter | Gemma-12B f16 KV, no drafter | Gemma-12B f16 KV, no drafter, 1 of 2 slots | Gemma-12B +MTP, q8_0 KV | Bonsai fork, f16 KV, no drafter | Bonsai fork, q4_0 KV + bias |
|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| 4K | 69.1 | 49.8 | 43.7 | 60.3 | 11.8 | 14.1 | 24.6 | 25.0 | 13.8 | 15.0 | 14.8 |
| 8K | 71.3 | | 44.1 | — | 18.2 | 13.8 | 24.1 | 24.1 | 8.7 | 16.3 | 13.2 |
| 16K | 65.7 | | 31.2 | 56.5 | 16.1 | 13.3 | 22.7 | 22.8 | *6.5 — floor at 16K* | 15.6 | 10.8 |
| 24-25K | 61.0 | | 24.2 | — | 17.2 | 12.8 | 21.6 | 21.5 | | 15.1 | 9.1 |
| 32-33K | 56.5 | | 19.6 | 45.9 | 16.4 | 12.4 | 20.6 | 20.6 | | 14.5 | *7.9 — floor at 33K* |
| 41K | **52.6 — window end** | **38.3 — window end** | 16.6 | — | 15.6 | 12.0 | 19.5 | 19.5 | | 13.9 | |
| 49K | | | 19.2 | 45.9 | 15.0 | 11.5 | 18.8 | 18.6 | | 13.4 | |
| 65K | | | 11.2 | — | **8.6 — last clean, swap past it** | 10.9 | 17.4 | 16.9 | | 12.5 | |
| 82K | | | **13.0 — last above the floor** | — | | 10.2 | 15.7 | **15.7 — last clean per slot, swap past it** | | 11.5 | |
| 98K | | | *7.9 — floor* | — | | 9.7 | 14.9 | | | 10.8 | |
| 115K | | | | 26.4 | | 9.2 | 13.6 | | | 10.2 | |
| 131K | | | | — | | 8.7 | 13.0 | | | **9.7 — window end, no floor found** | |
| 147K | | | | — | | **8.3 — last above the floor** | — | | | | |
| 164K | | | | — | | *7.9 — floor* | — | | | | |
| 180K | | | | — | | | 10.7 | | | | |
| 197K | | | | **17.3 — last step, `-c` 212992 the largest that loads** | | | — | | | | |
| 213K | | | | | | | 9.7 | | | | |
| 245K | | | | | | | **8.9 — window end** | | | | |

- llama-benchy on real text, 2026-09-11: the Qwen3.6 no-drafter column,
  the Qwen3.6 q8_0 cells at 4K, 49K and 82K, and the Qwen3.8 4-bit
  cells at 4K and 65K. Every other cell is a creep reading.
- Wired limit 25000 (2026-09-06 to 2026-09-09): the Qwen3.6, Qwen3.8
  GGUF, Bonsai f16 and Gemma-12B two-slot columns. Wired limit 24000
  (2026-08-30 to 2026-09-05): the Gemma-26B, Gemma-12B one-slot and
  Bonsai q4_0 columns.
- The DSpark drafter on the Bonsai fork lifts shallow decode, moves the
  floor from about 30K to 20-23K and adds 4-5 GB.
- The MTP drafter on the Qwen3.8 ISTA build loses at every depth: 12.4
  against 14.4 tok/s at depth 256, 7.9 against 9.5 at 98K.
- A 25-second pause between creep steps raised measured ceilings by
  about 2K tokens.

## RTX 5060 Ti 16 GB, llama-benchy, run 17

The served arm of each row is in bold; `-c` is in brackets where an arm
needed a smaller one.

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

- Every drafter arm reads faster than no drafter at the shared depths.
- The ISTA n-max 2 server crashed three times at about 440 MiB of free
  VRAM; the agent rows serve with no drafter.
- Raw evidence: `hardware/arrietty/benchmarks/bench17/` in the repo.
