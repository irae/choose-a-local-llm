# Run 24 — results

One section per block: the two KV picks with their ladders, the two
speed tables, the calibration with its derived budgets, the budget
block with score, empties, forced count and wall, the forced re-run
with its report table, and the blind row with its peak context and
tool-call count.

Every row of this run is served with the publisher's llama.cpp fork.
The stock binary produces garbage on these files, so the fork and its
commit belong in every config note.

## `bonsai2-pq2-kvpick`

`Ternary-Bonsai-2-27B-PQ2_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15` (commit `7dffb158d`), `--no-mmproj --parallel 1 -ngl 999 --fit off -fa on`, port 8081.

Ladder, `--cache-type-k q8_0 --cache-type-v q8_0`:

| `-c` | result |
|--:|---|
| 262144 | fail, CUDA OOM allocating 8704 MiB |
| 131072 | pass |
| 196608 | pass |
| 229376 | fail, CUDA OOM allocating 1210 MiB |
| 212992 | pass |

`bonsai2_27b_pq2_c_q8` = 212992. Verified with one real chat completion (200 OK, correct answer).

Ladder, `--cache-type-k f16 --cache-type-v f16`:

| `-c` | result |
|--:|---|
| 131072 | fail, CUDA OOM allocating 262 MiB |
| 65536 | pass |
| 98304 | pass |
| 114688 | pass |
| 122880 | pass |

`bonsai2_27b_pq2_c_f16` = 122880 (131072 not retried; the 5-load budget was spent finding the largest multiple of 8192 below the known fail). Verified with one real chat completion (200 OK, correct answer).

**Pick**: q8_0, larger serving `-c` (212992 vs 122880). `bonsai2_27b_pq2_kv` = `q8_0`, `bonsai2_27b_pq2_c` = 212992.

Sampling defaults the server actually applies (from `/props` at load): `temperature 1.0, top_p 0.95, top_k 20, min_p 0.05`. Note: the runbook's Essentials line names `min_p 0.0` from the GGUF metadata; the served default is `min_p 0.05`. Recorded as measured, not corrected.

Files: `results/server-kvpick-pq2-q8-*.log`, `results/server-kvpick-pq2-f16-*.log`, `results/kvpick-pq2-*-probe.json`.

## `sweep-bonsai2-pq2`

`Ternary-Bonsai-2-27B-PQ2_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, pick q8_0, `-c 212992`, `--cache-ram 0` for the measurement. Tokenizer `unsloth/Qwen3.8-27B`. Corpus `corpus-mendel-js.txt`. Tool `local-llm-eval-tools` at `204acec`. Depths 4096, 24576, 65536, 211968 (= 212992 − 1024).

| arm | depth | tok/s (tg256) | prompt tok/s (pp512) | VRAM used | MemAvailable |
|---|--:|--:|--:|--:|--:|
| q8 | 4096 | 46.04 ± 0.04 | 951.06 ± 0.29 | 15735 MiB | ~18.9 GB |
| q8 | 24576 | 38.17 ± 0.01 | 886.72 ± 0.03 | 15735 MiB | ~18.9 GB |
| q8 | 65536 | 28.23 ± 0.02 | 747.84 ± 0.14 | 15735 MiB | ~18.9 GB |
| q8 | 211968 | 14.51 ± 0.00 | 472.40 ± 0.01 | 15735 MiB | ~18.9 GB |

VRAM flat across every depth (15735 MiB), no swap growth. Every depth clears the 8 tok/s floor; the deepest tested depth is the deepest clean depth.

`bonsai2_pq2_clean` = 211968 (deepest tested depth, still above the floor at 14.51 tok/s; the sweep did not find a depth below the floor).

Files: `results/benchy-bonsai2-pq2-q8.md`, `results/benchy-bonsai2-pq2-q8.out.log`, `results/benchy-bonsai2-pq2-q8-vm.log`, `results/server-sweep-pq2-q8.log`.

**A table and no pick.**
