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

## `bonsai2-pq2-smoke-xhigh`

`bonsai2_pq2_window` = 208896 (`bonsai2_pq2_clean` 211968 rounded down to a multiple of 4096, at or under `-c` 212992). Registered `bonsai2-27b-pq2` in `~/.pi/agent/models.json` (llama provider, `qwen35`-family template, `reasoning_effort` chat-template kwarg — same pattern as `qwen3.8-27b-iq3s`; backup kept at `~/.pi/agent/models.json.bak-run24`).

`SMOKE_MENDEL_CONTEXT_WINDOW=208896 benchmarks/mendel-smoke.sh bonsai2-27b-pq2 xhigh`: task xtend, 12 tool calls (12 distinct), 1 commit, clean tree, no repetition loop, 0 compactions, peak 4418 tokens, wall 37s. **verdict: pass.** Session log carries 8 reasoning blocks — the thinking-on entry reached the server.

Files: `results/mendel-smoke-bonsai2-pq2.log`.

## `bonsai2-pq2-mendel-blind-xhigh`

`model`: `bonsai2-27b-pq2 (prism-ml PQ2_0, xhigh, arrietty)`. `model_id`: `prism-ml/Ternary-Bonsai-2-27B-gguf`, file `Ternary-Bonsai-2-27B-PQ2_0.gguf`, revision `6ed5e12bf84b7a63069882c91dd9e9218647d17b`. `hardware`: `arrietty`.

Config note: fork `PrismML-Eng/llama.cpp` release `prism-b10685-7dffb15` (commit `7dffb158d`) — **the stock llama.cpp binary produces garbage on this file**; `-c 212992`, cache type q8_0 (`bonsai2-pq2-kvpick`); window 208896 (`bonsai2_pq2_clean` 211968 rounded to a multiple of 4096, `bonsai2-pq2-smoke-xhigh`); reserve 8192, keep-recent pi's default (window > 65536); 0 compactions; `vram 16311 MiB`; sampling as the server applies it, temperature 1.0, top_p 0.95, top_k 20, min_p 0.05 (`bonsai2-pq2-kvpick`, `/props`).

Branch `bonsai2-27b-pq2-xhigh-issue-13`, base commit `2652ed6c`. Started `2026-09-18T08:04:13Z`, ended `2026-09-18T09:36:40Z`, wall 1:32:27. `end_reason`: complete. Loop flag: ok, worst ratio 0.27 (thinking). 16 commits (16 non-chore, 0 multi-package, 0 TASKS.md leaks). 0 nudges (tooling or model), 0 respawns, 0 retries.

| field | value |
|---|--:|
| score | 60/100 |
| tasks | 1/1 (single blind task) |
| worst defect | CRITICAL |
| stop reason | complete |
| tool calls | 245 |
| peak ctx | 192679/208896 (92.2%) |
| known events | 0 |
| elapsed | 1:32:27 |

`peak_context` verified with `benchmark/count-tool-calls.mjs` against the session log: `tool_calls 245, assistant_msgs 216, peak_context 192679` — agrees with the worker's own `contextUsage.tokens`.

**Score: 60/100.** Scored by a judgment subagent from the evidence pack, the session log, and the worktree diff — never from the model's own claims.

**Worst defect: CRITICAL.** Commit `ede1f89c` (`packages/mendel-development/validate-manifest.js`) adds `process.on('exit', () => fs.rmSync(tempDir, {recursive:true, force:true}))` right after the code writes and prints the debug manifest path — the exact trap-C regression the rubric warns about: the file the user needs to inspect is deleted before they can read it.

Per-criterion breakdown (criterion / max / scored / evidence):

| # | criterion | max | scored | evidence |
|--:|---|--:|--:|---|
| 1 | Bugs remaining | 25 | 10 | Critical: exit-hook trap-C regression. Medium: chalk port drops `enableColor` handling entirely (commit `55398f75` removes the level-set line with no replacement; `cli.js:55` and tests still pass `enableColor`). Trap A passed (`trap_a.ok: true`). |
| 2 | Task completion | 20 | 13 | All 8 libraries touched, but `static_completeness.clean: false` — 2 stale `require('rimraf')` in `legacy-packages/mendel-requirify` (trap B, missed, not in TASKS.md), plus stale `rimraf`/`tmp` entries in two `package.json` files. |
| 3 | node_modules pruned | 8 | 0 | `lockfile.numstat: "no change"`, `shrank: false`; no `pnpm install` in the session log; `root_devdeps.removed: false` (`tmp` still declared). |
| 4 | Prettier/ESLint | 5 | 2 | `runtime_checks.eslint.ok: true`; `runtime_checks.prettier.ok: false` (`[warn] TASKS.md`, never reformatted). |
| 5 | Commit craft | 12 | 8 | 16/16 commits `fix(...)`, not `chore`; one package per commit (4/4); no `--no-verify`, no `git add -A`, no TASKS.md leak. |
| 6 | Right the first time | 8 | 8 | No repair/fixup commits; 0 model nudges, 0 tooling nudges. |
| 7 | Test discipline | 10 | 9 | `full_suite_runs: 7` over 16 commits (beats the every-5 mandate); `lint_self_runs: 13`. |
| 8 | House conventions | 5 | 4 | Diffs minimal, style-matched (kept `var`, function shape); one added comment is explanatory, not churn. |
| 9 | Task list | 4 | 4 | TASKS.md lists all 8 libraries upfront, ticked, with discovery notes. |
| 10 | Truncated noisy commands | 3 | 1.5 | `truncation_share: 65%` (50/77 noisy commands piped through tail/head). |

Sum 59.5, rounds to **60/100**.

## `bonsai2-pq2-f16-kvpick`

`Ternary-Bonsai-2-27B-PQ2_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, `--cache-type-k f16 --cache-type-v f16`, `--no-mmproj --parallel 1 -ngl 999 --fit off -fa on --cache-ram 0`, port 8081. Type fixed to f16; only the serving ceiling was open.

Planning value 122880 — the f16 ceiling `bonsai2-pq2-kvpick` already measured for this file, where 131072 failed. Loaded at 122880: pass. The gap to the known fail (131072) is already 8192, the ladder's finest step, so no further bisection is possible or needed.

`bonsai2_pq2_f16_c` = 122880. Verified with one real chat completion (200 OK, correct answer).

Files: `results/server-kvpick-pq2-f16-arm-122880.log`, `results/kvpick-pq2-f16-arm-122880-probe.json`.

## `sweep-bonsai2-pq2-f16`

`Ternary-Bonsai-2-27B-PQ2_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, f16 KV, `-c 122880`, `--cache-ram 0` for the measurement. Tokenizer `unsloth/Qwen3.8-27B`. Corpus `corpus-mendel-js.txt` (restarted for this block). Tool `local-llm-eval-tools` at `204acec`. Depths 4096, 24576, 65536, 121856 (= 122880 − 1024).

| arm | depth | tok/s (tg256) | prompt tok/s (pp512) | VRAM used | MemAvailable |
|---|--:|--:|--:|--:|--:|
| f16 | 4096 | 46.29 ± 0.01 | 969.88 ± 0.52 | 15464 MiB | ~18.6 GB |
| f16 | 24576 | 40.47 ± 0.08 | 899.59 ± 0.29 | 15464 MiB | ~18.6 GB |
| f16 | 65536 | 32.17 ± 0.03 | 761.47 ± 0.13 | 15464 MiB | ~18.6 GB |
| f16 | 121856 | 25.09 ± 0.00 | 625.61 ± 0.04 | 15464 MiB | ~18.6 GB |

VRAM flat across every depth (15464 MiB), no swap growth. Every depth clears the 8 tok/s floor; the deepest tested depth is the deepest clean depth.

`bonsai2_pq2_f16_clean` = 121856 (deepest tested depth, still above the floor at 25.09 tok/s).

Files: `results/benchy-bonsai2-pq2-f16.md`, `results/benchy-bonsai2-pq2-f16.out.log`, `results/benchy-bonsai2-pq2-f16-vm.log`, `results/server-sweep-pq2-f16-arm.log`.

**A table and no pick.**

Files: `results/mendel-blind-bonsai2-pq2.out.log`, `results/mendel-blind-bonsai2-pq2-evidence.json`, session `~/.local/share/mendel-benchmark/runs/bonsai2-27b-pq2-xhigh-blind-session.jsonl`, meta `~/.local/share/mendel-benchmark/runs/bonsai2-27b-pq2-xhigh-blind-meta.json`.

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

## `sweep-bonsai2-ptq1`

`Ternary-Bonsai-2-27B-PTQ1_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, pick q8_0, `-c 245760`, `--cache-ram 0` for the measurement. Tokenizer `unsloth/Qwen3.8-27B`. Corpus `corpus-mendel-js.txt`. Tool `local-llm-eval-tools` at `204acec`. Depths 4096, 24576, 65536, 244736 (= 245760 − 1024).

| arm | depth | tok/s (tg256) | prompt tok/s (pp512) | VRAM used | MemAvailable |
|---|--:|--:|--:|--:|--:|
| q8 | 4096 | 41.69 ± 0.00 | 452.74 ± 0.06 | 15837 MiB | ~18.7 GB |
| q8 | 24576 | 34.89 ± 0.00 | 439.02 ± 0.02 | 15837 MiB | ~18.7 GB |
| q8 | 65536 | 26.48 ± 0.00 | 402.04 ± 0.02 | 15837 MiB | ~18.7 GB |
| q8 | 244736 | 12.79 ± 0.00 | 288.05 ± 0.17 | 15837 MiB | ~18.7 GB |

VRAM flat across every depth (15837 MiB), no swap growth. Every depth clears the 8 tok/s floor; the deepest tested depth is the deepest clean depth.

`bonsai2_ptq1_clean` = 244736 (deepest tested depth, still above the floor at 12.79 tok/s).

Files: `results/benchy-bonsai2-ptq1-q8.md`, `results/benchy-bonsai2-ptq1-q8.out.log`, `results/benchy-bonsai2-ptq1-q8-vm.log`, `results/server-sweep-ptq1-q8.log`.

**A table and no pick.**

## `bonsai2-pq2-mendel-blind-xhigh-f16`

`model`: `bonsai2-27b-pq2-f16 (prism-ml PQ2_0, xhigh, arrietty)`. `model_id`: `prism-ml/Ternary-Bonsai-2-27B-gguf`, file `Ternary-Bonsai-2-27B-PQ2_0.gguf`, revision `6ed5e12bf84b7a63069882c91dd9e9218647d17b`. `hardware`: `arrietty`.

Config note: fork `PrismML-Eng/llama.cpp` release `prism-b10685-7dffb15` (commit `7dffb158d`) — the stock llama.cpp binary produces garbage on this file; `-c 122880`, cache type **f16** (`bonsai2-pq2-f16-kvpick`); window 118784 (`bonsai2_pq2_f16_clean` 121856 rounded to a multiple of 4096, never the q8_0 row's window); reserve 8192, keep-recent pi's default (window > 65536); 1 compaction; `vram 16311 MiB`; sampling as the server applies it, temperature 1.0, top_p 0.95, top_k 20, min_p 0.05. **No smoke: the same file passed its smoke at q8_0 in this run (owner, 2026-09-18).**

Branch `bonsai2-27b-pq2-f16-xhigh-issue-13`, base commit `2652ed6c`. Started `2026-09-18T12:45:31Z`, ended `2026-09-18T14:00:15Z`, wall 1:14:44. `end_reason`: complete. Loop flag: ok, worst ratio 0.35 (thinking). 13 commits, 1 compaction (at threshold, `2026-09-18T13:25:29Z`). 0 nudges, 0 retries.

| field | value |
|---|--:|
| score | 72/100 |
| tasks | 1/1 (single blind task) |
| worst defect | MEDIUM |
| stop reason | complete |
| tool calls | 230 |
| peak ctx | 110354/118784 (92.9%) |
| known events | 1 compaction |
| elapsed | 1:14:44 |

`peak_context` verified with `benchmark/count-tool-calls.mjs` against the session log: `tool_calls 230, assistant_msgs 231, peak_context 110354`. This is the peak over the session, not the post-compaction figure the worker's own `contextUsage.tokens` (99991) reports — the rule is never the value after a compaction.

**Score: 72/100.** Scored by a judgment subagent from the evidence pack, the session log, and the worktree diff — never from the model's own claims. **Correction**: the subagent's own final line claimed 78/100, but its ten-criterion breakdown sums to 72; this run recomputed the sum and used the verified total, 72, not the subagent's unsupported round-up.

**Worst defect: MEDIUM.** The chalk swap keeps `enableColor` forcing (`cli-printer.js:18`, `this._colorEnabled = options.enableColor !== false`; `cli.js:55` still passes `enableColor: true`), against the blind prompt's requirement that color follow Node's own defaults with no forced enable/disable. **The CRITICAL exit-hook regression from the sibling q8_0 row does not repeat here** — `validate-manifest.js` switches cleanly to `fs.mkdtempSync` with no exit hook (confirmed in the worktree diff).

Per-criterion breakdown (criterion / max / scored / evidence):

| # | criterion | max | scored | evidence |
|--:|---|--:|--:|---|
| 1 | Bugs remaining | 25 | 19 | One medium bug, the chalk `enableColor` forcing above. Trap A passes clean (`trap_a.ok: true`). |
| 2 | Task completion | 20 | 15 | 7/8 libraries fully done; `mendel-requirify` still requires `rimraf` in two test files and its `package.json` (trap B missed, `static_completeness.stale_requires`/`stale_package_json`). |
| 3 | node_modules pruned | 8 | 7 | Lockfile shrank by 96 lines; `pnpm install` run and committed, though its output was piped through `tail`. |
| 4 | Prettier/ESLint | 5 | 3 | ESLint clean; Prettier fails on `TASKS.md` only (`runtime_checks.prettier.ok: false`). Model self-ran lint once (`lint_self_runs: 1`). |
| 5 | Commit craft | 12 | 4 | All 13 commits `fix:`, none `chore`; 2 multi-package commits; `git add -A` used in every commit (no `--no-verify`, no TASKS.md leak). |
| 6 | Right the first time | 8 | 8 | No repair/fixup commits; 0 model nudges. |
| 7 | Test discipline | 10 | 8 | `full_suite_runs: 7` across 13 commits, roughly every 2 commits — denser than the every-5 mandate. |
| 8 | House conventions | 5 | 4 | Minimal, style-matched diff (39 files); one explanatory drive-by comment. |
| 9 | Task list | 4 | 3 | Not directly inspectable from the evidence pack; session log shows a per-package commit cadence consistent with progressive discovery. |
| 10 | Truncated noisy commands | 3 | 1 | `truncation_share: 55%` (42/76 noisy commands piped through tail/head). |

Sum 72, exact (subagent's own arithmetic; its reported headline of 78 was not supported and is not used).

Files: `results/mendel-blind-bonsai2-pq2-f16.out.log`, `results/mendel-blind-bonsai2-pq2-f16-evidence.json`, session `~/.local/share/mendel-benchmark/runs/bonsai2-27b-pq2-f16-xhigh-blind-session.jsonl`, meta `~/.local/share/mendel-benchmark/runs/bonsai2-27b-pq2-f16-xhigh-blind-meta.json`.

## `bonsai2-ptq1-f16-kvpick`

`Ternary-Bonsai-2-27B-PTQ1_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, `--cache-type-k f16 --cache-type-v f16`, `--no-mmproj --parallel 1 -ngl 999 --fit off -fa on --cache-ram 0`, port 8081. Type fixed to f16; only the serving ceiling was open.

Planning value 139264 — the f16 ceiling `bonsai2-ptq1-kvpick` already measured for this file, where 147456 aborted on a live CUDA out-of-memory. Loaded at 139264: pass. The gap to the known fail (147456) is already 8192, the ladder's finest step, so no further bisection is possible or needed.

`bonsai2_ptq1_f16_c` = 139264. Verified with one real chat completion (200 OK, correct answer).

Files: `results/server-kvpick-ptq1-f16-arm-139264.log`, `results/kvpick-ptq1-f16-arm-139264-probe.json`.

## `sweep-bonsai2-ptq1-f16`

`Ternary-Bonsai-2-27B-PTQ1_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, f16 KV, `-c 139264`, `--cache-ram 0` for the measurement. Tokenizer `unsloth/Qwen3.8-27B`. Corpus `corpus-mendel-js.txt` (restarted for this block). Tool `local-llm-eval-tools` at `204acec`. Depths 4096, 24576, 65536, 138240 (= 139264 − 1024).

| arm | depth | tok/s (tg256) | prompt tok/s (pp512) | VRAM used | MemAvailable |
|---|--:|--:|--:|--:|--:|
| f16 | 4096 | 42.06 ± 0.04 | 454.29 ± 0.32 | 15353-15357 MiB | ~17.0-17.9 GB |
| f16 | 24576 | 37.31 ± 0.00 | 440.68 ± 0.02 | 15353-15357 MiB | ~17.0-17.9 GB |
| f16 | 65536 | 30.13 ± 0.02 | 404.69 ± 0.01 | 15353-15357 MiB | ~17.0-17.9 GB |
| f16 | 138240 | 22.37 ± 0.04 | 352.89 ± 0.01 | 15353-15357 MiB | ~17.0-17.9 GB |

VRAM flat across every depth (15353-15357 MiB, a 4 MiB drift, no swap growth). Every depth clears the 8 tok/s floor; the deepest tested depth is the deepest clean depth.

`bonsai2_ptq1_f16_clean` = 138240 (deepest tested depth, still above the floor at 22.37 tok/s).

Files: `results/benchy-bonsai2-ptq1-f16.md`, `results/benchy-bonsai2-ptq1-f16.out.log`, `results/benchy-bonsai2-ptq1-f16-vm.log`.

**A table and no pick.**

## `bonsai2-ptq1-mendel-blind-xhigh`

`model`: `bonsai2-27b-ptq1 (prism-ml PTQ1_0, xhigh, arrietty)`. `model_id`: `prism-ml/Ternary-Bonsai-2-27B-gguf`, file `Ternary-Bonsai-2-27B-PTQ1_0.gguf`, revision `6ed5e12bf84b7a63069882c91dd9e9218647d17b`. `hardware`: `arrietty`.

Config note: fork `PrismML-Eng/llama.cpp` release `prism-b10685-7dffb15` (commit `7dffb158d`) — the stock llama.cpp binary produces garbage on this file; `-c 245760`, cache type q8_0 (`bonsai2-ptq1-kvpick`); window 241664 (`bonsai2_ptq1_clean` 244736 rounded to a multiple of 4096, never the f16 arm's window); reserve 8192, keep-recent pi's default (window > 65536); 0 compactions; `vram 16311 MiB`; sampling as the server applies it, temperature 1.0, top_p 0.95, top_k 20, min_p 0.05. **No smoke precedes this row: the larger packing already passed its smoke on this binary at this level, and the owner accepts that evidence for the smaller packing (owner, 2026-09-18). This row ran before any EvalPlus score on this file, so the 0.800 gate does not apply to it (owner, 2026-09-18).**

Branch `bonsai2-27b-ptq1-xhigh-issue-13`, base commit `2652ed6c`. Started `2026-09-18T15:00:43Z`, ended `2026-09-18T17:03:47Z`, wall 2:03:04. `end_reason`: complete. Loop flag: ok, worst ratio 0.28 (thinking). 17 commits, 0 compactions. 1 model nudge (`2026-09-18T16:36:33Z`, "model stopped; TASKS.md has unchecked items"), 0 tooling nudges, 0 retries.

| field | value |
|---|--:|
| score | 57.5/100 |
| tasks | 1/1 (single blind task) |
| worst defect | CRITICAL |
| stop reason | complete |
| tool calls | 254 |
| peak ctx | 225161/241664 (93.2%) |
| known events | 1 nudge |
| elapsed | 2:03:04 |

`peak_context` verified with `benchmark/count-tool-calls.mjs`: `tool_calls 254, assistant_msgs 256, peak_context 225161`.

**Score: 57.5/100.** Scored by a judgment subagent from the evidence pack, the session log, and the worktree diff — never from the model's own claims. The subagent checked its own arithmetic and showed the sum; this run independently re-verified it (10+12+8+0+4+6+9+4+2.5+2 = 57.5, exact).

**Worst defect: CRITICAL.** `packages/mendel-development/validate-manifest.js` adds an exit hook, `process.on('exit', () => fs.rmSync(tempDir, {recursive:true,force:true}))`, one line after the code writes and logs the debug manifest's path — the same trap-C regression class the sibling `bonsai2-27b-pq2` q8_0 row hit (this run's own file, a smaller quant of the same model, reproduces the same defect independently).

Per-criterion breakdown (criterion / max / scored / evidence):

| # | criterion | max | scored | evidence |
|--:|---|--:|--:|---|
| 1 | Bugs remaining | 25 | 10 | Critical exit-hook regression (weight 3) plus a medium chalk regression (weight 2): 25 − 3×5. |
| 2 | Task completion | 20 | 12 | `mendel-requirify` still leaves `rimraf` in 2 test files and its `package.json`; root `package.json` still declares `tmp`. TASKS.md shows the model explicitly reasoned both out of scope. |
| 3 | node_modules pruned | 8 | 8 | `pnpm install --no-audit --no-frozen-lockfile` run to completion; lockfile shrank 93 lines to 0. |
| 4 | Prettier/ESLint | 5 | 0 | `runtime_checks.prettier.ok: false` (`[warn] TASKS.md`), not clean on re-run. |
| 5 | Commit craft | 12 | 4 | 15/17 commits `fix(...)`, not `chore`; no multi-package commits (full credit there); 18 `git add -A` uses forfeit the hygiene component. |
| 6 | Right the first time | 8 | 6 | 1 model nudge ("TASKS.md has unchecked items"), −2 per rubric; no other repair commits. |
| 7 | Test discipline | 10 | 9 | Full-suite runs at commits 5, 10, 15 match the every-5-commits cadence; `full_suite_runs: 7`. |
| 8 | House conventions | 5 | 4 | Tight diff (39 files, +114/−191), style-matched; the exit-hook cleanup is unrequested logic (already penalized under criterion 1). |
| 9 | Task list | 4 | 2.5 | TASKS.md lists all 8 libraries upfront with sub-items, ticked faithfully. |
| 10 | Truncated noisy commands | 3 | 2 | `truncation_share: 50%` (43/86 noisy commands piped through tail/head). |

Sum 57.5, exact.

Files: `results/mendel-blind-bonsai2-ptq1.out.log`, `results/mendel-blind-bonsai2-ptq1-evidence.json`, session `~/.local/share/mendel-benchmark/runs/bonsai2-27b-ptq1-xhigh-blind-session.jsonl`, meta `~/.local/share/mendel-benchmark/runs/bonsai2-27b-ptq1-xhigh-blind-meta.json`.

## `bonsai2-ptq1-f16-mendel-blind-xhigh`

`model`: `bonsai2-27b-ptq1-f16 (prism-ml PTQ1_0, xhigh, arrietty)`. `model_id`: `prism-ml/Ternary-Bonsai-2-27B-gguf`, file `Ternary-Bonsai-2-27B-PTQ1_0.gguf`, revision `6ed5e12bf84b7a63069882c91dd9e9218647d17b`. `hardware`: `arrietty`.

Config note: fork `PrismML-Eng/llama.cpp` release `prism-b10685-7dffb15` (commit `7dffb158d`) — the stock llama.cpp binary produces garbage on this file; `-c 139264`, cache type **f16** (`bonsai2-ptq1-f16-kvpick`); window 135168 (`bonsai2_ptq1_f16_clean` 138240 rounded to a multiple of 4096, never the q8_0 arm's window); reserve 8192, keep-recent pi's default (window > 65536); 1 compaction; `vram 16311 MiB`; sampling as the server applies it, temperature 1.0, top_p 0.95, top_k 20, min_p 0.05. **No smoke precedes this row: the larger packing already passed its smoke on this binary at this level, and the owner accepts that evidence for the smaller packing (owner, 2026-09-18). This row ran before any EvalPlus score on this file, so the 0.800 gate does not apply to it (owner, 2026-09-18).**

Branch `bonsai2-27b-ptq1-f16-xhigh-issue-13`, base commit `2652ed6c`. Started `2026-09-18T17:05:06Z`, ended `2026-09-18T18:33:29Z`, wall 1:28:23. `end_reason`: complete. Loop flag: ok, worst ratio 0.22 (thinking). 17 commits, all `chore` type — unlike the three sibling rows (`fix(...)`), which cost those rows commit-craft points. 1 compaction (at threshold, `2026-09-18T17:58:36Z`). 0 nudges, 0 retries.

| field | value |
|---|--:|
| score | 82/100 |
| tasks | 1/1 (single blind task) |
| worst defect | CRITICAL |
| stop reason | complete |
| tool calls | 258 |
| peak ctx | 127141/135168 (94.1%) |
| known events | 1 compaction |
| elapsed | 1:28:23 |

`peak_context` verified with `benchmark/count-tool-calls.mjs`: `tool_calls 258, assistant_msgs 235, peak_context 127141`.

**Score: 82/100 — the best of the four blind rows in this run.** Scored by a judgment subagent from the evidence pack, the session log, and the worktree diff — never from the model's own claims. The subagent showed its own arithmetic; this run independently re-verified it (13+16+8+5+12+8+9+5+4+2 = 82, exact).

**Worst defect: CRITICAL.** Commit `8918fcc` does a naive `.then()` swap on `fs.promises.glob()` in `packages/mendel-development/apply-extra-options.js` — trap A. The rubric's own runtime repro confirms it throws (`runtime_checks.trap_a.out`: "THREW: TypeError fs.promises.glob(...).then is not a function"). No test in the repo covers this file, so the model never caught it.

**This row does not repeat either sibling defect.** `validate-manifest.js` uses `fs.mkdtempSync` with no exit hook (correct — the trap-C regression the other three rows' PQ2_0/PTQ1_0 q8_0 siblings hit does not appear here). The `tmp` replacements in `mendel-manifest-extract-bundles` and `mendel-manifest-uglify` add `fs.rmSync` inside `t.teardown()`, not a process exit hook — safe. The chalk port fully removes `chalk.level` forcing, matching the blind prompt's Node-defaults instruction exactly (the MEDIUM defect the PQ2_0 f16 sibling carried does not appear here either).

Per-criterion breakdown (criterion / max / scored / evidence):

| # | criterion | max | scored | evidence |
|--:|---|--:|--:|---|
| 1 | Bugs remaining | 25 | 13 | Critical trap A (weight 3) plus one self-acknowledged minor glob dotfile-matching regression in `mendel-mocha-runner` (weight 1): 25 − 3×4. |
| 2 | Task completion | 20 | 16 | All 8 libraries done; model found and explicitly left the `mendel-requirify` `rimraf` reference unfixed ("Out of scope... left alone" in TASKS.md), `static_completeness.clean: false`. |
| 3 | node_modules pruned | 8 | 8 | Real `pnpm install` after nearly every commit; lockfile shrank 96 lines; `root_devdeps.removed: true`. |
| 4 | Prettier/ESLint | 5 | 5 | `eslint.ok: true`; `prettier.ok: false` only flags the uncommitted `TASKS.md`, not branch code; `lint_self_runs: 18`. |
| 5 | Commit craft | 12 | 12 | All 17/17 `chore`, 0 multi-package, no `--no-verify`, no `git add -A`, no TASKS.md leak. |
| 6 | Right the first time | 8 | 8 | No repair/revert commits; 17 planned commits = 17 actual. |
| 7 | Test discipline | 10 | 9 | Full-suite runs after commits 5, 10, 15, and final, matching the every-5-commits cadence (`full_suite_runs: 8`). |
| 8 | House conventions | 5 | 5 | Minimal diffs, keeps existing style conventions, no drive-by churn. |
| 9 | Task list | 4 | 4 | TASKS.md lists libraries upfront, sub-items per package, checked off per commit. |
| 10 | Truncated noisy commands | 3 | 2 | `truncation_share: 74%`, most noisy commands piped through tail/head. |

Sum 82, exact.

Files: `results/mendel-blind-bonsai2-ptq1-f16.out.log`, `results/mendel-blind-bonsai2-ptq1-f16-evidence.json`, session `~/.local/share/mendel-benchmark/runs/bonsai2-27b-ptq1-f16-xhigh-blind-session.jsonl`, meta `~/.local/share/mendel-benchmark/runs/bonsai2-27b-ptq1-f16-xhigh-blind-meta.json`.

## `bonsai2-ptq1-f16-evalplus-calibrate`

`Ternary-Bonsai-2-27B-PTQ1_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, f16 KV (`bonsai2-ptq1-f16-kvpick`), `-c 32768`, no reasoning-budget flag. Calibration name `bonsai2-ptq1-f16-xhigh-think`, alias `bonsai2-27b-ptq1-f16`, extra body `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}`.

| task_id | finish_reason | reasoning_len (chars) |
|---|---|--:|
| HumanEval/0 | stop | 2930 |
| HumanEval/10 | stop | 33291 |
| HumanEval/26 | stop | 2075 |
| HumanEval/32 | length | 94482 |
| HumanEval/38 | stop | 4468 |
| HumanEval/39 | length | 51565 |
| HumanEval/76 | stop | 34657 |
| HumanEval/99 | length | 36846 |
| HumanEval/124 | stop | 7263 |
| HumanEval/145 | stop | 76819 |

7 converged, 3 cut, no converged row with an empty answer.

`thinking-budget.py derive`: converged 7, cut 3, max_reasoning_tokens 23805, max_answer_tokens 274, think_budget 30000 (capped — 23805 × 1.5 = 35707.5 exceeds the 30000 cap), answer_budget 2048 (floor), max_tokens 32048.

`bonsai2_ptq1_f16_think_budget` = 30000, `bonsai2_ptq1_f16_answer_budget` = 2048, `bonsai2_ptq1_f16_max_tokens` = 32048.

Files: `hardware/arrietty/calibrations/calibration-bonsai2-ptq1-f16-xhigh-think.json`, `results/server-bonsai2-ptq1-f16-evalplus-calibrate.log`.

## `bonsai2-ptq1-f16-evalplus-budget-xhigh`

`Ternary-Bonsai-2-27B-PTQ1_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, f16 KV, `-c 32768`, `--reasoning-budget 30000 --reasoning-budget-message "Thinking budget reached. Give the final answer now."`, extra body `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}`, `EVALPLUS_MAX_NEW_TOKENS=32048`. Full 164-problem HumanEval run, `2026-09-18T19:38:36Z` to `2026-09-18T22:53:47Z`, wall 3:15:30.

| metric | value |
|---|--:|
| HumanEval base pass@1 | 0.970 |
| HumanEval plus pass@1 | 0.939 |
| completion rate | 100% |
| empty (from samples) | 0/164 |
| forced (budget fired) | 6/164 |

Forced task ids: `HumanEval/32`, `HumanEval/39`, `HumanEval/80`, `HumanEval/95`, `HumanEval/99`, `HumanEval/137`. Whether each still passed its test is checked in `bonsai2-ptq1-f16-evalplus-forced-rerun` below, not assumed from "not empty."

**This row is the first EvalPlus score for `PTQ1_0` on any cache type.** Base pass@1 0.970 ≥ 0.800.

Files: `results/bonsai2-ptq1-f16-evalplus-budget-xhigh/`, `results/server-bonsai2-ptq1-f16-evalplus-budget-xhigh.log`, `results/watcher-bonsai2-ptq1-f16-evalplus-budget-xhigh.log`, `results/run-bonsai2-ptq1-f16-evalplus-budget-xhigh.out.log`.

## `bonsai2-ptq1-f16-evalplus-forced-rerun`

Natural re-run (no reasoning-budget flags), same config, `EVALPLUS_MAX_NEW_TOKENS=30000`. Prepared from `bonsai2-ptq1-f16-evalplus-budget-xhigh`: 6 forced, 2 forced-failed (`HumanEval/32`, `99`), regenerated only those 2. Wall 0:25:18.

| task_id | cell | forced_tokens | natural_finish | natural_tokens | natural_reasoning_tokens |
|---|---|--:|---|--:|--:|
| HumanEval/32 | forced-fail-loop | 31000 | length | 30000 | 30000 |
| HumanEval/39 | forced-pass | 30540 | | | |
| HumanEval/80 | forced-pass | 30209 | | | |
| HumanEval/95 | forced-pass | 30405 | | | |
| HumanEval/99 | forced-fail-loop | 30212 | length | 30000 | 30000 |
| HumanEval/137 | forced-pass | 30316 | | | |

Summary: forced-pass=4, forced-fail-late=0, forced-fail-loop=2, forced-fail-wrong=0. `corrected_think_budget`: unchanged, no late answer — both forced-failed problems still hit the 30000-token generous cap unconverged, genuine non-convergence.

Files: `results/bonsai2-ptq1-f16-evalplus-forced-rerun/`, `results/server-bonsai2-ptq1-f16-evalplus-forced-rerun.log`, `results/watcher-bonsai2-ptq1-f16-evalplus-forced-rerun.log`, `results/run-bonsai2-ptq1-f16-evalplus-forced-rerun.out.log`.

## `bonsai2-pq2-f16-evalplus-calibrate`

`Ternary-Bonsai-2-27B-PQ2_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, f16 KV, `-c 32768`, no reasoning-budget flag. Calibration name `bonsai2-pq2-f16-xhigh-think`, alias `bonsai2-27b-pq2-f16`, extra body `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}`. All 10 rows resolve `xhigh`. The first row was written in an earlier, stopped pass (started while the ptq1-f16 blind score was pending, stopped when that score won the group order); `calibrate.py` resumed the same file for the rest.

| task_id | finish_reason | reasoning_len (chars) |
|---|---|--:|
| HumanEval/0 | stop | 2740 |
| HumanEval/10 | stop | 65248 |
| HumanEval/26 | stop | 2110 |
| HumanEval/32 | length | 92581 |
| HumanEval/38 | stop | 5025 |
| HumanEval/39 | length | 35182 |
| HumanEval/76 | stop | 29463 |
| HumanEval/99 | length | 33428 |
| HumanEval/124 | length | 98972 |
| HumanEval/145 | stop | 73989 |

6 converged, 4 cut, no converged row with an empty answer.

`thinking-budget.py derive`: converged 6, cut 4, max_reasoning_tokens 22933, max_answer_tokens 365, think_budget 30000 (capped, 22933 × 1.5 = 34399.5 exceeds the cap), answer_budget 2048 (floor), max_tokens 32048.

`bonsai2_pq2_f16_think_budget` = 30000, `bonsai2_pq2_f16_answer_budget` = 2048, `bonsai2_pq2_f16_max_tokens` = 32048.

Files: `hardware/arrietty/calibrations/calibration-bonsai2-pq2-f16-xhigh-think.json`, `results/server-bonsai2-pq2-f16-evalplus-calibrate.log`.
