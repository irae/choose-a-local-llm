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

## `bonsai2-pq2-calibrate-think`

`Ternary-Bonsai-2-27B-PQ2_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, pick q8_0, `-c 32768`, no reasoning-budget flag. Calibration name `bonsai2-pq2-xhigh-think`, extra body `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}`. All 10 rows resolve `resolved_reasoning_effort: "xhigh"` from the request; no level mismatch.

| task_id | finish_reason | reasoning_len (chars) | wall_s |
|---|---|--:|--:|
| HumanEval/0 | stop | 2474 | 15.6 |
| HumanEval/10 | stop | 41282 | - |
| HumanEval/26 | stop | 3395 | - |
| HumanEval/32 | length | 84642 | 721.0 |
| HumanEval/38 | stop | 4425 | - |
| HumanEval/39 | stop | 9363 | - |
| HumanEval/76 | stop | 48380 | - |
| HumanEval/99 | length | 33429 | 719.8 |
| HumanEval/124 | stop | 11191 | - |
| HumanEval/145 | length | 99016 | 719.1 |

7 converged, 3 cut at the generous wall-clock cap (~720s each, non-convergence, not a token cap). No converged row had an empty answer.

`thinking-budget.py derive`: converged 7, cut 3, max_reasoning_tokens 16806, max_answer_tokens 453, think_budget 25209, answer_budget 2048 (floor), max_tokens 27257.

`bonsai2_pq2_think_budget` = 25209, `bonsai2_pq2_answer_budget` = 2048, `bonsai2_pq2_max_tokens` = 27257.

Files: `hardware/arrietty/calibrations/calibration-bonsai2-pq2-xhigh-think.json`, `results/server-bonsai2-pq2-calibrate-think.log`.

## `bonsai2-pq2-budget-xhigh`

`Ternary-Bonsai-2-27B-PQ2_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, pick q8_0, `-c 32768`, `--reasoning-budget 25209 --reasoning-budget-message "Thinking budget reached. Give the final answer now."`, extra body `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}`, `EVALPLUS_MAX_NEW_TOKENS=27257`. Full 164-problem HumanEval run, `2026-09-18T03:03:04Z` to `2026-09-18T05:58:51Z`, wall 2:56:03. VRAM 8871 MiB stable.

| metric | value |
|---|--:|
| HumanEval base pass@1 | 0.982 |
| HumanEval plus pass@1 | 0.939 |
| completion rate | 100% |
| empty (from samples) | 0/164 |
| forced (budget fired) | 7/164 |

Forced task ids: `HumanEval/32`, `HumanEval/64`, `HumanEval/80`, `HumanEval/91`, `HumanEval/99`, `HumanEval/137`, `HumanEval/145`. Correction: "0 empty" means no sample was blank, not that every forced problem passed its test — `bonsai2-pq2-forced-rerun` below found 4 of the 7 forced problems failed their tests (non-empty wrong answers).

**The agent gate**: base pass@1 0.982 ≥ 0.800 — pass. `bonsai2-pq2-smoke-xhigh` and the blind row proceed.

Files: `results/bonsai2-pq2-budget-xhigh/`, `results/server-bonsai2-pq2-budget-xhigh.log`, `results/watcher-bonsai2-pq2-budget-xhigh.log`, `results/run-bonsai2-pq2-budget-xhigh.out.log`.

## `bonsai2-pq2-forced-rerun`

Natural re-run (no reasoning-budget flags), same config, `EVALPLUS_MAX_NEW_TOKENS=30000`. Prepared from `bonsai2-pq2-budget-xhigh`: 7 forced, 4 forced-failed (`HumanEval/32`, `91`, `99`, `145`), regenerated only those 4. Wall 0:48:28.

| task_id | cell | forced_tokens | natural_finish | natural_tokens | natural_reasoning_tokens |
|---|---|--:|---|--:|--:|
| HumanEval/32 | forced-fail-loop | 26055 | length | 30000 | 30000 |
| HumanEval/64 | forced-pass | 27257 | | | |
| HumanEval/80 | forced-pass | 25425 | | | |
| HumanEval/91 | forced-fail-loop | 25519 | length | 30000 | 30000 |
| HumanEval/99 | forced-fail-loop | 25421 | length | 30000 | 30000 |
| HumanEval/137 | forced-pass | 25621 | | | |
| HumanEval/145 | forced-fail-loop | 25323 | length | 30000 | 30000 |

Summary: forced-pass=3, forced-fail-late=0, forced-fail-loop=4, forced-fail-wrong=0. `corrected_think_budget`: unchanged, no late answer (every forced-failed problem still hit the 30000-token generous cap unconverged — the budget was not too small, these four are genuine non-convergence).

Files: `results/bonsai2-pq2-forced-rerun/`, `results/server-bonsai2-pq2-forced-rerun.log`, `results/watcher-bonsai2-pq2-forced-rerun.log`, `results/run-bonsai2-pq2-forced-rerun.out.log`.

## `bonsai2-ptq1-kvpick`

`Ternary-Bonsai-2-27B-PTQ1_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, `--no-mmproj --parallel 1 -ngl 999 --fit off -fa on`, port 8081.

Ladder, `--cache-type-k q8_0 --cache-type-v q8_0`:

| `-c` | result |
|--:|---|
| 262144 | fail, CUDA OOM allocating 1370 MiB |
| 131072 | pass |
| 196608 | pass |
| 229376 | pass |
| 245760 | pass |
| 253952 | fail, CUDA OOM allocating 1330 MiB |

`bonsai2_27b_ptq1_c_q8` = 245760. Verified with one real chat completion (200 OK, correct answer).

Ladder, `--cache-type-k f16 --cache-type-v f16`:

| `-c` | result |
|--:|---|
| 131072 | pass |
| 196608 | fail, CUDA OOM allocating 12288 MiB |
| 163840 | fail, CUDA OOM allocating 10240 MiB |
| 147456 | fail, CUDA OOM abort during first eval (compute buffer, not the load itself — a live crash, not a clean "model loaded" reject) |
| 139264 | pass |

`bonsai2_27b_ptq1_c_f16` = 139264. Verified with one real chat completion (200 OK, correct answer).

**Pick**: q8_0, larger serving `-c` (245760 vs 139264). `bonsai2_27b_ptq1_kv` = `q8_0`, `bonsai2_27b_ptq1_c` = 245760.

Files: `results/server-kvpick-ptq1-q8-*.log`, `results/server-kvpick-ptq1-f16-*.log`, `results/kvpick-ptq1-*-probe.json`.
